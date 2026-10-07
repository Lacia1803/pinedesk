#!/usr/bin/env bash
# ==============================================================================
#  CAI DAT HOAN CHINH PINEDESK - TRUONG DAI HOC DA LAT
# ==============================================================================
#  Do an thuc tap: Xay dung he thong ho tro ky thuat (PineDesk)
#
#  Script nay chay MOT LAN la co ngay he thong san sang su dung:
#     1. Kiem tra Docker + sinh chung chi SSL + khoi dong cac container
#        (GLPI + MariaDB + Redis + Nginx gateway)
#        + noi GLPI voi Redis (cache) + dat url_base
#     2. Nap du lieu nen (danh muc nghiep vu: vi tri phong may, loai thiet bi,
#        trang thai, loai su co, ...) + du lieu demo (thiet bi, phieu, tai
#        khoan mau) + Viet hoa du lieu hien thi (don vi, bang dieu khien)
#     3. Bat 3 plugin: Barcode/QR (sinh ma QR cho thiet bi) + DLU Brand
#        (giao dien Da Lat) + PineDesk (chan that han muc phieu qua hook GLPI)
#        + cai giao dien Da Lat (bang mau, logo, ten ung dung)
#     4. Nap ban dich tieng Viet (gop ban chinh thuc + bo sung cua do an)
#     5. Nap SLA that + co che chong lam dung (tran phieu, chong trung)
#     6. Kiem tra suc khoe he thong
#
#  CHAY (tu thu muc goc cua du an):
#     bash scripts/cai-dat-tat-ca.sh
#
#  LUU Y: Chay lai nhieu lan KHONG tao du lieu trung.
# ==============================================================================

set -uo pipefail

# Duong dan dang Windows (G:/...) de Python tren Windows doc duoc.
# Git Bash tra ve "/g/duong-dan-du-an" -> Python hieu sai thanh "\g\duong-dan-du-an".
# Dung "pwd -W" (chi co tren Git Bash) de lay duong dan Windows that.
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

# Bao ve khoi dong: neu co 'internal' cua mang da doi thi phai 'down' truoc.
# Xem scripts/lib/compose-guard.sh (va chu thich trong docker-compose.yml).
# shellcheck source=scripts/lib/compose-guard.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib/compose-guard.sh"

# Sinh chung chi SSL (self-signed, co SAN) neu chua co — dung chung voi
# start.sh. TRUOC DAY THIEU BUOC NAY: tren may sach, nginx khong khoi dong
# duoc vi thieu nginx/ssl/glpi.crt (chung chi khong duoc commit vao Git).
# shellcheck source=scripts/lib/ssl-cert.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib/ssl-cert.sh"

# Doc .env AN TOAN (khong `source` nhu shell script — xem giai thich trong
# scripts/lib/doc-env.sh). Dung chung cho moi script de chi con MOT cach doc.
# shellcheck source=scripts/lib/doc-env.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib/doc-env.sh"

# Mau hien thi
G='\033[0;32m'; Y='\033[1;33m'; R='\033[0;31m'; C='\033[0;36m'; B='\033[1m'; N='\033[0m'

ok()    { echo -e "  ${G}[ OK ]${N} $*"; }
info()  { echo -e "  ${C}[INFO]${N} $*"; }
warn()  { echo -e "  ${Y}[CANH BAO]${N} $*"; }
err()   { echo -e "  ${R}[LOI]${N} $*"; }
step()  { echo ""; echo -e "${B}=== $* ===${N}"; }

# Python: uu tien bien moi truong GLPI_PYTHON, roi den python he thong.
# KHONG hardcode duong dan tuyet doi de chay duoc tren may khac.
PY="${GLPI_PYTHON:-}"
if [ -z "$PY" ] || [ ! -x "$PY" ]; then
    PY="$(command -v python3 || command -v python)"
fi
if [ -z "$PY" ]; then
    err "Khong tim thay Python. Cai Python 3 hoac dat bien GLPI_PYTHON."
    exit 1
fi

LOI=0

# ------------------------------------------------------------------------------
step "BUOC 1/6 - Khoi dong cac container"
# ------------------------------------------------------------------------------
if ! docker info >/dev/null 2>&1; then
    err "Docker chua chay. Hay mo Docker Desktop roi chay lai script."
    exit 1
fi

# ------------------------------------------------------------------------------
# KIEM TRA .env TRUOC KHI KHOI DONG (lo hong that da bi chi ra khi phan bien):
#   README chi dan chay thang script nay tren may sach, nhung script KHONG
#   bao gio tao / kiem tra .env. Hau qua da kiem chung:
#     - Thieu .env  -> `docker compose up` dung ngay voi loi interpolate
#       (required variable GLPI_DB_PASSWORD is missing a value) — script chay
#       tiep ~2 phut cho doi vo ich roi moi bao loi.
#     - .env.example chep nguyen (con <DOI_MAT_KHAU_MANH_TAI_DAY>) -> compose
#       CHAP NHAN IM LANG: he thong khoi dong voi mat khau la CHUOI
#       PLACEHOLDER tren DB/root/Redis — lo hong bao mat that.
#   => Bat buoc: co .env, va khong con placeholder. Dung han voi chi dan ro.
# ------------------------------------------------------------------------------
if [ ! -f "$ROOT/.env" ]; then
    err "Chua co file .env — he thong CHUA the khoi dong."
    echo ""
    echo "      Hay tao file cau hinh tu file mau roi dien mat khau that:"
    echo "        cp .env.example .env"
    echo "        (mo .env va doi TAT CA mat khau <DOI_MAT_KHAU_MANH_TAI_DAY>)"
    echo "        bash scripts/cai-dat-tat-ca.sh"
    exit 1
fi

if grep -q "DOI_MAT_KHAU_MANH_TAI_DAY" "$ROOT/.env" 2>/dev/null; then
    err "File .env van con mat khau MAU <DOI_MAT_KHAU_MANH_TAI_DAY>."
    echo ""
    echo "      KHONG the khoi dong: compose se chap nhan chuoi placeholder nay"
    echo "      lam mat khau THAT cho DB/root/Redis (da kiem chung)."
    echo "      Mo .env, doi TAT CA dong <DOI_MAT_KHAU_MANH_TAI_DAY> thanh mat"
    echo "      khau manh cua ban, roi chay lai script."
    exit 1
fi

# Nap .env (doc an toan) de lay HTTPS_PORT cho url_base + cac buoc kiem tra.
doc_env "$ROOT/.env" || { err "Khong doc duoc .env"; exit 1; }

# HTTPS_PORT phai la SO: vua de compose map cong hop le, vua tranh gia tri la
# (vd chua ky tu shell) bi dien vao chuoi lenh `config:set` ben duoi.
if ! printf '%s' "${HTTPS_PORT:-8443}" | grep -qE '^[0-9]{1,5}$'; then
    err "HTTPS_PORT trong .env khong hop le: '${HTTPS_PORT:-}' (phai la so, vi du 8443)"
    exit 1
fi

# Dia chi goc cua he thong — BAM THEO HTTPS_PORT trong .env.
# Truoc day hardcode https://localhost:8443: doi HTTPS_PORT trong .env thi
# url_base (link trong email/QR/thong bao) van tro ve 8443 -> link chet.
URL_BASE="https://localhost:${HTTPS_PORT:-8443}"

# BAT BUOC: nginx can nginx/ssl/glpi.crt moi khoi dong duoc. Tren may sach
# (chua co chung chi), phai sinh TRUOC 'compose up'.
if ! dam_bao_chung_chi_ssl "$ROOT"; then
    err "Khong the chuan bi chung chi SSL -> nginx se khong khoi dong duoc."
    exit 1
fi

compose_up_an_toan "$PY"
if [ $? -eq 0 ]; then
    ok "Da khoi dong 4 container"
else
    err "Khoi dong that bai"; LOI=1
fi

info "Cho cac dich vu san sang..."
for i in $(seq 1 60); do
    if docker exec pinedesk-db mariadb-admin ping -h 127.0.0.1 --silent >/dev/null 2>&1; then
        ok "MariaDB da san sang (sau ${i}s)"; break
    fi
    [ "$i" -eq 60 ] && { err "MariaDB khong phan hoi sau 60s"; LOI=1; }
    sleep 1
done

for i in $(seq 1 60); do
    if curl -sk -o /dev/null -w '%{http_code}' "$URL_BASE/" 2>/dev/null | grep -qE '200|302'; then
        ok "GLPI da phan hoi qua HTTPS (sau ${i}s)"; break
    fi
    [ "$i" -eq 60 ] && { warn "GLPI chua phan hoi sau 60s (co the con dang khoi tao)"; }
    sleep 1
done

# --- Cau hinh REDIS lam cache cho GLPI ---------------------------------------
# BAI HOC TU LOI THAT: Redis van chay tu truoc (docker-compose.yml), nhung GLPI
# KHONG duoc noi vao no -> service thua, tuyen bo "cache phien lam viec, tang
# toc do" la suong. GLPI 11 co lenh CLI chinh thuc `cache:configure`; ket qua
# luu vao /var/glpi/config/cache.php (nam trong named volume glpi_config nen
# giu qua cac lan nang cap container).
# BAO MAT: mat khau Redis KHONG truyen qua argv (lo trong `ps` tren host).
# Chuoi DSN duoc day qua stdin: shell trong container doc roi truyen cho PHP.
info "Cau hinh Redis lam cache cho GLPI..."
RP=$(docker exec pinedesk-redis printenv REDISCLI_AUTH 2>/dev/null | tr -d '\r')
if [ -n "$RP" ]; then
    if printf 'redis://:%s@redis:6379/0' "$RP" | \
       docker exec -i -u www-data pinedesk-glpi sh -c \
         'IFS= read -r DSN; cd /var/www/glpi && php bin/console cache:configure --dsn="$DSN" --no-interaction' \
       >/tmp/_cache.log 2>&1; then
        ok "Da noi GLPI voi Redis (cache:configure)"
    else
        warn "Cau hinh cache that bai (xem /tmp/_cache.log)"
    fi
else
    warn "Khong doc duoc mat khau Redis -> bo qua cau hinh cache"
fi

# --- url_base: dia chi goc de GLPI sinh link tuyet doi ------------------------
# Link trong email thong bao, QR, thong bao he thong deu dua tren url_base.
# Mac dinh GLPI la 'http://localhost' -> moi link sinh ra deu sai (thieu cong,
# sai giao thuc). Lenh config:set cua GLPI 11 ghi truc tiep vao CSDL.
# URL_BASE bam theo HTTPS_PORT trong .env (xem khoi dau script) — doi cong
# thi url_base doi theo, khong con canh link chet sau khi doi cong.
info "Dat url_base = $URL_BASE..."
if docker exec -u www-data pinedesk-glpi sh -c \
     "cd /var/www/glpi && php bin/console config:set url_base \"$URL_BASE\" --no-interaction" \
     >/tmp/_urlbase.log 2>&1; then
    ok "Da dat url_base (link trong email/thong bao dung giao thuc + cong)"
else
    warn "Dat url_base that bai (xem /tmp/_urlbase.log)"
fi

# ------------------------------------------------------------------------------
step "BUOC 2/6 - Nap du lieu nen (danh muc nghiep vu)"
# ------------------------------------------------------------------------------
if [ -f "$HERE/nap-du-lieu-nen.sh" ]; then
    if bash "$HERE/nap-du-lieu-nen.sh" >/tmp/_seed.log 2>&1; then
        ok "Da nap danh muc nghiep vu"
        # In bang tom tat ket qua
        sed -n '/KET QUA TAO DU LIEU NEN/,/====/p' /tmp/_seed.log | head -25
    else
        err "Nap du lieu nen that bai (xem /tmp/_seed.log)"; LOI=1
    fi
else
    err "Khong tim thay nap-du-lieu-nen.sh"; LOI=1
fi

# --- Du lieu DEMO (thiet bi, phieu, tai khoan mau) ---------------------------
# BAI HOC TU LOI THAT: truoc day buoc nay KHONG duoc goi o dau ca trong luong
# cai dat. Hau qua tren may sach:
#   - Buoc 5 (SLA) co 2 phan B2/B3 dua tren du lieu mau: 2 luot muon dua tren
#     laptop 'TDL-LAP-001'/'TDL-LAP-003' va nguoi muon 'sv.hoa' — deu do buoc
#     nay tao ra. Thieu du lieu mau -> cac cau lenh co guard 'WHERE @lap IS NOT
#     NULL' bo qua TRONG IM LANG: he thong bao cai dat thanh cong nhung khong
#     co lich bao tri / luot muon / phieu thu 14.
#   - Kich ban demo (tai-lieu/README.md muc 8) dang nhap 'sv.hoa' -> tai khoan khong
#     ton tai.
# Goi ngay sau buoc danh muc (buoc nay can vi tri/danh muc tu buoc 2).
if [ -f "$HERE/nap-du-lieu-mau.sh" ]; then
    info "Nap du lieu demo (thiet bi, phieu, 6 tai khoan mau)..."
    if bash "$HERE/nap-du-lieu-mau.sh" >/tmp/_mau.log 2>&1; then
        ok "Da nap du lieu demo + dat mat khau tai khoan mau"
    else
        err "Nap du lieu demo that bai (xem /tmp/_mau.log)"; LOI=1
    fi
else
    err "Khong tim thay nap-du-lieu-mau.sh"; LOI=1
fi

# --- Viet hoa DU LIEU (ten don vi, bang dieu khien, ho so quyen) ---------------
# BAI HOC TU LOI THAT (ban 0.4.0): truoc day buoc nay KHONG duoc goi o dau ca,
# nen tren may sach don vi goc van la "Root entity", cac bang dieu khien van la
# "Central / Assets / Assistance" (tieng Anh) du menu da Viet hoa. Goi ngay sau
# khi nap danh muc + du lieu mau de du lieu hien thi dung tieng Viet.
if [ -f "$HERE/viet-hoa-du-lieu.sh" ]; then
    if bash "$HERE/viet-hoa-du-lieu.sh" >/tmp/_viethoa.log 2>&1; then
        ok "Da Viet hoa du lieu (don vi, bang dieu khien, ho so quyen)"
    else
        warn "Viet hoa du lieu that bai (xem /tmp/_viethoa.log)"
    fi
else
    warn "Khong tim thay viet-hoa-du-lieu.sh -> bo qua"
fi

# ------------------------------------------------------------------------------
step "BUOC 3/6 - Bat cac plugin (QR code + giao dien DLU + chan han muc)"
# ------------------------------------------------------------------------------
info "Trang thai plugin truoc khi bat:"
docker exec pinedesk-db sh -c \
  'MYSQL_PWD="$MARIADB_ROOT_PASSWORD" mariadb -uroot glpi -e "SELECT directory,state FROM glpi_plugins;"' \
  2>/dev/null | sed 's/^/      /'

# --- Cai + bat plugin dung co che CUA GLPI -----------------------------------
# BAI HOC TU LOI THAT (ban 0.3.0): ban cu chi chay
#     UPDATE glpi_plugins SET state=1 WHERE directory IN ('barcode','dlubrand')
# Tren MAY SACH bang glpi_plugins RONG, cau UPDATE khop 0 dong -> plugin
# KHONG duoc bat, ma script van bao "[OK]". Hau qua: toan bo giao dien Da Lat,
# logo va plugin QR deu 404 (da kiem chung bang curl).
#
# Cach dung: goi CLI chinh thuc cua GLPI 11 (plugin:install + plugin:activate).
#   - `-u www-data`: chay dung nguoi dung webserver, tranh canh bao quyen.
#   - Tuy chon `-u glpi` (user dang nhap) CHI co o plugin:install, KHONG co o
#     plugin:activate -> truyen khac nhau cho tung lenh.
activate_plugin() {   # $1 = ten thu muc plugin
    local dir="$1"
    local co_mat
    co_mat=$(docker exec pinedesk-glpi sh -c \
        "test -f /var/www/glpi/plugins/$dir/setup.php && echo CO" 2>/dev/null)
    if [ "$co_mat" != "CO" ]; then
        warn "Plugin '$dir' khong co trong thu muc plugins -> bo qua"
        return 1
    fi
    # Buoc 1: dang ky plugin (tao dong trong glpi_plugins) neu chua co.
    local state
    state=$(docker exec pinedesk-db sh -c \
        "MYSQL_PWD=\"\$MARIADB_ROOT_PASSWORD\" mariadb -uroot glpi -N -B -e \
         \"SELECT state FROM glpi_plugins WHERE directory='$dir';\"" 2>/dev/null | tr -d '\r')
    if [ -z "$state" ]; then
        docker exec -u www-data pinedesk-glpi sh -c \
          "cd /var/www/glpi && php bin/console plugin:install $dir -u glpi" \
          >/dev/null 2>&1 || true
    fi
    # Buoc 2: bat plugin.
    docker exec -u www-data pinedesk-glpi sh -c \
      "cd /var/www/glpi && php bin/console plugin:activate $dir" \
      >/dev/null 2>&1 || true
    # Buoc 3: kiem chung THAT SU da bat chua (state=1).
    state=$(docker exec pinedesk-db sh -c \
        "MYSQL_PWD=\"\$MARIADB_ROOT_PASSWORD\" mariadb -uroot glpi -N -B -e \
         \"SELECT state FROM glpi_plugins WHERE directory='$dir';\"" 2>/dev/null | tr -d '\r')
    if [ "$state" = "1" ]; then
        ok "Plugin '$dir' da bat (state=1)"
    else
        err "Plugin '$dir' CHUA bat duoc (state='${state:-khong co}')"
        return 1
    fi
}

# Plugin barcode (QR): tai tu GitHub neu thieu (khong co san trong image GLPI).
if [ ! -f "$HERE/cai-plugin-qrcode.sh" ]; then
    warn "Thieu cai-plugin-qrcode.sh -> bo qua plugin QR"
else
    if ! docker exec pinedesk-glpi sh -c \
         'test -f /var/www/glpi/plugins/barcode/setup.php' 2>/dev/null; then
        info "Chua co plugin barcode -> tai & cai..."
        if bash "$HERE/cai-plugin-qrcode.sh" >/tmp/_qrcode.log 2>&1; then
            ok "Da cai plugin barcode (QR)"
        else
            warn "Cai plugin barcode that bai (xem /tmp/_qrcode.log) — bo qua"
        fi
    fi
fi
# Plugin giao dien DLU: da mount san tu docker-compose.yml.
activate_plugin barcode    || true
activate_plugin dlubrand   || { err "Khong bat duoc plugin giao dien DLU"; LOI=1; }
# Plugin pinedesk: chan that han muc phieu (T3/T4) bang hook cua GLPI.
# Mount san tu docker-compose.yml. Xem plugins/pinedesk/setup.php.
activate_plugin pinedesk   || { err "Khong bat duoc plugin chan han muc (pinedesk)"; LOI=1; }

# --- Cai giao dien "Da Lat": bang mau + logo + ten ung dung ------------------
# BAI HOC TU LOI THAT (ban 0.4.0): cai-giao-dien.sh dat `app_name` (ten tren the
# trinh duyet), dai mau uu tien (priority_1..6) va bang mau mac dinh — nhung
# script nay KHONG duoc goi o dau trong luong cai dat. Hau qua tren may sach:
#   - The trinh duyet hien "... - GLPI" thay vi "... - PineDesk DLU" -> lo ngay
#     day la GLPI chua tuy bien.
#   - Dai mau uu tien van la hong do mac dinh cua GLPI (#fff2f2 -> #ff5555),
#     lech han the gioi Da Lat.
# Goi ngay sau khi bat plugin (logo duoc copy vao thu muc public/ cua plugin).
if [ -f "$HERE/cai-giao-dien.sh" ]; then
    if bash "$HERE/cai-giao-dien.sh" >/tmp/_giaodien.log 2>&1; then
        ok "Da cai giao dien Da Lat (bang mau + logo + ten ung dung)"
    else
        warn "Cai giao dien that bai (xem /tmp/_giaodien.log)"
    fi
else
    warn "Khong tim thay cai-giao-dien.sh -> bo qua"
fi

# --- QUAN TRONG: thu muc xuat file QR cua plugin barcode ---------------------
# Plugin ghi file PDF vao GLPI_PLUGIN_DOC_DIR.'/barcode/' = /var/glpi/files/_plugins/barcode/.
# Neu thu muc nay KHONG ton tai thi file_put_contents() THAT BAI AM THAM
# (khong bao loi), nen bam "Print QRcodes" se khong ra file nao.
info "Tao thu muc xuat file QR cho plugin barcode..."
docker exec pinedesk-glpi sh -c \
  'mkdir -p /var/glpi/files/_plugins/barcode && chown -R www-data:www-data /var/glpi/files/_plugins'
ok "Da tao /var/glpi/files/_plugins/barcode"

# --- Quyen su dung plugin barcode cho ho so Super-Admin ----------------------
# Mac dinh GLPI chua bat quyen plugin_barcode_config -> tuy chon sinh QR
# khong xuat hien trong menu "Cac hanh dong".
info "Cap quyen plugin barcode cho ho so Super-Admin..."
docker exec pinedesk-db sh -c \
  'MYSQL_PWD="$MARIADB_ROOT_PASSWORD" mariadb -uroot glpi -e "
     UPDATE glpi_profilerights SET rights=31
       WHERE profiles_id=4 AND name=\"plugin_barcode_barcode\";
     INSERT INTO glpi_profilerights (profiles_id, name, rights)
       SELECT 4, \"plugin_barcode_config\", 31
       WHERE NOT EXISTS (SELECT 1 FROM glpi_profilerights
                         WHERE profiles_id=4 AND name=\"plugin_barcode_config\");
   "' >/dev/null 2>&1
ok "Da cap quyen sinh ma QR"

# Xoa cache de GLPI nap lai plugin + theme
docker exec pinedesk-glpi sh -c \
  'rm -rf /var/glpi/files/_cache/* 2>/dev/null' || true
ok "Da xoa cache"

# ------------------------------------------------------------------------------
step "BUOC 4/6 - Nap ban dich tieng Viet"
# ------------------------------------------------------------------------------
if [ -f "$HERE/tao-mo-bo-sung.py" ] && [ -f "$HERE/gop-ban-dich-tieng-viet.py" ]; then
    info "a) Tao lop phu ban dich bo sung..."
    if "$PY" "$HERE/tao-mo-bo-sung.py" >/tmp/_mo1.log 2>&1; then
        grep -E 'Da ghi|Lop phu|Tu dien' /tmp/_mo1.log | sed 's/^/      /'
    else
        warn "Tao lop phu that bai (xem /tmp/_mo1.log)"; LOI=1
    fi

    info "b) Gop vao catalog chinh..."
    if "$PY" "$HERE/gop-ban-dich-tieng-viet.py" >/tmp/_mo2.log 2>&1; then
        grep -E 'Ket qua|Tong so chuoi|Khong mat chuoi' /tmp/_mo2.log | sed 's/^/      /'
        ok "Da nap ban dich tieng Viet"
    else
        warn "Gop ban dich that bai (xem /tmp/_mo2.log)"; LOI=1
    fi
else
    warn "Thieu script dich -> bo qua buoc nay"; LOI=1
fi

# ------------------------------------------------------------------------------
step "BUOC 5/6 - Nap SLA + co che chong lam dung"
# ------------------------------------------------------------------------------
# VI SAO CO BUOC NAY:
#   README truoc day ghi he thong co "cam ket SLA", nhung CSDL GLPI KHONG co
#   ban ghi SLA nao -> tuyen bo suong. Buoc nay tao SLA THAT + bang nhat ky
#   chong lam dung (tran phieu/nguoi/ngay, phat hien trung).
#   Nam NGOAI loi GLPI -> nang cap GLPI khong mat.
if [ -f "$HERE/nap-sla-va-chong-lam-dung.sh" ]; then
    if bash "$HERE/nap-sla-va-chong-lam-dung.sh" >/tmp/_sla.log 2>&1; then
        grep -E '\[ OK \]|\[CANH BAO\]' /tmp/_sla.log | sed 's/^/      /'
        ok "Da nap SLA + co che chong lam dung"
    else
        warn "Nap SLA that bai (xem /tmp/_sla.log)"
        tail -5 /tmp/_sla.log | sed 's/^/      /'
        LOI=1
    fi
else
    warn "Thieu nap-sla-va-chong-lam-dung.sh -> bo qua buoc nay"; LOI=1
fi

# ------------------------------------------------------------------------------
step "BUOC 6/6 - Kiem tra suc khoe he thong"
# ------------------------------------------------------------------------------
echo ""
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | sed 's/^/  /'

echo ""
info "Kiem tra cac thanh phan quan trong:"

# 1. Trang dang nhap
CODE=$(curl -sk -o /dev/null -w '%{http_code}' "$URL_BASE/" 2>/dev/null)
[ "$CODE" = "200" ] && ok "Trang dang nhap        : HTTP $CODE" \
                    || { err "Trang dang nhap        : HTTP $CODE"; LOI=1; }

# 2. CSS giao dien DLU
CODE=$(curl -sk -o /dev/null -w '%{http_code}' \
       "$URL_BASE/plugins/dlubrand/css/dlu-theme.css" 2>/dev/null)
[ "$CODE" = "200" ] && ok "CSS giao dien Da Lat    : HTTP $CODE" \
                    || { err "CSS giao dien Da Lat    : HTTP $CODE"; LOI=1; }

# 3. Logo DLU
# Duong dan phai la /plugins/dlubrand/pics/logos/... vi dlu-theme.css tro
# --glpi-logo-* vao do (xem giai thich trong dlu-theme.css). Duong dan cu
# /pics/logos/... da thanh 404 sau khi logo chuyen ve plugin.
CODE=$(curl -sk -o /dev/null -w '%{http_code}' \
       "$URL_BASE/plugins/dlubrand/pics/logos/logo-DLU-100.png" 2>/dev/null)
[ "$CODE" = "200" ] && ok "Logo DLU               : HTTP $CODE" \
                    || { err "Logo DLU               : HTTP $CODE"; LOI=1; }

# 4. Ban dich tieng Viet
docker exec pinedesk-glpi test -f /var/glpi/files/_locales/core/vi_VN.mo 2>/dev/null \
    && ok "Ban dich tieng Viet     : da cai" \
    || { err "Ban dich tieng Viet     : CHUA cai"; LOI=1; }

# 5. Plugin (barcode + dlubrand + pinedesk = 3)
PDIR=$(docker exec pinedesk-db sh -c \
  'MYSQL_PWD="$MARIADB_ROOT_PASSWORD" mariadb -uroot glpi -N -e "SELECT COUNT(*) FROM glpi_plugins WHERE state=1;"' \
  2>/dev/null | tr -d '\r')
[ "${PDIR:-0}" -ge 3 ] && ok "Plugin dang hoat dong  : $PDIR plugin" \
                       || { err "Plugin dang hoat dong  : $PDIR plugin (can >= 3)"; LOI=1; }

# ------------------------------------------------------------------------------
echo ""
if [ "$LOI" -eq 0 ]; then
    echo -e "${G}${B}"
    echo "  ============================================================"
    echo "     HOAN TAT - HE THONG DA SAN SANG SU DUNG"
    echo "  ============================================================"
    echo -e "${N}"
else
    echo -e "${Y}${B}"
    echo "  ============================================================"
    echo "     HOAN TAT NHUNG CO $LOI MUC CAN KIEM TRA LAI"
    echo "  ============================================================"
    echo -e "${N}"
fi

cat <<EOF
  Truy cap he thong:
     $URL_BASE
     (Chung chi tu ky -> trinh duyet se canh bao, chon "Tiep tuc")

  Tai khoan quan tri mac dinh:
     Tai khoan: glpi
     Mat khau : (mat khau ban da dat trong file .env / khi cai GLPI)
     >>> DOI MAT KHAU NAY NGAY sau khi dang nhap lan dau! <<<

  Sau khi dang nhap, kiem tra:
     - Tai san > Vi tri           : danh muc phong may, toa nha
     - Tai san > May tinh         : thiet bi, co ma QR
     - Ho tro  > Phieu yeu cau    : tiep nhan su co
     - Bang dieu khien            : thong ke

  Sinh ma QR hang loat cho thiet bi:
     python scripts/sinh-ma-qr.py

  Do lai do phu tieng Viet:
     python scripts/do-do-phu-tieng-viet.py

EOF

# Tra ve ma loi THAT (0 = thanh cong, 1 = co muc can kiem tra).
# Truoc day script khong co dong nay -> luon tra ve 0 du buoc 4/5 that bai,
# nen CI/nguoi chay khong the phat hien loi tu dong.
exit "$LOI"
