#!/usr/bin/env bash
# =============================================================================
#  KIỂM TRA LẠM DỤNG NỘP PHIẾU (tầng nghiệp vụ)
#  PineDesk - Trường Đại học Đà Lạt
# =============================================================================
#  VÌ SAO CẦN SCRIPT NÀY:
#    Nginx chỉ chặn được TỐC ĐỘ theo IP. Nhưng cả phòng máy đi ra bằng một IP
#    (NAT), nên chặn theo IP sẽ chặn oan cả lớp. Muốn biết "tài khoản này đang
#    lạm dụng" thì phải đếm theo TÀI KHOẢN -> cần truy vấn CSDL.
#
#  Script làm 3 việc:
#    1. Đếm số phiếu đang mở của từng tài khoản -> ai vượt hạn mức
#    2. Phát hiện phiếu TRÙNG (cùng người + cùng loại sự cố + cùng vị trí,
#       phiếu sau cách phiếu trước trong cửa sổ N phút) -> gợi ý gom lại
#    3. Phát hiện nộp QUÁ NHANH (nhiều phiếu trong thời gian rất ngắn)
#
#  Cách dùng:
#     bash scripts/kiem-tra-lam-dung.sh              # báo cáo
#     bash scripts/kiem-tra-lam-dung.sh --thuc-thi   # báo cáo + ghi log vi phạm
#
#  KHÔNG tự động xoá phiếu của người dùng: chỉ BÁO CÁO để kỹ thuật viên quyết.
#  Xoá phiếu tự động là hành vi nguy hiểm (có thể xoá phiếu thật).
# =============================================================================
set -euo pipefail

DB_CONTAINER="${DB_CONTAINER:-pinedesk-db}"
DB_NAME="${DB_NAME:-glpi}"
THUC_THI=0
[ "${1:-}" = "--thuc-thi" ] && THUC_THI=1

G='\033[0;32m'; Y='\033[1;33m'; R='\033[0;31m'; C='\033[0;36m'; B='\033[1m'; N='\033[0m'
ok()    { echo -e "  ${G}[ OK ]${N} $*"; }
canh()  { echo -e "  ${Y}[CANH BAO]${N} $*"; }
loi()   { echo -e "  ${R}[PHAT HIEN]${N} $*"; }
info()  { echo -e "  ${C}[INFO]${N} $*"; }
step()  { echo ""; echo -e "${B}=== $* ===${N}"; }

if ! docker ps --format '{{.Names}}' | grep -qx "$DB_CONTAINER"; then
    echo -e "${R}[LOI]${N} Không thấy container '$DB_CONTAINER'. Chạy hệ thống trước." >&2
    exit 1
fi

echo "==================================================================="
echo "   KIỂM TRA LẠM DỤNG NỘP PHIẾU"
echo "   (tầng nghiệp vụ - đếm theo TÀI KHOẢN, không theo IP)"
echo "==================================================================="

# --- 0. Kiểm tra bảng hạn mức đã có chưa -------------------------------------
HAS_LIMIT=$(docker exec -i "$DB_CONTAINER" sh -c \
    "MYSQL_PWD=\"\$MARIADB_ROOT_PASSWORD\" mysql -uroot $DB_NAME -N -B -e \
     \"SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='glpi_plugin_pinedesk_limits';\"")

if [ "$HAS_LIMIT" != "1" ]; then
    echo ""
    echo -e "${R}[LOI]${N} Chưa cấu hình bảng hạn mức."
    echo "       Chạy trước:  bash scripts/nap-sla-va-chong-lam-dung.sh"
    exit 1
fi
ok "Đã có bảng cấu hình hạn mức"

# Đọc hạn mức hiện hành
read -r MAX_OPEN MAX_DAY WIN_MIN <<EOF
$(docker exec -i "$DB_CONTAINER" sh -c \
  "MYSQL_PWD=\"\$MARIADB_ROOT_PASSWORD\" mysql -uroot $DB_NAME -N -B -e \
   \"SELECT so_phieu_mo_toi_da, so_phieu_ngay_toi_da, cua_so_trung_phut
       FROM glpi_plugin_pinedesk_limits WHERE rule_name='mac_dinh' AND is_active=1;\"")
EOF

# Chốt an toàn: nếu bảng có dòng 'mac_dinh' nhưng bị xoá cờ is_active (hoặc
# giá trị rỗng), các phép so sánh số phía dưới sẽ vỡ với "unary operator
# expected" hoặc chặn oan toàn bộ. Dừng ngay với thông báo rõ ràng.
if ! [[ "${MAX_OPEN:-}" =~ ^[0-9]+$ && "${MAX_DAY:-}" =~ ^[0-9]+$ && "${WIN_MIN:-}" =~ ^[0-9]+$ ]]; then
    echo -e "${R}[LOI]${N} Không đọc được hạn mức 'mac_dinh' (is_active=1) từ bảng cấu hình." >&2
    echo "       Giá trị đọc được: MAX_OPEN='${MAX_OPEN:-}', MAX_DAY='${MAX_DAY:-}', WIN_MIN='${WIN_MIN:-}'" >&2
    echo "       Chạy lại: bash scripts/nap-sla-va-chong-lam-dung.sh" >&2
    exit 1
fi

info "Hạn mức: mở tối đa ${MAX_OPEN} phiếu · ${MAX_DAY} phiếu/ngày · cửa sổ chống trùng ${WIN_MIN} phút"

VI_PHAM=0

# ------------------------------------------------------------------------------
step "1. Tài khoản vượt hạn mức PHIẾU ĐANG MỞ"
# ------------------------------------------------------------------------------
KQ1=$(docker exec -i "$DB_CONTAINER" sh -c \
  "MYSQL_PWD=\"\$MARIADB_ROOT_PASSWORD\" mysql -uroot $DB_NAME --table -e \"
   SELECT u.name AS 'Tai khoan',
          u.realname AS 'Ho', u.firstname AS 'Ten',
          COUNT(*) AS 'Phieu dang mo'
     FROM glpi_tickets t
     JOIN glpi_users u ON u.id = t.users_id_recipient
    WHERE t.is_deleted = 0
      AND t.status IN (1,2,3,4)
    GROUP BY t.users_id_recipient, u.name, u.realname, u.firstname
   HAVING COUNT(*) > ${MAX_OPEN}
    ORDER BY COUNT(*) DESC;\"")

if [ -z "$(echo "$KQ1" | grep -v '^$')" ]; then
    ok "Không có tài khoản nào vượt hạn mức phiếu đang mở"
else
    echo "$KQ1"
    loi "Có tài khoản vượt hạn mức (> ${MAX_OPEN} phiếu mở)"
    VI_PHAM=$((VI_PHAM+1))
fi

# ------------------------------------------------------------------------------
step "2. Phiếu TRÙNG (cùng người + cùng loại + cùng vị trí, cách nhau < ${WIN_MIN} phút)"
# ------------------------------------------------------------------------------
# Cách đếm phải KHỚP với plugin chặn (plugins/pinedesk/hook.php
# -> plugin_pinedesk_find_duplicate): hai phiếu bị coi là trùng khi cùng
# người + cùng loại sự cố + cùng vị trí, phiếu sau cách phiếu trước trong
# cửa sổ ${WIN_MIN} phút, và cả hai đều CHƯA xong (status không thuộc 5,6).
#
# Bản cũ gom theo DATE_FORMAT(..., '%Y-%m-%d %H:%i') — tức gom theo PHÚT
# ĐỒNG HỒ, nên hai phiếu cách nhau 2 phút (10:00 và 10:02) không bao giờ bị
# phát hiện dù plugin chặn đúng theo cửa sổ ${WIN_MIN} phút. Ngoài ra bản cũ
# thiếu bộ lọc trạng thái nên còn báo cả phiếu đã đóng từ lâu.
KQ2=$(docker exec -i "$DB_CONTAINER" sh -c \
  "MYSQL_PWD=\"\$MARIADB_ROOT_PASSWORD\" mysql -uroot $DB_NAME --table -e \"
   SELECT u.name AS 'Tai khoan',
          t1.id AS 'Phieu truoc',
          t2.id AS 'Phieu sau',
          t2.date AS 'Thoi diem phieu sau',
          TIMESTAMPDIFF(MINUTE, t1.date, t2.date) AS 'Cach (phut)'
     FROM glpi_tickets t1
     JOIN glpi_tickets t2
       ON  t2.users_id_recipient = t1.users_id_recipient
       AND t2.itilcategories_id  = t1.itilcategories_id
       AND t2.locations_id       = t1.locations_id
       AND t2.id                 > t1.id
       AND t2.date              >= t1.date
       AND t2.date              <  DATE_ADD(t1.date, INTERVAL ${WIN_MIN} MINUTE)
     JOIN glpi_users u ON u.id = t1.users_id_recipient
    WHERE t1.is_deleted = 0
      AND t2.is_deleted = 0
      AND t1.status NOT IN (5, 6)
      AND t2.status NOT IN (5, 6)
      AND t1.itilcategories_id > 0
      AND t2.date >= DATE_SUB(NOW(), INTERVAL 7 DAY)
    ORDER BY t2.date DESC
    LIMIT 20;\"")

if [ -z "$(echo "$KQ2" | grep -v '^$')" ]; then
    ok "Không phát hiện phiếu trùng trong 7 ngày qua"
else
    echo "$KQ2"
    canh "Có phiếu nghi trùng — gom lại thay vì xử lý riêng"
    VI_PHAM=$((VI_PHAM+1))
fi

# ------------------------------------------------------------------------------
step "3. Nộp QUÁ NHANH (> 2 phiếu trong cùng một phút)"
# ------------------------------------------------------------------------------
KQ3=$(docker exec -i "$DB_CONTAINER" sh -c \
  "MYSQL_PWD=\"\$MARIADB_ROOT_PASSWORD\" mysql -uroot $DB_NAME --table -e \"
   SELECT u.name AS 'Tai khoan',
          DATE_FORMAT(t.date, '%Y-%m-%d %H:%i') AS 'Phut',
          COUNT(*) AS 'So phieu'
     FROM glpi_tickets t
     JOIN glpi_users u ON u.id = t.users_id_recipient
    WHERE t.is_deleted = 0
      AND t.date >= DATE_SUB(NOW(), INTERVAL 7 DAY)
    GROUP BY t.users_id_recipient, u.name, DATE_FORMAT(t.date, '%Y-%m-%d %H:%i')
   HAVING COUNT(*) > 2
    ORDER BY COUNT(*) DESC
    LIMIT 20;\"")

if [ -z "$(echo "$KQ3" | grep -v '^$')" ]; then
    ok "Không phát hiện nộp quá nhanh"
else
    echo "$KQ3"
    canh "Có tài khoản nộp nhiều phiếu trong cùng một phút"
    VI_PHAM=$((VI_PHAM+1))
fi

# ------------------------------------------------------------------------------
step "KẾT LUẬN"
# ------------------------------------------------------------------------------
if [ "$VI_PHAM" -eq 0 ]; then
    ok "Không phát hiện dấu hiệu lạm dụng."
else
    canh "Phát hiện ${VI_PHAM} nhóm dấu hiệu cần xem xét."
    info "Đây là BÁO CÁO, không tự xoá phiếu. Kỹ thuật viên xem rồi quyết định."
    info "Chạy lại với --thuc-thi để ghi nhật ký vi phạm vào bảng ticketlog."
fi

if [ "$THUC_THI" -eq 1 ]; then
    step "GHI NHẬT KÝ VI PHẠM (--thuc-thi)"
    # Ghi 1 DÒNG / NGƯỜI vượt hạn mức (bản cũ ghi 1 dòng / phiếu — một người
    # có 7 phiếu mở vượt hạn mức 5 bị ghi 7 dòng, sai bản chất: vi phạm thuộc
    # về TÀI KHOẢN, không phải từng phiếu).
    #
    # Chống ghi trùng: bỏ qua người đã có dòng LIMIT_BLOCKED trong 24 giờ qua,
    # để chạy lại script nhiều lần không nhân bản nhật ký.
    #
    # Chỉ ghi vi phạm CỨNG (vượt hạn mức phiếu mở). Hai mục 2 và 3 là CẢNH BÁO
    # (nghi trùng / nộp nhanh) — kỹ thuật viên xem rồi quyết, không tự ghi tội.
    if docker exec -i "$DB_CONTAINER" sh -c \
      "MYSQL_PWD=\"\$MARIADB_ROOT_PASSWORD\" mysql -uroot $DB_NAME -e \"
       INSERT INTO glpi_plugin_pinedesk_ticketlog
           (users_id, tickets_id, ip_address, tickets_id_dup, reason, date_creation)
       SELECT t.users_id_recipient, MAX(t.id), NULL, 0, 'LIMIT_BLOCKED', NOW()
         FROM glpi_tickets t
        WHERE t.is_deleted = 0
          AND t.status IN (1,2,3,4)
        GROUP BY t.users_id_recipient
       HAVING COUNT(*) > ${MAX_OPEN}
          AND NOT EXISTS (
                SELECT 1 FROM glpi_plugin_pinedesk_ticketlog l
                 WHERE l.users_id = t.users_id_recipient
                   AND l.reason   = 'LIMIT_BLOCKED'
                   AND l.date_creation >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
              );\""; then
        ok "Đã ghi nhật ký vi phạm (bỏ qua người đã có ghi nhận trong 24h)"
    else
        canh "Ghi nhật ký vi phạm thất bại — xem log MySQL phía trên"
    fi
fi

echo ""
echo "  Ghi chú: tầng hạ tầng (nginx) đã chặn theo tốc độ tại endpoint"
echo "           /front/ticket.form.php — xem nginx/conf.d/default.conf."
echo ""
