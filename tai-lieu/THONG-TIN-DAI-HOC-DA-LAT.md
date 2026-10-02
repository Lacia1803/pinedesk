# THÔNG TIN TRƯỜNG ĐẠI HỌC ĐÀ LẠT (DLU)
## Tư liệu phục vụ đồ án PineDesk

> **Mục đích:** cung cấp dữ liệu thực tế để cấu hình hệ thống khớp với tổ chức
> của Trường Đại học Đà Lạt — dùng cho cây vị trí, phòng máy, khoa/trung tâm,
> và phần thuyết minh trong báo cáo đồ án.
>
> **Nguồn:** website chính thức `dlu.edu.vn` (truy cập 19/09/2026; **cập nhật lại 02/10/2026**).
> **Trạng thái:** ✅ đã dùng để tạo dữ liệu nền trong `scripts/seed-du-lieu-nen.sql`.
>
> ---
>
> ### ⚠️ ĐÍNH CHÍNH NGÀY 02/10/2026
>
> Rà soát lại website chính thức cho thấy **một số tên đơn vị đã thay đổi** so với
> bản tài liệu lập ngày 19/09/2026. Cần sửa khi trích dẫn:
>
> | Bản cũ (19/09) | Bản đúng (02/10) | Bằng chứng |
> |---|---|---|
> | Trung tâm CNTT — tên miền `cict.dlu.edu.vn` | **Trung tâm Công nghệ thông tin** — tên miền thật `itc.dlu.edu.vn` (`cict` chuyển hướng 301) | `itc.dlu.edu.vn/gioi-thieu/` |
> | Phòng Cơ sở Vật chất (`pcsvc`) | **Phòng Quản trị Cơ sở vật chất** (tên miền `pcsvc.dlu.edu.vn` vẫn đúng) | Danh mục đơn vị trên trang chủ |
> | Phòng Chính trị và Công tác Sinh viên | **Phòng Công tác sinh viên** | Danh mục đơn vị trên trang chủ |
> | Phòng Quản lý chất lượng (`pktkd`) | **Phòng Quản lý chất lượng và Pháp chế** | Danh mục đơn vị trên trang chủ |
> | Phòng Quản lý Khoa học – Hợp tác Quốc tế | **Phòng Khoa học công nghệ và Hợp tác quốc tế** | Danh mục đơn vị trên trang chủ |
> | Phòng Tài chính (`ptc`) | **Phòng Tài chính Kế hoạch** | Danh mục đơn vị trên trang chủ |
> | Khoa Toán – Tin (`ktt`) | **Khoa Toán – Tin học** | Danh mục đơn vị trên trang chủ |
>
> **Chi tiết đầy đủ về nhân sự & chức năng của Trung tâm CNTT (ITC):**
> xem [`BAI-TOAN-NGHIEP-VU.md`](BAI-TOAN-NGHIEP-VU.md) mục 2 — có danh sách
> **5 nhân sự thật** (Giám đốc, Phó Giám đốc, 2 chuyên viên, 1 nhân viên).

---

## 1. THÔNG TIN CHUNG

| Hạng mục | Thông tin |
|---|---|
| **Tên tiếng Việt** | Trường Đại học Đà Lạt |
| **Tên tiếng Anh** | Dalat University (DLU) |
| **Mã trường** | **TDL** |
| **Năm thành lập** | **1976** (kỷ niệm 50 năm 1976–2026) |
| **Địa chỉ** | Số 01 Phù Đổng Thiên Vương, Phường Lâm Viên, TP Đà Lạt, tỉnh Lâm Đồng |
| **Website** | https://dlu.edu.vn |
| **Hiệu trưởng** | TS. Mai Minh Nhật (Bí thư Đảng uỷ, Hiệu trưởng) |
| **Người học** | hơn **14.500** |
| **Chương trình đào tạo** | 41 đại học · 14 thạc sĩ · 07 tiến sĩ |
| **Tỉ lệ có việc làm** | ~90% |
| **Cán bộ có học vị GS/PGS/TS** | ~42% |

**Vì sao thông tin này quan trọng cho đồ án:**

- **Mã trường `TDL`** → dùng làm tiền tố mã tài sản (ví dụ `TDL-PC-A101-001`)
  thay vì tiền tố giả định.
- **Quy mô 14.500 người học** → biện luận cho thiết kế CSDL & phân quyền
  (cần nhiều hồ sơ người dùng, phân quyền theo khoa).
- **Địa chỉ đầy đủ** → điền vào trường *Vị trí* gốc trong GLPI.

---

## 2. CÁC KHOA (16 khoa)

Dùng để tạo **nhóm (Groups)** và **cây vị trí** trong GLPI — mỗi khoa là một
đơn vị quản lý tài sản riêng.

| # | Tên khoa | Tên miền |
|---|---|---|
| 1 | Khoa Toán – Tin | ktt.dlu.edu.vn |
| 2 | Khoa Công nghệ Thông tin | cntt.dlu.edu.vn |
| 3 | Khoa Vật lý và Kỹ thuật hạt nhân | vl.dlu.edu.vn |
| 4 | Khoa Hóa học và Môi trường | khhmt.dlu.edu.vn |
| 5 | Khoa Sinh học | ksh.dlu.edu.vn |
| 6 | Khoa Nông lâm | knl.dlu.edu.vn |
| 7 | Khoa Ngữ văn và Lịch sử | nvvh.dlu.edu.vn |
| 8 | Khoa Kinh tế – Quản trị Kinh doanh | kktqt.dlu.edu.vn |
| 9 | Khoa Du lịch | kqtdl.dlu.edu.vn |
| 10 | Khoa Luật học | klh.dlu.edu.vn |
| 11 | Khoa Ngoại ngữ | nn.dlu.edu.vn |
| 12 | Khoa Quốc tế học | kqth.dlu.edu.vn |
| 13 | Khoa Xã hội học và Công tác xã hội | kctxh.dlu.edu.vn |
| 14 | Khoa Sư phạm | sp.dlu.edu.vn |
| 15 | Khoa Lý luận Chính trị | kllct.dlu.edu.vn |
| 16 | Khoa Giáo dục thể chất | kgdtc.dlu.edu.vn |

**Phòng máy theo khoa (dùng cho dữ liệu nền):**

- **Khoa Công nghệ Thông tin** — phòng máy chuyên ngành (lập trình, mạng, AI).
  Đây là đơn vị có **mật độ thiết bị cao nhất** → ưu tiên triển khai trước.
- **Khoa Toán – Tin** — phòng máy tính toán, thực hành tin học cơ bản.
- **Các khoa còn lại** — phòng máy dùng chung, chủ yếu là máy tính để bàn
  phục vụ giảng dạy đại cương.

---

## 3. CÁC PHÒNG CHỨC NĂNG (10 phòng)

| # | Tên phòng | Tên miền |
|---|---|---|
| 1 | Phòng Tổ chức – Hành chính | tchc.dlu.edu.vn |
| 2 | Phòng Quản lý Đào tạo | pqldt.dlu.edu.vn |
| 3 | Phòng Chính trị và Công tác Sinh viên | pctsv.dlu.edu.vn |
| 4 | Phòng Quản lý chất lượng | pktkd.dlu.edu.vn |
| 5 | Phòng Quản lý Khoa học – Hợp tác Quốc tế | pkhht.dlu.edu.vn |
| 6 | Phòng Thanh tra | dlu.edu.vn |
| 7 | Phòng Tài chính | ptc.dlu.edu.vn |
| 8 | **Phòng Cơ sở Vật chất** | pcsvc.dlu.edu.vn |
| 9 | Phòng Quản lý Đào tạo Sau Đại học | sdh.dlu.edu.vn |
| 10 | Phòng Tạp chí và Truyền thông | ptctt.dlu.edu.vn |

> **⭐ LƯU Ý QUAN TRỌNG CHO ĐỒ ÁN:**
> **Phòng Cơ sở Vật chất (`pcsvc`)** là đơn vị **quản lý tài sản, cơ sở vật chất**
> của Trường. Trong thực tế, đây chính là **đơn vị chủ quản của PineDesk** —
> tức là **khách hàng chính** của đồ án. Khi thuyết minh, hãy nêu rõ:
> hệ thống được xây dựng để phục vụ nghiệp vụ quản lý & hỗ trợ kỹ thuật cho
> Phòng Cơ sở Vật chất và Trung tâm Công nghệ thông tin.

---

## 4. CÁC TRUNG TÂM (6 trung tâm) & VIỆN (1)

| # | Tên đơn vị | Tên miền |
|---|---|---|
| 1 | **Trung tâm Công nghệ thông tin** | itc.dlu.edu.vn |
| 2 | Trung tâm Ngoại ngữ và Đào tạo nguồn nhân lực | ttnn.dlu.edu.vn |
| 3 | Trung tâm Hỗ trợ Khởi nghiệp | khoinghiep.dlu.edu.vn |
| 4 | Trung tâm Phân tích và Kiểm định | vnckd.dlu.edu.vn |
| 5 | Trung tâm nghiên cứu đa dạng sinh học và biến đổi khí hậu | crcb.dlu.edu.vn |
| 6 | Trung tâm Giáo dục Quốc phòng và An ninh | qpan.dlu.edu.vn |
| — | Học viện King Sejong Đà Lạt (Viện) | kingsejongdalat.dlu.edu.vn |

> **⭐ LƯU Ý QUAN TRỌNG CHO ĐỒ ÁN:**
> **Trung tâm Công nghệ thông tin (`itc`)** là đơn vị **vận hành kỹ thuật** —
> tức là **đội ngũ kỹ thuật viên (Technician)** sử dụng hệ thống hằng ngày để
> tiếp nhận và xử lý sự cố. Đây là **người dùng chính thứ hai** của đồ án.

### Mô hình 2 vai trò thực tế tại DLU

```
   PHÒNG QUẢN TRỊ CSVC (pcsvc)          TRUNG TÂM CNTT (itc)
   ─ Chủ quản tài sản                     ─ Đội kỹ thuật vận hành
   ─ Theo dõi thiết bị, thanh lý          ─ Tiếp nhận & xử lý sự cố
   ─ Lập kế hoạch mua sắm                 ─ Cấu hình mạng, máy chủ
              │                                        │
              └──────────────┬─────────────────────────┘
                             ▼
                  HỆ THỐNG PINEDESK (GLPI)
                             │
                             ▼
        Người dùng cuối: giảng viên, sinh viên, nhân viên
        (báo sự cố qua ticket / cổng dịch vụ)
```

---

## 5. CƠ CẤU TỔ CHỨC KHÁC

| Đơn vị | Ghi chú |
|---|---|
| Hội đồng Trường | Cơ quan quản trị cao nhất |
| Đảng uỷ | Tổ chức Đảng |

---

## 6. ĐỊA CHỈ & VỊ TRÍ THỰC TẾ (dùng cho cây vị trí GLPI)

**Địa chỉ:** Số 01 Phù Đổng Thiên Vương, Phường Lâm Viên, TP Đà Lạt, tỉnh Lâm Đồng

**Đặc điểm khuôn viên (theo thực tế):**

- Khuôn viên trường nằm trên **đồi thông**, địa hình dốc — các toà nhà được
  đánh số theo khu (A, B, C, H...) và số tầng (ví dụ `A7` = toà A, tầng 7).
- Theo tư liệu của Khoa Lý luận Chính trị: địa chỉ phòng là *"Lầu 1, tòa nhà A7"*
  → xác nhận **quy ước đặt tên toà nhà + lầu** trong trường.

**Quy ước đặt tên vị trí đã dùng trong dữ liệu nền của đồ án:**

```
Trường Đại học Đà Lạt
├── Khu hành chính H1
├── Khu hành chính H2
├── Giảng đường A1
│   ├── Phòng máy A101
│   ├── Phòng máy A102
│   └── ...
├── Giảng đường A2
├── Giảng đường B1
├── Giảng đường B2
├── Trung tâm CNTT (itc)
├── Thư viện
└── Ký túc xá
```

> ⚠️ **Lưu ý về tính xác thực:** Cây vị trí **tên toà nhà cụ thể** (A101, B203...)
> là **do đồ án mô phỏng**, vì Trường chưa công bố sơ đồ phòng máy chi tiết.
> Trong báo cáo cần ghi rõ điều này để đảm bảo trung thực học thuật.
> Các thông tin về **khoa, phòng, trung tâm, địa chỉ, quy mô** thì **hoàn toàn
> xác thực** (lấy từ website chính thức).

---

## 7. CÁCH ÁP DỤNG VÀO HỆ THỐNG GLPI

| Thông tin DLU | Ánh xạ vào GLPI | Bảng dữ liệu |
|---|---|---|
| Khoa / Phòng / Trung tâm | **Nhóm (Groups)** | `glpi_groups` |
| Toà nhà / Phòng máy | **Vị trí (Locations)** — cây | `glpi_locations` |
| Thiết bị theo khoa | **Máy tính (Computers)** + `locations_id` | `glpi_computers` |
| Nhân sự khoa/phòng | **Người dùng (Users)** | `glpi_users` |
| Kỹ thuật viên CICT | Hồ sơ **Technician** | `glpi_profiles_users` |
| Quản lý CSVCP | Hồ sơ **Admin** | `glpi_profiles_users` |
| Loại sự cố theo phòng máy | **Loại sự cố (ITIL Categories)** | `glpi_itilcategories` |

### Gợi ý mã tài sản theo chuẩn DLU

Nên dùng **mã trường `TDL`** làm tiền tố:

```
TDL-PC-A101-001     máy tính, phòng A101, số thứ tự 001
TDL-SW-A101-01      switch mạng, phòng A101
TDL-PR-B203-01      máy in, phòng B203
TDL-MON-A102-005    màn hình, phòng A102
```

Trong đó:

- `TDL` — mã trường (chuẩn quốc gia)
- `PC` — loại thiết bị (PC, MON, PR, SW, PJ cho máy chiếu)
- `A101` — phòng (theo quy ước toà + số phòng của Trường)
- `001` — số thứ tự thiết bị trong phòng

---

## 8. SỐ LIỆU THIẾT BỊ ƯỚC TÍNH (để thuyết minh quy mô)

Dựa trên quy mô thực tế **14.500 người học, 41 chương trình đào tạo**:

| Loại thiết bị | Ước tính | Cơ sở suy luận |
|---|---|---|
| Máy tính để bàn (phòng máy) | 800 – 1.200 | ~10-12 phòng máy × 40-60 máy |
| Máy tính văn phòng | 400 – 600 | ~26 đơn vị (16 khoa + 10 phòng) |
| Máy in | 80 – 120 | 1-2 máy/đơn vị + phòng máy |
| Máy chiếu | 100 – 150 | giảng đường, phòng học lớn |
| Switch / Router mạng | 150 – 250 | theo toà nhà & tầng |
| Màn hình | 1.200 – 1.500 | kèm máy tính + màn hình rời |
| Máy chủ (Server) | 15 – 25 | Trung tâm CNTT quản lý |

> ⚠️ Đây là **ước tính để thuyết minh**, không phải số liệu công bố chính thức.
> Khi bảo vệ, nên trình bày dưới dạng *"quy mô ước tính dựa trên số lượng
> người học và số đơn vị"*, kèm giả định rõ ràng.

---

## 9. GHI CHÚ TRUNG THỰC HỌC THUẬT

Khi viết báo cáo, phân biệt rõ 3 nhóm thông tin:

| Nhóm | Ví dụ | Độ tin cậy |
|---|---|---|
| ✅ **Số liệu chính thức** | 16 khoa, 10 phòng, 6 trung tâm, địa chỉ, 14.500 người học, thành lập 1976 | Lấy từ `dlu.edu.vn` |
| 🟡 **Suy luận hợp lý** | Số lượng thiết bị ước tính, mô hình 2 vai trò CSVCP–CICT | Có căn cứ, ghi rõ giả định |
| 🔵 **Mô phỏng của đồ án** | Tên phòng máy cụ thể (A101, B203), mã tài sản | Do đồ án tự đặt, ghi rõ trong báo cáo |

Cách trình bày này thể hiện **tính trung thực học thuật** — điều mà hội đồng
đánh giá cao hơn việc đưa số liệu "đẹp" nhưng không kiểm chứng được.
