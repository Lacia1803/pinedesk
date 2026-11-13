# BẢNG PHÂN CÔNG NHIỆM VỤ ĐỀ TÀI THỰC TẬP TỐT NGHIỆP

**Đề tài:** Xây dựng hệ thống hỗ trợ kỹ thuật (IT Helpdesk) — Hệ thống **PineDesk**  
**Đơn vị thực tập:** Trung tâm Công nghệ Thông tin — Trường Đại học Đà Lạt  
**Thời gian thực hiện:** Học kỳ 1 Năm học 2026 – 2027 (10 tuần: từ 10/08/2026 đến 17/10/2026)  
**Giảng viên hướng dẫn tại Khoa:** ThS. La Quốc Thắng  
**Cán bộ hướng dẫn tại Trung tâm CNTT:** ThS. La Quốc Thắng & ThS. Đặng Quốc Phi  

---

## 1. Danh sách Thành viên Nhóm thực tập (Nhóm 4 - ITC)

Căn cứ theo *Danh sách thực tập Trung tâm CNTT Năm học 2026 – 2027*:

| STT | Họ và tên | Mã số SV | Lớp | Số điện thoại | Email trường (@dlu.edu.vn) | Vai trò trong nhóm |
|:---:|---|:---:|:---:|:---:|---|---|
| 1 | **Phùng Võ Quốc Hiển** | 2212364 | CTK46-PM | 0964.504.905 | `2212364@dlu.edu.vn` | **Nhóm trưởng** — Phụ trách kiến trúc hệ thống, bảo mật lõi, kiểm thử tự động & tích hợp |
| 2 | **Lý Gia Bảo** | 2213934 | CTK46 | 0327.055.354 | `2213934@dlu.edu.vn` | **Thành viên** — Phụ trách khảo sát hạ tầng thiết bị, giao diện bản sắc (UI/UX) & mã QR |
| 3 | **Nguyễn Việt Bình** | 2213831 | CTK46 | 0355.250.338 | `2213831@dlu.edu.vn` | **Thành viên** — Phụ trách phân tích quy trình nghiệp vụ, chuẩn hóa ITIL/SLA & tài liệu vận hành |

---

## 2. Ma trận Phân công Trách nhiệm và Tệp nguồn Phụ trách

Hệ thống mã nguồn PineDesk được tổ chức rõ ràng theo kiến trúc module. Từng thành viên chịu trách nhiệm chính về các phân hệ và tệp nguồn tương ứng:

```
PINEDESK REPOSITORY
├── Kiến trúc & Bảo mật (Hiển) ─── docker-compose.yml, nginx/, plugins/pinedesk/, CI/CD
├── Giao diện & Thiết bị (Bảo) ─── plugins/dlubrand/, scripts/sinh-ma-qr.py, Dữ liệu 10 phòng máy
└── Nghiệp vụ & ITIL (Bình) ────── Danh mục tòa nhà/khoa, 79 loại sự cố, 5 mức SLA, Quy trình
```

### Chi tiết phân công theo từng thành viên:

```
┌──────────────────────────────────────────────────────────────────────────────┐
│ 1. PHÙNG VÕ QUỐC HIỂN (Nhóm trưởng / Kỹ thuật & Bảo mật)                    │
├──────────────────────────────────────────────────────────────────────────────┤
│ Nhiệm vụ chính:                                                              │
│ - Thiết kế kiến trúc phân vùng 4 container Docker (Nginx Gateway, GLPI 11,    │
│   MariaDB 10.11 LTS, Redis 7).                                               │
│ - Cấu hình an toàn Nginx: SSL/TLS có SAN, giới hạn tần suất (rate limit),    │
│   bộ đệm chống tấn công Slowloris, 9 tiêu đề HTTP an toàn.                   │
│ - Phát triển lớp bảo mật phòng thủ chiều sâu 6 tầng ngoài lõi GLPI:         │
│   + T1: Nginx Gateway (30 req/phút, lọc method, chặn tệp nhạy cảm).          │
│   + T2: Xác thực email trường DLU (@dlu.edu.vn) qua hook PRE_ITEM_ADD.        │
│   + T3: Hạn mức nghiệp vụ (trần 5 phiếu mở, 10 phiếu/ngày mỗi tài khoản).    │
│   + T4: Chống nộp trùng bằng khóa phân tán MariaDB mutex GET_LOCK (3 giây). │
│   + T5: Tự động phát hiện ưu tiên cao/rất cao, tạo nhắc nhở nội bộ (System). │
│   + T6: Bảng nhật ký kiểm toán độc lập (glpi_plugin_pinedesk_ticketlog).     │
│ - Thiết lập phân quyền theo vai trò (Self-Service, Technician, Super-Admin).  │
│ - Xây dựng bộ công cụ kiểm thử tự động toàn diện:                            │
│   + Harness kiểm thử tích hợp CSDL 56 điểm kiểm (kiem-thu-han-muc.php).      │
│   + Kịch bản kiểm thử End-to-End Playwright 3 use case (kiem-tra-usecase.js).│
│   + Đo tải định lượng hệ thống bằng wrk (do-tai.sh).                         │
│   + Pipeline GitHub Actions CI 6 nhóm kiểm tra tự động.                     │
│ - Viết script cài đặt tự động một lệnh (cai-dat-tat-ca.sh).                  │
│                                                                              │
│ Tệp nguồn & tài liệu phụ trách trực tiếp:                                     │
│ - docker-compose.yml, nginx/nginx.conf, nginx/conf.d/default.conf           │
│ - plugins/pinedesk/hook.php, setup.php                                      │
│ - plugins/pinedesk/tests/kiem-thu-han-muc.php                                │
│ - scripts/kiem-tra-usecase.js, scripts/do-tai.sh, scripts/quet-bi-mat.sh      │
│ - .github/workflows/ci.yml, scripts/cai-dat-tat-ca.sh                        │
│ - tai-lieu/DO-TAI.md, tai-lieu/CAI-TIEN-CHAT-LUONG.md                        │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│ 2. LÝ GIA BẢO (Thành viên / Thiết bị, Giao diện & Mã QR)                     │
├──────────────────────────────────────────────────────────────────────────────┤
│ Nhiệm vụ chính:                                                              │
│ - Khảo sát thực địa thông số kỹ thuật 10 phòng thực hành máy tính tại ITC    │
│   (A24.1, A24 lầu, A8.3, A8.4, A8.5, A8.6, TV1, TV2, TV3, TV4).             │
│ - Số hóa dữ liệu phần cứng: 482 máy tính, 487 màn hình & Tivi thông minh,    │
│   3 máy in Canon LBP2900, 17 thiết bị mạng & tủ rack, 10 phần mềm đào tạo.   │
│ - Xây dựng quy chuẩn mã định danh tài sản chuẩn hóa (TDL-PC-A241-001...).    │
│ - Thiết kế hệ sinh thái giao diện nhận diện bản sắc Trường Đại học Đà Lạt:   │
│   + Kết hợp ngôn ngữ Apple Precision + Claude Warmth + Bản sắc Đà Lạt.       │
│   + Trích xuất bảng màu đặc trưng từ logo DLU (xanh rêu thông và cam đất).   │
│   + Phát triển plugin giao diện dlubrand và tệp CSS chủ đề dlu-theme.css.    │
│ - Nghiên cứu giải pháp quản lý tài sản bằng mã QR:                           │
│   + Khắc phục 3 lỗi tương thích phiên bản của plugin Barcode 2.7.1 trên     │
│     GLPI 11 (setup.php, vendor autoload, cú pháp $DB->doQuery()).            │
│   + Kiểm thử in mã QR trực tiếp từ hồ sơ thiết bị và in nhãn hàng loạt.      │
│   + Phát triển script Python dự phòng độc lập sinh nhãn QR (sinh-ma-qr.py).  │
│ - Chụp và quản lý hệ thống ảnh chụp màn hình minh chứng giao diện thực tế.   │
│                                                                              │
│ Tệp nguồn & tài liệu phụ trách trực tiếp:                                     │
│ - scripts/seed-du-lieu-mau.sql (khối dữ liệu 10 phòng máy & thiết bị)        │
│ - plugins/dlubrand/ (toàn bộ mã nguồn plugin giao diện, CSS và logo)        │
│ - themes/dlu-theme.scss, scripts/cai-giao-dien.sh                            │
│ - DESIGN.md (đặc tả hệ thống thiết kế giao diện)                             │
│ - scripts/sinh-ma-qr.py, requirements.txt                                    │
│ - scripts/chup-lai-anh-minh-chung.js, tai-lieu/anh-giao-dien/ (01 - 13)       │
│ - tai-lieu/SO-LIEU-THUC-TE-DLU.md (Mục 1 & Mục 2: thông số phần cứng ITC)   │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│ 3. NGUYỄN VIỆT BÌNH (Thành viên / Phân tích nghiệp vụ, Chuẩn ITIL & SLA)     │
├──────────────────────────────────────────────────────────────────────────────┤
│ Nhiệm vụ chính:                                                              │
│ - Khảo sát quy trình tiếp nhận và xử lý sự cố kỹ thuật hiện hành tại ITC.     │
│ - Phỏng vấn kỹ thuật viên ITC, giảng viên và sinh viên thực hành để xác định  │
│   khoảng trống nghiệp vụ và đúc kết 3 mâu thuẫn cốt lõi (M1, M2, M3).        │
│ - Xây dựng bộ danh mục nghiệp vụ trường học hoàn chỉnh:                      │
│   + 12 tòa nhà, 54 phòng chức năng, 16 khoa đào tạo, 10 phòng ban.           │
│   + Chuẩn hóa 79 danh mục sự cố 2 cấp theo khung thực hành chuẩn ITIL v4    │
│     (Phần cứng, Mạng & Kết nối, Phần mềm, Tài khoản & Dịch vụ số).           │
│ - Thiết kế chính sách cam kết thời gian xử lý dịch vụ (SLA):                 │
│   + 5 cấp độ ưu tiên kỹ thuật (P1 Khẩn cấp đến P5 Rất thấp).                 │
│   + Mốc thời gian phản hồi (TTO: 30p - 8h) và hoàn thành xử lý (TTR: 2h - 48h).│
│ - Cấu hình luồng nghiệp vụ bảo trì định kỳ và mượn trả thiết bị phòng máy:   │
│   + Lập lịch bảo trì định kỳ cho 10 phòng máy (glpi_ticketrecurrents).       │
│   + Cấu hình cho phép đặt trước và mượn laptop phòng máy (glpi_reservations).│
│ - Tham gia mở rộng bản dịch tiếng Việt cho GLPI 11 (667 mục từ + 212 mục     │
│   chuỗi số nhiều), đạt độ phủ 100% menu, biểu mẫu và dashboard.              │
│ - Kiểm thử chấp nhận người dùng (UAT) và soạn thảo tài liệu hướng dẫn.       │
│                                                                              │
│ Tệp nguồn & tài liệu phụ trách trực tiếp:                                     │
│ - scripts/seed-du-lieu-nen.sql, scripts/nap-du-lieu-nen.sh                  │
│ - scripts/seed-sla-va-chong-lam-dung.sql, scripts/nap-sla-va-chong-lam-dung.sh│
│ - scripts/viet-hoa-du-lieu.sh, scripts/bo-sung-tieng-viet.py                 │
│ - scripts/gop-ban-dich-tieng-viet.py, scripts/do-do-phu-tieng-viet.py        │
│ - scripts/kiem-tra-chuc-nang.sh (kiểm thử nghiệp vụ 3 vai trò người dùng)    │
│ - tai-lieu/README.md (kịch bản demo 7 phút, hướng dẫn nghiệp vụ vận hành)   │
│ - tai-lieu/SO-LIEU-THUC-TE-DLU.md (Mục 3: quy chuẩn email & cơ cấu tổ chức) │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│ 4. CẢ 3 THÀNH VIÊN (Nhiệm vụ chung của thực tập sinh tại Trung tâm CNTT)     │
├──────────────────────────────────────────────────────────────────────────────┤
│ - Tham gia công tác quản trị, kiểm tra và bảo dưỡng định kỳ các phòng máy     │
│   tính tại khu A và khu TV dưới sự hướng dẫn của ThS. Đặng Quốc Phi.         │
│ - Hỗ trợ chuẩn bị phòng máy, cài đặt phần mềm chuyên dụng phục vụ Hội thi     │
│   Tin học trẻ toàn quốc tổ chức tại Trường Đại học Đà Lạt.                    │
│ - Chuẩn bị địa điểm và hỗ trợ hạ tầng kỹ thuật cho cuộc thi An toàn thông     │
│   tin sinh viên.                                                             │
│ - Tham gia các buổi họp giao ban tiến độ định kỳ với cán bộ hướng dẫn ITC.   │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Tiến độ Thực hiện 10 Tuần và Phân công Chi tiết

| Tuần | Thời gian | Nhiệm vụ của Phùng Võ Quốc Hiển | Nhiệm vụ của Lý Gia Bảo | Nhiệm vụ của Nguyễn Việt Bình | Sản phẩm bàn giao chung |
|:---:|---|---|---|---|---|
| **1** | 10/08 – 15/08/2026 | Nhận bàn giao tại ITC; học tập nội quy; tìm hiểu kiến trúc mạng tổng thể của trường. | Khảo sát thực địa vị trí 10 phòng máy tại Tòa A và Tòa F (TV1 – TV4). | Tiếp nhận quy chế làm việc; khảo sát cách thức ghi chép sổ theo dõi sự cố hiện hành. | Báo cáo khảo sát hiện trạng hạ tầng & quy chế ITC. |
| **2** | 17/08 – 22/08/2026 | Phân tích yêu cầu phi chức năng (bảo mật, hiệu năng, cô lập dữ liệu). | Lập danh sách thiết bị cần thu thập thông số kỹ thuật chi tiết. | Phỏng vấn kỹ thuật viên ITC; đúc kết 3 mâu thuẫn nghiệp vụ M1, M2, M3. | Bản đặc tả yêu cầu nghiệp vụ ITSM trường học. |
| **3** | 24/08 – 29/08/2026 | Thiết kế kiến trúc 4 container Docker; cấu hình Nginx Gateway HTTPS & SSL có SAN. | Khảo sát quy cách nhãn dán tài sản và mã vạch/QR hiện có trên thiết bị. | Khảo sát danh mục cơ cấu tổ chức: tòa nhà, phòng ban, khoa viện của DLU. | Môi trường Docker Compose hoạt động ổn định. |
| **4** | 31/08 – 05/09/2026 | Tối ưu cấu hình PHP-FPM, giới hạn tài nguyên và cấu hình bảo mật kết nối MariaDB. | Thiết kế cấu trúc mã định danh tài sản (`TDL-PC-A241-001`). | Xây dựng bộ danh mục 12 tòa nhà, 54 phòng, 16 khoa, 79 loại sự cố ITIL. | Bộ script nạp dữ liệu nền `seed-du-lieu-nen.sql`. |
| **5** | 07/09 – 12/09/2026 | Phát triển lớp bảo mật phòng thủ 6 tầng & plugin `pinedesk` (Email DLU, Hạn mức, Chống trùng). | Nghiên cứu plugin Barcode 2.7.1, phân tích các lỗi cú pháp trên GLPI 11. | Xây dựng bảng quy chuẩn 5 mức SLA và luồng bảo trì, mượn trả thiết bị. | Plugin `pinedesk` + Bảng cấu hình SLA thật trong CSDL. |
| **6** | 14/09 – 19/09/2026 | Xây dựng cơ chế khóa phân tán MariaDB `GET_LOCK` chống nộp phiếu đồng thời. | Phát triển plugin giao diện `dlubrand`, CSS màu thông reo - đất đỏ DLU. | Mở rộng biên dịch từ điển tiếng Việt 667 thuật ngữ + 212 mục số nhiều. | Plugin `dlubrand` hoàn thiện + Gói ngôn ngữ tiếng Việt. |
| **7** | 21/09 – 26/09/2026 | Tích hợp nhật ký kiểm toán T6 và phân quyền tài khoản 3 nhóm người dùng. | Vá 3 lỗi của plugin Barcode trên GLPI 11; viết script Python `sinh-ma-qr.py`. | Kiểm thử quy trình gửi phiếu sự cố dạng ticket theo các nhóm quyền. | Tính năng in mã QR từ hồ sơ thiết bị & script QR hàng loạt. |
| **8** | 28/09 – 03/10/2026 | Tự động hóa luồng cấp quyền demo và thiết lập script một lệnh `cai-dat-tat-ca.sh`. | Nhập liệu thông số 482 máy tính, 487 màn hình, máy in từ văn bản khảo sát ITC. | Rà soát tính hợp lệ của danh mục nghiệp vụ và độ chính xác của SLA. | Script nạp dữ liệu mẫu 10 phòng máy thật `seed-du-lieu-mau.sql`. |
| **9** | 05/10 – 10/10/2026 | Viết harness kiểm thử CSDL 56 điểm kiểm, kịch bản Playwright E2E, đo tải wrk. | Chụp bộ 13 ảnh minh chứng giao diện thực tế đầy đủ các phân hệ. | Chạy bộ kiểm thử chức năng theo vai trò `kiem-tra-chuc-nang.sh`. | Báo cáo kiểm thử tự động, kết quả đo tải định lượng. |
| **10** | 12/10 – 17/10/2026 | Rà soát chất lượng đối kháng (13 vấn đề), tích hợp mã nguồn, đóng gói sản phẩm. | Hoàn thiện tài liệu đặc tả thiết kế `DESIGN.md` và slide thuyết trình. | Hoàn thiện tài liệu hướng dẫn vận hành, kịch bản demo 7 phút. | Báo cáo thực tập tốt nghiệp & Slide bảo vệ hoàn chỉnh. |

---

## 4. Hướng dẫn Khai thác Mã nguồn và Viết Báo cáo cho Từng Thành viên

Để các thành viên viết báo cáo thực tập đạt kết quả cao, đúng quy chế học thuật của Khoa CNTT và không bị đánh giá là sao chép nội dung lẫn nhau:

### 4.1. Hướng dẫn chung về Báo cáo
1. **Cấu trúc chung:** Cả 3 báo cáo đều có phần giới thiệu đơn vị thực tập (Trung tâm CNTT ĐH Đà Lạt), mục tiêu chung của đề tài PineDesk và bảng phân công nhiệm vụ của Nhóm 4.
2. **Nội dung chuyên sâu riêng biệt:** Mỗi bạn tập trung đào sâu vào **chương 3 và chương 4** theo đúng mảng việc mình được phân công:
   - Bạn **Hiển**: Đi sâu vào phân tích kiến trúc Microservices/Docker, nguyên tắc Zero-Core-Modification, 6 tầng phòng thủ chống lạm dụng, khóa chống đua TOCTOU, cơ chế xác thực email `@dlu.edu.vn` và kết quả kiểm thử tự động 56 điểm kiểm.
   - Bạn **Bảo**: Đi sâu vào phân tích bài toán quản lý tài sản phần cứng trường học, mô hình định danh thiết bị bằng mã QR, phương pháp giải quyết lỗi tương thích plugin Barcode trên PHP 8.3/GLPI 11, và ngôn ngữ thiết kế giao diện bản sắc văn hóa địa phương.
   - Bạn **Bình**: Đi sâu vào phân tích khoảng trống quy trình ITSM tại ITC, ứng dụng khung chuẩn ITIL v4, phân loại 79 danh mục sự cố, bài toán quản lý cam kết chất lượng dịch vụ (SLA) trong môi trường giáo dục đại học, và quy trình kiểm thử chấp nhận người dùng (UAT).

### 4.2. Cách lấy mã nguồn và chạy thử nghiệm
1. Kéo mã nguồn mới nhất từ GitHub:
   ```bash
   git clone https://github.com/Lacia1803/pinedesk.git
   cd pinedesk
   ```
2. Khởi tạo môi trường:
   ```bash
   cp .env.example .env
   # Chỉnh sửa mật khẩu an toàn trong .env
   bash scripts/cai-dat-tat-ca.sh
   bash scripts/nap-du-lieu-mau.sh
   ```
3. Chạy các bài kiểm thử xác nhận:
   - Kiểm thử CSDL 56 điểm kiểm: `docker compose exec -T glpi php /var/www/glpi/plugins/pinedesk/tests/kiem-thu-han-muc.php`
   - Kiểm thử chức năng: `bash scripts/kiem-tra-chuc-nang.sh`
   - Quét bí mật mã nguồn: `bash scripts/quet-bi-mat.sh`

---

*Tài liệu này được lập và thống nhất bởi các thành viên Nhóm 4 làm căn cứ thực hiện nhiệm vụ và báo cáo trước Hội đồng chấm thực tập tốt nghiệp.*
