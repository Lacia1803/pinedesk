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

DB_CONTAINER="helpdesk-db"
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
docker exec -i "$DB_CONTAINER" sh -c "mysql -uroot -p\"\$MARIADB_ROOT_PASSWORD\" $DB_NAME" <<'SQL'
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

-- 3. Tên hồ sơ quyền (chỉ là dữ liệu, mã nguồn không tham chiếu tên)
UPDATE glpi_profiles SET name = 'Người dùng'       WHERE name = 'Self-Service';
UPDATE glpi_profiles SET name = 'Người quan sát'   WHERE name = 'Observer';
UPDATE glpi_profiles SET name = 'Quản trị viên'    WHERE name = 'Admin';
UPDATE glpi_profiles SET name = 'Quản trị cấp cao' WHERE name = 'Super-Admin';
UPDATE glpi_profiles SET name = 'Trực tổng đài'    WHERE name = 'Hotliner';
UPDATE glpi_profiles SET name = 'Kỹ thuật viên'    WHERE name = 'Technician';
UPDATE glpi_profiles SET name = 'Giám sát'         WHERE name = 'Supervisor';
UPDATE glpi_profiles SET name = 'Chỉ đọc'          WHERE name = 'Read-Only';
SQL

# Kiểm chứng ngay bằng truy vấn đọc lại
echo ""
xanh "  Kết quả sau khi Việt hoá:"
docker exec "$DB_CONTAINER" sh -c "mysql -uroot -p\"\$MARIADB_ROOT_PASSWORD\" $DB_NAME -e \"
  SELECT CONCAT('    Đơn vị gốc      : ', name) FROM glpi_entities WHERE id = 0;
  SELECT CONCAT('    Bảng điều khiển : ', GROUP_CONCAT(name ORDER BY id SEPARATOR ' | ')) FROM glpi_dashboards_dashboards;
  SELECT CONCAT('    Hồ sơ quyền     : ', GROUP_CONCAT(name ORDER BY id SEPARATOR ' | ')) FROM glpi_profiles;
\"" 2>/dev/null

echo ""
xanh "  [OK] Đã Việt hoá dữ liệu."
echo "  Nhớ xoá bộ nhớ đệm để giao diện nhận thay đổi:"
echo "    docker exec helpdesk-redis redis-cli FLUSHALL"
echo "    docker exec helpdesk-glpi sh -c 'rm -rf /var/glpi/files/_cache/*'"
