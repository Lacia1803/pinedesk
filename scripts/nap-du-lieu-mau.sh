#!/bin/bash
# ==============================================================================
#  NAP DU LIEU MAU DE DEMO - HE THONG HO TRO KY THUAT (PINEDESK) DLU
# ==============================================================================
#  CACH DUNG:
#    bash scripts/nap-du-lieu-mau.sh
#
#  SCRIPT NAY LAM GI:
#    1. Nap du lieu mau (thiet bi, phieu su co, phan mem) tu file .sql
#    2. Dat mat khau cho 6 tai khoan mau (bcrypt hash - KHONG the lam bang SQL
#       thuan vi phai dung ham password_hash cua PHP)
#    3. Kiem tra ket qua va bao cao
#
#  TAI KHOAN MAU TAO RA (mat khau: Dlu@2026):
#    ktv.an    / ktv.binh   -> Ky thuat vien (Technician)
#    gv.cuong  / gv.dung    -> Giang vien (Requester)
#    sv.hoa    / sv.khanh   -> Sinh vien (Requester)
#
#  DAC TINH: idempotent - chay lai nhieu lan khong sinh du lieu trung.
# ==============================================================================

set -e

# ------------------------------------------------------------------------------
#  Git Bash tren Windows: `pwd` tra ve duong dan POSIX (/g/...) gay loi cho
#  Python/duong dan Windows. Phai dung `pwd -W` de lay duong dan Windows that.
# ------------------------------------------------------------------------------
_winpath() {
    local p="$1"
    if pwd -W >/dev/null 2>&1; then
        (cd "$p" && pwd -W)
    else
        (cd "$p" && pwd)
    fi
}

HERE="$(_winpath "$(dirname "${BASH_SOURCE[0]}")")"
ROOT="$(_winpath "$(dirname "${BASH_SOURCE[0]}")/..")"
cd "$ROOT" || exit 1

export MSYS_NO_PATHCONV=1
export MSYS2_ARG_CONV_EXCL='*'

# Doc .env AN TOAN (de in dung cong HTTPS trong thong bao cuoi).
# shellcheck source=scripts/lib/doc-env.sh
. "$HERE/lib/doc-env.sh"
doc_env "$ROOT/.env" || true

MAT_KHAU_MAC_DINH="Dlu@2026"
SQL_FILE="$HERE/seed-du-lieu-mau.sql"

echo "=============================================================="
echo "   NAP DU LIEU MAU DE DEMO"
echo "=============================================================="
echo ""

# ---------- 1. Kiem tra container dang chay ----------
if ! docker ps --format '{{.Names}}' | grep -q '^pinedesk-db$'; then
    echo "[LOI] Container pinedesk-db khong chay."
    echo "      Hay khoi dong: bash scripts/cai-dat-tat-ca.sh"
    exit 1
fi

if [ ! -f "$SQL_FILE" ]; then
    echo "[LOI] Khong tim thay file $SQL_FILE"
    exit 1
fi

# ---------- 2. Nap du lieu mau ----------
echo "[1/4] Dang nap du lieu mau (thiet bi, phieu su co, phan mem)..."

DB_ERR=$(docker exec -i pinedesk-db sh -c \
    'MYSQL_PWD="$MARIADB_ROOT_PASSWORD" mariadb -uroot glpi' < "$SQL_FILE" 2>&1 | grep -i "^ERROR" || true)

if [ -n "$DB_ERR" ]; then
    echo "[LOI] Nap du lieu that bai:"
    echo "$DB_ERR"
    exit 1
fi
echo "      [OK] Da nap xong."

# ---------- 3. Dat mat khau cho tai khoan mau ----------
# Khong the lam bang SQL thuan: mat khau GLPI dung bcrypt (password_hash cua PHP).
# Phai goi PHP trong container GLPI de sinh hash, roi ghi vao CSDL.
# LUU Y: phai ghi hash ra FILE roi docker cp, KHONG truyen qua shell string
#        vi ky tu '$' trong hash se bi shell an mat -> mat khau sai.
echo ""
echo "[2/4] Dang dat mat khau cho tai khoan mau..."

TMP_HASH=".tmp-hash-$$.txt"

if ! docker exec pinedesk-glpi php -r \
    "echo password_hash('${MAT_KHAU_MAC_DINH}', PASSWORD_BCRYPT);" > "$TMP_HASH" 2>/dev/null; then
    echo "[LOI] Khong sinh duoc mat khau (container pinedesk-glpi co chay khong?)"
    rm -f "$TMP_HASH"
    exit 1
fi

HASH=$(cat "$TMP_HASH" | tr -d '\r\n')

# Kiem tra hash co dung dinh dang bcrypt khong (phai bat dau bang $2y$)
case "$HASH" in
    \$2y\$*|\$2a\$*|\$2b\$*) : ;;
    *)
        echo "[LOI] Hash sinh ra khong hop le: '$HASH'"
        rm -f "$TMP_HASH"
        exit 1
        ;;
esac

docker cp "$TMP_HASH" pinedesk-db:/tmp/hash.txt >/dev/null 2>&1
rm -f "$TMP_HASH"

docker exec pinedesk-db sh -c '
    H=$(cat /tmp/hash.txt)
    MYSQL_PWD="$MARIADB_ROOT_PASSWORD" mariadb -uroot glpi -e "
        UPDATE glpi_users
        SET password = \"$H\",
            password_last_update = NOW(),
            is_active = 1
        WHERE name IN (\"ktv.an\",\"ktv.binh\",\"gv.cuong\",\"gv.dung\",\"sv.hoa\",\"sv.khanh\");
    "
    rm -f /tmp/hash.txt
' >/dev/null 2>&1

echo "      [OK] Da dat mat khau '${MAT_KHAU_MAC_DINH}' cho 6 tai khoan."

# ---------- 4. Kiem tra nguon du lieu tham chieu (tranh du lieu bi NULL) ----------
echo ""
echo "[3/4] Kiem tra chat luong du lieu (cac truong bat buoc)..."

NULL_CHECK=$(docker exec pinedesk-db sh -c '
    MYSQL_PWD="$MARIADB_ROOT_PASSWORD" mariadb -uroot glpi -N -e "
        SELECT COUNT(*) FROM glpi_computers
          WHERE computermodels_id IS NULL OR computermodels_id = 0
             OR manufacturers_id IS NULL OR manufacturers_id = 0
             OR states_id IS NULL OR states_id = 0
             OR locations_id IS NULL OR locations_id = 0
        UNION ALL
        SELECT COUNT(*) FROM glpi_tickets
          WHERE itilcategories_id IS NULL OR itilcategories_id = 0;
    "' 2>/dev/null | awk '{s+=$1} END {print s}')

if [ "$NULL_CHECK" = "0" ]; then
    echo "      [OK] Khong co truong tham chieu nao bi rong."
else
    echo "      [CANH BAO] Con $NULL_CHECK truong tham chieu bi rong."
fi

# ---------- 5. Bao cao ket qua ----------
echo ""
echo "[4/4] Ket qua:"
echo ""

docker exec -i pinedesk-db sh -c \
    'MYSQL_PWD="$MARIADB_ROOT_PASSWORD" mariadb -uroot glpi' < "$SQL_FILE" 2>/dev/null | tail -15

echo ""
echo "=============================================================="
echo "   HOAN TAT"
echo "=============================================================="
echo ""
echo " Tai khoan demo (mat khau: ${MAT_KHAU_MAC_DINH}):"
echo "   ktv.an    | ktv.binh    -> Ky thuat vien"
echo "   gv.cuong  | gv.dung     -> Giang vien"
echo "   sv.hoa    | sv.khanh    -> Sinh vien"
echo ""
echo " Truy cap: https://localhost:${HTTPS_PORT:-8443}"
echo ""
