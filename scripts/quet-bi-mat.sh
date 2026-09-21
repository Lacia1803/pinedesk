#!/usr/bin/env bash
# ==============================================================================
#  QUET BI MAT TRONG MA NGUON  (PineDesk)
# ==============================================================================
#  Vi sao co script nay thay vi vai dong grep trong ci.yml:
#
#  1. Bo quet CU nam ngay trong ci.yml va CHUA CHINH CAC MAT KHAU THAT
#     (regex liet ke thang cac mat khau that) -> ban than no la mot cho ro ri.
#     Khong the "liet ke bi mat cam" ma khong viet ra bi mat do ra. Script nay
#     quet theo HINH DANG (shape), khong theo gia tri cu the.
#
#  2. Bo quet CU chi quet --include='*.sh' --include='*.py' --include='*.js'.
#     Ca hai vu ro ri that deu nam trong .md va .yml -> lot luoi.
#     Script nay quet MOI tep van ban trong Git.
#
#  Cach dung:
#      bash scripts/quet-bi-mat.sh            # quet cay lam viec
#      bash scripts/quet-bi-mat.sh <commit>   # quet mot commit cu
# ==============================================================================
set -uo pipefail

TARGET="${1:-}"

# Loai tru: placeholder, bien moi truong, ten cau hinh cua GLPI, va
# mat khau DEMO (co y cong khai trong README - xem ghi chu cuoi file).
LOAI_TRU='\$\{?[A-Za-z_][A-Za-z0-9_]*\}?|<[A-Za-z_]+>|DOI_MAT_KHAU|example|placeholder|your[_-]?pass|getenv|process\.env|password_need|password_min|password_expiration|non_reusable|password_last_update|basic_auth_password|password_forget|password_init|password2|password_last|Dlu@2026([^A-Za-z0-9]|$)'

quyet() {
    # $1 = nhan, $2 = mau regex
    local nhan="$1" mau="$2" ket_qua
    if [ -n "$TARGET" ]; then
        ket_qua=$(git grep -nIE -e "$mau" "$TARGET" -- . ':!.tmp-*' ':!node_modules' 2>/dev/null \
            | grep -vIE "$LOAI_TRU" || true)
    else
        ket_qua=$(git grep -nIE -e "$mau" -- . ':!.tmp-*' ':!node_modules' 2>/dev/null \
            | grep -vIE "$LOAI_TRU" || true)
    fi
    if [ -n "$ket_qua" ]; then
        echo ""
        echo "[$nhan] NGHI NGO:"
        printf '%s\n' "$ket_qua" | sed 's/^/   /' | head -20
        so=$(printf '%s\n' "$ket_qua" | grep -c . || true)
        TONG=$((TONG + so))
    fi
}

TONG=0
echo "==================================================================="
echo "  QUET BI MAT (${TARGET:-cay lam viec})"
echo "==================================================================="

# P1: mat khau tren dong lenh, co nhay bao quanh, KHONG phai bien.
#     Khop: lenh mariadb/mysql/mysqldump/mysqladmin co -p roi ngay mot chuoi
#           trong nhay (vi du -p theo sau la mot mat khau viet thang).
#     Khong khop: -p"$PW"  hay  setup-python / dashboard-preview
quyet "P1-mat-khau-tren-lenh" \
    '(mariadb|mysql|mysqldump|mysqladmin)[^|]*-p["'"'"'][^"'"'"'$][A-Za-z0-9!@#$%^&*_.+-]{6,}["'"'"']'

# P2: gan mat khau bang literal (khong phai bien/placeholder).
quyet "P2-gan-literal" \
    '(pass(word|wd)?|pwd|secret|api[_-]?key|auth[_-]?token|mat[_-]?khau)[[:space:]]*[:=][[:space:]]*["'"'"']?[A-Za-z0-9][A-Za-z0-9!@#$%^&*_.+-]{7,}'

# P3: MYSQL_PWD gan truc tiep.
quyet "P3-mysql-pwd" \
    'MYSQL_PWD=["'"'"']?[A-Za-z0-9][A-Za-z0-9!@#$%^&*_.+-]{7,}'

# P4: tai lieu mo ta mat khau that (dang tung ro ri trong .md).
#     Tim dong co tu khoa mat khau/tai khoan ROI co mot token chua ky hieu.
if [ -n "$TARGET" ]; then
    dong=$(git grep -nIE -e 'mật khẩu|mat khau|tài khoản|tai khoan|password' "$TARGET" -- . ':!.tmp-*' 2>/dev/null || true)
else
    dong=$(git grep -nIE -e 'mật khẩu|mat khau|tài khoản|tai khoan|password' -- . ':!.tmp-*' 2>/dev/null || true)
fi
if [ -n "$dong" ]; then
    p4=$(printf '%s\n' "$dong" | grep -IE '[A-Za-z0-9]+[!@#$%^&*][A-Za-z0-9]+' \
        | grep -vIE "$LOAI_TRU" || true)
    if [ -n "$p4" ]; then
        echo ""
        echo "[P4-mat-khau-trong-tai-lieu] NGHI NGO:"
        printf '%s\n' "$p4" | sed 's/^/   /' | head -20
        so=$(printf '%s\n' "$p4" | grep -c . || true)
        TONG=$((TONG + so))
    fi
fi

echo ""
if [ "$TONG" -gt 0 ]; then
    echo "==================================================================="
    echo "  [LOI] Phat hien $TONG dong nghi ngo chua bi mat."
    echo "  Sua: dung bien moi truong (\$GLPI_DB_PASSWORD) hoac placeholder."
    echo "==================================================================="
    exit 1
fi
echo "==================================================================="
echo "  [OK] Khong phat hien bi mat hardcode."
echo "==================================================================="

# ------------------------------------------------------------------------------
#  GHI CHU: vi sao mien tru 'Dlu@2026'
#  Day la mat khau tai khoan DEMO (ktv.an, gv.cuong, sv.hoa...) duoc seed boi
#  scripts/nap-du-lieu-mau.sh va CO Y cong khai trong README de trinh dien do an.
#  No KHONG phai bi mat that cua he thong trien khai.
#  Mau mien tru dung 'Dlu@2026([^A-Za-z0-9]|$)' de KHONG che mat khau quan tri
#  that (chuoi 'Dlu@2026' noi lien them mot hau to chu cai).
# ------------------------------------------------------------------------------
