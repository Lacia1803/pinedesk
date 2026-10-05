#!/usr/bin/env bash
# =============================================================================
#  NẠP SLA THẬT + CƠ CHẾ CHỐNG LẠM DỤNG VÀO GLPI
#  PineDesk - Trường Đại học Đà Lạt
# =============================================================================
#  VÌ SAO CẦN:
#    README trước đây ghi hệ thống có "cam kết SLA", nhưng CSDL GLPI KHÔNG có
#    bản ghi SLA nào. Đó là tuyên bố suông — hội đồng có thể bắt lỗi ngay.
#    Script này biến nó thành DỮ LIỆU THẬT trong CSDL.
#
#  Chạy SAU khi đã có dữ liệu nền, tốt nhất sau nap-du-lieu-mau.sh.
#  Idempotent: chạy lại nhiều lần không tạo dữ liệu trùng.
#
#  Dùng:  bash scripts/nap-sla-va-chong-lam-dung.sh
# =============================================================================
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DB_CONTAINER="${DB_CONTAINER:-pinedesk-db}"
DB_NAME="${DB_NAME:-glpi}"

G='\033[0;32m'; Y='\033[1;33m'; R='\033[0;31m'; C='\033[0;36m'; B='\033[1m'; N='\033[0m'
ok()   { echo -e "  ${G}[ OK ]${N} $*"; }
warn() { echo -e "  ${Y}[CANH BAO]${N} $*"; }
err()  { echo -e "  ${R}[LOI]${N} $*"; }
info() { echo -e "  ${C}[INFO]${N} $*"; }
step() { echo ""; echo -e "${B}=== $* ===${N}"; }

echo "==================================================================="
echo "   NẠP SLA + CHỐNG LẠM DỤNG VÀO GLPI"
echo "==================================================================="

# --- 0. Kiểm tra container ----------------------------------------------------
if ! docker ps --format '{{.Names}}' | grep -qx "$DB_CONTAINER"; then
    err "Không thấy container '$DB_CONTAINER'."
    info "Chạy trước:  bash start.sh   (hoặc  docker compose up -d)"
    exit 1
fi
ok "Container CSDL '$DB_CONTAINER' đang chạy"

# --- 1. Bảng glpi_slas phải tồn tại (do GLPI tạo khi cài) ---------------------
HAS_SLAS=$(docker exec -i "$DB_CONTAINER" sh -c \
    "MYSQL_PWD=\"\$MARIADB_ROOT_PASSWORD\" mysql -uroot $DB_NAME -N -B -e \
     \"SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='glpi_slas';\"")

if [ "$HAS_SLAS" != "1" ]; then
    err "Bảng glpi_slas không tồn tại — GLPI chưa được cài đặt xong."
    info "Chạy trước:  bash scripts/cai-dat-tat-ca.sh"
    exit 1
fi
ok "Bảng glpi_slas tồn tại"

# --- 2. Nạp tệp SQL ------------------------------------------------------------
step "Nạp SLA + cơ chế chống lạm dụng"

SQL_FILE="$HERE/seed-sla-va-chong-lam-dung.sql"
if [ ! -f "$SQL_FILE" ]; then
    err "Không tìm thấy tệp $SQL_FILE"
    exit 1
fi

# Nạp qua stdin (tránh lỗi nháy kép của Git Bash trên Windows).
set +e
KQ=$(docker exec -i "$DB_CONTAINER" sh -c \
      "MYSQL_PWD=\"\$MARIADB_ROOT_PASSWORD\" mysql -uroot $DB_NAME" < "$SQL_FILE" 2>&1)
RC=$?
set -e

if [ $RC -ne 0 ]; then
    err "Nạp thất bại:"
    echo "$KQ" | sed 's/^/      /'
    exit 1
fi
echo "$KQ" | sed 's/^/      /'

# --- 3. Kiểm chứng kết quả -----------------------------------------------------
step "Kiểm chứng"

SLAS=$(docker exec -i "$DB_CONTAINER" sh -c \
    "MYSQL_PWD=\"\$MARIADB_ROOT_PASSWORD\" mysql -uroot $DB_NAME -N -B -e \
     \"SELECT COUNT(*) FROM glpi_slas WHERE name LIKE 'SLA - Ưu tiên%';\"")
LEVELS=$(docker exec -i "$DB_CONTAINER" sh -c \
    "MYSQL_PWD=\"\$MARIADB_ROOT_PASSWORD\" mysql -uroot $DB_NAME -N -B -e \
     \"SELECT COUNT(*) FROM glpi_slalevels l JOIN glpi_slas s ON s.id=l.slas_id
        WHERE s.name LIKE 'SLA - Ưu tiên%';\"")

if [ "$SLAS" -ge 5 ]; then
    ok "Đã tạo $SLAS định nghĩa SLA"
else
    warn "Chỉ có $SLAS SLA (mong đợi 5)"
fi

if [ "$LEVELS" -ge 10 ]; then
    ok "Đã tạo $LEVELS mốc thời gian (TTO + TTR cho mỗi SLA)"
else
    warn "Chỉ có $LEVELS mốc (mong đợi 10)"
fi

# --- 4. Kiểm chứng phần BẢO TRÌ + MƯỢN/TRẢ ------------------------------------
# Phần B2/B3 của tệp SQL chỉ tạo được khi ĐÃ có dữ liệu mẫu: 2 lượt mượn dựa
# trên laptop 'TDL-LAP-001'/'TDL-LAP-003' và người mượn 'sv.hoa'/'gv.cuong',
# tất cả đều do nap-du-lieu-mau.sh sinh ra. Thiếu dữ liệu mẫu thì các câu
# lệnh có guard 'WHERE @lap IS NOT NULL' bỏ qua trong im lặng. Kiểm ở đây để
# báo rõ thay vì để người dùng tưởng đã có dữ liệu mượn.
RI=$(docker exec -i "$DB_CONTAINER" sh -c \
    "MYSQL_PWD=\"\$MARIADB_ROOT_PASSWORD\" mysql -uroot $DB_NAME -N -B -e \
     \"SELECT COUNT(*) FROM glpi_reservationitems;\"")
RV=$(docker exec -i "$DB_CONTAINER" sh -c \
    "MYSQL_PWD=\"\$MARIADB_ROOT_PASSWORD\" mysql -uroot $DB_NAME -N -B -e \
     \"SELECT COUNT(*) FROM glpi_reservations;\"")
TR=$(docker exec -i "$DB_CONTAINER" sh -c \
    "MYSQL_PWD=\"\$MARIADB_ROOT_PASSWORD\" mysql -uroot $DB_NAME -N -B -e \
     \"SELECT COUNT(*) FROM glpi_ticketrecurrents;\"")

if [ "${RI:-0}" -ge 2 ] && [ "${RV:-0}" -ge 2 ]; then
    ok "Đã tạo $TR lịch bảo trì + $RI thiết bị cho mượn + $RV lượt mượn"
else
    warn "Chưa có dữ liệu mượn/trả (thiết bị cho mượn: ${RI:-0}, lượt mượn: ${RV:-0})."
    info "Phần này cần DỮ LIỆU MẪU. Chạy trước:  bash scripts/nap-du-lieu-mau.sh"
    info "rồi chạy lại script này. (Lịch bảo trì hiện có: ${TR:-0}.)"
fi

info "Bảng nhật ký + hạn mức chống lạm dụng đã tạo."
info "Kiểm tra lạm dụng:  bash scripts/kiem-tra-lam-dung.sh"

echo ""
echo "  ⚠️  LƯU Ý TRUNG THỰC:"
echo "      Các mức SLA (8h/4h/2h/1h/30p) là ĐỀ XUẤT KỸ THUẬT của đồ án,"
echo "      KHÔNG phải cam kết đã được Trường ban hành. Muốn thành SLA thật"
echo "      phải có văn bản phê duyệt của Trung tâm CNTT (ITC)."
echo ""
