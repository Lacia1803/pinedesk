# Design System — PineDesk DLU

<!-- impeccable:design-schema 1 -->

## Philosophy & Voice

PineDesk dung hợp vẻ đẹp nhân văn, biên tập của Claude (`DESIGN-claude.md`) với chuẩn mực tối giản, sắc sảo của Apple (`DESIGN-apple.md`), trên nền tảng bản sắc thiên nhiên và di sản của Trường Đại học Đà Lạt.
- **Bầu không khí (Claude Warmth):** Bề mặt sương ấm cao nguyên (`#FAF9F5`), loại bỏ hoàn toàn cảm giác xám lạnh vô cảm của Tabler mặc định.
- **Tiêu đề biên tập:** Sử dụng phông serif `Literata` cho các tiêu đề trang trọng (Đăng nhập, Dashboard, Tiêu đề biểu mẫu lớn), kết hợp với `Be Vietnam Pro` cho nội dung thao tác và `IBM Plex Mono` cho mã tài sản / Ticket ID.
- **Chuẩn mực tương tác (Apple Precision):** Đường phân cách siêu mảnh (hairlines `1px solid rgba(..., 0.08)`), vi hành động nén nhẹ khi bấm (`transform: scale(0.98)`), bo góc viên thuốc (`border-radius: 9999px`) cho các nút hành động chính và huy hiệu trạng thái (capsule chips).
- **Điểm nhấn tương tác độc tôn (Single Accent Rule):** Sắc cam đất DLU (`#F08418` / `#BA5B08` đạt chuẩn WCAG AA >= 4.5:1) là màu dẫn hướng hành động duy nhất, tương tự Action Blue của Apple và Coral của Claude.

## Color Tokens

### 1. Thương hiệu Đà Lạt (Core Identity)
- `brand-cam`: `#F08418` (Cam đất mặt trời DLU — Accent, viền tiêu điểm, điểm nhấn)
- `brand-cam-cta`: `#BA5B08` (Cam đất đậm — Đạt tương phản WCAG AA >= 4.5:1 cho nút bấm chữ trắng)
- `brand-reu`: `#607824` (Xanh rêu đồi thông — Thanh điều hướng, cấu trúc trang, trạng thái hoàn tất)
- `brand-reu-dam`: `#3D4E17` (Xanh rêu sẫm — Tiêu đề trang trọng)
- `brand-hon`: `#3E8E9E` (Xanh hồ Xuân Hương — Thẻ thông tin, chỉ dẫn phụ)
- `brand-do`: `#CC2430` (Đỏ sao vàng — Cảnh báo khẩn cấp P5)

### 2. Bề mặt & Nền (Surfaces & Canvas)
- `canvas`: `#FAF9F5` (Nền sương ấm cao nguyên, thay thế xám trắng `#F1F5F9`)
- `surface-card`: `#FFFFFF` (Bề mặt thẻ nội dung)
- `surface-muted`: `#F3EFE6` (Bề mặt vùng trũng, ô nhập liệu)
- `surface-elevated`: `#FCFBF7` (Bề mặt thanh công cụ, modal header)
- `hairline`: `rgba(38, 48, 26, 0.08)` (Đường kẻ siêu mảnh)
- `hairline-strong`: `rgba(38, 48, 26, 0.16)` (Đường kẻ phân đoạn rõ)

### 3. Mực in (Typography Ink)
- `ink`: `#26301A` (Mực xanh thông sẫm, độ tương phản tuyệt đối)
- `ink-muted`: `#6C7262` (Mực phụ, chú thích, nhãn phụ)
- `ink-subtle`: `#9DA393` (Mực mờ, placeholder)

## Typography Scale

- **Display Serif (`Literata`):**
  - Hero Login: 28px / 600 / tracking -0.025em / line-height 1.2
  - Section Title: 20px / 600 / tracking -0.02em / line-height 1.3
  - Modal Title: 18px / 600 / tracking -0.015em
- **UI Sans (`Be Vietnam Pro`):**
  - Body: 14px / 400 / line-height 1.55 / letter-spacing -0.01em
  - Body Strong: 14px / 600 / line-height 1.55
  - Table Header: 11.5px / 600 / uppercase / tracking +0.04em
  - Small / Badge: 12px / 500
- **Data Mono (`IBM Plex Mono`):**
  - Ticket ID / Asset Tag: 13px / 500 / tabular-nums
  - Counter Metric: 28px / 600 / tabular-nums

## 5 Màn hình Mặt tiền (Key Surfaces)

1. **Trang đăng nhập (`.welcome-anonymous`):**
   - Tiêu đề `Literata` trang nhã.
   - Thẻ đăng nhập kính mờ sương ấm (`rgba(255, 255, 253, 0.94)`, `backdrop-filter: blur(20px)`), bo góc `16px`, đường kẻ hairline mảnh.
   - Nút đăng nhập hình viên thuốc (pill) cam đất với phản hồi bấm nén `scale(0.98)`.
   - Cảnh đồi thông Đà Lạt nhiều lớp có chiều sâu êm dịu.
2. **Bảng điều khiển trung tâm (`central.php`):**
   - Tiêu đề card chuyển `Literata` 600 trang trọng.
   - Thẻ số liệu đếm dùng `IBM Plex Mono` căn chỉnh số thẳng hàng.
   - Bỏ đổ bóng thô của Tabler; dùng whisper elevation (`0 1px 3px rgba(..., 0.04)`).
3. **Danh sách phiếu yêu cầu (`ticket.php`):**
   - Tiêu đề cột `th` chữ hoa nhỏ có tracking dương nhẹ.
   - Hàng bảng hairline ngăn nắp, hover êm dịu.
   - Mã phiếu căn chỉnh monospace thẳng cột.
   - Huy hiệu trạng thái chuyển capsule chip bo tròn viên thuốc (`border-radius: 9999px`).
   - Dải ưu tiên mép trái 3.5px bo tròn tích hợp mượt mà.
4. **Form tạo phiếu mới (`Form/Render/1` & `ticket.form.php`):**
   - Thẻ danh mục dịch vụ hover viền cam đất nổi nhẹ.
   - Ô nhập liệu nền ngà sạch sẽ, focus ring 2 tầng rõ nét.
5. **Modal in mã QR thiết bị:**
   - Hộp thoại Apple Sheet bo tròn 16px.
   - Decal in mã QR mô phỏng chất liệu tem thực tế, mã thiết bị hiển thị monospace nổi bật.
