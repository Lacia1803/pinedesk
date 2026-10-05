# KỊCH BẢN DEMO BẢO VỆ ĐỒ ÁN — PINEDESK

> **Thời lượng mục tiêu: 7 phút** (co giãn 5–10 phút tuỳ hội đồng).
> **Nguyên tắc:** *chứng minh, đừng tuyên bố*. Mỗi phút phải có một thứ hiện ra
> trên màn hình, không nói suông.
>
> **Ngày lập:** 02/10/2026 · Xem kèm `CAU-HOI-PHAN-BIEN.md`.

---

## 0. CHUẨN BỊ TRƯỚC 30 PHÚT (checklist bắt buộc)

### 0.1. Chuẩn bị máy — chạy hết, không để tới lúc demo mới chạy

```bash
cd <thu-muc-du-an>
docker compose up -d                    # hoặc: bash start.sh
bash scripts/nap-du-lieu-mau.sh         # dữ liệu demo
bash scripts/nap-sla-va-chong-lam-dung.sh   # SLA + chống lạm dụng
```

**Kiểm tra trước khi lên bục:**
- [ ] Mở được `https://localhost:8443` (bấm "Advanced → Proceed" nếu trình duyệt cảnh báo cert)
- [ ] Đăng nhập được bằng `glpi`
- [ ] Xem thấy dashboard có số liệu (không phải bảng trống)
- [ ] Mở sẵn 4 tab: **Dashboard** · **Danh sách phiếu** · **Landing page** · **README.md**
- [ ] **Tắt thông báo** (Zalo, Messenger, email) — cực kỳ quan trọng khi chiếu máy chiếu
- [ ] Điện thoại để im lặng
- [ ] **Sạc/mang sạc**

### 0.2. Phương án dự phòng — ĐỌC KỸ PHẦN NÀY

| Tình huống | Xử lý |
|---|---|
| **Docker không khởi động kịp** | Dùng ảnh chụp trong `tai-lieu/anh-giao-dien/` — vẫn kể được câu chuyện |
| **Mất mạng hoàn toàn** | Landing page + ảnh minh chứng chạy **ngoại tuyến hoàn toàn** (font tự lưu, không CDN) |
| **Trình duyệt chặn cert** | Đã có sẵn ngoại lệ; nếu vẫn chặn → chụp ảnh đã chuẩn bị |
| **Máy chiếu sai độ phân giải** | Landing page responsive; dùng `Ctrl` + `+`/`-` |
| **Hội đồng hỏi ngoài dự kiến** | Mở `CAU-HOI-PHAN-BIEN.md` — chọn câu gần nhất rồi diễn đạt lại |

👉 **Mở sẵn `tai-lieu/anh-giao-dien/` trong một cửa sổ Explorer** — bí mật sau
cùng. Nếu máy sập, bạn vẫn còn 19 ảnh chụp giao diện thật để trình bày.

---

## 1. KỊCH BẢN 7 PHÚT — CHIA THEO PHÚT

### ⏱️ PHÚT 0:00–1:30 — ĐẶT VẤN ĐỀ (không cần máy chiếu)

> **Lời thoại gợi ý:**
>
> *"Trung tâm Công nghệ thông tin của Trường có 5 nhân sự, phải phục vụ hơn 14.500
> người học, và kênh tiếp nhận sự cố chỉ mở từ 7h30 đến 16h30 thứ 2 đến thứ 6 —
> nghĩa là 73% thời gian trong tuần không có kênh tiếp nhận chính thức. Em xây
> dựng PineDesk để giải quyết đúng khoảng trống đó."*

**Trên màn hình:** slide 1 — 3 con số lớn (5 nhân sự · 14.500+ người học · 7h30–16h30).

⚠️ **Nói rõ là dữ kiện công khai, có nguồn** — đừng để hội đồng nghĩ bạn bịa.
Nếu bị hỏi nguồn: *"Dạ từ website chính thức của Trường và của Trung tâm CNTT,
em có ghi nguồn và ngày truy cập trong tài liệu."*

---

### ⏱️ PHÚT 1:30–2:30 — CHO THẤY HỆ THỐNG CHẠY THẬT

**Mở:** `https://localhost:8443` → trang đăng nhập tiếng Việt, logo DLU.

> **Thao tác:** đăng nhập `glpi`.
> **Lời:** *"Đây là giao diện đã Việt hoá và mang bảng màu Đà Lạt lấy từ logo
> Trường — cả trang đăng nhập cũng đã Việt hoá."*

**Điểm nhấn kỹ thuật (nói nhanh, 15 giây):**
- HTTPS với chứng chỉ **có SAN** → trình duyệt cho thêm ngoại lệ;
- 4 container: Nginx · GLPI · MariaDB · Redis;
- Cài **bằng một lệnh**.

**Ảnh đối chiếu:** `tai-lieu/anh-giao-dien/01-trang-dang-nhap.png`

---

### ⏱️ PHÚT 2:30–4:00 — NGHIỆP VỤ: NỘP PHIẾU & CHỐNG LẠM DỤNG ⭐ ĐIỂM NHẤN

**Đây là phần quan trọng nhất — trả lời trực tiếp phê bình của thầy.**

**Bước 1 — Cho thấy sinh viên nộp phiếu được (30 giây):**
- Đăng xuất → đăng nhập `sv.hoa` (sinh viên)
- Vào **Hỗ trợ → Tạo phiếu** → điền nhanh → **Lưu**
- > *"Sinh viên có thể tự nộp phiếu, chỉ thấy phiếu của mình, không thấy của người khác."*

**Bước 2 — Trình diễn chống spam (60 giây):**

Mở terminal, chạy:
```bash
bash scripts/kiem-tra-lam-dung.sh
```

> *"Đây là tầng nghiệp vụ. Nginx chặn theo IP, nhưng phòng máy dùng NAT chung nên
> chặn theo IP sẽ chặn oan cả lớp — nên phải đếm theo tài khoản."*

**Bước 2b — Chứng minh chặn thật bằng plugin (30 giây, tuỳ chọn):**

Nếu còn giờ: đang đăng nhập `sv.hoa`, nộp liên tiếp đến phiếu thứ 6 đang mở →
hệ thống **chặn ngay kèm thông báo tiếng Việt** ("Bạn đang có 5 phiếu chưa xử lý
xong..."). Đây là bằng chứng tầng nghiệp vụ chạy thật, không chỉ báo cáo.

**Bước 3 — Chứng minh rate limit (30 giây):**

Chạy lệnh này **trước buổi bảo vệ để có ảnh**, hoặc demo trực tiếp nếu tự tin:
```bash
for i in $(seq 1 40); do
  curl -sSk -o /dev/null -w '%{http_code} ' https://localhost:8443/front/ticket.form.php
done; echo
```
> *"Sau một số request, hệ thống trả về 429 — nghĩa là đã bị chặn."*

**Nếu bị hỏi "sao không chặt hơn?"** → trả lời theo mục 2.3 của
`CHONG-LAM-DUNG.md`: NAT chung cả phòng máy, chặn IP chặt là chặn oan → tầng
nghiệp vụ mới siết theo tài khoản.

---

### ⏱️ PHÚT 4:00–5:30 — VÒNG ĐỜI PHIẾU & SLA

**Đăng nhập lại `glpi`** (quản trị).

**Thao tác 1 — Danh sách phiếu (30 giây):**
- Vào **Hỗ trợ → Phiếu yêu cầu**
- > *"13 phiếu mẫu trải đủ 4 trạng thái: Mới, Được giao, Đã giải quyết, Đã đóng."*

**Thao tác 2 — SLA thật (30 giây):**
- Vào **Thiết lập → Mức dịch vụ (SLA)**
- > *"5 mức SLA đã cấu hình thật trong CSDL — mỗi mức có hạn phản hồi và hạn
  giải quyết. **Nhưng em nói rõ: đây là đề xuất kỹ thuật của em, chưa phải cam
  kết đã được Trường ban hành.**"*

⚠️ **Nói câu này TRƯỚC khi bị hỏi** — chủ động thừa nhận ghi điểm cao hơn bị bắt lỗi.

**Thao tác 3 — Phiếu quá hạn (30 giây):**
- Lọc phiếu có mốc phản hồi đã trôi qua
- > *"Hai phiếu này đã quá hạn phản hồi — hệ thống phát hiện được."*

**Ảnh:** `tai-lieu/anh-giao-dien/04-danh-sach-phieu-yeu-cau.png`

---

### ⏱️ PHÚT 5:30–6:30 — TÀI SẢN & MÃ QR

**Thao tác:**
- Vào **Tài sản → Máy tính** → mở một máy (`TDL-PC-A101-001`)
- Cho thấy **mã QR** trên hồ sơ thiết bị
- > *"Mã QR in ra dán lên máy thật; quét là mở đúng hồ sơ máy đó. Em đã cài
> plugin, vá 2 lỗi của plugin, và **giải mã kiểm chứng** mã QR tạo ra."*

**Ảnh:** `tai-lieu/anh-giao-dien/07-chi-tiet-thiet-bi.png`,
`11-ma-qr-thiet-bi.png`

**Điểm kỹ thuật để nói (nếu còn giờ):** mã tài sản theo quy ước thật của trường —
tiền tố `TDL` là mã trường DLU.

---

### ⏱️ PHÚT 6:30–7:00 — CHIỀU SÂU KỸ THUẬT & KẾT

**Mở:** `README.md` (hoặc slide cuối).

> *"Về mặt kỹ thuật: toàn bộ tùy biến nằm **ngoài lõi GLPI** — nên nâng cấp GLPI
> không mất công. Có CI tự kiểm 6 nhóm, trong đó có smoke test khởi động thật 4
> container. Và em ghi rõ những gì chưa làm trong tài liệu."*

**Kết:**
> *"Điều em muốn nói rõ nhất: đây là đồ án **chưa được Trung tâm CNTT phê duyệt**.
> Em đã xây dựng hệ thống chạy thật, nhưng bước tiếp theo là phỏng vấn 5 nhân sự
> ITC để kiểm chứng bài toán và xin số liệu thực tế."*

👉 **Kết bằng việc tự nhận giới hạn** — hội đồng nhớ rất lâu.

---

## 2. BẢNG PHÂN BỔ THỜI GIAN — BẢN RÚT GỌN

| Phút | Nội dung | Trên màn hình |
|---|---|---|
| 0:00–1:30 | Đặt vấn đề: 5 người / 14.500 người học / 7h30–16h30 | Slide 3 con số |
| 1:30–2:30 | Hệ thống chạy thật | Trang đăng nhập |
| 2:30–4:00 | **Nộp phiếu + chống spam** ⭐ | Terminal + GLPI |
| 4:00–5:30 | Vòng đời phiếu + SLA thật | Danh sách phiếu, SLA |
| 5:30–6:30 | Tài sản + mã QR | Hồ sơ thiết bị |
| 6:30–7:00 | Kiến trúc ngoài lõi + tự nhận giới hạn | README / slide cuối |

**Nếu chỉ có 5 phút:** bỏ phút 5:30–6:30 (QR), giữ nguyên phần chống spam.

---

## 3. NĂM CÂU HỎI CHẮC CHẮN BỊ HỎI — TRẢ LỜI SẴN

| Câu hỏi | Trả lời ngắn |
|---|---|
| *"Em đã gặp ITC chưa?"* | **"Dạ chưa."** Rồi nêu kế hoạch phỏng vấn |
| *"SLA này ai ban hành?"* | **"Chưa ai — là đề xuất của em."** |
| *"Sinh viên spam thì sao?"* | 6 tầng; T1/T3/T4/T6 đã dựng thật, chỉ T5 còn ở mức quy trình; demo 429 + chặn phiếu thứ 6 |
| *"Sao không dùng Google Form?"* | Không phân công / không SLA / không truy vết / NAT & 5 nhân sự |
| *"Chịu được mấy nghìn người?"* | **"Em chưa đo, nên không dám khẳng định."** |

Chi tiết đầy đủ 25 câu: [`CAU-HOI-PHAN-BIEN.md`](CAU-HOI-PHAN-BIEN.md).

---

## 4. NHỮNG LỖI TRÌNH BÀY PHẢI TRÁNH

| ❌ Đừng | ✅ Nên |
|---|---|
| Đọc slide nguyên văn | Nhìn hội đồng, slide chỉ có số & hình |
| Nói "hệ thống rất tốt / hoàn hảo" | Nói "phần này em làm được, phần kia chưa" |
| Bịa số khi chưa đo | "Em chưa đo được, không dám khẳng định" |
| Chống đỡ khi bị chỉ lỗi | "Dạ đúng, phần này còn yếu" rồi nêu hướng |
| Demo lan man quá 10 phút | Bấm giờ, dừng đúng lúc |
| Mở nhiều tab lộn xộn | 4 tab chuẩn bị sẵn theo thứ tự |

---

## 5. SAU KHI BẢO VỆ — VIỆC CẦN LÀM NGAY

Ghi lại **ngay trong vòng 30 phút** khi còn nhớ:

- [ ] Hội đồng hỏi gì mà bạn chưa trả lời được?
- [ ] Góp ý nào cần sửa vào tài liệu?
- [ ] Có câu nào bạn trả lời sai/nói quá không?

Rồi cập nhật vào `tai-lieu/CAU-HOI-PHAN-BIEN.md` để lần sau tốt hơn.
**Đừng để tới hôm sau — sẽ quên hết.**
