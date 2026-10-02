# CHỐNG LẠM DỤNG — "SINH VIÊN SPAM THÌ SAO?"

> **Tài liệu này trả lời trực tiếp câu hỏi phản biện của giảng viên hướng dẫn:**
> *"Nếu sinh viên spam thì sao? Cơ chế để sinh viên nộp ticket hiện tại là gì?"*
>
> **Ngày lập:** 02/10/2026 · Xem kèm `BAI-TOAN-NGHIEP-VU.md` mục 6.

---

## 0. TÓM TẮT — ĐỌC 30 GIÂY

**6 tầng, phòng thủ theo chiều sâu (defence in depth):**

```
   Người dùng
       │
       ▼
  ┌─────────────────────────────────────────────────┐
  │ T1  NGINX      rate limit theo IP (tốc độ)      │  ← chặn bot, bấm liên tục
  ├─────────────────────────────────────────────────┤
  │ T2  PHIÊN      bắt buộc đăng nhập để nộp        │  ← chặn người ngoài
  ├─────────────────────────────────────────────────┤
  │ T3  NGHIỆP VỤ  trần phiếu/người/ngày            │  ← chặn lạm dụng theo tài khoản
  ├─────────────────────────────────────────────────┤
  │ T4  CHỐNG TRÙNG cùng người+thiết bị+loại        │  ← chặn nộp lặp
  ├─────────────────────────────────────────────────┤
  │ T5  KIỂM DUYỆT  kỹ thuật viên xác nhận ưu tiên  │  ← chặn tự nâng khẩn cấp
  ├─────────────────────────────────────────────────┤
  │ T6  NHẬT KÝ     ghi ai, khi nào, từ đâu         │  ← truy vết, xử lý sau
  └─────────────────────────────────────────────────┘
```

**Trạng thái thật của từng tầng** — ghi rõ để không nói quá:

| Tầng | Cơ chế | Trạng thái | Bằng chứng |
|---|---|---|---|
| T1 | Rate limit endpoint nộp phiếu | ✅ **Đã dựng** | `nginx/nginx.conf`, `nginx/conf.d/default.conf` |
| T2 | Bắt buộc đăng nhập | ✅ Có sẵn của GLPI | Cấu hình vai trò trong `seed-du-lieu-mau.sql` |
| T3 | Trần phiếu mở / ngày | ✅ **Đã dựng** (bảng + script kiểm) | `scripts/seed-sla-va-chong-lam-dung.sql`, `scripts/kiem-tra-lam-dung.sh` |
| T4 | Phát hiện trùng | ✅ **Đã dựng** (phát hiện + báo cáo) | `scripts/kiem-tra-lam-dung.sh` mục 2 |
| T5 | Kiểm duyệt trước khi giao | 🟡 **Cấu hình GLPI** — không phải mã | Xem mục 5 |
| T6 | Nhật ký | ✅ **Đã dựng** (bảng riêng) | `glpi_plugin_pinedesk_ticketlog` |

---

## 1. CƠ CHẾ NỘP TICKET HIỆN TẠI LÀ GÌ?

### 1.1. Ai nộp được

| Vai trò | Tài khoản demo | Nộp phiếu | Xem phiếu của ai |
|---|---|---|---|
| Sinh viên | `sv.hoa`, `sv.khanh` | ✅ | Chỉ của mình |
| Giảng viên | `gv.cuong`, `gv.dung` | ✅ | Chỉ của mình |
| Kỹ thuật viên | `ktv.an`, `ktv.binh` | ✅ | Của nhóm phụ trách |
| Quản trị | `glpi` | ✅ | Toàn bộ |

**Điểm quan trọng:** 🟢 **KHÔNG có nộp phiếu ẩn danh.** Muốn nộp phải đăng nhập
trước → mọi phiếu đều truy vết được về một tài khoản. Đây là tầng T2 và là nền
tảng cho mọi tầng phía sau (không có danh tính thì không đếm được theo tài khoản).

### 1.2. Luồng nộp

```
Người dùng đăng nhập
   → menu "Hỗ trợ" → "Tạo phiếu"
   → điền: tiêu đề, mô tả, loại sự cố, thiết bị liên quan, mức ưu tiên
   → bấm "Lưu"
   → nginx (T1 kiểm tốc độ) → GLPI (T2 kiểm đăng nhập)
   → phiếu vào hàng đợi trạng thái "Mới" (1)
   → kỹ thuật viên thấy trong "Phiếu yêu cầu" → giao việc (T5)
```

**Bằng chứng ảnh:** `tai-lieu/anh-giao-dien/05-tao-phieu-moi.png`,
`tai-lieu/anh-giao-dien/04-danh-sach-phieu-yeu-cau.png`.

### 1.3. Vì sao cần ≥6 tầng mà không chỉ 1 tầng?

Mỗi tầng chặn một **kiểu tấn công khác nhau**, không tầng nào chặn hết:

| Nếu chỉ có | Thì thủng ở đâu |
|---|---|
| Chỉ rate limit theo IP | Trường dùng NAT chung → một phòng 40 máy chung 1 IP → chặn oan cả lớp |
| Chỉ đếm theo tài khoản | Kẻ tấn công tạo nhiều tài khoản (nếu cho tự đăng ký) |
| Chỉ chống trùng | Không chặn được spam nội dung khác nhau |
| Chỉ nhật ký | Ghi lại mà không cản → chỉ xử lý được sau khi đã bị |

---

## 2. TẦNG T1 — RATE LIMIT Ở NGINX

### 2.1. Vấn đề gốc (lỗ hổng đã bị chỉ ra)

Bản đầu của đồ án **chỉ rate-limit ở `/front/login.php` và `/index.php`**.
Endpoint **tạo phiếu `/front/ticket.form.php` không bị giới hạn gì** → một tài
khoản bấm "Lưu" liên tục có thể tạo hàng trăm phiếu rác, làm ngập hàng đợi của
3 kỹ thuật viên. **Đây là lỗ hổng thật.**

### 2.2. Cách khắc phục

**`nginx/nginx.conf`** — thêm một zone riêng:

```nginx
# ticket_zone: 30 request/phút cho MỖI IP, chỉ áp cho endpoint nghiệp vụ
limit_req_zone $binary_remote_addr zone=ticket_zone:10m rate=30r/m;
```

**`nginx/conf.d/default.conf`** — áp cho endpoint tạo/sửa phiếu và API:

```nginx
location ~* /front/ticket\.form\.php$ {
    limit_req zone=ticket_zone burst=10 nodelay;
    limit_req_status 429;          # vượt ngưỡng trả 429, không phải 503
    proxy_pass http://glpi:80;
    ...
}
```

### 2.3. Vì sao chọn 30 request/phút, không chặt hơn?

**Đây là quyết định thiết kế quan trọng nhất của cả tài liệu này.**

- Khuôn viên trường dùng **NAT chung**: cả phòng máy 35–40 máy đi ra Internet
  bằng **một địa chỉ IP** 🟡.
- Nếu đặt ngưỡng theo IP quá thấp (ví dụ 5 request/phút), **một lớp học đang thao
  tác có thể bị chặn oan** — sinh viên thứ 6 trong phòng bấm lưu sẽ bị 429 dù họ
  hoàn toàn hợp lệ.
- Vì vậy tầng mạng giữ ngưỡng **rộng có chủ đích**, và **tầng nghiệp vụ (T3) mới
  là nơi siết chính xác theo tài khoản** — vì tài khoản không bị NAT.

👉 Nếu hội đồng hỏi *"sao không chặn chặt hơn?"* — câu trả lời là: **chặn chặt
theo IP là sai thiết kế trong môi trường có NAT**, không phải là bỏ sót.

### 2.4. `burst=10 nodelay` nghĩa là gì?

- **burst=10**: cho phép 10 request vượt ngưỡng xếp hàng chờ, xử lý ngay.
- **nodelay**: các request trong cửa sổ burst được phục vụ **ngay**, không bị trễ.
- Nhờ vậy thao tác bình thường (tạo 1 phiếu = 1–2 request, có thể kèm đính kèm)
  **không hề bị ảnh hưởng**; chỉ khi vượt hẳn mới bị chặn.

---

## 3. TẦNG T3 + T4 — HẠN MỨC VÀ CHỐNG TRÙNG THEO TÀI KHOẢN

### 3.1. Cấu trúc dữ liệu (nằm NGOÀI lõi GLPI)

**`scripts/seed-sla-va-chong-lam-dung.sql`** tạo 2 bảng + 1 view:

| Đối tượng | Vai trò |
|---|---|
| `glpi_plugin_pinedesk_limits` | Cấu hình hạn mức (sửa được, không hardcode trong mã) |
| `glpi_plugin_pinedesk_ticketlog` | Nhật ký tạo phiếu + vi phạm |
| `v_pinedesk_phieu_dang_mo` | View đếm nhanh số phiếu đang mở mỗi người |

**Hạn mức mặc định** (lấy từ bảng, không phải hằng số trong mã):

| Tham số | Giá trị | Ý nghĩa |
|---|---|---|
| `so_phieu_mo_toi_da` | **5** | Một người tối đa 5 phiếu đang mở cùng lúc |
| `so_phieu_ngay_toi_da` | **10** | Tối đa 10 phiếu/ngày mỗi người |
| `cua_so_trung_phut` | **30** | Cửa sổ phát hiện trùng lặp |

> **Vì sao 5 và 10?** Đây là **đề xuất kỹ thuật của đồ án** 🟡, dựa trên lập luận:
> một người học bình thường hiếm khi có quá 2–3 sự cố đang chờ xử lý cùng lúc.
> Con số này **cần được Trung tâm CNTT (ITC) xác nhận** trước khi dùng thật.
> Vì là dữ liệu trong bảng, chỉnh sửa chỉ cần một câu UPDATE — không phải sửa mã.

### 3.2. Cách kiểm tra

**`scripts/kiem-tra-lam-dung.sh`** làm 3 việc, in ra báo cáo:

| # | Kiểm gì | Ngưỡng |
|---|---|---|
| 1 | Tài khoản vượt hạn mức **phiếu đang mở** | > 5 phiếu |
| 2 | **Phiếu trùng** (cùng người + cùng loại + cùng vị trí, cùng phút) | ≥ 2 phiếu |
| 3 | **Nộp quá nhanh** (nhiều phiếu trong cùng một phút) | > 2 phiếu/phút |

Cách dùng:
```bash
bash scripts/kiem-tra-lam-dung.sh              # chỉ báo cáo
bash scripts/kiem-tra-lam-dung.sh --thuc-thi   # báo cáo + ghi nhật ký vi phạm
```

### 3.3. Quyết định thiết kế: KHÔNG tự xoá phiếu

Script **chỉ báo cáo**, không tự động xoá hay chặn phiếu. Lý do:

- Xoá tự động có thể **xoá nhầm phiếu thật** của người dùng hợp lệ;
- Việc "phiếu này có lạm dụng hay không" cần **phán đoán của con người**;
- Nhật ký để lại bằng chứng, kỹ thuật viên xem rồi quyết định xử lý.

👉 Đây là nguyên tắc thiết kế có chủ đích: **hệ thống hỗ trợ con người ra quyết
định, không thay con người ra quyết định trong việc xoá dữ liệu.**

---

## 4. TẦNG T6 — NHẬT KÝ

Bảng `glpi_plugin_pinedesk_ticketlog` ghi:

| Cột | Ý nghĩa |
|---|---|
| `users_id` | Ai tạo |
| `tickets_id` | Phiếu nào |
| `ip_address` | Từ IP nào (nếu lấy được qua `X-Forwarded-For`) |
| `tickets_id_dup` | Trùng với phiếu nào |
| `reason` | `NEW` (bình thường) / `DUP_BLOCKED` / `LIMIT_BLOCKED` |
| `date_creation` | Khi nào |

**Vì sao không dùng log sẵn có của GLPI:** log của GLPI ghi chung nhiều loại
hành động, truy vấn đếm theo tài khoản sẽ chậm. Bảng riêng chỉ ghi **một việc**:
ai tạo phiếu, khi nào, có trùng không → truy vấn nhanh, ý nghĩa rõ.

---

## 5. TẦNG T5 — KIỂM DUYỆT TRƯỚC KHI GIAO VIỆC

### 5.1. Vấn đề

Nếu để người yêu cầu tự chọn mức ưu tiên và nó có hiệu lực ngay, thì **ai cũng sẽ
chọn "Rất cao"** — phá vỡ thứ tự xử lý công bằng. Đây là rủi ro R4.

### 5.2. Cách xử lý

Phiếu mới vào trạng thái **"Mới" (1)** và cần kỹ thuật viên **xác nhận mức ưu
tiên** trước khi chuyển sang **"Được giao" (2)**. Nói cách khác: **mức ưu tiên do
người yêu cầu đề xuất, nhưng do kỹ thuật viên quyết định.**

### 5.3. Trạng thái triển khai — TRUNG THỰC

Tầng này **chưa được tự động hoá bằng mã** 🟡. Nó hiện dựa trên **quy trình vận
hành** (kỹ thuật viên tự soát khi giao việc) và có thể siết bằng **quy tắc nghiệp
vụ (business rules)** của GLPI cấu hình qua giao diện.

**Lý do không viết mã cho tầng này:** muốn tự động chặn thì phải móc vào sự kiện
tạo phiếu của GLPI → phải viết plugin sửa vào luồng lõi → **mất tính "tùy biến
ngoài lõi"** (mục tiêu cốt lõi của đồ án, xem `SO-SANH-VOI-GLPI-GOC.md`). Đồ án
chọn **giữ kiến trúc sạch** thay vì chặn tự động. Đây là **đánh đổi có ý thức**.

---

## 6. SLA THẬT — TỪ TUYÊN BỐ SUÔNG THÀNH DỮ LIỆU

### 6.1. Vấn đề đã tồn tại

README và `SO-SANH-VOI-GLPI-GOC.md` ghi hệ thống có **"cam kết SLA"**, nhưng khi
kiểm tra CSDL thì **KHÔNG có bản ghi `glpi_slas` nào**. Đây là **tuyên bố suông**
— đúng loại mà hội đồng bắt lỗi.

### 6.2. Đã khắc phục

`scripts/seed-sla-va-chong-lam-dung.sql` tạo **5 định nghĩa SLA thật** khớp 5 mức
ưu tiên, mỗi SLA có **2 mốc** (TTO = thời gian phản hồi, TTR = thời gian giải quyết):

| Mức ưu tiên | Phản hồi | Giải quyết | Dùng cho |
|---|---|---|---|
| Rất thấp (P1) | 8 giờ | 48 giờ | Sự cố không gấp |
| Thấp (P2) | 4 giờ | 24 giờ | Ảnh hưởng 1 người |
| Trung bình (P3) | 2 giờ | 8 giờ | Ảnh hưởng 1 lớp học |
| Cao (P4) | 1 giờ | 4 giờ | Nhiều lớp / thiết bị mạng |
| Rất cao (P5) | 30 phút | 2 giờ | Máy chủ / hạ tầng |

### 6.3. GHI CHÚ TRUNG THỰC BẮT BUỘC

> ⚠️ **Các con số trên là ĐỀ XUẤT KỸ THUẬT của đồ án, KHÔNG phải cam kết đã được
> Trường Đại học Đà Lạt ban hành.** Muốn trở thành SLA thật phải có **văn bản phê
> duyệt của Trung tâm CNTT (ITC)**. Trước khi có văn bản đó, phải gọi là **"mức
> thời gian đề xuất"**, không được gọi là "cam kết dịch vụ".

---

## 7. NHỮNG GÌ CÒN THIẾU — NÓI THẲNG

| # | Còn thiếu | Mức độ |
|---|---|---|
| 1 | T5 (kiểm duyệt) chưa tự động hoá bằng mã | 🟡 quy trình |
| 2 | Chưa đo được hiệu năng khi tải cao (5.000 người cùng lúc) | 🔴 chưa kiểm thử |
| 3 | Hạn mức 5 phiếu / 10 phiếu/ngày chưa được ITC xác nhận | 🔴 đề xuất |
| 4 | Chưa dựng tài khoản tự đăng ký → chưa phải lo chống tạo tài khoản ảo | 🔴 phạm vi |
| 5 | Nhật ký chưa có giao diện xem cho kỹ thuật viên (hiện xem bằng SQL) | 🟡 tiện ích |
| 6 | Chưa có CAPTCHA cho trường hợp mở nộp ẩn danh qua QR | 🔴 phạm vi |

**Điểm 4 và 6 là do quyết định phạm vi:** đồ án **không cho tự đăng ký** và
**không cho nộp ẩn danh** → hai rủi ro đó bị loại bỏ ở gốc thay vì phải chống.
Đây là **giảm thiểu rủi ro bằng thiết kế (mitigation by design)**, mạnh hơn là
chống đỡ sau khi đã cho phép.

---

## 8. BẢNG TRA NHANH KHI BỊ HỎI

| Câu hỏi | Mở file | Nói gì |
|---|---|---|
| "Sinh viên spam thì sao?" | tài liệu này + `nginx/conf.d/default.conf` | 6 tầng, T1/T3/T4/T6 đã dựng |
| "Sao chặn theo IP, không theo tài khoản?" | mục 2.3 | NAT chung cả phòng → chặn IP là chặn oan |
| "Đã kiểm thử chưa?" | `scripts/kiem-tra-lam-dung.sh` | Có script kiểm + CI |
| "SLA là gì, ai ban hành?" | mục 6.3 | Đề xuất kỹ thuật, chưa được Trường ban hành |
| "Còn thiếu gì?" | mục 7 | 6 điểm, nói thẳng |
