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
| T1 | Rate limit mọi đường nộp phiếu | ✅ **Đã dựng** | `nginx/nginx.conf`, `nginx/conf.d/default.conf` |
| T2 | Bắt buộc đăng nhập | ✅ Có sẵn của GLPI | Cấu hình vai trò trong `seed-du-lieu-mau.sql` |
| T3 | Trần phiếu mở / ngày | ✅ **Đã dựng, CHẶN thật khi tạo phiếu** | `plugins/pinedesk/hook.php` (T3a/T3b), `plugins/pinedesk/tests/kiem-thu-han-muc.php` |
| T4 | Chặn phiếu trùng | ✅ **Đã dựng, CHẶN thật khi tạo phiếu** | `plugins/pinedesk/hook.php` (T4) |
| T5 | Kiểm duyệt trước khi giao | 🟡 **Cấu hình GLPI** — không phải mã | Xem mục 5 |
| T6 | Nhật ký mọi lần tạo phiếu (kể cả lần bị chặn) | ✅ **Đã dựng** (plugin ghi tự động) | `plugins/pinedesk/hook.php`, bảng `glpi_plugin_pinedesk_ticketlog` |

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

**`nginx/conf.d/default.conf`** — zone `ticket_zone` áp cho MỌI đường nộp phiếu,
cả đường truyền thống lẫn đường biểu mẫu mới của GLPI 11:

| Đường nộp phiếu | Ghi chú |
|---|---|
| `/front/(ticket\|problem\|change).form.php` | Đường truyền thống (tạo/sửa phiếu, vấn đề, thay đổi) |
| `/Form/SubmitAnswers` | Biểu mẫu Service Catalog của GLPI 11 (sinh viên/giảng viên dùng đường này) |
| `/Form/ValidateAnswers` | Kiểm tra dữ liệu biểu mẫu khi chuyển mục hoặc bấm Gửi |
| `/apirest.php`, `/api.php` | API REST (mặc định tắt, giới hạn sẵn để khi bật không hở) |

```nginx
location ~* ^/Form/(SubmitAnswers|ValidateAnswers)(/|$) {
    limit_req zone=ticket_zone burst=10 nodelay;
    limit_req_status 429;          # vượt ngưỡng trả 429, không phải 503
    proxy_pass http://glpi:80;
    ...
}
```

> **Lỗ hổng đã sửa (phát hiện khi phản biện):** trước đây location chỉ khớp
> `/front/ticket.form.php`, còn đường biểu mẫu `/Form/SubmitAnswers` rơi vào
> `general_zone` (600 request/phút, burst 200), yếu hơn khoảng 20 lần so với
> thiết kế. Đã đo trên hệ thống đang chạy: 12 POST liên tiếp vào
> `/Form/SubmitAnswers` cho 0 lần 429. Sau khi thêm location, cùng phép đo cho
> 429 ngay ở request thứ 12, khớp với đường `/front/ticket.form.php`.
> Các neo `(/|$)` cũng chặn luôn đường lách thêm hậu tố (`/Form/SubmitAnswers/x`).

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

### 3.2. Thực thi thật — chặn ngay khi tạo phiếu (`plugins/pinedesk`)

Bảng cấu hình chỉ là dữ liệu; thứ **thực sự chặn** là plugin `pinedesk`. Plugin
dùng hook công khai `PRE_ITEM_ADD` của GLPI, kiểm tra trước khi phiếu được ghi
và huỷ thao tác nếu vi phạm, **không sửa một dòng nào trong lõi GLPI**.

| Cơ chế | Cách hoạt động |
|---|---|
| **T3a — trần phiếu mở** | Đếm phiếu trạng thái 1–4 của người nộp; chạm trần (mặc định 5) thì chặn |
| **T3b — trần phiếu/ngày** | Đếm phiếu tạo từ 0h hôm nay; chạm trần (mặc định 10) thì chặn |
| **T4 — chống trùng** | Cùng người + cùng thiết bị, hoặc cùng loại sự cố + cùng vị trí, trong cửa sổ 30 phút, phiếu cũ chưa đóng → chặn, chỉ luôn sang phiếu cũ |
| **T6 — nhật ký** | Ghi **mọi** lần tạo phiếu, kể cả lần bị chặn (`reason = LIMIT_BLOCKED` / `DUP_BLOCKED`) |

**Ai bị áp dụng:** chỉ tài khoản Self-Service (sinh viên, giảng viên). Kỹ thuật
viên và quản trị có quyền cập nhật phiếu được miễn trừ, phiếu do cron sinh
(bảo trì định kỳ) cũng được miễn trừ.

**Chống đua (race):** nhiều tab cùng bấm Lưu một lúc vẫn không lách được: plugin
dùng khoá `GET_LOCK` của MariaDB theo từng tài khoản.

**Khi lỗi thì mở, không chặn oan:** nếu truy vấn đếm gặp lỗi, plugin cho phiếu
đi qua và ghi lỗi vào log riêng (`pinedesk.log`), ưu tiên không chặn nhầm người
dùng hợp lệ.

**Kiểm thử:** `plugins/pinedesk/tests/kiem-thu-han-muc.php` chạy trên CSDL thật,
37 điểm kiểm (tạo đủ 5 phiếu thành công, phiếu thứ 6 bị chặn, phiếu trùng bị
chặn, kỹ thuật viên không bị chặn, cron không bị chặn, nhật ký đúng), tự dọn dẹp
sau khi chạy. CI chạy harness này trong job `smoke`.

### 3.3. Cách kiểm tra định kỳ (báo cáo)

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

### 3.4. Quyết định thiết kế: chặn lúc tạo, KHÔNG tự xoá phiếu sau

Plugin **chặn ngay lúc tạo** (phiếu vi phạm không bao giờ vào CSDL), nhưng không
có cơ chế nào **tự xoá phiếu đã tồn tại**. Lý do:

- Xoá tự động có thể **xoá nhầm phiếu thật** của người dùng hợp lệ;
- Việc "phiếu này có lạm dụng hay không" cần **phán đoán của con người**;
- Nhật ký để lại bằng chứng, kỹ thuật viên xem rồi quyết định xử lý.

👉 Đây là nguyên tắc thiết kế có chủ đích: **hệ thống hỗ trợ con người ra quyết
định, không thay con người ra quyết định trong việc xoá dữ liệu.** Script
`kiem-tra-lam-dung.sh` vẫn giữ vai trò rà soát định kỳ: nó báo cáo các trường
hợp đáng ngờ (kể cả phiếu lọt qua trước khi plugin bật) để kỹ thuật viên xem xét.

---

## 4. TẦNG T6 — NHẬT KÝ

Bảng `glpi_plugin_pinedesk_ticketlog` ghi:

| Cột | Ý nghĩa |
|---|---|
| `users_id` | Ai tạo |
| `tickets_id` | Phiếu nào |
| `ip_address` | Từ IP nào: nginx đã ghi đè `X-Forwarded-For` bằng IP thật của kết nối nên giá trị giả từ client bị loại bỏ |
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

**Lý do không viết mã cho tầng này:** T3/T4 chỉ cần đếm và so khớp dữ liệu, nên
cưỡng chế được bằng máy. T5 là phán đoán: cùng một mức "Rất cao" có thể chính
đáng (sự cố phòng thi, máy chủ hỏng) hoặc lạm dụng, máy không phân biệt được.
Phiếu mới vẫn nằm ở trạng thái "Mới" chờ kỹ thuật viên xem xét trước khi giao
việc: bước kiểm duyệt có thật, chỉ là không có mã cưỡng chế.

**Ghi chú đính chính:** bản trước của tài liệu này viết "muốn tự động hoá T5 thì
phải móc vào lõi GLPI". Điều đó **không đúng**: plugin `pinedesk` đã chứng minh
hook công khai `PRE_ITEM_ADD` can thiệp được vào lúc tạo phiếu mà không sửa lõi.
Về kỹ thuật, tự động hoá T5 là khả thi; đồ án để lại như hướng phát triển vì cần
chính sách mức ưu tiên do ITC ban hành trước khi máy tự quyết thay con người.

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
| "Sinh viên spam thì sao?" | tài liệu này + `plugins/pinedesk/` | 6 tầng; T1/T3/T4/T6 đã dựng thật, chỉ T5 còn ở mức quy trình |
| "Sao chặn theo IP, không theo tài khoản?" | mục 2.3 | NAT chung cả phòng → chặn IP là chặn oan |
| "Đã kiểm thử chưa?" | `plugins/pinedesk/tests/kiem-thu-han-muc.php` | Harness 37 điểm kiểm, CI chạy trong job `smoke` |
| "SLA là gì, ai ban hành?" | mục 6.3 | Đề xuất kỹ thuật, chưa được Trường ban hành |
| "Còn thiếu gì?" | mục 7 | 6 điểm, nói thẳng |
