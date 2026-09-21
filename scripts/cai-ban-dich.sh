#!/usr/bin/env bash
# =============================================================================
#  TAI BAN DICH TIENG VIET GOC TU GLPI VE MAY
#  Do an thuc tap DLU - He thong ho tro ky thuat (PineDesk)
#
#  Cach dung:
#     bash scripts/cai-ban-dich.sh tai   # tai file .po goc ve .tmp-locale/
#
#  ---------------------------------------------------------------------------
#  CANH BAO — CHE DO 'cai' DA BI GO BO (truoc day la mac dinh).
#  ---------------------------------------------------------------------------
#  Che do do copy thang file .tmp-locale/vi_VN.mo de len
#  /var/www/glpi/locales/vi_VN.mo. Nhung file .mo do chi la LOP PHU (chuoi
#  moi + ghi de), khong phai catalog day du — nen no XOA MAT ~2000 chuoi da
#  dich chinh thuc cua GLPI, va con ghi bang dinh dang .mo hong (offset
#  tuong doi) khien gettext khong doc duoc.
#  Duong di dung la tao lop phu roi GOP vao catalog day du:
#     python scripts/bo-sung-tieng-viet.py       # sinh lop phu
#     python scripts/tao-mo-bo-sung.py           # cai lop phu vao bo_sung/
#     python scripts/gop-ban-dich-tieng-viet.py  # gop + cai catalog day du
# =============================================================================
set -euo pipefail

GLPI_CONTAINER="${GLPI_CONTAINER:-pinedesk-glpi}"
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
  # MSYS_NO_PATHCONV=1: Git Bash tren Windows tu y doi '/var/...' thanh
  # 'C:/Program Files/Git/var/...' khi truyen lam THAM SO cho lenh ngoai.
  MSYS_NO_PATHCONV=1 docker exec "$GLPI_CONTAINER" ls /var/www/glpi/locales/vi_VN.po >/dev/null 2>&1 \
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
#  CHE DO 2 (DA GO BO) — thay bang thong bao loi co huong dan
# =============================================================================
echo "===================================================================" >&2
echo "   [LOI] Che do 'cai' da bi go bo vi no LAM MAT BAN DICH GLPI" >&2
echo "===================================================================" >&2
echo >&2
echo "  Che do nay copy lop phu .tmp-locale/vi_VN.mo de len catalog day du" >&2
echo "  /var/www/glpi/locales/vi_VN.mo, lam mat ~2000 chuoi da dich chinh" >&2
echo "  thuc cua GLPI. Duong di dung:" >&2
echo >&2
echo "     python scripts/bo-sung-tieng-viet.py       # sinh lop phu" >&2
echo "     python scripts/tao-mo-bo-sung.py           # cai lop phu" >&2
echo "     python scripts/gop-ban-dich-tieng-viet.py  # gop + cai" >&2
echo >&2
echo "  Hoac chay toan bo: bash scripts/cai-dat-tat-ca.sh" >&2
echo >&2
exit 1
