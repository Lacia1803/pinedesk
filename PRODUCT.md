# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

**Người dùng chính: hội đồng bảo vệ đồ án tốt nghiệp và đơn vị vận hành.**
Giảng viên khoa Công nghệ thông tin, Trường Đại học Đà Lạt trong buổi bảo vệ.
Họ đánh giá: hệ thống có chạy thật không, kiến trúc có hợp lý không, kỹ thuật có
chiều sâu không, và người làm có hiểu việc mình làm không.

**Người dùng hệ thống:** cán bộ **Trung tâm Công nghệ thông tin (ITC)** (đơn vị
vận hành hệ thống CNTT và phòng máy thực hành của Trường) cùng kỹ thuật viên,
giảng viên và sinh viên: người gửi phiếu sự cố và tra cứu thiết bị.

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

- Chạy bằng Docker Compose: 4 dịch vụ (Nginx gateway, GLPI 11, MariaDB 10.11, Redis 7).
- Truy cập qua HTTPS với chứng chỉ tự ký có SAN, tại `https://localhost:8443`.
- Cài đặt toàn bộ bằng một lệnh: `bash scripts/cai-dat-tat-ca.sh`.
- Bối cảnh sử dụng: trình chiếu trong buổi bảo vệ và máy trạm trong mạng nội bộ.

## Capabilities and Constraints

Đã xác nhận, có thật trong hệ thống:

- Quản lý tài sản: 17 máy tính, 5 màn hình, 3 máy in, 9 thiết bị mạng, 10 phần mềm.
- 13 phiếu sự cố mẫu trải đủ các trạng thái.
- 6 tài khoản mẫu, 3 vai trò (quản trị, kỹ thuật viên, người dùng), mật khẩu chung `Dlu@2026`.
- Mã tài sản theo quy ước thật: `TDL-PC-A101-001`.
- 556 thuật ngữ Việt hoá bổ sung + 212 mục dạng số nhiều; menu, biểu mẫu và nhãn
  dashboard đã Việt hoá.
- 79 loại sự cố được phân loại sẵn; 12 toà nhà, 54 phòng, 16 khoa.
- Bộ tài liệu trong `tai-lieu/`: `README.md` (tổng hợp toàn diện, 10 mục),
  `BAO-CAO-THUC-TAP.md` (báo cáo thực tập) và `slide-bao-ve.html` (8 slide bảo vệ).

Ràng buộc:

- **Hệ thống chạy ngoại tuyến:** không dùng CDN hay tài nguyên bên ngoài.
- Không đưa vào tuyên bố thương mại hay số liệu không có thật (khách hàng, giá,
  benchmark, cam kết dịch vụ).

## Brand Commitments

- **Logo Trường Đại học Đà Lạt là nguồn thương hiệu bắt buộc.** Bảng màu neo theo
  logo: xanh rêu `#607824`, cam đất `#F08418`, đỏ sao `#CC2430`, dải lá xanh `#90B43C`.
- Tên hệ thống: **PineDesk, Trường Đại học Đà Lạt**.
- Giao diện GLPI sử dụng bảng màu "Đà Lạt" lấy từ logo DLU.
- Ngôn ngữ: tiếng Việt.

## Evidence on Hand

- `tai-lieu/anh-giao-dien/`: 18 ảnh minh chứng giao diện thực tế được README
  nhúng trực tiếp. Sinh bằng `node scripts/chup-lai-anh-minh-chung.js`
  (cần `GLPI_PASS`), ảnh nhãn QR do `scripts/sinh-ma-qr.py`. Một ảnh luồng in qua
  plugin Barcode cần tài khoản quản trị, chụp bằng `node scripts/chup-anh-qr-admin.js`.

**Không được bịa:** không có khách hàng thật, không có số người dùng, không có
benchmark hiệu năng, không có giải thưởng, không có đánh giá từ bên thứ ba.

## Product Principles

1. **Chứng minh bằng thực tế:** Cho thấy hệ thống đang chạy thật (ảnh chụp thật,
   số liệu thật, kiến trúc thật) thay vì nói chung chung.
2. **Chiều sâu kỹ thuật:** Đồ án nhấn mạnh kiến trúc kỹ thuật cụ thể (bảo mật nhiều lớp,
   CI, cài đặt tự động).
3. **Chạy được khi mất mạng:** Mọi tài nguyên cấu hình nằm trực tiếp trên máy chủ.
4. **Nhất quán thương hiệu DLU:** Màu sắc và nhận diện lấy từ logo Trường, áp dụng xuyên
   suốt giao diện GLPI.

## Accessibility & Inclusion

Chưa có yêu cầu riêng do người dùng nêu. Áp dụng mức mặc định: tương phản đạt
WCAG AA, điều hướng bàn phím được, tôn trọng `prefers-reduced-motion`, và nội dung
vẫn đọc được khi JavaScript bị tắt.
