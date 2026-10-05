#!/bin/bash
# ==============================================================================
#  SCRIPT NAP DU LIEU NEN VAO PINEDESK
#
#  Cach dung: bash scripts/nap-du-lieu-nen.sh
#
#  Script se:
#    1. Kiem tra he thong dang chay
#    2. Nap danh muc nghiep vu (vi tri, thiet bi, su co...)
#    3. Hien thi ket qua
# ==============================================================================

set -e
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

echo "=============================================================="
echo "   NAP DU LIEU NEN - PINEDESK"
echo "=============================================================="
echo ""

# ---------- Kiem tra he thong dang chay ----------
if ! docker ps --format '{{.Names}}' | grep -q '^pinedesk-db$'; then
    echo "[LOI] He thong chua khoi dong."
    echo "      Hay chay truoc: bash start.sh"
    exit 1
fi
echo "[OK] He thong dang chay"

# ---------- Doc cau hinh ----------
if [ ! -f .env ]; then
    echo "[LOI] Khong tim thay file .env"
    exit 1
fi
# Doc .env bang bo doc AN TOAN dung chung cua du an (scripts/lib/doc-env.sh):
# doc tung dong, bo \r (CRLF cua Notepad), KHONG thuc thi noi dung file.
# shellcheck source=scripts/lib/doc-env.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/doc-env.sh"
doc_env .env || exit 1
echo "[OK] Da doc file cau hinh"
echo ""

# ---------- Xac nhan ----------
echo "[..] Dang nap du lieu vao co so du lieu '${GLPI_DB_NAME:-glpi}'..."
echo "     Script co the chay lai nhieu lan, khong tao du lieu trung."
echo ""

# ---------- Nap du lieu ----------
# BAO MAT: khong truyen mat khau qua -p tren dong lenh (se lo trong argv cua
# tien trinh docker tren may host). Shell ben trong container doc
# $MARIADB_ROOT_PASSWORD (bien san co cua container) roi gan cho MYSQL_PWD.
docker exec -i pinedesk-db sh -c \
    'MYSQL_PWD="$MARIADB_ROOT_PASSWORD" mariadb \
        -u root \
        --default-character-set=utf8mb4 \
        "$1"' _ "${GLPI_DB_NAME:-glpi}" < scripts/seed-du-lieu-nen.sql

echo ""
echo "=============================================================="
echo "   HOAN TAT"
echo "=============================================================="
echo ""
echo "   Buoc tiep theo:"
echo "     1. Mo trinh duyet: https://localhost:${HTTPS_PORT:-8443}"
echo "     2. Dang nhap va kiem tra cac muc:"
echo "        - Assets > Locations      (vi tri phong may)"
echo "        - Assets > Computers      (loai may tinh)"
echo "        - Assistance > Tickets    (loai su co)"
echo "     3. Vao Setup > Dropdowns de xem toan bo danh muc"
echo "=============================================================="
