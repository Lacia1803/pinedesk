# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

**Người xem chính (bề mặt landing page): hội đồng bảo vệ đồ án tốt nghiệp.**
Giảng viên khoa Công nghệ thông tin, Trường Đại học Đà Lạt. Họ đọc trang trong
buổi bảo vệ, thường chiếu lên máy chiếu, và dùng nó như một phần của bài trình bày.
Họ đánh giá: hệ thống có chạy thật không, kiến trúc có hợp lý không, kỹ thuật có
chiều sâu không, người làm có hiểu việc mình làm không, và trình bày có chỉn chu không.

**Người dùng thứ cấp của sản phẩm (không phải người xem chính của trang này):**
cán bộ **Trung tâm Công nghệ thông tin (ITC)** — đơn vị vận hành hệ thống CNTT và
tổ chức phòng thực hành máy tính của Trường — cùng kỹ thuật viên, giảng viên và
sinh viên: người gửi phiếu sự cố và tra cứu thiết bị.

## Product Purpose

Hệ thống hỗ trợ kỹ thuật (PineDesk) nội bộ của Trường Đại học Đà Lạt: quản lý
phòng máy và tài sản CNTT, tiếp nhận – phân công – theo dõi phiếu sự cố theo quy
trình ITIL, tra cứu hồ sơ thiết bị bằng mã QR, và thống kê tình hình qua dashboard.
Sản phẩm là một đồ án thực tập tốt nghiệp: mục tiêu là chứng minh năng lực kỹ thuật
của người làm, không phải một sản phẩm thương mại.

## Positioning

Không viết lại từ đầu: toàn bộ năng lực ITSM dựa trên GLPI 11 (mã nguồn mở, đã được
kiểm chứng), còn phần tùy biến của đồ án nằm hoàn toàn ở **lớp phủ riêng** — plugin
giao diện, bản dịch tiếng Việt bổ sung, script tự động hoá, cấu hình Docker. Nhờ vậy
nâng cấp GLPI không làm mất công sức đã bỏ ra. Đây là điểm một sản phẩm cùng loại
viết tay từ đầu không thể sao chép được một cách trung thực.

## Operating Context

- Chạy bằng Docker Compose: 4 dịch vụ (Nginx gateway · GLPI 11 · MariaDB 10.11 · Redis 7).
- Truy cập qua HTTPS với chứng chỉ tự ký có SAN, tại `https://localhost:8443`.
- Cài đặt toàn bộ bằng một lệnh: `bash scripts/cai-dat-tat-ca.sh`.
- Trang landing page phục vụ **ngoại tuyến hoàn toàn**: 16 tệp font `.woff2` tự lưu,
  không dùng CDN; hội đồng có thể xem khi phòng không có mạng.
- Bối cảnh xem: máy chiếu trên lớp, đôi khi là màn hình laptop; cả điện thoại khi
  người xem tự mở lại sau buổi bảo vệ.

## Capabilities and Constraints

Đã xác nhận, có thật trong hệ thống:

- Quản lý tài sản: 17 máy tính, 5 màn hình, 3 máy in, 9 thiết bị mạng, 10 phần mềm.
- 13 phiếu sự cố mẫu trải đủ các trạng thái, cộng 1 phiếu mượn thiết bị (14 phiếu
  khi cài đầy đủ).
- 6 tài khoản mẫu, 3 vai trò (quản trị, kỹ thuật viên, người dùng), mật khẩu chung `Dlu@2026`.
- Mã tài sản theo quy ước thật: `TDL-PC-A101-001`.
- 556 thuật ngữ Việt hoá bổ sung + 212 mục dạng số nhiều; menu, biểu mẫu và nhãn
  dashboard đã Việt hoá.
- 79 loại sự cố được phân loại sẵn; 12 toà nhà, 54 phòng máy, 16 khoa.
- 10 tài liệu tiếng Việt trong `tai-lieu/`, cộng `README.md` và bộ slide bảo vệ.
- Ảnh dashboard thật: `landing/dashboard-preview.png` (sinh từ hệ thống đang chạy,
  dữ liệu thật, đã Việt hoá).

Ràng buộc:

- **Trang phải chạy được khi không có Internet** — không CDN, không tài nguyên ngoài.
- Liên kết tương đối, mở từ máy khác trong mạng LAN vẫn đúng.
- Nội dung phải hiển thị đầy đủ khi JavaScript bị tắt.
- Không được thêm tuyên bố thương mại hay số liệu không có thật (khách hàng, giá,
  benchmark, cam kết dịch vụ).

## Brand Commitments

- **Logo Trường Đại học Đà Lạt là nguồn thương hiệu bắt buộc.** Bảng màu neo theo
  logo: xanh rêu `#607824`, cam đất `#F08418`, đỏ sao `#CC2430`, dải lá xanh `#90B43C`.
- Tên hệ thống: **PineDesk — Trường Đại học Đà Lạt**.
- Giao diện GLPI bên trong hệ thống dùng bảng màu "Đà Lạt" lấy từ logo; landing page
  phải nhất quán về thương hiệu với giao diện đó.
- Ngôn ngữ: tiếng Việt.

## Evidence on Hand

- `landing/dashboard-preview.png` — ảnh chụp dashboard thật.
- `landing/logo-DLU-100sq.png` — logo Trường (100×100).
- `landing/qr-sample.png` — mã QR mẫu của một thiết bị.
- `landing/fonts/` — 16 tệp font `.woff2` có subset tiếng Việt.
- Bộ biểu tượng SVG nội bộ nhúng sẵn trong `landing/index.html`.
- `tai-lieu/anh-giao-dien/` — 21 ảnh minh chứng giao diện thực tế, được README
  nhúng trực tiếp. Phần lớn sinh bằng `node scripts/chup-lai-anh-minh-chung.js`
  (cần `GLPI_PASS`), ảnh landing do `scripts/kiem-tra-landing.js`, ảnh nhãn QR do
  `scripts/sinh-ma-qr.py`. Hai ảnh luồng in qua plugin Barcode cần tài khoản quản
  trị, chụp bằng `node scripts/chup-anh-qr-admin.js`.

**Không được bịa:** không có khách hàng thật, không có số người dùng, không có
benchmark hiệu năng, không có giải thưởng, không có đánh giá từ bên thứ ba.

## Product Principles

1. **Chứng minh, đừng tuyên bố.** Cho thấy hệ thống đang chạy thật (ảnh chụp thật,
   số liệu thật, kiến trúc thật) thay vì nói nó tốt.
2. **Chiều sâu kỹ thuật là điểm bán.** Hội đồng chấm năng lực kỹ thuật; những chi
   tiết cụ thể (bảo mật từng lớp, CI, một lệnh cài đặt) đáng giá hơn lời khen chung.
3. **Chạy được khi mất mạng.** Mọi tài nguyên phải nằm trong máy.
4. **Nhất quán thương hiệu DLU.** Màu và tinh thần lấy từ logo Trường, xuyên suốt từ
   landing page tới giao diện GLPI bên trong.

## Accessibility & Inclusion

Chưa có yêu cầu riêng do người dùng nêu. Áp dụng mức mặc định: tương phản đạt
WCAG AA, điều hướng bàn phím được, tôn trọng `prefers-reduced-motion`, và nội dung
vẫn đọc được khi JavaScript bị tắt.
