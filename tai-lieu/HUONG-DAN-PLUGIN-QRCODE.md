# HƯỚNG DẪN CÀI & SỬ DỤNG PLUGIN SINH MÃ QR

> **Dự án:** Xây dựng hệ thống hỗ trợ kỹ thuật (IT Helpdesk) — Trường Đại học Đà Lạt
> **Phiên bản GLPI:** 11.0.0 · **Plugin:** Barcode 2.7.1 (AGPL-3.0)
> **Trạng thái thực tế:** ✅ Đã cài đặt và **ĐANG HOẠT ĐỘNG** (Enabled)

---

## 1. TÓM TẮT NHANH

Plugin **Barcode** cho phép sinh **mã QR** và **mã vạch** cho từng thiết bị trong GLPI.
Mỗi máy tính / thiết bị mạng sẽ có một mã QR dán lên thân máy; khi kỹ thuật viên quét mã,
hệ thống mở ngay hồ sơ thiết bị đó (lịch sử sửa chữa, cấu hình, vị trí).

**Chỉ cần chạy 1 lệnh:**

```bash
cd <DUONG-DAN-DU-AN>/glpi-helpdesk
bash scripts/cai-plugin-qrcode.sh
```

Script sẽ tự động: tải plugin → copy vào volume → **vá lỗi tương thích GLPI 11** → cài → kích hoạt.

---

## 2. VÌ SAO PHẢI VÁ (PATCH) PLUGIN?

Plugin Barcode 2.7.1 được phát hành tháng 7/2022, chỉ hỗ trợ **GLPI 10.0.x**.
Khi cài trên **GLPI 11.0.0** sẽ gặp **3 lỗi** sau — script đã tự động xử lý hết:

| # | Lỗi gặp phải | Nguyên nhân | Cách script xử lý |
|---|---|---|---|
| 1 | *"Plugin not compatible with this version of GLPI"* | `setup.php` khai báo `PLUGIN_BARCODE_MAX_GLPI = '10.0.99'` | Đổi thành `'99.0.99'` |
| 2 | *"require_once(.../vendor/autoload.php): Failed to open stream"* | Bản tải từ nhánh `develop` (.tar.gz) **thiếu thư mục `vendor/`** | Dùng **bản release .tar.bz2** (đã đóng gói sẵn `vendor/`) |
| 3 | *"Executing direct queries is not allowed!"* | GLPI 11 **vô hiệu hoá** `$DB->query()`; plugin cũ vẫn dùng | Đổi hết `$DB->query(` → `$DB->doQuery(` trong `hook.php` (9 chỗ) |

> ⚠️ **Lưu ý quan trọng khi tự cài tay:** Phải tải từ mục **Releases**, KHÔNG tải từ nút
> "Download ZIP" của nhánh `develop`, vì bản ZIP thiếu thư viện `vendor/`.

---

## 3. ĐIỀU KIỆN CẦN CÓ (đã kiểm tra — đều ĐẠT)

| Yêu cầu | Trạng thái | Ghi chú |
|---|---|---|
| Extension PHP **bcmath** | ✅ Đã bật | Bắt buộc để sinh QR (xử lý số học lớn) |
| Extension PHP **gd** | ✅ Có sẵn trong image | Vẽ ảnh PNG cho mã QR |
| PHP ≥ 8.1 | ✅ 8.4.13 | Image `glpi/glpi:11.0.0` |
| Thư viện `deltalab/phpqrcode` | ✅ Có trong `vendor/` | Sinh mã QR |
| Thư viện `pear/Image_Barcode` | ✅ Có trong `vendor/` | Sinh mã vạch 1D |
| Thư viện `rospdf/pdf-php` | ✅ Có trong `vendor/` | Xuất PDF nhiều nhãn |

Đã kiểm chứng thực tế:

```
QRcode class: OK
Image_Barcode: OK
QR PNG generated: 243 bytes
```

---

## 4. CÀI ĐẶT TỰ ĐỘNG (KHUYẾN NGHỊ)

### Bước 1 — Chạy script

```bash
cd <DUONG-DAN-DU-AN>/glpi-helpdesk
bash scripts/cai-plugin-qrcode.sh
```

Kết quả mong đợi (rút gọn):

```
[ OK ] Container helpdesk-glpi dang chay
[ OK ] Extension day du
[ OK ] Da tai (1.9M)
[ OK ] Thu muc nguon: barcode (co vendor/ day du)
[ OK ] Da copy plugin 'barcode' vao volume
    -> Rang buoc phien ban hien tai:
       define('PLUGIN_BARCODE_MIN_GLPI', '10.0.0');
       define('PLUGIN_BARCODE_MAX_GLPI', '99.0.99');     <- da noi long
    -> So loi goi query() cu con lai (phai = 0):
       0                                                  <- da va xong
[ OK ] Da xu ly tuong thich GLPI 11 (version + doQuery)
    -> Trang thai plugin trong CSDL:
       name     version  state
       Barcode  2.7.1    4          <- 4 = da cai, chua bat
```

### Bước 2 — Kích hoạt

Nếu script dừng ở `state = 4` (đã cài, chưa bật), chạy thêm:

```bash
docker exec -u www-data helpdesk-glpi php /var/www/glpi/bin/console plugin:activate barcode
```

→ Kết quả: **`Plugin "barcode" has been activated.`**

### Bước 3 — Kiểm tra

```bash
docker exec -u www-data helpdesk-glpi php /var/www/glpi/bin/console plugin:list
```

Kết quả đúng phải là:

```
| Plugin Key | Name    | Version | Status  | Install method     |
| barcode    | Barcode | 2.7.1   | Enabled | Manually installed |
```

---

## 5. CÀI ĐẶT THỦ CÔNG QUA GIAO DIỆN WEB

Nếu muốn thao tác trên trình duyệt:

1. Mở **http://localhost:8080** → đăng nhập tài khoản quản trị.
2. Vào **Cấu hình (Setup) → Plugin**.
3. Thấy dòng **Barcode** ở trạng thái *"Không được cài đặt"*.
4. Bấm **Cài đặt (Install)** → đợi vài giây.
5. Bấm **Bật (Enable)**.
6. Vào tab **Barcode** trong mục Cấu hình để chọn kiểu mã mặc định (`code128`, `qrcode`...).

> 💡 Nếu nút *Cài đặt* báo lỗi đỏ, nghĩa là chưa chạy bước vá lỗi — hãy chạy
> `bash scripts/cai-plugin-qrcode.sh` trước rồi thử lại.

---

## 6. CÁCH SỬ DỤNG — IN MÃ QR HÀNG LOẠT

> ✅ **ĐÃ KIỂM CHỨNG THỰC TẾ** bằng trình duyệt tự động — xem ảnh
> `anh-giao-dien/11-cau-hinh-nhan-qr.png` và `13-phieu-qr-da-sinh.png`.

### 6.1. In mã QR cho thiết bị (qua Hành động hàng loạt)

> ⚠️ **LƯU Ý QUAN TRỌNG:** plugin Barcode **KHÔNG** thêm tab riêng vào hồ sơ
> thiết bị. Nó chỉ hoạt động qua **Hành động hàng loạt**. Đây là điểm khác
> so với nhiều tài liệu trên mạng.

1. Vào **Tài sản (Assets) → Các máy tính (Computers)**.
2. **Tích chọn** các máy cần in nhãn ở cột đầu tiên.
3. Nút **Các hành động** xuất hiện ở góc trên trái → bấm vào.
4. Một **hộp thoại** hiện ra, có ô xổ xuống **"Các hành động"** → chọn:
   - **`Barcode - Print QRcodes`** → in mã QR
   - **`Barcode - Print barcodes`** → in mã vạch 1D
5. Sau khi chọn, form cấu hình nhãn hiện ra:

   | Tham số | Ý nghĩa |
   |---|---|
   | Số sê-ri / Mã tài sản / Mã số / UUID / Tên | Chọn thông tin in kèm mã |
   | Ngày QRcode | Ngày sinh mã (tự động) |
   | Page size | Khổ giấy: **A4** |
   | Orientation | Hướng: **Portrait** hoặc Landscape |
   | Display border | Có viền nhãn hay không |
   | Display labels | Hiện nhãn mô tả |
   | Not use first xx barcodes | Bỏ qua xx nhãn đầu (khi in tiếp trang bị lỗi) |

6. Bấm **Create** → hệ thống sinh file PDF.
7. Quay lại danh sách, bấm liên kết **"Generated file"** (Tệp đã tạo) ở thông
   báo phía trên để **tải file PDF về** và in.

**Kết quả thực tế đã kiểm chứng:** file PDF 1 trang, chứa mã QR hợp lệ kèm
tên thiết bị in bên dưới (`PC-TEST-QR-DLU-001`). Xem `13-phieu-qr-da-sinh.png`.

### 6.2. In mã QR cho phiếu sự cố (Ticket)

Plugin cũng hỗ trợ in QR cho **Ticket** — hữu ích để dán lên biên bản bàn giao
hoặc phiếu yêu cầu sửa chữa. Vào **Hỗ trợ (Assistance) → Phiếu** → tích chọn →
**Các hành động** → chọn **Barcode - Print QRcodes** → **Create**.

### 6.3. Cấu hình kiểu mã & kích thước

Vào **Cấu hình (Setup) → Barcode**:

| Tham số | Ý nghĩa | Gợi ý cho dự án |
|---|---|---|
| Type | Kiểu mã vạch | `code128` (mã vạch) hoặc QR |
| Size | Cỡ chữ trên nhãn | 8–10 |
| Orientation | Hướng in | Landscape (ngang) cho nhiều nhãn/trang |
| Max per page | Số nhãn mỗi trang | 24 (3 cột × 8 hàng) |

### 6.4. ⚠️ HAI LỖI ÂM THẦM ĐÃ PHÁT HIỆN & SỬA

Hai lỗi này **KHÔNG hiện thông báo lỗi** — chỉ im lặng không ra kết quả.
Đã sửa và tích hợp vào `scripts/cai-dat-tat-ca.sh`:

| # | Triệu chứng | Nguyên nhân gốc | Cách sửa |
|---|---|---|---|
| 1 | Bấm **Create** xong quay về danh sách, **không có file PDF nào** | Thư mục `/var/glpi/files/_plugins/barcode/` **không tồn tại**. Hàm `file_put_contents()` (`barcode.class.php:428`) thất bại **âm thầm**, không xử lý lỗi | `mkdir -p /var/glpi/files/_plugins/barcode` + `chown www-data` |
| 2 | Menu **"Các hành động"** **không có** tuỳ chọn `Barcode - Print QRcodes` | GLPI chưa cấp quyền `plugin_barcode_config` cho hồ sơ nào. Plugin cần quyền này mới đăng ký massive action (`setup.php`: `Session::haveRight('plugin_barcode_config', UPDATE)`) | `UPDATE glpi_profilerights SET rights=31 WHERE profiles_id=4 AND name='plugin_barcode_barcode'` + thêm dòng `plugin_barcode_config` |

**Kiểm tra nhanh file QR đã sinh hay chưa:**

```bash
docker exec helpdesk-glpi ls -la /var/glpi/files/_plugins/barcode/
# Phai thay: <id>_QRcode.pdf
```

---

## 7. QUY TRÌNH NGHIỆP VỤ ĐỀ XUẤT (dán nhãn thiết bị DLU)

Đây là quy trình đưa vào **báo cáo đồ án** — gắn với thực tế phòng máy DLU:

### 7.1. Quy ước mã tài sản (đặt trong trường `Inventory number`)

```
<ĐƠN VỊ>-<LOẠI>-<PHÒNG>-<SỐ THỨ TỰ>
```

Ví dụ:

| Mã tài sản | Ý nghĩa |
|---|---|
| `ITC-PC-A101-001` | Trung tâm CNTT · Máy tính · Phòng A101 · máy số 1 |
| `ITC-SW-A101-01` | Trung tâm CNTT · Switch mạng · Phòng A101 · số 1 |
| `KTT-PR-B203-03` | Khoa Toán-Tin · Máy in · Phòng B203 · số 3 |
| `H1-MON-H105-12` | Khu hành chính H1 · Màn hình · Phòng H105 · số 12 |

> Prefix đơn vị: `ITC` (Trung tâm CNTT), `KTT` (Khoa Toán-Tin), `KCNTT` (Khoa CNTT),
> `H1`/`H2` (Khu hành chính), `TT` (Thư viện), `KGD` (Khu giảng đường).

### 7.2. Nội dung mã QR nên chứa gì?

**Khuyến nghị:** chỉ chứa **mã tài sản** (ngắn, quét nhanh, ít lỗi):

```
ITC-PC-A101-001
```

**Không nên** nhồi URL dài vào QR vì:
- QR quá dày → khó quét khi nhãn bị xước/mờ.
- URL chứa `localhost` → đổi máy chủ là hỏng hết nhãn.
- Rủi ro bảo mật: lộ địa chỉ nội bộ.

Khi cần, có thể dùng **URL rút gọn nội bộ** trỏ tới
`https://helpdesk.dlu.edu.vn/front/computer.form.php?id=<ID>` — nhưng phải
triển khai tên miền nội bộ trước (xem mục 9).

### 7.3. Các bước triển khai thực tế

```
Bước 1: Nhập/cập nhật thiết bị vào GLPI (đã có sẵn ở bảng dữ liệu nền)
        → gán "Inventory number" theo quy ước trên
Bước 2: Lọc theo phòng (Location) → tích chọn cả phòng
Bước 3: Hành động hàng loạt → Barcode → Print QRcodes  → tải PDF
Bước 4: In ra giấy decal (nhãn 40×30mm), dán lên thân máy
Bước 5: Cài app quét QR trên điện thoại kỹ thuật viên
Bước 6: Khi có sự cố → quét QR → tra mã tài sản trong GLPI → tạo Ticket
Bước 7: Dán thêm 1 nhãn QR cho Ticket vào biên bản sửa chữa
```

---

## 8. PHƯƠNG ÁN DỰ PHÒNG — SINH QR BẰNG PYTHON

Trong trường hợp plugin không chạy được (ví dụ: nâng cấp GLPI lên phiên bản
tương lai làm plugin lỗi), dự án vẫn có **phương án 2** hoàn toàn độc lập:
script Python đọc danh sách thiết bị từ **API REST của GLPI** rồi tự sinh
file PDF/PNG chứa mã QR.

```bash
python scripts/sinh-ma-qr.py
```

**Ưu điểm phương án này:**
- Không phụ thuộc plugin → không sợ GLPI nâng cấp làm hỏng.
- Tự do bố cục nhãn (thêm logo DLU, tên phòng, tên khoa...).
- Có thể chạy định kỳ để in lại nhãn bị mất.
- Là **điểm cộng** trong báo cáo: thể hiện kỹ năng lập trình, không chỉ dùng phần mềm có sẵn.

(Chi tiết xem file `scripts/sinh-ma-qr.py` và mục 10 của tài liệu này.)

---

## 9. GỢI Ý TRIỂN KHAI THỰC TẾ TẠI DLU

### 9.1. Tên miền nội bộ

Để mã QR trỏ tới hồ sơ thiết bị, cần một tên miền nội bộ:

```
helpdesk.dlu.edu.vn   →  trỏ về IP máy chủ chạy Docker (cổng 8443)
```

Cấu hình trong file `hosts` của máy trạm, hoặc DNS nội bộ của Trung tâm CNTT.

### 9.2. Bật HTTPS với tên miền thật

Sửa `nginx/conf.d/default.conf`, đổi `server_name` thành tên miền nội bộ; đồng
thời **thêm tên miền đó vào mục `[ san ]`** của `nginx/ssl/openssl-san.cnf`
(nếu không, trình duyệt sẽ báo sai tên miền — xem mục 3.4 của
`HUONG-DAN-TRIEN-KHAI.md`). Sau đó xoá chứng chỉ cũ và chạy lại `bash start.sh`:

```bash
rm nginx/ssl/glpi.crt nginx/ssl/glpi.key
bash start.sh
```

### 9.3. Phân quyền kỹ thuật viên

Tạo nhóm người dùng **"Kỹ thuật viên phòng máy"** với quyền:
- Xem thiết bị: theo phòng phụ trách (`Location`)
- Tạo/sửa Ticket
- **Không** có quyền xoá thiết bị, không xem được cấu hình hệ thống

### 9.4. Vật tư in nhãn đề xuất

| Loại | Kích thước | Số lượng (ước tính) |
|---|---|---|
| Giấy decal A4 | 3 cột × 8 hàng | Theo số thiết bị thực tế |
| Nhãn chống nước | 40×30mm | Cho thiết bị gần cửa sổ, phòng máy lạnh |
| Mực in | Laser đen trắng | — |

---

## 10. XỬ LÝ LỖI THƯỜNG GẶP

| Lỗi | Nguyên nhân | Cách xử lý |
|---|---|---|
| `Plugin not compatible with this version` | Chưa vá `MAX_GLPI` | Chạy `bash scripts/cai-plugin-qrcode.sh` |
| `Executing direct queries is not allowed!` | Còn `$DB->query(` cũ | Script vá tự động; kiểm tra `grep -c 'DB->query(' hook.php` = 0 |
| `vendor/autoload.php: Failed to open stream` | Tải nhầm bản `develop` | Phải dùng bản **release .tar.bz2** |
| Không thấy mục **Barcode** trong Hành động hàng loạt | Plugin chưa **Bật** (Enable) | `plugin:activate barcode` |
| QR in ra bị trắng/trống | Thiếu extension `gd` hoặc `bcmath` | Kiểm tra `php -m \| grep -E 'gd\|bcmath'` |
| `Module X is already loaded` (log PHP) | Khai báo trùng extension trong `php-custom.ini` | File ini hiện chỉ khai báo `bcmath` (đã sửa) |

### Kiểm tra nhanh tình trạng plugin

```bash
cd <DUONG-DAN-DU-AN>/glpi-helpdesk

# 1. Plugin co dang Enabled?
docker exec -u www-data helpdesk-glpi php /var/www/glpi/bin/console plugin:list

# 2. Trang thai trong CSDL
source .env
docker exec helpdesk-db mariadb -u "$GLPI_DB_USER" -p"$GLPI_DB_PASSWORD" glpi \
  -e "SELECT name,version,state FROM glpi_plugins;"
#   1 = ACTIVATED (tot nhat) | 2 = NOTINSTALLED | 3 = TOBECONFIGURED | 4 = NOTACTIVATED

# 3. Bang du lieu cua plugin da tao chua?
docker exec helpdesk-db mariadb -u "$GLPI_DB_USER" -p"$GLPI_DB_PASSWORD" glpi \
  -e "SHOW TABLES LIKE '%barcode%';"
#   Phai thay: glpi_plugin_barcode_configs, glpi_plugin_barcode_configs_types

# 4. Thu sinh 1 ma QR that
docker exec -u www-data helpdesk-glpi sh -c 'cd /var/www/glpi/plugins/barcode && \
  php -r "require \"vendor/autoload.php\"; QRcode::png(\"TEST-001\", \"/tmp/q.png\", QR_ECLEVEL_L, 4); \
  echo filesize(\"/tmp/q.png\")>0 ? \"QR OK\" : \"QR FAIL\";"'
```

---

## 11. BẢNG TÓM TẮT KẾT QUẢ ĐÃ KIỂM CHỨNG

| Hạng mục | Kết quả |
|---|---|
| Plugin Barcode tải về | ✅ 2.7.1 (bản release, 1.9 MB) |
| Thư mục `vendor/` đầy đủ | ✅ `QRcode: OK`, `Image_Barcode: OK` |
| Vá tương thích GLPI 11 | ✅ `MAX_GLPI = 99.0.99`, `query()` → `doQuery()` (0 lỗi còn lại) |
| Cài đặt (schema) | ✅ Tạo 2 bảng `glpi_plugin_barcode_configs*` |
| Kích hoạt | ✅ `state = 1` (ACTIVATED) |
| Quyền hồ sơ | ✅ Đã cấp `plugin_barcode_barcode` + `plugin_barcode_config` cho Super-Admin |
| Tuỳ chọn QR trong menu | ✅ `Barcode - Print QRcodes` hiện trong "Các hành động" |
| Sinh mã QR thực tế | ✅ File PDF 18.813 byte, 1 trang, QR hợp lệ, quét được |
| Thư mục xuất file | ✅ `/var/glpi/files/_plugins/barcode/` (đã tạo trong script cài) |
| Ảnh minh chứng | ✅ `anh-giao-dien/11-cau-hinh-nhan-qr.png`, `13-phieu-qr-da-sinh.png` |

> **Kiểm chứng bằng trình duyệt tự động thật (Chrome headless):**
> tạo thiết bị → tích chọn → Các hành động → Barcode - Print QRcodes →
> Create → tải PDF về → xác nhận mã QR quét được → xoá dữ liệu test.

---

*Tài liệu thuộc đồ án thực tập "Xây dựng hệ thống hỗ trợ kỹ thuật (IT Helpdesk)" — Trường Đại học Đà Lạt.*
