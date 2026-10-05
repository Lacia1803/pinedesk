#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Việt hoá DỮ LIỆU trong cơ sở dữ liệu GLPI.
#
# Vì sao cần riêng một bước:
#   Từ điển dịch (.mo) chỉ tác động lên các chuỗi ĐƯỢC VIẾT TRONG MÃ NGUỒN.
#   Một số nhãn người dùng nhìn thấy lại là DỮ LIỆU lưu trong CSDL — dịch từ điển
#   không chạm tới được:
#     - tên đơn vị (glpi_entities.name)         -> hiện ở góc trên phải
#     - tên bảng điều khiển (glpi_dashboards...) -> hiện ở ô chọn bảng điều khiển
#     - tên hồ sơ quyền (glpi_profiles.name)     -> hiện cạnh tên người dùng
#
#   Đã kiểm tra: mã nguồn GLPI KHÔNG tham chiếu tên hồ sơ quyền, chỉ dùng id,
#   nên đổi tên là an toàn.
#
# Idempotent — chạy lại nhiều lần không sao.
# Dùng:  ./scripts/viet-hoa-du-lieu.sh
# -----------------------------------------------------------------------------
set -euo pipefail

DB_CONTAINER="pinedesk-db"
DB_NAME="glpi"

xanh()  { printf '\033[0;32m%s\033[0m\n' "$1"; }
xam()   { printf '\033[0;90m%s\033[0m\n' "$1"; }

if ! docker ps --format '{{.Names}}' | grep -qx "$DB_CONTAINER"; then
    printf '\033[0;31mKhông thấy container %s. Chạy docker-compose up -d trước.\033[0m\n' "$DB_CONTAINER" >&2
    exit 1
fi

# Nạp thẳng câu lệnh SQL qua stdin — không tạo tệp tạm (tránh cả lỗi nháy kép
# của Git Bash trên Windows lẫn việc phải dọn tệp sau khi chạy).
xam "  Đang nạp các thay đổi vào CSDL $DB_NAME..."
docker exec -i "$DB_CONTAINER" sh -c "MYSQL_PWD=\"\$MARIADB_ROOT_PASSWORD\" mysql -uroot $DB_NAME" <<'SQL'
-- 1. Đơn vị gốc -> tên Trường
--    Đặt tên ngắn ("Đại học Đà Lạt") vì nhãn này hiện trong thẻ nhỏ ở góc trên
--    phải; tên đầy đủ sẽ bị cắt cụt giữa chừng, trông cẩu thả.
UPDATE glpi_entities
   SET name = 'Đại học Đà Lạt',
       completename = 'Đại học Đà Lạt'
 WHERE id = 0;

-- 2. Tên các bảng điều khiển dựng sẵn
UPDATE glpi_dashboards_dashboards SET name = 'Tổng quan'     WHERE name = 'Central';
UPDATE glpi_dashboards_dashboards SET name = 'Tài sản'       WHERE name = 'Assets';
UPDATE glpi_dashboards_dashboards SET name = 'Hỗ trợ'        WHERE name = 'Assistance';
UPDATE glpi_dashboards_dashboards SET name = 'Phiếu rút gọn' WHERE name = 'Mini tickets dashboard';

-- 2b. TẮT chế độ dữ liệu minh hoạ của bảng điều khiển.
--     LOI THAT (0.4.0): GLPI 11 bật sẵn `is_demo_dashboards = 1`. Khi bật, mọi
--     ô đếm trên bảng điều khiển hiện SỐ GIẢ (114.7K phần mềm, 1.5K phiếu...)
--     kèm băng-rôn "You are viewing demonstration data" — mâu thuẫn hoàn toàn
--     với dữ liệu thật của đồ án và gây mất điểm khi hội đồng nhìn thấy.
--     Đặt 0 để các ô đếm lấy số THẬT từ CSDL.
UPDATE glpi_configs SET value = 0 WHERE name = 'is_demo_dashboards';

-- 3. Tên hồ sơ quyền (chỉ là dữ liệu, mã nguồn không tham chiếu tên)
UPDATE glpi_profiles SET name = 'Người dùng'       WHERE name = 'Self-Service';
UPDATE glpi_profiles SET name = 'Người quan sát'   WHERE name = 'Observer';
UPDATE glpi_profiles SET name = 'Quản trị viên'    WHERE name = 'Admin';
UPDATE glpi_profiles SET name = 'Quản trị cấp cao' WHERE name = 'Super-Admin';
UPDATE glpi_profiles SET name = 'Trực tổng đài'    WHERE name = 'Hotliner';
UPDATE glpi_profiles SET name = 'Kỹ thuật viên'    WHERE name = 'Technician';
UPDATE glpi_profiles SET name = 'Giám sát'         WHERE name = 'Supervisor';
UPDATE glpi_profiles SET name = 'Chỉ đọc'          WHERE name = 'Read-Only';

-- 4. Dữ liệu TRANG TỰ PHỤC VỤ (trang sinh viên dùng để báo sự cố).
--    Vì sao phải sửa DỮ LIỆU chứ không chỉ từ điển .mo:
--      GLPI sinh các thẻ và biểu mẫu này MỘT LẦN lúc cài đặt, dùng hàm __()
--      để dịch NGAY tại thời điểm đó. Lúc cài, bản dịch bổ sung của đồ án chưa
--      được nạp nên chuỗi tiếng Anh bị ĐÓNG BĂNG vào CSDL; sau này nạp .mo
--      cũng không dịch lại được nữa. Phải UPDATE thẳng trong CSDL.
--    Đã kiểm chứng trên hệ thống chạy thật: trang Helpdesk hiện gần như 100%
--    tiếng Anh nếu bỏ qua bước này.

-- 4.1. Thẻ trên trang chủ tự phục vụ
UPDATE glpi_helpdesks_tiles_glpipagetiles
   SET title = 'Xem bài viết trợ giúp',
       description = 'Xem toàn bộ bài viết trợ giúp và các câu hỏi thường gặp.'
 WHERE title = 'Browse help articles';
UPDATE glpi_helpdesks_tiles_glpipagetiles
   SET title = 'Tạo phiếu yêu cầu',
       description = 'Mở danh mục dịch vụ và chọn biểu mẫu để tạo phiếu mới.'
 WHERE title = 'Create a ticket';
UPDATE glpi_helpdesks_tiles_glpipagetiles
   SET title = 'Xem phiếu của bạn',
       description = 'Xem toàn bộ phiếu yêu cầu bạn đã tạo.'
 WHERE title = 'See your tickets';
UPDATE glpi_helpdesks_tiles_glpipagetiles
   SET title = 'Đặt mượn thiết bị',
       description = 'Chọn một thiết bị còn trống và đặt mượn theo ngày.'
 WHERE title = 'Make a reservation';

-- 4.2. Biểu mẫu (thẻ "Báo cáo sự cố" / "Yêu cầu dịch vụ")
UPDATE glpi_forms_forms
   SET name = 'Báo cáo sự cố',
       description = 'Yêu cầu hỗ trợ từ đội ngũ trợ giúp.'
 WHERE name = 'Report an issue';
UPDATE glpi_forms_forms
   SET name = 'Yêu cầu dịch vụ',
       description = 'Yêu cầu đội ngũ cung cấp một dịch vụ.'
 WHERE name = 'Request a service';

-- 4.3. Nội dung bên trong biểu mẫu (phần sinh viên điền)
UPDATE glpi_forms_sections SET name = 'Thông tin sự cố' WHERE name = 'First section';
UPDATE glpi_forms_questions SET name = 'Mức độ khẩn cấp' WHERE name = 'Urgency';
UPDATE glpi_forms_questions SET name = 'Danh mục'        WHERE name = 'Category';
UPDATE glpi_forms_questions SET name = 'Thiết bị của bạn' WHERE name = 'User devices';
UPDATE glpi_forms_questions SET name = 'Người theo dõi'  WHERE name = 'Observers';
UPDATE glpi_forms_questions SET name = 'Vị trí'          WHERE name = 'Location';
UPDATE glpi_forms_questions SET name = 'Tiêu đề'         WHERE name = 'Title';
UPDATE glpi_forms_questions SET name = 'Mô tả'           WHERE name = 'Description';
UPDATE glpi_forms_destinations_formdestinations SET name = 'Phiếu yêu cầu' WHERE name = 'Ticket';
SQL

# Kiểm chứng ngay bằng truy vấn đọc lại
echo ""
xanh "  Kết quả sau khi Việt hoá:"
docker exec "$DB_CONTAINER" sh -c "MYSQL_PWD=\"\$MARIADB_ROOT_PASSWORD\" mysql -uroot $DB_NAME -e \"
  SELECT CONCAT('    Đơn vị gốc      : ', name) FROM glpi_entities WHERE id = 0;
  SELECT CONCAT('    Bảng điều khiển : ', GROUP_CONCAT(name ORDER BY id SEPARATOR ' | ')) FROM glpi_dashboards_dashboards;
  SELECT CONCAT('    Hồ sơ quyền     : ', GROUP_CONCAT(name ORDER BY id SEPARATOR ' | ')) FROM glpi_profiles;
\"" 2>/dev/null

echo ""
xanh "  [OK] Đã Việt hoá dữ liệu."
echo "  Nhớ xoá bộ nhớ đệm để giao diện nhận thay đổi:"
echo "    docker exec pinedesk-redis redis-cli FLUSHALL"
echo "    docker exec pinedesk-glpi sh -c 'rm -rf /var/glpi/files/_cache/*'"
