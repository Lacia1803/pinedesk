# HƯỚNG DẪN TRIỂN KHAI HỆ THỐNG PINEDESK (GLPI)

Tài liệu hướng dẫn cài đặt và vận hành hệ thống Hỗ trợ Kỹ thuật (PineDesk)
dựa trên nền tảng mã nguồn mở GLPI 11.

---

## 1. TỔNG QUAN HỆ THỐNG

### 1.1. Kiến trúc

Hệ thống gồm 4 thành phần, chạy trong các container Docker độc lập:

| Thành phần | Công nghệ | Vai trò |
|---|---|---|
| `pinedesk-gateway` | Nginx 1.27 | Cổng vào, HTTPS, bảo mật, chống brute-force |
| `pinedesk-glpi` | GLPI 11 (PHP 8.2) | Ứng dụng ITSM chính |
| `pinedesk-db` | MariaDB 10.11 | Cơ sở dữ liệu |
| `pinedesk-redis` | Redis 7 | Cache phiên làm việc |

### 1.2. Sơ đồ luồng truy cập

```
Người dùng (trình duyệt)
        |
        | HTTPS :8443
        v
 [ pinedesk-gateway ]  <- Nginx: SSL, rate limit, chặn file nhạy cảm
        |
        | HTTP nội bộ :80
        v
  [ pinedesk-glpi ]    <- GLPI: nghiệp vụ ITSM
        |          \
        |           \-> [ pinedesk-redis ]  (cache)
        v
  [ pinedesk-db ]      <- MariaDB: lưu dữ liệu
```

### 1.3. Chức năng đáp ứng yêu cầu đề bài

| Yêu cầu đề bài | GLPI đáp ứng bằng |
|---|---|
| Quản lý phòng máy, máy tính, thiết bị mạng | Module **Assets** (Máy tính, Màn hình, Thiết bị mạng, Thiết bị ngoại vi) |
| Hồ sơ thiết bị + mã QR | Module **Assets** + sinh QR qua extension `bcmath` |
| Quản lý cấu hình, vị trí, tình trạng | Trường **Localisation**, **Status**, **Custom Fields** |
| Lịch sử sửa chữa / bảo trì | Ticket liên kết thiết bị + **Recurring tickets** (lịch định kỳ) |
| Tiếp nhận sự cố dạng ticket | Module **Assistance** (Service Desk, đầy đủ nghiệp vụ ITIL) |
| Phân công người xử lý, theo dõi tiến độ | **Assignment**, **SLA**, **Timeline** trên ticket |
| Dashboard thống kê | Module **Dashboards** (kéo thả, biểu đồ tùy chỉnh) |
| Quản lý phần mềm cài đặt | Module **Software** (quản lý phần mềm trên từng máy) |
| Việt hóa | Gói `vi_VN` + lớp phủ bổ sung của đồ án → **31,8%** (xem `HUONG-DAN-GIAO-DIEN-VA-VIET-HOA.md` mục A.2) |
| Tùy biến giao diện | Bảng màu "Đà Lạt" (SCSS) + plugin `dlubrand` ghi đè CSS |
| Bảo mật, an toàn dữ liệu | HTTPS, rate limit, chặn file nhạy cảm, phân quyền, sao lưu |

### 1.4. Cài đặt nhanh — CHỈ 1 LỆNH

```bash
# Di chuyen vao thu muc goc cua du an (thay bang duong dan thuc tren may ban)
cd <DUONG-DAN-DU-AN>/pinedesk
bash scripts/cai-dat-tat-ca.sh
```

Script tự động làm 6 việc: khởi động container → nạp danh mục nghiệp vụ → bật plugin
(QR + giao diện) → nạp bản dịch tiếng Việt → **nạp SLA thật + cơ chế chống lạm dụng**
→ kiểm tra sức khỏe hệ thống, rồi in ra kết quả từng bước (màu xanh = đạt).

> Chi tiết về giao diện & Việt hoá: xem **`tai-lieu/HUONG-DAN-GIAO-DIEN-VA-VIET-HOA.md`**
> Chi tiết về plugin QR: xem **`tai-lieu/HUONG-DAN-PLUGIN-QRCODE.md`**
> Chi tiết về chống lạm dụng nộp phiếu: xem **`tai-lieu/CHONG-LAM-DUNG.md`**

#### Nạp riêng SLA + chống lạm dụng (nếu hệ thống đã cài trước đó)

```bash
bash scripts/nap-sla-va-chong-lam-dung.sh   # SLA thật + hạn mức + nhật ký
bash scripts/kiem-tra-lam-dung.sh           # kiểm tra lạm dụng (báo cáo)
bash scripts/kiem-tra-lam-dung.sh --thuc-thi # kiểm tra + ghi nhật ký vi phạm
```

---

## 2. YÊU CẦU HỆ THỐNG

### 2.1. Phần mềm bắt buộc

| Phần mềm | Phiên bản | Ghi chú |
|---|---|---|
| Docker Desktop | 20.10+ | Kèm Docker Compose |
| OpenSSL | 3.x | Có sẵn trên Windows Git Bash |

### 2.2. Cấu hình máy tối thiểu

| Tài nguyên | Tối thiểu | Khuyến nghị |
|---|---|---|
| RAM | 4 GB | 8 GB |
| Dung lượng đĩa | 10 GB | 20 GB |
| CPU | 2 nhân | 4 nhân |

---

## 3. CÀI ĐẶT

### 3.1. Chuẩn bị

**Bước 1** — Cài đặt Docker Desktop:
> Tải tại https://www.docker.com/products/docker-desktop/
> Sau khi cài, mở Docker Desktop và chờ đến khi biểu tượng chuyển sang trạng thái "running".

**Bước 2** — Mở Git Bash và di chuyển vào thư mục dự án:

```bash
cd <DUONG-DAN-DU-AN>/pinedesk
```

### 3.2. Cấu hình môi trường

**Bước 1** — Tạo file cấu hình từ mẫu:

```bash
cp .env.example .env
```

**Bước 2** — Mở file `.env` và đổi **TẤT CẢ** mật khẩu:

```bash
# Mo file bang trinh soan thao
notepad .env
```

Nội dung cần sửa:

```ini
GLPI_DB_PASSWORD=<mat khau manh>
DB_ROOT_PASSWORD=<mat khau manh khac>
REDIS_PASSWORD=<mat khau manh khac>
```

> **LƯU Ý BẢO MẬT:** Đây là bước quan trọng nhất.
> Không dùng mật khẩu mẫu khi triển khai thực tế.
> Nên dùng mật khẩu từ 16 ký tự, gồm chữ hoa, chữ thường, số và ký tự đặc biệt.

### 3.3. Khởi động hệ thống

**Cách 1** — Dùng script tự động (khuyến nghị):

```bash
bash start.sh
```

Script sẽ tự động:
1. Kiểm tra Docker đang chạy
2. Kiểm tra file cấu hình
3. Tạo chứng chỉ SSL tự ký cho mạng nội bộ (**có SAN** — xem mục 3.4)
4. Tải image và khởi động 4 container
5. Hiển thị thông tin truy cập

**Cách 2** — Chạy thủ công:

```bash
docker-compose up -d
```

Quá trình này mất 3–5 phút ở lần chạy đầu (do phải tải image).

### 3.4. Chứng chỉ SSL — bắt buộc có SAN

Chứng chỉ tự ký **phải có Subject Alternative Name (SAN)**. Trình duyệt hiện đại
(Chrome, Firefox, Edge) **bỏ qua** trường `Common Name` và **chỉ đọc SAN**; thiếu
SAN thì cảnh báo nặng hơn và **không thể thêm ngoại lệ** để truy cập tiếp.

Vì `openssl req -subj` **không đặt được SAN**, dự án khai báo tên miền/IP trong
file [`nginx/ssl/openssl-san.cnf`](../nginx/ssl/openssl-san.cnf):

```ini
[ san ]
DNS.1 = localhost
DNS.2 = pinedesk.local
DNS.3 = *.localhost
IP.1  = 127.0.0.1
IP.2  = ::1
```

`start.sh` dùng file này để sinh chứng chỉ. Script **tự kiểm tra SAN** và nếu gặp
chứng chỉ cũ thiếu SAN, nó **tự động sinh lại** (bản cũ được giữ lại với hậu tố
`.thieu-san.bak`).

Kiểm chứng:

```bash
openssl x509 -in nginx/ssl/glpi.crt -noout -text | grep -A1 "Subject Alternative Name"
# Phai thay: DNS:localhost, DNS:pinedesk.local, DNS:*.localhost, IP Address:127.0.0.1, ...
```

> **Triển khai với tên miền thật:** sửa `nginx/conf.d/default.conf` (`server_name`)
> **và** thêm tên miền vào mục `[ san ]` của `openssl-san.cnf`, rồi xoá
> `nginx/ssl/glpi.crt` và chạy lại `bash start.sh` để sinh chứng chỉ mới.

### 3.5. Kiểm tra kết quả

```bash
docker ps --filter "name=pinedesk-"
```

Kết quả mong đợi — cả 4 container đều `Up`:

```
NAMES              STATUS
pinedesk-gateway   Up (healthy)
pinedesk-glpi      Up
pinedesk-db        Up (healthy)
pinedesk-redis     Up (healthy)
```

---

## 4. TRUY CẬP VÀ CẤU HÌNH BAN ĐẦU

### 4.1. Đăng nhập lần đầu

Mở trình duyệt và truy cập:

```
https://localhost:8443
```

> **Cảnh báo chứng chỉ:** Trình duyệt sẽ hiện cảnh báo bảo mật
> ("Kết nối không riêng tư" / "Not secure").
> Đây là hiện tượng **bình thường** với chứng chỉ tự ký cho mạng nội bộ.
> Nhấn "Nâng cao" (Advanced) → "Tiếp tục truy cập localhost" (Proceed).

Đăng nhập bằng tài khoản mặc định:

| | |
|---|---|
| Tài khoản | `glpi` |
| Mật khẩu | `glpi` |

### 4.2. Đổi mật khẩu quản trị (BẮT BUỘC)

> **Đây là việc đầu tiên phải làm.** Tài khoản `glpi` mặc định là lỗ hổng
> bảo mật nghiêm trọng nếu giữ nguyên.

1. Vào **Cấu hình** (Setup) → **Người dùng** (Users)
2. Chọn tài khoản `glpi`
3. Đổi mật khẩu thành mật khẩu mạnh

### 4.3. Chuyển sang tiếng Việt

**Bước 1** — Đặt tiếng Việt làm ngôn ngữ mặc định cho toàn hệ thống:

1. Vào **Cấu hình** (Setup) → **Cấu hình chung** (General)
2. Tìm mục **Ngôn ngữ mặc định** (Default language)
3. Chọn **Tiếng Việt (vi_VN)**
4. Nhấn **Lưu** (Save)

**Bước 2** — Đặt tiếng Việt cho tài khoản cá nhân:

1. Vào **Cài đặt cá nhân** (My settings)
2. Mục **Ngôn ngữ** (Language) → chọn **Tiếng Việt**
3. Nhấn **Lưu**

> **Kiểm tra:** Sau khi đổi, toàn bộ menu và nhãn sẽ hiển thị tiếng Việt.
> Nếu vẫn còn tiếng Anh, hãy xóa cache trình duyệt (Ctrl + F5).

### 4.4. Kích hoạt giao diện tùy biến

Đồ án dùng **3 bảng màu** trong `themes/`: `da_lat` (xanh rêu — mặc định),
`da_lat_suong` (xanh hồ), `da_lat_nang` (cam đất).

> **KHÔNG cần copy thủ công vào container.** Thư mục `themes/` đã được
> **bind-mount** sẵn vào `/var/glpi/files/_themes` trong `docker-compose.yml`,
> nên sửa file trên máy là GLPI thấy ngay. (Cách `docker cp` trong tài liệu
> GLPI 10 không còn cần thiết.)

Chạy 1 lệnh để cài logo + xoá cache + đặt bảng màu mặc định + kiểm tra:

```bash
bash scripts/cai-giao-dien.sh
```

Sau đó vào **Cài đặt cá nhân** → **Giao diện** (Palette) → chọn một trong ba
bảng màu trên.

> **★ Màu nằm ở đâu?** `themes/*.scss` **chỉ đăng ký *tên* bảng màu** — **không
> chứa mã màu**. Toàn bộ mã màu **giao diện GLPI** nằm **duy nhất** tại
> `plugins/dlubrand/public/css/dlu-theme.css`. Muốn đổi màu → sửa **1 file đó**
> (chi tiết xem `tai-lieu/HUONG-DAN-GIAO-DIEN-VA-VIET-HOA.md`, mục B.1).
> *Ngoại lệ:* trang giới thiệu `landing/` do nginx phục vụ riêng, dùng bảng màu
> ở `landing/assets/css/style.css` — đổi màu thương hiệu phải sửa cả hai nơi.

---

## 5. CẤU HÌNH NGHIỆP VỤ

> ⚡ **TỰ ĐỘNG HOÁ:** toàn bộ mục 5.1 – 5.4 dưới đây **đã có script tạo sẵn**.
> Chạy 1 lệnh là có ngay dữ liệu nền:
>
> ```bash
> bash scripts/nap-du-lieu-nen.sh
> ```
>
> Script tự tạo: **12 tòa nhà · 54 phòng máy · 10 trạng thái · 24 hãng ·
> 35 loại thiết bị · 55 model · 10 loại sự cố cấp 1 · 69 loại cấp 2 ·
> 11 nguồn tiếp nhận · 11 hình thức xử lý · 11 nhóm phần mềm**.
>
> Chạy lại nhiều lần **không tạo dữ liệu trùng** (có kiểm tra `NOT EXISTS`).
> Phần dưới đây giải thích cấu trúc & cách thêm thủ công nếu cần.

### 5.1. Tạo cấu trúc phòng máy

Vào **Cấu hình** → **Danh mục** (Dropdowns) → **Vị trí** (Locations)

Cây vị trí 3 cấp theo thực tế Trường Đại học Đà Lạt
(địa chỉ: *Số 01 Phù Đổng Thiên Vương, Phường Lâm Viên, TP Đà Lạt, tỉnh Lâm Đồng*):

```
Trường Đại học Đà Lạt
├── Khu hành chính H1
├── Khu hành chính H2
├── Giảng đường A1  →  Phòng máy A1.101, A1.102, ...
├── Giảng đường A2  →  Phòng Lab A2.201, ...
├── Giảng đường B1  →  Phòng máy B1.101, ...
├── Giảng đường B2  →  Phòng Lab B2.301, ...
├── Trung tâm CNTT (ITC)
├── Thư viện
└── Ký túc xá
```

### 5.2. Tạo danh mục thiết bị

Vào **Cấu hình** → **Danh mục** → **Loại thiết bị** (Asset types)

| Loại | Ví dụ |
|---|---|
| Máy tính để bàn | PC FPT Elead, Dell OptiPlex |
| Máy tính xách tay | Dell Latitude, HP ProBook |
| Màn hình | Dell P2419H, Samsung LS24 |
| Thiết bị mạng | Switch Cisco, Router TP-Link |
| Máy in | HP LaserJet, Canon LBP |
| Máy chiếu | Epson EB-X06, Sony VPL |

### 5.3. Tạo trạng thái thiết bị

Vào **Cấu hình** → **Danh mục** → **Trạng thái** (Status)

| Trạng thái | Ý nghĩa | Màu gợi ý |
|---|---|---|
| Đang hoạt động | Thiết bị dùng tốt | Xanh lá |
| Đang sửa chữa | Đang được xử lý | Vàng |
| Hỏng | Không sử dụng được | Đỏ |
| Chờ thanh lý | Hết khấu hao, chờ xử lý | Xám |
| Trong kho | Chưa cấp phát | Xanh dương |

### 5.4. Tạo danh mục sự cố

Vào **Cấu hình** → **Danh mục** → **Loại sự cố** (Ticket categories)

```
Sự cố phần cứng
├── Máy không khởi động được
├── Màn hình không hiển thị
├── Bàn phím / chuột lỗi
└── Ổ cứng có tiếng lạ

Sự cố mạng
├── Không kết nối được Internet
├── Mạng chậm
└── Mất kết nối LAN

Sự cố phần mềm
├── Lỗi hệ điều hành
├── Ổ đĩa đầy
└── Phần mềm không chạy

Thiết bị ngoại vi
├── Máy in không in được
├── Máy chiếu không lên hình
└── Tai nghe / loa lỗi
```

### 5.5. Nhóm theo cơ cấu tổ chức thực tế của DLU

> ✅ **ĐÃ TẠO SẴN** tự động — chạy `bash scripts/nap-du-lieu-nen.sh`

Script tạo cây nhóm 2 cấp khớp **cơ cấu tổ chức thật** của Trường Đại học Đà Lạt
(lấy từ website chính thức `dlu.edu.vn`):

```
Nhóm (Groups)
├── Khoa (16)
│   ├── Khoa Toán – Tin
│   ├── Khoa Công nghệ Thông tin        ← mật độ thiết bị cao nhất
│   ├── Khoa Vật lý và Kỹ thuật hạt nhân
│   ├── Khoa Hóa học và Môi trường
│   ├── ... (12 khoa còn lại)
├── Phòng chức năng (10)
│   ├── Phòng Cơ sở Vật chất           ← ĐƠN VỊ CHỦ QUẢN TÀI SẢN
│   ├── Phòng Quản lý Đào tạo
│   └── ... (8 phòng còn lại)
└── Trung tâm và Viện (7)
    ├── Trung tâm Công nghệ thông tin   ← ĐƠN VỊ VẬN HÀNH KỸ THUẬT
    ├── Trung tâm Ngoại ngữ và Đào tạo nguồn nhân lực
    └── ... (5 đơn vị còn lại)
```

> 📖 Chi tiết đầy đủ về DLU + cách ánh xạ vào GLPI:
> xem **`tai-lieu/THONG-TIN-DAI-HOC-DA-LAT.md`**

### 5.6. Phân quyền người dùng

Vào **Cấu hình** → **Người dùng** → **Hồ sơ** (Profiles)

| Hồ sơ | Quyền hạn | Dành cho |
|---|---|---|
| Super-Admin | Toàn quyền | Quản trị viên hệ thống |
| Admin | Quản lý nhưng không sửa cấu hình lõi | Cán bộ Phòng Cơ sở Vật chất |
| Technician | Xử lý ticket, cập nhật thiết bị | Kỹ thuật viên Trung tâm CNTT |
| Self-Service | Chỉ tạo ticket, xem thiết bị của mình | Sinh viên, giảng viên |

> **QUAN TRỌNG:** Không cấp quyền Admin cho tất cả người dùng.
> Nguyên tắc "quyền tối thiểu" (least privilege) là yêu cầu bắt buộc về bảo mật.

### 5.7. Quyền cho plugin sinh mã QR

Plugin Barcode cần **2 quyền** mới hoạt động (script cài đã tự cấp):

| Quyền | Mục đích |
|---|---|
| `plugin_barcode_barcode` | Cho phép sinh & in mã QR/mã vạch |
| `plugin_barcode_config` | Đăng ký tuỳ chọn vào menu "Các hành động" |

> ⚠️ Nếu thiếu `plugin_barcode_config`, tuỳ chọn `Barcode - Print QRcodes`
> sẽ **không xuất hiện** trong menu, dù plugin đã được kích hoạt.
> Xem mục 6.4 của `HUONG-DAN-PLUGIN-QRCODE.md`.

---

## 6. SAO LƯU VÀ PHỤC HỒI

### 6.1. Sao lưu thủ công

```bash
cd <DUONG-DAN-DU-AN>/pinedesk
bash backup/backup.sh
```

Kết quả tạo 3 file trong `backup/`:

| File | Nội dung |
|---|---|
| `*_db.sql` | Toàn bộ cơ sở dữ liệu |
| `*_files.tar.gz` | `glpicrypt.key`, `config_db.php`, bản dịch, theme, tệp đính kèm, plugin (`/var/glpi/*` + `/var/www/glpi/plugins`) |
| `*_config.tar.gz` | File cấu hình dự án (docker-compose, nginx, themes, scripts) |

> Script tự kiểm tra `glpicrypt.key` có trong bản sao lưu không; thiếu khoá này
> thì dừng ngay và báo lỗi (vì phục hồi sẽ không giải mã được dữ liệu).

### 6.2. Sao lưu tự động hàng ngày

**Trên Windows** — dùng Task Scheduler:

1. Mở **Task Scheduler** → **Create Basic Task**
2. Đặt tên: `Sao luu PineDesk`
3. Trigger: **Daily**, chọn giờ (ví dụ 23:00)
4. Action: **Start a program**
   - Program: `C:\Program Files\Git\bin\bash.exe`
   - Arguments: `-c "cd /g/<DUONG-DAN-DU-AN>/pinedesk && bash backup/backup.sh"`
     (dùng dạng POSIX của Git Bash, ví dụ `/g/duong-dan-du-an` nếu ổ G:)
5. Nhấn **Finish**

### 6.3. Phục hồi dữ liệu

**Bước 1** — Khởi động hệ thống:

```bash
cd <DUONG-DAN-DU-AN>/pinedesk
bash start.sh
```

**Bước 2** — Phục hồi cơ sở dữ liệu:

```bash
# Đọc mật khẩu root từ .env, không ghi thẳng mật khẩu vào tài liệu.
set -a; . ./.env; set +a
docker exec -i -e MYSQL_PWD="$DB_ROOT_PASSWORD" pinedesk-db \
    mariadb -u root glpi \
    < backup/glpi_backup_YYYYMMDD_HHMMSS_db.sql
```

**Bước 3** — Phục hồi file hệ thống:

Bản sao lưu lưu đường dẫn tương đối từ gốc `/` (ví dụ `var/glpi/config/
glpicrypt.key`), nên phải giải nén **tại `/`** — KHÔNG dùng `-C /var/www/glpi`.
Giải nén đúng sẽ khôi phục cả `glpicrypt.key` (khoá mã hoá CSDL) và
`config_db.php`; nếu thiếu khoá này, dữ liệu mã hoá trong CSDL không đọc được.

```bash
docker run --rm \
    --volumes-from pinedesk-glpi \
    -v "$(pwd -W)/backup:/backup" \
    alpine:latest \
    tar xzf /backup/glpi_backup_YYYYMMDD_HHMMSS_files.tar.gz -C /
```

> **Lưu ý Git Bash trên Windows:** phải dùng `$(pwd -W)` (đường dẫn Windows)
> thay vì `$(pwd)`, nếu không Docker Desktop không tìm thấy thư mục.

**Bước 4** — Khởi động lại:

```bash
docker-compose restart glpi
```

---

## 7. LỆNH VẬN HÀNH THƯỜNG DÙNG

```bash
# Di chuyen vao thu muc du an
cd <DUONG-DAN-DU-AN>/pinedesk

# Khoi dong he thong
bash start.sh

# Hoac dung lenh truc tiep
docker-compose up -d

# Xem trang thai cac container
docker ps --filter "name=pinedesk-"

# Xem log ung dung GLPI
docker-compose logs -f glpi

# Xem log gateway (kiem tra truy cap, tan cong)
docker-compose logs -f nginx

# Dung tam thoi (giu du lieu)
docker-compose stop

# Khoi dong lai sau khi dung
docker-compose start

# Khoi dong lai mot dich vu cu the
docker-compose restart glpi

# Xoa hoan toan (GIU LAI du lieu trong volume)
docker-compose down

# Xoa hoan toan KE CA du lieu (NGUY HIEM - can sao luu truoc)
docker-compose down -v

# Sao luu du lieu
bash backup/backup.sh
```

---

## 8. XỬ LÝ SỰ CỐ THƯỜNG GẶP

### 8.1. Lỗi `docker-credential-desktop` khi tải image

**Triệu chứng:**
```
error getting credentials - err: exec: "docker-credential-desktop":
executable file not found in %PATH%
```

**Nguyên nhân:** File `~/.docker/config.json` có dòng `"credsStore": "desktop"`
nhưng helper tương ứng không tồn tại trong PATH.

**Cách sửa:**

1. Mở file `C:\Users\<tên>\.docker\config.json` bằng Notepad
2. Tìm và **xóa** dòng sau:
```json
"credsStore": "desktop",
```
3. Lưu file và chạy lại `docker-compose up -d`

### 8.2. Không truy cập được https://localhost:8443

**Kiểm tra theo thứ tự:**

```bash
# 1. Docker co dang chay khong?
docker info

# 2. Container co dang chay khong?
docker ps --filter "name=pinedesk-"

# 3. Cong 8443 co bi chiem khong?
netstat -ano | findstr :8443

# 4. Xem log gateway de tim loi
docker logs pinedesk-gateway --tail 30
```

**Nếu cổng bị chiếm:** Đổi `HTTPS_PORT` trong file `.env` thành cổng khác
(ví dụ `9443`), rồi chạy lại `docker-compose up -d`.

### 8.3. GLPI báo lỗi kết nối cơ sở dữ liệu

```bash
# Kiem tra database co san sang khong
docker exec pinedesk-db healthcheck.sh --connect --innodb_initialized

# Xem log database
docker logs pinedesk-db --tail 30
```

Nếu database chưa sẵn sàng ở lần chạy đầu, đợi 30–60 giây rồi thử lại.

> ⚠️ **Bẫy hiếm nhưng đã từng gặp — GLPI mất kết nối DB dù container DB vẫn khoẻ:**
> Docker **không đổi được** cờ `internal` của một mạng **đang tồn tại**. Khi giá trị
> `internal` trong `docker-compose.yml` thay đổi, Compose **tạo lại mạng**, nhưng
> container đang chạy chỉ được **gắn lại** mà **không đăng ký lại "alias" dịch vụ**
> (vd `mariadb`). Kết quả: GLPI không phân giải được tên `mariadb` → *"Unable to
> connect to database"* → tự cài đặt lại → **restart loop** — dù
> `docker network inspect` vẫn thấy container nằm trong mạng.
>
> **Cách xử lý:** chạy lại **từ đầu** (không chỉ `up -d`):
> ```bash
> docker compose down && docker compose up -d
> ```
> Volume là **named volume** nên **KHÔNG mất dữ liệu**. Kiểm chứng alias đã đăng ký:
> ```bash
> docker exec pinedesk-glpi getent hosts mariadb   # phải in ra 1 địa chỉ IP
> ```
>
> **Đã có sẵn "phanh an toàn":** `start.sh` và `scripts/cai-dat-tat-ca.sh` dùng
> chung `scripts/lib/compose-guard.sh` — trước khi `up -d`, script tự so cờ
> `internal` trong `docker-compose.yml` với mạng thực tế; nếu lệch, script tự
> chạy `down` trước để tạo lại mạng đúng (kèm cảnh báo). Nếu khởi động bằng
> `docker compose up -d` **thủ công** thì phanh này **không chạy** — gặp lỗi
> mất kết nối DB, hãy làm theo cách xử lý ở trên.

### 8.4. Không đăng nhập được (HTTP 403)

**Nguyên nhân có thể:**

| Nguyên nhân | Cách xử lý |
|---|---|
| Bị rate limit do thử quá nhiều lần | Đợi 1 phút rồi thử lại |
| Cookie bị chặn | Xóa cache trình duyệt (Ctrl + Shift + Del) |
| Sai thông tin đăng nhập | Tài khoản mặc định là `glpi` / `glpi` |

### 8.5. Trang hiển thị lỗi 502 Bad Gateway

Nghĩa là gateway không kết nối được tới GLPI. Kiểm tra:

```bash
docker ps --filter "name=pinedesk-glpi"
docker logs pinedesk-glpi --tail 50
docker-compose restart glpi
```

### 8.6. Cảnh báo chứng chỉ SSL trên trình duyệt

Chứng chỉ tự ký **luôn** khiến trình duyệt cảnh báo — đây là hiện tượng bình
thường. Cách xử lý: nhấn **Nâng cao** → **Tiếp tục truy cập localhost**.

> ⚠️ **Nếu KHÔNG thấy nút "Tiếp tục truy cập"** (chỉ có "Quay lại"): chứng chỉ
> đang **thiếu SAN** — trình duyệt không cho thêm ngoại lệ. Kiểm tra và sửa:

```bash
openssl x509 -in nginx/ssl/glpi.crt -noout -text | grep -A1 "Subject Alternative Name"
```

Nếu **không có kết quả**, chứng chỉ cũ cần sinh lại:

```bash
rm nginx/ssl/glpi.crt nginx/ssl/glpi.key
bash start.sh
```

Để hết cảnh báo hoàn toàn, cần chứng chỉ từ tổ chức cấp phát hợp lệ
(Let's Encrypt hoặc chứng chỉ nội bộ của trường).

### 8.7. Mọi trang trả về HTTP 400 (Bad Request)

**Nguyên nhân:** `session.cookie_secure = On` (trong `config/php-custom.ini`)
khiến GLPI **chặn mọi request không ở ngữ cảnh HTTPS** — đây là hành vi bảo mật
đúng, không phải lỗi. GLPI biết request là HTTPS nhờ Apache nhận header
`X-Forwarded-Proto` mà Nginx gửi sang (xem `config/apache-forwarded-proto.conf`).

Lỗi 400 xuất hiện khi **mắt xích đó đứt**:

| Tình huống | Cách xử lý |
|---|---|
| Truy cập thẳng Apache (cổng 80 trong container), **không qua Nginx** | Dùng đúng địa chỉ `https://localhost:8443` — **luôn đi qua Nginx** |
| Xoá nhầm `config/apache-forwarded-proto.conf` | Khôi phục file (nó được mount vào `/etc/apache2/conf-enabled/`) rồi `docker compose restart glpi` |
| Healthcheck báo `unhealthy` dù web vẫn chạy | Bình thường nếu healthcheck thiếu header — healthcheck của đồ án **đã** gửi kèm `X-Forwarded-Proto: https` |

Kiểm tra nhanh bằng `curl` **có** header (giả lập Nginx):

```bash
docker exec pinedesk-glpi \
  curl -fsS -H 'X-Forwarded-Proto: https' -o /dev/null -w '%{http_code}\n' \
  http://127.0.0.1:80/
# -> 200 hoặc 302 (tốt)  ·  400 (thiếu header -> xem bảng trên)
```

---

## 9. LƯU Ý BẢO MẬT

### 9.1. Đã triển khai trong hệ thống

| Biện pháp | Chi tiết |
|---|---|
| Mã hóa đường truyền | HTTPS/TLS 1.2–1.3 bắt buộc |
| Chuyển hướng HTTP → HTTPS | Tự động, không cho phép truy cập không mã hóa |
| Chống brute-force | Rate limit 10 lần/phút cho trang đăng nhập |
| Chống XSS | Cookie phiên có thuộc tính `HttpOnly` |
| Chống CSRF | Cookie phiên có thuộc tính `SameSite=Strict` |
| Chống lộ cookie qua HTTP | `session.cookie_secure = On` — cookie **chỉ** gửi qua HTTPS (cần `config/apache-forwarded-proto.conf`) |
| Chặn file nhạy cảm | Nginx chặn `.env`, `.sql`, `.log`, `.git` |
| Ẩn thông tin hệ thống | Tắt `expose_php`, ẩn phiên bản Nginx |
| Cô lập mạng | Database và Redis **cô lập hoàn toàn** (`internal: true`), không có gateway ra Internet |
| Bảo vệ header | X-Frame-Options, X-Content-Type-Options, CSP |

### 9.2. Cần làm khi triển khai thực tế

> Những việc **bắt buộc** phải làm trước khi đưa vào sử dụng thật:

1. **Đổi tất cả mật khẩu** trong file `.env`
2. **Đổi mật khẩu tài khoản `glpi`** ngay sau lần đăng nhập đầu
3. **Kiểm tra `session.cookie_secure = On`** trong `config/php-custom.ini`
   (đồ án **đã bật sẵn**). ⚠️ Nó **phụ thuộc** `config/apache-forwarded-proto.conf`
   — nếu xoá file đó, GLPI sẽ chặn **mọi** trang bằng HTTP 400. Xem mục 9.1.
4. **Cấu hình sao lưu tự động** hàng ngày
5. **Phân quyền theo vai trò**, không cấp Admin tràn lan
6. **Xem xét nhật ký** định kỳ để phát hiện truy cập bất thường
7. **Cập nhật GLPI** khi có bản vá bảo mật mới
8. **Không mở cổng database** ra ngoài mạng nội bộ

### 9.3. Những việc KHÔNG nên làm

- Không đưa file `.env` lên Git hoặc chia sẻ công khai
- Không dùng chứng chỉ tự ký cho môi trường Internet
- Không chạy `docker-compose down -v` khi chưa sao lưu
- Không sửa trực tiếp file trong container (mất khi khởi động lại)
- Không dùng chung một mật khẩu cho nhiều dịch vụ

---

## 10. CẤU TRÚC THƯ MỤC DỰ ÁN

```
pinedesk/
├── docker-compose.yml          # Định nghĩa các dịch vụ Docker
├── .env                        # Biến môi trường (CHỨA MẬT KHẨU - không commit)
├── .env.example                # Mẫu cấu hình để tham khảo
├── .gitignore                  # Chặn commit file nhạy cảm
├── start.sh                    # Script khởi động tự động
│
├── config/
│   ├── php-custom.ini          # Cấu hình PHP (QR, bảo mật phiên, upload)
│   └── apache-forwarded-proto.conf  # Chuyển tiếp HTTPS nginx -> Apache
│                               #   (để session.cookie_secure=On hoạt động)
│
├── nginx/
│   ├── nginx.conf              # Cấu hình Nginx chính
│   ├── conf.d/
│   │   └── default.conf        # Cấu hình gateway, HTTPS, rate limit
│   └── ssl/
│       ├── openssl-san.cnf     # ★ Cấu hình sinh chứng chỉ (có SAN)
│       ├── glpi.crt            # Chứng chỉ SSL (sinh tự động, không commit)
│       └── glpi.key            # Khóa riêng tư SSL (không commit)
│
├── plugins/
│   └── dlubrand/               # Plugin giao diện Đà Lạt
│       └── public/css/dlu-theme.css  # ★ NGUỒN MÀU DUY NHẤT cho giao diện GLPI
│
├── themes/
│   ├── da_lat.scss             # Đăng ký bảng màu "Đà Lạt" (xanh rêu)
│   ├── da_lat_suong.scss       # Đăng ký biến thể "sương mù" (xanh hồ)
│   └── da_lat_nang.scss        # Đăng ký biến thể "nắng" (cam đất)
│                               #   ★ 3 file này KHÔNG chứa mã màu — chỉ đăng ký TÊN
│
├── backup/
│   └── backup.sh               # Script sao lưu tự động
│
└── tai-lieu/
    └── HUONG-DAN-TRIEN-KHAI.md # Tài liệu này
```

---

## 11. THÔNG TIN KỸ THUẬT THAM KHẢO

### 11.1. Phiên bản phần mềm

| Thành phần | Phiên bản | Giấy phép |
|---|---|---|
| GLPI | 11.0.0 | GPL v3 |
| MariaDB | 10.11 LTS | GPL v2 |
| Redis | 7 Alpine | BSD |
| Nginx | 1.27 Alpine | BSD-2 |
| PHP | 8.2 | PHP License |

### 11.2. Cổng và giao thức

| Dịch vụ | Cổng | Giao thức | Phạm vi |
|---|---|---|---|
| Gateway HTTP | 8080 | HTTP | Chuyển hướng HTTPS |
| Gateway HTTPS | 8443 | HTTPS | Bên ngoài |
| GLPI nội bộ | 80 | HTTP | Chỉ trong Docker |
| MariaDB | 3306 | MySQL | Chỉ trong Docker |
| Redis | 6379 | Redis | Chỉ trong Docker |

### 11.3. Kiểm tra tự động trước khi triển khai

Repo có pipeline CI (`.github/workflows/ci.yml`) tự chạy khi push/PR. Có thể chạy
nhanh các kiểm tra tương tự **ngay trên máy** mà không cần GitHub:

```bash
# 1. Cu phap shell
for f in start.sh backup/backup.sh scripts/*.sh; do bash -n "$f" || echo "LOI: $f"; done

# 2. Cu phap Python + JavaScript
python -m py_compile scripts/*.py
for f in scripts/*.js scripts/lib/*.js; do node --check "$f"; done

# 3. Cau hinh docker compose (moi service phai co healthcheck)
docker compose config --quiet

# 4. Cau hinh Nginx (can them --add-host vi upstream 'glpi' chi co trong Docker)
docker run --rm --add-host glpi:127.0.0.1 \
  -v "$PWD/nginx/nginx.conf:/etc/nginx/nginx.conf:ro" \
  -v "$PWD/nginx/conf.d:/etc/nginx/conf.d:ro" \
  -v "$PWD/nginx/ssl:/etc/nginx/ssl:ro" \
  -v "$PWD/landing:/usr/share/nginx/html/landing:ro" \
  nginx:1.27-alpine nginx -t

# 5. Lint shell (nang cao, can cai shellcheck)
shellcheck --severity=warning --shell=bash start.sh backup/backup.sh scripts/*.sh
```

### 11.4. Đường dẫn quan trọng

| Mục đích | Đường dẫn |
|---|---|
| Truy cập hệ thống | `https://localhost:8443` |
| Mã nguồn GLPI | `/var/www/glpi` |
| **Thư mục DỮ LIỆU GLPI** (config, files, marketplace, logs) | **`/var/glpi`** |
| Khoá mã hoá CSDL | `/var/glpi/config/glpicrypt.key` |
| Log PHP | `/var/glpi/files/_log/php-error.log` |
| Thư mục palette | `/var/glpi/files/_themes` |

---

## 12. TÀI LIỆU THAM KHẢO

- Tài liệu chính thức GLPI: https://glpi-project.org/documentation/
- Yêu cầu hệ thống GLPI: https://glpi-install.readthedocs.io/en/latest/prerequisites.html
- Triển khai GLPI trên Docker: https://help.glpi-project.org/tutorials/procedures/running_glpi_on_docker
- Kho plugin GLPI: http://plugins.glpi-project.org/
- Diễn đàn cộng đồng GLPI: https://forum.glpi-project.org/
