#!/bin/bash
# ==============================================================================
#  SCRIPT KHOI DONG PINEDESK (GLPI)
#  Cach dung: bash start.sh
# ==============================================================================

cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1
PROJECT_DIR="$(pwd)"

# Bao ve khoi dong: neu co 'internal' cua mang da doi thi phai 'down' truoc.
# Xem scripts/lib/compose-guard.sh (va chu thich trong docker-compose.yml).
# shellcheck source=scripts/lib/compose-guard.sh
. "$PROJECT_DIR/scripts/lib/compose-guard.sh"

# Sinh chung chi SSL (self-signed, co SAN) neu chua co — BAT BUOC phai co
# truoc khi 'compose up', neu khong nginx se fail. Dung chung voi
# scripts/cai-dat-tat-ca.sh (mot nguon su that duy nhat).
# shellcheck source=scripts/lib/ssl-cert.sh
. "$PROJECT_DIR/scripts/lib/ssl-cert.sh"

# Doc .env AN TOAN (khong `source` nhu shell script — xem giai thich trong
# scripts/lib/doc-env.sh). Dung chung cho moi script de chi con MOT cach doc.
# shellcheck source=scripts/lib/doc-env.sh
. "$PROJECT_DIR/scripts/lib/doc-env.sh"

echo "=============================================================="
echo "   HE THONG HO TRO KY THUAT (PINEDESK) - GLPI"
echo "=============================================================="
echo ""

# ---------- 1. Kiem tra Docker ----------
if ! command -v docker &> /dev/null; then
    echo "[LOI] Chua cai dat Docker Desktop."
    echo "      Tai tai: https://www.docker.com/products/docker-desktop/"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "[LOI] Docker chua chay. Hay mo Docker Desktop truoc."
    exit 1
fi
echo "[OK] Docker dang hoat dong"

# ---------- 2. Kiem tra file .env ----------
if [ ! -f .env ]; then
    echo "[LOI] Khong tim thay file .env"
    echo "      Hay tao file .env voi cac bien moi truong can thiet."
    exit 1
fi
echo "[OK] Da tim thay file cau hinh .env"

# ---------- 3. Canh bao mat khau mau ----------
# .env.example de placeholder <DOI_MAT_KHAU_MANH_TAI_DAY>. Neu nguoi dung copy
# nguyen ma chua dien gia tri that thi canh bao (khong hardcode mat khau that).
if grep -q "DOI_MAT_KHAU_MANH_TAI_DAY" .env 2>/dev/null; then
    echo ""
    echo "[CANH BAO] File .env van con placeholder mau chua duoc dien mat khau that."
    echo "           Hay doi TAT CA mat khau trong .env truoc khi trien khai!"
    echo ""
fi

# ---------- 4. Tao chung chi SSL neu chua co ----------
#
#  Logic nam trong scripts/lib/ssl-cert.sh — dung chung voi
#  scripts/cai-dat-tat-ca.sh. Chung chi PHAI co Subject Alternative Name (SAN);
#  trinh duyet hien dai BO QUA Common Name va CHI doc SAN (xem giai thich
#  trong file thu vien va nginx/ssl/openssl-san.cnf).
if ! dam_bao_chung_chi_ssl "$PROJECT_DIR"; then
    exit 1
fi

# ---------- 5. Khoi dong he thong ----------
echo ""
echo "[..] Dang tai image va khoi dong cac dich vu..."
echo "     Lan dau tien co the mat 3-5 phut de tai image."
echo ""
compose_up_an_toan

# ---------- 6. Cho he thong san sang ----------
echo ""
echo "[..] Dang cho he thong khoi dong..."
sleep 20

# ---------- 7. Kiem tra trang thai ----------
echo ""
docker ps --filter "name=pinedesk-" --format "table {{.Names}}\t{{.Status}}"

# Doc bien moi truong (HTTPS_PORT, HTTP_PORT... de in ra man hinh).
# Dung bo doc an toan cua du an — KHONG `source .env`: source se THUC THI
# noi dung file nhu ma lenh (gia tri chua $()/backtick chay that) va am tham
# cat cut mat khau chua ky tu dac biet. Loi doc file phai hien ra, khong nuot.
doc_env .env || echo "  [CANH BAO] Khong doc duoc .env -> dung gia tri mac dinh."

echo ""
echo "=============================================================="
echo "   KHOI DONG HOAN TAT"
echo "=============================================================="
echo ""
echo "   Truy cap he thong:"
echo "     HTTPS:  https://localhost:${HTTPS_PORT:-8443}"
echo "     HTTP :  http://localhost:${HTTP_PORT:-8080}  (tu dong chuyen HTTPS)"
echo ""
echo "   Tai khoan dang nhap mac dinh cua GLPI:"
echo "     Tai khoan: glpi"
echo "     Mat khau : glpi"
echo "     >>> DOI MAT KHAU NAY NGAY sau khi dang nhap lan dau! <<<"
echo ""
echo "   Lenh quan ly:"
echo "     Xem log       : docker compose logs -f glpi"
echo "     Dung tam      : docker compose stop"
echo "     Khoi dong lai : docker compose start"
echo "     Xoa hoan toan : docker compose down"
echo "     Sao luu       : bash backup/backup.sh"
echo "=============================================================="
