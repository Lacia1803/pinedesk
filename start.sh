#!/bin/bash
# ==============================================================================
#  SCRIPT KHOI DONG HE THONG IT HELPDESK (GLPI)
#  Cach dung: bash start.sh
# ==============================================================================

cd "$(dirname "${BASH_SOURCE[0]}")"
PROJECT_DIR="$(pwd)"

echo "=============================================================="
echo "   HE THONG HO TRO KY THUAT (IT HELPDESK) - GLPI"
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

# ---------- 3. Canh bao mat khau mac dinh ----------
if grep -q "<MAT-KHAU-CSDL-DA-DOI>" .env 2>/dev/null; then
    echo ""
    echo "[CANH BAO] Ban dang dung mat khau mau trong file .env"
    echo "           Hay doi mat khau truoc khi trien khai thuc te!"
    echo ""
fi

# ---------- 4. Tao chung chi SSL neu chua co ----------
if [ ! -f nginx/ssl/glpi.crt ]; then
    echo "[..] Dang tao chung chi SSL (self-signed) cho mang noi bo..."
    mkdir -p nginx/ssl

    if command -v openssl &> /dev/null; then
        # Uu tien dung OpenSSL co san tren may (nhanh, khong can tai image)
        openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
            -keyout nginx/ssl/glpi.key -out nginx/ssl/glpi.crt \
            -subj "/C=VN/ST=LamDong/L=Da Lat/O=Do An IT Helpdesk/CN=helpdesk.local" 2>/dev/null
    else
        # Du phong: dung OpenSSL trong container
        docker run --rm -v "$PROJECT_DIR/nginx/ssl:/ssl" alpine/openssl \
            req -x509 -nodes -days 3650 -newkey rsa:2048 \
            -keyout /ssl/glpi.key -out /ssl/glpi.crt \
            -subj "/C=VN/ST=LamDong/L=Da Lat/O=Do An IT Helpdesk/CN=helpdesk.local" 2>/dev/null
    fi

    if [ -f nginx/ssl/glpi.crt ]; then
        echo "[OK] Da tao chung chi SSL"
        echo "     LUU Y: Day la chung chi tu ky, trinh duyet se canh bao."
        echo "            Chap nhan canh bao de tiep tuc (an toan trong mang noi bo)."
    else
        echo "[LOI] Tao chung chi SSL that bai."
        echo "      Hay cai OpenSSL hoac tao chung chi thu cong."
        exit 1
    fi
else
    echo "[OK] Chung chi SSL da co san"
fi

# ---------- 5. Khoi dong he thong ----------
echo ""
echo "[..] Dang tai image va khoi dong cac dich vu..."
echo "     Lan dau tien co the mat 3-5 phut de tai image."
echo ""
docker-compose up -d

# ---------- 6. Cho he thong san sang ----------
echo ""
echo "[..] Dang cho he thong khoi dong..."
sleep 20

# ---------- 7. Kiem tra trang thai ----------
echo ""
docker ps --filter "name=helpdesk-" --format "table {{.Names}}\t{{.Status}}"

# Doc bien moi truong
source .env 2>/dev/null || true

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
echo "     Xem log       : docker-compose logs -f glpi"
echo "     Dung tam      : docker-compose stop"
echo "     Khoi dong lai : docker-compose start"
echo "     Xoa hoan toan : docker-compose down"
echo "     Sao luu       : bash backup/backup.sh"
echo "=============================================================="
