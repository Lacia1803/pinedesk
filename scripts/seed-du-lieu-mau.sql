-- ==============================================================================
--  DU LIEU MAU DE DEMO - HE THONG HO TRO KY THUAT (PINEDESK) DLU
-- ==============================================================================
--  MUC DICH:
--    Tao du lieu thiet bi + phieu su c hoan chinh de:
--      1. Dashboard co so lieu thong ke that
--      2. Demo duoc luong phan cong ky thuat vien
--      3. Sinh duoc ma QR hang loat co y nghia
--
--  DAC TINH:
--    - IDEMPOTENT: chay lai nhieu lan khong sinh du lieu trung
--      (kiem tra bang serial + name truoc khi INSERT)
--    - KHONG xoa du lieu cu, chi THEM moi
--    - Dung ID tham chieu THAT tu du lieu nen (khong hardcode bay)
--
--  CACH CHAY:
--    bash scripts/nap-du-lieu-mau.sh
--    hoac truc tiep:
--      docker exec -i pinedesk-db mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" glpi < file.sql
-- ==============================================================================

SET NAMES utf8mb4;
SET @now = NOW();
SET @entity = 0;
-- Tra cuu theo TEN thay vi hardcode id: id cua cac tai khoan mac dinh GLPI
-- (glpi/post-only/tech/normal/glpi-system) co the khac nhau giua cac ban cai,
-- hardcode sai id se gan nham nguoi xu ly hoac lam FK tro sai.
SET @tech_user  = (SELECT id FROM glpi_users WHERE name = 'tech' LIMIT 1);

-- ==============================================================================
--  1. NGUOI DUNG MAU THEO VAI TRO
--     Tao tai khoan demo: giang vien, sinh vien, ky thuat vien
-- ==============================================================================

-- 1.1. Ky thuat vien (Technician) - nguoi xu ly su co
INSERT INTO glpi_users
    (name, password, realname, firstname, authtype, is_active,
     language, palette, date_creation, date_mod, comment)
SELECT 'ktv.an', '', 'Nguyễn Văn', 'An', 1, 1,
       'vi_VN', 'da_lat', @now, @now, 'Kỹ thuật viên - Trung tâm CNTT'
WHERE NOT EXISTS (SELECT 1 FROM glpi_users WHERE name = 'ktv.an');

INSERT INTO glpi_users
    (name, password, realname, firstname, authtype, is_active,
     language, palette, date_creation, date_mod, comment)
SELECT 'ktv.binh', '', 'Trần Thanh', 'Bình', 1, 1,
       'vi_VN', 'da_lat', @now, @now, 'Kỹ thuật viên - Trung tâm CNTT'
WHERE NOT EXISTS (SELECT 1 FROM glpi_users WHERE name = 'ktv.binh');

-- 1.2. Giang vien (Requester) - nguoi bao su co
INSERT INTO glpi_users
    (name, password, realname, firstname, authtype, is_active,
     language, palette, date_creation, date_mod, comment)
SELECT 'gv.cuong', '', 'Lê Mạnh', 'Cường', 1, 1,
       'vi_VN', 'da_lat', @now, @now, 'Giảng viên - Khoa Toán - Tin học'
WHERE NOT EXISTS (SELECT 1 FROM glpi_users WHERE name = 'gv.cuong');

INSERT INTO glpi_users
    (name, password, realname, firstname, authtype, is_active,
     language, palette, date_creation, date_mod, comment)
SELECT 'gv.dung', '', 'Phạm Thị', 'Dung', 1, 1,
       'vi_VN', 'da_lat', @now, @now, 'Giảng viên - Khoa Vật lý'
WHERE NOT EXISTS (SELECT 1 FROM glpi_users WHERE name = 'gv.dung');

-- 1.3. Sinh vien (Requester) - nguoi bao su co tu phong may
INSERT INTO glpi_users
    (name, password, realname, firstname, authtype, is_active,
     language, palette, date_creation, date_mod, comment)
SELECT 'sv.hoa', '', 'Đỗ Thị', 'Hoa', 1, 1,
       'vi_VN', 'da_lat', @now, @now, 'Sinh viên - Khoa Toán - Tin học'
WHERE NOT EXISTS (SELECT 1 FROM glpi_users WHERE name = 'sv.hoa');

INSERT INTO glpi_users
    (name, password, realname, firstname, authtype, is_active,
     language, palette, date_creation, date_mod, comment)
SELECT 'sv.khanh', '', 'Vũ Minh', 'Khánh', 1, 1,
       'vi_VN', 'da_lat', @now, @now, 'Sinh viên - Khoa Công nghệ thông tin'
WHERE NOT EXISTS (SELECT 1 FROM glpi_users WHERE name = 'sv.khanh');

-- 1.4. SUA DON: dam bao MOI tai khoan demo deu dung ngon ngu tieng Viet
--      + bang mau Da Lat + dang hoat dong.
--
--      VI SAO PHAI LIET KE CA 'tech','normal','post-only','glpi'?
--        Bon tai khoan nay do chinh trinh cai dat GLPI tao ra, va GLPI gan
--        san language = 'en_GB' cho chung. Gia tri luu theo tung tai khoan
--        LUON thang ngon ngu mac dinh cua he thong, nen du glpi_configs.language
--        da la vi_VN thi dang nhap bang 'tech' van hien giao dien TIENG ANH.
--        Day chinh la loi tung lam toan bo giao dien sau dang nhap hien chu
--        "Assets / Assistance / Management" thay vi tieng Viet.
--      'ktv.an' co language = NULL (trinh cai dat khong dien) -> NULL nghia la
--      "dung mac dinh he thong", ve ly thuyet la duoc, nhung ghi ro vi_VN cho
--      nhat quan va de doi chieu.
UPDATE glpi_users
SET language = 'vi_VN',
    palette  = 'da_lat',
    is_active = 1,
    date_mod = @now
WHERE name IN ('glpi','tech','normal','post-only',
               'ktv.an','ktv.binh','gv.cuong','gv.dung','sv.hoa','sv.khanh');

-- 1.5. Dat ngon ngu + bang mau mac dinh cho TOAN HE THONG
--      (de tai khoan tao moi sau nay tu dong dung Da Lat, khong bi "auror")
UPDATE glpi_configs SET value = 'vi_VN'  WHERE name = 'language' AND context = 'core';
UPDATE glpi_configs SET value = 'da_lat' WHERE name = 'palette'  AND context = 'core';


-- ==============================================================================
--  2. GAN NGUOI DUNG VAO NHOM THEO CO CAU TO CHUC
-- ==============================================================================

-- Ky thuat vien thuoc "Trung tâm và Viện"
INSERT INTO glpi_groups_users (users_id, groups_id)
SELECT u.id, 3
FROM glpi_users u
WHERE u.name IN ('ktv.an', 'ktv.binh')
  AND NOT EXISTS (SELECT 1 FROM glpi_groups_users gu
                  WHERE gu.users_id = u.id AND gu.groups_id = 3);

-- Giang vien / sinh vien thuoc "Khoa"
INSERT INTO glpi_groups_users (users_id, groups_id)
SELECT u.id, 1
FROM glpi_users u
WHERE u.name IN ('gv.cuong', 'gv.dung', 'sv.hoa', 'sv.khanh')
  AND NOT EXISTS (SELECT 1 FROM glpi_groups_users gu
                  WHERE gu.users_id = u.id AND gu.groups_id = 1);

-- Gan cac tai khoan mau vao entity Root, DUNG HO SO THEO VAI TRO.
--
-- VI SAO KHONG HARDCODE profiles_id = 1?
--   Ban dau cho TAT CA tai khoan vao ho so 1 ("Nguoi dung"). Ho so nay thuoc
--   giao dien helpdesk (tu phuc vu) chu KHONG phai giao dien trung tam, nen
--   'ktv.an' / 'ktv.binh' mang danh "ky thuat vien" ma khong mo duoc bang
--   dieu khien, khong thay menu "Tai san / Ho tro / Quan ly". README lai ghi
--   hai tai khoan do la "Ky thuat vien" -> tai lieu sai so voi he thong.
--   Tra cuu ho so theo TEN de khong phu thuoc vao thu tu id (id co the khac
--   nhau giua cac ban GLPI / ngon ngu cai dat).
--
--   'Technician'   (sau Viet hoa: 'Kỹ thuật viên') -> giao dien trung tam.
--   'Self-Service' (sau Viet hoa: 'Người dùng')    -> giao dien helpdesk.
--
--   LOI THAT da sua (0.4.0): ban cu CHI khop TEN TIENG VIET. Tren may sach,
--   GLPI tao ho so bang ten TIENG ANH ('Technician'/'Self-Service'), con
--   scripts/viet-hoa-du-lieu.sh — noi doi ten sang tieng Viet — lai khong nam
--   trong luong cai dat (nay da nam, nhung chay SAU buoc nay). Ket qua: JOIN
--   khop 0 dong, 6 tai khoan demo khong co ho so quyen nao => dang nhap bao
--   "Ban khong co quyen de ket noi" (HTTP 400). Kich ban demo lai dang nhap
--   'sv.hoa' -> se that bai ngay tren buc.
--   Nay khop CA HAI ten (truoc VA sau khi Viet hoa) de dung thu tu nao cung dung.
INSERT INTO glpi_profiles_users (users_id, profiles_id, entities_id, is_recursive, is_dynamic)
SELECT u.id, p.id, 0, 1, 0
FROM glpi_users u
JOIN glpi_profiles p
  ON p.name = CASE WHEN u.name IN ('ktv.an', 'ktv.binh')
                   THEN 'Technician' ELSE 'Self-Service' END
     OR p.name = CASE WHEN u.name IN ('ktv.an', 'ktv.binh')
                      THEN 'Kỹ thuật viên' ELSE 'Người dùng' END
WHERE u.name IN ('ktv.an', 'ktv.binh', 'gv.cuong', 'gv.dung', 'sv.hoa', 'sv.khanh')
  AND NOT EXISTS (SELECT 1 FROM glpi_profiles_users pu
                  WHERE pu.users_id = u.id AND pu.profiles_id = p.id);


-- ==============================================================================
--  3. THIET BI MAU (glpi_computers)
--     Ma tai san theo quy uoc: TDL-PC-<PHONG>-<SO>
--     Khoi tao 477 may tinh phong may thuc te cua Trung tam CNTT (DLU)
--     + 3 laptop cho muon + 2 may chu = 482 may tinh tong cong.
--     Dung ID tham chieu that tu du lieu nen.
-- ==============================================================================

-- 3.0. Don dep thiet bi mau gia lap cu (tranh lan voi du lieu 10 phong may that)
DELETE FROM glpi_items_tickets
 WHERE (itemtype = 'Computer' AND items_id IN (SELECT id FROM glpi_computers WHERE name LIKE 'TDL-PC-A101-%' OR name LIKE 'TDL-PC-A102-%' OR name LIKE 'TDL-PC-A201-%' OR name LIKE 'TDL-PC-B101-%'))
    OR (itemtype = 'Monitor' AND items_id IN (SELECT id FROM glpi_monitors WHERE name LIKE 'TDL-MON-A101-%' OR name LIKE 'TDL-MON-A102-%' OR name LIKE 'TDL-MON-A201-%' OR name LIKE 'TDL-MON-B101-%'))
    OR (itemtype = 'Printer' AND items_id IN (SELECT id FROM glpi_printers WHERE name IN ('TDL-PRN-A102-001', 'TDL-PRN-A201-001')))
    OR (itemtype = 'NetworkEquipment' AND items_id IN (SELECT id FROM glpi_networkequipments WHERE name IN ('TDL-SW-A101-001', 'TDL-SW-A201-001', 'TDL-AP-A101-001')));

DELETE FROM glpi_computers
 WHERE name LIKE 'TDL-PC-A101-%' OR name LIKE 'TDL-PC-A102-%' OR name LIKE 'TDL-PC-A201-%' OR name LIKE 'TDL-PC-B101-%';

DELETE FROM glpi_monitors
 WHERE name LIKE 'TDL-MON-A101-%' OR name LIKE 'TDL-MON-A102-%' OR name LIKE 'TDL-MON-A201-%' OR name LIKE 'TDL-MON-B101-%';

DELETE FROM glpi_printers
 WHERE name IN ('TDL-PRN-A102-001', 'TDL-PRN-A201-001');

DELETE FROM glpi_networkequipments
 WHERE name IN ('TDL-SW-A101-001', 'TDL-SW-A201-001', 'TDL-AP-A101-001');

-- 3.1. May tinh thuc hanh sinh vien trong 10 phong may Trung tam CNTT (471 may)
--      Sinh tu tap hop phong may va bang day so 1..60 bang ky thuat CROSS JOIN.
INSERT INTO glpi_computers
    (name, serial, otherserial, entities_id, locations_id, computertypes_id,
     computermodels_id, manufacturers_id, states_id, users_id,
     is_template, is_deleted, date_creation, date_mod, comment)
SELECT
    CONCAT('TDL-PC-', r.code, '-', LPAD(n.seq, 3, '0')) AS name,
    CONCAT('SN-', r.code, '-', LPAD(n.seq, 4, '0')) AS serial,
    CONCAT('TDL-PC-', r.code, '-', LPAD(n.seq, 3, '0')) AS otherserial,
    @entity,
    l.id,
    (SELECT id FROM glpi_computertypes WHERE name = 'Máy tính để bàn' LIMIT 1),
    (SELECT id FROM glpi_computermodels WHERE name = r.cmodel LIMIT 1),
    (SELECT id FROM glpi_manufacturers WHERE name = r.brand LIMIT 1),
    (SELECT id FROM glpi_states WHERE name = (
        CASE
            WHEN r.code = 'A85' AND n.seq = 3 THEN 'Đang sửa chữa'
            WHEN r.code = 'TV2' AND n.seq = 10 THEN 'Hỏng'
            WHEN r.code = 'A24L' AND n.seq = 5 THEN 'Đang bảo trì định kỳ'
            ELSE 'Đang sử dụng'
        END
    ) LIMIT 1),
    0, 0, 0, @now, @now,
    CONCAT('Máy tính thực hành sinh viên - ', r.loc, ' - Máy số ', n.seq) AS comment
FROM (
    SELECT 'Phòng máy A24.1' AS loc, 'A241' AS code, 45 AS qty, 'OptiPlex 3000 Small' AS cmodel, 'Dell' AS brand UNION ALL
    SELECT 'Phòng máy A24 lầu', 'A24L', 45, 'OptiPlex 3000 Small', 'Dell' UNION ALL
    SELECT 'Phòng máy A8.3', 'A83', 48, 'PC Lắp ráp Core i3', 'Intel' UNION ALL
    SELECT 'Phòng máy A8.4', 'A84', 48, 'PC Lắp ráp Core i3', 'Intel' UNION ALL
    SELECT 'Phòng máy A8.5', 'A85', 49, 'PC Lắp ráp Core i5', 'Intel' UNION ALL
    SELECT 'Phòng máy A8.6', 'A86', 50, 'PC Lắp ráp Core i5', 'Intel' UNION ALL
    SELECT 'Phòng máy TV1', 'TV1', 46, 'PC Lắp ráp Pentium', 'Intel' UNION ALL
    SELECT 'Phòng máy TV2', 'TV2', 45, 'PC Lắp ráp Pentium', 'Intel' UNION ALL
    SELECT 'Phòng máy TV3', 'TV3', 45, 'PC Lắp ráp Pentium', 'Intel' UNION ALL
    SELECT 'Phòng máy TV4', 'TV4', 50, 'PC Lắp ráp Pentium', 'Intel'
) r
CROSS JOIN (
    SELECT a.n + b.n * 10 AS seq
    FROM (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
          UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10) a
    CROSS JOIN (SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) b
    WHERE a.n + b.n * 10 BETWEEN 1 AND 60
) n
JOIN glpi_locations l ON l.name = r.loc AND l.level = 3
WHERE n.seq <= r.qty
  AND NOT EXISTS (
      SELECT 1 FROM glpi_computers c
      WHERE c.otherserial = CONCAT('TDL-PC-', r.code, '-', LPAD(n.seq, 3, '0'))
  );

-- 3.1b. May tinh giang vien trong cac phong may A24.1, A24 lau, A8.3, A8.4, A8.5, A8.6 (6 may)
INSERT INTO glpi_computers
    (name, serial, otherserial, entities_id, locations_id, computertypes_id,
     computermodels_id, manufacturers_id, states_id, users_id,
     is_template, is_deleted, date_creation, date_mod, comment)
SELECT s.name, s.serial, s.otherserial, @entity,
       l.id,
       (SELECT id FROM glpi_computertypes WHERE name = 'Máy tính để bàn' LIMIT 1),
       (SELECT id FROM glpi_computermodels WHERE name = s.cmodel LIMIT 1),
       (SELECT id FROM glpi_manufacturers  WHERE name = s.brand LIMIT 1),
       (SELECT id FROM glpi_states         WHERE name = 'Đang sử dụng' LIMIT 1),
       0, 0, 0, @now, @now, s.comment
FROM (
    SELECT 'TDL-PC-A241-GV' AS name, 'SN-A241-GV' AS serial, 'TDL-PC-A241-GV' AS otherserial,
           'Phòng máy A24.1' AS loc, 'OptiPlex 3000 Small' AS cmodel, 'Dell' AS brand,
           'Máy tính giảng viên phòng máy A24.1' AS comment UNION ALL
    SELECT 'TDL-PC-A24L-GV', 'SN-A24L-GV', 'TDL-PC-A24L-GV',
           'Phòng máy A24 lầu', 'OptiPlex 3000 Small', 'Dell',
           'Máy tính giảng viên phòng máy A24 lầu' UNION ALL
    SELECT 'TDL-PC-A83-GV', 'SN-A83-GV', 'TDL-PC-A83-GV',
           'Phòng máy A8.3', 'PC Lắp ráp Core i3', 'Intel',
           'Máy tính giảng viên phòng máy A8.3' UNION ALL
    SELECT 'TDL-PC-A84-GV', 'SN-A84-GV', 'TDL-PC-A84-GV',
           'Phòng máy A8.4', 'PC Lắp ráp Core i3', 'Intel',
           'Máy tính giảng viên phòng máy A8.4' UNION ALL
    SELECT 'TDL-PC-A85-GV', 'SN-A85-GV', 'TDL-PC-A85-GV',
           'Phòng máy A8.5', 'PC Lắp ráp Core i5', 'Intel',
           'Máy tính giảng viên phòng máy A8.5' UNION ALL
    SELECT 'TDL-PC-A86-GV', 'SN-A86-GV', 'TDL-PC-A86-GV',
           'Phòng máy A8.6', 'PC Lắp ráp Core i5', 'Intel',
           'Máy tính giảng viên phòng máy A8.6'
) s
JOIN glpi_locations l ON l.name = s.loc AND l.level = 3
WHERE NOT EXISTS (SELECT 1 FROM glpi_computers c WHERE c.otherserial = s.otherserial);

-- 3.2. May tinh xach tay (thiet bi ca nhan / cho muon)
INSERT INTO glpi_computers
    (name, serial, otherserial, entities_id, locations_id, computertypes_id,
     computermodels_id, manufacturers_id, states_id, is_template, is_deleted,
     date_creation, date_mod, comment)
SELECT s.name, s.serial, s.otherserial, @entity, l.id,
       (SELECT id FROM glpi_computertypes WHERE name = 'Máy tính xách tay' LIMIT 1),
       (SELECT id FROM glpi_computermodels  WHERE name = s.cmodel LIMIT 1),
       (SELECT id FROM glpi_manufacturers   WHERE name = s.brand  LIMIT 1),
       (SELECT id FROM glpi_states          WHERE name = 'Đang sử dụng' LIMIT 1),
       0, 0, @now, @now, s.comment
FROM (
    SELECT 'TDL-LAP-001' AS name, 'SN-LAP-0001' AS serial, 'TDL-LAP-001' AS otherserial,
           'Văn phòng Khoa Toán - Tin học' AS loc, 'Latitude 5420' AS cmodel, 'Dell' AS brand,
           'Laptop giảng viên Khoa Toán - Tin học' AS comment UNION ALL
    SELECT 'TDL-LAP-002', 'SN-LAP-0002', 'TDL-LAP-002',
           'Văn phòng Khoa Toán - Tin học', 'Latitude 5420', 'Dell',
           'Laptop giảng viên Khoa Toán - Tin học' UNION ALL
    SELECT 'TDL-LAP-003', 'SN-LAP-0003', 'TDL-LAP-003',
           'Phòng máy A24.1', 'ThinkPad E14', 'Lenovo',
           'Laptop mượn sinh viên thực hành'
) s
JOIN glpi_locations l ON l.name = s.loc AND l.level = 3
WHERE NOT EXISTS (SELECT 1 FROM glpi_computers c WHERE c.otherserial = s.otherserial);

-- 3.3. May chu
INSERT INTO glpi_computers
    (name, serial, otherserial, entities_id, locations_id, computertypes_id,
     computermodels_id, manufacturers_id, states_id, is_template, is_deleted,
     date_creation, date_mod, comment)
SELECT 'TDL-SRV-001', 'SN-SRV-0001', 'TDL-SRV-001', @entity, l.id,
       (SELECT id FROM glpi_computertypes WHERE name = 'Máy chủ' LIMIT 1),
       (SELECT id FROM glpi_computermodels WHERE name = 'PowerEdge R740' LIMIT 1),
       (SELECT id FROM glpi_manufacturers  WHERE name = 'Dell' LIMIT 1),
       (SELECT id FROM glpi_states         WHERE name = 'Đang hoạt động tốt' LIMIT 1),
       0, 0, @now, @now, 'Máy chủ chính phòng máy A24.1'
FROM glpi_locations l
WHERE l.name = 'Phòng máy A24.1' AND l.level = 3
  AND NOT EXISTS (SELECT 1 FROM glpi_computers c WHERE c.otherserial = 'TDL-SRV-001');

-- 3.4. May chu du phong (may chu thu 2)
INSERT INTO glpi_computers
    (name, serial, otherserial, entities_id, locations_id, computertypes_id,
     computermodels_id, manufacturers_id, states_id, is_template, is_deleted,
     date_creation, date_mod, comment)
SELECT 'TDL-SRV-002', 'SN-SRV-0002', 'TDL-SRV-002', @entity, l.id,
       (SELECT id FROM glpi_computertypes WHERE name = 'Máy chủ' LIMIT 1),
       (SELECT id FROM glpi_computermodels WHERE name = 'ProLiant DL380' LIMIT 1),
       (SELECT id FROM glpi_manufacturers  WHERE name = 'HP' LIMIT 1),
       (SELECT id FROM glpi_states         WHERE name = 'Đang bảo trì định kỳ' LIMIT 1),
       0, 0, @now, @now, 'Máy chủ dự phòng - đang bảo trì'
FROM glpi_locations l
WHERE l.name = 'Phòng máy A24.1' AND l.level = 3
  AND NOT EXISTS (SELECT 1 FROM glpi_computers c WHERE c.otherserial = 'TDL-SRV-002');


-- ==============================================================================
--  4. THIET BI NGOAI VI: MAN HINH + MAY IN + THIET BI MANG + AM THANH
-- ==============================================================================

-- 4.1. Man hinh may tinh sinh vien trong 10 phong may (471 man hinh)
INSERT INTO glpi_monitors
    (name, serial, otherserial, entities_id, locations_id, monitortypes_id,
     monitormodels_id, manufacturers_id, states_id, is_template, is_deleted,
     date_creation, date_mod, comment)
SELECT
    CONCAT('TDL-MON-', r.code, '-', LPAD(n.seq, 3, '0')) AS name,
    CONCAT('MN-', r.code, '-', LPAD(n.seq, 4, '0')) AS serial,
    CONCAT('TDL-MON-', r.code, '-', LPAD(n.seq, 3, '0')) AS otherserial,
    @entity,
    l.id,
    (SELECT id FROM glpi_monitortypes WHERE name = r.mtype LIMIT 1),
    (SELECT id FROM glpi_monitormodels WHERE name = r.mmodel LIMIT 1),
    (SELECT id FROM glpi_manufacturers WHERE name = r.mbrand LIMIT 1),
    (SELECT id FROM glpi_states WHERE name = 'Đang sử dụng' LIMIT 1),
    0, 0, @now, @now,
    CONCAT('Màn hình đi kèm máy tính sinh viên ', r.loc, ' - Máy số ', n.seq) AS comment
FROM (
    SELECT 'Phòng máy A24.1' AS loc, 'A241' AS code, 45 AS qty, 'Màn hình 22 inch' AS mtype, 'E2222H' AS mmodel, 'Dell' AS mbrand UNION ALL
    SELECT 'Phòng máy A24 lầu', 'A24L', 45, 'Màn hình 22 inch', 'E2222H', 'Dell' UNION ALL
    SELECT 'Phòng máy A8.3', 'A83', 48, 'Màn hình 22 inch', 'E2222H', 'Dell' UNION ALL
    SELECT 'Phòng máy A8.4', 'A84', 48, 'Màn hình 22 inch', 'E2222H', 'Dell' UNION ALL
    SELECT 'Phòng máy A8.5', 'A85', 49, 'Màn hình 22 inch', 'E2222H', 'Dell' UNION ALL
    SELECT 'Phòng máy A8.6', 'A86', 50, 'Màn hình 22 inch', 'E2222H', 'Dell' UNION ALL
    SELECT 'Phòng máy TV1', 'TV1', 46, 'Màn hình 22 inch', 'E2222H', 'Dell' UNION ALL
    SELECT 'Phòng máy TV2', 'TV2', 45, 'Màn hình 24 inch', '24MK430H', 'LG' UNION ALL
    SELECT 'Phòng máy TV3', 'TV3', 45, 'Màn hình 24 inch', '24MK430H', 'LG' UNION ALL
    SELECT 'Phòng máy TV4', 'TV4', 50, 'Màn hình 22 inch', 'E2222H', 'Dell'
) r
CROSS JOIN (
    SELECT a.n + b.n * 10 AS seq
    FROM (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
          UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10) a
    CROSS JOIN (SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) b
    WHERE a.n + b.n * 10 BETWEEN 1 AND 60
) n
JOIN glpi_locations l ON l.name = r.loc AND l.level = 3
WHERE n.seq <= r.qty
  AND NOT EXISTS (
      SELECT 1 FROM glpi_monitors m
      WHERE m.otherserial = CONCAT('TDL-MON-', r.code, '-', LPAD(n.seq, 3, '0'))
  );

-- 4.1b. Man hinh may giang vien (6 man hinh)
INSERT INTO glpi_monitors
    (name, serial, otherserial, entities_id, locations_id, monitortypes_id,
     monitormodels_id, manufacturers_id, states_id, is_template, is_deleted,
     date_creation, date_mod, comment)
SELECT s.name, s.serial, s.otherserial, @entity, l.id,
       (SELECT id FROM glpi_monitortypes WHERE name = s.mtype LIMIT 1),
       (SELECT id FROM glpi_monitormodels WHERE name = s.mmodel LIMIT 1),
       (SELECT id FROM glpi_manufacturers  WHERE name = s.brand LIMIT 1),
       (SELECT id FROM glpi_states WHERE name = 'Đang sử dụng' LIMIT 1),
       0, 0, @now, @now, s.comment
FROM (
    SELECT 'TDL-MON-A241-GV' AS name, 'MN-A241-GV' AS serial, 'TDL-MON-A241-GV' AS otherserial,
           'Phòng máy A24.1' AS loc, 'Màn hình 22 inch' AS mtype, 'E2222H' AS mmodel, 'Dell' AS brand,
           'Màn hình máy giảng viên A24.1' AS comment UNION ALL
    SELECT 'TDL-MON-A24L-GV', 'MN-A24L-GV', 'TDL-MON-A24L-GV',
           'Phòng máy A24 lầu', 'Màn hình 22 inch', 'E2222H', 'Dell',
           'Màn hình máy giảng viên A24 lầu' UNION ALL
    SELECT 'TDL-MON-A83-GV', 'MN-A83-GV', 'TDL-MON-A83-GV',
           'Phòng máy A8.3', 'Màn hình 22 inch', 'E2222H', 'Dell',
           'Màn hình máy giảng viên A8.3' UNION ALL
    SELECT 'TDL-MON-A84-GV', 'MN-A84-GV', 'TDL-MON-A84-GV',
           'Phòng máy A8.4', 'Màn hình 22 inch', 'E2222H', 'Dell',
           'Màn hình máy giảng viên A8.4' UNION ALL
    SELECT 'TDL-MON-A85-GV', 'MN-A85-GV', 'TDL-MON-A85-GV',
           'Phòng máy A8.5', 'Màn hình 22 inch', 'E2222H', 'Dell',
           'Màn hình máy giảng viên A8.5' UNION ALL
    SELECT 'TDL-MON-A86-GV', 'MN-A86-GV', 'TDL-MON-A86-GV',
           'Phòng máy A8.6', 'Màn hình 22 inch', 'E2222H', 'Dell',
           'Màn hình máy giảng viên A8.6'
) s
JOIN glpi_locations l ON l.name = s.loc AND l.level = 3
WHERE NOT EXISTS (SELECT 1 FROM glpi_monitors m WHERE m.otherserial = s.otherserial);

-- 4.1c. Smart Tivi giang day trong 10 phong may (10 chiec)
INSERT INTO glpi_monitors
    (name, serial, otherserial, entities_id, locations_id, monitortypes_id,
     monitormodels_id, manufacturers_id, states_id, is_template, is_deleted,
     date_creation, date_mod, comment)
SELECT s.name, s.serial, s.otherserial, @entity, l.id,
       (SELECT id FROM glpi_monitortypes WHERE name = s.mtype LIMIT 1),
       (SELECT id FROM glpi_monitormodels WHERE name = s.mmodel LIMIT 1),
       (SELECT id FROM glpi_manufacturers  WHERE name = s.brand LIMIT 1),
       (SELECT id FROM glpi_states WHERE name = 'Đang sử dụng' LIMIT 1),
       0, 0, @now, @now, s.comment
FROM (
    SELECT 'TDL-TV-A241-001' AS name, 'TV-A241-0001' AS serial, 'TDL-TV-A241-001' AS otherserial,
           'Phòng máy A24.1' AS loc, 'Smart Tivi' AS mtype, 'Sony Bravia 85"' AS mmodel, 'Sony' AS brand,
           'Smart Tivi 85 inch trình chiếu bài giảng A24.1' AS comment UNION ALL
    SELECT 'TDL-TV-A24L-001', 'TV-A24L-0001', 'TDL-TV-A24L-001',
           'Phòng máy A24 lầu', 'Smart Tivi', 'Inno Smart TV 85"', 'Inno',
           'Smart Tivi Inno 85 inch phòng A24 lầu' UNION ALL
    SELECT 'TDL-TV-A83-001', 'TV-A83-0001', 'TDL-TV-A83-001',
           'Phòng máy A8.3', 'Smart Tivi', 'Smart TV 80"', 'Sony',
           'Smart Tivi 80 inch phòng A8.3' UNION ALL
    SELECT 'TDL-TV-A84-001', 'TV-A84-0001', 'TDL-TV-A84-001',
           'Phòng máy A8.4', 'Smart Tivi', 'Smart TV 80"', 'Sony',
           'Smart Tivi 80 inch phòng A8.4' UNION ALL
    SELECT 'TDL-TV-A85-001', 'TV-A85-0001', 'TDL-TV-A85-001',
           'Phòng máy A8.5', 'Smart Tivi', 'Inno Smart TV 85"', 'Inno',
           'Smart Tivi Inno 85 inch phòng A8.5' UNION ALL
    SELECT 'TDL-TV-A86-001', 'TV-A86-0001', 'TDL-TV-A86-001',
           'Phòng máy A8.6', 'Smart Tivi', 'Inno Smart TV 85"', 'Inno',
           'Smart Tivi Inno 85 inch phòng A8.6' UNION ALL
    SELECT 'TDL-TV-TV1-001', 'TV-TV1-0001', 'TDL-TV-TV1-001',
           'Phòng máy TV1', 'Smart Tivi', 'Smart TV 80"', 'Sony',
           'Smart Tivi 80 inch phòng TV1' UNION ALL
    SELECT 'TDL-TV-TV2-001', 'TV-TV2-0001', 'TDL-TV-TV2-001',
           'Phòng máy TV2', 'Smart Tivi', 'Smart TV 80"', 'Sony',
           'Smart Tivi 80 inch phòng TV2' UNION ALL
    SELECT 'TDL-TV-TV3-001', 'TV-TV3-0001', 'TDL-TV-TV3-001',
           'Phòng máy TV3', 'Smart Tivi', 'Smart TV 80"', 'Sony',
           'Smart Tivi 80 inch phòng TV3' UNION ALL
    SELECT 'TDL-TV-TV4-001', 'TV-TV4-0001', 'TDL-TV-TV4-001',
           'Phòng máy TV4', 'Smart Tivi', 'Smart TV 80"', 'Sony',
           'Smart Tivi 80 inch phòng TV4'
) s
JOIN glpi_locations l ON l.name = s.loc AND l.level = 3
WHERE NOT EXISTS (SELECT 1 FROM glpi_monitors m WHERE m.otherserial = s.otherserial);

-- 4.2. May in
INSERT INTO glpi_printers
    (name, serial, otherserial, entities_id, locations_id, printertypes_id,
     printermodels_id, manufacturers_id, states_id, is_template, is_deleted,
     date_creation, date_mod, comment)
SELECT s.name, s.serial, s.otherserial, @entity, l.id,
       (SELECT id FROM glpi_printertypes WHERE name = s.ptype LIMIT 1),
       (SELECT id FROM glpi_printermodels WHERE name = s.pmodel LIMIT 1),
       (SELECT id FROM glpi_manufacturers  WHERE name = s.brand LIMIT 1),
       (SELECT id FROM glpi_states WHERE name = s.state LIMIT 1),
       0, 0, @now, @now, s.comment
FROM (
    SELECT 'TDL-PRN-A241-001' AS name, 'PR-A241-0001' AS serial, 'TDL-PRN-A241-001' AS otherserial,
           'Phòng máy A24.1' AS loc, 'Máy in laser đen trắng' AS ptype, 'imageCLASS LBP2900' AS pmodel,
           'Canon' AS brand, 'Đang sử dụng' AS state, 'Máy in phòng máy A24.1' AS comment UNION ALL
    SELECT 'TDL-PRN-A85-001', 'PR-A85-0001', 'TDL-PRN-A85-001',
           'Phòng máy A8.5', 'Máy in laser đen trắng', 'imageCLASS LBP2900', 'Canon',
           'Đang sử dụng', 'Máy in phòng máy A8.5' UNION ALL
    SELECT 'TDL-PRN-VPK-001', 'PR-VPK-0001', 'TDL-PRN-VPK-001',
           'Văn phòng Khoa Toán - Tin học', 'Máy in laser đen trắng', 'imageCLASS LBP2900', 'Canon',
           'Chờ linh kiện', 'Hết mực in, chờ thay mực'
) s
JOIN glpi_locations l ON l.name = s.loc AND l.level = 3
WHERE NOT EXISTS (SELECT 1 FROM glpi_printers p WHERE p.otherserial = s.otherserial);

-- 4.3. Thiet bi mang & Tu Rack phong may Trung tam CNTT
INSERT INTO glpi_networkequipments
    (name, serial, otherserial, entities_id, locations_id,
     networkequipmenttypes_id, networkequipmentmodels_id, manufacturers_id,
     states_id, is_template, is_deleted, date_creation, date_mod, comment)
SELECT s.name, s.serial, s.otherserial, @entity, l.id,
       (SELECT id FROM glpi_networkequipmenttypes WHERE name = s.ntype LIMIT 1),
       (SELECT id FROM glpi_networkequipmentmodels WHERE name = s.nmodel LIMIT 1),
       (SELECT id FROM glpi_manufacturers  WHERE name = s.brand LIMIT 1),
       (SELECT id FROM glpi_states WHERE name = s.state LIMIT 1),
       0, 0, @now, @now, s.comment
FROM (
    -- 4 Switch phong may thuc te
    SELECT 'TDL-SW-A241-001' AS name, 'SW-A241-0001' AS serial, 'TDL-SW-A241-001' AS otherserial,
           'Phòng máy A24.1' AS loc, 'Bộ chuyển mạch (Switch)' AS ntype, 'Catalyst 2960-48TT-L' AS nmodel,
           'Cisco' AS brand, 'Đang hoạt động tốt' AS state, 'Switch 48 cổng phòng máy A24.1' AS comment UNION ALL
    SELECT 'TDL-SW-A24L-001', 'SW-A24L-0001', 'TDL-SW-A24L-001',
           'Phòng máy A24 lầu', 'Bộ chuyển mạch (Switch)', 'Catalyst 2960-48TT-L',
           'Cisco', 'Đang hoạt động tốt', 'Switch 48 cổng phòng máy A24 lầu' UNION ALL
    SELECT 'TDL-SW-A85-001', 'SW-A85-0001', 'TDL-SW-A85-001',
           'Phòng máy A8.5', 'Bộ chuyển mạch (Switch)', 'Catalyst 2960-48TT-L',
           'Cisco', 'Đang hoạt động tốt', 'Switch 48 cổng phòng máy A8.5' UNION ALL
    SELECT 'TDL-SW-A86-001', 'SW-A86-0001', 'TDL-SW-A86-001',
           'Phòng máy A8.6', 'Bộ chuyển mạch (Switch)', 'Catalyst 2960-48TT-L',
           'Cisco', 'Đang hoạt động tốt', 'Switch 48 cổng phòng máy A8.6' UNION ALL

    -- 4 Tu Rack phong may thuc te
    SELECT 'TDL-RK-A241-001', 'RK-A241-0001', 'TDL-RK-A241-001',
           'Phòng máy A24.1', 'Tủ mạng (Rack)', 'Tủ mạng Rack 19U',
           'Cisco', 'Đang hoạt động tốt', 'Tủ mạng Rack 19U phòng máy A24.1' UNION ALL
    SELECT 'TDL-RK-A24L-001', 'RK-A24L-0001', 'TDL-RK-A24L-001',
           'Phòng máy A24 lầu', 'Tủ mạng (Rack)', 'Tủ mạng Rack 19U',
           'Cisco', 'Đang hoạt động tốt', 'Tủ mạng Rack 19U phòng máy A24 lầu' UNION ALL
    SELECT 'TDL-RK-A83-001', 'RK-A83-0001', 'TDL-RK-A83-001',
           'Phòng máy A8.3', 'Tủ mạng (Rack)', 'Tủ mạng Rack 19U',
           'Cisco', 'Đang hoạt động tốt', 'Tủ mạng Rack 19U phòng máy A8.3' UNION ALL
    SELECT 'TDL-RK-A85-001', 'RK-A85-0001', 'TDL-RK-A85-001',
           'Phòng máy A8.5', 'Tủ mạng (Rack)', 'Tủ mạng Rack 19U',
           'Cisco', 'Đang hoạt động tốt', 'Tủ mạng Rack 19U phòng máy A8.5' UNION ALL

    -- 9 Thiet bi mang cac toa nha & giang duong
    SELECT 'TDL-SW-B201-001', 'SW-B201-0001', 'TDL-SW-B201-001',
           'Phòng máy B201', 'Bộ chuyển mạch (Switch)', 'TL-SG1024D',
           'TP-Link', 'Đang sửa chữa', 'Switch phòng máy B201, đang sửa cổng quang' UNION ALL
    SELECT 'TDL-SW-C101-001', 'SW-C101-0001', 'TDL-SW-C101-001',
           'Phòng thí nghiệm C101', 'Bộ chuyển mạch (Switch)', 'Catalyst 2960-48TT-L',
           'Cisco', 'Đang bảo trì định kỳ', 'Switch 48 cổng phòng Lab C101' UNION ALL
    SELECT 'TDL-AP-TV1-001', 'AP-TV1-0001', 'TDL-AP-TV1-001',
           'Phòng máy TV1', 'Bộ phát WiFi (Access Point)', 'DIR-825',
           'D-Link', 'Đang hoạt động tốt', 'Bộ phát WiFi phòng máy TV1' UNION ALL
    SELECT 'TDL-AP-A241-001', 'AP-A241-0001', 'TDL-AP-A241-001',
           'Phòng máy A24.1', 'Bộ phát WiFi (Access Point)', 'DIR-825',
           'D-Link', 'Đang hoạt động tốt', 'Bộ phát WiFi phòng máy A24.1' UNION ALL
    SELECT 'TDL-AP-C101-001', 'AP-C101-0001', 'TDL-AP-C101-001',
           'Phòng thí nghiệm C101', 'Bộ phát WiFi (Access Point)', 'AR617VW',
           'Huawei', 'Trong kho', 'Bộ phát WiFi dự phòng' UNION ALL
    SELECT 'TDL-AP-GD-B1-001', 'AP-GDB1-0001', 'TDL-AP-GD-B1-001',
           'Giảng đường B1', 'Bộ phát WiFi (Access Point)', 'AR617VW',
           'Huawei', 'Đang hoạt động tốt', 'Bộ phát WiFi giảng đường B1' UNION ALL
    SELECT 'TDL-RT-VPK-001', 'RT-VPK-0001', 'TDL-RT-VPK-001',
           'Văn phòng Khoa Toán - Tin học', 'Bộ định tuyến (Router)', 'TL-ER605',
           'TP-Link', 'Đang hoạt động tốt', 'Router cân bằng tải văn phòng khoa' UNION ALL
    SELECT 'TDL-NAS-VPK-001', 'NAS-VPK-0001', 'TDL-NAS-VPK-001',
           'Văn phòng Khoa Toán - Tin học', 'Thiết bị NAS', 'DGS-1210-24',
           'Ubiquiti', 'Hỏng', 'Thiết bị NAS lưu trữ, hỏng ổ cứng' UNION ALL
    SELECT 'TDL-SW-A83-001', 'SW-A83-0001', 'TDL-SW-A83-001',
           'Phòng máy A8.3', 'Bộ chuyển mạch (Switch)', 'SG250-24',
           'Cisco', 'Đang hoạt động tốt', 'Switch 24 cổng phòng máy A8.3'
) s
JOIN glpi_locations l ON l.name = s.loc AND l.level = 3
WHERE NOT EXISTS (SELECT 1 FROM glpi_networkequipments n WHERE n.otherserial = s.otherserial);

-- 4.4. Thiet bi ngoai vi (am thanh Bosch trong phong may A8.5, A8.6, TV4)
INSERT INTO glpi_peripherals
    (name, serial, otherserial, entities_id, locations_id,
     peripheraltypes_id, peripheralmodels_id, manufacturers_id,
     states_id, is_template, is_deleted, date_creation, date_mod, comment)
SELECT s.name, s.serial, s.otherserial, @entity, l.id,
       (SELECT id FROM glpi_peripheraltypes WHERE name = s.ptype LIMIT 1),
       (SELECT id FROM glpi_peripheralmodels WHERE name = s.pmodel LIMIT 1),
       (SELECT id FROM glpi_manufacturers  WHERE name = s.brand LIMIT 1),
       (SELECT id FROM glpi_states WHERE name = 'Đang sử dụng' LIMIT 1),
       0, 0, @now, @now, s.comment
FROM (
    SELECT 'TDL-AUD-A85-001' AS name, 'AUD-A85-0001' AS serial, 'TDL-AUD-A85-001' AS otherserial,
           'Phòng máy A8.5' AS loc, 'Hệ thống âm thanh' AS ptype, 'PT-LB386' AS pmodel, 'Bosch' AS brand,
           'Hệ thống âm thanh giảng dạy Bosch phòng A8.5' AS comment UNION ALL
    SELECT 'TDL-AUD-A86-001', 'AUD-A86-0001', 'TDL-AUD-A86-001',
           'Phòng máy A8.6', 'Hệ thống âm thanh', 'PT-LB386', 'Bosch',
           'Hệ thống âm thanh giảng dạy Bosch phòng A8.6' UNION ALL
    SELECT 'TDL-AUD-TV4-001', 'AUD-TV4-0001', 'TDL-AUD-TV4-001',
           'Phòng máy TV4', 'Hệ thống âm thanh', 'PT-LB386', 'Bosch',
           'Hệ thống âm thanh giảng dạy Bosch phòng TV4'
) s
JOIN glpi_locations l ON l.name = s.loc AND l.level = 3
WHERE NOT EXISTS (SELECT 1 FROM glpi_peripherals p WHERE p.otherserial = s.otherserial);


-- ==============================================================================
--  5. PHAN MEM (glpi_softwares) + BAN QUYEN
-- ==============================================================================

INSERT INTO glpi_softwares
    (name, entities_id, is_helpdesk_visible, softwarecategories_id,
     is_template, is_deleted, is_recursive, is_update, is_valid,
     locations_id, users_id_tech, manufacturers_id, users_id,
     date_creation, date_mod, comment)
SELECT s.name, @entity, 1,
       COALESCE((SELECT id FROM glpi_softwarecategories WHERE name = s.cat LIMIT 1), 0),
       0, 0, 0, 0, 0, 0, 0, 0, 0, @now, @now, s.comment
FROM (
    SELECT 'Microsoft Windows 11 Pro' AS name, 'Hệ điều hành' AS cat,
           'He dieu hanh cho may tinh phong may' AS comment UNION ALL
    SELECT 'Microsoft Office 2021', 'Bộ văn phòng', 'Word, Excel, PowerPoint' UNION ALL
    SELECT 'Ubuntu Server 22.04 LTS', 'Hệ điều hành', 'He dieu hanh may chu' UNION ALL
    SELECT 'Visual Studio Code', 'Lập trình', 'IDE cho sinh vien CNTT' UNION ALL
    SELECT 'Dev-C++', 'Lập trình', 'IDE cho sinh vien nam 1-2' UNION ALL
    SELECT 'AutoCAD 2024', 'Đồ họa - Thiết kế', 'Do hoa ky thuat' UNION ALL
    SELECT 'MATLAB R2024a', 'Mô phỏng khoa học', 'Tinh toan khoa hoc' UNION ALL
    SELECT 'Kaspersky Endpoint Security', 'Mạng - Bảo mật', 'Phan mem diet virus' UNION ALL
    SELECT 'Google Chrome', 'Tiện ích', 'Trinh duyet pho bien' UNION ALL
    SELECT 'Mozilla Firefox', 'Tiện ích', 'Trinh duyet du phong'
) s
WHERE NOT EXISTS (SELECT 1 FROM glpi_softwares w WHERE w.name = s.name);


-- ==============================================================================
--  6. PHIEU YEU CAU SU CO (glpi_tickets)
--     Phan bo trang thai de dashboard co so lieu da dang.
-- ==============================================================================
-- (Da xoa 2 bien chet @st_new / @requester_prof: khai bao nhung khong noi nao
--  dung, lai con tra cuu theo ten tieng Anh 'Self-Service' — de gay hieu nham.)
--
-- LUU Y GUARD: bon khoi 6.1-6.4 kiem tra ton tai theo TEN phieu, KHONG theo
-- trang thai. Neu loc them `status = N`, phieu demo da doi trang thai (vi du
-- tiep nhan 1 -> 2 khi demo) se bi coi la "chua co" va bi insert lai -> nhan doi.
-- CI co buoc "Seed idempotent" doi trang thai 1 phieu roi chay lai de bat hoi quy.

-- 6.0. Don dep phieu mau cu voi ten cu (tranh trung lap khi chay lai tren CSDL cu)
DELETE FROM glpi_items_tickets
 WHERE tickets_id IN (
     SELECT id FROM glpi_tickets WHERE name IN (
         'Cài lại Windows cho máy TDL-PC-A101-004',
         'Thay mực máy in phòng A201',
         'Vệ sinh máy trạm A201',
         'Thay cáp mạng phòng B1',
         'Cài đặt Google Chrome cho phòng A102'
     )
 );

DELETE FROM glpi_tickets_users
 WHERE tickets_id IN (
     SELECT id FROM glpi_tickets WHERE name IN (
         'Cài lại Windows cho máy TDL-PC-A101-004',
         'Thay mực máy in phòng A201',
         'Vệ sinh máy trạm A201',
         'Thay cáp mạng phòng B1',
         'Cài đặt Google Chrome cho phòng A102'
     )
 );

DELETE FROM glpi_tickets
 WHERE name IN (
     'Cài lại Windows cho máy TDL-PC-A101-004',
     'Thay mực máy in phòng A201',
     'Vệ sinh máy trạm A201',
     'Thay cáp mạng phòng B1',
     'Cài đặt Google Chrome cho phòng A102'
 );

-- 6.1. Phieu dang "Moi" (New) - chua phan cong
INSERT INTO glpi_tickets
    (name, content, date, date_creation, date_mod, entities_id, users_id_recipient,
     itilcategories_id, type, status, urgency, impact, priority, requesttypes_id,
     locations_id, is_deleted)
SELECT s.name, s.content, DATE_SUB(@now, INTERVAL s.ago DAY), @now, @now, @entity,
       (SELECT id FROM glpi_users WHERE name = s.requester LIMIT 1),
       (SELECT id FROM glpi_itilcategories WHERE name = s.cat LIMIT 1),
       1, 1, s.urgency, s.impact, s.priority,
       -- Nguon tiep nhan: tra theo TEN, KHONG hardcode id. Ban cu ghi cung 5
       -- ('Written' - qua van ban) — SAI nghia: cac phieu nay do nguoi dung nop
       -- qua CONG THONG TIN. Id cua 'Bao qua cong thong tin' do seed-nen tao
       -- bang INSERT ... WHERE NOT EXISTS nen id co the khac giua cac lan cai.
       (SELECT id FROM glpi_requesttypes WHERE name = 'Báo qua cổng thông tin' LIMIT 1),
       (SELECT id FROM glpi_locations WHERE name = s.loc AND level = 3 LIMIT 1),
       0
FROM (
    SELECT 'Máy không khởi động được' AS name,
           'Máy TDL-PC-A85-003 bấm nút nguồn không lên, đèn nguồn không sáng. Mong kỹ thuật kiểm tra giúp.' AS content,
           0 AS ago, 'sv.hoa' AS requester, 'Máy không khởi động được' AS cat,
           3 AS urgency, 3 AS impact, 3 AS priority, 'Phòng máy A8.5' AS loc UNION ALL
    SELECT 'Không kết nối được mạng LAN',
           'Phòng máy A8.6 mất kết nối mạng từ sáng nay, không vào được Internet.',
           0, 'gv.cuong', 'Không kết nối được Internet', 4, 4, 4, 'Phòng máy A8.6' UNION ALL
    SELECT 'Máy in không in được',
           'Máy in TDL-PRN-A241-001 báo lỗi hết mực, không in được tài liệu.',
           1, 'gv.dung', 'Máy in không in được', 2, 2, 2, 'Phòng máy A24.1' UNION ALL
    SELECT 'Màn hình bị sọc ngang',
           'Màn hình TDL-MON-TV1-002 xuất hiện sọc ngang màu, ảnh hưởng giờ thực hành.',
           2, 'sv.khanh', 'Màn hình có sọc hoặc nhấp nháy', 3, 3, 3, 'Phòng máy TV1'
) s
WHERE NOT EXISTS (SELECT 1 FROM glpi_tickets t WHERE t.name = s.name);

-- 6.2. Phieu dang "Duoc giao" (Assigned) - da phan cong KTV
INSERT INTO glpi_tickets
    (name, content, date, date_creation, date_mod, entities_id, users_id_recipient,
     itilcategories_id, type, status, urgency, impact, priority, requesttypes_id,
     locations_id, is_deleted)
SELECT s.name, s.content, DATE_SUB(@now, INTERVAL s.ago DAY), @now, @now, @entity,
       (SELECT id FROM glpi_users WHERE name = s.requester LIMIT 1),
       (SELECT id FROM glpi_itilcategories WHERE name = s.cat LIMIT 1),
       1, 2, s.urgency, s.impact, s.priority, 1,
       (SELECT id FROM glpi_locations WHERE name = s.loc AND level = 3 LIMIT 1),
       0
FROM (
    SELECT 'Phần mềm AutoCAD báo lỗi bản quyền' AS name,
           'AutoCAD 2024 trên máy trạm A24 lầu báo lỗi hết hạn bản quyền.' AS content,
           3 AS ago, 'gv.cuong' AS requester, 'Phần mềm báo lỗi bản quyền' AS cat,
           4 AS urgency, 4 AS impact, 4 AS priority, 'Phòng máy A24 lầu' AS loc UNION ALL
    SELECT 'Chuột và bàn phím không nhận',
           'Bộ chuột bàn phím máy TDL-PC-A84-002 không hoạt động, đã thử cắm lại.',
           4, 'sv.hoa', 'Chuột không hoạt động', 2, 2, 2, 'Phòng máy A8.4' UNION ALL
    SELECT 'Máy tính chạy rất chậm',
           'Máy TDL-PC-TV2-001 khởi động rất chậm, treo khi mở nhiều ứng dụng.',
           5, 'gv.dung', 'Máy tính chạy chậm bất thường', 3, 3, 3, 'Phòng máy TV2'
) s
WHERE NOT EXISTS (SELECT 1 FROM glpi_tickets t WHERE t.name = s.name);

-- 6.3. Phieu dang "Da giai quyet" (Solved)
--      LUU Y NGAY THANG: date_creation PHAI bang `date` (ngay tao that su),
--      KHONG duoc la @now. Ban cu dat date_creation = @now trong khi `date` va
--      `solvedate` la qua khu -> solvedate < date_creation (da do thuc te tren
--      he thong that: lech -216 den -672 gio). Hoi dong chi can mo danh sach
--      phieu la thay ngay "giai quyet truoc khi tao" — vo ly.
INSERT INTO glpi_tickets
    (name, content, date, date_creation, date_mod, solvedate, entities_id, users_id_recipient,
     itilcategories_id, type, status, urgency, impact, priority, requesttypes_id,
     locations_id, is_deleted)
SELECT s.name, s.content, DATE_SUB(@now, INTERVAL s.ago DAY),
       DATE_SUB(@now, INTERVAL s.ago DAY), @now,
       DATE_SUB(@now, INTERVAL s.ago - 1 DAY), @entity,
       (SELECT id FROM glpi_users WHERE name = s.requester LIMIT 1),
       (SELECT id FROM glpi_itilcategories WHERE name = s.cat LIMIT 1),
       1, 5, s.urgency, s.impact, s.priority, 1,
       (SELECT id FROM glpi_locations WHERE name = s.loc AND level = 3 LIMIT 1),
       0
FROM (
    SELECT 'Cài lại Windows cho máy TDL-PC-A83-004' AS name,
           'Máy TDL-PC-A83-004 bị lỗi hệ điều hành, cần cài lại Windows và driver.' AS content,
           10 AS ago, 'sv.khanh' AS requester, 'Hệ điều hành không khởi động' AS cat,
           3 AS urgency, 3 AS impact, 3 AS priority, 'Phòng máy A8.3' AS loc UNION ALL
    SELECT 'Thay mực máy in phòng A24.1',
           'Máy in phòng A24.1 hết mực, đề nghị thay mực mới.',
           12, 'gv.cuong', 'Máy in không in được', 2, 2, 2, 'Phòng máy A24.1' UNION ALL
    SELECT 'Sửa lỗi đăng nhập tài khoản sinh viên',
           'Tài khoản sinh viên không đăng nhập được vào máy phòng TV3.',
           15, 'sv.hoa', 'Không đăng nhập được máy tính', 3, 3, 3, 'Phòng máy TV3'
) s
WHERE NOT EXISTS (SELECT 1 FROM glpi_tickets t WHERE t.name = s.name);

-- 6.4. Phieu dang "Da dong" (Closed)
--      Cung ly do nhu 6.3: date_creation phai la ngay tao that (qua khu),
--      khong phai @now — neu khong solvedate/closedate se som hon ngay tao.
INSERT INTO glpi_tickets
    (name, content, date, date_creation, date_mod, solvedate, closedate, entities_id,
     users_id_recipient, itilcategories_id, type, status, urgency, impact, priority,
     requesttypes_id, locations_id, is_deleted)
SELECT s.name, s.content, DATE_SUB(@now, INTERVAL s.ago DAY),
       DATE_SUB(@now, INTERVAL s.ago DAY), @now,
       DATE_SUB(@now, INTERVAL s.ago - 2 DAY), DATE_SUB(@now, INTERVAL s.ago - 3 DAY),
       @entity,
       (SELECT id FROM glpi_users WHERE name = s.requester LIMIT 1),
       (SELECT id FROM glpi_itilcategories WHERE name = s.cat LIMIT 1),
       1, 6, s.urgency, s.impact, s.priority, 1,
       (SELECT id FROM glpi_locations WHERE name = s.loc AND level = 3 LIMIT 1),
       0
FROM (
    SELECT 'Vệ sinh máy tính phòng TV4' AS name,
           'Vệ sinh bụi, tra keo tản nhiệt định kỳ cho máy tính phòng TV4.' AS content,
           20 AS ago, 'gv.dung' AS requester, 'Vệ sinh máy tính định kỳ' AS cat,
           1 AS urgency, 1 AS impact, 1 AS priority, 'Phòng máy TV4' AS loc UNION ALL
    SELECT 'Thay cáp mạng phòng A24.1',
           'Cáp mạng đấu nối Switch tủ Rack phòng A24.1 bị gãy lẫy tiếp xúc, thay cáp mới.',
           25, 'gv.cuong', 'Ổ cắm mạng hỏng', 3, 3, 3, 'Phòng máy A24.1' UNION ALL
    SELECT 'Cài đặt Google Chrome cho phòng A8.5',
           'Cài đặt trình duyệt Chrome theo yêu cầu giảng viên.',
           30, 'sv.khanh', 'Cài đặt bộ văn phòng', 2, 1, 1, 'Phòng máy A8.5'
) s
WHERE NOT EXISTS (SELECT 1 FROM glpi_tickets t WHERE t.name = s.name);

-- 6.5. SUA DON NGAY THANG CHO BAN GHI CU.
--      Cac phieu do LAN CHAY TRUOC tao ra (ban seed cu dat date_creation = @now
--      trong khi date/solvedate la qua khu) van nam trong CSDL. Vong lap
--      NOT EXISTS o 6.3/6.4 bo qua chung, nen chung KHONG tu duoc sua.
--      Da do tren he thong that: 16 phieu co date_creation = ngay chay script,
--      con date/solvedate la qua khu -> lech am den -672 gio.
--
--      PHAM VI: chi 13 phieu DEMO o tren (khop theo ten, dung danh sach 6.3/6.4).
--      Ban cu quet TOAN BO bang: phieu THAT cua nguoi dung (tao qua giao dien)
--      cung la doi tuong sua neu roi vao ca "date_creation > date" — script
--      seed khong duoc phep ghi vao du lieu nguoi dung that.
UPDATE glpi_tickets
   SET date_creation = date
 WHERE is_deleted = 0
   AND date IS NOT NULL
   AND date_creation > date
   AND name IN (
       'Máy không khởi động được',
       'Không kết nối được mạng LAN',
       'Máy in không in được',
       'Màn hình bị sọc ngang',
       'Phần mềm AutoCAD báo lỗi bản quyền',
       'Chuột và bàn phím không nhận',
       'Máy tính chạy rất chậm',
       'Cài lại Windows cho máy TDL-PC-A83-004',
       'Thay mực máy in phòng A24.1',
       'Sửa lỗi đăng nhập tài khoản sinh viên',
       'Vệ sinh máy tính phòng TV4',
       'Thay cáp mạng phòng A24.1',
       'Cài đặt Google Chrome cho phòng A8.5'
   );


-- ==============================================================================
--  7. GAN NGUOI XU LY (ky thuat vien) CHO PHIEU
--     Tao du lieu de dashboard "Phieu duoc giao" co so lieu.
-- ==============================================================================

-- 7.0. SUA DON: bo sung model con thieu cho ban ghi da co tu lan chay truoc
--      (vi vong lap NOT EXISTS bo qua ban ghi da ton tai, nen khong tu cap nhat)
UPDATE glpi_computers
SET computermodels_id = (SELECT id FROM glpi_computermodels WHERE name = 'PowerEdge R740' LIMIT 1),
    manufacturers_id  = (SELECT id FROM glpi_manufacturers WHERE name = 'Dell' LIMIT 1),
    date_mod = @now
WHERE otherserial = 'TDL-SRV-001'
  AND (computermodels_id IS NULL OR computermodels_id = 0);

-- Gan ky thuat vien cho phieu status IN (2,5,6) chua co nguoi xu ly.
-- CHI ap dung cho phieu DEMO (loc theo ten, cung ly do guard nhu phan C cua
-- seed-sla: chay lai seed tren he thong dang dung KHONG duoc gan 'tech' lam
-- nguoi xu ly cho phieu that cua nguoi dung).
INSERT INTO glpi_tickets_users (tickets_id, users_id, type, use_notification, alternative_email)
SELECT t.id, @tech_user, 2, 1, ''
FROM glpi_tickets t
WHERE t.status IN (2, 5, 6)
  AND t.name IN ('Máy không khởi động được', 'Không kết nối được mạng LAN',
                 'Máy in không in được', 'Màn hình bị sọc ngang',
                 'Phần mềm AutoCAD báo lỗi bản quyền', 'Chuột và bàn phím không nhận',
                 'Máy tính chạy rất chậm',
                 'Cài lại Windows cho máy TDL-PC-A83-004', 'Thay mực máy in phòng A24.1',
                 'Sửa lỗi đăng nhập tài khoản sinh viên', 'Vệ sinh máy tính phòng TV4',
                 'Thay cáp mạng phòng A24.1', 'Cài đặt Google Chrome cho phòng A8.5')
  AND NOT EXISTS (SELECT 1 FROM glpi_tickets_users tu
                  WHERE tu.tickets_id = t.id AND tu.type = 2);

-- Dam bao moi phieu DEMO deu co nguoi yeu cau (type=1) trong glpi_tickets_users.
-- Cung guard theo ten nhu tren.
INSERT INTO glpi_tickets_users (tickets_id, users_id, type, use_notification, alternative_email)
SELECT t.id, t.users_id_recipient, 1, 1, ''
FROM glpi_tickets t
WHERE t.users_id_recipient IS NOT NULL
  AND t.users_id_recipient > 0
  AND t.name IN ('Máy không khởi động được', 'Không kết nối được mạng LAN',
                 'Máy in không in được', 'Màn hình bị sọc ngang',
                 'Phần mềm AutoCAD báo lỗi bản quyền', 'Chuột và bàn phím không nhận',
                 'Máy tính chạy rất chậm',
                 'Cài lại Windows cho máy TDL-PC-A83-004', 'Thay mực máy in phòng A24.1',
                 'Sửa lỗi đăng nhập tài khoản sinh viên', 'Vệ sinh máy tính phòng TV4',
                 'Thay cáp mạng phòng A24.1', 'Cài đặt Google Chrome cho phòng A8.5')
  AND NOT EXISTS (SELECT 1 FROM glpi_tickets_users tu
                  WHERE tu.tickets_id = t.id AND tu.type = 1);

-- 7b. Lien ket phieu su co voi thiet bi (glpi_items_tickets)
--     Phuc vu tab "Lich su phieu su co" tren ho so thiet bi khi demo.
INSERT INTO glpi_items_tickets (itemtype, items_id, tickets_id)
SELECT m.itemtype, m.items_id, t.id
FROM (
    SELECT 'Máy không khởi động được' AS tname, 'Computer' AS itemtype,
           (SELECT id FROM glpi_computers WHERE name = 'TDL-PC-A85-003' LIMIT 1) AS items_id UNION ALL
    SELECT 'Máy in không in được', 'Printer',
           (SELECT id FROM glpi_printers WHERE name = 'TDL-PRN-A241-001' LIMIT 1) UNION ALL
    SELECT 'Màn hình bị sọc ngang', 'Monitor',
           (SELECT id FROM glpi_monitors WHERE name = 'TDL-MON-TV1-002' LIMIT 1) UNION ALL
    SELECT 'Phần mềm AutoCAD báo lỗi bản quyền', 'Computer',
           (SELECT id FROM glpi_computers WHERE name = 'TDL-PC-A24L-001' LIMIT 1) UNION ALL
    SELECT 'Chuột và bàn phím không nhận', 'Computer',
           (SELECT id FROM glpi_computers WHERE name = 'TDL-PC-A84-002' LIMIT 1) UNION ALL
    SELECT 'Máy tính chạy rất chậm', 'Computer',
           (SELECT id FROM glpi_computers WHERE name = 'TDL-PC-TV2-001' LIMIT 1) UNION ALL
    SELECT 'Cài lại Windows cho máy TDL-PC-A83-004', 'Computer',
           (SELECT id FROM glpi_computers WHERE name = 'TDL-PC-A83-004' LIMIT 1) UNION ALL
    SELECT 'Thay mực máy in phòng A24.1', 'Printer',
           (SELECT id FROM glpi_printers WHERE name = 'TDL-PRN-A241-001' LIMIT 1) UNION ALL
    SELECT 'Sửa lỗi đăng nhập tài khoản sinh viên', 'Computer',
           (SELECT id FROM glpi_computers WHERE name = 'TDL-PC-TV3-001' LIMIT 1) UNION ALL
    SELECT 'Vệ sinh máy tính phòng TV4', 'Computer',
           (SELECT id FROM glpi_computers WHERE name = 'TDL-PC-TV4-005' LIMIT 1) UNION ALL
    SELECT 'Thay cáp mạng phòng A24.1', 'NetworkEquipment',
           (SELECT id FROM glpi_networkequipments WHERE name = 'TDL-SW-A241-001' LIMIT 1) UNION ALL
    SELECT 'Cài đặt Google Chrome cho phòng A8.5', 'Computer',
           (SELECT id FROM glpi_computers WHERE name = 'TDL-PC-A85-001' LIMIT 1) UNION ALL
    SELECT 'Không kết nối được mạng LAN', 'NetworkEquipment',
           (SELECT id FROM glpi_networkequipments WHERE name = 'TDL-SW-A86-001' LIMIT 1)
) m
JOIN glpi_tickets t ON t.name = m.tname
WHERE m.items_id IS NOT NULL AND m.items_id > 0
  AND NOT EXISTS (
      SELECT 1 FROM glpi_items_tickets it
      WHERE it.itemtype = m.itemtype
        AND it.items_id = m.items_id
        AND it.tickets_id = t.id
  );


-- ==============================================================================
--  8. LICH BAO TRI DINH KY + MUON/TRA THIET BI
--     -> Da chuyen sang scripts/seed-sla-va-chong-lam-dung.sql (phan B2, B3)
--     Su dung glpi_ticketrecurrents (lich bao tri dinh ky) va
--     glpi_reservations (muon/tra thiet bi) - co che GOC cua GLPI.
-- ==============================================================================


-- ==============================================================================
--  KET QUA
-- ==============================================================================
SELECT '=== DU LIEU MAU DA TAO ===' AS ' ';
SELECT 'Người dùng mẫu'          AS 'Danh mục', COUNT(*) AS 'Số lượng'
    FROM glpi_users WHERE name IN ('ktv.an','ktv.binh','gv.cuong','gv.dung','sv.hoa','sv.khanh')
UNION ALL SELECT 'Máy tính phòng máy (desktop)', COUNT(*) FROM glpi_computers WHERE name LIKE 'TDL-PC-%'
UNION ALL SELECT 'Máy tính (laptop)',            COUNT(*) FROM glpi_computers WHERE name LIKE 'TDL-LAP-%'
UNION ALL SELECT 'Máy chủ',                      COUNT(*) FROM glpi_computers WHERE name LIKE 'TDL-SRV-%'
UNION ALL SELECT 'Màn hình LCD phòng máy',       COUNT(*) FROM glpi_monitors  WHERE name LIKE 'TDL-MON-%'
UNION ALL SELECT 'Smart Tivi phòng máy (80-85")', COUNT(*) FROM glpi_monitors WHERE name LIKE 'TDL-TV-%'
UNION ALL SELECT 'Máy in',                       COUNT(*) FROM glpi_printers  WHERE name LIKE 'TDL-PRN-%'
UNION ALL SELECT 'Thiết bị mạng & Tủ Rack',      COUNT(*) FROM glpi_networkequipments WHERE name LIKE 'TDL-%'
UNION ALL SELECT 'Thiết bị ngoại vi (âm thanh)', COUNT(*) FROM glpi_peripherals WHERE name LIKE 'TDL-%'
UNION ALL SELECT 'Phần mềm',                     COUNT(*) FROM glpi_softwares
UNION ALL SELECT 'Phiếu - Mới',                  COUNT(*) FROM glpi_tickets WHERE status = 1
UNION ALL SELECT 'Phiếu - Được giao',            COUNT(*) FROM glpi_tickets WHERE status = 2
UNION ALL SELECT 'Phiếu - Đã giải quyết',        COUNT(*) FROM glpi_tickets WHERE status = 5
UNION ALL SELECT 'Phiếu - Đã đóng',              COUNT(*) FROM glpi_tickets WHERE status = 6
UNION ALL SELECT 'Phiếu - TỔNG',                 COUNT(*) FROM glpi_tickets;
