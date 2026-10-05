# HƯỚNG DẪN TUỲ BIẾN GIAO DIỆN & VIỆT HOÁ

> **Dự án:** Xây dựng hệ thống hỗ trợ kỹ thuật (PineDesk) — Trường Đại học Đà Lạt
> **Nền tảng:** GLPI 11.0.0 · **Giao diện:** Bảng màu "Đà Lạt" + plugin `dlubrand`
> **Trạng thái thực tế:** ✅ Đã áp dụng và **đang chạy** (đã kiểm tra bằng ảnh chụp thật)

---

## PHẦN A — KẾT QUẢ ĐÃ LÀM ĐƯỢC

### A.1. Giao diện

| Hạng mục | Kết quả | Cách kiểm chứng |
|---|---|---|
| Trang đăng nhập | Nền gradient xanh rêu Đà Lạt, logo DLU, dải 3 màu | Ảnh `anh-giao-dien/01-*.png` |
| Bảng điều khiển | Menu xanh rêu đậm, thẻ số liệu theo màu DLU | Ảnh `02-*.png` |
| Toàn bộ trang con | Cùng bảng màu, logo DLU ở góc trên trái | Ảnh `03-`, `04-`, `05-` |
| Logo | Hiển thị đúng (HTTP 200) | `/plugins/dlubrand/pics/logos/logo-DLU-100.png` |

**Bảng màu trích từ logo chính thức ĐH Đà Lạt:**

| Mã | Màu | Ý nghĩa trong logo |
|---|---|---|
| `#F08418` | Cam đất | Vòng hoa văn, mặt trời |
| `#607824` | Xanh rêu | Núi, dòng chữ "ĐẠI HỌC ĐÀ LẠT" |
| `#90B43C` | Xanh lá | Sườn núi sáng |
| `#C0CC84` | Xanh nhạt | Đồi thông |
| `#CC2430` | Đỏ | Ngôi sao |
| `#3D4E17` | Xanh rêu đậm | Thanh menu (tạo độ tương phản) |
| `#3E8E9E` | Xanh hồ | Gợi màu nước hồ Xuân Hương |

### A.2. Kiểm tra tiếng Việt — **CÂU TRẢ LỜI TRUNG THỰC**

> ⚠️ **CHƯA ĐẠT 100% TIẾNG VIỆT — hiện tại là 32,0%.**

Số liệu đo bằng `scripts/do-do-phu-tieng-viet.py` (đọc file `.mo` thật trong GLPI):

| Chỉ số | Số lượng |
|---|---|
| Tổng số chuỗi GLPI cần dịch | 6.511 |
| Đã dịch | 2.084 |
| Còn thiếu | 4.427 |
| **Tỉ lệ hiện tại** | **32,0%** |

> **Bổ sung phiên 19/09:** đã Việt hóa thêm **9 nhãn thẻ đếm trạng thái phiếu** trên
> trang Hỗ trợ — đây là các nhãn *nổi bật nhất* của trang nhưng bản dịch `vi_VN`
> chính thức của GLPI **không hề có**:
> `Phiếu mới tiếp nhận · Phiếu đang chờ · Phiếu đã phân công · Phiếu đã lên kế hoạch ·
> Phiếu đã giải quyết · Phiếu đã đóng · Phiếu quá hạn`, cùng `Phiếu theo tháng`,
> `Tình trạng phiếu theo tháng`. Kiểm chứng bằng trình duyệt thật: **không còn chuỗi
> tiếng Anh nào** trên hàng thẻ đếm.

**Vì sao không thể đạt 100% ngay:**

1. **GLPI chỉ đóng gói sẵn ~32% bản dịch tiếng Việt chính thức.** Đây là giới hạn của
   chính GLPI, không phải lỗi của đồ án.
2. **4.427 chuỗi còn thiếu hầu hết là chuỗi kỹ thuật dài**, ví dụ:
   - `2 primary or foreign keys are using signed integers. Run the "php bin/console
     migration:unsigned_keys" command to migrate them.`
   - Thông báo lỗi hệ thống, mô tả tham số CLI, cảnh báo bảo mật.
3. Dịch máy các chuỗi này dễ gây **hiểu sai nghiệp vụ** — nguy hiểm hơn là để tiếng Anh.

**Phân bố chuỗi còn thiếu theo nhóm nghiệp vụ:**

| Nhóm | Số chuỗi | Tỉ lệ |
|---|---|---|
| Khác (chuỗi hệ thống dài) | 2.889 | 65,3% |
| Người dùng / Quyền | 293 | 6,6% |
| Sự cố / Phiếu | 283 | 6,4% |
| Mạng / Kết nối | 287 | 6,5% |
| Thiết bị / Tài sản | 238 | 5,4% |
| Cấu hình / Hệ thống | 235 | 5,3% |
| Phần mềm / Bản quyền | 118 | 2,7% |
| Thống kê / Dashboard | 51 | 1,2% |
| Bảo trì / Hợp đồng | 33 | 0,7% |

**Điểm mạnh:** các phần **người dùng nhìn thấy nhiều nhất đã gần như 100% tiếng Việt** —
đăng nhập, menu chính, danh sách thiết bị, form tạo phiếu, sidebar, cột bảng.

Ví dụ menu thật (lấy từ HTML đã đăng nhập): *Tài sản · Hỗ trợ · Quản lý · Công cụ ·
Quản trị · Cấu hình · Bảng điều khiển · Các máy tính · Các màn hình · Phần mềm ·
Các hộp mực · Các điện thoại · Vị trí · Các phiếu yêu cầu…*

### A.3. Cách nâng tỉ lệ lên cao hơn

Mở file `scripts/bo-sung-tieng-viet.py`, thêm vào từ điển `BAN_DICH_BO_SUNG`:

```python
BAN_DICH_BO_SUNG = {
    # ... các mục đã có ...
    "Manage tickets": "Quản lý phiếu yêu cầu",
    "My tickets": "Phiếu của tôi",
    "Assigned tickets": "Phiếu được giao",
}
```

Rồi chạy 3 lệnh:

```bash
python scripts/tao-mo-bo-sung.py          # tạo lớp phủ
python scripts/gop-ban-dich-tieng-viet.py # gộp vào catalog chính
python scripts/do-do-phu-tieng-viet.py    # đo lại tỉ lệ
```

Nếu chuỗi cần dịch là **dạng số nhiều** (GLPI gọi `_n()`), thêm vào bảng
`BAN_DICH_SO_NHIEU` trong cùng file — xem giải thích ở **mục B.3**.

### A.4. Việt hoá **DỮ LIỆU** (khác với Việt hoá giao diện)

Có những chữ **không nằm trong file dịch** mà nằm trong **CSDL** — dù dịch đủ
100% catalog thì chúng vẫn hiện tiếng Anh. Ví dụ đã gặp:

| Chữ hiện ra | Thực chất là gì |
|---|---|
| `Super-Admin`, `Technician`, `Self-Service` | **Tên hồ sơ quyền** trong `glpi_profiles` |
| `Central`, `Assets`, `Assistance` | **Tên bảng điều khiển** trong `glpi_dashboards_dashboards` |
| `Root entity` | **Tên đơn vị gốc** trong `glpi_entities` |

Đồ án xử lý bằng `scripts/viet-hoa-du-lieu.sh` — **chạy lại được**, không phải
sửa tay một lần:

```bash
bash scripts/viet-hoa-du-lieu.sh
```

> Đã kiểm chứng **an toàn**: các tên này chỉ là **dữ liệu**, mã nguồn GLPI
> **không tham chiếu** tới giá trị của chúng (đã `grep` toàn bộ `src/`,
> `templates/`, `js/`). Đổi tên **không** làm hỏng chức năng.

---

## PHẦN B — CƠ CHẾ HOẠT ĐỘNG (giải thích để bảo vệ đồ án)

### B.1. Vì sao giao diện vẫn hiển thị đúng dù GLPI khoá theme tự tạo?

GLPI 11 có 2 tầng giao diện, cần hiểu rõ để tránh nhầm lẫn:

| Tầng | Tên | Vai trò |
|---|---|---|
| 1 | **Bảng màu (palette)** | Đăng ký *tên* bảng màu để GLPI liệt kê trong "Thiết lập của tôi → Giao diện"; tên file `.scss` = key = giá trị `<html data-glpi-theme>` |
| 2 | **CSS ghi đè (override)** | **Chứa toàn bộ mã màu + ghi đè chi tiết giao diện**, do plugin `dlubrand` cung cấp |

**Điểm quan trọng:** GLPI 11 **bỏ qua** theme tự tạo nếu tên trùng khoá theme lõi
(hàm `getCustomThemes()` có dòng `if (!in_array($file_name, $core_keys, true))`).

Vì vậy đồ án dùng **cách an toàn hơn**: plugin `dlubrand` nạp file CSS riêng qua hook
`ADD_CSS` + `ADD_CSS_ANONYMOUS_PAGE` → ghi đè giao diện trên **mọi trang**, kể cả trang
đăng nhập (nơi chưa có session).

**Ưu điểm cách này:**
- Không sửa file lõi GLPI → nâng cấp GLPI không mất giao diện.
- Áp dụng cho cả người chưa đăng nhập (trang login).

#### ★ Nguồn màu DUY NHẤT — tránh "sửa màu phải sửa 2 nơi"

Trước đây mã màu bị **lặp ở 2 nơi**: `themes/*.scss` (tầng palette) **và**
`plugins/dlubrand/public/css/dlu-theme.css` (tầng override) → sửa màu phải sửa cả hai,
rất dễ lệch. Đã **gỡ hẳn mã màu khỏi `themes/*.scss`**:

- `themes/*.scss` giờ chỉ là **"giấy đăng ký"**: GLPI quét thư mục để **liệt kê** bảng màu;
  **tên file** (không phần mở rộng) là key. Nội dung chỉ còn chú thích, **không mã màu**.
- **Toàn bộ mã màu giao diện GLPI nằm duy nhất** trong `plugins/dlubrand/public/css/dlu-theme.css`.

Muốn đổi màu giao diện GLPI → **sửa DUY NHẤT 1 file** `dlu-theme.css`.

> **Ngoại lệ đã biết:** trang giới thiệu tĩnh `landing/` do nginx phục vụ **riêng** (không
> qua GLPI) nên không dùng được file này — bảng màu của nó nằm ở
> `landing/assets/css/style.css`. Đổi màu thương hiệu thì phải sửa **cả hai** nơi.

#### ⚠️ Cạm bẫy selector `:root[data-glpi-theme]` (đã từng làm 2 bảng màu "chết")

Selector `:root[data-glpi-theme]` **chỉ kiểm tra có attribute, KHÔNG kiểm tra giá trị** →
nó khớp với **mọi** bảng màu. Nếu đặt mã màu trực tiếp trong khối này thì mọi bảng màu
đều bị ghi đè thành **cùng một màu** (thực tế đã xảy ra: `da_lat_suong` và `da_lat_nang`
hiển thị **y hệt** `da_lat` — trông như "đã cài" nhưng **không có tác dụng**).

**Cách đúng:** tách mã màu vào khối **theo giá trị**, chỉ để khối ánh xạ chung ở dạng
attribute-only:

```css
/* ĐÚNG — bảng màu MẶC ĐỊNH dùng :root trần; hai bảng phụ theo GIÁ TRỊ */
:root                                 { --dlu-primary: #607824; /* da_lat — xanh rêu */ }
:root[data-glpi-theme="da_lat_suong"] { --dlu-primary: #3E8E9E; /* xanh hồ */ }
:root[data-glpi-theme="da_lat_nang"]  { --dlu-primary: #F08418; /* cam đất */ }

/* Khối ánh xạ chung — chạy cho MỌI bảng màu, KHÔNG chứa mã màu */
:root[data-glpi-theme] {
    --tblr-primary: var(--dlu-primary);
    --glpi-mainmenu-bg: var(--dlu-primary-dark);
}
```

> **Vì sao plugin luôn thắng:** plugin CSS nạp **sau cùng** trên mọi trang
> (`ADD_CSS` + `ADD_CSS_ANONYMOUS_PAGE`), còn `themes/*.scss` **chỉ nạp khi đã đăng nhập**.
> Vì vậy kể cả khi `.scss` có chứa màu, plugin vẫn ghi đè — nên **đặt màu ở plugin là
> đúng đắn**, đặt ở `.scss` sẽ gây hiểu nhầm.

### B.2. Bảng màu "Đà Lạt" cài thế nào?

```bash
bash scripts/cai-giao-dien.sh
```

Script copy `themes/*.scss` vào `/var/glpi/files/_themes/` rồi đặt `glpi_users.palette`
= `da_lat` cho mọi người dùng.

> **Lưu ý:** `.scss` chỉ đóng vai trò **đăng ký tên bảng màu** — **không chứa mã màu**.
> Màu thật do plugin `dlubrand` cung cấp (xem B.1).

> **Lưu ý đường dẫn:** GLPI 11 dùng `GLPI_VAR_DIR = /var/glpi/files`, **KHÔNG phải**
> `/var/www/glpi/files`. Đây là điểm rất dễ sai khi làm theo tài liệu GLPI 10.

### B.3. Việt hoá hoạt động thế nào?

GLPI nạp bản dịch theo thứ tự:

1. `/var/www/glpi/locales/vi_VN.mo` — bản chính thức (~32%)
2. `/var/glpi/files/_locales/core*/vi_VN.mo` — **bản của đồ án, nạp SAU nên thắng**

**Cạm bẫy đã gặp (ghi lại để tránh lặp lại):**

> Thư viện `laminas-i18n` **THAY THẾ** (không gộp) catalog theo cùng domain + locale.
> Nghĩa là nếu ta cài một file `.mo` **thiếu** chuỗi, các chuỗi thiếu đó sẽ
> **quay về tiếng Anh**, dù bản chính thức có dịch.

Vì vậy đồ án **luôn GỘP** (bản chính thức + lớp phủ) rồi mới cài — xem
`scripts/gop-ban-dich-tieng-viet.py`. Script có kiểm tra `Không mất chuỗi nào so với bản gốc`.

#### Cạm bẫy lớn nhất: GLPI có **HAI LOẠI KHOÁ DỊCH**

Đây là phát hiện quan trọng nhất trong quá trình Việt hoá — và là nguyên nhân
khiến một số chỗ **vẫn hiện tiếng Anh dù từ điển đã có bản dịch**:

| Cách GLPI gọi | Hàm dịch | Tra vào khoá nào | Từ điển thường vá được? |
|---|---|---|---|
| `__('Ticket')` | `gettext()` | **`msgid`** (số ít) | ✅ Có |
| `_n('Ticket', 'Tickets', 13)` | `translatePlural()` | **`msgid_plural`** — khoá là `"Ticket\0Tickets"` | ❌ **Không** |

Bản dịch `vi_VN` chính thức của GLPI để nguyên `msgstr[0] "Ticket"` (chưa dịch) ở
entry số nhiều. Vì từ điển chỉ tác động lên entry **đơn**, dạng số nhiều **không
bao giờ được vá** — nên bảng điều khiển hiện `13 Ticket` trong khi mọi thẻ khác
đã là tiếng Việt.

**Cách khắc phục trong đồ án:** thêm bảng `BAN_DICH_SO_NHIEU` (212 mục) và hàm
`va_entry_so_nhieu()` trong `scripts/gop-ban-dich-tieng-viet.py`, vá thẳng vào
entry có ký tự `\0`.

> ⚠️ **Bẫy phụ khi thêm entry số nhiều MỚI:** khoá thật là `"số_ít\0số_NHIEU"`
> (ví dụ `Asset\0Assets`), **không phải** `"số_ít\0số_ít"`. Nếu chỉ kiểm tra dạng
> sau, script sẽ thêm **hàng trăm entry chết** — trông như thành công nhưng
> **không bao giờ được tra cứu**. Phải kiểm tra: đã có khoá nào **bắt đầu bằng**
> `"số_ít\0"` chưa.

> **Lưu ý về nguồn số liệu:** file `.tmp-locale/vi_VN.po` (dùng làm mốc so sánh)
> và file `.mo` **thật trong image** là **hai phiên bản khác nhau**. Luôn lấy `.mo`
> trong container làm **nguồn sự thật** — xem `scripts/do-do-phu-tieng-viet.py`.

> **`.tmp-locale/` KHÔNG được version hóa** (xem `.gitignore`). Thư mục này chứa
> 2 file `.po` nguồn và 7 file `.mo` sinh ra. Cả hai loại đều **không cần commit**:
> `.po` byte-identical với bản trong image nên **tự tải lại được**, `.mo` là sản
> phẩm của script. Các script dịch (`tao-mo-bo-sung.py`, `bo-sung-tieng-viet.py`,
> `kiem-tra-tieng-viet.py`) **tự tải `.po` khi thiếu** — nên clone repo mới vẫn
> chạy `bash scripts/cai-dat-tat-ca.sh` được ngay, không cần bước tải riêng.
> Muốn tải tay: `bash scripts/cai-ban-dich.sh tai`.

### B.4. Vì sao phải vá cấu hình Nginx?

Khi kiểm tra bằng **trình duyệt thật** (Chrome headless), trang bị lỗi **503** và
**logo 404**. Truy nguyên trong log `pinedesk-gateway`:

| Lỗi | Nguyên nhân | Đã sửa |
|---|---|---|
| `503 Service Temporarily Unavailable` | Giới hạn `general_zone` chỉ `120r/m`, nhưng GLPI 11 nạp **hàng trăm** tệp CSS/JS/font mỗi trang | Nâng lên `600r/m`, cho phép tệp tĩnh miễn giới hạn |
| Logo DLU `404` | Cấu hình chặn dùng regex `\.(ini\|log\|sh\|sql\|bak\|conf\|yml\|yaml\|md\|lock\|dist\|json)$` — trong đó `\|json` bị hiểu thành chuỗi `njson` nên **chặn luôn `.png`** | Bỏ `png`/`json`/`md` khỏi danh sách chặn; thêm location riêng cho tệp tĩnh |

**Bài học:** luôn kiểm tra bằng trình duyệt thật, không chỉ bằng `curl` — vì `curl`
chỉ tải 1 tệp mỗi lần nên không bao giờ chạm giới hạn tần suất.

---

## PHẦN C — CÁC LỆNH THƯỜNG DÙNG

```bash
# Cài đặt toàn bộ hệ thống (chạy 1 lệnh là xong)
bash scripts/cai-dat-tat-ca.sh

# Chỉ cài lại giao diện
bash scripts/cai-giao-dien.sh

# Chỉ cài lại bản dịch tiếng Việt
python scripts/tao-mo-bo-sung.py
python scripts/gop-ban-dich-tieng-viet.py

# Đo tỉ lệ Việt hoá
python scripts/do-do-phu-tieng-viet.py

# Chụp ảnh minh chứng trong README (một màn hình một ảnh)
# Script này tạo tối đa 16 ảnh; 3 ảnh còn lại của bộ 19 do script khác tạo:
#   12-ket-qua-sinh-qr.png  <- scripts/kiem-tra-massive-qr.js
#   16/17-landing-*.png     <- scripts/kiem-tra-landing.js
# - Mật khẩu KHÔNG hardcode: truyền qua GLPI_PASS.
# - NODE_PATH trỏ tới node_modules có puppeteer-core (cài bằng `npm i puppeteer-core`).
# - Nếu Chrome không nằm ở đường dẫn mặc định, đặt thêm CHROME_PATH.
# - Hai ảnh luồng in QR cần quyền quản trị, chụp riêng bằng scripts/chup-anh-qr-admin.js.
GLPI_USER=ktv.an GLPI_PASS='<mật khẩu>' \
NODE_PATH="<DUONG-DAN>/node_modules" \
  node scripts/chup-lai-anh-minh-chung.js

# Sinh mã QR cho thiết bị
python scripts/sinh-ma-qr.py
```

---

## PHẦN D — CẤU TRÚC FILE LIÊN QUAN

```
pinedesk/
├── plugins/dlubrand/              ← plugin giao diện Đà Lạt
│   ├── setup.php                  ← đăng ký hook ADD_CSS + POST_INIT
│   └── public/
│       ├── css/dlu-theme.css      ← ★ NGUỒN MÀU DUY NHẤT cho giao diện GLPI (~67 KB, token --dlu-*)
│       └── pics/logos/            ← logo DLU
├── themes/                        ← "giấy đăng ký" bảng màu (KHÔNG chứa mã màu)
│   ├── da_lat.scss                ← đăng ký bảng màu chính (xanh rêu)
│   ├── da_lat_suong.scss          ← đăng ký biến thể sương mù (xanh hồ)
│   └── da_lat_nang.scss           ← đăng ký biến thể nắng (cam đất)
├── scripts/
│   ├── cai-dat-tat-ca.sh          ← cài toàn bộ, 1 lệnh
│   ├── nap-du-lieu-nen.sh         ← nạp danh mục nghiệp vụ
│   ├── tao-mo-bo-sung.py          ← tạo lớp phủ bản dịch
│   ├── gop-ban-dich-tieng-viet.py ← gộp bản dịch (không mất chuỗi)
│   ├── do-do-phu-tieng-viet.py    ← đo tỉ lệ Việt hoá
│   ├── chup-lai-anh-minh-chung.js ← chụp tối đa 16 ảnh minh chứng (một màn hình một ảnh)
│   └── sinh-ma-qr.py              ← sinh mã QR thiết bị
└── tai-lieu/anh-giao-dien/        ← ảnh chụp giao diện thực tế
```

---

## PHẦN E — LƯU Ý AN TOÀN

Bản vá Nginx chỉ **nới lỏng giới hạn tần suất cho tệp tĩnh** (CSS/JS/ảnh/font).
Các lớp bảo vệ quan trọng **vẫn giữ nguyên**:

- ✅ Chặn file cấu hình: `.ini .log .sh .sql .bak .conf .yml .yaml .lock .dist`
- ✅ Chặn thư mục nhạy cảm: `config/`, `files/_log/`, `files/_sessions/`
- ✅ Chặn file ẩn: `/\.`
- ✅ Giới hạn đăng nhập: `10r/m` (chống dò mật khẩu)
- ✅ HTTPS bắt buộc, HSTS, X-Frame-Options, X-Content-Type-Options

> Việc nới giới hạn cho **tệp tĩnh** không làm giảm bảo mật, vì tệp tĩnh
> không truy vấn CSDL và không chứa dữ liệu người dùng.
