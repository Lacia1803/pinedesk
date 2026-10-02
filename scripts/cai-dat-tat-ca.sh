#!/usr/bin/env bash
# ==============================================================================
#  CAI DAT HOAN CHINH PINEDESK - TRUONG DAI HOC DA LAT
# ==============================================================================
#  Do an thuc tap: Xay dung he thong ho tro ky thuat (PineDesk)
#
#  Script nay chay MOT LAN la co ngay he thong san sang su dung:
#     1. Khoi dong cac container (GLPI + MariaDB + Redis + Nginx gateway)
#     2. Nap du lieu nen (danh muc nghiep vu: vi tri phong may, loai thiet bi,
#        trang thai, loai su co, ...)
#     3. Bat 2 plugin: Barcode/QR (sinh ma QR cho thiet bi) + DLU Brand
#        (giao dien Da Lat)
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
    if curl -sk -o /dev/null -w '%{http_code}' https://localhost:8443/ 2>/dev/null | grep -qE '200|302'; then
        ok "GLPI da phan hoi qua HTTPS (sau ${i}s)"; break
    fi
    [ "$i" -eq 60 ] && { warn "GLPI chua phan hoi sau 60s (co the con dang khoi tao)"; }
    sleep 1
done

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

# ------------------------------------------------------------------------------
step "BUOC 3/6 - Bat cac plugin (QR code + giao dien DLU)"
# ------------------------------------------------------------------------------
info "Trang thai plugin truoc khi bat:"
docker exec pinedesk-db sh -c \
  'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" glpi -e "SELECT directory,state FROM glpi_plugins;"' \
  2>/dev/null | sed 's/^/      /'

docker exec pinedesk-db sh -c \
  'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" glpi -e "UPDATE glpi_plugins SET state=1 WHERE directory IN (\"barcode\",\"dlubrand\");"' \
  >/dev/null 2>&1
ok "Da bat plugin barcode (QR) va dlubrand (giao dien Da Lat)"

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
  'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" glpi -e "
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
        warn "Tao lop phu that bai (xem /tmp/_mo1.log)"
    fi

    info "b) Gop vao catalog chinh..."
    if "$PY" "$HERE/gop-ban-dich-tieng-viet.py" >/tmp/_mo2.log 2>&1; then
        grep -E 'Ket qua|Tong so chuoi|Khong mat chuoi' /tmp/_mo2.log | sed 's/^/      /'
        ok "Da nap ban dich tieng Viet"
    else
        warn "Gop ban dich that bai (xem /tmp/_mo2.log)"
    fi
else
    warn "Thieu script dich -> bo qua buoc nay"
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
    fi
else
    warn "Thieu nap-sla-va-chong-lam-dung.sh -> bo qua buoc nay"
fi

# ------------------------------------------------------------------------------
step "BUOC 6/6 - Kiem tra suc khoe he thong"
# ------------------------------------------------------------------------------
echo ""
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | sed 's/^/  /'

echo ""
info "Kiem tra cac thanh phan quan trong:"

# 1. Trang dang nhap
CODE=$(curl -sk -o /dev/null -w '%{http_code}' https://localhost:8443/ 2>/dev/null)
[ "$CODE" = "200" ] && ok "Trang dang nhap        : HTTP $CODE" \
                    || { err "Trang dang nhap        : HTTP $CODE"; LOI=1; }

# 2. CSS giao dien DLU
CODE=$(curl -sk -o /dev/null -w '%{http_code}' \
       https://localhost:8443/plugins/dlubrand/css/dlu-theme.css 2>/dev/null)
[ "$CODE" = "200" ] && ok "CSS giao dien Da Lat    : HTTP $CODE" \
                    || { err "CSS giao dien Da Lat    : HTTP $CODE"; LOI=1; }

# 3. Logo DLU
# Duong dan phai la /plugins/dlubrand/pics/logos/... vi dlu-theme.css tro
# --glpi-logo-* vao do (xem giai thich trong dlu-theme.css). Duong dan cu
# /pics/logos/... da thanh 404 sau khi logo chuyen ve plugin.
CODE=$(curl -sk -o /dev/null -w '%{http_code}' \
       https://localhost:8443/plugins/dlubrand/pics/logos/logo-DLU-100.png 2>/dev/null)
[ "$CODE" = "200" ] && ok "Logo DLU               : HTTP $CODE" \
                    || { err "Logo DLU               : HTTP $CODE"; LOI=1; }

# 4. Ban dich tieng Viet
docker exec pinedesk-glpi test -f /var/glpi/files/_locales/core/vi_VN.mo 2>/dev/null \
    && ok "Ban dich tieng Viet     : da cai" \
    || { err "Ban dich tieng Viet     : CHUA cai"; LOI=1; }

# 5. Plugin
PDIR=$(docker exec pinedesk-db sh -c \
  'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" glpi -N -e "SELECT COUNT(*) FROM glpi_plugins WHERE state=1;"' \
  2>/dev/null | tr -d '\r')
[ "${PDIR:-0}" -ge 2 ] && ok "Plugin dang hoat dong  : $PDIR plugin" \
                       || warn "Plugin dang hoat dong  : $PDIR plugin"

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
     https://localhost:8443
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
