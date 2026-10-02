# BÀI TOÁN NGHIỆP VỤ — PINEDESK GIẢI QUYẾT VẤN ĐỀ GÌ CỦA TRƯỜNG ĐẠI HỌC ĐÀ LẠT

> **Mục đích:** trả lời câu hỏi hội đồng luôn hỏi — *"Đồ án này thực tế giải quyết
> nhu cầu gì của trường?"* — bằng dữ kiện công khai, có nguồn, không suy diễn.
>
> **Ngày lập:** 02/10/2026
> **Người lập:** đồ án PineDesk
>
> **Quy ước ghi nguồn trong tài liệu này:**
> - 🟢 **DỮ KIỆN** — có nguồn công khai kiểm chứng được, ghi rõ URL & ngày truy cập.
> - 🟡 **SUY LUẬN** — được rút ra từ dữ kiện, nêu rõ lập luận. Không phải số đo.
> - 🔴 **GIẢ ĐỊNH** — chưa có nguồn, là giả thuyết của đồ án, phải kiểm chứng thực địa.

---

## 1. TÓM TẮT MỘT TRANG

**Ai đang đau:** Trung tâm Công nghệ thông tin (ITC) — đơn vị chịu trách nhiệm
"quản lý và vận hành hệ thống CNTT của Trường, tổ chức phòng thực hành máy tính
cho người học" 🟢.

**Đau vì đâu — ba mâu thuẫn đo được từ dữ kiện công khai:**

| # | Mâu thuẫn | Số liệu 🟢 | Suy luận 🟡 |
|---|---|---|---|
| **M1** | **Quá tải người/nhân sự** | 14.500+ người học; ITC có **5 nhân sự** (01 Giám đốc, 01 Phó Giám đốc, 02 Chuyên viên, 01 Nhân viên) | Tỉ lệ ≈ **1 nhân sự : 2.900 người học**. Không thể phục vụ thủ công |
| **M2** | **Cửa sổ tiếp nhận hẹp** | Hotline **0913 069 978**; giờ làm việc **Thứ 2–Thứ 6, 7h30–16h30** | **~143 giờ/tuần** trong 168 giờ là *không có kênh tiếp nhận*. Sự cố phòng máy (lớp tối, cuối tuần, kỳ thi) rơi vào khoảng trống |
| **M3** | **Không có kênh có cấu trúc** | ITC công bố hotline + email + form liên hệ; **không công bố** hệ thống tiếp nhận sự cố có phân công/trạng thái/SLA | Yêu cầu đến qua kênh phi cấu trúc (điện thoại, email, gặp trực tiếp) → dễ thất lạc, không đo được, không truy vết được |

**PineDesk giải quyết đúng ba mâu thuẫn trên bằng:**
1. **Kênh nộp 24/7 có cấu trúc** — thay cho việc phải chờ hotline trong giờ hành chính;
2. **Tự động phân công + trạng thái + SLA** — giảm gánh nặng điều phối thủ công cho 5 nhân sự;
3. **Hồ sơ thiết bị + mã QR + lịch sử sửa chữa** — biến việc "quản lý tài sản" từ trí nhớ cá nhân thành dữ liệu có thể truy vết.

**Điều PineDesk KHÔNG tuyên bố:** không có số liệu về số sự cố/tuần thực tế của
trường, không có cam kết SLA đã được ban hành, không có phê duyệt chính thức từ
ITC. Ba điều này nằm ở mục 7 (vui lòng đọc trước khi trích dẫn).

---

## 2. ĐƠN VỊ PHỤ TRÁCH — TRUNG TÂM CÔNG NGHỆ THÔNG TIN (ITC)

> ⚠️ **Đính chính:** một số tài liệu của đồ án trước đây ghi "Phòng Công nghệ
> thông tin". Tên đúng theo công bố chính thức của Trường là **Trung tâm Công
> nghệ thông tin (ITC)**. Tên miền `cict.dlu.edu.vn` từng xuất hiện trong tài
> liệu cũ cũng **không còn đúng**: hiện chuyển hướng 301 về `itc.dlu.edu.vn` 🟢.

### 2.1. Chức năng chính thức 🟢

Nguồn: https://itc.dlu.edu.vn/gioi-thieu/ (truy cập 02/10/2026). **Nguyên văn:**

> - Tham mưu cho Hiệu trưởng hoạch định chiến lược và quản lý các công tác
>   liên quan đến Công nghệ thông tin của Trường;
> - **Đơn vị quản lý và vận hành hệ thống Công nghệ thông tin của Trường.
>   Tổ chức phòng thực hành máy tính cho người học**;
> - Tổ chức các khoá đào tạo ngắn hạn về Công nghệ thông tin;
> - Xây dựng và chuyển giao các giải pháp Công nghệ thông tin cho các đơn vị
>   trong và ngoài Trường.

👉 Gạch đầu dòng thứ hai là **căn cứ pháp lý cho phạm vi đồ án**: PineDesk nằm
đúng trong nhiệm vụ "quản lý hệ thống CNTT + tổ chức phòng thực hành máy tính".

### 2.2. Nhân sự 🟢

Nguồn: https://itc.dlu.edu.vn/gioi-thieu/ (truy cập 02/10/2026).

| # | Họ tên | Chức danh | Email |
|---|---|---|---|
| 1 | Ths. Trần Thống | Giám đốc | `thongt@dlu.edu.vn` |
| 2 | TS. Trần Ngô Như Khánh | Phó Giám đốc | `khanhtnn@dlu.edu.vn` |
| 3 | Đặng Quốc Phi | Chuyên viên | `phidq@dlu.edu.vn` |
| 4 | Lê Thị Uyên | Chuyên viên | `uyenlt@dlu.edu.vn` |
| 5 | Phan Trung Tính | Nhân viên | `tinhpt@dlu.edu.vn` |

**Tổng: 05 nhân sự.** Không có bộ phận trực helpdesk riêng theo công bố công khai.
Trong 5 người, 2 người ở vị trí lãnh đạo (Giám đốc, Phó Giám đốc) → **số người
thực sự trực tiếp xử lý sự cố kỹ thuật rất mỏng (khoảng 3 người)** 🟡.

### 2.3. Kênh liên hệ công bố 🟢

Nguồn: https://itc.dlu.edu.vn/lien-he/ (truy cập 02/10/2026).

| Kênh | Thông tin |
|---|---|
| Hotline | **0913 069 978** (một số duy nhất) |
| Email | `itc@dlu.edu.vn` |
| Form liên hệ | Có trên website (không phải hệ thống ticket) |
| Thời gian làm việc | **Thứ 2 → Thứ 6, 7h30 – 16h30** |
| Địa chỉ | Số 1, Phù Đổng Thiên Vương, Phường Lâm Viên, Đà Lạt, Lâm Đồng |

---

## 3. QUY MÔ TRƯỜNG — ĐỐI TƯỢNG PHỤC VỤ 🟢

Nguồn: https://dlu.edu.vn/ (truy cập 02/10/2026).

| Hạng mục | Số liệu |
|---|---|
| Người học | **14.500+** |
| Chương trình đào tạo | 41 đại học · 14 thạc sĩ · 07 tiến sĩ |
| Mã trường | **TDL** (khớp tiền tố mã tài sản `TDL-PC-A101-001` của đồ án) |
| Đơn vị | 16 khoa · 10 phòng · 6 trung tâm |
| Giảng viên có GS/PGS/TS | ~42% |

**Phòng máy (phạm vi phục vụ trực tiếp):** ITC công bố có "N phòng máy thực hành"
(số hiển thị động trên trang chủ, không lấy được giá trị tĩnh) 🟢. Đồ án hiện mô
hình hoá **65 phòng máy** trong dữ liệu nền — con số này là **cấu trúc mẫu của đồ
án**, không phải số liệu công bố của Trường 🟡.

---

## 4. BA MÂU THUẪN — PHÂN TÍCH CHI TIẾT

### 4.1. M1 — 5 người phục vụ 14.500+ người học

**Dữ kiện 🟢:** 5 nhân sự ITC (mục 2.2) · 14.500+ người học (mục 3).

**Suy luận 🟡:**
- Tỉ lệ thô ≈ **1 : 2.900**. Để so sánh, một helpdesk CNTT nội bộ thông thường
  vận hành ở tỉ lệ 1 kỹ thuật viên : 200–500 người dùng. Tỉ lệ của DLU cao hơn
  khoảng **6–15 lần** so với mức phổ thông.
- Với 3 người trực tiếp kỹ thuật, mỗi người phụ trách ~4.800 người học.
- Kết luận: mô hình phục vụ **bắt buộc phải dựa vào tự phục vụ (self-service) và
  tự động hoá**, không thể là "người nhận – người gọi – người ghi sổ" thủ công.

**PineDesk đáp ứng:** vai trò Self-Service cho sinh viên/giảng viên (tự tạo phiếu,
tự tra cứu tình trạng, tự quét QR xem hồ sơ thiết bị) → giảm số lần phải gọi điện
tới hotline. Cấu hình tại `scripts/seed-du-lieu-mau.sql` (tài khoản `sv.hoa`,
`sv.khanh`, `gv.cuong`, `gv.dung`).

### 4.2. M2 — Cửa sổ tiếp nhận chỉ 7h30–16h30, Thứ 2–Thứ 6

**Dữ kiện 🟢:** giờ làm việc ITC (mục 2.3).

**Tính toán 🟡:** một tuần có 168 giờ; cửa sổ tiếp nhận là 5 ngày × 9 giờ
(7h30–16h30, đã tính giờ nghỉ trưa) ≈ **45 giờ/tuần** → **~123 giờ/tuần (73%)
trường không có kênh tiếp nhận chính thức**.

**Ai bị ảnh hưởng — các tình huống rơi vào khoảng trống 🟡:**
- Lớp học buổi tối / ngoài giờ hành chính trong phòng máy;
- Sự cố cuối tuần trước kỳ thi, đồ án, seminar;
- Máy chủ / thiết bị mạng hỏng ngoài giờ (không có ai trực để ghi nhận);
- Giảng viên phát hiện hỏng thiết bị trong tiết dạy nhưng chỉ nhớ báo "khi nào
  tiện" — dễ quên hẳn.

**PineDesk đáp ứng:** hệ thống chạy 24/7 qua HTTPS tại `https://localhost:8443`
(cấu hình `docker-compose.yml` + `nginx/`), nộp phiếu bất kể giờ nào; phiếu nằm
trong hàng đợi có trạng thái, sáng hôm sau kỹ thuật viên mở ra là thấy ngay thay
vì phải nhớ lại.

### 4.3. M3 — Không có kênh tiếp nhận có cấu trúc

**Dữ kiện 🟢:** ITC công bố hotline + email + form liên hệ, **không công bố** hệ
thống quản lý ticket (mục 2.3).

**Suy luận 🟡 — hệ quả của kênh phi cấu trúc:**

| Hệ quả | Vì sao |
|---|---|
| **Thất lạc** | Yêu cầu qua điện thoại không có bản ghi; nếu người nhận quên là mất |
| **Không đo được** | Không có dữ liệu thời gian phản hồi / thời gian xử lý / số lượng theo tuần |
| **Không truy vết** | Không biết "máy A101-003 đã hỏng mấy lần", "sửa gì rồi" |
| **Không công bằng** | Ai gọi to hơn, gặp đúng người hơn thì được ưu tiên |
| **Khó bàn giao** | Người phụ trách nghỉ → người khác không biết đang tồn những gì |
| **Không có số liệu để xin đầu tư** | Muốn đề xuất mua máy mới phải chứng minh bằng tần suất hỏng — nhưng không có dữ liệu |

**PineDesk đáp ứng:** ticket có mã, có trạng thái (Mới / Được giao / Đã giải quyết
/ Đã đóng), có người yêu cầu, có thiết bị gắn kèm, có nhật ký. Dashboard thống kê
tình hình. Toàn bộ truy vết được.

---

## 5. VÌ SAO KHÔNG DÙNG CÔNG CỤ SẴN CÓ — TRẢ LỜI CÂU HỎI KHÓ

Đây là câu hỏi hội đồng gần như chắc chắn sẽ hỏi. Trả lời từng phương án:

### 5.1. "Sao không dùng Google Form + Google Sheet?"

| Tiêu chí | Google Form + Sheet | PineDesk |
|---|---|---|
| Nộp phiếu 24/7 | ✅ Có | ✅ Có |
| Phân công cho kỹ thuật viên | ❌ Thủ công, không có hàng đợi | ✅ Theo vai trò |
| Trạng thái phiếu (Mới → Đóng) | ❌ Phải tự thêm cột, tự quản | ✅ Có sẵn, chuẩn ITIL |
| Hạn phản hồi / hạn xử lý (SLA) | ❌ Không | ✅ Có (cấu hình theo mức ưu tiên) |
| Nhiều người cùng sửa | ⚠️ Dễ ghi đè, mất dữ liệu | ✅ CSDL giao dịch |
| Liên kết phiếu ↔ thiết bị | ⚠️ Phải gõ tay mã máy | ✅ Liên kết khoá ngoại |
| Lịch sử sửa chữa thiết bị | ❌ Không tổng hợp được | ✅ Tra theo thiết bị |
| Phân quyền (ai xem được gì) | ❌ Ai có link là xem được | ✅ 3 vai trò |
| Truy vết thay đổi | ❌ Không có nhật ký | ✅ Có log |
| Mã QR dán lên máy → mở đúng hồ sơ | ❌ Không | ✅ Plugin Barcode đã tích hợp |

**Kết luận:** Form + Sheet phù hợp để *thu thập*, không phù hợp để *vận hành quy
trình*. Với **5 nhân sự phục vụ 14.500+ người**, mọi thao tác phải tự động, mọi
dữ liệu phải truy vết được — đọc Sheet thủ công không mở rộng nổi.

### 5.2. "Sao không dùng thẳng GLPI gốc? Bạn làm được gì?"

Toàn bộ câu trả lời và **bảng đối chiếu có kiểm chứng** nằm ở
[`SO-SANH-VOI-GLPI-GOC.md`](SO-SANH-VOI-GLPI-GOC.md). Tóm tắt phần liên quan
trực tiếp tới bài toán nghiệp vụ:

- GLPI gốc **hoàn toàn chưa Việt hoá** phần lớn menu → 5 nhân sự phải đọc tiếng
  Anh chuyên ngành ITSM;
- GLPI gốc là **CSDL rỗng** → không có sẵn danh mục vị trí/khoa/phòng của DLU;
- GLPI gốc **không có** logo, bảng màu, landing page, chứng chỉ SSL, chống
  brute-force, CI/CD hay quy trình cài một lệnh;
- Nhưng: **lõi nghiệp vụ ticket/asset/SLA của GLPI là nền tảng**, đồ án không tự
  viết lại điều này. Tùy biến **hoàn toàn nằm ngoài lõi** → nâng cấp GLPI không
  mất công.

### 5.3. "Sao không mua iTop / ServiceNow?"

- **ServiceNow:** chi phí bản quyền doanh nghiệp, không phù hợp ngân sách một
  trường công hỗ trợ đồ án nội bộ, và dùng thử thường bị giới hạn.
- **iTop:** có bản cộng đồng, nhưng vẫn phải Việt hoá + cấu hình + dựng dữ liệu
  từ đầu — **khối lượng công việc tương tự GLPI, mà GLPI có cộng đồng lớn hơn và
  phù hợp với mục tiêu chứng minh năng lực kỹ thuật của đồ án**.
- **Điểm mấu chốt:** đồ án chọn GLPI vì nó là *nguyên liệu thô* cần đúng những
  gì đồ án cung cấp (bản địa hoá, dữ liệu nghiệp vụ, tự động hoá) — xem
  `SO-SANH-VOI-GLPI-GOC.md` mục 0.

---

## 6. CƠ CHẾ CHỐNG LẠM DỤNG — "SINH VIÊN SPAM THÌ SAO?"

Đây là câu hỏi phản biện trực diện nhất. Câu trả lời phải là **cơ chế nhiều tầng
có thể trình diễn**, không phải "GLPI có sẵn".

### 6.1. Rủi ro cụ thể

| # | Hành vi lạm dụng | Hậu quả |
|---|---|---|
| R1 | Bấm nộp phiếu liên tục (spam tốc độ) | Quá tải, hàng đợi rác |
| R2 | Nộp cùng một sự cố nhiều lần | Trùng lặp, phân công nhiều người vô ích |
| R3 | Nộp phiếu không có nội dung / vô nghĩa | Lãng phí thời gian 3 người kỹ thuật |
| R4 | Cố tình đẩy mức ưu tiên lên "rất cao" | Phá vỡ thứ tự xử lý công bằng |
| R5 | Tài khoản bị lộ, người ngoài nộp phiếu | Ô nhiễm dữ liệu |
| R6 | Bot nộp phiếu hàng loạt | Quá tải tài nguyên máy chủ |

### 6.2. Thiết kế cơ chế nhiều tầng

> **Trạng thái triển khai:** xem `tai-lieu/CHONG-LAM-DUNG.md` để biết tầng nào
> đã dựng thật (có bằng chứng chạy), tầng nào mới ở mức cấu hình.

| Tầng | Cơ chế | Chặn được | Trạng thái |
|---|---|---|---|
| **T1 — Mạng (Nginx)** | Rate limit theo IP cho endpoint nộp phiếu & form đăng nhập; `limit_req_status 429` | R1, R6 | 🟢 đã có cho đăng nhập; xem ghi chú mục 6.3 |
| **T2 — Phiên (GLPI)** | Yêu cầu đăng nhập để nộp phiếu (không có nộp ẩn danh) | R5 | 🟢 có sẵn |
| **T3 — Nghiệp vụ** | Trần số phiếu đang mở / người; chặn theo cửa sổ thời gian | R1, R2 | 🟡 đang triển khai |
| **T4 — Chống trùng** | Cảnh báo khi cùng người + cùng thiết bị + cùng loại sự cố trong cửa sổ ngắn | R2 | 🟡 đang triển khai |
| **T5 — Kiểm duyệt** | Phiếu mới mặc định vào trạng thái chờ kỹ thuật viên xác nhận trước khi giao việc | R3, R4 | 🟡 đang triển khai |
| **T6 — Nhật ký** | Ghi log IP + tài khoản + thời điểm cho mọi lần tạo phiếu | R5 | 🟢 có sẵn trong GLPI |

### 6.3. Ghi chú kỹ thuật quan trọng

**Nginx hiện chỉ rate-limit ở `/front/login.php` và `/index.php`** 🟢 (xem
`nginx/conf.d/default.conf`). Endpoint nộp phiếu `/front/ticket.form.php`
**chưa được giới hạn**. Đây chính là lỗ hổng hội đồng có thể chỉ ra — và đồ án
đang bổ sung. Chi tiết và bằng chứng sau khi sửa: `tai-lieu/CHONG-LAM-DUNG.md`.

**Vì sao không đặt rate limit quá chặt cho endpoint nghiệp vụ:** khuôn viên trường
dùng NAT chung → nhiều người học chung một IP ra ngoài. Nếu chặn theo IP quá gắt,
**một lớp học có thể bị chặn oan**. Vì vậy tầng mạng dùng ngưỡng rộng, còn tầng
nghiệp vụ mới là nơi siết theo **tài khoản** (chính xác hơn IP). Đây là quyết định
thiết kế có lý do, không phải bỏ sót.

---

## 7. NHỮNG ĐIỀU CHƯA CHỨNG MINH ĐƯỢC — ĐỌC TRƯỚC KHI TRÍCH DẪN

Đồ án ghi rõ để **không tuyên bố quá mức**:

| # | Điều chưa có dữ liệu | Loại |
|---|---|---|
| 1 | Số sự cố ITC thực tế tiếp nhận mỗi tuần | 🔴 GIẢ ĐỊNH |
| 2 | Thời gian phản hồi/xử lý trung bình hiện tại của ITC | 🔴 GIẢ ĐỊNH |
| 3 | Tỉ lệ sự cố xảy ra trong khoảng 16h30–7h30 hay cuối tuần | 🔴 GIẢ ĐỊNH |
| 4 | Số phòng máy thực tế của Trường | 🔴 GIẢ ĐỊNH (đồ án dùng 65 làm mẫu cấu trúc) |
| 5 | ITC đã đồng ý dùng hệ thống này chưa | 🔴 Chưa — đồ án chưa được phê duyệt |
| 6 | Mức SLA cụ thể mà Trường muốn áp dụng | 🔴 Chưa có văn bản nào |

👉 **Cách dùng số liệu trong mục 4:** phần 🟢 là sự thật kiểm chứng được, phần 🟡
là lập luận. Trình bày trước hội đồng nên nói *"từ dữ kiện công khai, đồ án suy ra
rằng..."* — không nói *"hệ thống của em đã giảm X% thời gian xử lý"* vì chưa đo.

**Hướng hoàn thiện để lấp các giả định 🔴:** phỏng vấn 5 nhân sự ITC (mục 2.2),
xin số liệu tiếp nhận thực tế, và đề nghị cắm thử hệ thống ở một phòng máy để đo.
Đây là việc cần làm nếu muốn biến đồ án từ "đề xuất" thành "đã triển khai".

---

## 8. NGUỒN THAM KHẢO

| # | Nội dung | URL | Truy cập |
|---|---|---|---|
| 1 | Trang chủ Trường — quy mô người học, CT đào tạo | https://dlu.edu.vn/ | 02/10/2026 |
| 2 | ITC — chức năng, nhiệm vụ, nhân sự | https://itc.dlu.edu.vn/gioi-thieu/ | 02/10/2026 |
| 3 | ITC — liên hệ, hotline, giờ làm việc | https://itc.dlu.edu.vn/lien-he/ | 02/10/2026 |
| 4 | ITC — trang chủ, phòng máy thực hành | https://itc.dlu.edu.vn/ | 02/10/2026 |
| 5 | Danh mục đơn vị Trường | https://dlu.edu.vn/cac-phong-khoa | 02/10/2026 |
