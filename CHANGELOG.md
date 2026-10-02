# NHẬT KÝ THAY ĐỔI — PINEDESK

Định dạng theo [Keep a Changelog](https://keepachangelog.com/vi/1.1.0/).
Phiên bản theo [Semantic Versioning](https://semver.org/lang/vi/).

---

## [0.2.0] — 2026-10-02 — "Từ lý thuyết sang nghiệp vụ thật"

**Bối cảnh:** sau báo cáo tiến độ lần 1, giảng viên hướng dẫn nhận xét đồ án
*"còn lý thuyết, chưa thực tế"* và đặt câu hỏi trực diện: *"Nếu sinh viên spam
thì sao? Cơ chế để sinh viên nộp ticket là gì? Đồ án giải quyết nhu cầu gì của
trường?"*. Bản phát hành này trả lời trực tiếp ba câu hỏi đó.

### Thêm mới

**Tài liệu nghiệp vụ**
- `tai-lieu/BAI-TOAN-NGHIEP-VU.md` — bài toán thực tế với dữ kiện công khai có
  nguồn: 5 nhân sự Trung tâm CNTT (ITC) phục vụ 14.500+ người học, kênh tiếp nhận
  chỉ mở 7h30–16h30 thứ 2–6. Phân loại rõ 🟢 dữ kiện / 🟡 suy luận / 🔴 giả định.
- `tai-lieu/CHONG-LAM-DUNG.md` — sáu tầng chống lạm dụng nộp phiếu, ghi rõ tầng nào
  đã dựng thật, tầng nào còn ở mức quy trình.
- `tai-lieu/CAU-HOI-PHAN-BIEN.md` — 25 câu hỏi hội đồng thường hỏi + cách trả lời
  kèm bằng chứng; chỉ rõ ba câu phải trả lời bằng sự thật.
- `tai-lieu/KICH-BAN-DEMO.md` — kịch bản trình diễn 7 phút chia theo phút, kèm
  phương án dự phòng khi mất mạng hoặc Docker không chạy.
- `tai-lieu/slide-bao-ve.html` — 7 slide tự chứa, chạy ngoại tuyến hoàn toàn,
  dùng bảng màu Đà Lạt trích từ logo DLU.

**Cơ chế chống lạm dụng (đã dựng thật)**
- Rate limit cho endpoint nộp phiếu: zone `ticket_zone` (30 request/phút mỗi IP)
  áp cho `/front/ticket.form.php` và `/api/` — **vá lỗ hổng trước đây chỉ rate-limit
  ở trang đăng nhập**.
- `scripts/seed-sla-va-chong-lam-dung.sql` — tạo 5 định nghĩa SLA thật trong CSDL
  (trước đây README tuyên bố "cam kết SLA" nhưng CSDL rỗng), bảng hạn mức
  `glpi_plugin_pinedesk_limits`, bảng nhật ký `glpi_plugin_pinedesk_ticketlog`,
  view đếm phiếu đang mở, và phiếu quá hạn để demo cảnh báo.
- `scripts/nap-sla-va-chong-lam-dung.sh` — nạp cấu hình trên, có kiểm chứng.
- `scripts/kiem-tra-lam-dung.sh` — phát hiện vượt hạn mức, phiếu trùng, nộp quá
  nhanh theo **tài khoản** (không theo IP, vì trường dùng NAT chung).

**Bảo trì định kỳ + mượn/trả thiết bị (đã dựng thật)**
- 2 lịch bảo trì dùng cơ chế **gốc** `glpi_ticketrecurrents` (bảo trì phòng máy
  hàng tháng, kiểm tra thiết bị mạng hàng quý) kèm 2 mẫu phiếu điền sẵn tiêu đề,
  nội dung, danh mục và ưu tiên. Cron `ticketrecurrent` của GLPI tự sinh phiếu.
- 2 laptop vào diện đặt mượn + 2 lượt mượn mẫu (1 đang mượn, 1 đã trả) + 1 phiếu
  yêu cầu mượn — dùng `glpi_reservationitems`/`glpi_reservations` gốc, **không**
  tạo bảng riêng.
- Sửa **2 lỗi schema thật** phát hiện khi chạy cài đặt lần đầu:
  - `DATE_SUB(@now, INTERVAL 3 DAY - INTERVAL 2 HOUR)` — MySQL không hỗ trợ trừ
    hai `INTERVAL`; đổi thành `INTERVAL 70 HOUR`.
  - `glpi_slalevels.exec_time` **không tồn tại** (đúng là `execution_time`), và
    `glpi_slas.type` là `NOT NULL` (TTO=1/TTR=0) → lỗi 1054 chặn cả bước 5.
    Viết lại Phần A: 10 SLA (5 mức ưu tiên × 2 loại) + dọn bản ghi cũ khi nạp lại.

**Kiểm thử tự động**
- CI thêm 3 bước trong job `smoke`: bắt buộc phát hiện HTTP 429 khi spam endpoint
  nộp phiếu; kiểm tra bảng SLA có dữ liệu sau khi nạp; chạy script kiểm lạm dụng.

### Thay đổi

- `scripts/cai-dat-tat-ca.sh`: từ 5 bước lên **6 bước**, thêm bước nạp SLA + chống
  lạm dụng.
- `README.md`: bỏ tuyên bố suông "cam kết SLA"; thêm dòng minh bạch rằng các mức
  SLA là **đề xuất kỹ thuật, chưa được Trường ban hành**; thêm mục chống lạm dụng.
- `tai-lieu/SO-SANH-VOI-GLPI-GOC.md`: viết lại mục "Những điều chưa làm" thành hai
  phần — giới hạn kỹ thuật và **giới hạn nghiệp vụ** (10 điểm, nói thẳng).
- `landing/index.html`: bổ sung liên kết tới 3 tài liệu nghiệp vụ mới (từ 6 lên 9).

### Sửa

- **Đính chính tên đơn vị:** toàn bộ tài liệu đổi "Phòng Công nghệ thông tin" →
  **"Trung tâm Công nghệ thông tin (ITC)"** — tên đúng theo công bố chính thức.
- **Đính chính tên miền:** `cict.dlu.edu.vn` → `itc.dlu.edu.vn` (miền cũ chuyển
  hướng 301).
- **Đính chính tên phòng ban** theo danh mục hiện hành của Trường: "Phòng Cơ sở
  Vật chất" → "Phòng Quản trị Cơ sở vật chất"; "Phòng Chính trị và Công tác Sinh
  viên" → "Phòng Công tác sinh viên"; và 4 tên khác.
- Xoá nhánh nhánh cũ đã lỗi thời `sua-4-van-de-muc-thap`.

### Ghi chú

Ba điều đồ án **chưa** chứng minh được, ghi rõ để không tuyên bố quá mức:
1. Chưa gặp ITC để xác nhận nhu cầu (đồ án chưa được phê duyệt);
2. Chưa có số sự cố thực tế mỗi tuần của trường;
3. Chưa đo hiệu năng khi nhiều người cùng nộp.

### Số liệu đo được trên máy thật (2026-10-02)

| Chỉ số | Kết quả | Cách đo |
|---|---|---|
| Thời gian cài đặt trọn gói (6 bước) | **90 giây** | `time bash scripts/cai-dat-tat-ca.sh` |
| Độ phủ Việt hoá thực tế | **31,8%** (2.070/6.511 chuỗi) | `python scripts/do-do-phu-tieng-viet.py` |
| Thời gian phản hồi trang (5 lần) | **~55 ms** (52–64 ms) | `curl -w "%{time_total}"` |
| Thời gian phản hồi CSS tĩnh | **45 ms** | `curl -w "%{time_total}"` |

**Nói rõ để không hiểu sai:** 31,8% là tỉ lệ trên *toàn bộ catalog chuỗi của GLPI*
(GLPI chỉ đóng gói sẵn ~32% bản dịch tiếng Việt chính thức). Menu, biểu mẫu và
nhãn bảng điều khiển — phần người dùng thực sự nhìn thấy — đã Việt hoá 100%.
Con số 90 giây và 55 ms đo trên máy cá nhân, KHÔNG phải đo tải nhiều người
cùng lúc; đồ án chưa kiểm thử hiệu năng.


---

## [0.1.0] — 2026-09-22 — "Hoàn thiện nền tảng"

- Việt hoá bổ sung 443 thuật ngữ + 212 mục dạng số nhiều (phủ 30,6% catalog;
  menu, biểu mẫu và nhãn dashboard 100%).
- Giao diện "Đà Lạt" (`plugins/dlubrand/`) — bảng màu trích từ logo DLU.
- Plugin Barcode/QR: cài đặt, vá 2 lỗi, giải mã kiểm chứng.
- Hạ tầng 4 container Docker + Nginx gateway + HTTPS có SAN.
- Landing page chạy ngoại tuyến (16 font `.woff2` tự lưu).
- Dữ liệu nền 23 nhóm danh mục + dữ liệu demo (17 máy tính, 13 phiếu, 6 tài khoản).
- CI 6 nhóm job gồm smoke test khởi động thật 4 container.
- 5 tài liệu tiếng Việt + 19 ảnh minh chứng giao diện.
- Xử lý rò rỉ bí mật: quét theo hình dạng, không chứa mật khẩu thật.
