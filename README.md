# HỆ THỐNG HỖ TRỢ KỸ THUẬT (IT HELPDESK)

[![CI](https://github.com/OWNER/glpi-helpdesk/actions/workflows/ci.yml/badge.svg)](https://github.com/OWNER/glpi-helpdesk/actions/workflows/ci.yml)

> **Đồ án thực tập** — Trường Đại học Đà Lạt (DLU)
> Hệ thống quản lý phòng máy, thiết bị CNTT và tiếp nhận sự cố dạng ticket,
> xây dựng trên nền tảng mã nguồn mở **GLPI 11**.

## Tính năng chính

| Nhóm chức năng | Chi tiết |
|---|---|
| **Quản lý tài sản** | Phòng máy, máy tính, thiết bị mạng, phần mềm; hồ sơ đầy đủ kèm **mã QR** |
| **Tiếp nhận sự cố** | Ticket theo chuẩn ITIL: máy hỏng, lỗi mạng, lỗi phần mềm, thiết bị ngoại vi |
| **Phân công xử lý** | Giao việc cho kỹ thuật viên, theo dõi tiến độ, cam kết SLA |
| **Bảo trì định kỳ** | Lịch bảo trì tự động, lịch sử sửa chữa theo từng thiết bị |
| **Dashboard** | Thống kê số thiết bị, sự cố, lịch bảo trì theo thời gian thực |
| **Giao diện Đà Lạt** | Bảng màu xanh rêu + cam đất trích từ logo DLU, áp dụng toàn hệ thống |
| **Việt hoá** | Mặc định tiếng Việt, 443 thuật ngữ dịch bổ sung + 212 mục dạng số nhiều (30,6% catalog; menu, biểu mẫu & nhãn dashboard 100%) |
| **Trang giới thiệu** | Landing page thiết kế riêng tại `/landing/` — lấy cảm hứng Đà Lạt & DLU, chạy được khi không có mạng |
| **Bảo mật** | HTTPS (chứng chỉ tự ký **có SAN**), chống brute-force, phân quyền theo vai trò, sao lưu tự động |

## ⚡ Bắt đầu nhanh — CHỈ 1 LỆNH

```bash
# Di chuyen vao thu muc goc cua du an (thay bang duong dan thuc tren may ban)
cd duong-dan-toi/glpi-helpdesk
bash scripts/cai-dat-tat-ca.sh
```

Script tự động làm 5 việc và báo kết quả từng bước:

1. Khởi động 4 container (GLPI · MariaDB · Redis · Nginx)
2. Nạp **danh mục nghiệp vụ**: 12 toà nhà · 65 phòng máy · 16 khoa · 10 phòng ·
   7 trung tâm · 10 trạng thái · 79 loại sự cố …
3. Bật **plugin QR** + **plugin giao diện Đà Lạt**
4. Nạp **bản dịch tiếng Việt** (gộp bản chính thức + bổ sung của đồ án)
5. Kiểm tra sức khỏe hệ thống (5 hạng mục)

Truy cập: **https://localhost:8443** · Tài khoản: `glpi`
⚠️ **Đổi mật khẩu `glpi` ngay sau khi đăng nhập lần đầu.**
Mật khẩu admin **không lưu trong mã nguồn**; các script tự động hoá đọc mật khẩu
từ biến môi trường `GLPI_PASS` (không truyền qua tham số dòng lệnh).

## Kiến trúc

```
Nguoi dung --HTTPS:8443--> [ Nginx Gateway ]
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
glpi-helpdesk/
├── .github/workflows/ci.yml     # ★ Pipeline kiem tra tu dong (6 nhom)
├── docker-compose.yml           # Dinh nghia 4 dich vu Docker
├── .env                         # Bien moi truong (chua mat khau)
├── start.sh                     # Khoi dong he thong
├── config/                      # Cau hinh PHP (QR, bao mat)
├── nginx/                       # Gateway: HTTPS, rate limit, bao mat
│   └── ssl/openssl-san.cnf      #   Cau hinh sinh chung chi SSL (co SAN)
├── themes/                      # Dang ky bang mau Da Lat (chi co ten file, KHONG chua mau)
├── plugins/dlubrand/            # Plugin giao dien Da Lat (CSS + logo) — NGUON MAU DUY NHAT
├── landing/                     # ★ Trang gioi thieu du an (nginx phuc vu tai /landing/)
│   ├── index.html               #   Noi dung trang
│   ├── assets/css/style.css     #   Thiet ke rieng (Da Lat + DLU)
│   ├── fonts/                   #   20 tep .woff2 tu luu — chay duoc khi khong co mang
│   └── dashboard-preview.png    #   Anh bang dieu khien (sinh tu du lieu that)
├── scripts/                     # ★ Tat ca script tu dong hoa
│   ├── cai-dat-tat-ca.sh        #   Cai toan bo, 1 lenh
│   ├── nap-du-lieu-nen.sh       #   Nap danh muc nghiep vu
│   ├── nap-du-lieu-mau.sh       #   ★ Nap du lieu demo (thiet bi, phieu, tai khoan)
│   ├── seed-du-lieu-mau.sql     #     Du lieu mau
│   ├── viet-hoa-du-lieu.sh      #   Viet hoa DU LIEU (ten don vi, ho so quyen)
│   ├── tai-font.py              #   Tai font ve may (co subset tieng Viet)
│   ├── tao-mo-bo-sung.py        #   Tao lop phu ban dich
│   ├── gop-ban-dich-tieng-viet.py  # Gop ban dich (khong mat chuoi + va so nhieu)
│   ├── do-do-phu-tieng-viet.py  #   Do ti le Viet hoa
│   ├── bo-sung-tieng-viet.py    #   Tu dien thuat ngu (don + so nhieu)
│   ├── chup-anh-giao-dien.js    #   Chup anh minh chung
│   ├── chup-anh-dashboard.js    #   Chup anh bang dieu khien cho landing page
│   ├── chup-anh-tung-khu.js     #   Chup rieng tung khu de soi thiet ke
│   ├── kiem-tra-landing.js      #   Kiem tra landing (anchor, anh, font, console)
│   ├── kiem-tra-font.py         #   Do phu ky tu that trong tep font
│   └── sinh-ma-qr.py            #   Sinh ma QR hang loat
├── output-qr/                   # Ket qua sinh ma QR
├── backup/                      # Script sao luu du lieu
└── tai-lieu/                    # ★ Tai lieu huong dan + anh minh chung
    ├── HUONG-DAN-TRIEN-KHAI.md            # Trien khai & van hanh
    ├── HUONG-DAN-PLUGIN-QRCODE.md         # Plugin sinh ma QR
    ├── HUONG-DAN-GIAO-DIEN-VA-VIET-HOA.md # Giao dien & Viet hoa
    ├── THONG-TIN-DAI-HOC-DA-LAT.md        # Co cau to chuc DLU
    ├── SO-SANH-VOI-GLPI-GOC.md            # ★ Cai thien gi so voi ban goc
    └── anh-giao-dien/                     # Anh chup giao dien thuc te
```

## 🎬 Dữ liệu demo — để trình diễn cho hội đồng

Hệ thống cài xong là **CSDL rỗng**, không thể demo. Chạy 1 lệnh để có dữ liệu:

```bash
bash scripts/nap-du-lieu-mau.sh
```

Kết quả: **17 máy tính · 5 màn hình · 3 máy in · 9 thiết bị mạng · 10 phần mềm ·
13 phiếu sự cố (đủ 4 trạng thái) · 6 tài khoản 3 vai trò**.

| Tài khoản | Mật khẩu | Vai trò |
|---|---|---|
| `ktv.an`, `ktv.binh` | `Dlu@2026` | Kỹ thuật viên |
| `gv.cuong`, `gv.dung` | `Dlu@2026` | Giảng viên |
| `sv.hoa`, `sv.khanh` | `Dlu@2026` | Sinh viên |

> Script **idempotent** — chạy lại nhiều lần không nhân đôi dữ liệu.
> Mã tài sản theo quy ước thật: `TDL-PC-A101-001` = ĐH Đà Lạt – Máy tính – Toà A – Phòng 101 – Máy 01.

## 🌐 Trang giới thiệu dự án (Landing page)

Truy cập: **https://localhost:8443/landing/**

Trang giới thiệu dành cho hội đồng và người dùng mới, **thiết kế riêng theo bản
sắc Đà Lạt và Trường Đại học Đà Lạt** — không dùng giao diện mẫu có sẵn.

**Chất liệu tạo hình lấy từ chính DLU:**

| Nguồn | Thể hiện trên trang |
|---|---|
| Họa tiết trống đồng trong logo | Vòng đồng tâm mờ sau tiêu đề, họa tiết ngăn cách giữa các mục |
| Dải lá xanh + sao đỏ | Bảng màu chủ đạo, huy hiệu "Trường Đại học Đà Lạt" |
| Cảnh quan Đà Lạt | Đồi thông nhiều lớp, sương mù giữa các dãy núi, hồ nước ở chân trang |
| Kiến trúc Pháp cổ | Chữ tiêu đề **Playfair Display** (serif), thân bài **Be Vietnam Pro** |

**Kỹ thuật:**

- **Chạy hoàn toàn khi KHÔNG có Internet** — 20 tệp font `.woff2` tự lưu trong
  `landing/fonts/` (có subset tiếng Việt), **không dùng CDN**. Đã bỏ hẳn
  Tailwind CSS và Font Awesome (~1,5 MB) để trang gọn còn ~630 KB.
- **Bộ biểu tượng SVG nội bộ** — không phụ thuộc thư viện icon bên ngoài.
- **Liên kết tương đối** — mở từ máy khác trong mạng LAN vẫn hoạt động đúng.
- **Có hiệu ứng xuất hiện khi cuộn**, nhưng chỉ ẩn nội dung khi JavaScript chạy
  (nếu JS lỗi hoặc bị tắt, nội dung vẫn hiện đầy đủ).
- Ảnh dashboard trong trang sinh tự động bằng `node scripts/chup-anh-dashboard.js`
  (dữ liệu thật, đã Việt hoá, đã ẩn banner cảnh báo kỹ thuật).

**Kiểm thử tự động:** `node scripts/kiem-tra-landing.js` (anchor, ảnh, font,
tài nguyên lỗi, lỗi console) và `python scripts/kiem-tra-font.py` (đối chiếu
bảng ký tự thật trong tệp font với chữ có trên trang).

## Lệnh thường dùng

```bash
# Cai dat & du lieu
bash scripts/cai-dat-tat-ca.sh       # Cai toan bo he thong (1 lenh)
bash scripts/nap-du-lieu-nen.sh      # Chi nap lai danh muc nghiep vu
bash scripts/nap-du-lieu-mau.sh      # Nap du lieu demo (thiet bi, phieu, tai khoan)
bash scripts/cai-giao-dien.sh        # Chi cai lai giao dien Da Lat

# Tieng Viet
python scripts/tao-mo-bo-sung.py
python scripts/gop-ban-dich-tieng-viet.py
python scripts/do-do-phu-tieng-viet.py
bash   scripts/viet-hoa-du-lieu.sh   # Viet hoa du lieu (ten don vi, ho so quyen)

# Ma QR
python scripts/sinh-ma-qr.py         # Sinh QR hang loat (du phong)

# Landing page
python scripts/tai-font.py           # Tai font ve may (can mang, chi chay 1 lan)
node   scripts/kiem-tra-landing.js   # Kiem tra landing (anchor, anh, font, console)
node   scripts/chup-anh-tung-khu.js  # Chup rieng tung khu de soi thiet ke
python scripts/kiem-tra-font.py      # Do phu ky tu that trong tep font

# Chup anh giao dien (can dang nhap) — mat khau lay tu bien moi truong:
#   GLPI_USER=glpi GLPI_PASS='<mat-khau>' node scripts/chup-anh-dashboard.js
node   scripts/chup-anh-dashboard.js # Chup lai anh dashboard cho landing page
node   scripts/chup-anh-giao-dien.js # Chup anh minh chung bao cao

# Van hanh
bash start.sh                        # Khoi dong
docker-compose logs -f glpi          # Xem log
docker-compose stop                  # Dung tam thoi
docker-compose down                  # Tat hoan toan
bash backup/backup.sh                # Sao luu du lieu
```

## Tài liệu

| Tài liệu | Nội dung |
|---|---|
| [`HUONG-DAN-TRIEN-KHAI.md`](tai-lieu/HUONG-DAN-TRIEN-KHAI.md) | Cài đặt, cấu hình nghiệp vụ, sao lưu, xử lý sự cố |
| [`HUONG-DAN-GIAO-DIEN-VA-VIET-HOA.md`](tai-lieu/HUONG-DAN-GIAO-DIEN-VA-VIET-HOA.md) | Tuỳ biến giao diện Đà Lạt & Việt hoá |
| [`HUONG-DAN-PLUGIN-QRCODE.md`](tai-lieu/HUONG-DAN-PLUGIN-QRCODE.md) | Cài & dùng plugin sinh mã QR |
| [`THONG-TIN-DAI-HOC-DA-LAT.md`](tai-lieu/THONG-TIN-DAI-HOC-DA-LAT.md) | Cơ cấu tổ chức DLU, ánh xạ vào hệ thống |
| [`SO-SANH-VOI-GLPI-GOC.md`](tai-lieu/SO-SANH-VOI-GLPI-GOC.md) | **Đã cải thiện gì so với GLPI gốc** — bảng đối chiếu chi tiết |

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
