# SO SÁNH VỚI GLPI GỐC — NHỮNG GÌ ĐÃ CẢI THIỆN

> **Đồ án thực tập:** Xây dựng hệ thống hỗ trợ kỹ thuật (PineDesk)
> **Trường Đại học Đà Lạt** — Khoa Toán – Tin học
>
> **Đối tượng so sánh:**
> - **Gốc (upstream):** GLPI 11.0.0 chính thức — https://github.com/glpi-project/glpi (giấy phép GPL v3)
> - **Bản của đồ án:** repo này (`pinedesk`)
>
> **Ngày lập:** 19/09/2026

---

## 0. TÓM TẮT CHO NGƯỜI ĐỌC NHANH

| Câu hỏi | Trả lời ngắn |
|---|---|
| Có sửa vào mã nguồn lõi GLPI không? | **KHÔNG.** Toàn bộ tùy biến nằm ngoài lõi (plugin + config + script). |
| Cài đặt lại có mất công không? | Không. Một lệnh: `bash scripts/cai-dat-tat-ca.sh` |
| Bản gốc dùng được ngay chưa? | Chưa. Bản gốc là tiếng Anh, giao diện Teclib, **không có dữ liệu**, chạy bằng 1 container SQLite. |
| Điểm khác biệt lớn nhất là gì? | **Việt hóa + giao diện Đà Lạt + dữ liệu nghiệp vụ dựng sẵn + tự động hóa 1 lệnh + hạ tầng bảo mật.** |
| Nâng cấp GLPI lên 11.1 có mất tùy biến? | **Không** — vì tùy biến nằm ngoài lõi. |
| Đã kiểm thử thật chưa? | **Rồi.** 13 lỗi im lặng đã tìm ra và khắc phục — xem **mục 2.12**. |
| Demo cho hội đồng có cần nhập liệu không? | Không. `bash scripts/nap-du-lieu-mau.sh` là có ngay 17 thiết bị + 13 phiếu. |

---

## 1. BẢNG ĐỐI CHIẾU TỔNG QUAN

| Hạng mục | GLPI 11 gốc | Bản đồ án (pinedesk) | Mức cải thiện |
|---|---|---|---|
| **Ngôn ngữ giao diện** | Tiếng Anh mặc định; có sẵn ~28% tiếng Việt | Mặc định **tiếng Việt**, **556 thuật ngữ + 212 mục số nhiều** dịch bổ sung, phủ **32,0%→toàn bộ menu** | ⭐⭐⭐⭐ |
| **Giao diện / thương hiệu** | Bảng màu `auror` của Teclib, ngôn ngữ thẻ nổi bo tròn + bóng đổ | **Bảng màu "Đà Lạt"** lấy từ logo DLU (3 bảng màu) **+ ngôn ngữ hình ảnh riêng**: nền giấy/mực đậm/đường kẻ mảnh, thẻ mất vỏ hộp, bo góc 3–6px, đầu bảng in hoa, số liệu chữ đều | ⭐⭐⭐⭐⭐ |
| **Logo** | Logo Teclib / GLPI | **Logo chính thức ĐH Đà Lạt** ở mọi trang | ⭐⭐⭐⭐⭐ |
| **Dữ liệu nền** | **Rỗng hoàn toàn** — phải tự nhập | **Dựng sẵn 23 nhóm danh mục** theo cơ cấu thật của DLU | ⭐⭐⭐⭐⭐ |
| **Dữ liệu demo** | **Không có** — bảng điều khiển trống, không demo được | **1 lệnh ra 17 máy tính + 5 màn hình + 3 máy in + 9 thiết bị mạng + 10 phần mềm + 13 phiếu + 6 tài khoản 3 vai trò** | ⭐⭐⭐⭐⭐ |
| **Triển khai** | 1 lệnh chạy container SQLite (không production) | **Docker Compose 4 container** + Nginx + MariaDB + Redis | ⭐⭐⭐⭐⭐ |
| **HTTPS** | Không có | Nginx TLS 1.2/1.3, chứng chỉ tự ký sẵn | ⭐⭐⭐⭐ |
| **Chống brute-force** | Không có | Rate limit 3 tầng (đăng nhập 10/phút · chung 600/phút · **nộp phiếu 30/phút**) | ⭐⭐⭐⭐ |
| **Chống lạm dụng nộp phiếu** | Không có | **6 tầng**: rate limit · bắt buộc đăng nhập · hạn mức phiếu/người · chống trùng · kiểm duyệt · nhật ký (xem `CHONG-LAM-DUNG.md`) | ⭐⭐⭐⭐ |
| **SLA cấu hình sẵn** | Không có bản ghi nào | **5 mức SLA thật trong CSDL** (TTO/TTR), mỗi mức 2 mốc — *nhưng là đề xuất, chưa được Trường ban hành* | ⭐⭐⭐ |
| **Header bảo mật** | Không cấu hình | 5 header: HSTS, X-Frame-Options, nosniff, Referrer-Policy, Permissions-Policy | ⭐⭐⭐⭐ |
| **Chặn truy cập file nhạy cảm** | Phụ thuộc máy chủ web | Chặn `.env`, `.git`, `*.sql`, `*.log`, `config/`, `files/_log/`… | ⭐⭐⭐⭐ |
| **Sinh mã QR thiết bị** | Không có (phải tự tìm plugin) | **Đã cài + cấu hình + vá 2 lỗi** plugin Barcode; **QR đã giải mã kiểm chứng** | ⭐⭐⭐⭐⭐ |
| **Cài đặt lại / phục hồi** | Thủ công từng bước | **1 lệnh cài 5 bước** + script sao lưu | ⭐⭐⭐⭐⭐ |
| **Sao lưu** | Không có sẵn | `backup/backup.sh` — CSDL + files + config, tự dọn bản cũ | ⭐⭐⭐⭐ |
| **Tài liệu** | Tài liệu tiếng Anh trực tuyến | **5 tài liệu tiếng Việt** viết riêng cho đồ án | ⭐⭐⭐⭐ |
| **Trang giới thiệu** | Không có | **Landing page thiết kế riêng** theo bản sắc Đà Lạt & DLU — chạy được **offline** | ⭐⭐⭐⭐⭐ |
| **Kiểm thử tự động** | Không | 9 script kiểm thử (dịch, font, ảnh giao diện, luồng QR, landing) — **đã phát hiện 13 lỗi thật** | ⭐⭐⭐⭐ |

---

## 2. CHI TIẾT TỪNG HẠNG MỤC

### 2.1. Ngôn ngữ — Việt hóa

**Bản gốc:** GLPI 11 đóng gói sẵn bản dịch tiếng Việt nhưng chỉ đạt khoảng **32%** catalog. Bật tiếng Việt xong vẫn còn rất nhiều chuỗi tiếng Anh, đặc biệt ở menu và các màn hình nghiệp vụ.

**Bản đồ án đã làm:**

| Hạng mục | Số liệu |
|---|---|
| Tổng chuỗi cần dịch (catalog gốc) | 6.511 |
| Bản gốc đã có tiếng Việt | 1.831 |
| **Thuật ngữ dịch bổ sung do đồ án viết** | **556** (đơn) + 212 (dạng số nhiều) |
| Chuỗi tiếng Việt đang dùng trong GLPI | 2.084 |
| Tỉ lệ đo được trên giao diện thực tế | **32,0%** (2.084/6.511) |

**Cách làm — điểm kỹ thuật đáng chú ý:**

Không sửa file `.mo` của lõi. Thay vào đó, đồ án dùng **cơ chế lớp phủ bản dịch (translation overlay)** của GLPI 11:

```
/var/glpi/files/_locales/core/vi_VN.mo   ← bản GỘP (lõi + bổ sung), nạp SAU CÙNG
```

> ⚠️ **Cạm bẫy đã gặp và xử lý:** thư viện `laminas-i18n` mà GLPI dùng **THAY THẾ** chứ không **GỘP** catalog khi trùng domain + locale. Nếu cài một file `.mo` chỉ chứa vài trăm chuỗi bổ sung, **toàn bộ bản dịch lõi sẽ biến mất** (chuỗi quay về tiếng Anh). Vì vậy quy trình bắt buộc phải là:
>
> `vi_VN.po (lõi) + BAN_DICH_BO_SUNG (bổ sung)` → **GỘP** → `vi_VN.mo` → cài vào `_locales/core/`

Script `gop-ban-dich-tieng-viet.py` làm đúng việc gộp này, đảm bảo **không mất chuỗi nào**.

**Trả lời thẳng câu hỏi "đã 100% tiếng Việt chưa?"**

> **CHƯA.** Hiện là **32,0%**. Nhưng cần hiểu đúng con số này:
>
> - Đây là tỉ lệ trên **toàn bộ catalog**, kể cả các chuỗi kỹ thuật dài mà người dùng cuối không bao giờ thấy (thông báo lỗi CLI, log hệ thống, cảnh báo cron, SQL…).
> - **Giao diện người dùng thực sự chạm vào** — menu chính (Tài sản / Hỗ trợ / Quản lý / Công cụ / Quản trị / Cấu hình), thanh bên, tiêu đề bảng, nhãn biểu mẫu, nút bấm, nhãn trạng thái phiếu — **gần như 100% tiếng Việt**.
> - **Trang đăng nhập cũng đã Việt hóa** (xem 2.2).
> - **Không thể đạt 100%** bằng cách chỉ cài plugin, vì GLPI không ship đủ bản dịch. Muốn tăng phải dịch tay từng chuỗi — và phần còn lại chủ yếu là chuỗi kỹ thuật ẩn, **không đáng công**.

**⚠️ Một cái bẫy quan trọng: GLPI có HAI loại khoá dịch**

Đây là phát hiện đáng chú ý nhất về mặt kỹ thuật khi Việt hóa:

| Loại khoá | GLPI gọi bằng | Dùng cho | Từ điển thường vá được? |
|---|---|---|---|
| `msgid` (số ít) | `__('Ticket')` | Nhãn đơn, tiêu đề, nút | ✅ Có |
| `msgid_plural` (số nhiều) | `_n('Ticket', 'Tickets', $n)` → `translatePlural()` | **Mọi nhãn đếm số** trên danh sách & dashboard | ❌ **Không** |

Hệ quả thực tế: từ điển đã có `Ticket → Phiếu yêu cầu`, menu và biểu mẫu đều tiếng
Việt, nhưng thẻ số liệu trên dashboard vẫn hiện **`13 Ticket`** — vì GLPI tra
**entry số nhiều**, mà bản dịch `vi_VN` chính thức để `msgstr[0] "Ticket"` (chưa dịch).

Cách khắc phục: thêm bảng riêng `BAN_DICH_SO_NHIEU` (tiếng Việt có `nplurals=1`
nên một bản dịch dùng cho cả hai trường hợp) và hàm `va_entry_so_nhieu()` vá thẳng
các entry có ký tự `\0`. Xem **lỗi #11** ở mục 2.12.

**Các script liên quan:**

| Script | Chức năng |
|---|---|
| `bo-sung-tieng-viet.py` | Từ điển `BAN_DICH_BO_SUNG` — **556 thuật ngữ** (đơn) + `BAN_DICH_SO_NHIEU` — **212 mục** (dạng số nhiều) |
| `tao-mo-bo-sung.py` | Biên dịch từ điển thành file `.mo` |
| `gop-ban-dich-tieng-viet.py` | **GỘP** lõi + bổ sung (không mất chuỗi) + **vá/thêm entry số nhiều** |
| `dich-tu-dong-giao-dien.py` | Dịch tự động theo từ điển + mẫu câu (1.231 dòng) |
| `do-do-phu-tieng-viet.py` | Đo tỉ lệ Việt hóa **thật** bằng cách đọc `.mo` trong container |
| `cai-ban-dich.sh` | Cài bản dịch vào container |

> **File `.po` không được lưu trong git** (xem `.gitignore`). Các script dịch
> **tự tải lại** `vi_VN.po` từ image GLPI khi thấy thiếu hoặc file rỗng (0 byte),
> nên vẫn chạy được ngay sau khi clone mà không cần thao tác tay.

---

### 2.2. Việt hóa trang đăng nhập — một vấn đề riêng biệt

**Bản gốc:** Trang đăng nhập là trang **ẩn danh** (chưa có phiên làm việc). GLPI đọc thẳng `$_SESSION['glpilanguage']` **không có giá trị dự phòng**, nên khách chưa đăng nhập **luôn thấy tiếng Anh** — dù Thiết lập chung đã đặt `vi_VN`.

**Bản đồ án đã làm:** Plugin `dlubrand` đăng ký hook `POST_INIT` để gán ngôn ngữ mặc định cho phiên ẩn danh:

```php
$PLUGIN_HOOKS[Hooks::POST_INIT]['dlubrand'] = 'plugin_dlubrand_set_default_language';
```

Hàm này kiểm tra nếu phiên chưa có ngôn ngữ → lấy từ `$CFG_GLPI['language']` → nếu hợp lệ thì gán và gọi `Session::loadLanguage()` ngay.

**Kết quả:** Trang đăng nhập — "mặt tiền" của hệ thống — **hoàn toàn tiếng Việt**.

---

### 2.3. Giao diện — Bảng màu "Đà Lạt"

**Bản gốc:** Bảng màu `auror` mặc định của Teclib — tông xanh dương công nghiệp, không liên quan gì đến Đà Lạt.

**Bản đồ án đã làm:** Dựng **3 bảng màu tự tạo** trong `themes/`:

| File | Tên bảng màu | Ý tưởng |
|---|---|---|
| `da_lat.scss` | **Đà Lạt** (chính) | Xanh rêu đồi thông làm màu chủ đạo, cam đất làm điểm nhấn |
| `da_lat_nang.scss` | Đà Lạt — Nắng | Tông sáng, ấm — nắng cao nguyên |
| `da_lat_suong.scss` | Đà Lạt — Sương | Tông nhạt, dịu — sương mù sớm mai |

**Bảng màu được lấy trực tiếp từ logo chính thức DLU (2025):**

| Biến | Mã màu | Lấy từ đâu trong logo DLU |
|---|---|---|
| `--dlu-cam` | `#F08418` | **Cam đất** — vòng hoa văn, mặt trời (màu chủ đạo logo) |
| `--dlu-reu` | `#607824` | **Xanh rêu** — núi, dòng chữ "ĐẠI HỌC ĐÀ LẠT" |
| `--dlu-reu-dam` | `#3D4E17` | Xanh rêu đậm — nền thanh menu |
| `--dlu-la` | `#90B43C` | **Xanh lá** — sườn núi phía sáng |
| `--dlu-nhat` | `#C0CC84` | Xanh nhạt — đồi thông |
| `--dlu-do` | `#CC2430` | **Đỏ** — ngôi sao |
| `--dlu-hon` | `#3E8E9E` | Xanh hồ Xuân Hương |
| `--dlu-suong` | `#E8EDD8` | Xám sương mù sớm mai |

**Ngôn ngữ thiết kế — Đà Lạt được "dịch" sang màu sắc:**

| Yếu tố thiên nhiên Đà Lạt | Áp dụng vào giao diện |
|---|---|
| Đồi thông trong sương sớm | Nền thanh menu xanh rêu rất đậm `#3D4E17`, chữ trắng ngà ấm |
| Sương mù sớm mai | Nền trang đăng nhập gradient nhạt dần, `backdrop-filter: blur()` cho thẻ |
| Nắng vàng cao nguyên | Nhãn trạng thái "Đang chờ" màu vàng nắng `#FEC95C` |
| Hồ Xuân Hương | Nhãn "Đang xử lý" xanh hồ `#3E8E9E` |
| Ngôi sao đỏ trong logo | Cảnh báo, sự cố khẩn cấp `#CC2430` |
| Bảng màu lá non → rêu → cam | Thanh tiến trình: gradient 3 màu |

**Chi tiết tinh chỉnh đã làm (ngoài đổi màu):**

Giao diện bên trong không còn là GLPI "đổi màu". Nó đọc như một **cuốn sổ theo dõi**:
nền giấy, mực đậm, đường kẻ mảnh — khác hẳn ngôn ngữ thẻ nổi bo tròn của Tabler.

- **Thẻ nội dung mất hẳn vỏ hộp**: bỏ bóng đổ, bỏ bo góc, bỏ viền kín. Chỉ còn **một đường
  kẻ 1px phía trên** làm ranh giới. Bảng dữ liệu nhờ vậy đọc được nhiều dòng hơn trên cùng
  diện tích, và mắt không bị bóng đổ chen vào.
- **Đường kẻ thay cho bóng đổ.** Không dùng bóng để trang trí ở bất kỳ đâu.
- **Bo góc 3–6px** theo bậc thang có chủ ý (nhãn/ô nhập/nút nhỏ 3px, thẻ/khối 6px), thay cho
  10px+ đồng loạt của Tabler.
- **Thanh menu dọc**: nền xanh rêu đậm, **in chìm trường đường bình độ** của chính những dãy
  đồi ở trang đăng nhập → hai mặt tiền của hệ thống thuộc cùng một thế giới.
- **Mục menu đang chọn**: **vạch cam đất 3px bên trái** (lấy từ logo Trường), mục menu phẳng
  `border-radius: 0`, không còn pill bo tròn kiểu Tabler.
- **Đầu bảng dữ liệu**: chữ in hoa nhỏ, giãn chữ, mực phụ — đọc ra "nhãn cột" chứ không phải
  "tiêu đề khối".
- **Số liệu và mã**: phông đều, `font-variant-numeric: tabular-nums` → các chữ số thẳng cột
  dọc theo bảng (mã tài sản kiểu `TDL-PC-A101-001` cần điều này).
- **Thanh cuộn** (scrollbar): màu xanh rêu thương hiệu.
- **Chế độ tối**: nền mực xanh rêu rất tối `#171A11`, chữ sương sớm, thanh menu lùi vào
  `#1E2609`. Ba token giấy/mực đổi tại một chỗ (`PHẦN 0C`), nên không có chuyện nửa sáng nửa tối.

**Trang đăng nhập — được chăm chút kỹ nhất:**

- Nền: gradient 5 điểm dừng `#F4F7EA → #E8EDD8 → #D5DFBB → #B9C98D → #9CB262` (sương mai → rêu)
- **Cảnh đồi Đà Lạt 5 lớp** dựng bằng SVG, xếp lớp phía sau thẻ đăng nhập. Rê chuột thì mỗi
  lớp trôi một nhịp khác nhau (lớp gần trôi nhiều hơn lớp xa) → mắt đọc ra chiều sâu. Đây là
  hiệu ứng chuyển động **duy nhất** của cả hệ thống, và chỉ có ở mặt tiền; bên trong người ta
  đang làm việc thật nên không có chuyển động nào.
- Thẻ đăng nhập: trắng ngà bán trong suốt, bo góc 16px, bóng 2 lớp như sương
- **Dải màu trang trí 4px trên đỉnh thẻ**: gradient xanh rêu → xanh lá → cam đất (nhấn thương hiệu DLU)
- Ô nhập liệu bo góc, nền trắng ngà, focus đổi viền xanh lá
- Nút đăng nhập gradient + bóng màu xanh rêu, hover nâng lên
- **Tắt JavaScript** → trang vẫn nguyên vẹn, chỉ mất cảnh đồi. **Bật "giảm chuyển động"**
  → cảnh vẫn hiện nhưng đứng yên.

**Kiến trúc — phần quan trọng nhất:**

> Bảng màu tự tạo `files/_themes/*.scss` **chỉ được nạp khi đã đăng nhập** (GLPI đọc
> `$_SESSION['glpipalette']` và template trang ẩn danh không đưa file palette vào danh
> sách CSS). Trang đăng nhập **vẫn mang thuộc tính** `data-glpi-theme="da_lat"` — vì
> `$_SESSION['glpipalette']` được nạp từ **cấu hình chung** `glpi_configs.palette`
> (`SessionStart` chép `$CFG_GLPI['palette']` vào phiên ở cả ngữ cảnh ẩn danh) — nhưng
> **file `.scss` thì không được nạp**, nên màu của nó không có tác dụng.
>
> **Giải pháp:** dùng **plugin `dlubrand` chèn CSS ghi đè** qua 2 hook:
> - `ADD_CSS` → trang đã đăng nhập
> - `ADD_CSS_ANONYMOUS_PAGE` → trang ẩn danh (đăng nhập, quên mật khẩu…)
>
> **Ưu điểm lớn:** **KHÔNG sửa file lõi GLPI** → nâng cấp GLPI lên 11.1, 12… **không mất tùy biến**.

**★ NGUỒN MÀU DUY NHẤT cho giao diện GLPI (quan trọng khi bảo trì):**

> Toàn bộ **mã màu của giao diện GLPI** nằm **duy nhất** trong
> `plugins/dlubrand/public/css/dlu-theme.css`.
> Ba file `themes/*.scss` **chỉ còn là "giấy đăng ký"**: GLPI quét thư mục `files/_themes/`
> để **liệt kê** bảng màu trong *Thiết lập của tôi → Giao diện*; **tên file** (không phần mở rộng)
> chính là **key** của bảng màu, tức giá trị `<html data-glpi-theme="...">`. Nội dung file
> chỉ còn phần chú thích, **không chứa mã màu**.
>
> Nhờ vậy: **muốn đổi màu giao diện GLPI → sửa DUY NHẤT 1 file** (`dlu-theme.css`), không còn
> cảnh "sửa màu phải sửa 2 nơi rồi dễ lệch nhau".
>
> **Ngoại lệ đã biết:** trang giới thiệu tĩnh `landing/` do nginx phục vụ **riêng** (không chạy
> qua GLPI) nên **không dùng được** file CSS trên — nó có bảng màu riêng ở
> `landing/assets/css/style.css`. Khi đổi màu thương hiệu, nhớ sửa **cả hai** nơi.

**Cách plugin tách màu theo từng bảng màu:**

> CSS định nghĩa **token ngữ nghĩa** `--dlu-*` cho **từng bảng màu** rồi ánh xạ sang
> biến của GLPI/tabler. Bảng màu **mặc định (`da_lat`)** dùng `:root` trần (áp cho mọi
> trang, kể cả khi chưa kịp có attribute); hai bảng phụ dùng selector **theo giá trị**:
>
> ```css
> :root {                                   /* MẶC ĐỊNH = da_lat (xanh rêu) */
>     --dlu-primary: #607824; ...
> }
> :root[data-glpi-theme="da_lat_suong"]  { --dlu-primary: #3E8E9E; ... }  /* xanh hồ */
> :root[data-glpi-theme="da_lat_nang"]   { --dlu-primary: #F08418; ... }  /* cam đất */
>
> :root[data-glpi-theme] {                  /* ánh xạ chung, chạy cho MỌI bảng màu */
>     --tblr-primary: var(--dlu-primary);
>     --glpi-mainmenu-bg: var(--dlu-primary-dark);
>     ...
> }
> ```
>
> ⚠️ **Bẫy đã từng mắc:** selector `:root[data-glpi-theme]` **chỉ kiểm tra có attribute**,
> **không kiểm tra giá trị** → nó khớp với **mọi** bảng màu. Nếu đặt mã màu trực tiếp
> trong khối đó thì `da_lat_suong` và `da_lat_nang` sẽ **bị ghi đè thành cùng một màu xanh**
> (thực tế đã từng xảy ra: cả 3 bảng màu hiển thị **y hệt nhau**). Cách đúng là **tách mã
> màu vào khối riêng** (mặc định `:root`, hai bảng phụ theo giá trị như trên), chỉ để khối
> ánh xạ chung ở dạng attribute-only.

**Thứ tự nạp — vì sao plugin luôn thắng:** plugin CSS nạp **sau cùng** trên mọi trang
(`ADD_CSS` + `ADD_CSS_ANONYMOUS_PAGE`), còn `themes/*.scss` **chỉ nạp khi đã đăng nhập**.
Vì vậy kể cả khi `.scss` có chứa màu, plugin vẫn ghi đè — đó là lý do **đặt màu ở plugin
là đúng đắn**, còn đặt ở `.scss` sẽ gây hiểu nhầm.

**Logo thương hiệu DLU:** Đã đặt logo chính thức (3 kích cỡ: 100px, 100sq, 250px) và ghi đè 4 biến `--glpi-logo-*`, thay thế hoàn toàn logo Teclib/GLPI ở **cả trang đăng nhập lẫn sau khi đăng nhập**.

> ⚠️ **Bẫy đã từng mắc — đường dẫn logo phải TUYỆT ĐỐI.** Ban đầu viết
> `url("../pics/logos/logo-DLU-100.png")`. Trình duyệt phân giải `url()` trong biến CSS
> theo **stylesheet đang dùng biến**, không phải stylesheet khai báo biến. GLPI dùng
> `--glpi-logo-*` trong `/css_compiled/css_glpi.min.css`, nên `../pics/logos/...` bị hiểu
> thành `/pics/logos/...` → **404, logo vỡ**. Sửa thành
> `/plugins/dlubrand/pics/logos/logo-DLU-100.png` thì đúng trong mọi ngữ cảnh phân giải.

**Việt hoá giao diện sau đăng nhập — lỗi đã phát hiện và sửa:**

> Bốn tài khoản do **chính trình cài đặt GLPI** tạo (`glpi`, `tech`, `normal`, `post-only`)
> mang sẵn `language = 'en_GB'`. Ngôn ngữ **lưu theo từng tài khoản luôn thắng** ngôn ngữ
> mặc định của hệ thống, nên dù `glpi_configs.language` đã là `vi_VN`, đăng nhập bằng `tech`
> vẫn hiện giao diện **tiếng Anh** (`Assets / Assistance / Management`). Script
> `seed-du-lieu-mau.sql` nay đặt `language = 'vi_VN'` cho **cả bốn tài khoản này**, không
> chỉ sáu tài khoản mẫu.

**Hồ sơ (vai trò) của tài khoản kỹ thuật viên — lỗi đã phát hiện và sửa:**

> Script cũ gán **tất cả** tài khoản mẫu vào hồ sơ `profiles_id = 1` ("Người dùng"), vốn
> thuộc **giao diện helpdesk** (tự phục vụ). Vì vậy `ktv.an` / `ktv.binh` mang danh "kỹ thuật
> viên" mà **không mở được bảng điều khiển**, không thấy menu *Tài sản / Hỗ trợ / Quản lý* —
> trong khi README lại ghi hai tài khoản đó là "Kỹ thuật viên". Nay script tra cứu hồ sơ
> **theo tên** (`'Kỹ thuật viên'` cho hai tài khoản ktv, `'Người dùng'` cho phần còn lại),
> không phụ thuộc vào thứ tự id.

---

### 2.4. Dữ liệu nền — bản gốc RỖNG HOÀN TOÀN

**Bản gốc:** Sau khi cài, GLPI **không có bất kỳ dữ liệu nghiệp vụ nào**. Người dùng phải tự tạo từng danh mục bằng tay qua giao diện — rất tốn thời gian, dễ sai, không nhất quán.

**Bản đồ án đã làm:** Script `nap-du-lieu-nen.sh` + `seed-du-lieu-nen.sql` (**664 dòng**) dựng sẵn **23 nhóm danh mục**:

| # | Danh mục | Số lượng | Giá trị thực tế |
|---|---|---|---|
| 1 | **Vị trí** (3 cấp) | **67** | 1 khuôn viên → **12 tòa nhà** → **54 phòng** (phòng máy, lab, phòng ban) |
| 2 | Trạng thái thiết bị | 10 | Đang dùng, đang sửa, chờ thanh lý, thanh lý… |
| 3 | Hãng sản xuất | 24 | Dell, HP, Lenovo, Asus, Acer, Epson, Canon… |
| 4 | Loại thiết bị | 35 | 5 loại máy tính + 5 màn hình + 5 máy in + 12 ngoại vi + 8 thiết bị mạng |
| 5 | Model thiết bị | 55 | 20 model máy tính + 10 màn hình + 10 máy in + 15 thiết bị mạng |
| 6 | **Loại sự cố** (2 cấp) | **79** | **10 nhóm chính + 69 chi tiết** |
| 7 | Nguồn tiếp nhận sự cố | 11 | 5 nguồn của đồ án (**Báo qua mã QR**…) + 6 nguồn gốc của GLPI |
| 8 | Hình thức xử lý | 11 | Thay linh kiện, cài lại OS, vệ sinh, đổi dự phòng… |
| 9 | Nhóm phần mềm | 11 | 10 nhóm của đồ án + 1 mục gốc của GLPI |
| 10 | **Nhóm / đơn vị** | **36** | **Cơ cấu tổ chức THẬT của DLU** (xem dưới) |

**Đặc biệt — Mục 10: Cơ cấu tổ chức thật của Trường Đại học Đà Lạt**

Lấy từ website chính thức `dlu.edu.vn`, dựng thành **cây 2 cấp** trong GLPI:

```
Khoa                    (nhóm cấp 1)
└── 16 khoa chuyên môn  (Khoa Toán – Tin học, Khoa Sinh học, …)

Phòng chức năng         (nhóm cấp 1)
└── 10 phòng ban        (Phòng Quản trị Cơ sở vật chất, Phòng Đào tạo, …)

Trung tâm và Viện       (nhóm cấp 1)
└── 6 trung tâm + 1 viện
```

Hai đơn vị được chú thích rõ vì là **khách hàng chính** của hệ thống:
- **Phòng Quản trị Cơ sở vật chất** — *đơn vị chủ quản tài sản*
- **Trung tâm Công nghệ thông tin** — *đơn vị vận hành kỹ thuật* (đội kỹ thuật viên)

> Dùng để: phân quyền, gán người dùng, và **thống kê thiết bị theo đơn vị** trên dashboard.

**Đặc tính kỹ thuật quan trọng:**

- **Idempotent** — mọi câu `INSERT` đều có `WHERE NOT EXISTS`. Chạy lại **bao nhiêu lần cũng không sinh dữ liệu trùng**.
- **Có báo cáo kết quả** — script in ra bảng tổng kết 21 dòng để xác nhận dữ liệu đã vào.
- **Ghi rõ nguồn** — phần cơ cấu tổ chức ghi rõ "Nguồn: website chính thức dlu.edu.vn (truy cập 19/09/2026)".

---

### 2.5. Hạ tầng — từ 1 container SQLite lên 4 container production

**Bản gốc:**

```bash
docker run -d -p 80:80 glpi/glpi:11.0.0
```

Mặc định dùng **SQLite**, không HTTPS, không cache, không reverse proxy, không giới hạn tài nguyên — **không đủ điều kiện triển khai**.

**Bản đồ án — kiến trúc 4 tầng:**

```
        ┌─────────────────────────────────────────────┐
        │  pinedesk-gateway   (nginx:1.27-alpine)     │
        │  HTTPS 8443 · TLS 1.2/1.3 · Rate limit      │
        └────────────────────┬────────────────────────┘
                             │ frontend_net
        ┌────────────────────▼────────────────────────┐
        │  pinedesk-glpi      (glpi/glpi:11.0.0)      │
        │  Ứng dụng ITSM · PHP · plugin               │
        └──────────┬──────────────────────┬───────────┘
                   │ backend_net          │
     ┌─────────────▼──────────┐  ┌────────▼──────────┐
     │ pinedesk-db            │  │ pinedesk-redis    │
     │ mariadb:10.11          │  │ redis:7-alpine    │
     │ utf8mb4, +07:00, 512M  │  │ cache/lock 256MB  │
     └────────────────────────┘  └───────────────────┘
```

**Cải thiện cụ thể:**

| Hạng mục | Chi tiết |
|---|---|
| **Tách mạng** | `frontend_net` (gateway ↔ glpi) và `backend_net` (glpi ↔ db/redis) — CSDL **không** lộ ra ngoài |
| **Phiên bản cố định** | Ghim `nginx:1.27-alpine`, `glpi/glpi:11.0.0`, `mariadb:10.11`, `redis:7-alpine` — tránh vỡ khi upstream đổi |
| **UTF-8 toàn phần** | `utf8mb4` + `utf8mb4_unicode_ci` — **bắt buộc** để lưu tiếng Việt có dấu và emoji |
| **Múi giờ** | `Asia/Ho_Chi_Minh` xuyên suốt PHP + MariaDB + container |
| **Healthcheck** | 3/4 container có healthcheck; `glpi` chờ `mariadb: service_healthy` mới khởi động |
| **Redis cache** | `--maxmemory 256mb --maxmemory-policy allkeys-lru`, có mật khẩu (`requirepass`) |
| **Tối ưu InnoDB** | `innodb-buffer-pool-size=512M` |
| **Volume bền vững** | 6 named volume — dữ liệu sống sót khi `docker-compose down` hoặc nâng cấp image |
| **Volume lồng nhau** | Mount `./plugins/dlubrand` **nested** trên `glpi_plugins` — sửa plugin trực tiếp trên host mà **không mất plugin barcode** |

**Cấu hình PHP tùy chỉnh** (`config/php-custom.ini`, mount read-only — không sửa image gốc):

| Tham số | Giá trị | Lý do |
|---|---|---|
| `upload_max_filesize` / `post_max_size` | 64M | Đính kèm ảnh sự cố, hồ sơ thiết bị |
| `memory_limit` | 512M | GLPI 11 + báo cáo lớn |
| `max_execution_time` / `max_input_time` | 600s | Xuất báo cáo, sinh QR hàng loạt |
| `max_input_vars` | 5.000 | Biểu mẫu nhiều trường |
| `date.timezone` | `Asia/Ho_Chi_Minh` | Giờ Việt Nam |
| **`session.cookie_httponly`** | **On** | **Chặn JavaScript đọc cookie phiên — chống XSS đánh cắp phiên** |
| **`session.cookie_samesite`** | **Strict** | **Chặn cookie gửi chéo trang — chống CSRF (mức cao nhất)** |
| `session.gc_maxlifetime` | 28800 (8h) | Một ngày làm việc |
| `expose_php` | **Off** | **Ẩn phiên bản PHP — giảm phơi bày thông tin** |
| `log_errors` | On → `/var/www/glpi/files/_log/php-error.log` | Có log để debug |
| **`session.cookie_secure`** | **On** | **Chỉ gửi cookie phiên qua HTTPS.** Đi kèm bắt buộc `config/apache-forwarded-proto.conf` + header ở healthcheck (xem mục 3.2) |

---

### 2.6. Bảo mật — bản gốc gần như không cấu hình gì

**Bản gốc:** Không HTTPS, không header bảo mật, không rate limit, không chặn file nhạy cảm.

**Bản đồ án — đã bổ sung 5 lớp:**

**Lớp 1 — HTTPS & TLS** (`nginx/conf.d/default.conf`)

- HTTP :8080 → redirect 301 sang HTTPS :8443
- Chỉ cho phép **TLS 1.2 và 1.3** (loại bỏ SSLv3, TLS 1.0/1.1 đã lỗi thời)
- Bộ cipher hiện đại (ECDHE + AES-GCM / CHACHA20)
- `ssl_session_cache`, `ssl_session_tickets off`
- Hỗ trợ `http2`

**Lớp 2 — Header bảo mật (5 header)**

| Header | Giá trị | Chống được gì |
|---|---|---|
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains` | Buộc HTTPS trong 1 năm |
| `X-Frame-Options` | `SAMEORIGIN` | **Clickjacking** (nhúng trang vào iframe lạ) |
| `X-Content-Type-Options` | `nosniff` | **Đoán nội dung MIME** |
| `Referrer-Policy` | `strict-origin-when-cross-origin` | Rò rỉ thông tin khi chuyển trang |
| `Permissions-Policy` | `geolocation=(), microphone=(), camera=()` | Tắt tính năng trình duyệt nguy hiểm |

**Lớp 3 — Rate limiting 2 tầng (chống brute-force)**

```nginx
limit_req_zone $binary_remote_addr zone=login_zone:10m rate=10r/m;
limit_req_zone $binary_remote_addr zone=general_zone:10m rate=600r/m;
limit_req_status 429;
```

- **Trang đăng nhập**: 10 request/phút → chặn dò mật khẩu
- **Toàn hệ thống**: 600 request/phút, burst 200
- **Tài nguyên tĩnh được MIỄN rate limit** + cache 7 ngày

> 🐛 **Lỗi thực tế đã gặp và sửa:** ban đầu đặt `general_zone = 120r/m`. GLPI 11 nạp **hàng trăm file CSS/JS/font mỗi trang** → vượt hạn mức → **503 Service Temporarily Unavailable** trên trình duyệt thật. Đáng chú ý: **`curl` không phát hiện được lỗi này** vì chỉ tải 1 file/request.
>
> **Bài học: bắt buộc phải test bằng trình duyệt thật.** Tìm ra nguyên nhân trong `docker logs pinedesk-gateway`: `limiting requests, excess: 40.838 by zone "general_zone"`.

**Lớp 4 — Chặn truy cập file nhạy cảm**

```nginx
location ~ /\.            { deny all; return 404; }   # .env, .git
location ~* \.(ini|log|sh|sql|bak|conf|yml|yaml|lock|dist)$ { deny all; }
location ~* /(config|files/_log|files/_cron|files/_dumps|files/_sessions)/ { deny all; }
```

> 🐛 **Lỗi thực tế #2:** regex chặn file ban đầu có nhánh `|json`. Nhưng `|json` trong nhóm alternation bị hiểu thành **chuỗi literal `njson`** → **vô tình chặn luôn `.png`** → logo DLU trả 404.
>
> **Đã sửa:** bỏ `png`/`json`/`md` khỏi danh sách chặn (giải thích rõ trong comment của file config), **giữ nguyên** các đuôi nguy hiểm `ini/log/sh/sql/bak/conf/yml/dist/lock`.

**Lớp 5 — Bảo mật phiên làm việc**

- `session.cookie_httponly = On` — JS không đọc được cookie phiên
- `session.cookie_samesite = Lax` — chống CSRF
- `session.gc_maxlifetime = 28800` — phiên hết hạn sau 8 giờ
- `expose_php = Off` — ẩn phiên bản PHP
- `.gitignore` chặn commit: `.env`, chứng chỉ SSL `*.crt`/`*.key`/`*.pem`, file sao lưu `*.sql`/`*.tar.gz`

**Cấu trúc thư mục dữ liệu — điểm dễ sai:**

> Ảnh `glpi/glpi` dùng **`/var/glpi`** làm thư mục dữ liệu, **KHÔNG phải `/var/www/glpi`**:
> - `/var/glpi/config` → cấu hình
> - `/var/glpi/files` → `_themes`, `_locales`, `_cache`, `_log`, `_plugins`, `_uploads`
> - `/var/glpi/marketplace` → plugin tải từ chợ
> - `/var/www/glpi/plugins` → plugin cài thủ công
> - `/var/www/glpi/public` → **web root thực tế**
>
> Nhầm chỗ này là nguyên nhân phổ biến khiến bảng màu / bản dịch "cài rồi mà không thấy".

---

### 2.7. Plugin sinh mã QR — phải tự tích hợp và vá lỗi

**Bản gốc:** GLPI **không có** chức năng sinh mã QR cho thiết bị. Phải tự tìm, cài và cấu hình plugin bên thứ ba.

**Bản đồ án đã làm:** Tích hợp **plugin Barcode 2.7.1** và **vá 2 lỗi âm thầm** khiến plugin không hoạt động.

**Hai lỗi đã gặp và cách xử lý:**

| # | Lỗi | Biểu hiện | Nguyên nhân | Cách sửa |
|---|---|---|---|---|
| 1 | **Không sinh được PDF, không báo lỗi** | Bấm "Create" → báo thành công nhưng **không có file nào** | Thư mục `/var/glpi/files/_plugins/barcode/` **không tồn tại** → `file_put_contents()` trong `barcode.class.php:428` **thất bại im lặng** (plugin không kiểm tra giá trị trả về) | `mkdir -p /var/glpi/files/_plugins/barcode` + `chown www-data` |
| 2 | **Mục QR không xuất hiện trong menu** | Menu "Các hành động" **thiếu** dòng `Barcode - Print QRcodes` | Không profile nào có quyền `plugin_barcode_config` (plugin đăng ký tuỳ chọn dựa trên quyền này) | `UPDATE glpi_profilerights` cấp quyền `plugin_barcode_barcode` = 31 và chèn `plugin_barcode_config` |

> Cả hai lỗi này **rất khó tìm** vì plugin không hề báo lỗi. Đã ghi lại đầy đủ ở mục 6.4 của `HUONG-DAN-PLUGIN-QRCODE.md`.

**Hiểu đúng cách dùng plugin (điểm dễ hiểu sai):**

> Plugin Barcode **KHÔNG có tab riêng** trên hồ sơ thiết bị. Nó **chỉ hoạt động qua "Các hành động" (Massive Action)**:
>
> 1. Tick chọn thiết bị trong danh sách
> 2. Bấm nút **"Các hành động"**
> 3. Chọn **`Barcode - Print QRcodes`**
> 4. Cấu hình khổ giấy / hướng / đường viền / nhãn
> 5. Bấm **Create** → sinh PDF

**Đã kiểm chứng chạy thật:** sinh ra `2_QRcode.pdf` (**18.813 bytes**, 1 trang, nhúng 1 ảnh, kết thúc đúng `%%EOF`), render ra ảnh cho thấy **mã QR quét được**, nhãn `PC-TEST-QR-DLU-001`. Đã xóa thiết bị test sau khi kiểm tra.

**Phương án dự phòng:** `sinh-ma-qr.py` (**342 dòng**) dùng thư viện `qrcode[pil]` + `reportlab` sinh QR hàng loạt ngoài GLPI — dùng khi cần in nhãn số lượng lớn hoặc plugin gặp sự cố. Đã kiểm chứng: tạo PDF 10 nhãn + 10 file QR PNG.

---

### 2.8. Tự động hóa — từ thao tác tay lên 1 lệnh

**Bản gốc:** Cài đặt, cấu hình, nạp dữ liệu, cài plugin — **toàn bộ thủ công qua giao diện web**, hàng chục bước.

**Bản đồ án đã làm:**

| Script | Dòng | Chức năng |
|---|---|---|
| **`cai-dat-tat-ca.sh`** | **257** | ⭐ **Cài toàn bộ 5 bước, 1 lệnh duy nhất** |
| `start.sh` | 168 | Khởi động + kiểm tra Docker + tạo SSL + cảnh báo mật khẩu mặc định |
| `lib/compose-guard.sh` | 85 | Phanh an toàn: tự `down` khi cờ `internal` của mạng đã lệch |
| `nap-du-lieu-nen.sh` | 71 | Nạp dữ liệu nền |
| `seed-du-lieu-nen.sql` | **664** | 23 nhóm danh mục nghiệp vụ |
| `cai-plugin-qrcode.sh` | 197 | Cài + cấu hình plugin QR |
| `cai-giao-dien.sh` | 152 | Cài giao diện |
| `cai-ban-dich.sh` | 78 | Cài bản dịch |
| `backup/backup.sh` | — | Sao lưu CSDL + files + config, tự dọn bản cũ |

**`cai-dat-tat-ca.sh` — 5 bước tự động:**

```
[1/5] Khởi động 4 container
[2/5] Nạp dữ liệu nền (23 nhóm danh mục + cơ cấu tổ chức DLU)
[3/5] Kích hoạt plugin + tạo thư mục QR + cấp quyền barcode
[4/5] Cài bản dịch tiếng Việt đã gộp
[5/5] Kiểm tra sức khỏe — 5 phép kiểm tra
```

**Kết quả chạy thật (đã xác nhận):**

```
[ OK ] Trang đăng nhập         : HTTP 200
[ OK ] CSS giao diện Đà Lạt    : HTTP 200
[ OK ] Logo DLU                : HTTP 200
[ OK ] Bản dịch tiếng Việt     : đã cài
[ OK ] Plugin đang hoạt động   : 2 plugin (Barcode, DLU Brand)
```

> 🐛 **Lỗi thực tế #3 — Git Bash trên Windows:** script dịch bị lỗi `can't open file 'G:\g\duong-dan-du-an\scripts\...'`. Nguyên nhân: `pwd` trong Git Bash trả về đường dẫn POSIX `/g/duong-dan-du-an`, Python hiểu sai thành `\g\duong-dan-du-an`.
>
> **Đã sửa:** hàm `_winpath()` dùng `pwd -W` để lấy đường dẫn Windows thật, kèm `MSYS_NO_PATHCONV=1` và `MSYS2_ARG_CONV_EXCL='*'`.

---

### 2.9. Sao lưu & phục hồi

**Bản gốc:** Không có công cụ sao lưu sẵn.

**Bản đồ án:** `backup/backup.sh`

- Sao lưu **3 thành phần**: CSDL MariaDB (`.sql`), thư mục files (`_uploads`, `_themes`, `_locales`…), cấu hình
- Tên file có **timestamp**: `glpi_backup_20260919_034151_db.sql`
- **Tự dọn bản cũ**, mặc định giữ 7 bản gần nhất → không đầy ổ cứng
- Tùy chọn: `--keep 30` (giữ 30 bản), `--dir /path` (đổi thư mục)
- Hướng dẫn **hẹn lịch tự động** bằng Windows Task Scheduler (chạy 23:00 hằng ngày)
- Kiểm tra container `pinedesk-db` đang chạy trước khi dump

---

### 2.10. Kiểm thử tự động

**Bản gốc:** Không có script kiểm thử cho người triển khai.

**Bản đồ án:**

| Script | Công cụ | Kiểm tra gì |
|---|---|---|
| `do-do-phu-tieng-viet.py` | Python | Đọc `.mo` **thực tế trong container**, đo tỉ lệ Việt hóa, phân loại chuỗi thiếu theo nhóm nghiệp vụ |
| `kiem-tra-tieng-viet.py` | Python | Đo tỉ lệ Việt hóa từ `.mo` **đang cài trong GLPI** (cùng công thức với `do-do-phu-tieng-viet.py`) |
| `chup-lai-anh-minh-chung.js` | Puppeteer + Chrome | Chụp **19 ảnh minh chứng** cho README, mỗi màn hình một ảnh, tự bỏ qua trang thiếu quyền |
| `chup-anh-qr-admin.js` | Puppeteer + Chrome | Chụp luồng in QR qua plugin Barcode bằng tài khoản quản trị |
| `kiem-tra-massive-qr.js` | Puppeteer + Chrome | **Kiểm tra luồng sinh QR qua Massive Action** end-to-end |
| `kiem-tra-qr-va-chup-anh.js` | Puppeteer + Chrome | Kiểm tra + chụp ảnh kết quả QR |

> Điểm quan trọng: các script kiểm thử dùng **trình duyệt thật (Chrome headless)**, không dùng `curl`. Đây chính là cách phát hiện lỗi rate limit 503 mà `curl` bỏ qua.

---

### 2.11. Dữ liệu mẫu để demo — bản gốc hoàn toàn không có

**Bản gốc:** GLPI gốc cài xong là **CSDL rỗng** — 0 thiết bị, 0 phiếu, 0 người dùng khác ngoài `glpi`.
Bảng điều khiển trống trơn, **không thể demo** cho hội đồng.

**Bản đồ án:** `scripts/seed-du-lieu-mau.sql` + `scripts/nap-du-lieu-mau.sh`

Chạy **một lệnh** là có ngay dữ liệu để trình diễn:

```bash
bash scripts/nap-du-lieu-mau.sh
```

| Kết quả tạo ra | Số lượng |
|---|---|
| Người dùng mẫu (3 vai trò) | 6 |
| Máy tính để bàn | 12 |
| Máy tính xách tay | 3 |
| Máy chủ | 2 |
| Màn hình | 5 |
| Máy in | 3 |
| Phần mềm | 10 |
| **Phiếu sự cố (đủ 4 trạng thái)** | **13** |

**Tài khoản demo** — mật khẩu chung `Dlu@2026`:

| Tài khoản | Vai trò |
|---|---|
| `ktv.an`, `ktv.binh` | Kỹ thuật viên |
| `gv.cuong`, `gv.dung` | Giảng viên |
| `sv.hoa`, `sv.khanh` | Sinh viên |

**Đặc điểm kỹ thuật đáng chú ý:**

- **Idempotent** — chạy lại nhiều lần cho kết quả y hệt, không nhân đôi dữ liệu
  (mọi `INSERT` đều có `WHERE NOT EXISTS`).
- **Mã tài sản theo quy ước thật**: `TDL-PC-A101-001` = Đại học Đà Lạt – Máy tính –
  Toà A – Phòng 101 – Máy 01. Nhìn mã là biết ngay thiết bị nằm ở đâu.
- **Dữ liệu khớp 100% với danh mục đã nạp** — không có trường tham chiếu nào bị rỗng
  (đã kiểm chứng bằng script kiểm tra chất lượng dữ liệu).
- **Phiếu trải đủ 4 trạng thái** (Mới / Được giao / Đã giải quyết / Đã đóng) để
  biểu đồ trạng thái trên bảng điều khiển có dữ liệu thật.
- **Mật khẩu đặt qua PHP `password_hash()`** rồi `docker cp` vào container — không
  thể đặt bằng SQL thuần vì GLPI 11 dùng bcrypt (`$2y$...`), và ký tự `$` sẽ bị
  shell nuốt mất nếu truyền qua dòng lệnh.

**Đã phải xử lý thêm — tắt chế độ demo của GLPI:**

GLPI 11 mặc định bật `is_demo_dashboards = 1`, khiến bảng điều khiển hiển thị
**dữ liệu giả** (114,7K phần mềm, 5,4K máy tính) đè lên dữ liệu thật. Đã đặt về `0`:

```sql
UPDATE glpi_configs SET value='0' WHERE name='is_demo_dashboards';
```

Sau khi tắt, bảng điều khiển hiển thị đúng số liệu thật của trường:
**17 máy tính · 5 màn hình · 3 máy in · 9 thiết bị mạng · 10 phần mềm · 13 phiếu**,
và biểu đồ phân bố theo **các khoa/phòng thật của DLU**.

---

### 2.12. Lỗi phát hiện được khi kiểm thử sâu (và cách khắc phục)

Đây là phần **trung thực nhất** của tài liệu: những lỗi chỉ lộ ra khi chạy thử thật,
không thể thấy bằng cách đọc mã nguồn.

| # | Lỗi | Triệu chứng | Nguyên nhân gốc | Cách khắc phục |
|---|---|---|---|---|
| 1 | **Mã QR in ra trỏ sai địa chỉ** | Quét mã trên nhãn in → không mở được | `glpi_configs.url_base = http://localhost` — thiếu `https` và thiếu cổng `8443` | Cập nhật `url_base = https://localhost:8443`, sinh lại nhãn, **giải mã QR kiểm chứng** đã đúng |
| 2 | **Bảng điều khiển hiện dữ liệu giả** | Thấy 114,7K phần mềm, 5,4K máy tính | GLPI 11 bật sẵn `is_demo_dashboards = 1` | Đặt về `0` |
| 3 | **9 nhãn thẻ đếm trạng thái phiếu vẫn tiếng Anh** | Hàng thẻ trên trang Hỗ trợ hiện *Incoming/Pending/Assigned/Solved/Closed tickets* | Bản dịch `vi_VN` chính thức của GLPI **không có** các chuỗi này | Thêm 9 thuật ngữ vào `BAN_DICH_BO_SUNG`, gộp lại, kiểm chứng bằng trình duyệt: **hết tiếng Anh** |
| 4 | **File cấu hình PHP bị lặp khối** | Khối nội dung bị chép 2 lần trong `php-custom.ini` | Lỗi soạn thảo | Viết lại file, thêm chú thích thứ tự nạp |
| 5 | **Cấu hình làm YẾU bảo mật** | `session.cookie_samesite = Lax` **ghi đè** giá trị `Strict` mà image GLPI đã đặt | Không để ý image đã cấu hình sẵn | Khôi phục về `Strict`; **kiểm chứng bằng header `Set-Cookie` thật** sau khi khởi động lại container |
| 6 | **`max_execution_time` tưởng như không có tác dụng** | `php -r` báo giá trị `0` / `-1` | **Báo động giả** — PHP CLI luôn ép 2 giá trị này; chỉ web SAPI mới phản ánh đúng | Dò qua HTTP (Apache) → đúng `600`/`600`. Ghi chú lại vào file cấu hình |
| 7 | **Mật khẩu tài khoản mẫu không đặt được** | Đăng nhập thất bại dù SQL báo thành công | Chuỗi bcrypt chứa `$`; shell nội suy `$2y$` thành rỗng → lưu `y2Vy3gDY...` | Ghi hash ra **file** rồi `docker cp` vào container, đọc lại bằng `cat` |
| 8 | **Dữ liệu mẫu tham chiếu danh mục không tồn tại** | Lỗi `Unknown column` / tham chiếu rỗng | 12 tên loại sự cố + 5 tên nhóm phần mềm **tự nghĩ ra**, không có trong CSDL | Truy vấn CSDL lấy **tên thật**, sửa lại toàn bộ |
| 9 | **Trang đăng nhập hiện TIẾNG ANH với trình duyệt cấu hình tiếng Anh** | Chrome/Firefox để tiếng Anh → trang đăng nhập là *Authentication - GLPI* | GLPI chọn ngôn ngữ theo header `Accept-Language` của trình duyệt **trước**, rồi mới tới ngôn ngữ mặc định. Thứ tự khởi động: `SessionStart(130)` → `LoadLanguage(120)` → `InitializePlugins(110)` — plugin chạy **sau** khi ngôn ngữ đã chốt, nên **không hook nào của plugin sửa được** | Ghi đè `Accept-Language` thành `vi-VN` **tại tầng gateway nginx** cho trang đăng nhập (không sửa lõi) |
| 10 | **`ADD_HEADER_TAG_ANONYMOUS_PAGE` gây lỗi 500** | Trang trắng, log ghi *"Only arrays and Traversables can be unpacked, string given"* | Hook này được GLPI đọc **trực tiếp như một mảng thẻ header**, **không** gọi callback. Gán tên hàm (chuỗi) → Twig spread chuỗi → crash | Nhận diện đúng cơ chế, bỏ cách làm sai, ghi chú lại để tránh lặp lại |
| 11 | **Nhãn "Ticket" trên dashboard vẫn tiếng Anh** dù từ điển đã có `Ticket → Phiếu yêu cầu` | Thẻ số liệu hiện `13 Ticket`, trong khi **mọi thẻ khác đã tiếng Việt** | GLPI gọi `_n()` → `translatePlural()` → tra **entry có `msgid_plural`**, **không** dùng entry `msgid` đơn. Bản dịch `vi_VN` chính thức để `msgstr[0] "Ticket"` (chưa dịch) ở entry số nhiều. Từ điển chỉ tác động lên entry đơn → **không chạm tới entry số nhiều** | Thêm bảng `BAN_DICH_SO_NHIEU` + hàm `va_entry_so_nhieu()` vá thẳng entry có ký tự `\0` |
| 12 | **Sửa `landing/index.html` nhưng trang vẫn hiển thị bản cũ** | File trên host 22.062 bytes (đã sửa), trong container vẫn 21.800 bytes (bản cũ); **file mới tạo không xuất hiện** | Bind mount `./landing:/usr/share/nginx/html/landing:ro` của Docker Desktop trên Windows **ngừng lan truyền thay đổi** — `docker restart` cũng **không** khôi phục | `docker-compose up -d --force-recreate nginx`. Kiểm chứng bằng cách tạo **file đánh dấu** trên host rồi `ls` trong container |
| 13 | **Chữ tiếng Việt bị hụt khoảng cách, dấu hiện sai** (`Hệ thô  ng`) | Chữ **có dấu** rơi về font hệ thống, chữ **không dấu** dùng font chính → hai mặt chữ khác nhau trên cùng một dòng | Script tải font đặt **trùng tên tệp** cho hai tập ký tự khác nhau: `...-vietnamese.woff2` và `...-latin.woff2` cùng ghi vào **một** tên → **tập tải sau ghi đè tập trước**, tệp còn lại thiếu ký tự Latin | Đặt tên tệp kèm tên tập ký tự (`be-vietnam-pro-400-vietnamese.woff2`). Thêm `scripts/kiem-tra-font.py` đọc **bảng ký tự thật** trong tệp `.woff2` để bắt đúng loại lỗi này |

> **Bài học chung:** cả 13 lỗi đều **im lặng** — không crash, không báo lỗi rõ ràng.
> Chỉ phát hiện được bằng cách **chạy thật rồi kiểm chứng kết quả đầu ra**
> (giải mã lại mã QR, đọc header HTTP thật, đọc log GLPI, mở trình duyệt thật).
>
> **Riêng lỗi #9 và #10** cho thấy một điều quan trọng: **không phải lỗi nào cũng
> sửa được ở tầng plugin.** Khi thứ tự khởi động của framework không cho phép,
> giải pháp đúng là can thiệp ở **tầng hạ tầng** (gateway) — vẫn giữ nguyên
> nguyên tắc *không sửa mã nguồn lõi*.

### 2.13. Trang giới thiệu dự án (Landing page)

GLPI gốc **không có trang giới thiệu** — người mới truy cập chỉ thấy ngay màn hình
đăng nhập, không biết hệ thống dùng để làm gì. Đồ án bổ sung một landing page
phục vụ trình diễn trước hội đồng.

**Truy cập:** `https://localhost:8443/landing/`

| Nội dung | Mô tả |
|---|---|
| Khung cảnh Đà Lạt | Năm lớp đồi xếp chồng nhạt dần, rừng thông ở lớp gần nhất, hai dải sương trôi — vẽ bằng SVG |
| Cửa sổ sản phẩm | Khung trình duyệt chứa ảnh dashboard thật, đặt trên sườn đồi |
| Quy mô | 4 chỉ số thật: 4 dịch vụ · 34 tài sản · 556 thuật ngữ Việt hoá · 0đ bản quyền |
| Tính năng nổi bật | Mã QR · Quy trình sự cố ITIL · Dashboard thống kê · An toàn dữ liệu |
| Mặt cắt kiến trúc | Năm lớp xếp chồng như sườn đồi, đưa chuột lên một lớp thì dải tương ứng sáng lên |
| Bốn dịch vụ Docker | `pinedesk-gateway` · `pinedesk-glpi` · `pinedesk-db` · `pinedesk-redis`, kèm lệnh chạy |
| Tài khoản demo | 6 tài khoản 3 vai trò — **bấm để copy**, kèm mật khẩu chung |
| Tài liệu | Sáu thẻ dẫn tới `tai-lieu/*.md` và `README.md` |

#### Chất liệu tạo hình — lấy từ chính DLU và Đà Lạt

Trang **không dùng giao diện mẫu có sẵn**. Mọi chi tiết tạo hình đều có nguồn:

| Nguồn thật | Thể hiện trên trang |
|---|---|
| **Đồi thông Đà Lạt** | Năm lớp đồi nhạt dần theo tầm nhìn xa, rừng thông ở lớp gần nhất |
| **Khí hậu cao nguyên** | Hai dải sương trôi chậm giữa các lớp đồi; nền trang là sắc sương sớm |
| **Dải lá xanh + sao đỏ** trong logo | Bảng màu chủ đạo: xanh rêu `#607824`, dải lá `#90B43C`, cam đất `#F08418`, đỏ sao `#CC2430` |
| **Kiến trúc Pháp cổ** của thành phố | Chữ tiêu đề **Fraunces** (serif), thân bài **Be Vietnam Pro** |

#### Bốn quyết định kỹ thuật quan trọng

1. **Không phụ thuộc CDN.** Bản đầu dùng Tailwind CSS + Font Awesome từ CDN →
   **phòng bảo vệ không có mạng là trang mất toàn bộ giao diện**. Đã thay bằng
   **CSS tự viết** và **16 tệp font `.woff2` tự lưu** trong `landing/fonts/`
   (có subset tiếng Việt). Cả thư mục `landing/` gọn còn **~600 KB**, phần lớn
   là ảnh dashboard (trước ~2,1 MB).

2. **Liên kết tương đối, không hardcode `localhost`.** Ban đầu 3 nút đều trỏ
   `https://localhost:8443` → **mở từ máy khác trong mạng LAN là hỏng ngay**
   (vì `localhost` trỏ về chính máy người xem). Đổi thành `/` và `/front/login.php`
   để hoạt động với mọi tên miền/IP. *Cùng loại lỗi với lỗi `url_base` của mã QR.*

3. **Ảnh dashboard lấy từ dữ liệu thật.** Ảnh đầu tiên chụp **trước khi tắt chế độ
   demo** nên hiển thị `114,7K phần mềm`, tên người nước ngoài (*May Sharon,
   Mcmahan Theod…*) và cả dòng chữ **"You are viewing demonstration data"** —
   hoàn toàn không khớp với hệ thống thật. Đã sinh lại bằng
   `node scripts/chup-anh-dashboard.js` (tự đăng nhập, chụp, và ẩn banner cảnh báo
   kỹ thuật tạm thời).

4. **Không dùng hiệu ứng xuất hiện khi cuộn.** Bản trước gắn lớp `.reveal` cho
   từng mục rồi cho mờ dần hiện ra lúc cuộn tới. Cách đó vừa là mẫu thiết kế
   chung chung, vừa có rủi ro: nếu JavaScript lỗi hoặc bị tắt thì nội dung
   vẫn nằm ở `opacity: 0`. Bản này bỏ hẳn hiệu ứng cuộn — **nội dung hiện đầy
   đủ ngay cả khi JavaScript bị tắt**. JavaScript chỉ còn lo hai việc: sao chép
   tài khoản và làm sáng dải mặt cắt khi đưa chuột lên một lớp.

**Kiểm thử:**

| Script | Kiểm cái gì |
|---|---|
| `node scripts/kiem-tra-landing.js` | Tài nguyên tải được, font nạp đúng, **mọi anchor nội bộ tồn tại** (đã phát hiện nút *"Tổng quan"* trỏ vào `#tong-quan` **không tồn tại**), lỗi console |
| `python scripts/kiem-tra-font.py` | Đọc **bảng ký tự thật** trong từng tệp `.woff2`, đối chiếu với **chữ thật có trên trang** — bắt được lỗi #13 |

> **Lưu ý về cách kiểm tra font:** `document.fonts.check()` của trình duyệt
> **không dùng được** để kiểm việc này — nó chỉ xét `unicode-range` khai báo
> trong `@font-face`, **không đọc bảng ký tự thật trong tệp**, nên vẫn báo "OK"
> khi tệp thiếu chữ có dấu. Phải đọc trực tiếp bảng `cmap` của tệp `.woff2`.

---

## 3. NHỮNG FILE ĐÃ TẠO / SỬA

### 3.1. File tự tạo mới — không có trong bản gốc

| Đường dẫn | Dòng | Mô tả |
|---|---|---|
| `plugins/dlubrand/setup.php` | 203 | Plugin giao diện DLU — 3 hook |
| `plugins/dlubrand/public/css/dlu-theme.css` | 1.541 | ★ **NGUỒN MÀU DUY NHẤT** cho giao diện GLPI — token `--dlu-*` cho cả 3 bảng màu + ánh xạ + trang đăng nhập |
| `themes/da_lat.scss` | 21 | Giấy đăng ký bảng màu Đà Lạt (chính) — **không chứa mã màu** |
| `themes/da_lat_nang.scss` | 25 | Giấy đăng ký bảng màu Đà Lạt — Nắng — **không chứa mã màu** |
| `themes/da_lat_suong.scss` | 22 | Giấy đăng ký bảng màu Đà Lạt — Sương — **không chứa mã màu** |
| `themes/dlu-logo.png` | — | Logo DLU |
| `scripts/cai-dat-tat-ca.sh` | 281 | ⭐ Cài 5 bước, 1 lệnh |
| `scripts/lib/compose-guard.sh` | 85 | Phanh an toàn: tự `down` khi cờ `internal` của mạng đã lệch |
| `start.sh` | 168 | Khởi động + tạo SSL tự động + cảnh báo mật khẩu mặc định |
| `scripts/seed-du-lieu-nen.sql` | 664 | 23 nhóm dữ liệu nghiệp vụ |
| `scripts/nap-du-lieu-nen.sh` | 71 | Nạp dữ liệu nền |
| `scripts/seed-du-lieu-mau.sql` | 554 | ⭐ **Dữ liệu mẫu demo** (thiết bị, phiếu, phần mềm, thiết bị mạng) |
| `scripts/nap-du-lieu-mau.sh` | 164 | ⭐ Nạp dữ liệu mẫu + đặt mật khẩu tài khoản demo |
| `scripts/bo-sung-tieng-viet.py` | 1.239 | Từ điển 556 thuật ngữ (dạng đơn **+ 212 mục dạng số nhiều**) |
| `scripts/gop-ban-dich-tieng-viet.py` | 560 | Gộp bản dịch (không mất chuỗi) + **vá/thêm entry số nhiều** |
| `scripts/tao-mo-bo-sung.py` | 334 | Biên dịch `.mo` thuần Python (tự tải `.po` khi thiếu) |
| `scripts/dich-tu-dong-giao-dien.py` | 1.231 | Dịch tự động (tự tải `.po` khi thiếu) |
| `scripts/do-do-phu-tieng-viet.py` | 246 | Đo tỉ lệ Việt hóa (tự tải `.po` khi thiếu) |
| `scripts/kiem-tra-tieng-viet.py` | 221 | Đo tỉ lệ Việt hóa từ `.mo` đang cài (tự tải `.po` khi thiếu) |
| `scripts/viet-hoa-du-lieu.sh` | 74 | ⭐ **Việt hoá DỮ LIỆU** (tên đơn vị, hồ sơ quyền, tên dashboard) |
| `scripts/tai-font.py` | 117 | ⭐ Tải font `.woff2` (tách đúng theo tập ký tự) |
| `scripts/kiem-tra-font.py` | 194 | ⭐ Đọc **bảng ký tự thật** trong tệp font, đối chiếu chữ trên trang |
| `scripts/sinh-ma-qr.py` | 342 | Sinh QR dự phòng |
| `scripts/cai-plugin-qrcode.sh` | 197 | Cài plugin QR |
| `scripts/cai-giao-dien.sh` | 152 | Cài giao diện |
| `scripts/cai-ban-dich.sh` | 78 | Cài bản dịch (`tai` = chỉ tải `.po`) |
| `scripts/chup-lai-anh-minh-chung.js` | 253 | ⭐ **Chụp 19 ảnh minh chứng** cho README (một màn hình một ảnh, bỏ qua trang thiếu quyền) |
| `scripts/chup-anh-qr-admin.js` | 192 | ⭐ Chụp luồng in QR qua plugin Barcode (cần tài khoản quản trị) |
| `scripts/chup-anh-giao-dien.js` | 170 | Chụp ảnh giao diện |
| `scripts/kiem-tra-massive-qr.js` | 140 | Kiểm tra luồng QR |
| `scripts/kiem-tra-qr-va-chup-anh.js` | 104 | Kiểm tra + chụp QR |
| `scripts/chup-anh-dashboard.js` | 72 | ⭐ Chụp ảnh dashboard thật cho landing page |
| `scripts/chup-anh-tung-khu.js` | 61 | ⭐ Chụp riêng từng khu để soi thiết kế |
| `scripts/kiem-tra-landing.js` | 242 | ⭐ Kiểm tra landing (anchor, ảnh, font, console) |
| `landing/index.html` | 760 | ⭐ **Trang giới thiệu dự án** (thiết kế riêng theo cảnh quan Đà Lạt) |
| `landing/assets/css/style.css` | 1.269 | ⭐ **CSS tự viết** cho landing (không dùng Tailwind) |
| `tai-lieu/HUONG-DAN-TRIEN-KHAI.md` | — | Hướng dẫn triển khai |
| `tai-lieu/HUONG-DAN-PLUGIN-QRCODE.md` | — | Hướng dẫn plugin QR |
| `tai-lieu/HUONG-DAN-GIAO-DIEN-VA-VIET-HOA.md` | — | Giao diện & Việt hóa |
| `tai-lieu/THONG-TIN-DAI-HOC-DA-LAT.md` | — | Thông tin ĐH Đà Lạt |
| `tai-lieu/SO-SANH-VOI-GLPI-GOC.md` | — | **Tài liệu này** |

**Tổng code tự viết: ~9.900 dòng** (script + plugin + theme + CSS + landing page).
*(Không tính `landing/fonts/` — đó là 16 tệp font `.woff2` tải sẵn từ Google Fonts,
không phải code tự viết.)*

### 3.2. File cấu hình tùy chỉnh

| Đường dẫn | Thay đổi so với mặc định |
|---|---|
| `docker-compose.yml` | 190 dòng — 4 service, 2 network (**backend `internal: true`**), 6 volume |
| `nginx/nginx.conf` | Thêm zone rate limit 2 tầng + `limit_req_status 429` |
| `nginx/conf.d/default.conf` | 190 dòng — HTTPS, 5 header bảo mật, chặn file, static cache |
| `config/php-custom.ini` | Tài nguyên, múi giờ, bảo mật phiên (httponly/samesite/**secure**), expose_php Off |
| `config/apache-forwarded-proto.conf` | ⭐ Chuyển tiếp `X-Forwarded-Proto` → `HTTPS` cho PHP (để `cookie_secure` hoạt động sau TLS của nginx) |
| `.env` / `.env.example` | Biến môi trường (mật khẩu, cổng, tên CSDL) — **tách khỏi code** |
| `.gitignore` | Chặn commit bí mật; **bỏ** `.tmp-locale/` (`.po` tải lại được từ container, `.mo` là sản phẩm sinh ra) |
| `backup/backup.sh` | Sao lưu 3 thành phần + tự dọn bản cũ |
| `start.sh` | Khởi động + tạo SSL tự động + cảnh báo mật khẩu mặc định |

### 3.3. Điểm mấu chốt — KHÔNG sửa lõi

> **Không có bất kỳ file nào trong `/var/www/glpi` (mã nguồn GLPI) bị sửa.**
>
> Toàn bộ tùy biến nằm ở:
> - **Plugin** (`plugins/dlubrand/`) — dùng hook chính thức của GLPI
> - **Theme** (`themes/*.scss`) — GLPI tự quét thư mục `_themes`
> - **Config** (`nginx/`, `config/php-custom.ini`, `docker-compose.yml`)
> - **Script** (`scripts/`, `backup/`)
>
> **Hệ quả:** nâng cấp GLPI lên 11.1 / 12 **không mất tùy biến**. Đây là lý do chọn cách plugin-CSS-ghi-đè thay vì sửa file gốc.

---

## 4. NHỮNG ĐIỀU **CHƯA** LÀM / HẠN CHẾ

> **Đọc kỹ mục này trước khi bảo vệ.** Hội đồng đánh giá cao việc người làm tự
> biết giới hạn của mình hơn là một danh sách thành tựu không có điểm yếu.

### 4.1. Giới hạn kỹ thuật

| Hạng mục | Trạng thái | Ghi chú |
|---|---|---|
| Việt hóa 100% | ❌ **32,0%** | GLPI chỉ ship ~32%; phần còn lại chủ yếu là chuỗi kỹ thuật ẩn |
| `session.cookie_secure = On` | ✅ Đã bật | Đi kèm bắt buộc `config/apache-forwarded-proto.conf` + healthcheck gửi header |
| Chứng chỉ SSL | ⚠️ Tự ký nhưng **CÓ SAN** | Đã có SAN (`localhost`, `pinedesk.local`, `127.0.0.1`); triển khai thật nên dùng Let's Encrypt |
| `url_base` | ⚠️ Đang là `https://localhost:8443` | Triển khai thật phải đổi tên miền, nếu không **mã QR in ra sẽ sai** |
| Tài khoản mẫu 3 vai trò | ✅ Đã tạo | 6 tài khoản: 2 KTV, 2 giảng viên, 2 sinh viên — đã kiểm chứng đăng nhập |
| Dữ liệu thiết bị mẫu | ✅ Đã nhập | 17 máy tính + 5 màn hình + 3 máy in + 9 thiết bị mạng + 10 phần mềm + 13 phiếu |
| Trang Thống kê | ⚠️ Cần tham số | Phải mở từ menu Hỗ trợ → Thống kê, không gõ URL trực tiếp |
| Đa ngôn ngữ | ✅ Việt + Anh | Các ngôn ngữ khác chưa dịch |
| Ứng dụng di động | ❌ Không có | GLPI có bản mobile chính thức, chưa tích hợp |

### 4.2. Giới hạn **nghiệp vụ** — phần hội đồng khoan sâu nhất

Đây là nhóm hạn chế đã bị chỉ ra khi báo cáo tiến độ lần 1 (*"đồ án còn lý
thuyết, chưa thực tế"*). Đồ án đã làm được một phần và **ghi rõ phần còn lại**:

| # | Hạn chế | Mức độ | Đã làm gì / hướng khắc phục |
|---|---|---|---|
| 1 | **Chưa gặp Trung tâm CNTT (ITC) để xác nhận nhu cầu** | 🔴 Nghiêm trọng | Đã viết `BAI-TOAN-NGHIEP-VU.md` từ dữ kiện công khai (5 nhân sự ITC / 14.500+ người học / hotline 7h30–16h30). **Cần phỏng vấn 5 nhân sự ITC** để kiểm chứng |
| 2 | **Số sự cố thực tế/tuần của trường chưa có** | 🔴 Nghiêm trọng | Ghi rõ là giả định trong `BAI-TOAN-NGHIEP-VU.md` mục 7. Không bịa số |
| 3 | **SLA chưa được Trường ban hành** | 🟡 Trung bình | Đã tạo 5 mức SLA thật trong CSDL, nhưng là **đề xuất kỹ thuật** — cần văn bản phê duyệt của ITC |
| 4 | **Hạn mức chống spam chưa được ITC xác nhận** | 🟡 Trung bình | Đã cấu hình (5 phiếu mở / 10 phiếu/ngày) nhưng là đề xuất. Sửa được bằng 1 câu UPDATE |
| 5 | **Tầng kiểm duyệt (T5) chưa tự động hoá bằng mã** | 🟡 Trung bình | Dựa trên quy trình vận hành: phiếu mới nằm ở trạng thái "Mới" chờ kỹ thuật viên xác nhận ưu tiên. T3/T4 thì đã cưỡng chế bằng plugin `pinedesk` (hook công khai, không sửa lõi) |
| 6 | **Chưa đo tải khi nhiều người cùng nộp** | 🔴 Nghiêm trọng | Chưa kiểm thử hiệu năng. **Không dám nói "chịu được 5.000 người" khi chưa đo** |
| 7 | **Bảo trì định kỳ dùng lịch GỐC của GLPI** | 🟢 Đã xử lý | Tạo 2 lịch `glpi_ticketrecurrents` (bảo trì phòng máy hàng tháng + kiểm tra thiết bị mạng hàng quý) kèm mẫu phiếu; cron `ticketrecurrent` của GLPI tự sinh phiếu. **Chưa chạy đủ 1 chu kỳ** để chứng minh tự động sinh phiếu |
| 8 | ~~Phiếu quá hạn chưa có dữ liệu demo~~ | 🟢 Đã xử lý | Phần C của `seed-sla-va-chong-lam-dung.sql` đẩy 2 phiếu đang mở vào quá khứ → phiếu quá hạn thật, demo được cảnh báo SLA |
| 9 | **Luồng mượn/trả dùng Reservation gốc** | 🟢 Đã xử lý | 2 thiết bị vào diện đặt mượn + 2 lượt mượn mẫu (1 đang mượn, 1 đã trả) + 1 phiếu yêu cầu mượn. Dùng `glpi_reservationitems`/`glpi_reservations` gốc, không tạo bảng riêng |
| 10 | Nhật ký lạm dụng chưa có giao diện xem | 🟢 Thấp | Hiện xem bằng SQL; chưa làm màn hình cho kỹ thuật viên |

### 4.3. Ba câu phải trả lời bằng sự thật, không chống đỡ

1. *"Em đã nói chuyện với ITC chưa?"* → **Chưa.** Đồ án chưa được ITC phê duyệt.
2. *"SLA này ai ban hành?"* → **Chưa ai.** Là đề xuất kỹ thuật của đồ án.
3. *"Chịu được bao nhiêu người cùng lúc?"* → **Chưa đo được.** Không khẳng định.

👉 Các câu hỏi phản biện đầy đủ + cách trả lời: [`CAU-HOI-PHAN-BIEN.md`](CAU-HOI-PHAN-BIEN.md).



Ghi rõ để tránh hiểu nhầm khi bảo vệ đồ án:

| Hạng mục | Trạng thái | Ghi chú |
|---|---|---|
| Việt hóa 100% | ❌ **32,0%** | GLPI chỉ ship ~32%; phần còn lại chủ yếu là chuỗi kỹ thuật ẩn |
| Mật khẩu mặc định | ⚠️ **Chưa đổi** | Mật khẩu `glpi` **không hardcode trong mã** — script đọc từ biến môi trường `GLPI_PASS`. Khi triển khai thật phải đổi mật khẩu trong `.env` và tài khoản `glpi` |
| `session.cookie_secure = On` | ✅ **Đã bật** | Cookie phiên chỉ gửi qua HTTPS. Đi kèm **bắt buộc**: `config/apache-forwarded-proto.conf` (chuyển tiếp tín hiệu HTTPS từ nginx) + healthcheck gửi header — thiếu 1 trong 2 là GLPI chặn mọi trang bằng HTTP 400 |
| Tài khoản mẫu 3 vai trò | ✅ **Đã tạo** | 6 tài khoản: 2 KTV, 2 giảng viên, 2 sinh viên — đã kiểm chứng đăng nhập được |
| Dữ liệu thiết bị mẫu | ✅ **Đã nhập** | 17 máy tính + 5 màn hình + 3 máy in + 9 thiết bị mạng + 10 phần mềm + 13 phiếu |
| Trang Thống kê (`stat.global.php`) | ⚠️ **Cần tham số** | Phải mở từ **menu Hỗ trợ → Thống kê**, không gõ URL trực tiếp (sẽ báo lỗi) |
| Chứng chỉ SSL | ⚠️ **Tự ký nhưng CÓ SAN** | Đã có Subject Alternative Name (`localhost`, `pinedesk.local`, `127.0.0.1`…) nên trình duyệt cho thêm ngoại lệ; triển khai thật nên dùng Let's Encrypt |
| Đa ngôn ngữ | ✅ Tiếng Việt + tiếng Anh | Các ngôn ngữ khác chưa dịch |
| Ứng dụng di động | ❌ Không có | GLPI có bản mobile chính thức, chưa tích hợp |
| Kiểm thử tự động | ✅ **Đã có CI** | `.github/workflows/ci.yml`: cú pháp (shell/Python/JS), ShellCheck, `docker compose config`, `nginx -t`, chứng chỉ có SAN, kiểm tra bảo mật, smoke test khởi động thật 4 container |
| `url_base` | ⚠️ **Đang là `https://localhost:8443`** | Khi triển khai lên máy chủ thật phải đổi lại tên miền, nếu không **mã QR in ra sẽ sai** |
| Phiếu quá hạn | ⚠️ Chưa có dữ liệu | Seed đủ 4 trạng thái chính, chưa tạo phiếu trễ hạn để demo cảnh báo |

---

## 5. KẾT LUẬN

Bản gốc GLPI 11 là một **framework ITSM mạnh** nhưng ở trạng thái **"nguyên liệu thô"**: tiếng Anh, giao diện Teclib, CSDL rỗng, hạ tầng không đủ để triển khai.

Đồ án đã biến nó thành một **hệ thống hỗ trợ kỹ thuật hoàn chỉnh, mang bản sắc Trường Đại học Đà Lạt**, với 6 nhóm cải thiện chính:

1. **Bản địa hóa** — Việt hóa cả giao diện lẫn trang đăng nhập (556 thuật ngữ + 212 mục dạng số nhiều bổ sung)
2. **Nhận diện thương hiệu** — Bảng màu "Đà Lạt" lấy từ logo DLU, phủ mọi trang
3. **Dữ liệu nghiệp vụ** — 23 nhóm danh mục dựng sẵn theo cơ cấu tổ chức **thật** của DLU
4. **Dữ liệu demo** — 1 lệnh ra ngay hệ thống có sống, sẵn sàng trình diễn
5. **Trang giới thiệu** — Landing page thiết kế riêng theo bản sắc Đà Lạt & DLU, chạy được khi không có mạng
6. **Vận hành & bảo mật** — Hạ tầng 4 container, HTTPS, 5 header bảo mật, rate limit, sao lưu, và **cài đặt bằng 1 lệnh**

**Điểm quan trọng nhất về mặt kỹ thuật:** toàn bộ tùy biến **nằm ngoài mã nguồn lõi** — nhờ plugin, theme và config. Điều này đáp ứng đúng yêu cầu của giảng viên: *"không làm lại từ đầu, tận dụng mã nguồn mở"*, đồng thời **vẫn giữ được khả năng nâng cấp** về sau.

**Về kiểm thử:** đồ án đã được kiểm thử bằng **trình duyệt thật** và **giải mã ngược mã QR** để xác minh kết quả đầu ra, qua đó phát hiện và khắc phục **13 lỗi im lặng** (xem mục 2.12) — trong đó có 1 lỗi **làm yếu bảo mật** và 1 lỗi khiến **mã QR in ra không dùng được**. Đây là minh chứng cho việc kiểm thử thực chất, không chỉ chạy script cho có.

---

*Tài liệu liên quan:*
- `README.md` — hướng dẫn nhanh 1 lệnh
- `tai-lieu/HUONG-DAN-TRIEN-KHAI.md` — triển khai chi tiết
- `tai-lieu/HUONG-DAN-PLUGIN-QRCODE.md` — plugin QR (kèm 2 lỗi đã vá)
- `tai-lieu/HUONG-DAN-GIAO-DIEN-VA-VIET-HOA.md` — giao diện & Việt hóa
- `tai-lieu/THONG-TIN-DAI-HOC-DA-LAT.md` — thông tin ĐH Đà Lạt
