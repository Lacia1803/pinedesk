-- =============================================================================
--  SLA THẬT + CƠ CHẾ CHỐNG LẠM DỤNG (TẦNG NGHIỆP VỤ)
--  PineDesk - Trường Đại học Đà Lạt
-- =============================================================================
--  Tệp này chạy SAU khi đã có dữ liệu nền (scripts/nap-du-lieu-nen.sh) và sau
--  dữ liệu mẫu (scripts/nap-du-lieu-mau.sh).
--
--  Gồm 2 phần:
--    PHẦN A - Cấu hình SLA thật trong GLPI (hạn phản hồi / hạn giải quyết)
--    PHẦN B - Bảng nhật ký + quy tắc chống lạm dụng (trần phiếu, chống trùng)
--
--  VÌ SAO LÀM Ở ĐÂY:
--    README trước đây ghi "cam kết SLA" nhưng CSDL GLPI KHÔNG có bản ghi SLA
--    nào -> đó là tuyên bố suông. Tệp này biến nó thành dữ liệu thật.
--
--  Idempotent: chạy lại nhiều lần không tạo dữ liệu trùng.
-- =============================================================================

SET NAMES utf8mb4;
SET @now := NOW();

-- =============================================================================
--  PHẦN A - SLA THẬT
-- =============================================================================
--  GLPI lưu SLA ở 3 bảng:
--    glpi_slas        : định nghĩa mức dịch vụ (TTO = thời gian phản hồi,
--                       TTR = thời gian giải quyết)
--    glpi_slalevels   : các mốc thời gian của một SLA
--    glpi_slalevels_tickets : SLA đã áp cho từng phiếu
--
--  Quy ước đặt mức (KHÔNG phải cam kết của Trường - xem ghi chú cuối tệp):
--    Rất thấp : phản hồi 8 giờ  | giải quyết 48 giờ
--    Thấp     : phản hồi 4 giờ  | giải quyết 24 giờ
--    Trung bình: phản hồi 2 giờ | giải quyết 8 giờ
--    Cao      : phản hồi 1 giờ  | giải quyết 4 giờ
--    Rất cao  : phản hồi 30 phút| giải quyết 2 giờ
-- -----------------------------------------------------------------------------

-- A.1. Tạo 10 định nghĩa SLA: 5 mức ưu tiên x 2 loại (TTO = phản hồi, TTR = giải quyết)
--      VÌ SAO 2 LOẠI: cột glpi_slas.type NOT NULL (SLM::TTO=1, SLM::TTR=0).
--      GLPI tách "thời gian phản hồi" và "thời gian giải quyết" thành 2 bản ghi.
--      (Bản cũ chỉ tạo 1 bản ghi/SLA và dùng cột 'exec_time' không tồn tại ->
--       lỗi 1054 khi nạp. Đã tra DESCRIBE trên CSDL thật và sửa.)
--      DỌN BẢN CŨ: phiên bản trước tạo SLA tên trần kiểu 'SLA - Ưu tiên rất thấp (P1)'
--      (thiếu hậu tố '— phản hồi'/'— giải quyết') và dùng sai cột type/number_time.
--      Xoá mốc rồi xoá SLA cũ để tránh trùng lặp khi nạp lại. An toàn vì bản cũ
--      chưa từng được gán vào phiếu nào (glpi_slalevels_tickets rỗng).
DELETE l FROM glpi_slalevels l
  JOIN glpi_slas s ON l.slas_id = s.id
 WHERE s.name IN ('SLA - Ưu tiên rất thấp (P1)', 'SLA - Ưu tiên thấp (P2)',
                  'SLA - Ưu tiên trung bình (P3)', 'SLA - Ưu tiên cao (P4)',
                  'SLA - Ưu tiên rất cao (P5)');
DELETE FROM glpi_slas
 WHERE name IN ('SLA - Ưu tiên rất thấp (P1)', 'SLA - Ưu tiên thấp (P2)',
                'SLA - Ưu tiên trung bình (P3)', 'SLA - Ưu tiên cao (P4)',
                'SLA - Ưu tiên rất cao (P5)');

INSERT INTO glpi_slas
    (name, comment, type, date_creation, date_mod, is_recursive, entities_id,
     calendars_id, number_time, definition_time, end_of_working_day)
SELECT 'SLA - Ưu tiên rất thấp (P1) — phản hồi',
       'Phản hồi 8 giờ. Mức mặc định cho sự cố không gấp.',
       1, @now, @now, 0, 0, 0, 8, 'hour', 0
WHERE NOT EXISTS (SELECT 1 FROM glpi_slas WHERE name = 'SLA - Ưu tiên rất thấp (P1) — phản hồi');

INSERT INTO glpi_slas
    (name, comment, type, date_creation, date_mod, is_recursive, entities_id,
     calendars_id, number_time, definition_time, end_of_working_day)
SELECT 'SLA - Ưu tiên thấp (P2) — phản hồi',
       'Phản hồi 4 giờ. Sự cố ảnh hưởng một người.',
       1, @now, @now, 0, 0, 0, 4, 'hour', 0
WHERE NOT EXISTS (SELECT 1 FROM glpi_slas WHERE name = 'SLA - Ưu tiên thấp (P2) — phản hồi');

INSERT INTO glpi_slas
    (name, comment, type, date_creation, date_mod, is_recursive, entities_id,
     calendars_id, number_time, definition_time, end_of_working_day)
SELECT 'SLA - Ưu tiên trung bình (P3) — phản hồi',
       'Phản hồi 2 giờ. Sự cố phòng máy ảnh hưởng một lớp học.',
       1, @now, @now, 0, 0, 0, 2, 'hour', 0
WHERE NOT EXISTS (SELECT 1 FROM glpi_slas WHERE name = 'SLA - Ưu tiên trung bình (P3) — phản hồi');

INSERT INTO glpi_slas
    (name, comment, type, date_creation, date_mod, is_recursive, entities_id,
     calendars_id, number_time, definition_time, end_of_working_day)
SELECT 'SLA - Ưu tiên cao (P4) — phản hồi',
       'Phản hồi 1 giờ. Sự cố ảnh hưởng nhiều lớp / thiết bị mạng.',
       1, @now, @now, 0, 0, 0, 1, 'hour', 0
WHERE NOT EXISTS (SELECT 1 FROM glpi_slas WHERE name = 'SLA - Ưu tiên cao (P4) — phản hồi');

INSERT INTO glpi_slas
    (name, comment, type, date_creation, date_mod, is_recursive, entities_id,
     calendars_id, number_time, definition_time, end_of_working_day)
SELECT 'SLA - Ưu tiên rất cao (P5) — phản hồi',
       'Phản hồi 30 phút. Máy chủ / hạ tầng mạng hỏng.',
       1, @now, @now, 0, 0, 0, 30, 'minute', 0
WHERE NOT EXISTS (SELECT 1 FROM glpi_slas WHERE name = 'SLA - Ưu tiên rất cao (P5) — phản hồi');

INSERT INTO glpi_slas
    (name, comment, type, date_creation, date_mod, is_recursive, entities_id,
     calendars_id, number_time, definition_time, end_of_working_day)
SELECT 'SLA - Ưu tiên rất thấp (P1) — giải quyết',
       'Giải quyết 48 giờ.',
       0, @now, @now, 0, 0, 0, 48, 'hour', 0
WHERE NOT EXISTS (SELECT 1 FROM glpi_slas WHERE name = 'SLA - Ưu tiên rất thấp (P1) — giải quyết');

INSERT INTO glpi_slas
    (name, comment, type, date_creation, date_mod, is_recursive, entities_id,
     calendars_id, number_time, definition_time, end_of_working_day)
SELECT 'SLA - Ưu tiên thấp (P2) — giải quyết',
       'Giải quyết 24 giờ.',
       0, @now, @now, 0, 0, 0, 24, 'hour', 0
WHERE NOT EXISTS (SELECT 1 FROM glpi_slas WHERE name = 'SLA - Ưu tiên thấp (P2) — giải quyết');

INSERT INTO glpi_slas
    (name, comment, type, date_creation, date_mod, is_recursive, entities_id,
     calendars_id, number_time, definition_time, end_of_working_day)
SELECT 'SLA - Ưu tiên trung bình (P3) — giải quyết',
       'Giải quyết 8 giờ.',
       0, @now, @now, 0, 0, 0, 8, 'hour', 0
WHERE NOT EXISTS (SELECT 1 FROM glpi_slas WHERE name = 'SLA - Ưu tiên trung bình (P3) — giải quyết');

INSERT INTO glpi_slas
    (name, comment, type, date_creation, date_mod, is_recursive, entities_id,
     calendars_id, number_time, definition_time, end_of_working_day)
SELECT 'SLA - Ưu tiên cao (P4) — giải quyết',
       'Giải quyết 4 giờ.',
       0, @now, @now, 0, 0, 0, 4, 'hour', 0
WHERE NOT EXISTS (SELECT 1 FROM glpi_slas WHERE name = 'SLA - Ưu tiên cao (P4) — giải quyết');

INSERT INTO glpi_slas
    (name, comment, type, date_creation, date_mod, is_recursive, entities_id,
     calendars_id, number_time, definition_time, end_of_working_day)
SELECT 'SLA - Ưu tiên rất cao (P5) — giải quyết',
       'Giải quyết 2 giờ.',
       0, @now, @now, 0, 0, 0, 2, 'hour', 0
WHERE NOT EXISTS (SELECT 1 FROM glpi_slas WHERE name = 'SLA - Ưu tiên rất cao (P5) — giải quyết');


-- A.2. Tạo mốc thời gian (glpi_slalevels) cho từng SLA chưa có mốc.
--      Cột THẬT của GLPI 11: execution_time (không phải 'exec_time'),
--      match ('AND'), entities_id, is_recursive. KHÔNG có date_creation/date_mod.
--      execution_time tính bằng GIÂY; chuyển từ number_time + definition_time.
INSERT INTO glpi_slalevels (slas_id, name, execution_time, is_active, entities_id, is_recursive, `match`)
SELECT s.id, 'Mốc chính',
       CASE
         WHEN s.definition_time = 'minute' THEN s.number_time * 60
         WHEN s.definition_time = 'hour'   THEN s.number_time * 3600
         ELSE s.number_time
       END,
       1, 0, 0, 'AND'
  FROM glpi_slas s
 WHERE NOT EXISTS (SELECT 1 FROM glpi_slalevels l
                    WHERE l.slas_id = s.id);


-- A.3. KHÔNG gán cứng SLA vào từng phiếu ở đây.
--      Việc gán SLA thật do GLPI tự làm khi phiếu được tạo, DỰA TRÊN:
--        - mức ưu tiên (priority 1..5)  -> người tạo chọn khi mở phiếu
--        - quy tắc nghiệp vụ (business rules) -> cấu hình qua giao diện GLPI
--      Gán cứng bằng SQL sẽ SAI khi có phiếu mới -> để quy tắc lo.
--      Kiểm tra trạng thái: xem câu SELECT ở cuối tệp.

-- =============================================================================
--  PHẦN B - CƠ CHẾ CHỐNG LẠM DỤNG (TẦNG NGHIỆP VỤ)
-- =============================================================================
--  Nginx mới chặn được TỐC ĐỘ (rate) theo IP. Nó không biết:
--    - ai là ai (IP bị NAT chung cả phòng máy)
--    - người này đang có bao nhiêu phiếu mở
--    - phiếu này có trùng với phiếu vừa nộp không
--  => Cần tầng nghiệp vụ. Bảng dưới đây là sổ ghi để đếm & phát hiện trùng.
-- -----------------------------------------------------------------------------

-- B.1. Bảng nhật ký tạo phiếu (audit + đếm theo tài khoản)
--      Vì sao không dùng log của GLPI: log GLPI ghi chung nhiều loại hành động,
--      truy vấn đếm sẽ chậm. Bảng riêng này chỉ ghi 1 việc: AI tạo phiếu, KHI NÀO,
--      TRÙNG VỚI GÌ -> đếm nhanh và rõ nghĩa.
CREATE TABLE IF NOT EXISTS glpi_plugin_pinedesk_ticketlog (
    id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
    users_id      INT UNSIGNED NOT NULL DEFAULT 0,
    tickets_id    INT UNSIGNED NOT NULL DEFAULT 0,
    ip_address    VARCHAR(45)      NULL,
    tickets_id_dup INT UNSIGNED   NOT NULL DEFAULT 0,
    reason        VARCHAR(64)      NULL COMMENT 'ly do: NEW / DUP_BLOCKED / LIMIT_BLOCKED',
    date_creation TIMESTAMP        NULL DEFAULT NULL,
    PRIMARY KEY (id),
    KEY idx_user_date (users_id, date_creation),
    KEY idx_tickets   (tickets_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- B.2. Bảng hạn mức (cấu hình được, không hardcode trong mã)
CREATE TABLE IF NOT EXISTS glpi_plugin_pinedesk_limits (
    id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
    rule_name      VARCHAR(64)  NOT NULL,
    mo_ta          VARCHAR(255)     NULL,
    so_phieu_mo_toi_da INT      NOT NULL DEFAULT 5  COMMENT 'so phieu dang mo toi da / nguoi',
    so_phieu_ngay_toi_da INT    NOT NULL DEFAULT 10 COMMENT 'so phieu tao toi da / nguoi / ngay',
    cua_so_trung_phut  INT      NOT NULL DEFAULT 30 COMMENT 'cua so phat hien trung (phut)',
    is_active      TINYINT(1)   NOT NULL DEFAULT 1,
    date_mod       TIMESTAMP    NULL DEFAULT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_rule (rule_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO glpi_plugin_pinedesk_limits
    (rule_name, mo_ta, so_phieu_mo_toi_da, so_phieu_ngay_toi_da, cua_so_trung_phut, is_active, date_mod)
SELECT 'mac_dinh',
       'Hạn mức mặc định: tối đa 5 phiếu mở cùng lúc, 10 phiếu/ngày, cửa sổ chống trùng 30 phút',
       5, 10, 30, 1, @now
WHERE NOT EXISTS (SELECT 1 FROM glpi_plugin_pinedesk_limits WHERE rule_name = 'mac_dinh');

-- B.3. View đếm nhanh phục vụ kiểm tra hạn mức (dùng khi cần tra tay / demo)
CREATE OR REPLACE VIEW v_pinedesk_phieu_dang_mo AS
SELECT t.users_id_recipient AS users_id,
       COUNT(*)              AS so_phieu_mo
  FROM glpi_tickets t
 WHERE t.is_deleted = 0
   AND t.status IN (1, 2, 3, 4)   -- Mới, Được giao, Đã lên kế hoạch, Chờ
 GROUP BY t.users_id_recipient;

-- =============================================================================
--  PHẦN B2 - BẢO TRÌ ĐỊNH KỲ THẬT (glpi_ticketrecurrents)
-- =============================================================================
--  VÌ SAO LÀM Ở ĐÂY:
--    seed-du-lieu-mau.sql mục 8 chỉ đánh dấu ngày bảo trì gần nhất cho 2 thiết
--    bị, kèm ghi chú "lịch thật phải tạo qua giao diện". Nay tạo lịch THẬT
--    bằng cơ chế GỐC của GLPI (glpi_ticketrecurrents) - không sửa lõi.
--    Cron 'ticketrecurrent' của GLPI tự sinh phiếu theo chu kỳ.
--
--  LƯU Ý VỀ ĐỊNH DẠNG periodicity (đã tra mã nguồn GLPI 11):
--    - Theo giờ / ngày: số nguyên giây  (vd 86400 = 1 ngày)
--    - Theo tháng      : chuỗi '1MONTH', '3MONTH'
--    - Theo năm        : chuỗi '1YEAR'
-- -----------------------------------------------------------------------------

-- B2.1. Mẫu phiếu "Bảo trì phòng máy định kỳ"
INSERT INTO glpi_tickettemplates (name, entities_id, is_recursive, comment)
SELECT 'Bảo trì phòng máy định kỳ', 0, 1, 'Mẫu tự động tạo phiếu bảo trì hàng tháng'
WHERE NOT EXISTS (SELECT 1 FROM glpi_tickettemplates WHERE name = 'Bảo trì phòng máy định kỳ');

SET @tmpl_id := (SELECT id FROM glpi_tickettemplates WHERE name = 'Bảo trì phòng máy định kỳ');

-- Predefined: tiêu đề (num=1 -> name)
INSERT INTO glpi_tickettemplatepredefinedfields (tickettemplates_id, num, value)
SELECT @tmpl_id, 1, 'Bảo trì phòng máy định kỳ — [tự động]'
WHERE @tmpl_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM glpi_tickettemplatepredefinedfields
                   WHERE tickettemplates_id = @tmpl_id AND num = 1);

-- Predefined: nội dung (num=21 -> content)
INSERT INTO glpi_tickettemplatepredefinedfields (tickettemplates_id, num, value)
SELECT @tmpl_id, 21, 'Phiếu tự động tạo bởi hệ thống PineDesk.\nKỹ thuật viên kiểm tra: vệ sinh bụi, tra keo tản nhiệt, kiểm tra ổ cứng, cập nhật phần mềm.\nSau khi hoàn tất, ghi kết quả vào phiếu rồi đóng.'
WHERE @tmpl_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM glpi_tickettemplatepredefinedfields
                   WHERE tickettemplates_id = @tmpl_id AND num = 21);

-- Predefined: loại = Yêu cầu (num=14 -> type, 2=Request)
INSERT INTO glpi_tickettemplatepredefinedfields (tickettemplates_id, num, value)
SELECT @tmpl_id, 14, '2'
WHERE @tmpl_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM glpi_tickettemplatepredefinedfields
                   WHERE tickettemplates_id = @tmpl_id AND num = 14);

-- Predefined: danh mục = 'Bảo trì phòng máy' (num=7 -> itilcategories_id)
SET @cat_baotri := (SELECT id FROM glpi_itilcategories WHERE name = 'Bảo trì phòng máy' LIMIT 1);
INSERT INTO glpi_tickettemplatepredefinedfields (tickettemplates_id, num, value)
SELECT @tmpl_id, 7, @cat_baotri
WHERE @tmpl_id IS NOT NULL AND @cat_baotri IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM glpi_tickettemplatepredefinedfields
                   WHERE tickettemplates_id = @tmpl_id AND num = 7);

-- Predefined: ưu tiên = Trung bình (num=3 -> priority, 3=Medium)
INSERT INTO glpi_tickettemplatepredefinedfields (tickettemplates_id, num, value)
SELECT @tmpl_id, 3, '3'
WHERE @tmpl_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM glpi_tickettemplatepredefinedfields
                   WHERE tickettemplates_id = @tmpl_id AND num = 3);

-- B2.2. Lịch bảo trì hàng tháng
INSERT INTO glpi_ticketrecurrents
    (name, comment, entities_id, is_active, tickettemplates_id,
     begin_date, periodicity, create_before, next_creation_date,
     calendars_id, end_date)
SELECT 'Bảo trì phòng máy — hàng tháng',
       'Tự động tạo phiếu bảo trì phòng máy vào đầu mỗi tháng. Kỹ thuật viên nhận phiếu → thực hiện → đóng.',
       0, 1, @tmpl_id,
       DATE_FORMAT(@now, '%Y-%m-01 08:00:00'),
       '1MONTH',
       604800,
       DATE_FORMAT(DATE_ADD(@now, INTERVAL 1 MONTH), '%Y-%m-01 08:00:00'),
       0, NULL
WHERE @tmpl_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM glpi_ticketrecurrents
                   WHERE name = 'Bảo trì phòng máy — hàng tháng');

-- B2.3. Mẫu phiếu "Kiểm tra thiết bị mạng định kỳ"
INSERT INTO glpi_tickettemplates (name, entities_id, is_recursive, comment)
SELECT 'Kiểm tra thiết bị mạng định kỳ', 0, 1, 'Mẫu tự động tạo phiếu kiểm tra switch/AP hàng quý'
WHERE NOT EXISTS (SELECT 1 FROM glpi_tickettemplates WHERE name = 'Kiểm tra thiết bị mạng định kỳ');

SET @tmpl_net := (SELECT id FROM glpi_tickettemplates WHERE name = 'Kiểm tra thiết bị mạng định kỳ');
SET @cat_mang  := (SELECT id FROM glpi_itilcategories WHERE name = 'Kiểm tra thiết bị mạng' LIMIT 1);

INSERT INTO glpi_tickettemplatepredefinedfields (tickettemplates_id, num, value)
SELECT @tmpl_net, 1, 'Kiểm tra thiết bị mạng định kỳ — [tự động]'
WHERE @tmpl_net IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM glpi_tickettemplatepredefinedfields
                   WHERE tickettemplates_id = @tmpl_net AND num = 1);

INSERT INTO glpi_tickettemplatepredefinedfields (tickettemplates_id, num, value)
SELECT @tmpl_net, 21, 'Phiếu tự động: kiểm tra switch, access point, cáp mạng, tốc độ kết nối.\nGhi kết quả đo vào phiếu.'
WHERE @tmpl_net IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM glpi_tickettemplatepredefinedfields
                   WHERE tickettemplates_id = @tmpl_net AND num = 21);

INSERT INTO glpi_tickettemplatepredefinedfields (tickettemplates_id, num, value)
SELECT @tmpl_net, 14, '2'
WHERE @tmpl_net IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM glpi_tickettemplatepredefinedfields
                   WHERE tickettemplates_id = @tmpl_net AND num = 14);

INSERT INTO glpi_tickettemplatepredefinedfields (tickettemplates_id, num, value)
SELECT @tmpl_net, 7, @cat_mang
WHERE @tmpl_net IS NOT NULL AND @cat_mang IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM glpi_tickettemplatepredefinedfields
                   WHERE tickettemplates_id = @tmpl_net AND num = 7);

INSERT INTO glpi_tickettemplatepredefinedfields (tickettemplates_id, num, value)
SELECT @tmpl_net, 3, '3'
WHERE @tmpl_net IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM glpi_tickettemplatepredefinedfields
                   WHERE tickettemplates_id = @tmpl_net AND num = 3);

INSERT INTO glpi_ticketrecurrents
    (name, comment, entities_id, is_active, tickettemplates_id,
     begin_date, periodicity, create_before, next_creation_date,
     calendars_id, end_date)
SELECT 'Kiểm tra thiết bị mạng — hàng quý',
       'Tự động tạo phiếu kiểm tra switch/AP mỗi 3 tháng.',
       0, 1, @tmpl_net,
       DATE_FORMAT(@now, '%Y-%m-01 08:00:00'),
       '3MONTH',
       604800,
       DATE_FORMAT(DATE_ADD(@now, INTERVAL 3 MONTH), '%Y-%m-01 08:00:00'),
       0, NULL
WHERE @tmpl_net IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM glpi_ticketrecurrents
                   WHERE name = 'Kiểm tra thiết bị mạng — hàng quý');

-- =============================================================================
--  PHẦN B3 - MƯỢN / TRẢ THIẾT BỊ (glpi_reservations gốc của GLPI)
-- =============================================================================
--  VÌ SAO LÀM Ở ĐÂY:
--    SO-SANH mục 4.2 hàng 9 ghi "luồng mượn/trả chưa dựng riêng". GLPI đã có
--    sẵn bảng đặt mượn (glpi_reservationitems + glpi_reservations). Dùng hàng
--    GỐC thay vì tạo bảng riêng -> giao diện Reservation của GLPI hiển thị được.
-- -----------------------------------------------------------------------------

-- B3.1. Cho 2 laptop vào diện được đặt mượn
SET @lap3 := (SELECT id FROM glpi_computers WHERE name = 'TDL-LAP-003' LIMIT 1);
SET @lap1 := (SELECT id FROM glpi_computers WHERE name = 'TDL-LAP-001' LIMIT 1);

INSERT INTO glpi_reservationitems (itemtype, entities_id, is_recursive, items_id, comment, is_active)
SELECT 'Computer', 0, 1, @lap3, 'Laptop cho sinh viên mượn khi cần', 1
WHERE @lap3 IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM glpi_reservationitems
                   WHERE itemtype = 'Computer' AND items_id = @lap3);

INSERT INTO glpi_reservationitems (itemtype, entities_id, is_recursive, items_id, comment, is_active)
SELECT 'Computer', 0, 1, @lap1, 'Laptop dự phòng cho giảng viên mượn', 1
WHERE @lap1 IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM glpi_reservationitems
                   WHERE itemtype = 'Computer' AND items_id = @lap1);

-- B3.2. Hai lượt mượn mẫu: 1 đang mượn, 1 đã trả
SET @sv_hoa   := (SELECT id FROM glpi_users WHERE name = 'sv.hoa' LIMIT 1);
SET @gv_cuong := (SELECT id FROM glpi_users WHERE name = 'gv.cuong' LIMIT 1);
SET @ri_lap3  := (SELECT id FROM glpi_reservationitems WHERE itemtype = 'Computer' AND items_id = @lap3);
SET @ri_lap1  := (SELECT id FROM glpi_reservationitems WHERE itemtype = 'Computer' AND items_id = @lap1);

INSERT INTO glpi_reservations (reservationitems_id, begin, end, users_id, comment, `group`)
SELECT @ri_lap3,
       DATE_SUB(@now, INTERVAL 1 DAY),
       DATE_ADD(@now, INTERVAL 2 DAY),
       @sv_hoa,
       'Mượn laptop để làm đồ án môn học',
       0
WHERE @ri_lap3 IS NOT NULL AND @sv_hoa IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM glpi_reservations r
                   WHERE r.reservationitems_id = @ri_lap3 AND r.users_id = @sv_hoa);

INSERT INTO glpi_reservations (reservationitems_id, begin, end, users_id, comment, `group`)
SELECT @ri_lap1,
       DATE_SUB(@now, INTERVAL 10 DAY),
       DATE_SUB(@now, INTERVAL 7 DAY),
       @gv_cuong,
       'Mượn laptop dự phòng cho buổi giảng',
       0
WHERE @ri_lap1 IS NOT NULL AND @gv_cuong IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM glpi_reservations r
                   WHERE r.reservationitems_id = @ri_lap1 AND r.users_id = @gv_cuong);

-- B3.3. Phiếu yêu cầu mượn (nối luồng phiếu với luồng đặt mượn)
SET @cat_muon := (SELECT id FROM glpi_itilcategories WHERE name = 'Mượn thiết bị tạm thời' LIMIT 1);

INSERT INTO glpi_tickets
    (entities_id, name, date, date_mod, status, users_id_recipient,
     requesttypes_id, content, urgency, impact, priority,
     itilcategories_id, type, is_deleted, date_creation)
SELECT 0,
       'Mượn laptop cho đồ án môn Mạng máy tính',
       DATE_SUB(@now, INTERVAL 1 DAY),
       @now,
       5,
       @sv_hoa,
       1,
       'Em cần mượn 1 laptop để làm đồ án môn Mạng máy tính từ ngày mai đến cuối tuần.\nEm sẽ trả vào thứ Hai tuần sau.\n\nThông tin:\n- MSSV: 2112345\n- Lớp: CTK44\n- Môn: Mạng máy tính',
       3, 3, 3,
       @cat_muon,
       1,
       0,
       DATE_SUB(@now, INTERVAL 1 DAY)
WHERE @sv_hoa IS NOT NULL AND @cat_muon IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM glpi_tickets
                   WHERE name = 'Mượn laptop cho đồ án môn Mạng máy tính');

-- =============================================================================
--  PHẦN C - PHIẾU QUÁ HẠN (dữ liệu để demo cảnh báo SLA)
-- =============================================================================
--  VÌ SAO CẦN:
--    Mục 4.2 trong SO-SANH ghi "Phiếu quá hạn: chưa có dữ liệu" -> không demo
--    được cảnh báo SLA. Phần này tạo vài phiếu ĐÃ QUÁ HẠN PHẢN HỒI để khi trình
--    diễn có cái chỉ vào mà nói "hệ thống phát hiện trễ hạn".
--
--  AN TOÀN: chỉ đặt mốc thời gian quá khứ cho phiếu ĐANG MỞ (status 1/2).
--    KHÔNG sửa phiếu đã giải quyết/đã đóng -> không làm sai lịch sử.
-- -----------------------------------------------------------------------------

-- C.1. Gán hạn phản hồi CHO CÁC PHIẾU ĐANG MỞ có ưu tiên >= 3 (trung bình trở lên),
--      mốc thời gian tính từ ngày tạo theo bảng SLA ở PHẦN A.
UPDATE glpi_tickets t
   SET t.time_to_own = DATE_ADD(t.date, INTERVAL
         CASE t.priority
           WHEN 5 THEN 30     -- 30 phút
           WHEN 4 THEN 60     -- 1 giờ
           WHEN 3 THEN 120    -- 2 giờ
           WHEN 2 THEN 240    -- 4 giờ
           ELSE 480           -- 8 giờ
         END MINUTE),
       t.time_to_resolve = DATE_ADD(t.date, INTERVAL
         CASE t.priority
           WHEN 5 THEN 120
           WHEN 4 THEN 240
           WHEN 3 THEN 480
           WHEN 2 THEN 1440
           ELSE 2880
         END MINUTE),
       t.date_mod = @now
 WHERE t.is_deleted = 0
   AND t.status IN (1, 2)
   AND t.time_to_own IS NULL
   AND t.date IS NOT NULL;

-- C.2. Đẩy NGÀY TẠO của 2 phiếu mở xuống quá khứ để mốc hạn đã trôi qua
--      -> thành phiếu QUÁ HẠN thật, demo được cảnh báo.
--      Chọn phiếu có id nhỏ nhất trong các phiếu đang mở để ổn định.
SET @tq1 := (SELECT MIN(id) FROM glpi_tickets WHERE is_deleted=0 AND status IN (1,2));
SET @tq2 := (SELECT MIN(id) FROM glpi_tickets WHERE is_deleted=0 AND status IN (1,2) AND id > @tq1);

UPDATE glpi_tickets
   SET date = DATE_SUB(@now, INTERVAL 3 DAY),
       time_to_own = DATE_SUB(@now, INTERVAL 70 HOUR),
       time_to_resolve = DATE_SUB(@now, INTERVAL 1 DAY),
       date_mod = @now
 WHERE id = @tq1;

UPDATE glpi_tickets
   SET date = DATE_SUB(@now, INTERVAL 2 DAY),
       time_to_own = DATE_SUB(@now, INTERVAL 44 HOUR),
       time_to_resolve = DATE_SUB(@now, INTERVAL 12 HOUR),
       date_mod = @now
 WHERE id = @tq2;

-- =============================================================================
--  KẾT QUẢ
-- =============================================================================
SELECT '=== SLA + CHONG LAM DUNG DA CAU HINH ===' AS ' ';
SELECT 'SLA đã tạo'            AS 'Hạng mục', COUNT(*) AS 'Số lượng' FROM glpi_slas
UNION ALL SELECT 'Mốc SLA (slalevels)',   COUNT(*) FROM glpi_slalevels
UNION ALL SELECT 'Bảng nhật ký phiếu',    COUNT(*) FROM information_schema.tables
      WHERE table_schema = DATABASE() AND table_name = 'glpi_plugin_pinedesk_ticketlog'
UNION ALL SELECT 'Quy tắc hạn mức',       COUNT(*) FROM glpi_plugin_pinedesk_limits
UNION ALL SELECT 'Phiếu QUÁ HẠN (demo)',  COUNT(*) FROM glpi_tickets
      WHERE is_deleted=0 AND status IN (1,2)
        AND time_to_own IS NOT NULL AND time_to_own < NOW()
UNION ALL SELECT 'Lịch bảo trì tự động',  COUNT(*) FROM glpi_ticketrecurrents
UNION ALL SELECT 'Thiết bị cho mượn',     COUNT(*) FROM glpi_reservationitems
UNION ALL SELECT 'Lượt đặt mượn',         COUNT(*) FROM glpi_reservations;

-- -----------------------------------------------------------------------------
--  GHI CHÚ TRUNG THỰC (không được bỏ khi thuyết minh):
--
--  1. Con số 8h/4h/2h/1h/30p Ở TRÊN LÀ ĐỀ XUẤT KỸ THUẬT của đồ án, KHÔNG phải
--     cam kết đã được Trường Đại học Đà Lạt ban hành. Muốn thành SLA thật phải
--     có văn bản phê duyệt của Trung tâm CNTT (ITC).
--
--  2. Bảng glpi_plugin_pinedesk_ticketlog và _limits do ĐỒ ÁN tự tạo, nằm NGOÀI
--     lõi GLPI. Khi nâng cấp GLPI, hai bảng này KHÔNG bị ảnh hưởng.
--
--  3. Cơ chế CHẶN theo hạn mức (B.2) chưa được thực thi tự động trong tệp này.
--     Tệp chỉ TẠO CẤU TRÚC + HẠN MỨC. Phần thực thi nằm ở:
--       - Quy tắc nghiệp vụ của GLPI (business rules) - cấu hình qua giao diện
--       - hoặc script kiểm tra định kỳ (xem scripts/kiem-tra-lam-dung.sh)
--     Lý do tách: ghi thẳng vào lõi GLPI sẽ làm mất tính "tùy biến ngoài lõi".
-- -----------------------------------------------------------------------------
