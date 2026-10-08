#!/usr/bin/env bash
# =============================================================================
#  CAI PLUGIN SINH MA QR / BARCODE CHO GLPI
#  Plugin: pluginsGLPI/barcode  (AGPL-3.0)
#  Tac gia script: do an thuc tap DLU - He thong ho tro ky thuat (PineDesk)
#
#  Cach dung:
#     bash scripts/cai-plugin-qrcode.sh
#
#  Script se:
#    1. Tai plugin barcode tu GitHub
#    2. Copy vao volume pinedesk-glpi-plugins
#    3. Cai dat plugin qua CLI cua GLPI (khong can bam tay tren web)
#    4. Kiem tra ket qua
# =============================================================================
set -euo pipefail

GLPI_CONTAINER="${GLPI_CONTAINER:-pinedesk-glpi}"
PLUGIN_NAME="barcode"
PLUGIN_VERSION="2.7.1"
# Nap bien tu file .env (GLPI_DB_USER, GLPI_DB_PASSWORD...) de truy van CSDL.
# Dung bo doc AN TOAN dung chung (scripts/lib/doc-env.sh) — KHONG `source`
# (source thuc thi noi dung file nhu ma lenh va am tham cat cut mat khau
# chua ky tu dac biet; xem giai thich dau file thu vien).
# shellcheck source=scripts/lib/doc-env.sh
. "$(cd "$(dirname "$0")/.." && pwd)/scripts/lib/doc-env.sh"
doc_env "$(cd "$(dirname "$0")/.." && pwd)/.env" || true
GLPI_DB_USER="${GLPI_DB_USER:-glpi_user}"
GLPI_DB_PASSWORD="${GLPI_DB_PASSWORD:-}"
DB_CONTAINER="${DB_CONTAINER:-pinedesk-db}"
# QUAN TRONG: Phai dung goi RELEASE (dinh dang .tar.bz2) chu KHONG dung nhanh
# 'develop' (.tar.gz), vi goi release da dong goi san thu muc 'vendor/' chua
# cac thu vien can thiet (deltalab/phpqrcode, pear/Image_Barcode, rospdf/pdf-php).
# Nhanh develop thieu vendor/ nen plugin se bao loi:
#   "require_once(.../vendor/autoload.php): Failed to open stream"
PLUGIN_URL="https://github.com/pluginsGLPI/barcode/releases/download/${PLUGIN_VERSION}/glpi-barcode-${PLUGIN_VERSION}.tar.bz2"

# CANH BAO: phan "Ep tuong thich GLPI 11" ben duoi (doi MAX_GLPI, thay
# $DB->query() bang $DB->doQuery()) duoc viet RIENG cho ban ${PLUGIN_VERSION}.
# Neu nang PLUGIN_VERSION, PHAI doc lai setup.php/hook.php cua ban moi va cap
# nhat cac lenh sed cho khop — neu khong, ban va co the khong con ap dung va
# plugin se loi tren GLPI 11 (hoac te hon: va im lang, khong bao loi).
# Script da kiem chung lai sau khi va: "So loi goi query() cu con lai (phai = 0)"
# va trang thai state=1 trong CSDL.

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'
ok()   { echo -e "${GREEN}[ OK ]${NC} $1"; }
info() { echo -e "${CYAN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[CANH BAO]${NC} $1"; }
err()  { echo -e "${RED}[LOI]${NC} $1"; }

echo "==================================================================="
echo "   CAI PLUGIN MA QR / BARCODE CHO GLPI"
echo "==================================================================="

# --- 0. Kiem tra container dang chay -----------------------------------------
if ! docker ps --format '{{.Names}}' | grep -q "^${GLPI_CONTAINER}$"; then
  err "Container '${GLPI_CONTAINER}' khong chay. Chay './start.sh' truoc."
  exit 1
fi
ok "Container ${GLPI_CONTAINER} dang chay"

# --- 1. Kiem tra extension can thiet (QR can bcmath/gd) ----------------------
info "Kiem tra PHP extension (bcmath, gd)..."
docker exec "$GLPI_CONTAINER" php -r '
  $need = ["bcmath","gd"];
  $miss = [];
  foreach ($need as $e) { if (!extension_loaded($e)) { $miss[] = $e; } }
  if ($miss) { echo "THIEU: ".implode(",", $miss)."\n"; exit(1); }
  echo "DU: bcmath, gd\n";
' && ok "Extension day du" || { err "Thieu extension. Xem lai config/php-custom.ini"; exit 1; }

# --- 2. Tai plugin ------------------------------------------------------------
WORKDIR="$(cd "$(dirname "$0")/.." && pwd)"
# Dung thu muc tam NGAY TRONG PROJECT de tranh loi dich duong dan Windows/Git Bash
# (mktemp -d tren Git Bash tra ve /c/Users/... lam 'tar' hieu sai thanh host 'C:')
TMPDIR="$WORKDIR/.tmp-plugin"
rm -rf "$TMPDIR"; mkdir -p "$TMPDIR"
# QUAN TRONG: 'curl' tren Git Bash cua Windows bi loi (23) khi ghi ra duong dan
# tuyet doi kieu '/g/...' hoac 'C:/...'. Vi vay ta 'cd' vao thu muc tam va dung
# duong dan TUONG DOI cho moi thao tac tai/ghi file.
cd "$TMPDIR"

info "Dang tai plugin (ban release ${PLUGIN_VERSION}) tu GitHub..."
if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$PLUGIN_URL" -o "barcode.tar.bz2"
elif command -v wget >/dev/null 2>&1; then
  wget -q "$PLUGIN_URL" -O "barcode.tar.bz2"
else
  err "Khong co curl/wget."; exit 1
fi
[ -s "barcode.tar.bz2" ] || { err "Tai that bai (file rong)."; exit 1; }
ok "Da tai ($(du -h "barcode.tar.bz2" | cut -f1))"

info "Giai nen..."
mkdir -p extract
tar -xjf "barcode.tar.bz2" -C "extract"
SRC_DIR="$(find "extract" -mindepth 1 -maxdepth 1 -type d | head -1)"
[ -n "$SRC_DIR" ] && [ -d "$SRC_DIR" ] || { err "Khong tim thay thu muc plugin sau khi giai nen"; exit 1; }
[ -f "$SRC_DIR/vendor/autoload.php" ] || { err "Goi tai ve thieu thu muc vendor/ - khong the cai."; exit 1; }
ok "Thu muc nguon: $(basename "$SRC_DIR") (co vendor/ day du)"
# Lay duong dan kieu WINDOWS (C:\...) vi 'docker cp' khong hieu '/g/...' cua Git Bash
SRC_DIR_WIN="$(cd "$SRC_DIR" && { pwd -W 2>/dev/null || pwd; })"

# --- 3. Copy vao volume plugin cua GLPI --------------------------------------
info "Copy plugin vao volume pinedesk-glpi-plugins..."

# Tao volume neu chua co
docker volume inspect pinedesk-glpi-plugins >/dev/null 2>&1 || docker volume create pinedesk-glpi-plugins >/dev/null

# Copy bang 'docker cp' -> container tam
CID="$(docker create -v pinedesk-glpi-plugins:/dest alpine:3.20 sh -c 'sleep 1')"
docker cp "$SRC_DIR_WIN/." "$CID:/dest/${PLUGIN_NAME}"
docker start "$CID" >/dev/null
docker exec "$CID" chown -R 33:33 "/dest/${PLUGIN_NAME}" 2>/dev/null || true
docker rm -f "$CID" >/dev/null 2>&1 || true

ok "Da copy plugin '${PLUGIN_NAME}' vao volume"

# --- 4. Ep tuong thich GLPI 11 -------------------------------------------------
info "Dieu chinh plugin de chay tren GLPI 11..."
docker exec "$GLPI_CONTAINER" sh -c '
  F=/var/www/glpi/plugins/barcode/setup.php
  if [ -f "$F" ]; then
    # Plugin goc ghi: define(PLUGIN_BARCODE_MAX_GLPI, "10.0.99")  => chan GLPI 11
    # Noi long len 99.0.99 de GLPI 11 chap nhan cai dat
    sed -i "s/PLUGIN_BARCODE_MAX_GLPI., *.10\.0\.99./PLUGIN_BARCODE_MAX_GLPI'"'"', '"'"'99.0.99'"'"'/" "$F"
  fi

  # SUA LOI QUAN TRONG: GLPI 11 da VO HIEU hoa $DB->query() (nem exception
  # "Executing direct queries is not allowed!"). Plugin barcode 2.7.1 van dung
  # ham cu nay trong hook.php => phai doi sang $DB->doQuery().
  H=/var/www/glpi/plugins/barcode/hook.php
  if [ -f "$H" ]; then
    sed -i "s/\\\$DB->query(/\\\$DB->doQuery(/g" "$H"
  fi

  rm -rf /var/www/glpi/files/_cache/* 2>/dev/null || true
'
echo "    -> Rang buoc phien ban hien tai:"
docker exec "$GLPI_CONTAINER" sh -c "grep -E \"PLUGIN_BARCODE_(MIN|MAX)_GLPI\" /var/www/glpi/plugins/barcode/setup.php | sed 's/^/       /'" 2>&1
echo "    -> So loi goi query() cu con lai (phai = 0):"
docker exec "$GLPI_CONTAINER" sh -c "grep -c 'DB->query(' /var/www/glpi/plugins/barcode/hook.php 2>/dev/null || echo 0" 2>&1 | sed 's/^/       /'
ok "Da xu ly tuong thich GLPI 11 (version + doQuery)"

# --- 5. Kiem tra GLPI nhan dien plugin ---------------------------------------
info "Kiem tra GLPI nhan dien plugin..."
docker exec "$GLPI_CONTAINER" sh -c 'ls /var/www/glpi/plugins/barcode/setup.php >/dev/null 2>&1 && echo CO' | grep -q CO \
  && ok "File setup.php ton tai" \
  || { err "Plugin khong nam dung vi tri"; exit 1; }

# --- 6. Tu dong cai dat + kich hoat qua CLI ----------------------------------
info "Dang cai dat plugin qua dong lenh GLPI (khong can bam tay)..."
INSTALL_OK=0
if docker exec -u www-data "$GLPI_CONTAINER" php /var/www/glpi/bin/console plugin:install barcode -u glpi 2>&1 | tee /dev/stderr | grep -qiE 'Plugin .* installed|has been installed'; then
  INSTALL_OK=1
fi
# Thu lai neu lan dau khong bat duoc ket qua tu output. LUU Y NGUOC CHIEU:
# plugin:install BAT BUOC phai co `-u` (thieu `-u` console dung lai hoi
# "User to use:" roi huy, da do bang lenh that); nguoc lai plugin:activate
# KHONG nhan `-u`. Hai lenh khac nhau ve tham so.
if [ "$INSTALL_OK" -eq 0 ]; then
  docker exec -u www-data "$GLPI_CONTAINER" php /var/www/glpi/bin/console plugin:install barcode -u glpi 2>&1 | tail -5 || true
fi

echo
echo "    -> Trang thai plugin trong CSDL:"
if [ -n "$GLPI_DB_PASSWORD" ]; then
  # BAO MAT: khong dung -p"$GLPI_DB_PASSWORD" (lo trong argv tren host).
  # Shell trong container doc $MARIADB_PASSWORD cua chinh no -> MYSQL_PWD.
  docker exec "$DB_CONTAINER" sh -c '
    MYSQL_PWD="$MARIADB_PASSWORD" mariadb -u "$MARIADB_USER" "$MARIADB_DATABASE" \
      -e "SELECT name, version, state FROM glpi_plugins WHERE directory='"'"'barcode'"'"';"' \
    2>/dev/null | sed 's/^/       /' || echo "       (chua co ban ghi - can cai qua giao dien web)"
else
  echo "       (khong doc duoc GLPI_DB_PASSWORD tu .env)"
fi

# Kich hoat (enable) neu da cai.
# BAI HOC TU LOI THAT (CI bat duoc sau khi them cua dem plugin): tuy chon
# `-u glpi` CHI co o plugin:install, KHONG co o plugin:activate cua GLPI 11.
# Truyen `-u` vao activate lam console in usage roi thoat ma loi, bi `|| true`
# che mat -> tren may sach barcode ket o state=4 (da cai, chua bat) va chi con
# 2 plugin bat thay vi 3. Da do truc tiep `plugin:activate --help` de xac nhan.
docker exec -u www-data "$GLPI_CONTAINER" php /var/www/glpi/bin/console plugin:activate barcode 2>&1 | tail -3 || true

# Kiem chung THAT SU da bat chua (state=1). Khong tin ma tra ve cua lenh:
# plugin:activate tra loi ca khi plugin DA bat (chay lai lan 2), do khong
# phai loi that, nhung cung khong phai bang chung da bat. Xem state trong CSDL.
if [ -n "$GLPI_DB_PASSWORD" ]; then
  STATE=$(docker exec "$DB_CONTAINER" sh -c '
    MYSQL_PWD="$MARIADB_PASSWORD" mariadb -u "$MARIADB_USER" "$MARIADB_DATABASE" \
      -N -B -e "SELECT state FROM glpi_plugins WHERE directory='"'"'barcode'"'"';"' \
    2>/dev/null | tr -d '\r' || true)
  if [ "$STATE" = "1" ]; then
    ok "Plugin barcode da bat (state=1)"
  else
    err "Plugin barcode CHUA bat duoc (state='${STATE:-khong co ban ghi}')"
    exit 1
  fi
else
  warn "Khong doc duoc mat khau CSDL tu .env -> bo qua buoc kiem chung state"
fi

echo
echo "==================================================================="
echo "  HOAN TAT CAI DAT PLUGIN"
echo "==================================================================="
echo
echo "  NEU PLUGIN DA O TRANG THAI 'activated' o tren => XONG, dung ngay duoc."
echo
echo "  NEU CHUA (GLPI 11 chan plugin cu): lam theo cach thu cong:"
echo "    1. Mo:  http://localhost:8080"
echo "    2. Dang nhap bang tai khoan quan tri (glpi/glpi hoac tai khoan da doi)"
echo "    3. Vao:  Cau hinh (Setup)  ->  Plugin"
echo "    4. Tim 'Barcode' trong danh sach  ->  bam 'Cai dat' (Install)"
echo "    5. Sau khi cai xong  ->  bam 'Bat' (Enable)"
echo
echo "  CACH SU DUNG:"
echo "    - Vao:  Thiet bi (Assets) -> May tinh (Computers)"
echo "    - Tich chon cac may can in nhan"
echo "    - Mo menu 'Hanh dong hang loat' (Massive actions)"
echo "    - Chon 'In ma QR' (print a QRcode) hoac 'In ma vach' (print a bar code)"
echo
warn "Neu GLPI 11 van bao loi tuong thich: dung GIAI PHAP DU PHONG (sinh QR bang Python)"
echo "    -> Xem tai-lieu/README.md (muc 6.2 'Phuong an du phong')"
echo "    -> Chay: python scripts/sinh-ma-qr.py"
echo

# --- Don dep thu muc tam ------------------------------------------------------
rm -rf "$TMPDIR" 2>/dev/null || true

exit 0
