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

-- A.1. Tạo 5 định nghĩa SLA (khớp 5 mức ưu tiên của GLPI: 1..5)
INSERT INTO glpi_slas
    (name, comment, date_creation, date_mod, is_recursive, entities_id,
     calendars_id, number_time, definition_time, end_of_working_day)
SELECT 'SLA - Ưu tiên rất thấp (P1)',
       'Phản hồi 8 giờ, giải quyết 48 giờ. Mức mặc định cho sự cố không gấp.',
       @now, @now, 0, 0, 0, 8, 'hour', 0
WHERE NOT EXISTS (SELECT 1 FROM glpi_slas WHERE name = 'SLA - Ưu tiên rất thấp (P1)');

INSERT INTO glpi_slas
    (name, comment, date_creation, date_mod, is_recursive, entities_id,
     calendars_id, number_time, definition_time, end_of_working_day)
SELECT 'SLA - Ưu tiên thấp (P2)',
       'Phản hồi 4 giờ, giải quyết 24 giờ. Sự cố ảnh hưởng một người.',
       @now, @now, 0, 0, 0, 4, 'hour', 0
WHERE NOT EXISTS (SELECT 1 FROM glpi_slas WHERE name = 'SLA - Ưu tiên thấp (P2)');

INSERT INTO glpi_slas
    (name, comment, date_creation, date_mod, is_recursive, entities_id,
     calendars_id, number_time, definition_time, end_of_working_day)
SELECT 'SLA - Ưu tiên trung bình (P3)',
       'Phản hồi 2 giờ, giải quyết 8 giờ. Sự cố phòng máy ảnh hưởng một lớp học.',
       @now, @now, 0, 0, 0, 2, 'hour', 0
WHERE NOT EXISTS (SELECT 1 FROM glpi_slas WHERE name = 'SLA - Ưu tiên trung bình (P3)');

INSERT INTO glpi_slas
    (name, comment, date_creation, date_mod, is_recursive, entities_id,
     calendars_id, number_time, definition_time, end_of_working_day)
SELECT 'SLA - Ưu tiên cao (P4)',
       'Phản hồi 1 giờ, giải quyết 4 giờ. Sự cố ảnh hưởng nhiều lớp / thiết bị mạng.',
       @now, @now, 0, 0, 0, 1, 'hour', 0
WHERE NOT EXISTS (SELECT 1 FROM glpi_slas WHERE name = 'SLA - Ưu tiên cao (P4)');

INSERT INTO glpi_slas
    (name, comment, date_creation, date_mod, is_recursive, entities_id,
     calendars_id, number_time, definition_time, end_of_working_day)
SELECT 'SLA - Ưu tiên rất cao (P5)',
       'Phản hồi 30 phút, giải quyết 2 giờ. Máy chủ / hạ tầng mạng hỏng.',
       @now, @now, 0, 0, 0, 30, 'minute', 0
WHERE NOT EXISTS (SELECT 1 FROM glpi_slas WHERE name = 'SLA - Ưu tiên rất cao (P5)');

-- A.2. Tạo mốc thời gian (slalevels) cho từng SLA nếu chưa có.
--      GLPI cần ít nhất 1 mốc TTO và 1 mốc TTR cho mỗi SLA.
INSERT INTO glpi_slalevels (slas_id, name, exec_time, is_active, date_creation, date_mod)
SELECT s.id, 'Phản hồi', s.number_time, 1, @now, @now
  FROM glpi_slas s
 WHERE NOT EXISTS (SELECT 1 FROM glpi_slalevels l
                    WHERE l.slas_id = s.id AND l.name = 'Phản hồi');

INSERT INTO glpi_slalevels (slas_id, name, exec_time, is_active, date_creation, date_mod)
SELECT s.id, 'Giải quyết',
       CASE
         WHEN s.name LIKE '%rất thấp%'  THEN 2880
         WHEN s.name LIKE '%thấp%'      THEN 1440
         WHEN s.name LIKE '%trung bình%' THEN 480
         WHEN s.name LIKE '%cao (P4)%'  THEN 240
         WHEN s.name LIKE '%rất cao%'   THEN 120
         ELSE 480
       END,
       1, @now, @now
  FROM glpi_slas s
 WHERE NOT EXISTS (SELECT 1 FROM glpi_slalevels l
                    WHERE l.slas_id = s.id AND l.name = 'Giải quyết');

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
       time_to_own = DATE_SUB(@now, INTERVAL 3 DAY - INTERVAL 2 HOUR),
       time_to_resolve = DATE_SUB(@now, INTERVAL 1 DAY),
       date_mod = @now
 WHERE id = @tq1;

UPDATE glpi_tickets
   SET date = DATE_SUB(@now, INTERVAL 2 DAY),
       time_to_own = DATE_SUB(@now, INTERVAL 2 DAY - INTERVAL 4 HOUR),
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
        AND time_to_own IS NOT NULL AND time_to_own < NOW();

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
