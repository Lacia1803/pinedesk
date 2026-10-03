# BỘ CÂU HỎI PHẢN BIỆN & CÁCH TRẢ LỜI

> **Mục đích:** luyện tập trước hội đồng. Mỗi câu gồm *ý chính cần nói* (1–2 câu,
> nói ra miệng được) và *bằng chứng trong repo* để khi bị hỏi sâu thì mở ra.
>
> **Nguyên tắc trả lời:**
> 1. **Thừa nhận trước, biện luận sau.** Câu nào chưa làm được thì nói thẳng
>    "phần này em chưa làm" rồi nêu hướng — đừng chống đỡ.
> 2. **Có số liệu thì nói số liệu, không có thì nói "em chưa đo được".**
> 3. **Mỗi tuyên bố phải mở ra được một file trong máy.**
>
> **Ngày lập:** 02/10/2026 · Xem kèm `BAI-TOAN-NGHIEP-VU.md`.

---

## NHÓM A — BÀI TOÁN & NHU CẦU THỰC TẾ (5 câu)

### A1. "Đồ án này giải quyết nhu cầu gì của trường?"

> **Trả lời:** Trung tâm Công nghệ thông tin (ITC) có **5 nhân sự** nhưng phải
> phục vụ **14.500+ người học**, và kênh tiếp nhận chỉ mở **7h30–16h30 thứ 2–6**.
> Nghĩa là 73% thời gian trong tuần không có kênh tiếp nhận sự cố. PineDesk mở
> kênh nộp 24/7 có cấu trúc, tự phân công và có theo dõi trạng thái — thay vì dựa
> vào gọi điện cho 3 người.

**Bằng chứng:** `tai-lieu/BAI-TOAN-NGHIEP-VU.md` mục 1 & 4.
Nguồn: `itc.dlu.edu.vn/gioi-thieu/` (5 nhân sự), `dlu.edu.vn` (14.500+).

**Nếu bị hỏi ngược "em đo được điều đó chưa?"** → Thừa nhận: *"Ba số liệu trên là
dữ kiện công khai từ website trường, có ghi nguồn. Còn số sự cố thực tế mỗi tuần
thì em chưa có — em ghi rõ trong tài liệu là giả định chưa kiểm chứng."*

### A2. "Thực tế trường đang nhận sự cố bằng cách nào?"

> **Trả lời:** Theo công bố chính thức, ITC có **một hotline, một email, một form
> liên hệ** và **không công bố** hệ thống ticket nào. Tức là kênh phi cấu trúc:
> dễ thất lạc, không đo được, không truy vết.

**Bằng chứng:** `BAI-TOAN-NGHIEP-VU.md` mục 2.3, 4.3. Nguồn:
`itc.dlu.edu.vn/lien-he/`.

⚠️ **Cẩn thận:** đây là *suy luận từ công bố công khai*. Nếu trường thực ra có hệ
thống nội bộ không công bố, câu trả lời phải là *"theo những gì công bố công khai
thì..."* — đừng khẳng định chắc.

### A3. "Ai là người dùng thật? Sinh viên có dùng không?"

> **Trả lời:** Ba nhóm, đúng theo nghiệp vụ:
> - **Sinh viên** — người báo sự cố tại phòng máy (Self-Service);
> - **Giảng viên** — báo sự cố trong tiết dạy + mượn/trả thiết bị;
> - **Kỹ thuật viên ITC + lãnh đạo** — nhận việc, theo dõi, xem thống kê.
>
> Đồ án đã tạo đủ 6 tài khoản cho 3 vai trò để chứng minh.

**Bằng chứng:** `scripts/seed-du-lieu-mau.sql` (tài khoản `sv.hoa`, `sv.khanh`,
`gv.cuong`, `gv.dung`, `ktv.an`, `ktv.binh`).

### A4. "Em đã nói chuyện với ITC chưa? Họ có cần không?"

> **Trả lời thẳng:** *"Dạ chưa. Đồ án chưa được ITC phê duyệt. Em thu thập thông
> tin từ trang công khai của Trung tâm, và ghi rõ trong tài liệu đây là đề xuất,
> chưa phải hệ thống đã được đưa vào dùng."*

⚠️ **Đây là điểm yếu thật — đừng chống đỡ.** Nhưng nếu bạn có thể phỏng vấn 5 nhân
sự ITC trước buổi bảo vệ thì đây là **điểm cộng rất lớn**. Xem mục 7 của
`BAI-TOAN-NGHIEP-VU.md` để biết cần hỏi gì.

### A5. "Nhu cầu này có thật không hay em tự nghĩ ra?"

> **Trả lời:** Ba dữ kiện (14.500+ người học · 5 nhân sự · 7h30–16h30 T2–6) đều
> công khai, có ghi nguồn và ngày truy cập. Phần *suy luận* được đánh dấu 🟡,
> phần *giả định* đánh dấu 🔴 trong tài liệu. Em không trộn lẫn hai loại.

---

## NHÓM B — CHỐNG LẠM DỤNG (5 câu) ⭐ HỘI ĐỒNG KHOAN SÂU NHẤT

### B1. "Sinh viên spam nộp phiếu thì sao?"

> **Trả lời:** Em thiết kế 6 tầng, nhưng phải nói thẳng trạng thái:
> - 🟢 **Đã có:** rate limit đăng nhập (Nginx), bắt buộc đăng nhập mới nộp được
>   (GLPI), nhật ký hành động;
> - 🟡 **Đang bổ sung:** rate limit cho endpoint nộp phiếu; trần số phiếu đang mở
>   mỗi người; chống trùng; kiểm duyệt trước khi giao việc.
>
> **Cách trình diễn:** bấm nộp liên tục → nhận **HTTP 429**; đó là bằng chứng
> sống, không phải lời nói.

**Bằng chứng:** `tai-lieu/CHONG-LAM-DUNG.md`, `nginx/conf.d/default.conf`.

### B2. "Tại sao rate limit đặt theo IP mà không theo tài khoản?"

> **Trả lời:** Vì **khuôn viên trường dùng NAT chung** — cả phòng máy ra ngoài bằng
> một IP. Nếu chặn theo IP quá chặt, **một lớp 40 sinh viên có thể bị chặn oan**.
> Nên tầng mạng để ngưỡng rộng, còn siết chính xác theo **tài khoản** ở tầng
> nghiệp vụ. Đây là quyết định có lý do, không phải bỏ sót.

**Đây là câu trả lời rất mạnh — nó cho thấy bạn hiểu môi trường thật của trường.**

### B3. "Nếu sinh viên nộp trùng cùng một sự cố 5 lần?"

> **Trả lời:** Cơ chế chống trùng dựa trên bộ ba (người yêu cầu + thiết bị + loại
> sự cố) trong một cửa sổ thời gian; nếu trùng thì gom vào phiếu đang mở thay vì
> tạo phiếu mới. Trạng thái: 🟡 đang triển khai.

### B4. "Nếu kẻ xấu dùng bot nộp hàng loạt?"

> **Trả lời:** Bot phải vượt qua bước đăng nhập trước, và bước đăng nhập đã bị
> giới hạn 10 request/phút mỗi IP với `limit_req_status 429`. Endpoint nộp phiếu
> đang được thêm giới hạn tương tự. Ngoài ra mọi lần tạo phiếu đều ghi log IP +
> tài khoản để truy vết sau.

**Bằng chứng:** `nginx/nginx.conf` (khai báo `login_zone`), `nginx/conf.d/default.conf`.

### B5. "Cơ chế này em đã kiểm thử chưa?"

> **Trả lời — trung thực:** phần đã bật thì có kiểm chứng (rate limit đăng nhập
> được test trong CI); phần đang bổ sung thì có kịch bản kiểm thử tự động.
> Em không nói "đã chống spam hoàn hảo" — em nói "đã có tầng, có kiểm thử, có
> nhật ký để cải thiện tiếp".

**Bằng chứng:** `.github/workflows/ci.yml` (job `smoke` + hygiene).

---

## NHÓM C — QUY TRÌNH NGHIỆP VỤ (5 câu)

### C1. "Quy trình xử lý phiếu từ lúc nhận đến lúc đóng thế nào?"

> **Trả lời:** Chuẩn ITIL: Mới (1) → Được giao (2) → Đã giải quyết (5) → Đã đóng
> (6), có thể Chờ / Đã lên kế hoạch ở giữa. Kèm người yêu cầu, kỹ thuật viên phụ
> trách, thiết bị liên quan và nhật ký theo dõi.

**Bằng chứng:** `tai-lieu/anh-giao-dien/04-danh-sach-phieu-yeu-cau.png`,
`scripts/seed-du-lieu-mau.sql` (13 phiếu trải đủ trạng thái).

### C2. "Mức ưu tiên do ai quyết? Sinh viên tự chọn 'khẩn cấp' hết thì sao?"

> **Trả lời:** Đây là rủi ro thật (R4 trong tài liệu). Cơ chế: phiếu mới vào hàng
> đợi để kỹ thuật viên **xác nhận mức ưu tiên** trước khi giao việc, chứ không để
> người yêu cầu tự quyết định thứ tự xử lý. Trạng thái: 🟡 đang triển khai.

**Bằng chứng:** `BAI-TOAN-NGHIEP-VU.md` mục 6.1 (R4), 6.2 (T5).

### C3. "SLA là gì? Ai ban hành?"

> **Trả lời thẳng:** SLA trong hệ thống là **cấu hình kỹ thuật** (hạn phản hồi /
> hạn giải quyết theo mức ưu tiên), **chưa phải cam kết đã được Trường ban hành**.
> Em không gọi nó là "cam kết dịch vụ" nếu chưa có văn bản.

⚠️ **Đây là chỗ đồ án từng nói quá** ("cam kết SLA" ở README) trong khi CSDL chưa
có bản ghi SLA nào. Đã được sửa — xem mục 2 của `SO-SANH-VOI-GLPI-GOC.md` sau khi
cập nhật.

### C4. "Ticket đã đóng mà sinh viên nói chưa sửa xong thì sao?"

> **Trả lời:** Mở lại phiếu (reopen) — GLPI có sẵn trạng thái và nhật ký, người
> dùng không phải tạo phiếu mới. Việc mở lại cũng ghi vào lịch sử để thấy chất
> lượng xử lý.

### C5. "Kỹ thuật viên nghỉ phép, phiếu gán vào người vắng mặt?"

> **Trả lời:** Phiếu gán theo **nhóm** (nhóm kỹ thuật) trước, cá nhân nhận sau —
> nên nếu một người vắng, người khác trong nhóm vẫn nhận được. Đây là lý do đồ án
> dùng nhóm thay vì gán thẳng từng người.

**Bằng chứng:** `scripts/seed-du-lieu-nen.sql` (cây nhóm theo khoa/phòng/trung tâm).

---

## NHÓM D — SO SÁNH & LỰA CHỌN CÔNG NGHỆ (5 câu)

### D1. "Sao không dùng Google Form + Excel cho nhanh?"

> **Trả lời:** Form phù hợp để *thu thập*, không đủ để *vận hành*. Không phân
> công, không trạng thái, không SLA, không kiểm soát ai xem được gì, không liên
> kết phiếu với thiết bị, không có nhật ký. Với 5 nhân sự phục vụ 14.500+ người,
> đọc Excel thủ công không mở rộng nổi.

**Bằng chứng:** `BAI-TOAN-NGHIEP-VU.md` mục 5.1 (bảng 10 tiêu chí).

### D2. "GLPI có sẵn hết rồi, em làm được gì?"

> **Trả lời:** GLPI cho em **lõi nghiệp vụ** (ticket, asset, SLA) — em không viết
> lại. Việc của em: Việt hoá (541 thuật ngữ + 212 mục), giao diện Đà Lạt, dữ liệu
> nghiệp vụ DLU, hạ tầng 4 container + HTTPS + bảo mật, chống lạm dụng, CI, tài
> liệu, và **cài bằng một lệnh**. Toàn bộ nằm ngoài lõi → nâng cấp GLPI không mất.

**Bằng chứng:** `tai-lieu/SO-SANH-VOI-GLPI-GOC.md` mục 1 (bảng đối chiếu 20 dòng).

### D3. "Sao không mua ServiceNow / dùng iTop?"

> **Trả lời:** ServiceNow vượt ngân sách một trường công cho đồ án nội bộ; iTop
> cũng phải Việt hoá + cấu hình + dựng dữ liệu y như vậy nhưng cộng đồng nhỏ hơn.
> Chọn GLPI vì nó là *nguyên liệu thô* đúng thứ đồ án cần chứng minh.

**Bằng chứng:** `BAI-TOAN-NGHIEP-VU.md` mục 5.3.

### D4. "Nếu GLPI ra bản mới thì công em đổ sông đổ biển hết?"

> **Trả lời:** Không — đây là **điểm mạnh nhất của kiến trúc**. Tùy biến nằm ở
> plugin (`dlubrand`), cấu hình (`config/`, `nginx/`), script và dữ liệu — **không
> sửa một dòng nào trong lõi GLPI**. Nâng cấp chỉ việc đổi image.

**Bằng chứng:** `SO-SANH-VOI-GLPI-GOC.md` mục 3.3, `plugins/dlubrand/`.

### D5. "Làm sao chứng minh em không sửa lõi?"

> **Trả lời:** GLPI giữ nguyên trong Docker image chính thức; mọi thứ của đồ án
> nằm ở file của repo (xem cây thư mục trong README) — không có file nào nằm
> trong đường dẫn `src/` của GLPI.

---

## NHÓM E — BẢO MẬT, VẬN HÀNH & CÂU HỎI BẪY (5 câu)

### E1. "Mật khẩu admin của em là gì? Có lộ không?"

> **Trả lời:** Mật khẩu **không nằm trong mã nguồn**. Script đọc từ biến môi
> trường `GLPI_PASS` / `.env` (đã loại khỏi Git). CI có job quét bí mật theo *hình
> dạng* để bắt mật khẩu lộ.

**Bằng chứng:** `.github/workflows/ci.yml` job `hygiene`, `scripts/quet-bi-mat.sh`,
`.env.example`.

⚠️ **Điểm yếu còn lại (phải nói):** tài khoản `glpi` mặc định **chưa đổi mật
khẩu** trong môi trường demo — đây là việc phải làm khi triển khai thật.

### E2. "Cert SSL tự ký thì trình duyệt chặn, làm sao?"

> **Trả lời:** Cert có **Subject Alternative Name** đầy đủ (`localhost`,
> `pinedesk.local`, `127.0.0.1`) nên trình duyệt cho thêm ngoại lệ. CI có job
> riêng **bắt buộc phải có SAN** — thiếu là pipeline đỏ. Khi triển khai thật thì
> thay bằng Let's Encrypt.

**Bằng chứng:** `nginx/ssl/openssl-san.cnf`, job `ssl-san` trong `ci.yml`.

### E3. "Mất mạng thì còn demo được không?"

> **Trả lời:** Được. Landing page **phục vụ ngoại tuyến hoàn toàn** — 16 file font
> `.woff2` tự lưu, không CDN, mọi liên kết tương đối. Hệ thống chạy trong Docker
> nội bộ nên không phụ thuộc Internet.

**Bằng chứng:** `landing/fonts/`, `landing/index.html`.

### E4. "Nếu 5.000 sinh viên cùng nộp một lúc?"

> **Trả lời thẳng:** Em **chưa đo tải**, nên không khẳng định. Kiến trúc có Redis
> cache + MariaDB + Nginx đệm, nhưng với mức tải đó thì cần đo thực tế và có thể
> phải tách máy chủ. Em không dám nói "chịu được" khi chưa đo.

⚠️ **Không được bịa số.** Đây là câu bẫy; trả lời thật sẽ ghi điểm.

### E5. "Sinh viên tốt nghiệp rồi ai bảo trì?"

> **Trả lời:** Đây là vấn đề bàn giao. Đồ án giảm rủi ro bằng: tài liệu tiếng Việt
> (5 file), cài một lệnh, CI tự kiểm, không sửa lõi, và tùy biến tập trung ở plugin
> → người tiếp nhận chỉ cần đọc `tai-lieu/` là chạy lại được.

**Bằng chứng:** `tai-lieu/HUONG-DAN-TRIEN-KHAI.md`, `scripts/cai-dat-tat-ca.sh`.

---

## PHỤ LỤC — BẢNG TRA NHANH: CÂU HỎI → FILE MỞ NGAY

| Nếu bị hỏi về... | Mở file |
|---|---|
| Nhu cầu, bài toán, vì sao ITC | `tai-lieu/BAI-TOAN-NGHIEP-VU.md` |
| Chống spam | `tai-lieu/CHONG-LAM-DUNG.md` |
| So sánh GLPI gốc + giới hạn thật | `tai-lieu/SO-SANH-VOI-GLPI-GOC.md` |
| Cài đặt, vận hành, phục hồi | `tai-lieu/HUONG-DAN-TRIEN-KHAI.md` |
| Giao diện, Việt hoá | `tai-lieu/HUONG-DAN-GIAO-DIEN-VA-VIET-HOA.md` |
| QR cho thiết bị | `tai-lieu/HUONG-DAN-PLUGIN-QRCODE.md` |
| Số liệu DLU, cơ cấu tổ chức | `tai-lieu/THONG-TIN-DAI-HOC-DA-LAT.md` |
| Ảnh minh chứng giao diện thật | `tai-lieu/anh-giao-dien/` |
| Rate limit, bảo mật, HTTPS | `nginx/nginx.conf`, `nginx/conf.d/default.conf` |
| Pipeline tự kiểm | `.github/workflows/ci.yml` |
| Dữ liệu mẫu & tài khoản demo | `scripts/seed-du-lieu-mau.sql` |

---

## LỜI KHUYÊN KHI LUYỆN TẬP

1. **Tập nói câu A1 trong 30 giây** — không đọc. Đây là câu mở màn, nói vấp là mất điểm cả buổi.
2. **Nhóm B (chống spam) phải thuộc lòng** vì đây là điểm yếu bị khoan nhiều nhất.
3. **Ba câu phải trả lời bằng sự thật, không chống đỡ:** A4 (chưa gặp ITC), C3 (SLA chưa được ban hành), E4 (chưa đo tải).
4. **Tuyệt đối không bịa số.** Thừa nhận "em chưa đo" luôn an toàn hơn một con số sai.
