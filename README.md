# PINEDESK — HỆ THỐNG HỖ TRỢ KỸ THUẬT

[![CI](https://github.com/Lacia1803/pinedesk/actions/workflows/ci.yml/badge.svg)](https://github.com/Lacia1803/pinedesk/actions/workflows/ci.yml)

> **Đồ án thực tập** — Trường Đại học Đà Lạt (DLU)
> Hệ thống quản lý phòng máy, thiết bị CNTT và tiếp nhận sự cố dạng ticket,
> xây dựng trên nền tảng mã nguồn mở **GLPI 11**.
>
> Tên **PineDesk** ghép từ *pine* (rừng thông Đà Lạt) và *desk* (bàn hỗ trợ).

## Giao diện

### Trang đăng nhập

![Trang đăng nhập](tai-lieu/anh-giao-dien/01-trang-dang-nhap.png)

### Bảng điều khiển

![Bảng điều khiển](tai-lieu/anh-giao-dien/02-bang-dieu-khien.png)

### Quản lý tài sản

| Danh sách máy tính | Chi tiết thiết bị |
|---|---|
| ![Danh sách máy tính](tai-lieu/anh-giao-dien/03-danh-sach-may-tinh.png) | ![Chi tiết thiết bị](tai-lieu/anh-giao-dien/07-chi-tiet-thiet-bi.png) |

| Màn hình | Thiết bị mạng |
|---|---|
| ![Danh sách màn hình](tai-lieu/anh-giao-dien/03b-danh-sach-man-hinh.png) | ![Thiết bị mạng](tai-lieu/anh-giao-dien/03c-thiet-bi-mang.png) |

| Máy in | Phần mềm |
|---|---|
| ![Danh sách máy in](tai-lieu/anh-giao-dien/03d-danh-sach-may-in.png) | ![Danh sách phần mềm](tai-lieu/anh-giao-dien/03e-danh-sach-phan-mem.png) |

| Thêm thiết bị mới | Hành động hàng loạt |
|---|---|
| ![Tạo thiết bị](tai-lieu/anh-giao-dien/06-tao-thiet-bi.png) | ![Menu hành động](tai-lieu/anh-giao-dien/10-menu-cac-hanh-dong.png) |

### Tiếp nhận sự cố

| Danh sách phiếu yêu cầu | Tạo phiếu mới |
|---|---|
| ![Danh sách phiếu yêu cầu](tai-lieu/anh-giao-dien/04-danh-sach-phieu-yeu-cau.png) | ![Tạo phiếu mới](tai-lieu/anh-giao-dien/05-tao-phieu-moi.png) |

### Mã QR cho thiết bị

Mã QR in trên hồ sơ thiết bị, quét ra là mở đúng máy đó:

| Mã QR trên hồ sơ thiết bị | Nhãn QR in hàng loạt |
|---|---|
| ![Mã QR thiết bị](tai-lieu/anh-giao-dien/11-ma-qr-thiet-bi.png) | ![Kết quả sinh QR](tai-lieu/anh-giao-dien/12-ket-qua-sinh-qr.png) |

### Nhân sự và tổ chức

| Cơ cấu tổ chức | Người dùng |
|---|---|
| ![Nhóm cơ cấu tổ chức](tai-lieu/anh-giao-dien/06-nhom-co-cau-to-chuc.png) | ![Danh sách người dùng](tai-lieu/anh-giao-dien/08-danh-sach-nguoi-dung.png) |

### Thống kê

![Thống kê toàn cầu](tai-lieu/anh-giao-dien/13-thong-ke-toan-cau.png)

### Trang giới thiệu dự án

![Landing page](tai-lieu/anh-giao-dien/16-landing-dau-trang.png)

[![Landing page toàn trang](tai-lieu/anh-giao-dien/17-landing-toan-trang.png)](tai-lieu/anh-giao-dien/17-landing-toan-trang.png)

Ảnh minh chứng đầy đủ nằm trong [`tai-lieu/anh-giao-dien/`](tai-lieu/anh-giao-dien/).

## Tính năng chính

| Nhóm chức năng | Chi tiết |
|---|---|
| **Quản lý tài sản** | Phòng máy, máy tính, thiết bị mạng, phần mềm; hồ sơ đầy đủ kèm **mã QR** |
| **Tiếp nhận sự cố** | Ticket theo chuẩn ITIL: máy hỏng, lỗi mạng, lỗi phần mềm, thiết bị ngoại vi |
| **Phân công xử lý** | Giao việc cho kỹ thuật viên, theo dõi tiến độ, **5 mức SLA cấu hình sẵn** (xem ghi chú bên dưới) |
| **Chống lạm dụng** | 6 tầng: rate limit · bắt buộc đăng nhập · hạn mức phiếu · chống trùng · kiểm duyệt · nhật ký |
| **Bảo trì định kỳ** | Lịch sử sửa chữa theo từng thiết bị; lịch bảo trì tạo qua giao diện GLPI |
| **Dashboard** | Thống kê số thiết bị, sự cố, lịch bảo trì theo thời gian thực |
| **Giao diện Đà Lạt** | Bảng màu xanh rêu + cam đất trích từ logo DLU, áp dụng toàn hệ thống |
| **Việt hoá** | Mặc định tiếng Việt, 541 thuật ngữ dịch bổ sung + 212 mục dạng số nhiều (31,8% catalog; menu, biểu mẫu & nhãn dashboard 100%) |
| **Trang giới thiệu** | Landing page thiết kế riêng tại `/landing/` — lấy cảm hứng Đà Lạt & DLU, chạy được khi không có mạng |
| **Bảo mật** | HTTPS (chứng chỉ tự ký **có SAN**), chống brute-force, phân quyền theo vai trò, sao lưu tự động |

> ⚠️ **Về SLA — nói rõ để tránh hiểu nhầm:** hệ thống đã cấu hình **5 mức SLA thật
> trong CSDL** (`glpi_slas`), nhưng các con số (8h/4h/2h/1h/30p) là **đề xuất kỹ
> thuật của đồ án**, **chưa phải cam kết đã được Trường Đại học Đà Lạt ban hành**.
> Chi tiết: [`tai-lieu/CHONG-LAM-DUNG.md`](tai-lieu/CHONG-LAM-DUNG.md) mục 6.

## Bắt đầu nhanh

```bash
# Di chuyển vào thư mục gốc của dự án (thay bằng đường dẫn thực trên máy bạn)
cd duong-dan-toi/pinedesk
bash scripts/cai-dat-tat-ca.sh
```

Script tự động làm 6 việc và báo kết quả từng bước:

1. Khởi động 4 container (GLPI · MariaDB · Redis · Nginx)
2. Nạp **danh mục nghiệp vụ**: 12 toà nhà · 54 phòng máy · 16 khoa · 10 phòng ·
   7 trung tâm · 10 trạng thái · 79 loại sự cố …
3. Bật **plugin QR** + **plugin giao diện Đà Lạt**
4. Nạp **bản dịch tiếng Việt** (gộp bản chính thức + bổ sung của đồ án)
5. Nạp **SLA thật + cơ chế chống lạm dụng** (hạn mức phiếu, chống trùng, nhật ký)
6. Kiểm tra sức khỏe hệ thống (5 hạng mục)

Truy cập: **https://localhost:8443** · Tài khoản: `glpi`
⚠️ **Đổi mật khẩu `glpi` ngay sau khi đăng nhập lần đầu.**
Mật khẩu admin **không lưu trong mã nguồn**; các script tự động hoá đọc mật khẩu
từ biến môi trường `GLPI_PASS` (không truyền qua tham số dòng lệnh).

## Kiến trúc

```
Người dùng --HTTPS:8443--> [ Nginx Gateway ]
                                    |
                          HTTP:80   |
                                    v
                            [ GLPI 11 ] <--> [ Redis Cache ]
                                    |
                                    v
                              [ MariaDB 10.11 ]
```

Mỗi thành phần chạy trong container riêng, cô lập và dễ bảo trì.
Database và Redis chỉ giao tiếp trong mạng nội bộ Docker, không lộ ra ngoài.

## Cấu trúc thư mục

```
pinedesk/
├── .github/workflows/ci.yml     # ★ Pipeline kiểm tra tự động (6 nhóm)
├── docker-compose.yml           # Định nghĩa 4 dịch vụ Docker
├── .env                         # Biến môi trường (chứa mật khẩu)
├── start.sh                     # Khởi động hệ thống
├── config/                      # Cấu hình PHP (QR, bảo mật)
├── nginx/                       # Gateway: HTTPS, rate limit, bảo mật
│   └── ssl/openssl-san.cnf      #   Cấu hình sinh chứng chỉ SSL (có SAN)
├── themes/                      # Đăng ký bảng màu Đà Lạt (chỉ có tên file, KHÔNG chứa màu)
├── plugins/dlubrand/            # Plugin giao diện Đà Lạt (CSS + logo) — NGUỒN MÀU DUY NHẤT
├── landing/                     # ★ Trang giới thiệu dự án (nginx phục vụ tại /landing/)
│   ├── index.html               #   Nội dung trang
│   ├── assets/css/style.css     #   Thiết kế riêng (Đà Lạt + DLU)
│   ├── fonts/                   #   16 tệp .woff2 tự lưu — chạy được khi không có mạng
│   └── dashboard-preview.png    #   Ảnh bảng điều khiển (sinh từ dữ liệu thật)
├── scripts/                     # ★ Tất cả script tự động hoá
│   ├── cai-dat-tat-ca.sh        #   Cài toàn bộ, 1 lệnh
│   ├── nap-du-lieu-nen.sh       #   Nạp danh mục nghiệp vụ
│   ├── nap-du-lieu-mau.sh       #   ★ Nạp dữ liệu demo (thiết bị, phiếu, tài khoản)
│   ├── seed-du-lieu-mau.sql     #     Dữ liệu mẫu
│   ├── viet-hoa-du-lieu.sh      #   Việt hoá DỮ LIỆU (tên đơn vị, hồ sơ quyền)
│   ├── nap-sla-va-chong-lam-dung.sh # ★ Nạp SLA thật + hạn mức chống spam
│   ├── seed-sla-va-chong-lam-dung.sql #  SLA + bảng nhật ký/hạn mức
│   ├── kiem-tra-lam-dung.sh     # ★ Phát hiện spam / trùng phiếu theo tài khoản
│   ├── tai-font.py              #   Tải font về máy (có subset tiếng Việt)
│   ├── tao-mo-bo-sung.py        #   Tạo lớp phủ bản dịch
│   ├── gop-ban-dich-tieng-viet.py  # Gộp bản dịch (không mất chuỗi + và số nhiều)
│   ├── do-do-phu-tieng-viet.py  #   Đo tỉ lệ Việt hoá
│   ├── bo-sung-tieng-viet.py    #   Từ điển thuật ngữ (đơn + số nhiều)
│   ├── chup-lai-anh-minh-chung.js  # Chụp 19 ảnh minh chứng (một màn hình một ảnh)
│   ├── chup-anh-qr-admin.js     #   Chụp luồng in QR (cần tài khoản quản trị)
│   ├── chup-anh-dashboard.js    #   Chụp ảnh bảng điều khiển cho landing page
│   ├── chup-anh-tung-khu.js     #   Chụp riêng từng khu để soi thiết kế
│   ├── kiem-tra-landing.js      #   Kiểm tra landing (anchor, ảnh, font, console)
│   ├── kiem-tra-font.py         #   Đo phủ ký tự thật trong tệp font
│   └── sinh-ma-qr.py            #   Sinh mã QR hàng loạt
├── backup/                      # Script sao lưu dữ liệu
└── tai-lieu/                    # ★ Tài liệu hướng dẫn + ảnh minh chứng
    ├── HUONG-DAN-TRIEN-KHAI.md            # Triển khai & vận hành
    ├── HUONG-DAN-PLUGIN-QRCODE.md         # Plugin sinh mã QR
    ├── HUONG-DAN-GIAO-DIEN-VA-VIET-HOA.md # Giao diện & Việt hoá
    ├── THONG-TIN-DAI-HOC-DA-LAT.md        # Cơ cấu tổ chức DLU
    ├── SO-SANH-VOI-GLPI-GOC.md            # ★ Cải thiện gì so với bản gốc
    ├── BAI-TOAN-NGHIEP-VU.md              # ★ Đồ án giải quyết vấn đề gì của Trường
    ├── CHONG-LAM-DUNG.md                  # ★ 6 tầng chống spam (trả lời phản biện)
    ├── CAU-HOI-PHAN-BIEN.md               # ★ Bộ câu hỏi hội đồng + cách trả lời
    ├── KICH-BAN-DEMO.md                   # ★ Kịch bản trình diễn 7 phút + dự phòng
    ├── slide-bao-ve.html                  # ★ 7 slide bảo vệ, chạy ngoại tuyến
    └── anh-giao-dien/                     # Ảnh chụp giao diện thực tế
```

## Dữ liệu demo

Hệ thống cài xong là **CSDL rỗng**, không thể demo. Chạy 1 lệnh để có dữ liệu:

```bash
bash scripts/nap-du-lieu-mau.sh
```

Kết quả: **17 máy tính · 5 màn hình · 3 máy in · 9 thiết bị mạng · 10 phần mềm ·
13 phiếu sự cố (đủ 4 trạng thái) · 6 tài khoản 3 vai trò**.

| Tài khoản | Mật khẩu | Vai trò |
|---|---|---|
| `tech` | `tech` | Kỹ thuật viên (tài khoản có sẵn của GLPI) |
| `ktv.an`, `ktv.binh` | `Dlu@2026` | Kỹ thuật viên |
| `gv.cuong`, `gv.dung` | `Dlu@2026` | Giảng viên |
| `sv.hoa`, `sv.khanh` | `Dlu@2026` | Sinh viên |

> Tài khoản `tech` do chính trình cài đặt GLPI tạo ra, không thuộc script
> `nap-du-lieu-mau.sh`, nên mật khẩu là `tech` chứ không phải `Dlu@2026`.

> Script **idempotent** — chạy lại nhiều lần không nhân đôi dữ liệu.
> Mã tài sản theo quy ước thật: `TDL-PC-A101-001` = ĐH Đà Lạt – Máy tính – Toà A – Phòng 101 – Máy 01.

## Trang giới thiệu dự án (Landing page)

Truy cập: **https://localhost:8443/landing/**

Trang giới thiệu dành cho hội đồng và người dùng mới. Toàn bộ hình ảnh trên
trang lấy từ cảnh quan Đà Lạt và từ chính Trường, không dùng giao diện mẫu.

**Chất liệu tạo hình:**

| Nguồn | Thể hiện trên trang |
|---|---|
| Đồi thông Đà Lạt | Năm lớp đồi xếp chồng, nhạt dần theo tầm nhìn xa, có rừng thông ở lớp gần nhất |
| Khí hậu cao nguyên | Hai dải sương mờ trôi chậm giữa các lớp đồi; nền trang là sắc sương sớm |
| Bảng màu logo DLU | Xanh rêu `#607824`, dải lá `#90B43C`, cam đất `#F08418`, đỏ sao `#CC2430` |
| Kiến trúc Pháp cổ ở Đà Lạt | Chữ tiêu đề **Fraunces** (serif), thân bài **Be Vietnam Pro** |

Phần kiến trúc hệ thống cũng vẽ theo cùng một lối: năm lớp phủ xếp chồng như
sườn đồi, đưa chuột lên một lớp thì dải tương ứng sáng lên.

**Kỹ thuật:**

- **Chạy hoàn toàn khi KHÔNG có Internet** — 16 tệp font `.woff2` tự lưu trong
  `landing/fonts/` (có subset tiếng Việt), **không dùng CDN**. Đã bỏ hẳn
  Tailwind CSS và Font Awesome (~1,5 MB); cả thư mục `landing/` nặng khoảng
  600 KB, phần lớn là ảnh dashboard.
- **Bộ biểu tượng SVG nội bộ** — không phụ thuộc thư viện icon bên ngoài.
- **Liên kết tương đối** — mở từ máy khác trong mạng LAN vẫn hoạt động đúng.
  Nút "Mở hệ thống" trỏ về gốc `/` chứ không hardcode `localhost`.
- **Nội dung hiện đầy đủ khi JavaScript bị tắt.** JavaScript chỉ dùng cho việc
  sao chép tài khoản và làm sáng dải mặt cắt; không có hiệu ứng cuộn.
- Ảnh dashboard trong trang sinh tự động bằng `node scripts/chup-anh-dashboard.js`
  (dữ liệu thật, đã Việt hoá, đã ẩn banner cảnh báo kỹ thuật).

**Tài liệu trong trang:** sáu thẻ tài liệu trỏ tới `tai-lieu/*.md` và `README.md`
ở gốc mã nguồn. Gateway mount thêm hai đường dẫn này và phục vụ dưới dạng
`text/plain` để mở xem ngay trên trình duyệt (xem `nginx/conf.d/default.conf`).

**Kiểm thử tự động:** `node scripts/kiem-tra-landing.js` (anchor, ảnh, font,
tài nguyên lỗi, lỗi console) và `python scripts/kiem-tra-font.py` (đối chiếu
bảng ký tự thật trong tệp font với chữ có trên trang).

## Lệnh thường dùng

```bash
# Cài đặt & dữ liệu
bash scripts/cai-dat-tat-ca.sh       # Cài toàn bộ hệ thống (1 lệnh)
bash scripts/nap-du-lieu-nen.sh      # Chỉ nạp lại danh mục nghiệp vụ
bash scripts/nap-du-lieu-mau.sh      # Nạp dữ liệu demo (thiết bị, phiếu, tài khoản)
bash scripts/cai-giao-dien.sh        # Chỉ cài lại giao diện Đà Lạt

# Tiếng Việt
python scripts/tao-mo-bo-sung.py
python scripts/gop-ban-dich-tieng-viet.py
python scripts/do-do-phu-tieng-viet.py
bash   scripts/viet-hoa-du-lieu.sh   # Việt hoá dữ liệu (tên đơn vị, hồ sơ quyền)

# Mã QR
python scripts/sinh-ma-qr.py         # Sinh QR hàng loạt (dự phòng)

# Landing page
python scripts/tai-font.py           # Tải font về máy (cần mạng, chỉ chạy 1 lần)
node   scripts/kiem-tra-landing.js   # Kiểm tra landing (anchor, ảnh, font, console)
node   scripts/chup-anh-tung-khu.js  # Chụp riêng từng khu để soi thiết kế
python scripts/kiem-tra-font.py      # Đo phủ ký tự thật trong tệp font

# Chụp ảnh giao diện (cần đăng nhập) — mật khẩu lấy từ biến môi trường:
#   GLPI_USER=ktv.an GLPI_PASS='<mat-khau>' node scripts/chup-lai-anh-minh-chung.js
node   scripts/chup-lai-anh-minh-chung.js # Chụp 19 ảnh minh chứng cho README
node   scripts/chup-anh-dashboard.js # Chụp lại ảnh dashboard cho landing page
#   Hai ảnh luồng in QR cần quyền quản trị: node scripts/chup-anh-qr-admin.js

# Vận hành
bash start.sh                        # Khởi động
docker-compose logs -f glpi          # Xem log
docker-compose stop                  # Dừng tạm thời
docker-compose down                  # Tắt hoàn toàn
bash backup/backup.sh                # Sao lưu dữ liệu
```

## Tài liệu

| Tài liệu | Nội dung |
|---|---|
| [`HUONG-DAN-TRIEN-KHAI.md`](tai-lieu/HUONG-DAN-TRIEN-KHAI.md) | Cài đặt, cấu hình nghiệp vụ, sao lưu, xử lý sự cố |
| [`HUONG-DAN-PLUGIN-QRCODE.md`](tai-lieu/HUONG-DAN-PLUGIN-QRCODE.md) | Cài & dùng plugin sinh mã QR |
| [`HUONG-DAN-GIAO-DIEN-VA-VIET-HOA.md`](tai-lieu/HUONG-DAN-GIAO-DIEN-VA-VIET-HOA.md) | Tuỳ biến giao diện Đà Lạt & Việt hoá |
| [`SO-SANH-VOI-GLPI-GOC.md`](tai-lieu/SO-SANH-VOI-GLPI-GOC.md) | **Đã cải thiện gì so với GLPI gốc** — bảng đối chiếu chi tiết |
| [`BAI-TOAN-NGHIEP-VU.md`](tai-lieu/BAI-TOAN-NGHIEP-VU.md) | **Bài toán nghiệp vụ** — đồ án giải quyết vấn đề gì của Trường |
| [`CHONG-LAM-DUNG.md`](tai-lieu/CHONG-LAM-DUNG.md) | **Sáu tầng chống lạm dụng** nộp phiếu — trả lời câu hỏi phản biện |
| [`CAU-HOI-PHAN-BIEN.md`](tai-lieu/CAU-HOI-PHAN-BIEN.md) | Bộ câu hỏi hội đồng thường hỏi + cách trả lời kèm bằng chứng |
| [`KICH-BAN-DEMO.md`](tai-lieu/KICH-BAN-DEMO.md) | Kịch bản trình diễn 7 phút, kèm phương án dự phòng |
| [`slide-bao-ve.html`](tai-lieu/slide-bao-ve.html) | 7 slide bảo vệ, tự chứa, chạy được khi không có mạng |

## Kiểm thử tự động (CI)

Mỗi pull request và mỗi lần push lên `main`/`master` đều chạy pipeline
[`.github/workflows/ci.yml`](.github/workflows/ci.yml) — **6 nhóm kiểm tra**:

| # | Nhóm | Nội dung |
|---|---|---|
| 1 | **Cú pháp** | `bash -n` (shell) · `py_compile` (Python) · `node --check` (JS) |
| 2 | **ShellCheck** | Lint shell ở mức `warning` — bắt lỗi thật, không bắt style |
| 3 | **Cấu hình** | `docker compose config` · mọi service phải có `healthcheck` · `nginx -t` |
| 4 | **Chứng chỉ SSL** | Sinh được từ `openssl-san.cnf` và **bắt buộc có SAN** |
| 5 | **Bảo mật** | Không commit `.env`/chứng chỉ; không hardcode mật khẩu hay đường dẫn máy cá nhân |
| 6 | **Smoke test** | Khởi động thật 4 container → chờ `healthy` → kiểm tra HTTP/HTTPS |

> Pipeline **chặn merge** nếu bất kỳ cửa nào thất bại. Chạy kiểm tra nhanh trên
> máy trước khi push:
>
> ```bash
> bash -n start.sh                     # cú pháp shell
> python -m py_compile scripts/*.py    # cú pháp Python
> node --check scripts/lib/browser.js  # cú pháp JS
> docker compose config --quiet        # cấu hình compose
> ```

## Yêu cầu hệ thống

- Docker Desktop 20.10 trở lên
- RAM tối thiểu 4 GB (khuyến nghị 8 GB)
- Dung lượng đĩa trống 10 GB
- OpenSSL 3.x (có sẵn trong Git Bash)

## Giấy phép

Hệ thống sử dụng GLPI — phần mềm mã nguồn mở theo giấy phép **GPL v3**.
