# Tài liệu tổng hợp hệ thống Hỗ trợ Kỹ thuật PineDesk

Hệ thống Hỗ trợ Kỹ thuật và Quản lý Tài sản Công nghệ Thông tin (PineDesk) cho Trường Đại học Đà Lạt, xây dựng trên nền tảng GLPI 11.0.0 và kiến trúc container hóa.

Tài liệu này tổng hợp toàn diện các nội dung về bài toán nghiệp vụ, cơ cấu tổ chức Đại học Đà Lạt, kiến trúc kỹ thuật ngoài lõi, cơ chế phòng thủ 6 tầng chống lạm dụng, tùy biến giao diện và Việt hóa, quản lý thiết bị bằng mã QR, hướng dẫn triển khai vận hành, kịch bản bảo vệ đồ án và bộ 25 câu hỏi phản biện.

---

## Mục lục

1. [Bài toán nghiệp vụ và bối cảnh Trường Đại học Đà Lạt](#1-bài-toán-nghiệp-vụ-và-bối-cảnh-trường-đại-học-đà-lạt)
2. [Cơ cấu tổ chức DLU và ánh xạ dữ liệu vào GLPI](#2-cơ-cấu-tổ-chức-dlu-và-ánh-xạ-dữ-liệu-vào-glpi)
3. [Kiến trúc kỹ thuật và so sánh với GLPI gốc](#3-kiến-trúc-kỹ-thuật-và-so-sánh-với-glpi-gốc)
4. [Cơ chế phòng thủ 6 tầng chống lạm dụng và spam phiếu](#4-cơ-chế-phòng-thủ-6-tầng-chống-lạm-dụng-và-spam-phiếu)
5. [Tùy biến giao diện nhận diện DLU và quy trình Việt hóa](#5-tùy-biến-giao-diện-nhận-diện-dlu-và-quy-trình-việt-hóa)
6. [Quản lý tài sản và tạo mã QR thiết bị](#6-quản-lý-tài-sản-và-tạo-mã-qr-thiết-bị)
7. [Hướng dẫn triển khai, vận hành và an toàn thông tin](#7-hướng-dẫn-triển-khai-vận-hành-và-an-toàn-thông-tin)
8. [Kịch bản trình diễn bảo vệ đồ án (7 phút)](#8-kịch-bản-trình-diễn-bảo-vệ-đồ-án-7-phút)
9. [Bộ 25 câu hỏi phản biện và định hướng trả lời](#9-bộ-25-câu-hỏi-phản-biện-và-định-hướng-trả-lời)
10. [Phụ lục lệnh thao tác nhanh](#10-phụ-lục-lệnh-thao-tác-nhanh)

---

## 1. Bài toán nghiệp vụ và bối cảnh Trường Đại học Đà Lạt

### 1.1. Tóm tắt đề tài

Xây dựng hệ thống quản lý các phòng máy, máy tính, thiết bị mạng và phần mềm cài đặt. Mỗi thiết bị có hồ sơ và mã QR; quản lý cấu hình, vị trí, tình trạng hoạt động và lịch sử sửa chữa bảo trì. Bổ sung chức năng tiếp nhận sự cố dạng ticket (máy không hoạt động, lỗi mạng, phần mềm, thiết bị ngoại vi), tự động điều phối, phân công người xử lý và theo dõi tiến độ theo chuẩn ITIL. Bảng điều khiển (Dashboard) thống kê số thiết bị, sự cố và lịch bảo trì.

### 1.2. Đơn vị phụ trách và ba mâu thuẫn vận hành

Đơn vị phụ trách kỹ thuật tại trường: Trung tâm Công nghệ thông tin (ITC), chịu trách nhiệm quản lý, vận hành hệ thống CNTT và tổ chức phòng thực hành máy tính cho người học.

Ba mâu thuẫn cốt lõi trong mô hình tiếp nhận truyền thống:

| Ký hiệu | Mâu thuẫn | Dữ kiện thực tế (có nguồn) | Suy luận kỹ thuật |
|---|---|---|---|
| M1 | Tỉ lệ người học trên nhân sự kỹ thuật cao | Hơn 14.500 người học (dlu.edu.vn). ITC có 5 nhân sự gồm 01 Giám đốc, 01 Phó Giám đốc, 02 Chuyên viên, 01 Nhân viên (itc.dlu.edu.vn/gioi-thieu/). | Tỉ lệ trung bình khoảng 1 nhân sự trên 2.900 người học (tính riêng 3 nhân sự kỹ thuật trực tiếp là khoảng 1 : 4.800). Bắt buộc phải có cổng tự phục vụ (Self-Service) và tự động hóa điều phối thay vì liên hệ thủ công. |
| M2 | Cửa sổ tiếp nhận trực tiếp hẹp | Hotline duy nhất 0913 069 978, giờ làm việc Thứ 2 đến Thứ 6, từ 7h30 đến 16h30 (itc.dlu.edu.vn/lien-he/). | Khoảng 123 giờ mỗi tuần (chiếm 73% tổng thời gian tuần) không có kênh tiếp nhận trực tiếp. Các ca học tối, cuối tuần hoặc đợt thi cử không có kênh ghi nhận tức thời. |
| M3 | Kênh tiếp nhận phi cấu trúc | ITC công bố hotline, email và biểu mẫu liên hệ tĩnh; chưa công bố hệ thống ticket có phân công, trạng thái và SLA. | Tiếp nhận qua điện thoại và email tự do dễ thất lạc, không đo lường được thời gian xử lý, không lưu vết lịch sử hỏng hóc gắn với từng thiết bị và khó bàn giao ca trực. |

### 1.3. Cơ cấu nhân sự Trung tâm CNTT (ITC)

Nguồn công khai từ cổng thông tin `itc.dlu.edu.vn` (tháng 10/2026):

| STT | Họ tên | Chức danh | Email liên hệ |
|---|---|---|---|
| 1 | ThS. Trần Thống | Giám đốc | thongt@dlu.edu.vn |
| 2 | TS. Trần Ngô Như Khánh | Phó Giám đốc | khanhtnn@dlu.edu.vn |
| 3 | Đặng Quốc Phi | Chuyên viên | phidq@dlu.edu.vn |
| 4 | Lê Thị Uyên | Chuyên viên | uyenlt@dlu.edu.vn |
| 5 | Phan Trung Tính | Nhân viên | tinhpt@dlu.edu.vn |

Hotline: 0913 069 978 · Email: itc@dlu.edu.vn · Địa chỉ: Số 01 Phù Đổng Thiên Vương, Phường Lâm Viên, TP. Đà Lạt.

### 1.4. So sánh với các giải pháp thay thế

| Tiêu chí so sánh | Google Forms + Sheets | GLPI gốc không tùy biến | Phần mềm thương mại (ServiceNow, Jira) | PineDesk (Đồ án đề xuất) |
|---|---|---|---|---|
| Cổng tự phục vụ 24/7 | Có | Có | Có | Có |
| Vòng đời chuẩn ITIL (Mới, Giao, Chờ, Đóng) | Không | Có | Có | Có |
| Phân công tự động theo nhóm kỹ thuật | Không | Có | Có | Có |
| Theo dõi cam kết thời gian xử lý (SLA) | Không | Có sẵn cấu hình | Có | Đã cấu hình 5 mức SLA kỹ thuật |
| Quản lý hồ sơ thiết bị, vị trí, phần mềm | Không | Có | Có | Có, nạp sẵn danh mục DLU |
| Sinh và in nhãn mã QR vật lý dán máy | Không | Cần plugin | Cần tiện ích mở rộng | Tích hợp plugin Barcode đã vá lỗi + script Python |
| Nhận diện thương hiệu trường | Không | Mặc định xám/xanh | Tùy biến phức tạp | Bảng màu Đà Lạt, logo DLU, CSS ngoài lõi |
| Giao diện tiếng Việt hoàn chỉnh | Phụ thuộc trình duyệt | Dịch sẵn khoảng 32% | Đa ngôn ngữ có phí | Gộp bản dịch 32,0%, 100% nhãn trạng thái chính |
| Phòng thủ chống spam nộp phiếu | Hạn chế (chỉ Captcha) | Không có hạn mức tài khoản | Có cấu hình nâng cao | 6 tầng phòng thủ (Nginx, trần 5 phiếu, chống trùng 30m) |
| Chi phí bản quyền và làm chủ dữ liệu | Miễn phí nhưng dữ liệu ngoài | Mã nguồn mở miễn phí | Rất cao hàng năm | Mã nguồn mở, tự lưu trữ nội bộ tại trường |

### 1.5. Kế hoạch khảo sát thực địa tiếp theo

- Đã kiểm chứng: Thông tin tổ chức trường, danh mục đơn vị, 5 nhân sự ITC, hotline, giờ làm việc, kiến trúc container, plugin và cơ chế chặn spam.
- Giả định kỹ thuật cần khảo sát thực địa tại ITC: Số lượng sự cố trung bình mỗi tuần, thời gian phản hồi thực tế hiện nay, tỉ lệ hỏng hóc ngoài giờ và văn bản ban hành chỉ số SLA chính thức từ nhà trường.

---

## 2. Cơ cấu tổ chức DLU và ánh xạ dữ liệu vào GLPI

### 2.1. Thông tin chung Trường Đại học Đà Lạt

- Tên tiếng Việt: Trường Đại học Đà Lạt (Dalat University - DLU).
- Mã trường: TDL (tiền tố mã tài sản trong hệ thống: `TDL-PC-A101-001`).
- Thành lập: 1976. Địa chỉ: Số 01 Phù Đổng Thiên Vương, Phường Lâm Viên, TP. Đà Lạt, tỉnh Lâm Đồng.
- Hiệu trưởng: TS. Mai Minh Nhật. Quy mô đào tạo: Hơn 14.500 người học (41 ngành đại học, 14 thạc sĩ, 07 tiến sĩ).

### 2.2. Danh mục 16 khoa, 10 phòng chức năng và các đơn vị

16 khoa chuyên môn (tương ứng nhóm người dùng và vị trí):
1. Khoa Toán - Tin học (`ktt.dlu.edu.vn`)
2. Khoa Công nghệ Thông tin (`cntt.dlu.edu.vn`, mật độ thiết bị cao nhất)
3. Khoa Vật lý và Kỹ thuật hạt nhân (`vl.dlu.edu.vn`)
4. Khoa Hóa học và Môi trường (`khhmt.dlu.edu.vn`)
5. Khoa Sinh học (`ksh.dlu.edu.vn`)
6. Khoa Nông lâm (`knl.dlu.edu.vn`)
7. Khoa Ngữ văn và Lịch sử (`nvvh.dlu.edu.vn`)
8. Khoa Kinh tế - Quản trị Kinh doanh (`kktqt.dlu.edu.vn`)
9. Khoa Du lịch (`kqtdl.dlu.edu.vn`)
10. Khoa Luật học (`klh.dlu.edu.vn`)
11. Khoa Ngoại ngữ (`nn.dlu.edu.vn`)
12. Khoa Quốc tế học (`kqth.dlu.edu.vn`)
13. Khoa Xã hội học và Công tác xã hội (`kctxh.dlu.edu.vn`)
14. Khoa Sư phạm (`sp.dlu.edu.vn`)
15. Khoa Lý luận Chính trị (`kllct.dlu.edu.vn`)
16. Khoa Giáo dục thể chất (`kgdtc.dlu.edu.vn`)

10 phòng chức năng:
1. Phòng Tổ chức - Hành chính (`tchc.dlu.edu.vn`)
2. Phòng Quản lý Đào tạo (`pqldt.dlu.edu.vn`)
3. Phòng Công tác sinh viên (`pctsv.dlu.edu.vn`)
4. Phòng Quản lý chất lượng và Pháp chế (`pktkd.dlu.edu.vn`)
5. Phòng Khoa học công nghệ và Hợp tác quốc tế (`pkhht.dlu.edu.vn`)
6. Phòng Thanh tra
7. Phòng Tài chính Kế hoạch (`ptc.dlu.edu.vn`)
8. Phòng Quản trị Cơ sở vật chất (`pcsvc.dlu.edu.vn`, đơn vị chủ quản tài sản chung)
9. Phòng Quản lý Đào tạo Sau Đại học (`sdh.dlu.edu.vn`)
10. Phòng Tạp chí và Truyền thông (`ptctt.dlu.edu.vn`)

Trung tâm và viện trực thuộc:
Trung tâm Công nghệ thông tin (ITC, đơn vị vận hành kỹ thuật), Trung tâm Ngoại ngữ và Đào tạo nguồn nhân lực, Trung tâm Hỗ trợ Khởi nghiệp, Trung tâm Phân tích và Kiểm định, Trung tâm nghiên cứu đa dạng sinh học và biến đổi khí hậu, Trung tâm Giáo dục Quốc phòng và An ninh, Học viện King Sejong Đà Lạt.

Phân định trách nhiệm vận hành:
- Phòng Quản trị Cơ sở vật chất: Chủ quản tài sản, theo dõi kế hoạch mua sắm, điều chuyển và thanh lý.
- Trung tâm Công nghệ thông tin (ITC): Tiếp nhận, phân công và xử lý sự cố kỹ thuật, bảo trì hệ thống mạng và phòng thực hành.
- Giảng viên và sinh viên: Người dùng cuối gửi yêu cầu qua cổng Self-Service.

### 2.3. Cây vị trí và ánh xạ vào cơ sở dữ liệu GLPI

Cấu trúc cây vị trí 3 cấp (đã nạp qua `scripts/seed-du-lieu-nen.sql` gồm 12 tòa nhà, 54 phòng, 67 vị trí tổng thể):

```
Trường Đại học Đà Lạt
├── Khu hành chính H1 (Phòng ban chuyên môn)
├── Khu hành chính H2
├── Giảng đường A1 (Phòng máy thực hành A101, A102...)
├── Giảng đường A2 (Phòng Lab thực hành)
├── Giảng đường B1 (Phòng máy thực hành B101...)
├── Giảng đường B2 (Phòng Lab B201...)
├── Trung tâm CNTT (ITC)
├── Thư viện
└── Ký túc xá
```

Ánh xạ vào các bảng cơ sở dữ liệu GLPI:

| Dữ liệu nghiệp vụ DLU | Thành phần trong GLPI | Bảng cơ sở dữ liệu | Số lượng nạp mẫu |
|---|---|---|---|
| Khoa, phòng ban, trung tâm | Nhóm (Groups) | `glpi_groups` | 33 đơn vị (16 khoa, 10 phòng, 7 trung tâm) |
| Tòa nhà, phòng máy, văn phòng | Cây vị trí (Locations) | `glpi_locations` | 67 bản ghi (12 tòa nhà, 54 phòng máy) |
| Thiết bị theo đơn vị và phòng | Máy tính (Computers) | `glpi_computers` | 17 máy tính demo gắn vị trí |
| Màn hình, máy in, mạng | Màn hình, Máy in, Thiết bị mạng | `glpi_monitors`, `glpi_printers`, `glpi_networkequipments` | 5 màn hình, 3 máy in, 9 thiết bị mạng |
| Cán bộ, kỹ thuật viên, sinh viên | Người dùng (Users) | `glpi_users` | 6 tài khoản demo trải đều 3 vai trò |
| Phân quyền theo vai trò | Hồ sơ quyền (Profiles) | `glpi_profiles_users` | Super-Admin, Admin, Technician, Self-Service |
| Danh mục phân loại sự cố | ITIL Categories | `glpi_itilcategories` | 79 loại sự cố (10 cấp 1, 69 cấp 2) |

Quy chuẩn mã định danh tài sản (`Inventory number`):
- `TDL-PC-A101-001`: Trường ĐH Đà Lạt, Máy tính, Phòng A101, Số thứ tự 001.
- `TDL-SW-A101-01`: Trường ĐH Đà Lạt, Switch mạng, Phòng A101, Số thứ tự 01.
- `TDL-PR-B203-01`: Trường ĐH Đà Lạt, Máy in, Phòng B203, Số thứ tự 01.
- `TDL-MON-A102-005`: Trường ĐH Đà Lạt, Màn hình, Phòng A102, Số thứ tự 005.

Ước tính quy mô phần cứng toàn trường khi triển khai thực tế:
800 - 1.200 máy tính phòng máy thực hành (10-12 phòng máy, 40-60 máy/phòng); 400 - 600 máy tính văn phòng; 80 - 120 máy in; 100 - 150 máy chiếu; 150 - 250 thiết bị mạng; 1.200 - 1.500 màn hình; 15 - 25 máy chủ do ITC quản lý.

---

## 3. Kiến trúc kỹ thuật và so sánh với GLPI gốc

### 3.1. Kiến trúc container hóa

PineDesk bao gồm 4 dịch vụ container độc lập:
1. `pinedesk-gateway` (Nginx 1.27 Alpine): Cổng tiếp nhận mạng bên ngoài qua HTTPS cổng 8443, áp dụng chứng chỉ SSL tự ký có cấu hình SAN, kiểm soát tốc độ truy cập (Rate Limit) và lọc tệp tĩnh.
2. `pinedesk-glpi` (GLPI 11.0.0 trên nền PHP 8.4): Máy chủ ứng dụng ITSM, chạy Apache nội bộ lắng nghe cổng 80, kết nối plugin `dlubrand` và `pinedesk`.
3. `pinedesk-db` (MariaDB 10.11 LTS): Lưu trữ cơ sở dữ liệu quan hệ, thiết lập mạng cô lập nội bộ (`internal: true`).
4. `pinedesk-redis` (Redis 7 Alpine): Bộ đệm lưu trữ phiên làm việc, thiết lập mạng cô lập nội bộ (`internal: true`).

Nguyên tắc kiến trúc cốt lõi: 100% các thành phần tùy biến nằm hoàn toàn ngoài mã nguồn cốt lõi GLPI (thư mục `/var/www/glpi/src/`). Toàn bộ tính năng bổ sung được đóng gói trong plugin, tệp ngôn ngữ ngoài lõi, cấu hình Nginx gateway và các kịch bản tự động hóa. Khi nâng cấp image GLPI mới, hệ thống không bị xung đột mã nguồn.

### 3.2. Bảng đối chiếu đóng góp kỹ thuật so với GLPI 11 gốc

| Hạng mục | GLPI 11 gốc khi mới cài | Hệ thống PineDesk hoàn thiện | Giá trị kỹ thuật đóng góp |
|---|---|---|---|
| Khởi động hệ thống | Cần cài thủ công từng bước web | Cài đặt tự động bằng một lệnh `bash scripts/cai-dat-tat-ca.sh` | Tự động hóa toàn bộ quá trình thiết lập |
| Cổng giao tiếp mạng | Chạy HTTP không mã hóa hoặc tự cấu hình | Nginx gateway HTTPS cổng 8443, SSL tích hợp SAN | Bảo mật kết nối, hỗ trợ mạng nội bộ không lỗi cert |
| Nhận diện thương hiệu | Giao diện chuẩn Tabler xám/xanh | Bảng màu Đà Lạt (xanh rêu, cam đất) + logo DLU | Bộ nhận diện thương hiệu nhất quán qua CSS ngoài lõi |
| Ngôn ngữ tiếng Việt | Gói `vi_VN.mo` chính thức chỉ đạt ~32% | Lớp phủ gộp bổ sung 556 thuật ngữ + 212 mục số nhiều | Dịch 100% các thẻ trạng thái và menu thường dùng |
| Cạm bẫy dịch số nhiều `_n()` | Để nguyên tiếng Anh do khóa `\0` | Script gộp catalog xử lý trực tiếp khóa ghép `\0` | Khắc phục triệt để lỗi thẻ số nhiều hiển thị tiếng Anh |
| Việt hóa dữ liệu CSDL | Tên hồ sơ, bảng điều khiển vẫn là tiếng Anh | Script `viet-hoa-du-lieu.sh` cập nhật tự động trong CSDL | Đồng bộ tiếng Việt ở cả tầng dữ liệu |
| Cơ cấu tổ chức trường | Cơ sở dữ liệu rỗng | Nạp sẵn 16 khoa, 10 phòng, 7 trung tâm, 12 tòa nhà, 54 phòng | Ánh xạ chính xác dữ liệu thực tế Đại học Đà Lạt |
| Phân loại sự cố ITIL | Rỗng | 79 loại sự cố 2 cấp chuẩn hóa | Hỗ trợ phân loại sự cố chính xác ngay khi vận hành |
| Dữ liệu thiết bị mẫu | Rỗng | 17 máy tính, 5 màn hình, 3 máy in, 9 thiết bị mạng | Có dữ liệu kiểm chứng và kịch bản demo sống động |
| Tài khoản thử nghiệm | Chỉ có tài khoản mặc định `glpi` | 6 tài khoản mẫu cho 3 vai trò (SV, GV, KTV) | Chứng minh phân quyền Least Privilege trên thực tế |
| Quy trình phiếu mẫu | Rỗng | 13 phiếu trải đều các trạng thái chuẩn ITIL | Minh họa luồng xử lý từ tiếp nhận đến đóng phiếu |
| Quy định hạn mức xử lý (SLA) | Rỗng | 5 mức SLA kỹ thuật (P1 đến P5) kèm mốc TTO và TTR | Thiết lập cơ chế kiểm soát tiến độ xử lý sự cố |
| Chống spam tại tầng mạng | Không có | Nginx rate limit 30 request/phút theo IP có burst đệm | Ngăn chặn bot tự động nộp phiếu tần suất cao |
| Chống lạm dụng theo tài khoản | Không có | Plugin `pinedesk` chặn trần 5 phiếu mở và 10 phiếu/ngày | Chống spam phiếu hiệu quả trong môi trường mạng NAT |
| Chống nộp phiếu trùng lặp | Không có | Plugin `pinedesk` chặn phiếu trùng cùng thiết bị trong 30 phút | Ngăn chặn hiện tượng gửi lặp nhiều lần cho một lỗi |
| Ghi vết nhật ký tạo phiếu | Lịch sử chung khó tra cứu hạn mức | Bảng chuyên dụng `glpi_plugin_pinedesk_ticketlog` | Lưu vết địa chỉ IP, tài khoản, nguyên nhân chặn |
| Khả năng an toàn đồng thời | Dễ race condition khi mở nhiều tab | MariaDB mutex `GET_LOCK()` theo từng tài khoản | Đảm bảo tính nhất quán dữ liệu khi gửi đồng thời |
| Tính năng mã QR thiết bị | Chưa có hoặc plugin Barcode lỗi trên GLPI 11 | Vá 3 lỗi tương thích cho plugin Barcode 2.7.1 | Kích hoạt thành công tính năng in QR hàng loạt |
| Giải pháp QR dự phòng | Không có | Script Python `sinh-ma-qr.py` kết xuất mã độc lập | Không phụ thuộc vào chu kỳ nâng cấp của GLPI |
| Kiểm thử tự động (CI) | Không có kịch bản cho dự án | Pipeline CI kiểm tra cú pháp, cấu hình và 37 test cases | Đảm bảo hệ thống ổn định trước khi đưa vào vận hành |

### 3.3. Danh mục tài khoản kiểm thử và phân quyền

| Tài khoản | Mật khẩu mẫu | Vai trò nghiệp vụ | Hồ sơ quyền GLPI | Phạm vi truy cập |
|---|---|---|---|---|
| `sv.hoa` | Đọc từ `.env` | Sinh viên Khoa CNTT | Self-Service | Chỉ tạo phiếu và xem phiếu do chính mình gửi |
| `sv.khanh` | Đọc từ `.env` | Sinh viên Khoa Toán - Tin | Self-Service | Chỉ tạo phiếu và xem phiếu do chính mình gửi |
| `gv.cuong` | Đọc từ `.env` | Giảng viên Khoa CNTT | Self-Service | Tạo phiếu, yêu cầu mượn thiết bị giảng dạy |
| `gv.dung` | Đọc từ `.env` | Giảng viên Khoa Kinh tế | Self-Service | Tạo phiếu, yêu cầu mượn thiết bị giảng dạy |
| `ktv.an` | Đọc từ `.env` | Kỹ thuật viên ITC | Technician | Tiếp nhận, xử lý, cập nhật trạng thái phiếu được giao |
| `ktv.binh` | Đọc từ `.env` | Kỹ thuật viên ITC | Technician | Tiếp nhận, xử lý, cập nhật trạng thái phiếu được giao |
| `glpi` | Đổi sau khi cài | Quản trị viên hệ thống | Super-Admin | Toàn quyền cấu hình, điều phối và phân tích báo cáo |

---

## 4. Cơ chế phòng thủ 6 tầng chống lạm dụng và spam phiếu

### 4.1. Sơ đồ kiến trúc phòng thủ theo chiều sâu

```
Người dùng gửi phiếu yêu cầu
       │
       ▼
┌────────────────────────────────────────────────────────┐
│ T1. NGINX: Giới hạn tần suất 30 request/phút theo IP   │
├────────────────────────────────────────────────────────┤
│ T2. PHIÊN: Bắt buộc đăng nhập tài khoản DLU xác thực   │
├────────────────────────────────────────────────────────┤
│ T3. NGHIỆP VỤ: Giới hạn tối đa 5 phiếu mở và 10 p/ngày │
├────────────────────────────────────────────────────────┤
│ T4. CHỐNG TRÙNG: Chặn trùng thiết bị trong vòng 30 phút│
├────────────────────────────────────────────────────────┤
│ T5. KIỂM DUYỆT: Kỹ thuật viên soát xét mức ưu tiên     │
├────────────────────────────────────────────────────────┤
│ T6. NHẬT KÝ: Ghi vết địa chỉ IP, tài khoản và vi phạm  │
└────────────────────────────────────────────────────────┘
```

Trạng thái kỹ thuật từng tầng:
- T1 (Đã kích hoạt): Nginx `ticket_zone` áp dụng cho mọi đường nộp phiếu (`nginx/conf.d/default.conf`).
- T2 (Có sẵn): Bắt buộc xác thực tài khoản DLU, không mở nộp phiếu ẩn danh.
- T3 (Đã kích hoạt qua plugin): Plugin `pinedesk` chặn trần 5 phiếu mở và 10 phiếu/ngày (`plugins/pinedesk/hook.php`).
- T4 (Đã kích hoạt qua plugin): Plugin `pinedesk` chặn trùng lặp thiết bị trong 30 phút.
- T5 (Quy trình vận hành): Kỹ thuật viên kiểm tra nội dung và xác nhận lại mức độ khẩn cấp trước khi giao việc.
- T6 (Đã kích hoạt qua plugin): Bảng nhật ký `glpi_plugin_pinedesk_ticketlog` ghi nhận mọi lượt gửi và các lần bị chặn.

### 4.2. Tầng T1: Giới hạn tần suất mạng tại Nginx và bài toán NAT phòng máy

Trong cấu hình Nginx:

```nginx
limit_req_zone $binary_remote_addr zone=ticket_zone:10m rate=30r/m;

location ~* ^/Form/(SubmitAnswers|ValidateAnswers)(/|$) {
    limit_req zone=ticket_zone burst=10 nodelay;
    limit_req_status 429;
    proxy_pass http://glpi:80;
}
```

Căn cứ chọn ngưỡng 30 request/phút:
Khuôn viên trường sử dụng mạng NAT: toàn bộ 35 đến 40 máy trong một phòng thực hành chia sẻ chung một địa chỉ IP ra bên ngoài. Nếu đặt ngưỡng IP quá khắt khe (ví dụ 5 request/phút), các sinh viên nộp phiếu cùng thời điểm trong một lớp học sẽ bị chặn nhầm mã lỗi HTTP 429. Do đó, tầng mạng đặt ngưỡng 30 request/phút kèm `burst=10 nodelay` nhằm lọc bot tự động, còn việc kiểm soát chặt chẽ từng cá nhân được chuyển giao cho tầng nghiệp vụ T3 theo tài khoản.

### 4.3. Tầng T3 và T4: Kiểm soát hạn mức tài khoản qua plugin pinedesk

Plugin `pinedesk` đăng ký hook `PRE_ITEM_ADD` của GLPI, can thiệp trước khi bản ghi phiếu được thêm vào cơ sở dữ liệu:
- Kiểm tra T3a (Trần phiếu đang mở): Đếm số phiếu chưa đóng của tài khoản (`v_pinedesk_phieu_dang_mo`). Nếu đạt ngưỡng 5 phiếu, hệ thống từ chối tạo phiếu và gửi thông báo tiếng Việt yêu cầu chờ xử lý các phiếu cũ.
- Kiểm tra T3b (Trần phiếu theo ngày): Đếm số phiếu tạo trong ngày của tài khoản. Nếu chạm ngưỡng 10 phiếu, hệ thống từ chối yêu cầu tiếp theo.
- Kiểm tra T4 (Chống phiếu trùng): Nếu cùng tài khoản nộp phiếu cho cùng một thiết bị trong vòng 30 phút mà phiếu cũ chưa đóng, hệ thống chặn phiếu mới và thông báo mã phiếu cũ đang được xử lý.
- An toàn đồng thời: Sử dụng hàm `GET_LOCK('pinedesk_user_' . $users_id, 5)` của MariaDB để ngăn chặn tình trạng người dùng mở nhiều tab trình duyệt và bấm nộp cùng lúc (race condition).
- Khả năng chịu lỗi: Nếu truy vấn đếm gặp lỗi cơ sở dữ liệu, plugin ghi log vào `pinedesk.log` và tạm thời cho phép phiếu đi qua nhằm tránh chặn nhầm người dùng hợp lệ.

Hệ thống kiểm thử tự động tại `plugins/pinedesk/tests/kiem-thu-han-muc.php` bao gồm 37 điểm kiểm thử xác nhận đầy đủ hành vi chặn hạn mức, chống trùng và quyền miễn trừ cho kỹ thuật viên.

Lệnh rà soát định kỳ qua terminal:

```bash
bash scripts/kiem-tra-lam-dung.sh              # Kiểm tra và in báo cáo vi phạm
bash scripts/kiem-tra-lam-dung.sh --thuc-thi   # Ghi nhận vi phạm vào bảng nhật ký
```

### 4.4. Tầng T6: Bảng dữ liệu nhật ký theo dõi

Bảng `glpi_plugin_pinedesk_ticketlog` lưu trữ:
- `users_id`: Mã tài khoản người gửi.
- `tickets_id`: Mã phiếu tạo thành công (nếu có).
- `ip_address`: Địa chỉ IP kết nối thực tế (chuẩn hóa qua header proxy Nginx).
- `tickets_id_dup`: Mã phiếu trùng lặp liên quan (khi bị chặn trùng).
- `reason`: Trạng thái xử lý (`NEW`, `LIMIT_BLOCKED`, `DUP_BLOCKED`).
- `date_creation`: Dấu thời gian thực hiện.

Việc tách riêng bảng nhật ký giúp tốc độ truy vấn đếm hạn mức luôn ổn định và không làm chậm bảng lịch sử chung của GLPI.

### 4.5. Tầng T5: Quy trình soát xét mức ưu tiên và cấu hình SLA

Khi người dùng tạo phiếu, mức độ ưu tiên chỉ mang tính chất đề xuất. Khi phiếu vào hàng đợi ở trạng thái Mới, kỹ thuật viên kiểm tra nội dung và xác nhận lại mức độ ưu tiên thực tế trước khi chuyển sang trạng thái Được giao.

Cấu hình 5 mức SLA kỹ thuật trong bảng `glpi_slas`:

| Mức ưu tiên | Hạn phản hồi (TTO) | Hạn giải quyết (TTR) | Đối tượng áp dụng |
|---|---|---|---|
| Rất thấp (P1) | 8 giờ | 48 giờ | Sự cố đơn lẻ, không gấp |
| Thấp (P2) | 4 giờ | 24 giờ | Ảnh hưởng cục bộ một cá nhân |
| Trung bình (P3) | 2 giờ | 8 giờ | Ảnh hưởng thiết bị phòng thực hành |
| Cao (P4) | 1 giờ | 4 giờ | Sự cố thiết bị mạng hoặc phòng máy lớn |
| Rất cao (P5) | 30 phút | 2 giờ | Hạ tầng máy chủ, hệ thống mạng trung tâm |

Lưu ý: Các mốc thời gian trên là tham số kỹ thuật được cấu hình làm mẫu trong đồ án. Khi đưa vào vận hành chính thức, các chỉ số này cần được điều chỉnh theo quy định do nhà trường ban hành.

---

## 5. Tùy biến giao diện nhận diện DLU và quy trình Việt hóa

### 5.1. Bảng màu thương hiệu Đại học Đà Lạt

Trích xuất trực tiếp từ biểu trưng chính thức của Trường Đại học Đà Lạt:

| Mã màu | Tên gọi | Ứng dụng trong giao diện |
|---|---|---|
| `#F08418` | Cam đất | Vòng hoa văn, mặt trời, nút thao tác chính |
| `#607824` | Xanh rêu | Màu thương hiệu chủ đạo, tiêu đề và dải nhận diện |
| `#90B43C` | Xanh lá | Sườn núi sáng |
| `#C0CC84` | Xanh nhạt | Đồi thông |
| `#CC2430` | Đỏ | Ngôi sao |
| `#3D4E17` | Xanh rêu đậm | Thanh menu điều hướng chính (tăng độ tương phản) |
| `#3E8E9E` | Xanh hồ | Gợi màu nước hồ Xuân Hương (bảng màu sương mù) |

### 5.2. Kiến trúc giao diện và nguồn màu duy nhất

GLPI 11 phân tách giao diện thành hai tầng:
1. Tầng bảng màu (Palette): Các tệp `.scss` trong thư mục `themes/` đóng vai trò đăng ký tên bảng màu để hiển thị trong menu "Thiết lập của tôi > Giao diện".
2. Tầng ghi đè giao diện: Plugin `dlubrand` đăng ký hook `ADD_CSS` và `ADD_CSS_ANONYMOUS_PAGE`, nạp tệp `plugins/dlubrand/public/css/dlu-theme.css` trên toàn bộ các trang (kể cả trang đăng nhập khi chưa khởi tạo phiên).

Toàn bộ mã màu giao diện được quản lý tại nguồn duy nhất `plugins/dlubrand/public/css/dlu-theme.css`, còn các tệp `.scss` trong `themes/` chỉ là các tệp khai báo danh mục rỗng mã màu.

Cấu trúc bộ chọn CSS hỗ trợ đa theme:

```css
/* Bảng màu mặc định dùng :root; các biến thể lọc theo giá trị cụ thể */
:root                                 { --dlu-primary: #607824; /* da_lat: xanh rêu */ }
:root[data-glpi-theme="da_lat_suong"] { --dlu-primary: #3E8E9E; /* xanh hồ */ }
:root[data-glpi-theme="da_lat_nang"]  { --dlu-primary: #F08418; /* cam đất */ }

/* Khối gán biến chung cho các thành phần GLPI */
:root[data-glpi-theme] {
    --tblr-primary: var(--dlu-primary);
    --glpi-mainmenu-bg: var(--dlu-primary-dark);
}
```

### 5.3. Mức độ phủ tiếng Việt và giải pháp khóa dịch số nhiều

Đo lường trực tiếp qua `scripts/do-do-phu-tieng-viet.py` từ tệp `.mo` trong container GLPI:
- Tổng số chuỗi giao diện: 6.511 chuỗi.
- Đã dịch: 2.084 chuỗi (đạt tỉ lệ 32,0%).
- Chưa dịch: 4.427 chuỗi (tập trung 65,3% ở các thông báo kỹ thuật sâu và cảnh báo hệ thống).

Hệ thống đã Việt hóa toàn bộ 9 thẻ đếm trạng thái tại trang Hỗ trợ: `Phiếu mới tiếp nhận`, `Phiếu đang chờ`, `Phiếu đã phân công`, `Phiếu đã lên kế hoạch`, `Phiếu đã giải quyết`, `Phiếu đã đóng`, `Phiếu quá hạn`, cùng hai biểu đồ `Phiếu theo tháng` và `Tình trạng phiếu theo tháng`.

Giải pháp xử lý cạm bẫy thư viện `laminas-i18n` và khóa dịch số nhiều `_n()`:
1. Thư viện `laminas-i18n` của GLPI thay thế toàn bộ catalog khi gặp cùng domain và locale thay vì gộp thêm. Do đó, script `scripts/gop-ban-dich-tieng-viet.py` trích xuất toàn bộ chuỗi từ bản dịch gốc, gộp lớp phủ bổ sung rồi mới biên dịch thành tệp MO hoàn chỉnh.
2. Dạng số ít `__('Ticket')` sử dụng khóa `msgid`. Dạng số nhiều `_n('Ticket', 'Tickets', 13)` sử dụng hàm `translatePlural()`, lưu trữ dưới khóa ghép chứa ký tự phân cách `\0` (ví dụ `"Ticket\0Tickets"`). Bản dịch gốc của GLPI chưa dịch các mục này. Script gộp đã bổ sung bảng `BAN_DICH_SO_NHIEU` (212 mục) và chèn trực tiếp các chuỗi dịch tương ứng vào các khóa chứa ký tự `\0`.

Việt hóa dữ liệu cơ sở dữ liệu:
Các chuỗi lưu trong CSDL như tên hồ sơ quyền (`Super-Admin`, `Technician`, `Self-Service`), tên bảng điều khiển (`Central`, `Assets`), tên đơn vị gốc (`Root entity`) được chuyển đổi sang tiếng Việt bằng script `scripts/viet-hoa-du-lieu.sh`.

---

## 6. Quản lý tài sản và tạo mã QR thiết bị

### 6.1. Quy trình in nhãn mã QR qua plugin Barcode

Plugin Barcode 2.7.1 hỗ trợ sinh mã QR và mã vạch cho máy tính và thiết bị mạng. Khi quét mã, hệ thống mở trực tiếp hồ sơ thiết bị (vị trí, cấu hình, phần mềm, lịch sử sửa chữa).

Ba bản vá tương thích trên GLPI 11 (được tự động hóa trong `scripts/cai-plugin-qrcode.sh`):
1. `setup.php`: Nâng hằng số giới hạn `PLUGIN_BARCODE_MAX_GLPI = '99.0.99'` để vượt qua kiểm tra phiên bản.
2. Tải bản phát hành chính thức định dạng `.tar.bz2` đã đóng gói sẵn thư mục `vendor/` chứa thư viện `deltalab/phpqrcode` và `rospdf/pdf-php`.
3. Chuyển đổi toàn bộ `$DB->query(` thành `$DB->doQuery(` trong `hook.php` (9 vị trí) do GLPI 11 cấm thực thi truy vấn trực tiếp.

Thao tác in nhãn hàng loạt:
1. Điều hướng đến **Tài sản > Các máy tính**.
2. Tích chọn các thiết bị cần in nhãn.
3. Nhấp nút **Các hành động** tại góc trên bên trái, chọn **Barcode - Print QRcodes**.
4. Chọn khổ giấy A4, hướng in, thông tin hiển thị (Mã tài sản, Tên máy) và nhấp **Create**.
5. Nhấp liên kết tải tệp PDF chứa danh sách mã QR.

Cấu hình nền tảng bắt buộc:
- Cấp quyền `plugin_barcode_barcode` và `plugin_barcode_config` cho hồ sơ quản trị.
- Khởi tạo thư mục lưu trữ `/var/glpi/files/_plugins/barcode/` và cấp quyền cho người dùng `www-data`.
- Kích hoạt extension PHP `bcmath` và `gd`.

### 6.2. Phương án dự phòng bằng mã nguồn Python

Hệ thống xây dựng giải pháp dự phòng độc lập tại `scripts/sinh-ma-qr.py`:

```bash
python scripts/sinh-ma-qr.py
```

Ưu điểm phương án dự phòng: Kết nối trực tiếp vào cơ sở dữ liệu hoặc API REST của GLPI để lấy danh sách máy tính, tự động kết xuất ảnh mã QR và tạo tệp nhãn in hoàn chỉnh độc lập với chu kỳ nâng cấp của GLPI, cho phép tùy biến bố cục nhãn có logo Đại học Đà Lạt.

---

## 7. Hướng dẫn triển khai, vận hành và an toàn thông tin

### 7.1. Cài đặt toàn bộ bằng một lệnh

```bash
# 1. Di chuyển vào thư mục dự án và khởi tạo file cấu hình
cd <DUONG-DAN-DU-AN>/pinedesk
cp .env.example .env

# 2. Đổi mật khẩu trong .env
notepad .env

# 3. Khởi chạy cài đặt tự động
bash scripts/cai-dat-tat-ca.sh
```

Script thực hiện: Khởi động 4 container, nạp danh mục đơn vị DLU, kích hoạt plugin (Barcode, giao diện DLU, hạn mức pinedesk), gộp bản dịch tiếng Việt, nạp cấu hình SLA và chống lạm dụng, kiểm tra sức khỏe hệ thống.

### 7.2. Cấu hình chứng chỉ SSL với Subject Alternative Name (SAN)

Trình duyệt hiện đại bắt buộc chứng chỉ phải có trường Subject Alternative Name (SAN). Cấu hình tại `nginx/ssl/openssl-san.cnf`:

```ini
[ san ]
DNS.1 = localhost
DNS.2 = pinedesk.local
DNS.3 = *.localhost
IP.1  = 127.0.0.1
IP.2  = ::1
```

Script `start.sh` tự động đọc tệp trên để tạo chứng chỉ `nginx/ssl/glpi.crt`. Lệnh kiểm tra:

```bash
openssl x509 -in nginx/ssl/glpi.crt -noout -text | grep -A1 "Subject Alternative Name"
```

Khi triển khai tên miền thực tế (ví dụ `pinedesk.dlu.edu.vn`), cập nhật tên miền vào `[ san ]` của `openssl-san.cnf` và thông số `server_name` trong `nginx/conf.d/default.conf`, sau đó xóa chứng chỉ cũ và chạy lại `bash start.sh`.

### 7.3. Quy trình sao lưu và phục hồi dữ liệu

Lệnh thực hiện sao lưu:

```bash
bash backup/backup.sh
```

Tạo ra 3 tệp trong thư mục `backup/`:
- `*_db.sql`: Bản sao lưu toàn bộ cơ sở dữ liệu MariaDB.
- `*_files.tar.gz`: Tệp cấu hình, khóa giải mã `glpicrypt.key`, tệp đính kèm và plugin (`/var/glpi/*` và `/var/www/glpi/plugins`).
- `*_config.tar.gz`: Cấu hình Docker, Nginx, theme và các script quản trị.

Quy trình phục hồi:

```bash
# 1. Khởi động container
bash start.sh

# 2. Phục hồi cơ sở dữ liệu
#    Mật khẩu KHÔNG đi qua tham số dòng lệnh (tránh lộ trong `ps`).
#    Shell BÊN TRONG container tự đọc $MARIADB_ROOT_PASSWORD của chính nó
#    rồi gán cho MYSQL_PWD của tiến trình con.
docker exec -i pinedesk-db sh -c \
  'MYSQL_PWD="$MARIADB_ROOT_PASSWORD" mariadb -u root "$1"' \
  _ glpi < backup/glpi_backup_YYYYMMDD_HHMMSS_db.sql

# 3. Phục hồi tệp hệ thống và khóa mã hóa glpicrypt.key
docker run --rm --volumes-from pinedesk-glpi -v "$(pwd -W)/backup:/backup" alpine:latest tar xzf /backup/glpi_backup_YYYYMMDD_HHMMSS_files.tar.gz -C /

# 4. Khởi động lại ứng dụng
docker compose restart glpi
```

### 7.4. Xử lý các sự cố thường gặp

- Cổng 8443 bị chiếm: Thay đổi `HTTPS_PORT` trong `.env` thành cổng khác (ví dụ `9443`), sau đó chạy `docker compose up -d nginx` và cập nhật cấu hình GLPI: `docker exec -u www-data pinedesk-glpi php /var/www/glpi/bin/console config:set url_base "https://localhost:9443" --no-interaction`.
- Mất kết nối DB sau khi đổi cấu hình mạng: Chạy `docker compose down && docker compose up -d` để Docker đăng ký lại alias dịch vụ.
- Lỗi 400 Bad Request: Do `session.cookie_secure = On` trong `config/php-custom.ini`. Luôn truy cập qua cổng HTTPS của Nginx (`https://localhost:8443`) để Apache nhận header `X-Forwarded-Proto: https`.

### 7.5. Chính sách an toàn thông tin

- Bắt buộc giao thức TLS 1.2 và 1.3, tự động chuyển hướng HTTP sang HTTPS.
- Giới hạn tần suất đăng nhập 10 request/phút mỗi IP chống brute-force.
- Cookie phiên thiết lập cờ `HttpOnly`, `SameSite=Strict` và `Secure`.
- Gateway Nginx chặn truy cập trực tiếp các tệp nhạy cảm (`.env`, `.sql`, `.log`, `.git`, `.sh`).
- Ẩn thông tin phiên bản phần mềm (`expose_php = Off`).
- Dịch vụ cơ sở dữ liệu MariaDB và Redis cô lập hoàn toàn trong mạng nội bộ Docker (`internal: true`).

---

## 8. Kịch bản trình diễn bảo vệ đồ án (7 phút)

### 8.1. Checklist chuẩn bị trước 30 phút

Thực thi chuẩn bị:

```bash
docker compose up -d
bash scripts/nap-du-lieu-mau.sh
bash scripts/nap-sla-va-chong-lam-dung.sh
```

Kiểm tra:
- Mở `https://localhost:8443`, đăng nhập thành công bằng tài khoản `glpi`.
- Mở sẵn 4 tab: Bảng điều khiển, Danh sách phiếu, Slide bảo vệ (`tai-lieu/slide-bao-ve.html`), Báo cáo tổng hợp.
- Tắt thông báo hệ thống và ứng dụng nhắn tin trên máy tính.
- Chuẩn bị sẵn thư mục `tai-lieu/anh-giao-dien/` làm phương án dự phòng khi máy chiếu hoặc Docker gặp sự cố.

### 8.2. Phân bổ thời lượng chi tiết

| Thời lượng | Nội dung thao tác và thuyết minh | Màn hình hiển thị |
|---|---|---|
| Phút 0:00 - 1:30 | Đặt vấn đề: 5 nhân sự ITC, 14.500+ người học, 73% thời gian tuần ngoài giờ không có kênh tiếp nhận trực tiếp. PineDesk mở kênh tự phục vụ 24/7 có cấu trúc. | Slide tổng quan chỉ số |
| Phút 1:30 - 2:30 | Trình diễn hệ thống thực tế: Đăng nhập giao diện tiếng Việt bảng màu Đà Lạt, kết nối HTTPS với chứng chỉ SAN, kiến trúc 4 container triển khai 1 lệnh. | Trang đăng nhập hệ thống |
| Phút 2:30 - 4:00 | Nghiệp vụ nộp phiếu và chống spam: Đăng nhập sinh viên `sv.hoa` nộp phiếu tự phục vụ; chạy `bash scripts/kiem-tra-lam-dung.sh`; giải thích NAT phòng máy và trần 5 phiếu mở; thử gửi phiếu thứ 6 bị chặn kèm thông báo tiếng Việt; chứng minh HTTP 429 khi gửi dồn dập. | Giao diện sinh viên, terminal |
| Phút 4:00 - 5:30 | Vòng đời phiếu và SLA: Đăng nhập `glpi`, mở danh sách 13 phiếu mẫu trải đủ 4 trạng thái; trình diễn 5 mức SLA kỹ thuật (P1 đến P5); lọc phiếu quá hạn phản hồi. Nhấn mạnh SLA là tham số kỹ thuật mẫu đề xuất. | Bảng danh sách phiếu, SLA |
| Phút 5:30 - 6:30 | Quản lý thiết bị và mã QR: Mở máy `TDL-PC-A101-001`, trình chiếu mã QR trên hồ sơ máy; giải thích quy chuẩn mã tài sản TDL; nêu bản vá cho plugin Barcode và script Python dự phòng. | Hồ sơ máy tính |
| Phút 6:30 - 7:00 | Kiến trúc ngoài lõi và kết luận: Toàn bộ tùy biến nằm ngoài `src/` GLPI; pipeline CI kiểm thử tự động; thừa nhận đồ án là giải pháp kỹ thuật đề xuất, bước tiếp theo là khảo sát thực địa tại ITC. | Sơ đồ hệ thống, slide cuối |

---

## 9. Bộ 25 câu hỏi phản biện và định hướng trả lời

### Nhóm A: Bài toán và nhu cầu thực tế

**A1. "Đồ án này giải quyết nhu cầu gì của trường?"**
- Trả lời: Trung tâm CNTT (ITC) có 5 nhân sự phục vụ hơn 14.500 người học, kênh tiếp nhận hotline chỉ mở 7h30 đến 16h30 từ thứ 2 đến thứ 6 (khoảng 73% thời gian tuần không có kênh tiếp nhận trực tiếp). PineDesk mở kênh tự phục vụ 24/7 có cấu trúc, tự động phân công và theo dõi tiến độ theo chuẩn ITIL.
- Minh chứng: Mục 1 tài liệu này; nguồn `itc.dlu.edu.vn` (5 nhân sự) và `dlu.edu.vn` (14.500+).

**A2. "Thực tế trường đang tiếp nhận sự cố bằng cách nào?"**
- Trả lời: Theo thông tin công bố chính thức, ITC có một hotline, một email và một biểu mẫu liên hệ tĩnh, chưa công bố hệ thống ticket có phân công, trạng thái và SLA. Đây là các kênh phi cấu trúc, dễ thất lạc và khó đo lường thời gian xử lý.
- Minh chứng: Nguồn `itc.dlu.edu.vn/lien-he/`.

**A3. "Ai là người dùng thật? Sinh viên có dùng không?"**
- Trả lời: Ba nhóm đối tượng: Sinh viên báo sự cố phòng máy qua cổng Self-Service; Giảng viên báo sự cố giảng đường và yêu cầu mượn thiết bị; Kỹ thuật viên ITC và lãnh đạo tiếp nhận việc, xử lý và xem thống kê. Đồ án thiết lập 6 tài khoản mẫu cho 3 vai trò để kiểm chứng.
- Minh chứng: `scripts/seed-du-lieu-mau.sql`.

**A4. "Em đã trao đổi với ITC chưa? Họ có cần hệ thống này không?"**
- Trả lời thẳng thắn: Dạ chưa. Đồ án chưa được ITC phê duyệt chính thức. Em thu thập thông tin từ cổng công khai của trường để đề xuất giải pháp kỹ thuật khả thi, bước tiếp theo là khảo sát thực địa tại trung tâm.

**A5. "Nhu cầu này có thật không hay em tự nghĩ ra?"**
- Trả lời: Các dữ kiện về 14.500+ người học, 5 nhân sự, hotline và giờ làm việc đều là số liệu công khai có nguồn kiểm chứng rõ ràng. Phần suy luận kỹ thuật và các điểm giả định được phân định minh bạch trong tài liệu.

### Nhóm B: Cơ chế chống lạm dụng và spam

**B1. "Sinh viên spam nộp phiếu liên tục thì sao?"**
- Trả lời: Hệ thống áp dụng 6 tầng phòng thủ. Tầng mạng giới hạn 30 request/phút theo IP; tầng nghiệp vụ giới hạn tối đa 5 phiếu mở và 10 phiếu/ngày cho mỗi tài khoản; chặn phiếu trùng cùng thiết bị trong 30 phút; ghi nhật ký mọi lượt gửi vào bảng riêng. Trình diễn thực tế: Gửi dồn dập nhận HTTP 429; gửi phiếu thứ 6 bị chặn kèm thông báo tiếng Việt.
- Minh chứng: Mục 4 tài liệu này, `nginx/conf.d/default.conf`, `plugins/pinedesk/hook.php`.

**B2. "Tại sao rate limit đặt theo IP mà không theo tài khoản?"**
- Trả lời: Do khuôn viên trường sử dụng mạng NAT, cả phòng máy 35-40 sinh viên chia sẻ chung một địa chỉ IP ra ngoài. Nếu đặt giới hạn IP quá khắt khe, cả lớp học sẽ bị chặn nhầm. Do đó tầng mạng đặt ngưỡng 30 request/phút để lọc bot, còn kiểm soát chặt chẽ được chuyển giao cho tầng nghiệp vụ theo từng tài khoản.

**B3. "Nếu sinh viên nộp trùng cùng một sự cố nhiều lần?"**
- Trả lời: Plugin `pinedesk` kiểm tra trước khi ghi dữ liệu. Nếu cùng tài khoản nộp phiếu cho cùng thiết bị trong vòng 30 phút mà phiếu cũ chưa đóng, phiếu mới bị từ chối và hệ thống dẫn người dùng tới mã phiếu đã tạo trước đó.
- Minh chứng: `plugins/pinedesk/hook.php` (T4) và kịch bản kiểm thử `kiem-thu-han-muc.php`.

**B4. "Nếu kẻ xấu dùng bot nộp hàng loạt?"**
- Trả lời: Bot phải vượt qua bước đăng nhập vốn bị giới hạn 10 request/phút mỗi IP với mã lỗi 429. Mọi cổng nộp phiếu đều nằm trong vùng đệm 30 request/phút của Nginx. Kể cả qua được tầng mạng, bot vẫn bị chặn bởi trần phiếu tài khoản và khóa chống trùng lặp.

**B5. "Cơ chế này em đã kiểm thử tự động chưa?"**
- Trả lời: Đã xây dựng bộ kiểm thử tự động gồm 37 điểm kiểm thử tại `plugins/pinedesk/tests/kiem-thu-han-muc.php`, tích hợp vào pipeline CI để xác nhận hành vi trả mã 429, chặn vượt trần, chặn trùng lặp và quyền miễn trừ cho kỹ thuật viên.

### Nhóm C: Quy trình nghiệp vụ và cam kết thời gian (SLA)

**C1. "Quy trình xử lý phiếu từ lúc tiếp nhận đến lúc đóng diễn ra thế nào?"**
- Trả lời: Tuân thủ chuẩn ITIL qua các trạng thái: Mới (1) > Được giao (2) > Đang chờ (3) / Đã lên kế hoạch (4) > Đã giải quyết (5) > Đã đóng (6). Mỗi phiếu gắn với người yêu cầu, kỹ thuật viên phụ trách, thiết bị liên quan và tiến trình xử lý.
- Minh chứng: 13 phiếu mẫu trong `scripts/seed-du-lieu-mau.sql`.

**C2. "Mức ưu tiên do ai quyết định? Sinh viên tự chọn Rất cao hết thì sao?"**
- Trả lời: Mức ưu tiên khi sinh viên tạo phiếu chỉ là đề xuất ban đầu. Khi phiếu vào hàng đợi ở trạng thái Mới, kỹ thuật viên kiểm tra nội dung và xác nhận lại mức độ ưu tiên thực tế trước khi chuyển giao xử lý.

**C3. "Chỉ số SLA là gì? Ai ban hành?"**
- Trả lời thẳng thắn: Các mốc SLA trong hệ thống (TTO từ 30 phút đến 8 giờ, TTR từ 2 giờ đến 48 giờ) là cấu hình kỹ thuật mẫu do đồ án thiết lập để chứng minh tính năng, chưa phải quy định chính thức do nhà trường ban hành.

**C4. "Phiếu đã đóng nhưng sinh viên phản ánh sự cố chưa xử lý xong thì sao?"**
- Trả lời: Hệ thống hỗ trợ tính năng mở lại phiếu (Reopen). GLPI lưu vết toàn bộ lịch sử trao đổi, sinh viên không cần tạo phiếu mới và hệ thống ghi nhận để đánh giá chất lượng xử lý của kỹ thuật viên.

**C5. "Kỹ thuật viên vắng mặt thì phiếu có bị tồn đọng không?"**
- Trả lời: Phiếu được điều phối theo nhóm kỹ thuật (theo khoa/phòng) trước khi phân công cá nhân. Khi một kỹ thuật viên vắng mặt, các thành viên khác trong nhóm vẫn tiếp nhận và xử lý bình thường.
- Minh chứng: Cây nhóm đơn vị trong `scripts/seed-du-lieu-nen.sql`.

### Nhóm D: So sánh và lựa chọn công nghệ

**D1. "Tại sao không dùng Google Forms và Excel cho nhanh?"**
- Trả lời: Google Forms chỉ hỗ trợ thu thập dữ liệu thô, không có cơ chế hàng đợi phân công, không có vòng đời trạng thái chuẩn ITIL, không theo dõi được thời hạn SLA, không liên kết được với hồ sơ vòng đời thiết bị và không hỗ trợ định danh mã QR vật lý.

**D2. "GLPI có sẵn mọi tính năng, vậy đóng góp của đồ án là gì?"**
- Trả lời: GLPI cung cấp lõi nghiệp vụ ITSM. Đóng góp của đồ án bao gồm: Cài đặt tự động một lệnh, cổng gateway HTTPS tích hợp SAN cert, bảng màu thương hiệu DLU và CSS ngoài lõi, nâng độ phủ dịch tiếng Việt lên 32,0% và xử lý lỗi khóa số nhiều `_n()`, nạp cơ cấu tổ chức 16 khoa và 54 phòng của DLU, cơ chế phòng thủ 6 tầng chống lạm dụng với 37 test cases, vá 3 lỗi tương thích cho plugin Barcode trên GLPI 11 và script Python dự phòng.
- Minh chứng: Bảng đối chiếu 20 dòng tại Mục 3.2.

**D3. "Tại sao không mua ServiceNow hoặc triển khai iTop?"**
- Trả lời: ServiceNow có chi phí bản quyền định kỳ rất cao, không phù hợp với ngân sách nội bộ của trường công lập. iTop đòi hỏi cấu hình và Việt hóa tương tự nhưng cộng đồng hỗ trợ nhỏ hơn. GLPI là giải pháp mã nguồn mở trưởng thành, tuân thủ ITIL và cho phép tự lưu trữ dữ liệu tại trường.

**D4. "Nếu GLPI nâng cấp phiên bản mới thì các tùy biến có bị mất không?"**
- Trả lời: Toàn bộ tùy biến nằm hoàn toàn ngoài mã nguồn cốt lõi GLPI (thư mục `src/`), được tổ chức trong plugin riêng, tệp MO lớp phủ, cấu hình Nginx và các script ngoài container. Khi nâng cấp Docker image GLPI, toàn bộ tùy biến được giữ nguyên.

**D5. "Làm thế nào để chứng minh đồ án không can thiệp vào lõi GLPI?"**
- Trả lời: Toàn bộ mã nguồn dự án được quản lý trong kho lưu trữ Git và không chứa bất kỳ tệp nào thuộc đường dẫn `src/` của GLPI. GLPI chạy nguyên bản từ image Docker chính thức của nhà phát hành.

### Nhóm E: Bảo mật, vận hành và câu hỏi mở rộng

**E1. "Mật khẩu quản trị có bị lộ trong mã nguồn không?"**
- Trả lời: Mật khẩu không lưu trong mã nguồn mà đọc từ biến môi trường `.env` (được đưa vào `.gitignore`). Hệ thống tích hợp script `scripts/quet-bi-mat.sh` trong pipeline CI để quét và ngăn chặn lộ lọt bí mật.

**E2. "Trình duyệt chặn chứng chỉ SSL tự ký thì xử lý thế nào?"**
- Trả lời: Chứng chỉ tự ký được tạo với đầy đủ Subject Alternative Name (SAN) cho `localhost`, `127.0.0.1` và `pinedesk.local`. Trình duyệt cho phép thêm ngoại lệ để truy cập bình thường. Khi triển khai chính thức, hệ thống sẽ sử dụng chứng chỉ Let's Encrypt hoặc chứng chỉ số của trường.

**E3. "Nếu mất kết nối Internet tại hội trường thì có trình diễn được không?"**
- Trả lời: Hoàn toàn trình diễn được. Hệ thống chạy trên mạng nội bộ Docker, font chữ và các tệp hỗ trợ được lưu trữ ngoại tuyến cục bộ, không phụ thuộc vào CDN bên ngoài.

**E4. "Hệ thống chịu tải được bao nhiêu sinh viên truy cập đồng thời?"**
- Trả lời thẳng thắn: Em chưa thực hiện đo tải thực tế nên không khẳng định con số cụ thể. Kiến trúc hiện tại sử dụng Nginx đệm và Redis cache để tối ưu hóa, nhưng để phục vụ hàng nghìn kết nối đồng thời trong các đợt cao điểm thi, cần tiến hành kiểm thử tải và cân nhắc phân tách máy chủ cơ sở dữ liệu riêng.

**E5. "Sau khi sinh viên tốt nghiệp thì ai sẽ tiếp nhận bảo trì hệ thống?"**
- Trả lời: Đồ án giảm thiểu rủi ro bàn giao bằng cách cung cấp bộ tài liệu tổng hợp đầy đủ tại `tai-lieu/README.md`, kịch bản cài đặt tự động một lệnh, pipeline CI kiểm tra tự động và kiến trúc tùy biến 100% ngoài lõi giúp người tiếp nhận dễ dàng vận hành lại hệ thống.

---

## 10. Phụ lục lệnh thao tác nhanh

```bash
# 1. Khởi động và cài đặt toàn bộ
bash start.sh
bash scripts/cai-dat-tat-ca.sh

# 2. Quản lý dữ liệu danh mục và mẫu
bash scripts/nap-du-lieu-nen.sh
bash scripts/nap-du-lieu-mau.sh
bash scripts/viet-hoa-du-lieu.sh

# 3. Giao diện, bản dịch và mã QR
bash scripts/cai-giao-dien.sh
python scripts/tao-mo-bo-sung.py
python scripts/gop-ban-dich-tieng-viet.py
bash scripts/cai-plugin-qrcode.sh
python scripts/sinh-ma-qr.py

# 4. Kiểm thử và sao lưu
bash scripts/kiem-tra-lam-dung.sh
docker exec pinedesk-glpi php /var/www/glpi/plugins/pinedesk/tests/kiem-thu-han-muc.php
bash scripts/quet-bi-mat.sh
bash backup/backup.sh
```
