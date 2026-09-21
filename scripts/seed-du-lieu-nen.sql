-- ==============================================================================
--  DU LIEU NEN HE THONG IT HELPDESK - TRUONG DAI HOC DA LAT
--  File: seed-du-lieu-nen.sql
--
--  MO TA:
--    Tao danh muc nghiep vu day du cho he thong GLPI 11:
--    - Vi tri: khuon vien > toa nha > phong may / phong lab
--    - Trang thai thiet bi
--    - Hang san xuat
--    - Loai thiet bi (theo tung nhom: may tinh, man hinh, may in, ngoai vi, mang)
--    - Model thiet bi thuong dung
--    - Loai su co (danh muc ticket phan cap 2 muc)
--    - Nguon tiep nhan su co
--    - Hinh thuc xu ly
--
--  CACH CHAY:
--    docker exec -i helpdesk-db mariadb -u root -p"<mat khau root>" glpi \
--        < scripts/seed-du-lieu-nen.sql
--
--  HOAC dung script tien loi:
--    bash scripts/nap-du-lieu-nen.sh
--
--  LUU Y: Chay lai nhieu lan KHONG tao du lieu trung (co kiem tra NOT EXISTS).
-- ==============================================================================

SET NAMES utf8mb4;
SET time_zone = '+07:00';

-- ==============================================================================
--  1. VI TRI (glpi_locations)
--     Cau truc 3 cap, dua tren so do thuc te Truong Dai hoc Da Lat
--     Dia chi: 01 Phu Dong Thien Vuong, Phuong Lam Vien, TP Da Lat, Lam Dong
-- ==============================================================================

-- 1.1. Cap 1: Khuon vien chinh
INSERT INTO glpi_locations (name, completename, level, locations_id, comment, entities_id, is_recursive, date_creation, date_mod)
SELECT 'Trường Đại học Đà Lạt', 'Trường Đại học Đà Lạt', 1, 0,
       'Số 01 Phù Đổng Thiên Vương, Phường Lâm Viên, TP Đà Lạt, tỉnh Lâm Đồng',
       0, 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM glpi_locations WHERE name = 'Trường Đại học Đà Lạt');

SET @root_id = (SELECT id FROM glpi_locations WHERE name = 'Trường Đại học Đà Lạt' LIMIT 1);

-- 1.2. Cap 2: Cac toa nha trong khuon vien
INSERT INTO glpi_locations (name, completename, level, locations_id, comment, entities_id, is_recursive, date_creation, date_mod)
SELECT t.name, CONCAT('Trường Đại học Đà Lạt > ', t.name), 2, @root_id, t.comment, 0, 1, NOW(), NOW()
FROM (
    SELECT 'Tòa nhà A' AS name, 'Khu hành chính và phòng học lý thuyết' AS comment UNION ALL
    SELECT 'Tòa nhà B', 'Khu giảng đường và phòng học lớn' UNION ALL
    SELECT 'Tòa nhà C', 'Khu phòng thí nghiệm và thực hành' UNION ALL
    SELECT 'Tòa nhà D', 'Khu chuyên ngành Công nghệ thông tin' UNION ALL
    SELECT 'Tòa nhà E', 'Khu Nông lâm và Sinh học' UNION ALL
    SELECT 'Tòa nhà F', 'Thư viện và Trung tâm học liệu' UNION ALL
    SELECT 'Tòa nhà G', 'Khu nghiên cứu khoa học' UNION ALL
    SELECT 'Tòa nhà H', 'Khu thể thao và giáo dục thể chất' UNION ALL
    SELECT 'Khu Ký túc xá', 'Khu nội trú sinh viên' UNION ALL
    SELECT 'Trung tâm CNTT (ITC)', 'Trung tâm Công nghệ thông tin - đơn vị vận hành hạ tầng số' UNION ALL
    SELECT 'Khu hành chính H1', 'Các phòng ban chức năng' UNION ALL
    SELECT 'Khu dịch vụ', 'Căng tin và khu dịch vụ sinh viên'
) t
WHERE NOT EXISTS (SELECT 1 FROM glpi_locations WHERE name = t.name);

-- 1.3. Cap 3: Phong may va phong lab
INSERT INTO glpi_locations (name, completename, level, locations_id, comment, entities_id, is_recursive, date_creation, date_mod)
SELECT p.name,
       CONCAT('Trường Đại học Đà Lạt > ', p.building, ' > ', p.name),
       3,
       (SELECT id FROM glpi_locations WHERE name = p.building LIMIT 1),
       p.comment, 0, 1, NOW(), NOW()
FROM (
    -- Toa nha A - Hanh chinh & phong hoc
    SELECT 'Phòng máy A101' AS name, 'Tòa nhà A' AS building, 'Phòng thực hành 40 máy tính' AS comment UNION ALL
    SELECT 'Phòng máy A102', 'Tòa nhà A', 'Phòng thực hành 40 máy tính' UNION ALL
    SELECT 'Phòng máy A201', 'Tòa nhà A', 'Phòng thực hành 30 máy tính' UNION ALL
    SELECT 'Phòng học A103', 'Tòa nhà A', 'Phòng học lý thuyết có máy chiếu' UNION ALL
    SELECT 'Phòng học A104', 'Tòa nhà A', 'Phòng học lý thuyết có máy chiếu' UNION ALL
    SELECT 'Phòng học A105', 'Tòa nhà A', 'Phòng học lý thuyết' UNION ALL
    SELECT 'Văn phòng Khoa Toán - Tin học', 'Tòa nhà A', 'Khu làm việc giảng viên' UNION ALL

    -- Toa nha B - Giang duong
    SELECT 'Giảng đường B1', 'Tòa nhà B', 'Hội trường lớn 200 chỗ' UNION ALL
    SELECT 'Giảng đường B2', 'Tòa nhà B', 'Giảng đường 150 chỗ' UNION ALL
    SELECT 'Giảng đường B3', 'Tòa nhà B', 'Giảng đường 120 chỗ' UNION ALL
    SELECT 'Phòng máy B201', 'Tòa nhà B', 'Phòng thực hành 45 máy tính' UNION ALL
    SELECT 'Phòng máy B202', 'Tòa nhà B', 'Phòng thực hành 45 máy tính' UNION ALL
    SELECT 'Phòng học B203', 'Tòa nhà B', 'Phòng học lý thuyết' UNION ALL
    SELECT 'Phòng học B204', 'Tòa nhà B', 'Phòng học lý thuyết' UNION ALL

    -- Toa nha C - Thi nghiem
    SELECT 'Phòng thí nghiệm C101', 'Tòa nhà C', 'Phòng thí nghiệm Vật lý' UNION ALL
    SELECT 'Phòng thí nghiệm C102', 'Tòa nhà C', 'Phòng thí nghiệm Hóa học' UNION ALL
    SELECT 'Phòng thí nghiệm C103', 'Tòa nhà C', 'Phòng thí nghiệm Sinh học' UNION ALL
    SELECT 'Phòng máy C201', 'Tòa nhà C', 'Phòng thực hành 35 máy tính' UNION ALL
    SELECT 'Phòng thí nghiệm C202', 'Tòa nhà C', 'Phòng thí nghiệm Điện tử - Viễn thông' UNION ALL
    SELECT 'Phòng thí nghiệm C203', 'Tòa nhà C', 'Phòng thí nghiệm Vật lý hạt nhân' UNION ALL

    -- Toa nha D - CNTT (trong tam cua he thong)
    SELECT 'Phòng máy D101', 'Tòa nhà D', 'Phòng thực hành lập trình - 50 máy' UNION ALL
    SELECT 'Phòng máy D102', 'Tòa nhà D', 'Phòng thực hành mạng - 40 máy' UNION ALL
    SELECT 'Phòng máy D103', 'Tòa nhà D', 'Phòng thực hành cơ sở dữ liệu - 40 máy' UNION ALL
    SELECT 'Phòng máy D201', 'Tòa nhà D', 'Phòng thực hành Trí tuệ nhân tạo - 30 máy' UNION ALL
    SELECT 'Phòng Lab D202', 'Tòa nhà D', 'Phòng Lab mạng Cisco' UNION ALL
    SELECT 'Phòng máy chủ D203', 'Tòa nhà D', 'Phòng đặt máy chủ, có điều hòa riêng' UNION ALL
    SELECT 'Văn phòng Khoa Công nghệ thông tin', 'Tòa nhà D', 'Khu làm việc giảng viên CNTT' UNION ALL

    -- Toa nha E - Nong lam, Sinh hoc
    SELECT 'Phòng thí nghiệm E101', 'Tòa nhà E', 'Phòng thí nghiệm Sinh học phân tử' UNION ALL
    SELECT 'Phòng thí nghiệm E102', 'Tòa nhà E', 'Phòng thí nghiệm Nông học' UNION ALL
    SELECT 'Phòng thí nghiệm E201', 'Tòa nhà E', 'Phòng thí nghiệm Công nghệ thực phẩm' UNION ALL
    SELECT 'Văn phòng Khoa Nông lâm', 'Tòa nhà E', 'Khu làm việc giảng viên' UNION ALL

    -- Toa nha F - Thu vien
    SELECT 'Phòng máy tra cứu F101', 'Tòa nhà F', 'Phòng tra cứu tài liệu số - 25 máy' UNION ALL
    SELECT 'Phòng học nhóm F102', 'Tòa nhà F', 'Phòng học nhóm có màn hình lớn' UNION ALL
    SELECT 'Phòng học nhóm F103', 'Tòa nhà F', 'Phòng học nhóm' UNION ALL
    SELECT 'Kho tài liệu F201', 'Tòa nhà F', 'Kho sách và tài liệu' UNION ALL

    -- Toa nha G - Nghien cuu
    SELECT 'Phòng nghiên cứu G101', 'Tòa nhà G', 'Phòng nghiên cứu Khoa học dữ liệu' UNION ALL
    SELECT 'Phòng nghiên cứu G102', 'Tòa nhà G', 'Phòng nghiên cứu Kỹ thuật hạt nhân' UNION ALL
    SELECT 'Phòng nghiên cứu G201', 'Tòa nhà G', 'Phòng nghiên cứu Công nghệ sinh học' UNION ALL

    -- Toa nha H - The thao
    SELECT 'Phòng máy H101', 'Tòa nhà H', 'Phòng thực hành tin học cơ bản' UNION ALL
    SELECT 'Văn phòng Bộ môn Giáo dục thể chất', 'Tòa nhà H', 'Khu làm việc giảng viên' UNION ALL

    -- Trung tam CNTT (ITC) - don vi van hanh he thong
    SELECT 'Trung tâm Điều hành ITC', 'Trung tâm CNTT (ITC)', 'Phòng điều hành hạ tầng mạng' UNION ALL
    SELECT 'Phòng máy ITC-01', 'Trung tâm CNTT (ITC)', 'Phòng đào tạo CNTT cơ bản - 40 máy' UNION ALL
    SELECT 'Phòng máy ITC-02', 'Trung tâm CNTT (ITC)', 'Phòng đào tạo CNTT nâng cao - 40 máy' UNION ALL
    SELECT 'Phòng máy ITC-03', 'Trung tâm CNTT (ITC)', 'Phòng luyện thi chứng chỉ CNTT - 35 máy' UNION ALL
    SELECT 'Phòng Robotics', 'Trung tâm CNTT (ITC)', 'Không gian sáng tạo Robotics' UNION ALL
    SELECT 'Kho thiết bị ITC', 'Trung tâm CNTT (ITC)', 'Kho lưu thiết bị dự phòng' UNION ALL

    -- Khu hanh chinh
    SELECT 'Phòng Tổ chức Hành chính', 'Khu hành chính H1', 'Phòng ban chức năng' UNION ALL
    SELECT 'Phòng Quản lý Đào tạo', 'Khu hành chính H1', 'Phòng ban chức năng' UNION ALL
    SELECT 'Phòng Tài chính Kế hoạch', 'Khu hành chính H1', 'Phòng ban chức năng' UNION ALL
    SELECT 'Phòng Công tác Sinh viên', 'Khu hành chính H1', 'Phòng ban chức năng' UNION ALL
    SELECT 'Phòng Khoa học Công nghệ', 'Khu hành chính H1', 'Phòng ban chức năng' UNION ALL
    SELECT 'Văn phòng Đoàn - Hội', 'Khu hành chính H1', 'Văn phòng đoàn thể' UNION ALL

    -- Khu dich vu
    SELECT 'Căng tin sinh viên', 'Khu dịch vụ', 'Khu ăn uống sinh viên' UNION ALL
    SELECT 'Nhà xe sinh viên', 'Khu dịch vụ', 'Khu gửi xe'
) p
WHERE NOT EXISTS (SELECT 1 FROM glpi_locations WHERE name = p.name);


-- ==============================================================================
--  2. TRANG THAI THIET BI (glpi_states)
-- ==============================================================================
INSERT INTO glpi_states (name, comment, states_id, level, is_recursive, is_helpdesk_visible, date_creation, date_mod)
SELECT s.name, s.comment, 0, 1, 1, 1, NOW(), NOW()
FROM (
    SELECT 'Đang hoạt động tốt' AS name, 'Thiết bị hoạt động bình thường, sẵn sàng sử dụng' AS comment UNION ALL
    SELECT 'Đang sử dụng', 'Đã cấp phát và đang được sử dụng' UNION ALL
    SELECT 'Trong kho', 'Thiết bị dự phòng, chưa cấp phát' UNION ALL
    SELECT 'Đang sửa chữa', 'Đang được kỹ thuật viên xử lý' UNION ALL
    SELECT 'Chờ linh kiện', 'Đang chờ linh kiện thay thế' UNION ALL
    SELECT 'Hỏng', 'Thiết bị hỏng, không sử dụng được' UNION ALL
    SELECT 'Chờ thanh lý', 'Hết khấu hao, chờ thủ tục thanh lý' UNION ALL
    SELECT 'Đã thanh lý', 'Đã hoàn tất thủ tục thanh lý' UNION ALL
    SELECT 'Đang bảo trì định kỳ', 'Đang trong đợt bảo trì theo lịch' UNION ALL
    SELECT 'Mất hoặc thất lạc', 'Thiết bị bị mất, đang xác minh'
) s
WHERE NOT EXISTS (SELECT 1 FROM glpi_states WHERE name = s.name);


-- ==============================================================================
--  3. HANG SAN XUAT (glpi_manufacturers)
-- ==============================================================================
INSERT INTO glpi_manufacturers (name, date_creation, date_mod)
SELECT m.name, NOW(), NOW()
FROM (
    SELECT 'Dell' AS name UNION ALL
    SELECT 'HP' UNION ALL
    SELECT 'Lenovo' UNION ALL
    SELECT 'Asus' UNION ALL
    SELECT 'Acer' UNION ALL
    SELECT 'Apple' UNION ALL
    SELECT 'MSI' UNION ALL
    SELECT 'FPT Elead' UNION ALL
    SELECT 'Samsung' UNION ALL
    SELECT 'LG' UNION ALL
    SELECT 'ViewSonic' UNION ALL
    SELECT 'Cisco' UNION ALL
    SELECT 'TP-Link' UNION ALL
    SELECT 'D-Link' UNION ALL
    SELECT 'Huawei' UNION ALL
    SELECT 'Ubiquiti' UNION ALL
    SELECT 'Canon' UNION ALL
    SELECT 'Epson' UNION ALL
    SELECT 'Brother' UNION ALL
    SELECT 'Logitech' UNION ALL
    SELECT 'APC' UNION ALL
    SELECT 'Synology' UNION ALL
    SELECT 'Xiaomi' UNION ALL
    SELECT 'Panasonic'
) m
WHERE NOT EXISTS (SELECT 1 FROM glpi_manufacturers WHERE name = m.name);


-- ==============================================================================
--  4. LOAI THIET BI - theo tung nhom (GLPI 11 dung bang rieng cho moi nhom)
-- ==============================================================================

-- 4.1. Loai may tinh
INSERT INTO glpi_computertypes (name, comment, date_creation, date_mod)
SELECT t.name, t.comment, NOW(), NOW()
FROM (
    SELECT 'Máy tính để bàn' AS name, 'Máy trạm cố định tại phòng máy' AS comment UNION ALL
    SELECT 'Máy tính xách tay', 'Thiết bị di động cấp cho giảng viên' UNION ALL
    SELECT 'Máy trạm đồ họa', 'Máy cấu hình cao phục vụ thiết kế' UNION ALL
    SELECT 'Máy chủ', 'Server phục vụ hạ tầng' UNION ALL
    SELECT 'Thiết bị Robotics', 'Bộ kit Robotics phục vụ đào tạo'
) t
WHERE NOT EXISTS (SELECT 1 FROM glpi_computertypes WHERE name = t.name);

-- 4.2. Loai man hinh
INSERT INTO glpi_monitortypes (name, comment, date_creation, date_mod)
SELECT t.name, t.comment, NOW(), NOW()
FROM (
    SELECT 'Màn hình 19 inch' AS name, 'Màn hình cỡ nhỏ' AS comment UNION ALL
    SELECT 'Màn hình 21.5 inch', 'Màn hình phổ thông' UNION ALL
    SELECT 'Màn hình 24 inch', 'Màn hình tiêu chuẩn phòng máy' UNION ALL
    SELECT 'Màn hình 27 inch', 'Màn hình lớn' UNION ALL
    SELECT 'Màn hình cảm ứng', 'Màn hình tương tác'
) t
WHERE NOT EXISTS (SELECT 1 FROM glpi_monitortypes WHERE name = t.name);

-- 4.3. Loai may in
INSERT INTO glpi_printertypes (name, comment, date_creation, date_mod)
SELECT t.name, t.comment, NOW(), NOW()
FROM (
    SELECT 'Máy in laser đen trắng' AS name, 'Máy in văn phòng thông dụng' AS comment UNION ALL
    SELECT 'Máy in laser màu', 'Máy in màu cho văn phòng' UNION ALL
    SELECT 'Máy in phun', 'Máy in phun màu' UNION ALL
    SELECT 'Máy in đa chức năng', 'In, scan, photocopy' UNION ALL
    SELECT 'Máy scan', 'Máy quét tài liệu chuyên dụng'
) t
WHERE NOT EXISTS (SELECT 1 FROM glpi_printertypes WHERE name = t.name);

-- 4.4. Loai thiet bi ngoai vi
INSERT INTO glpi_peripheraltypes (name, comment, date_creation, date_mod)
SELECT t.name, t.comment, NOW(), NOW()
FROM (
    SELECT 'Bàn phím' AS name, 'Bàn phím máy tính' AS comment UNION ALL
    SELECT 'Chuột máy tính', 'Chuột có dây và không dây' UNION ALL
    SELECT 'Tai nghe', 'Tai nghe có dây và không dây' UNION ALL
    SELECT 'Loa máy tính', 'Loa để bàn' UNION ALL
    SELECT 'Webcam', 'Camera phục vụ học trực tuyến' UNION ALL
    SELECT 'Máy chiếu', 'Máy chiếu phục vụ giảng dạy' UNION ALL
    SELECT 'Bảng tương tác', 'Bảng tương tác thông minh' UNION ALL
    SELECT 'Bộ lưu điện (UPS)', 'UPS và ổn áp' UNION ALL
    SELECT 'Ổ cứng di động', 'Ổ cứng gắn ngoài' UNION ALL
    SELECT 'USB', 'Thiết bị lưu trữ USB' UNION ALL
    SELECT 'Camera giám sát', 'Camera an ninh trong khuôn viên' UNION ALL
    SELECT 'Bộ chuyển đổi tín hiệu', 'HDMI, VGA, USB-C adapter'
) t
WHERE NOT EXISTS (SELECT 1 FROM glpi_peripheraltypes WHERE name = t.name);

-- 4.5. Loai thiet bi mang
INSERT INTO glpi_networkequipmenttypes (name, comment, date_creation, date_mod)
SELECT t.name, t.comment, NOW(), NOW()
FROM (
    SELECT 'Bộ chuyển mạch (Switch)' AS name, 'Switch các loại' AS comment UNION ALL
    SELECT 'Bộ định tuyến (Router)', 'Router các loại' UNION ALL
    SELECT 'Bộ phát WiFi (Access Point)', 'Access Point' UNION ALL
    SELECT 'Tường lửa (Firewall)', 'Thiết bị bảo mật mạng' UNION ALL
    SELECT 'Bộ cân bằng tải', 'Load balancer' UNION ALL
    SELECT 'Thiết bị NAS', 'Thiết bị lưu trữ mạng' UNION ALL
    SELECT 'Bộ chuyển đổi quang', 'Media converter' UNION ALL
    SELECT 'Tủ mạng (Rack)', 'Tủ rack chứa thiết bị mạng'
) t
WHERE NOT EXISTS (SELECT 1 FROM glpi_networkequipmenttypes WHERE name = t.name);

-- 4.6. Loai phan mem (theo nhom chuc nang)
INSERT INTO glpi_softwarecategories (name, comment)
SELECT t.name, t.comment
FROM (
    SELECT 'Hệ điều hành' AS name, 'Windows, Linux, macOS' AS comment UNION ALL
    SELECT 'Bộ văn phòng', 'Microsoft Office, LibreOffice' UNION ALL
    SELECT 'Lập trình', 'IDE, compiler, môi trường phát triển' UNION ALL
    SELECT 'Đồ họa - Thiết kế', 'Photoshop, Illustrator, AutoCAD' UNION ALL
    SELECT 'Cơ sở dữ liệu', 'MySQL, SQL Server, PostgreSQL' UNION ALL
    SELECT 'Trí tuệ nhân tạo', 'Python, Anaconda, TensorFlow' UNION ALL
    SELECT 'Mạng - Bảo mật', 'Cisco Packet Tracer, Wireshark' UNION ALL
    SELECT 'Tiện ích', 'Trình duyệt, giải nén, diệt virus' UNION ALL
    SELECT 'Mô phỏng khoa học', 'MATLAB, SPSS, mô phỏng vật lý' UNION ALL
    SELECT 'Quản lý giáo dục', 'Phần mềm quản lý đào tạo'
) t
WHERE NOT EXISTS (SELECT 1 FROM glpi_softwarecategories WHERE name = t.name);


-- ==============================================================================
--  5. MODEL THIET BI THUONG DUNG
--     LUU Y GLPI 11: Hang san xuat gan voi TAI SAN (glpi_computers...),
--     khong gan voi model. Model chi luu ten va so san pham.
--     Vi vay phan nay chi tao ten model.
-- ==============================================================================

-- 5.1. Model may tinh
INSERT INTO glpi_computermodels (name, date_creation, date_mod)
SELECT m.name, NOW(), NOW()
FROM (
    SELECT 'OptiPlex 3080' AS name UNION ALL
    SELECT 'OptiPlex 5090' UNION ALL
    SELECT 'OptiPlex 7090' UNION ALL
    SELECT 'Latitude 3420' UNION ALL
    SELECT 'Latitude 5420' UNION ALL
    SELECT 'Vostro 3400' UNION ALL
    SELECT 'ProDesk 400 G7' UNION ALL
    SELECT 'ProDesk 600 G6' UNION ALL
    SELECT 'EliteDesk 800 G6' UNION ALL
    SELECT 'ProBook 450 G8' UNION ALL
    SELECT 'ThinkCentre M720' UNION ALL
    SELECT 'ThinkCentre M75q' UNION ALL
    SELECT 'ThinkPad E14' UNION ALL
    SELECT 'IdeaCentre AIO 3' UNION ALL
    SELECT 'ProArt Station D940MX' UNION ALL
    SELECT 'ExpertCenter D500' UNION ALL
    SELECT 'Veriton X2660G' UNION ALL
    SELECT 'PowerEdge R740' UNION ALL
    SELECT 'ProLiant DL380' UNION ALL
    SELECT 'PowerEdge T340'
) m
WHERE NOT EXISTS (SELECT 1 FROM glpi_computermodels WHERE name = m.name);

-- 5.2. Model man hinh
INSERT INTO glpi_monitormodels (name, date_creation, date_mod)
SELECT m.name, NOW(), NOW()
FROM (
    SELECT 'P2419H' AS name UNION ALL
    SELECT 'P2422H' UNION ALL
    SELECT 'E2222H' UNION ALL
    SELECT 'E2422HN' UNION ALL
    SELECT 'S2421HN' UNION ALL
    SELECT 'LS24R350' UNION ALL
    SELECT '24MP400' UNION ALL
    SELECT '27MP400' UNION ALL
    SELECT 'VA2419' UNION ALL
    SELECT 'VA2447'
) m
WHERE NOT EXISTS (SELECT 1 FROM glpi_monitormodels WHERE name = m.name);

-- 5.3. Model may in
INSERT INTO glpi_printermodels (name, date_creation, date_mod)
SELECT m.name, NOW(), NOW()
FROM (
    SELECT 'LaserJet Pro M404dn' AS name UNION ALL
    SELECT 'LaserJet M1136' UNION ALL
    SELECT 'LaserJet M126nw' UNION ALL
    SELECT 'LaserJet Pro MFP M428fdw' UNION ALL
    SELECT 'imageCLASS LBP2900' UNION ALL
    SELECT 'imageCLASS MF3010' UNION ALL
    SELECT 'i-SENSYS MF4410' UNION ALL
    SELECT 'HL-L2321D' UNION ALL
    SELECT 'DCP-L2520D' UNION ALL
    SELECT 'EcoTank L3210'
) m
WHERE NOT EXISTS (SELECT 1 FROM glpi_printermodels WHERE name = m.name);

-- 5.4. Model thiet bi mang
INSERT INTO glpi_networkequipmentmodels (name, date_creation, date_mod)
SELECT m.name, NOW(), NOW()
FROM (
    SELECT 'Catalyst 2960-24TT-L' AS name UNION ALL
    SELECT 'Catalyst 2960-48TT-L' UNION ALL
    SELECT 'Catalyst 3560-24PS' UNION ALL
    SELECT 'SG250-24' UNION ALL
    SELECT 'TL-SG1024D' UNION ALL
    SELECT 'TL-SG1048' UNION ALL
    SELECT 'TL-SG3210' UNION ALL
    SELECT 'TL-ER605' UNION ALL
    SELECT 'TL-WA1201' UNION ALL
    SELECT 'DGS-1210-24' UNION ALL
    SELECT 'DIR-825' UNION ALL
    SELECT 'UniFi U6-Lite' UNION ALL
    SELECT 'UniFi Switch 24 PoE' UNION ALL
    SELECT 'AR617VW' UNION ALL
    SELECT 'S5720-28X'
) m
WHERE NOT EXISTS (SELECT 1 FROM glpi_networkequipmentmodels WHERE name = m.name);


-- ==============================================================================
--  6. LOAI SU CO / DANH MUC TICKET (glpi_itilcategories)
--     Cay phan cap 2 muc
-- ==============================================================================

-- 6.1. Cap 1: Nhom su co chinh
INSERT INTO glpi_itilcategories (name, completename, level, itilcategories_id, comment, entities_id, is_recursive, date_creation, date_mod)
SELECT c.name, c.name, 1, 0, c.comment, 0, 1, NOW(), NOW()
FROM (
    SELECT 'Sự cố phần cứng' AS name, 'Lỗi liên quan đến thiết bị vật lý' AS comment UNION ALL
    SELECT 'Sự cố mạng', 'Mất kết nối, mạng chậm, lỗi cấu hình mạng' UNION ALL
    SELECT 'Sự cố phần mềm', 'Lỗi hệ điều hành và ứng dụng' UNION ALL
    SELECT 'Sự cố thiết bị ngoại vi', 'Máy in, máy chiếu, chuột, bàn phím' UNION ALL
    SELECT 'Yêu cầu cài đặt phần mềm', 'Đề nghị cài đặt hoặc cập nhật phần mềm' UNION ALL
    SELECT 'Yêu cầu cấp phát thiết bị', 'Đề nghị cấp mới hoặc thay thế thiết bị' UNION ALL
    SELECT 'Yêu cầu bảo trì định kỳ', 'Đề nghị bảo trì, vệ sinh thiết bị' UNION ALL
    SELECT 'Sự cố tài khoản và truy cập', 'Quên mật khẩu, không đăng nhập được' UNION ALL
    SELECT 'Sự cố an ninh thông tin', 'Nghi ngờ virus, mã độc, truy cập trái phép' UNION ALL
    SELECT 'Yêu cầu khác', 'Các yêu cầu chưa phân loại'
) c
WHERE NOT EXISTS (SELECT 1 FROM glpi_itilcategories WHERE name = c.name AND level = 1);

-- 6.2. Cap 2: Chi tiet tung nhom su co
INSERT INTO glpi_itilcategories (name, completename, level, itilcategories_id, comment, entities_id, is_recursive, date_creation, date_mod)
SELECT s.name,
       CONCAT(s.parent_name, ' > ', s.name),
       2,
       (SELECT id FROM glpi_itilcategories WHERE name = s.parent_name AND level = 1 LIMIT 1),
       s.comment, 0, 1, NOW(), NOW()
FROM (
    -- Su co phan cung
    SELECT 'Máy không khởi động được' AS name, 'Sự cố phần cứng' AS parent_name, 'Nhấn nguồn không lên, không có tín hiệu' AS comment UNION ALL
    SELECT 'Máy tự tắt hoặc khởi động lại', 'Sự cố phần cứng', 'Máy đang dùng thì tự tắt hoặc khởi động lại' UNION ALL
    SELECT 'Máy tính chạy chậm bất thường', 'Sự cố phần cứng', 'Hiệu năng giảm rõ rệt so với bình thường' UNION ALL
    SELECT 'Màn hình không hiển thị', 'Sự cố phần cứng', 'Màn hình đen, không lên hình' UNION ALL
    SELECT 'Màn hình có sọc hoặc nhấp nháy', 'Sự cố phần cứng', 'Hiển thị lỗi hình ảnh' UNION ALL
    SELECT 'Ổ cứng có tiếng kêu lạ', 'Sự cố phần cứng', 'Tiếng kêu bất thường phát ra từ ổ cứng' UNION ALL
    SELECT 'Quạt tản nhiệt kêu to', 'Sự cố phần cứng', 'Quạt chạy ồn, máy nóng bất thường' UNION ALL
    SELECT 'Pin máy tính xách tay chai', 'Sự cố phần cứng', 'Pin nhanh hết, không giữ được điện' UNION ALL
    SELECT 'Máy báo lỗi màn hình xanh', 'Sự cố phần cứng', 'Lỗi màn hình xanh trên Windows' UNION ALL
    SELECT 'Cổng kết nối không hoạt động', 'Sự cố phần cứng', 'Cổng USB, HDMI không nhận thiết bị' UNION ALL

    -- Su co mang
    SELECT 'Không kết nối được Internet', 'Sự cố mạng', 'Mất kết nối hoàn toàn' UNION ALL
    SELECT 'Mạng chậm, tải trang lâu', 'Sự cố mạng', 'Tốc độ dưới mức bình thường' UNION ALL
    SELECT 'Không vào được mạng nội bộ', 'Sự cố mạng', 'Không truy cập được tài nguyên nội bộ trường' UNION ALL
    SELECT 'WiFi không kết nối được', 'Sự cố mạng', 'Không bắt được sóng WiFi' UNION ALL
    SELECT 'WiFi yếu, chập chờn', 'Sự cố mạng', 'Tín hiệu không ổn định' UNION ALL
    SELECT 'Không vào được một số website', 'Sự cố mạng', 'Bị chặn nhầm hoặc lỗi phân giải tên miền' UNION ALL
    SELECT 'Địa chỉ IP bị trùng', 'Sự cố mạng', 'Xung đột địa chỉ IP trong mạng LAN' UNION ALL
    SELECT 'Ổ cắm mạng hỏng', 'Sự cố mạng', 'Cổng mạng RJ45 không hoạt động' UNION ALL
    SELECT 'Thiết bị mạng gặp lỗi', 'Sự cố mạng', 'Switch hoặc Router hoạt động bất thường' UNION ALL
    SELECT 'Không truy cập được hệ thống nội bộ', 'Sự cố mạng', 'Không vào được cổng thông tin, email trường' UNION ALL

    -- Su co phan mem
    SELECT 'Hệ điều hành không khởi động', 'Sự cố phần mềm', 'Windows không vào được' UNION ALL
    SELECT 'Ổ đĩa hệ thống đầy', 'Sự cố phần mềm', 'Hết dung lượng ổ đĩa cài hệ điều hành' UNION ALL
    SELECT 'Phần mềm không chạy được', 'Sự cố phần mềm', 'Ứng dụng báo lỗi khi mở' UNION ALL
    SELECT 'Phần mềm báo lỗi bản quyền', 'Sự cố phần mềm', 'Lỗi giấy phép, hết hạn sử dụng' UNION ALL
    SELECT 'Máy tính bị nhiễm virus', 'Sự cố phần mềm', 'Phát hiện mã độc, quảng cáo lạ' UNION ALL
    SELECT 'Không mở được tập tin', 'Sự cố phần mềm', 'Lỗi định dạng hoặc tập tin bị hỏng' UNION ALL
    SELECT 'Cập nhật hệ thống gây lỗi', 'Sự cố phần mềm', 'Windows Update gây sự cố' UNION ALL
    SELECT 'Trình duyệt hoạt động bất thường', 'Sự cố phần mềm', 'Trình duyệt treo, lỗi hiển thị' UNION ALL
    SELECT 'Mất dữ liệu', 'Sự cố phần mềm', 'Tập tin hoặc thư mục bị mất' UNION ALL

    -- Su co ngoai vi
    SELECT 'Máy in không in được', 'Sự cố thiết bị ngoại vi', 'Lệnh in không thực hiện' UNION ALL
    SELECT 'Máy in ra giấy trắng', 'Sự cố thiết bị ngoại vi', 'Hết mực hoặc lỗi đầu in' UNION ALL
    SELECT 'Máy in bị kẹt giấy', 'Sự cố thiết bị ngoại vi', 'Giấy kẹt trong máy' UNION ALL
    SELECT 'Máy in báo lỗi', 'Sự cố thiết bị ngoại vi', 'Đèn báo lỗi nhấp nháy' UNION ALL
    SELECT 'Máy chiếu không lên hình', 'Sự cố thiết bị ngoại vi', 'Không có tín hiệu chiếu' UNION ALL
    SELECT 'Máy chiếu mờ hoặc sai màu', 'Sự cố thiết bị ngoại vi', 'Chất lượng hình ảnh kém' UNION ALL
    SELECT 'Chuột không hoạt động', 'Sự cố thiết bị ngoại vi', 'Con trỏ không di chuyển' UNION ALL
    SELECT 'Bàn phím bấm không ăn', 'Sự cố thiết bị ngoại vi', 'Một số phím không phản hồi' UNION ALL
    SELECT 'Tai nghe không có âm thanh', 'Sự cố thiết bị ngoại vi', 'Không nghe được tiếng' UNION ALL
    SELECT 'Webcam không hoạt động', 'Sự cố thiết bị ngoại vi', 'Máy không nhận camera' UNION ALL
    SELECT 'UPS báo lỗi', 'Sự cố thiết bị ngoại vi', 'Bộ lưu điện kêu bíp, không giữ điện' UNION ALL

    -- Yeu cau cai dat phan mem
    SELECT 'Cài đặt bộ văn phòng', 'Yêu cầu cài đặt phần mềm', 'Microsoft Office, LibreOffice' UNION ALL
    SELECT 'Cài đặt công cụ lập trình', 'Yêu cầu cài đặt phần mềm', 'Visual Studio, VS Code, Eclipse' UNION ALL
    SELECT 'Cài đặt phần mềm đồ họa', 'Yêu cầu cài đặt phần mềm', 'Photoshop, AutoCAD, Illustrator' UNION ALL
    SELECT 'Cài đặt môi trường trí tuệ nhân tạo', 'Yêu cầu cài đặt phần mềm', 'Python, Anaconda, TensorFlow' UNION ALL
    SELECT 'Cài đặt phần mềm mô phỏng', 'Yêu cầu cài đặt phần mềm', 'MATLAB, SPSS, Cisco Packet Tracer' UNION ALL
    SELECT 'Cập nhật phần mềm hiện có', 'Yêu cầu cài đặt phần mềm', 'Nâng cấp lên phiên bản mới' UNION ALL
    SELECT 'Cài đặt máy in mạng', 'Yêu cầu cài đặt phần mềm', 'Kết nối máy in qua mạng nội bộ' UNION ALL

    -- Yeu cau cap phat
    SELECT 'Cấp mới máy tính', 'Yêu cầu cấp phát thiết bị', 'Đề nghị cấp thiết bị mới' UNION ALL
    SELECT 'Thay thế thiết bị hỏng', 'Yêu cầu cấp phát thiết bị', 'Đổi thiết bị không sửa được' UNION ALL
    SELECT 'Cấp phát linh kiện', 'Yêu cầu cấp phát thiết bị', 'RAM, ổ cứng, nguồn, quạt' UNION ALL
    SELECT 'Mượn thiết bị tạm thời', 'Yêu cầu cấp phát thiết bị', 'Mượn máy chiếu, máy tính xách tay' UNION ALL
    SELECT 'Thu hồi thiết bị', 'Yêu cầu cấp phát thiết bị', 'Thu lại thiết bị không còn sử dụng' UNION ALL

    -- Bao tri dinh ky
    SELECT 'Vệ sinh máy tính định kỳ', 'Yêu cầu bảo trì định kỳ', 'Vệ sinh bụi, tra keo tản nhiệt' UNION ALL
    SELECT 'Bảo trì máy in', 'Yêu cầu bảo trì định kỳ', 'Vệ sinh đầu in, thay mực' UNION ALL
    SELECT 'Kiểm tra thiết bị mạng', 'Yêu cầu bảo trì định kỳ', 'Kiểm tra switch, access point định kỳ' UNION ALL
    SELECT 'Kiểm tra bộ lưu điện', 'Yêu cầu bảo trì định kỳ', 'Kiểm tra ắc quy UPS' UNION ALL
    SELECT 'Bảo trì phòng máy', 'Yêu cầu bảo trì định kỳ', 'Kiểm tra tổng thể phòng máy định kỳ' UNION ALL

    -- Tai khoan va truy cap
    SELECT 'Quên mật khẩu tài khoản', 'Sự cố tài khoản và truy cập', 'Cần cấp lại mật khẩu' UNION ALL
    SELECT 'Không đăng nhập được máy tính', 'Sự cố tài khoản và truy cập', 'Sai tài khoản hoặc bị khóa' UNION ALL
    SELECT 'Không truy cập được thư mục chia sẻ', 'Sự cố tài khoản và truy cập', 'Lỗi phân quyền truy cập' UNION ALL
    SELECT 'Yêu cầu cấp tài khoản mới', 'Sự cố tài khoản và truy cập', 'Tài khoản email, hệ thống đào tạo' UNION ALL
    SELECT 'Yêu cầu mở khóa tài khoản', 'Sự cố tài khoản và truy cập', 'Tài khoản bị khóa do nhập sai nhiều lần' UNION ALL
    SELECT 'Không truy cập được WiFi trường', 'Sự cố tài khoản và truy cập', 'Lỗi xác thực tài khoản WiFi' UNION ALL

    -- An ninh thong tin
    SELECT 'Máy tính có dấu hiệu bị mã độc', 'Sự cố an ninh thông tin', 'Tập tin bị mã hóa, quảng cáo lạ xuất hiện' UNION ALL
    SELECT 'Nhận được email lừa đảo', 'Sự cố an ninh thông tin', 'Email giả mạo, lừa đảo' UNION ALL
    SELECT 'Phát hiện truy cập trái phép', 'Sự cố an ninh thông tin', 'Đăng nhập lạ, nghi rò rỉ dữ liệu' UNION ALL
    SELECT 'Thiết bị USB không rõ nguồn gốc', 'Sự cố an ninh thông tin', 'USB lạ cắm vào máy' UNION ALL
    SELECT 'Mất thiết bị có chứa dữ liệu', 'Sự cố an ninh thông tin', 'Máy tính xách tay, USB bị mất' UNION ALL
    SELECT 'Tài khoản bị xâm nhập', 'Sự cố an ninh thông tin', 'Nghi ngờ tài khoản bị chiếm quyền'
) s
WHERE NOT EXISTS (
    SELECT 1 FROM glpi_itilcategories
    WHERE name = s.name
      AND itilcategories_id = (SELECT id FROM glpi_itilcategories WHERE name = s.parent_name AND level = 1 LIMIT 1)
);


-- ==============================================================================
--  7. NGUON TIEP NHAN SU CO (glpi_requesttypes)
-- ==============================================================================
INSERT INTO glpi_requesttypes (name, is_helpdesk_default, is_followup_default, is_mail_default, is_mailfollowup_default, is_active, is_ticketheader, is_itilfollowup, date_creation, date_mod)
SELECT r.name, r.is_helpdesk_default, 0, 0, 0, 1, 1, 0, NOW(), NOW()
FROM (
    SELECT 'Báo qua mã QR' AS name, 0 AS is_helpdesk_default UNION ALL
    SELECT 'Báo qua điện thoại', 0 UNION ALL
    SELECT 'Báo qua email', 0 UNION ALL
    SELECT 'Báo trực tiếp tại ITC', 0 UNION ALL
    SELECT 'Báo qua cổng thông tin', 1
) r
WHERE NOT EXISTS (SELECT 1 FROM glpi_requesttypes WHERE name = r.name);


-- ==============================================================================
--  8. HINH THUC XU LY (glpi_solutiontypes)
-- ==============================================================================
INSERT INTO glpi_solutiontypes (name, comment, entities_id, is_recursive, date_creation, date_mod)
SELECT s.name, s.comment, 0, 1, NOW(), NOW()
FROM (
    SELECT 'Khởi động lại thiết bị' AS name, 'Xử lý nhanh bằng cách khởi động lại' AS comment UNION ALL
    SELECT 'Thay thế linh kiện', 'Thay RAM, ổ cứng, nguồn, quạt' UNION ALL
    SELECT 'Cài lại hệ điều hành', 'Cài lại Windows và trình điều khiển' UNION ALL
    SELECT 'Cài đặt phần mềm', 'Cài mới hoặc cập nhật phần mềm' UNION ALL
    SELECT 'Cấu hình lại hệ thống', 'Sửa cấu hình mạng, tài khoản' UNION ALL
    SELECT 'Vệ sinh thiết bị', 'Vệ sinh bụi, tra keo tản nhiệt' UNION ALL
    SELECT 'Sửa chữa bo mạch', 'Sửa chữa phần cứng chuyên sâu' UNION ALL
    SELECT 'Đổi sang thiết bị dự phòng', 'Chuyển người dùng sang thiết bị khác' UNION ALL
    SELECT 'Không sửa được, đề nghị thanh lý', 'Thiết bị hỏng nặng' UNION ALL
    SELECT 'Hướng dẫn người dùng', 'Hướng dẫn thao tác, không cần sửa chữa' UNION ALL
    SELECT 'Chuyển đơn vị khác xử lý', 'Ngoài phạm vi trung tâm CNTT'
) s
WHERE NOT EXISTS (SELECT 1 FROM glpi_solutiontypes WHERE name = s.name);


-- ==============================================================================
--  10. NHOM (glpi_groups) - CO CAU TO CHUC THUC TE CUA DH DA LAT
--
--  Nguon: website chinh thuc dlu.edu.vn (truy cap 19/09/2026)
--  - 16 Khoa
--  - 10 Phong chuc nang
--  - 06 Trung tam + 01 Hoc vien
--
--  Cau truc 2 cap:
--     Cap 1: nhom lon (Khoa / Phong ban / Trung tam)
--     Cap 2: cac don vi cu the
--
--  Dung de: phan quyen, gan nguoi dung, thong ke thiet bi theo don vi.
-- ==============================================================================

-- 10.1. Cap 1: 3 nhom lon
INSERT INTO glpi_groups (name, completename, level, groups_id, comment, entities_id, is_recursive, date_creation, date_mod)
SELECT s.name, s.name, 1, 0, s.comment, 0, 1, NOW(), NOW()
FROM (
    SELECT 'Khoa' AS name, 'Các khoa chuyên môn của Trường Đại học Đà Lạt' AS comment UNION ALL
    SELECT 'Phòng chức năng', 'Các phòng ban quản lý, hành chính' UNION ALL
    SELECT 'Trung tâm và Viện', 'Các trung tâm nghiên cứu, đào tạo và dịch vụ'
) s
WHERE NOT EXISTS (SELECT 1 FROM glpi_groups WHERE name = s.name);

-- 10.2. 16 KHOA - lay tu dlu.edu.vn/cac-phong-khoa/
INSERT INTO glpi_groups (name, completename, level, groups_id, comment, entities_id, is_recursive, date_creation, date_mod)
SELECT s.ten, CONCAT('Khoa > ', s.ten), 2,
       (SELECT id FROM (SELECT id FROM glpi_groups WHERE name='Khoa' LIMIT 1) x),
       s.ghi_chu, 0, 1, NOW(), NOW()
FROM (
    SELECT 'Khoa Toán – Tin' AS ten, 'Khoa phụ trách phòng máy tính toán' AS ghi_chu UNION ALL
    SELECT 'Khoa Công nghệ Thông tin', 'Khoa có mật độ thiết bị cao nhất - nhiều phòng máy chuyên ngành' UNION ALL
    SELECT 'Khoa Vật lý và Kỹ thuật hạt nhân', 'Có phòng thí nghiệm chuyên sâu' UNION ALL
    SELECT 'Khoa Hóa học và Môi trường', 'Có phòng thí nghiệm hóa học' UNION ALL
    SELECT 'Khoa Sinh học', 'Có phòng thí nghiệm sinh học' UNION ALL
    SELECT 'Khoa Nông lâm', NULL UNION ALL
    SELECT 'Khoa Ngữ văn và Lịch sử', NULL UNION ALL
    SELECT 'Khoa Kinh tế – Quản trị Kinh doanh', 'Phòng máy thực hành nghiệp vụ kinh tế' UNION ALL
    SELECT 'Khoa Du lịch', NULL UNION ALL
    SELECT 'Khoa Luật học', NULL UNION ALL
    SELECT 'Khoa Ngoại ngữ', 'Có phòng máy học ngoại ngữ (language lab)' UNION ALL
    SELECT 'Khoa Quốc tế học', NULL UNION ALL
    SELECT 'Khoa Xã hội học và Công tác xã hội', NULL UNION ALL
    SELECT 'Khoa Sư phạm', NULL UNION ALL
    SELECT 'Khoa Lý luận Chính trị', NULL UNION ALL
    SELECT 'Khoa Giáo dục thể chất', NULL
) s
WHERE NOT EXISTS (
    SELECT 1 FROM (SELECT name FROM glpi_groups) g WHERE g.name = s.ten
);

-- 10.3. 10 PHONG CHUC NANG
INSERT INTO glpi_groups (name, completename, level, groups_id, comment, entities_id, is_recursive, date_creation, date_mod)
SELECT s.ten, CONCAT('Phòng chức năng > ', s.ten), 2,
       (SELECT id FROM (SELECT id FROM glpi_groups WHERE name='Phòng chức năng' LIMIT 1) x),
       s.ghi_chu, 0, 1, NOW(), NOW()
FROM (
    SELECT 'Phòng Tổ chức – Hành chính' AS ten, NULL AS ghi_chu UNION ALL
    SELECT 'Phòng Quản lý Đào tạo', NULL UNION ALL
    SELECT 'Phòng Chính trị và Công tác Sinh viên', NULL UNION ALL
    SELECT 'Phòng Quản lý chất lượng', NULL UNION ALL
    SELECT 'Phòng Quản lý Khoa học – Hợp tác Quốc tế', NULL UNION ALL
    SELECT 'Phòng Thanh tra', NULL UNION ALL
    SELECT 'Phòng Tài chính', NULL UNION ALL
    SELECT 'Phòng Cơ sở Vật chất', 'ĐƠN VỊ CHỦ QUẢN TÀI SẢN - khách hàng chính của hệ thống' UNION ALL
    SELECT 'Phòng Quản lý Đào tạo Sau Đại học', NULL UNION ALL
    SELECT 'Phòng Tạp chí và Truyền thông', NULL
) s
WHERE NOT EXISTS (
    SELECT 1 FROM (SELECT name FROM glpi_groups) g WHERE g.name = s.ten
);

-- 10.4. 06 TRUNG TAM + 01 HOC VIEN
INSERT INTO glpi_groups (name, completename, level, groups_id, comment, entities_id, is_recursive, date_creation, date_mod)
SELECT s.ten, CONCAT('Trung tâm và Viện > ', s.ten), 2,
       (SELECT id FROM (SELECT id FROM glpi_groups WHERE name='Trung tâm và Viện' LIMIT 1) x),
       s.ghi_chu, 0, 1, NOW(), NOW()
FROM (
    SELECT 'Trung tâm Công nghệ thông tin' AS ten,
           'ĐƠN VỊ VẬN HÀNH KỸ THUẬT - đội kỹ thuật viên chính của hệ thống' AS ghi_chu UNION ALL
    SELECT 'Trung tâm Ngoại ngữ và Đào tạo nguồn nhân lực', 'Có phòng máy học ngoại ngữ' UNION ALL
    SELECT 'Trung tâm Hỗ trợ Khởi nghiệp', NULL UNION ALL
    SELECT 'Trung tâm Phân tích và Kiểm định', 'Có thiết bị phân tích chuyên dụng' UNION ALL
    SELECT 'Trung tâm nghiên cứu đa dạng sinh học và biến đổi khí hậu', NULL UNION ALL
    SELECT 'Trung tâm Giáo dục Quốc phòng và An ninh', NULL UNION ALL
    SELECT 'Học viện King Sejong Đà Lạt', 'Có phòng học đa phương tiện'
) s
WHERE NOT EXISTS (
    SELECT 1 FROM (SELECT name FROM glpi_groups) g WHERE g.name = s.ten
);


-- ==============================================================================
--  KET QUA
-- ==============================================================================
SELECT '=== KET QUA TAO DU LIEU NEN ===' AS ' ';
SELECT 'Vị trí - Tòa nhà'        AS 'Danh mục', COUNT(*) AS 'Số lượng' FROM glpi_locations WHERE level = 2
UNION ALL SELECT 'Vị trí - Phòng máy / Lab', COUNT(*) FROM glpi_locations WHERE level = 3
UNION ALL SELECT 'Nhóm - Khoa',              COUNT(*) FROM glpi_groups WHERE completename LIKE 'Khoa > %'
UNION ALL SELECT 'Nhóm - Phòng chức năng',   COUNT(*) FROM glpi_groups WHERE completename LIKE 'Phòng chức năng > %'
UNION ALL SELECT 'Nhóm - Trung tâm / Viện',  COUNT(*) FROM glpi_groups WHERE completename LIKE 'Trung tâm và Viện > %'
UNION ALL SELECT 'Trạng thái thiết bị',      COUNT(*) FROM glpi_states
UNION ALL SELECT 'Hãng sản xuất',            COUNT(*) FROM glpi_manufacturers
UNION ALL SELECT 'Loại máy tính',            COUNT(*) FROM glpi_computertypes
UNION ALL SELECT 'Loại màn hình',            COUNT(*) FROM glpi_monitortypes
UNION ALL SELECT 'Loại máy in',              COUNT(*) FROM glpi_printertypes
UNION ALL SELECT 'Loại thiết bị ngoại vi',   COUNT(*) FROM glpi_peripheraltypes
UNION ALL SELECT 'Loại thiết bị mạng',       COUNT(*) FROM glpi_networkequipmenttypes
UNION ALL SELECT 'Nhóm phần mềm',            COUNT(*) FROM glpi_softwarecategories
UNION ALL SELECT 'Model máy tính',           COUNT(*) FROM glpi_computermodels
UNION ALL SELECT 'Model màn hình',           COUNT(*) FROM glpi_monitormodels
UNION ALL SELECT 'Model máy in',             COUNT(*) FROM glpi_printermodels
UNION ALL SELECT 'Model thiết bị mạng',      COUNT(*) FROM glpi_networkequipmentmodels
UNION ALL SELECT 'Loại sự cố (cấp 1)',       COUNT(*) FROM glpi_itilcategories WHERE level = 1
UNION ALL SELECT 'Loại sự cố (cấp 2)',       COUNT(*) FROM glpi_itilcategories WHERE level = 2
UNION ALL SELECT 'Nguồn tiếp nhận',          COUNT(*) FROM glpi_requesttypes
UNION ALL SELECT 'Hình thức xử lý',          COUNT(*) FROM glpi_solutiontypes;
