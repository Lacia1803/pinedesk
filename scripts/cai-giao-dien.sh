#!/usr/bin/env bash
# =============================================================================
#  CAI GIAO DIEN "DA LAT" CHO GLPI
#  Do an thuc tap DLU - He thong ho tro ky thuat (PineDesk)
#
#  Script se:
#    1. Copy logo DLU vao thu muc anh duoc GLPI phuc vu qua web
#    2. Xoa cache CSS de GLPI bien dich lai cac bang mau
#    3. Kich hoat bang mau "Da Lat" lam mac dinh
#    4. Kiem tra ket qua
#
#  Cach dung:
#     bash scripts/cai-giao-dien.sh
# =============================================================================
set -euo pipefail

GLPI_CONTAINER="${GLPI_CONTAINER:-pinedesk-glpi}"
WORKDIR="$(cd "$(dirname "$0")/.." && pwd)"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'
ok()   { echo -e "${GREEN}[ OK ]${NC} $1"; }
info() { echo -e "${CYAN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[CANH BAO]${NC} $1"; }
err()  { echo -e "${RED}[LOI]${NC} $1"; }

echo "==================================================================="
echo "   CAI GIAO DIEN 'DA LAT' CHO GLPI"
echo "==================================================================="

# --- 0. Kiem tra container ----------------------------------------------------
docker ps --format '{{.Names}}' | grep -q "^${GLPI_CONTAINER}$" \
  || { err "Container '${GLPI_CONTAINER}' khong chay. Chay './start.sh' truoc."; exit 1; }
ok "Container dang chay"

# --- 1. Kiem tra file bang mau ------------------------------------------------
THEME_DIR="$WORKDIR/themes"
so_bang_mau=$(find "$THEME_DIR" -maxdepth 1 -name '*.scss' 2>/dev/null | wc -l)
[ "$so_bang_mau" -gt 0 ] || { err "Khong thay file .scss nao trong themes/"; exit 1; }
info "Tim thay ${so_bang_mau} bang mau:"
find "$THEME_DIR" -maxdepth 1 -name '*.scss' -exec basename {} \; | sed 's/^/       - /'

# --- 2. Copy logo DLU vao thu muc plugin duoc phuc vu qua web ----------------
# dlu-theme.css tro --glpi-logo-* vao /plugins/dlubrand/pics/logos/...
# GLPI 11 phuc vu /plugins/<ten>/... tu thu muc public/ cua plugin, nen dich
# dung la plugins/dlubrand/public/pics/logos/. Truoc day script copy vao
# /var/www/glpi/public/pics/logos/ — noi khong con ai doc, nen logo tren dia
# host khong bao gio duoc dung.
info "Cai logo DLU vao plugin dlubrand..."
LOGO_DIR="$THEME_DIR/pics/logos"
LOGO_DICH="$WORKDIR/plugins/dlubrand/public/pics/logos"
if [ -d "$LOGO_DIR" ]; then
  mkdir -p "$LOGO_DICH"
  so_logo=0
  for f in "$LOGO_DIR"/*.png; do
    [ -f "$f" ] || continue
    cp -f "$f" "$LOGO_DICH/"
    so_logo=$((so_logo + 1))
  done
  docker exec "$GLPI_CONTAINER" sh -c 'chown -R www-data:www-data /var/www/glpi/plugins/dlubrand/public/pics 2>/dev/null || true'
  ok "Da cai logo: ${so_logo} file -> plugins/dlubrand/public/pics/logos/"
else
  warn "Khong thay thu muc themes/pics/logos -> bo qua logo"
fi

# --- 3. Xoa cache de GLPI bien dich lai --------------------------------------
info "Xoa cache CSS (buoc GLPI bien dich lai bang mau)..."
docker exec "$GLPI_CONTAINER" sh -c '
  rm -rf /var/glpi/files/_cache/* 2>/dev/null || true
  rm -rf /var/www/glpi/public/css_compiled/* 2>/dev/null || true
  true
'
ok "Da xoa cache"

# --- 4. Dat bang mau "Da Lat" lam mac dinh -----------------------------------
info "Dat bang mau 'da_lat' lam mac dinh..."
THEME_KEY="${THEME_KEY:-da_lat}"
ENV_FILE="$WORKDIR/.env"
if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck source=/dev/null
  . "$ENV_FILE"
  set +a
fi
DB_CONTAINER="${DB_CONTAINER:-pinedesk-db}"
if [ -n "${GLPI_DB_PASSWORD:-}" ]; then
  # GLPI luu bang mau dang chon trong: session (glpipalette).
  # Gia tri mac dinh cho nguoi dung moi nam o bang glpi_users > palette (neu co).
  #
  # Mau do uu tien (priority_1..6) nam trong bang glpi_configs CHU KHONG phai
  # trong CSS. Mac dinh cua GLPI la dai mau hong do (#fff2f2 -> #ff5555) —
  # khong he co trong logo DLU va lech han voi dai mau uu tien ma dlu-theme.css
  # mo ta (xam suong -> xanh ho -> cam dat -> cam chay -> do sao). Doi o day
  # de thanh uu tien doc ra dung the gioi Da Lat. Dung chung cho MOI bang mau.
  #
  # app_name: ten ung dung hien tren THE TRINH DUYET ("<trang> - <app_name>")
  # va trong chu ky email. Mac dinh GLPI la "GLPI" -> moi the tab deu ghi
  # "... - GLPI", lo ngay day la GLPI chua tuy bien. Cot nay khong co san
  # trong bang glpi_configs nen phai INSERT; bang co khoa duy nhat (context,
  # name) nen dung ON DUPLICATE KEY UPDATE de chay lai script khong loi.
  # Ten 'PineDesk DLU' phai KHOP voi ten hien tren landing page (PineDesk).
  docker exec "$DB_CONTAINER" mariadb -u "${GLPI_DB_USER:-glpi_user}" -p"$GLPI_DB_PASSWORD" glpi -e "
    UPDATE glpi_users SET palette='$THEME_KEY' WHERE palette IS NULL OR palette='';
    INSERT INTO glpi_configs (context, name, value) VALUES ('core', 'app_name', 'PineDesk DLU')
      ON DUPLICATE KEY UPDATE value='PineDesk DLU';
    UPDATE glpi_configs SET value='#EDF0E4' WHERE name='priority_1';
    UPDATE glpi_configs SET value='#CFE0DE' WHERE name='priority_2';
    UPDATE glpi_configs SET value='#F6D9A8' WHERE name='priority_3';
    UPDATE glpi_configs SET value='#F0A870' WHERE name='priority_4';
    UPDATE glpi_configs SET value='#CC2430' WHERE name='priority_5';
    UPDATE glpi_configs SET value='#9E1A24' WHERE name='priority_6';
  " 2>/dev/null && ok "Da dat bang mau mac dinh = $THEME_KEY + dai mau uu tien + ten ung dung" \
    || warn "Khong cap nhat duoc CSDL"
else
  warn "Khong doc duoc mat khau CSDL -> bo qua"
fi

# --- 5. Kiem tra phuc vu bang mau --------------------------------------------
info "Kiem tra GLPI bien dich bang mau..."
sleep 2
while IFS= read -r key; do
  [ -n "$key" ] || continue
  code=$(curl -sk -o /dev/null -w "%{http_code}" \
    "https://localhost:8443/front/css.php?file=${key}&is_custom_theme=1" 2>/dev/null || echo "000")
  if [ "$code" = "200" ]; then
    ok "  ${key}: HTTP 200 (bien dich thanh cong)"
  else
    warn "  ${key}: HTTP ${code}"
  fi
done < <(find "$THEME_DIR" -maxdepth 1 -name '*.scss' -exec basename {} .scss \;)

echo
echo "==================================================================="
echo "  HOAN TAT CAI GIAO DIEN"
echo "==================================================================="
echo
echo "  CHON BANG MAU (tren trinh duyet):"
echo "    1. Mo https://localhost:8443"
echo "    2. Vao:  Thiet lap cua toi (My settings)"
echo "    3. Muc 'Giao dien' (Interface) -> chon bang mau:"
echo "         · Da lat          -> Xanh reu DLU (mac dinh, khuyen dung)"
echo "         · Da lat suong    -> Xanh ngoch suong mai (nhe mat)"
echo "         · Da lat nang     -> Cam dat DLU (man hinh lon)"
echo "    4. Bam 'Luu' (Save)"
echo
echo "  BANG MAU LAY TU DAU:"
echo "    Mau chinh xac trich xuat tu logo chinh thuc DH Da Lat (2025):"
echo "       #F08418  cam dat   (vong hoa van, mat troi)"
echo "       #607824  xanh reu  (nui, dong chu 'DAI HOC DA LAT')"
echo "       #90B43C  xanh la   (suon nui sang)"
echo "       #C0CC84  xanh nhat (doi thong)"
echo "       #CC2430  do        (ngoi sao)"
echo
