#!/usr/bin/env bash
# ==============================================================================
#  SINH CHUNG CHI SSL SELF-SIGNED (co SAN) CHO GATEWAY NGINX
# ==============================================================================
#  VAN DE (da tung gay loi that):
#    nginx/ssl/glpi.crt + glpi.key KHONG duoc commit vao Git (dung: khoa rieng
#    tu khong nen nam trong repo). Nhung nginx trong docker-compose lai BAT BUOC
#    phai co 2 tep nay moi khoi dong duoc. Tren MAY SACH, phai sinh chung chi
#    TRUOC khi 'compose up', neu khong nginx fail voi loi
#    "cannot load certificate ... No such file or directory".
#
#  VI SAO PHAI CO SAN (Subject Alternative Name):
#    Trinh duyet hien dai (Chrome/Firefox/Edge) BO QUA truong Common Name va
#    CHI doc SAN; chung chi thieu SAN bi canh bao nang va khong the them
#    ngoai le. Vi vay phan khai bao ten mien/IP nam trong
#    nginx/ssl/openssl-san.cnf, KHONG dung -subj.
#
#  File nay duoc 'source' tu start.sh va scripts/cai-dat-tat-ca.sh
#  (quy uoc du an: mot nguon su that duy nhat — xem scripts/lib/compose-guard.sh).
# ==============================================================================

# Kiem tra chung chi da co SAN chua (tra ve 0 = co, 1 = khong/khong doc duoc)
chung_chi_co_san() {
    [ -f "$1" ] || return 1
    openssl x509 -in "$1" -noout -text 2>/dev/null \
        | grep -q "Subject Alternative Name"
}

# Sinh chung chi (uu tien OpenSSL tren may, du phong OpenSSL trong container).
# $1 = thu muc goc du an (da cd vao do truoc khi goi)
tao_chung_chi_ssl() {
    local project_dir="$1"

    if command -v openssl &> /dev/null; then
        # Uu tien dung OpenSSL co san tren may (nhanh, khong can tai image)
        openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
            -config nginx/ssl/openssl-san.cnf \
            -keyout nginx/ssl/glpi.key -out nginx/ssl/glpi.crt 2>/dev/null
    else
        # Du phong: dung OpenSSL trong container.
        # MSYS_NO_PATHCONV: Git Bash tren Windows khong duoc doi /ssl/... thanh
        # duong dan Windows (neu khong, -config /ssl/... se sai).
        MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL='*' \
            docker run --rm -v "$project_dir/nginx/ssl:/ssl" alpine/openssl \
            req -x509 -nodes -days 3650 -newkey rsa:2048 \
            -config /ssl/openssl-san.cnf \
            -keyout /ssl/glpi.key -out /ssl/glpi.crt 2>/dev/null
    fi
}

# Ham chinh: dam bao nginx/ssl/glpi.crt ton tai VA co SAN.
# PHAI goi TRUOC 'compose up'. Tra ve:
#   0 = san sang (co san tu truoc, hoac vua sinh xong)
#   1 = that bai (nginx se khong khoi dong duoc)
# $1 = thu muc goc du an (tuy chon; mac dinh: thu muc hien tai)
dam_bao_chung_chi_ssl() {
    local project_dir="${1:-$(pwd)}"

    if [ ! -f "$project_dir/nginx/ssl/openssl-san.cnf" ]; then
        echo "  [LOI] Khong tim thay file cau hinh chung chi: nginx/ssl/openssl-san.cnf"
        echo "        File nay bat buoc phai co de sinh SAN dung cach."
        return 1
    fi

    cd "$project_dir" || return 1

    local tao_moi=0
    if [ ! -f nginx/ssl/glpi.crt ]; then
        tao_moi=1
    elif ! command -v openssl &> /dev/null; then
        # Khong co openssl de kiem tra -> khong the sinh lai duoc, cu dung cert hien co.
        echo "  [CANH BAO] Khong co openssl nen khong kiem tra duoc SAN cua chung chi cu."
        echo "             Neu trinh duyet bao loi ten mien, hay xoa nginx/ssl/glpi.crt"
        echo "             roi chay lai script nay (can Docker de dung alpine/openssl)."
        return 0
    elif ! chung_chi_co_san nginx/ssl/glpi.crt; then
        # Chung chi cu (sinh bang -subj) thieu SAN -> trinh duyet canh bao nang.
        # Tu dong sinh lai va giu lai ban cu du phong.
        echo "  [..] Chung chi SSL hien tai THIEU Subject Alternative Name (SAN)."
        echo "       Trinh duyet hien dai se canh bao nang -> dang sinh lai chung chi moi..."
        mv nginx/ssl/glpi.crt "nginx/ssl/glpi.crt.thieu-san.bak" 2>/dev/null || true
        mv nginx/ssl/glpi.key "nginx/ssl/glpi.key.thieu-san.bak" 2>/dev/null || true
        tao_moi=1
    fi

    if [ "$tao_moi" = "1" ]; then
        echo "  [..] Dang tao chung chi SSL (self-signed, co SAN) cho mang noi bo..."
        mkdir -p nginx/ssl
        tao_chung_chi_ssl "$project_dir"

        if chung_chi_co_san nginx/ssl/glpi.crt; then
            echo "  [OK] Da tao chung chi SSL (co Subject Alternative Name)"
            echo "       Ten mien/IP hop le: localhost, pinedesk.local, *.localhost,"
            echo "                           127.0.0.1, ::1"
            echo "       LUU Y: Day la chung chi tu ky, trinh duyet se canh bao."
            echo "              Chap nhan canh bao de tiep tuc (an toan trong mang noi bo)."
        else
            echo "  [LOI] Tao chung chi SSL that bai (hoac khong co SAN)."
            echo "        Hay cai OpenSSL 1.1.1+ hoac tao chung chi thu cong."
            return 1
        fi
    else
        echo "  [OK] Chung chi SSL da co san (co SAN)"
    fi

    return 0
}
