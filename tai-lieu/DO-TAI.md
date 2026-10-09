# ĐO TẢI HỆ THỐNG PINEDESK

> **Mục đích.** Trả lời câu hỏi *"hệ thống chịu được bao nhiêu người dùng đồng
> thời?"* bằng **số đo thật**, thay vì suy luận kiến trúc suông. Đây là phần
> trước đây đồ án tự nhận là khoảng trống ("chưa đo hiệu năng").
>
> Chạy lại: `bash scripts/do-tai.sh` · Công cụ: `wrk` (trong Docker, không cần
> cài gì trên máy). Môi trường đo: máy phát triển cục bộ, 4 container chạy chung
> một máy (Nginx + GLPI + MariaDB + Redis chia sẻ CPU/RAM) — **thấp hơn** một
> máy chủ riêng, nên đây là **cận dưới** (bảo thủ) của năng lực thật.

---

## 1. Kết quả đo (máy phát triển, 09/10/2026)

### 1.1. Tầng gateway Nginx (endpoint `/healthz`)

| Chỉ số | Giá trị |
|---|---|
| Connections | 20 |
| **Requests/giây** | **~54.000** |
| p50 latency | 238 µs |
| p99 latency | 3.65 ms |

=> Nginx **không phải** điểm nghẽn. Nó chịu hàng chục nghìn request/giây cho
nội dung tĩnh hoặc chuyển tiếp nhanh.

### 1.2. Tầng ứng dụng GLPI (trang đăng nhập — qua PHP + phiên)

| Connections | Requests/giây | p50 | p99 | timeout |
|---|---|---|---|---|
| 10 | 68 | 108 ms | 216 ms | 0 |
| 30 | 89 | 284 ms | 473 ms | 6 |
| 50 | 106 | 387 ms | 783 ms | 11 |
| 100 | 98 | 765 ms | 1.45 s | 39 |

**Đọc bảng này thế nào:**
- Từ 10 → 100 connections, **throughput gần như không tăng** (68 → ~100 req/s)
  nhưng **độ trễ tăng vọt** (108 ms → 765 ms) và bắt đầu có timeout.
- Đây là dấu hiệu **bão hoà rõ ràng ở khoảng ~100 req/s**: thêm tải chỉ làm
  hàng đợi dài hơn, chứ không xử lý thêm được.
- Nút thắt là **GLPI/PHP/Apache xử lý một request một lúc** (không có worker
  pool song song mạnh), không phải Nginx hay CSDL.

### 1.3. Đường GHI — tạo phiếu (thao tác nặng nhất)

| Chỉ số | Giá trị |
|---|---|
| Số phiếu tạo | 30 |
| Tổng thời gian | 0.64 s |
| **Tốc độ ghi** | **~47–60 phiếu/giây** (≈ 17–21 ms/phiếu) |

Mỗi lần tạo phiếu gồm: INSERT phiếu + chạy hook chống lạm dụng (đếm + khoá
`GET_LOCK` + ghi nhật ký). Vẫn đạt **~50 phiếu/giây** — dư sức cho quy mô đồ án.

---

## 2. Số này nghĩa là gì với Trường Đại học Đà Lạt?

Kịch bản giờ cao điểm (đầu giờ sáng, nhiều lớp cùng vào):

| Kịch bản | Cách tính | Tải cần | Kết luận |
|---|---|---|---|
| **Bình thường**: 10% trong 14.500 người truy cập trong 10 phút, mỗi người ~10 trang | 1.450 × 10 / 600s | **~24 req/s** | ✅ Dư sức (ngưỡng ~100) |
| **Cao điểm**: 30% truy cập cùng lúc | 4.350 × 10 / 600s | **~72 req/s** | ⚠️ Gần bão hoà, độ trễ tăng |
| **Xấu nhất**: cả trường cùng vào trong 5 phút | 14.500 × 10 / 300s | **~480 req/s** | ❌ Vượt xa năng lực 1 máy |

**Kết luận trung thực:**
- **1 máy GLPI đủ cho vài trăm người dùng đồng thời** — phù hợp với mức sử dụng
  thực tế của một trung tâm hỗ trợ nội bộ (không phải cả trường cùng lúc).
- **KHÔNG đủ** nếu cả trường dồn vào cùng lúc — nhưng đó không phải cách hệ
  thống helpdesk được dùng (phiếu đến rải rác, không đồng loạt như thi trực tuyến).
- Khi cần tăng: thêm worker PHP, tách CSDL sang máy riêng, hoặc nhân bản GLPI
  sau một load balancer. Chưa làm vì chưa cần ở quy mô này.

---

## 3. Điểm mạnh và giới hạn của phép đo

**Điểm mạnh (đáng tin):**
- Đo trên hệ thống **đang chạy thật**, không mô phỏng.
- Bao cả tầng tĩnh (Nginx), tầng động (GLPI), và đường ghi (tạo phiếu).
- Script **tái lập được**: chạy lại bằng một lệnh, kết quả ghi rõ từng mức tải.

**Giới hạn (nói thẳng):**
- 4 container **chung một máy** → năng lực thật trên máy chủ riêng sẽ cao hơn.
- Chưa đo: đăng nhập + duyệt nhiều trang liên tiếp (chuỗi phiên), tải CSDL khi
  dữ liệu lớn dần, hành vi khi đồng thời có cả đọc lẫn ghi.
- Chưa đo Redis bật vs tắt để định lượng đóng góp của Redis (mới xác nhận Redis
  *đang được dùng*, chưa đo *nhanh hơn bao nhiêu*).

---

## 4. Việc nên làm tiếp (nếu muốn con số chắc hơn)

1. **Đo Redis bật/tắt** — chạy lại phép đo trang đăng nhập hai lần (một lần tắt
   cache), so sánh p50. Sẽ trả lời được "Redis có ích bao nhiêu".
2. **Đo chuỗi phiên thật** — dùng k6/Playwright mô phỏng một người đăng nhập rồi
   duyệt 10 trang, thay vì chỉ GET trang đăng nhập.
3. **Đo trên máy chủ tách biệt** — nếu có điều kiện, tách CSDL/Redis ra máy khác
   để có con số sát môi trường thật.

*Số liệu trong tài liệu này do `scripts/do-tai.sh` sinh ra trên máy phát triển
cục bộ. Chạy lại script để cập nhật.*
