#!/bin/bash
# ==============================================================================
#  SCRIPT SAO LUU HE THONG PINEDESK (GLPI)
#
#  CACH DUNG:
#    bash backup/backup.sh                 -> sao luu ngay, giu 7 ban gan nhat
#    bash backup/backup.sh --keep 30       -> giu 30 ban gan nhat
#    bash backup/backup.sh --dir /path     -> doi thu muc sao luu
#
#  HEN LICH TU DONG (Windows Task Scheduler):
#    Program : C:\Program Files\Git\bin\bash.exe
#    Argument: -c "cd /g/<DUONG-DAN-DU-AN>/pinedesk && bash backup/backup.sh"
#    Trigger : Hang ngay luc 23:00
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$SCRIPT_DIR"
KEEP=7

# Doi duong dan POSIX cua Git Bash (/g/duong-dan-du-an/...) sang dang Windows
# (G:/duong-dan-du-an/...) de Docker Desktop tren Windows hieu dung.
_winpath() {
    local p="$1"
    if pwd -W >/dev/null 2>&1; then
        (cd "$p" && pwd -W)
    else
        (cd "$p" && pwd)
    fi
}

# ---------- Doc cau hinh tu .env ----------
# Dung bo doc AN TOAN dung chung cua du an (scripts/lib/doc-env.sh): doc tung
# dong, bo \r (CRLF cua Notepad), khong THUC THI noi dung file nhu shell.
# shellcheck source=scripts/lib/doc-env.sh
. "$PROJECT_DIR/scripts/lib/doc-env.sh"
doc_env "$PROJECT_DIR/.env" || exit 1

# Git Bash tren Windows: MSYS tu dong doi "/var/glpi" thanh
# "C:/Program Files/Git/var/glpi" khi truyen lam tham so cho docker.
# Phai tat quy tac nay truoc moi lenh docker.
export MSYS_NO_PATHCONV=1
export MSYS2_ARG_CONV_EXCL='*'

# ---------- Xu ly tham so dong lenh ----------
while [[ $# -gt 0 ]]; do
    case $1 in
        --keep)
            # Chan gia tri sai: --keep 0 (hoac am, hoac chu) se lam vong xoa
            # ben duoi xoa LUON ban vua tao. KEEP phai la so nguyen >= 1.
            if ! [[ "${2:-}" =~ ^[0-9]+$ ]] || [ "${2:-0}" -lt 1 ]; then
                echo "[LOI] --keep can la so nguyen >= 1 (nhan duoc: '${2:-}')"
                exit 1
            fi
            KEEP="$2"; shift 2 ;;
        --dir)  BACKUP_DIR="$2"; shift 2 ;;
        *) shift ;;
    esac
done

mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="glpi_backup_$TIMESTAMP"

echo "=============================================================="
echo "   SAO LUU HE THONG PINEDESK - $TIMESTAMP"
echo "=============================================================="
echo ""

# ---------- 1. Kiem tra container dang chay ----------
if ! docker ps --format '{{.Names}}' | grep -q '^pinedesk-db$'; then
    echo "[LOI] Container pinedesk-db khong chay."
    echo "      Hay khoi dong he thong bang: bash start.sh"
    exit 1
fi

# ---------- 2. Sao luu co so du lieu ----------
echo "[1/4] Dang sao luu co so du lieu..."
DB_FILE="$BACKUP_DIR/${BACKUP_NAME}_db.sql"

# BAO MAT: KHONG truyen mat khau qua tham so -p tren dong lenh. Shell tren may
# host mo rong "$DB_ROOT_PASSWORD" truoc khi goi docker -> mat khau nam trong
# argv cua tien trinh docker tren host, ai chay 'ps' cung doc duoc.
# Cach dung: de shell BEN TRONG container tu doc $MARIADB_ROOT_PASSWORD (bien
# moi truong san co cua container) roi gan cho MYSQL_PWD cua tien trinh con —
# mat khau khong bao gio xuat hien trong argv cua bat ky tien trinh nao.
# (MYSQL_PWD la bien chuan cua MariaDB/MySQL client; khong hien thi trong ps.)
#
# KHONG giau stderr: neu dump that bai thi phai thay loi that (sai mat khau,
# mat ket noi...) thay vi chi thay "file trong".
if ! docker exec -i pinedesk-db sh -c \
        'MYSQL_PWD="$MARIADB_ROOT_PASSWORD" mariadb-dump \
            -u root \
            --single-transaction \
            --routines \
            --triggers \
            --events \
            "$1"' _ "${GLPI_DB_NAME:-glpi}" > "$DB_FILE"; then
    echo "      [LOI] Lenh sao luu CSDL that bai (xem thong bao phia tren)!"
    rm -f "$DB_FILE"
    exit 1
fi

if [ -s "$DB_FILE" ]; then
    echo "      [OK] $(basename "$DB_FILE") - $(du -h "$DB_FILE" | cut -f1)"
else
    echo "      [LOI] Sao luu co so du lieu that bai (file trong)!"
    rm -f "$DB_FILE"
    exit 1
fi

# ---------- 3. Sao luu file he thong (config, plugin, tep dinh kem) ----------
#  LUU Y VE DUONG DAN (da tung sai, gay mat du lieu):
#    Image glpi/glpi:11 dat THU MUC DU LIEU tai /var/glpi (khong phai
#    /var/www/glpi). Cac volume duoc mount vao /var/glpi/{config,files,
#    marketplace,logs} va /var/www/glpi/plugins. Trong container chi dung
#    de backup (--volumes-from) thi /var/www/glpi/config KHONG ton tai.
#    Vi vay phai tar tu /var/glpi/*, neu khong se mat glpicrypt.key.
echo "[2/4] Dang sao luu file he thong..."
FILES_FILE="$BACKUP_DIR/${BACKUP_NAME}_files.tar.gz"

docker run --rm \
    --volumes-from pinedesk-glpi \
    -v "$(_winpath "$BACKUP_DIR"):/backup" \
    alpine:latest \
    tar czf "/backup/${BACKUP_NAME}_files.tar.gz" \
        --exclude='*/_cache' \
        --exclude='*/_sessions' \
        --exclude='*/_tmp' \
        -C / \
        var/glpi/config \
        var/glpi/files \
        var/glpi/marketplace \
        var/glpi/logs \
        var/www/glpi/plugins

if [ -s "$FILES_FILE" ]; then
    echo "      [OK] $(basename "$FILES_FILE") - $(du -h "$FILES_FILE" | cut -f1)"
else
    echo "      [LOI] Sao luu file he thong that bai (file trong)!"
    exit 1
fi

# Kiem tra file song con: thieu glpicrypt.key => khong the giai ma du lieu
# trong CSDL sau khi phuc hoi (mat khoa ma hoa).
# LUU Y: phai cd vao thu muc roi dung TEN FILE, khong truyen duong dan
# dang "G:/..." cho tar. GNU tar hieu "G:" la ten may tu xa (cu phap
# host:file) nen se that bai IM LANG -> kiem tra luon bao sai.
if ! (cd "$BACKUP_DIR" && tar tzf "$(basename "$FILES_FILE")" 2>/dev/null \
        | grep -q 'var/glpi/config/glpicrypt.key'); then
    echo "      [LOI] Ban sao luu THIEU glpicrypt.key -> khong the phuc hoi!"
    exit 1
fi
echo "      [OK] Da kiem tra co glpicrypt.key + config_db.php"

# ---------- 4. Sao luu ma nguon cau hinh (khong gom .env vi chua mat khau) ----------
# LUU Y: GNU tar cua Git Bash hieu "G:/..." la dia chi may tu xa
# (cu phap host:file) -> bao "Cannot connect to G:". Phai cd vao thu muc
# roi ghi bang TEN FILE tuong doi.
echo "[3/4] Dang sao luu file cau hinh du an..."
CONFIG_FILE="$BACKUP_DIR/${BACKUP_NAME}_config.tar.gz"
if (cd "$BACKUP_DIR" && tar czf "${BACKUP_NAME}_config.tar.gz" \
        -C "$PROJECT_DIR" \
        docker-compose.yml nginx config themes scripts) 2>/dev/null; then
    echo "      [OK] $(basename "$CONFIG_FILE") - $(du -h "$CONFIG_FILE" | cut -f1)"
else
    echo "      [LOI] Sao luu file cau hinh that bai!"
    exit 1
fi

# ---------- 5. Don dep ban sao luu cu ----------
echo "[4/4] Don dep ban sao luu cu (giu $KEEP bo gan nhat)..."
# Xoa theo TUNG BO (moc thoi gian), KHONG theo tung loai tep.
# VI SAO: moi lan sao luu sinh ra 3 tep CUNG mot moc thoi gian
# (…_db.sql, …_files.tar.gz, …_config.tar.gz) hop thanh mot BO. Neu xoa rieng
# tung loai ("giu 7 tep db, 7 tep files, 7 tep config"), khi co mot bo KHUYET
# (lan sao luu that bai giua chung -> chi co db, khong co files) thi hai danh
# sach tro ve hai bo khac nhau -> xoa mat db cua bo van con files, de lai bo
# khuyet khong the phuc hoi. Xoa theo bo giu dung ngu nghia "giu N ban gan nhat".
cd "$BACKUP_DIR"
MOC="$(
    ls -1 glpi_backup_*_db.sql glpi_backup_*_files.tar.gz glpi_backup_*_config.tar.gz 2>/dev/null \
        | sed -E 's/^glpi_backup_([0-9]{8}_[0-9]{6})_.*$/\1/' \
        | sort -r -u
)"
printf '%s\n' "$MOC" | tail -n +$((KEEP + 1)) | while read -r old; do
    [ -n "$old" ] || continue
    for f in glpi_backup_"${old}"_*; do
        [ -e "$f" ] || continue
        rm -f "$f"
        echo "      Da xoa: $f"
    done
done

echo ""
echo "=============================================================="
echo "   SAO LUU HOAN TAT"
echo "   Thu muc: $BACKUP_DIR"
echo "=============================================================="
echo ""
echo "   CACH PHUC HOI KHI CAN:"
echo "     (Xem tai-lieu/README.md, muc 7.3 Sao luu & Phuc hoi)"
echo "     1. Khoi dong lai he thong : bash start.sh"
echo "     2. Phuc hoi CSDL:"
echo "        docker exec -i pinedesk-db mariadb -u root -p\"\$DB_ROOT_PASSWORD\" glpi < <file>_db.sql"
echo "     3. Phuc hoi file he thong (giai nen tu goc /):"
echo "        docker run --rm --volumes-from pinedesk-glpi -v \"\$(pwd -W):/backup\" alpine \\"
echo "          tar xzf /backup/<file>_files.tar.gz -C /"
echo "=============================================================="
