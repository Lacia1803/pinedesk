#!/usr/bin/env bash
# =============================================================================
#  TAI & CAI BAN DICH TIENG VIET CHO GLPI
#  Do an thuc tap DLU - He thong ho tro ky thuat (IT Helpdesk)
#
#  Cach dung:
#     bash scripts/cai-ban-dich.sh tai   # chi tai file .po goc ve may
#     bash scripts/cai-ban-dich.sh       # cai ban dich da bo sung vao GLPI
# =============================================================================
set -euo pipefail

GLPI_CONTAINER="${GLPI_CONTAINER:-helpdesk-glpi}"
WORKDIR="$(cd "$(dirname "$0")/.." && pwd)"
THU_MUC="$WORKDIR/.tmp-locale"
mkdir -p "$THU_MUC"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'
ok()   { echo -e "${GREEN}[ OK ]${NC} $1"; }
info() { echo -e "${CYAN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[CANH BAO]${NC} $1"; }
err()  { echo -e "${RED}[LOI]${NC} $1"; }

CHAT_VAO="${1:-cai}"   # 'tai' hoac 'cai'


# =============================================================================
#  CHE DO 1: TAI BAN DICH GOC TU CONTAINER
# =============================================================================
if [ "$CHAT_VAO" = "tai" ]; then
  echo "==================================================================="
  echo "   TAI BAN DICH GOC TIENG VIET TU GLPI"
  echo "==================================================================="
  docker exec "$GLPI_CONTAINER" ls /var/www/glpi/locales/vi_VN.po >/dev/null 2>&1 \
    || { err "Khong thay vi_VN.po trong container"; exit 1; }

  cd "$THU_MUC"
  docker cp "$GLPI_CONTAINER:/var/www/glpi/locales/vi_VN.po" "./vi_VN.po"
  [ -s "./vi_VN.po" ] && ok "Da tai: $(du -h ./vi_VN.po | cut -f1)" || { err "Tai that bai"; exit 1; }

  echo
  echo "  Buoc tiep:  python scripts/bo-sung-tieng-viet.py"
  echo
  exit 0
fi


# =============================================================================
#  CHE DO 2: CAI BAN DICH DA BO SUNG VAO GLPI
# =============================================================================
echo "==================================================================="
echo "   CAI BAN DICH TIENG VIET (DA BO SUNG) VAO GLPI"
echo "==================================================================="

MO_NGUON="$THU_MUC/vi_VN.mo"
[ -s "$MO_NGUON" ] || { err "Chua co vi_VN.mo. Chay truoc:"; echo "   bash scripts/cai-ban-dich.sh tai"; echo "   python scripts/bo-sung-tieng-viet.py"; exit 1; }
ok "Tim thay ban dich bo sung: $(du -h "$MO_NGUON" | cut -f1)"

# QUAN TRONG: 'docker cp' tren Git Bash KHONG hieu duong dan '/g/...'.
# Phai dung duong dan kieu Windows (C:\...) lay tu lenh 'pwd -W'.
MO_NGUON_WIN="$(cd "$THU_MUC" && pwd -W 2>/dev/null || echo "$MO_NGUON")"

# --- 1. Ghi de file .mo goc ---------------------------------------------------
info "Ghi de file vi_VN.mo vao container..."
docker cp "$MO_NGUON_WIN/vi_VN.mo" "$GLPI_CONTAINER:/var/www/glpi/locales/vi_VN.mo"
docker exec "$GLPI_CONTAINER" chown www-data:www-data /var/www/glpi/locales/vi_VN.mo
ok "Da ghi de /var/www/glpi/locales/vi_VN.mo"

# --- 2. Cai qua co che LOCAL I18N (khong bi mat khi nang cap GLPI) -----------
# GLPI quet thu muc GLPI_LOCAL_I18N_DIR: files/_locales/
# va uu tien cac thu muc 'core' / 'core_*' => ghi de ban dich goc.
info "Cai qua co che local i18n (ben vung khi nang cap)..."
docker exec "$GLPI_CONTAINER" sh -c 'mkdir -p /var/glpi/files/_locales/core'
docker cp "$MO_NGUON_WIN/vi_VN.mo" "$GLPI_CONTAINER:/var/glpi/files/_locales/core/vi_VN.mo"
docker exec "$GLPI_CONTAINER" sh -c 'chown -R www-data:www-data /var/glpi/files/_locales'
ok "Da cai vao /var/glpi/files/_locales/core/vi_VN.mo"

# --- 3. Dat tieng Viet lam ngon ngu mac dinh ---------------------------------
info "Dat tieng Viet lam ngon ngu mac dinh..."
# Nap bien .env de ket noi CSDL
ENV_FILE="$WORKDIR/.env"
if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck source=/dev/null
  . "$ENV_FILE"
  set +a
fi
DB_CONTAINER="${DB_CONTAINER:-helpdesk-db}"
if [ -n "${GLPI_DB_PASSWORD:-}" ]; then
  docker exec "$DB_CONTAINER" mariadb -u "${GLPI_DB_USER:-glpi_user}" -p"$GLPI_DB_PASSWORD" glpi -e "
    UPDATE glpi_configs SET value='vi_VN' WHERE name='language';
    UPDATE glpi_users SET language='vi_VN' WHERE language IS NULL OR language='';
  " 2>/dev/null && ok "Da dat vi_VN lam ngon ngu mac dinh" || warn "Khong cap nhat duoc CSDL"
else
  warn "Khong doc duoc GLPI_DB_PASSWORD tu .env -> bo qua buoc nay"
fi

# --- 4. Xoa cache de GLPI nap lai ban dich -----------------------------------
info "Xoa cache ban dich..."
docker exec "$GLPI_CONTAINER" sh -c 'rm -rf /var/glpi/files/_cache/* 2>/dev/null; true'
ok "Da xoa cache"

# --- 5. Khoi dong lai GLPI ----------------------------------------------------
info "Khoi dong lai GLPI de nap ban dich moi..."
docker restart "$GLPI_CONTAINER" >/dev/null && ok "Da khoi dong lai"

echo
echo "==================================================================="
echo "  HOAN TAT CAI BAN DICH TIENG VIET"
echo "==================================================================="
echo
echo "  KIEM TRA:"
echo "    1. Mo http://localhost:8080 -> dang nhap"
echo "    2. Vao Thiet lap cua toi (My settings) -> Ngon ngu = Tieng Viet"
echo "    3. Menu se hien: Tai san / Ho tro / Quan ly / Cau hinh..."
echo
echo "  DO DO PHU BAN DICH:"
echo "    python scripts/kiem-tra-tieng-viet.py"
echo
