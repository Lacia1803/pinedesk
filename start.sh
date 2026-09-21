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
#  Chung chi PHAI co Subject Alternative Name (SAN). Trinh duyet hien dai
#  (Chrome/Firefox/Edge) BO QUA truong Common Name va CHI doc SAN; thieu SAN
#  thi canh bao nang hon va khong the them ngoai le. Vi vay phan khai bao
#  ten mien/IP nam trong nginx/ssl/openssl-san.cnf, KHONG dung -subj.
#
SSL_CNF="nginx/ssl/openssl-san.cnf"

# Kiem tra chung chi da co SAN chua (tra ve 0 = co, 1 = khong/khong doc duoc)
chung_chi_co_san() {
    [ -f "$1" ] || return 1
    openssl x509 -in "$1" -noout -text 2>/dev/null \
        | grep -q "Subject Alternative Name"
}

tao_chung_chi_ssl() {
    if command -v openssl &> /dev/null; then
        # Uu tien dung OpenSSL co san tren may (nhanh, khong can tai image)
        openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
            -config "$SSL_CNF" \
            -keyout nginx/ssl/glpi.key -out nginx/ssl/glpi.crt 2>/dev/null
    else
        # Du phong: dung OpenSSL trong container.
        # MSYS_NO_PATHCONV: Git Bash tren Windows khong duoc doi /ssl/... thanh
        # duong dan Windows (neu khong, -config /ssl/... se sai).
        MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL='*' \
            docker run --rm -v "$PROJECT_DIR/nginx/ssl:/ssl" alpine/openssl \
            req -x509 -nodes -days 3650 -newkey rsa:2048 \
            -config /ssl/openssl-san.cnf \
            -keyout /ssl/glpi.key -out /ssl/glpi.crt 2>/dev/null
    fi
}

if [ ! -f "$SSL_CNF" ]; then
    echo "[LOI] Khong tim thay file cau hinh chung chi: $SSL_CNF"
    echo "      File nay bat buoc phai co de sinh SAN dung cach."
    exit 1
fi

TAO_MOI=0
if [ ! -f nginx/ssl/glpi.crt ]; then
    TAO_MOI=1
elif ! command -v openssl &> /dev/null; then
    # Khong co openssl de kiem tra -> khong the sinh lai duoc, cu dung cert hien co.
    echo "[CANH BAO] Khong co openssl nen khong kiem tra duoc SAN cua chung chi cu."
    echo "           Neu trinh duyet bao loi ten mien, hay xoa nginx/ssl/glpi.crt"
    echo "           roi chay lai script nay (can Docker de dung alpine/openssl)."
elif ! chung_chi_co_san nginx/ssl/glpi.crt; then
    # Chung chi cu (sinh bang -subj) thieu SAN -> trinh duyet canh bao nang.
    # Tu dong sinh lai va giu lai ban cu du phong.
    echo "[..] Chung chi SSL hien tai THIEU Subject Alternative Name (SAN)."
    echo "     Trinh duyet hien dai se canh bao nang -> dang sinh lai chung chi moi..."
    mv nginx/ssl/glpi.crt "nginx/ssl/glpi.crt.thieu-san.bak" 2>/dev/null || true
    mv nginx/ssl/glpi.key "nginx/ssl/glpi.key.thieu-san.bak" 2>/dev/null || true
    TAO_MOI=1
fi

if [ "$TAO_MOI" = "1" ]; then
    echo "[..] Dang tao chung chi SSL (self-signed, co SAN) cho mang noi bo..."
    mkdir -p nginx/ssl
    tao_chung_chi_ssl

    if chung_chi_co_san nginx/ssl/glpi.crt; then
        echo "[OK] Da tao chung chi SSL (co Subject Alternative Name)"
        echo "     Ten mien/IP hop le: localhost, pinedesk.local, *.localhost,"
        echo "                         127.0.0.1, ::1"
        echo "     LUU Y: Day la chung chi tu ky, trinh duyet se canh bao."
        echo "            Chap nhan canh bao de tiep tuc (an toan trong mang noi bo)."
    else
        echo "[LOI] Tao chung chi SSL that bai (hoac khong co SAN)."
        echo "      Hay cai OpenSSL 1.1.1+ hoac tao chung chi thu cong."
        exit 1
    fi
else
    echo "[OK] Chung chi SSL da co san (co SAN)"
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
