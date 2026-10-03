# NHẬT KÝ THAY ĐỔI — PINEDESK

Định dạng theo [Keep a Changelog](https://keepachangelog.com/vi/1.1.0/).
Phiên bản theo [Semantic Versioning](https://semver.org/lang/vi/).

## [0.4.0] — 2026-10-03 — "Vá ba lỗi cài máy sạch, sửa giao diện, Việt hoá dữ liệu và chuyển sang Playwright"

**Bối cảnh:** tiếp tục chuẩn bị báo cáo lần 2. Bản này gỡ ba lỗi chỉ lộ ra khi
cài trên máy sạch, đẩy nốt phần dữ liệu hiển thị sang tiếng Việt, làm lại tầng
công cụ trình duyệt, kiểm thử lại toàn bộ chức năng theo từng vai trò và thêm
năm cửa kiểm CI để những lỗi đó không quay lại.

### Sửa (ba lỗi cài trên máy sạch)

- **Sáu tài khoản demo không có hồ sơ quyền, đăng nhập là chết.** `seed-du-lieu-mau.sql`
  gán hồ sơ theo tên tiếng Việt (`Technician`, `Self-Service`), nhưng trên máy
  sạch GLPI tạo hồ sơ bằng tên tiếng Anh, còn `viet-hoa-du-lieu.sh` (đổi tên sang
  tiếng Việt) lại không nằm trong luồng cài. JOIN khớp 0 dòng, nên `ktv.an`,
  `sv.hoa` và bốn tài khoản còn lại đăng nhập trả HTTP 400 *"Bạn không có quyền
  để kết nối"*. Kịch bản demo đăng nhập `sv.hoa` sẽ chết ngay trên bục. Nay câu
  lệnh khớp cả hai tên, chạy theo thứ tự nào cũng đúng.
- **Bảng điều khiển hiện chế độ minh hoạ của GLPI.** GLPI 11 bật sẵn
  `is_demo_dashboards = 1`; chế độ này thay bảng điều khiển thật bằng dữ liệu mẫu.
  `viet-hoa-du-lieu.sh` đã tắt nó, nhưng script không được gọi trong luồng cài.
  Nay bước Việt hoá dữ liệu chạy ngay sau khi nạp danh mục nghiệp vụ.
- **Thương hiệu và dải màu ưu tiên không được áp.** `cai-giao-dien.sh` đặt
  `app_name`, dải màu ưu tiên và bảng màu mặc định, nhưng cũng không được gọi ở
  đâu. Trên máy sạch thẻ trình duyệt hiện *"... - GLPI"* và dải màu ưu tiên vẫn
  là hồng đỏ mặc định của GLPI. Nay script chạy ngay sau khi bật plugin.

### Sửa (giao diện)

- **Thanh điều hướng trang tự phục vụ gần như tàng hình.** Trang helpdesk dùng
  `navbar-dark` (chữ kem) trên nền giấy sáng, tương phản khoảng 1,06:1. Đổi sang
  token `--dlu-muc`, token này tự đổi giá trị theo sáng/tối (#26301A khi sáng,
  #E6EADB khi tối). Trang kỹ thuật viên dùng `navbar-light` nên không bị.
- **Trang tự phục vụ hoá xanh dương khi bật chế độ tối.** Bảng màu tối của GLPI
  (`auror_dark`) gán cứng ba dải nền đầu trang thành xanh dương, trong khi phần
  còn lại theo tông xanh rêu Đà Lạt. Nay ba dải đó bám đúng token của đồ án.
  Lỗi lộ ra khi đo màu thật trên trình duyệt ở cả hai chế độ, không phải khi đọc
  mã.

### Thay đổi

- **Chuyển công cụ trình duyệt từ Puppeteer sang Playwright.** Chín script chụp
  ảnh và kiểm tra nay dùng `playwright-core` điều khiển Chrome có sẵn trên máy,
  không tải thêm trình duyệt. Thêm `package.json` (khai báo `playwright-core`
  `^1.63.0`) và viết lại `scripts/lib/browser.js` theo API Playwright.
- **Sửa `kiem-tra-qr-va-chup-anh.js` cho đúng GLPI 11.** Bản cũ tạo một máy tính
  thử (`PC-TEST-QR-DLU-001`) rồi thử mở `/plugins/barcode/front/barcode.php` —
  đường dẫn này không còn ở GLPI 11 (404), và thiết bị thử làm bẩn bộ dữ liệu
  demo 17 máy. Bản mới dùng thiết bị có sẵn, đi theo đúng luồng *Các hành động →
  Barcode - Print QRcodes*, không tạo dữ liệu rác.

### Thêm mới

- **`tai-lieu/BAO-CAO-THUC-TAP.md` — báo cáo thực tập viết theo định dạng của
  Trường Đại học Đà Lạt.** Viết lại từ đầu: trang bìa, lời cảm ơn, nhận xét đơn
  vị thực tập (chỗ ký), mục lục, danh mục từ viết tắt / bảng biểu / hình ảnh;
  phần mở đầu và 5 chương (tổng quan đơn vị thực tập, cơ sở lý thuyết, phân tích
  và thiết kế, triển khai và kiểm thử, đánh giá); kết luận và kiến nghị, tài liệu
  tham khảo, phụ lục. Mục 4.1 kể tiến độ theo ba giai đoạn từ 21/09 đến
  03/10/2026, kể cả những lần phải làm lại.
- **Từ điển Việt hoá: 541 → 556 thuật ngữ** (+15 mục cho trang tự phục vụ, ví dụ
  "Báo cáo sự cố", "Đặt mượn thiết bị", "Xem phiếu của bạn"). Bản dịch vi_VN chính
  thức của GLPI 11 để trống toàn bộ nhóm nhãn này. Độ phủ đo từ `.mo` thật:
  31,8% → **32,0%** (2.084/6.511 chuỗi). Số liệu 31,8% / 2.070 trong tài liệu
  được cập nhật đồng bộ theo.
- **`scripts/kiem-tra-chuc-nang.sh` — kiểm chức năng theo vai trò.** Đăng nhập
  thật rồi GET từng trang, đối chiếu mã HTTP: trang được phép phải 200, trang
  Setup phải 403 với kỹ thuật viên và mọi trang trung tâm phải 403 với sinh viên.
  Chạy được cho cả ba vai trò (quản trị / kỹ thuật viên / sinh viên).
- **`scripts/kiem-tra-usecase.js` — ba use case thật, chạy end-to-end.** Sinh
  viên nộp phiếu sự cố, kỹ thuật viên thấy phiếu đó trong danh sách, sinh viên
  đặt mượn thiết bị. Kết quả đối chiếu với danh sách phiếu và danh sách đặt chỗ,
  không chỉ kiểm mã HTTP.
- **Năm cửa kiểm CI mới** trong job `smoke`:
  - Tài khoản demo phải có hồ sơ quyền và đăng nhập được (chốt 0 tài khoản thiếu
    hồ sơ, và `ktv.an`/`sv.hoa` trả HTTP 302).
  - Dữ liệu hiển thị phải Việt hoá (đơn vị "Đại học Đà Lạt", 0 bảng điều khiển
    tiếng Anh, `is_demo_dashboards = 0`).
  - Thương hiệu và dải màu ưu tiên phải được đặt (`app_name = 'PineDesk DLU'`,
    `priority_5 = '#CC2430'`).
  - Từ điển phải đủ 556 thuật ngữ + 212 mục số nhiều.
  - Chức năng + phân quyền theo vai trò phải hoạt động (`kiem-tra-chuc-nang.sh`
    chạy cho `ktv.an` và `sv.hoa`).

### Sửa (thứ tự nạp dữ liệu)

- **CI nạp SLA trước khi có dữ liệu mẫu, nên phần mượn/trả bị bỏ qua trong im
  lặng.** `seed-sla-va-chong-lam-dung.sql` tạo 2 lượt mượn cho hai laptop
  `TDL-LAP-001`/`TDL-LAP-003` và 1 phiếu mượn của `sv.hoa`; cả ba đều do
  `nap-du-lieu-mau.sh` sinh ra. CI lại chạy bước SLA trước bước dữ liệu mẫu, nên
  các câu lệnh có guard `WHERE @lap IS NOT NULL` khớp 0 dòng và không báo lỗi.
  Cửa kiểm "Dữ liệu bảo trì + mượn thiết bị" vì thế thấy 0 thiết bị cho mượn
  thay vì 2. Nay hai bước danh mục và dữ liệu mẫu chạy **trước** bước SLA, đúng
  như phần đầu tệp SQL đã ghi.
- **`nap-sla-va-chong-lam-dung.sh` nay tự kiểm phần bảo trì + mượn/trả.** Trước
  đây script chỉ kiểm SLA và im lặng với phần phụ thuộc dữ liệu mẫu. Nay nếu
  thiếu dữ liệu mẫu, script in cảnh báo kèm hướng dẫn chạy `nap-du-lieu-mau.sh`
  rồi chạy lại, thay vì để người dùng tưởng đã có dữ liệu mượn.
- **Đính chính hai tài liệu.** `README.md` và `SO-SANH-VOI-GLPI-GOC.md` ghi
  `cai-dat-tat-ca.sh` là có ngay 14 phiếu, nhưng script đó không nạp dữ liệu mẫu.
  Nay ghi rõ: chạy `nap-du-lieu-mau.sh` để có 13 phiếu, rồi
  `nap-sla-va-chong-lam-dung.sh` để thêm phiếu mượn thứ 14.

### Ghi chú

- Số 541 thuật ngữ / 31,8% ghi trong bản 0.3.0 là **đúng tại thời điểm đó**; mục
  nhật ký là bản ghi lịch sử, không sửa lại.
- `cai-dat-tat-ca.sh` nay gọi `viet-hoa-du-lieu.sh` và `cai-giao-dien.sh`. Trước
  đây cả hai script đều có sẵn nhưng không nằm trong luồng cài, nên máy sạch
  thiếu cả dữ liệu Việt hoá lẫn thương hiệu.

---

## [0.3.0] — 2026-10-03 — "Chuẩn hoá số liệu và vá lỗi dữ liệu mẫu cho báo cáo lần 2"

**Bối cảnh:** chuẩn bị báo cáo lần 2. Trước khi trình bày, đồ án rà soát lại
toàn bộ số liệu trong tài liệu đối chiếu với hệ thống chạy thật, và chạy cài
đặt trên **máy sạch (xoá sạch volume)** để kiểm chứng.

### Sửa (lỗi thật tìm thấy khi cài trên máy sạch)

- **Dữ liệu mẫu âm thầm thiếu 4 thiết bị.** `seed-du-lieu-mau.sql` tham chiếu
  tên vị trí **không khớp** với `seed-du-lieu-nen.sql`:
  - `'Văn phòng Khoa Toán - Tin'` — sai, tên đúng là `'Văn phòng Khoa Toán - Tin học'`
  - `'Phòng Lab C101'` — sai, tên đúng là `'Phòng thí nghiệm C101'`

  Vì câu lệnh dùng `JOIN glpi_locations … ON l.name = s.loc`, các dòng không
  khớp bị **bỏ qua trong im lặng**: thiếu **2 laptop, 1 máy in và 4 thiết bị
  mạng** (kết quả thực tế chỉ 15 máy tính / 2 máy in / 5 thiết bị mạng thay vì
  17 / 3 / 9). Đã sửa tên cho khớp; nay cài sạch cho đủ **17 máy tính · 5 màn
  hình · 3 máy in · 9 thiết bị mạng · 10 phần mềm · 13 phiếu**.
- **`scripts/kiem-tra-landing.js`:** biến `const URL = '…'` che khuất hàm tạo
  `URL` toàn cục của Node, khiến phần kiểm liên kết tài liệu **luôn báo lỗi
  `URL is not a constructor`** và bỏ qua toàn bộ phần kiểm còn lại. Đổi tên
  thành `URL_TRANG`. Nay script kiểm được đủ 10 liên kết tài liệu (đều HTTP 200).
- **`scripts/kiem-tra-tieng-viet.py`:** đo tỉ lệ Việt hoá từ file `.po` (đếm
  thô theo dòng) nên ra một con số khác (36,3%) và **mâu thuẫn** với
  `do-do-phu-tieng-viet.py` (đọc `.mo` thật). Viết lại để cùng đọc `.mo` đang
  cài — hai script nay cho **cùng kết quả 31,8%**.

### Sửa (số liệu tài liệu cho khớp hệ thống thật)

- **Số phòng máy: 65 → 54.** Con số 65 không tái lập được trên máy sạch; seed
  thực tế dựng **12 toà nhà + 54 phòng máy/lab = 67 vị trí**. Sửa ở `README.md`,
  `PRODUCT.md`, `landing/index.html`, `BAI-TOAN-NGHIEP-VU.md`, `SO-SANH-VOI-GLPI-GOC.md`.
- **Từ điển Việt hoá: 443 → 541 thuật ngữ.** Từ điển đã được bổ sung lên 541
  nhưng tài liệu còn ghi 443. Sửa đồng bộ toàn bộ tài liệu và landing page.
- **Độ phủ Việt hoá: 30,6% → 31,8%** (2.070/6.511 chuỗi, đo lại từ `.mo` thật).
  Sửa ở `README.md`, `HUONG-DAN-GIAO-DIEN-VA-VIET-HOA.md`, `HUONG-DAN-TRIEN-KHAI.md`,
  `SO-SANH-VOI-GLPI-GOC.md`.
- **Số dòng script:** làm mới **17 dòng** trong bảng kiểm kê `SO-SANH-VOI-GLPI-GOC.md`
  (nhiều file đã dài thêm mà bảng chưa cập nhật).
- Nêu rõ nguồn gốc các con số danh mục: "11 nguồn tiếp nhận" = 5 nguồn của đồ án
  + 6 nguồn gốc GLPI; "11 nhóm phần mềm" = 10 của đồ án + 1 gốc GLPI.

### Thêm mới

- **Trang giới thiệu:** thêm 2 thẻ tài liệu (`KICH-BAN-DEMO.md`, `slide-bao-ve.html`)
  — từ 9 lên 11 liên kết; nêu đúng "mười tài liệu".
- **`nginx/conf.d/default.conf`:** thêm `location` riêng cho
  `/tai-lieu/slide-bao-ve.html` trả `text/html` — trước đây bị `location /tai-lieu/`
  ép `text/plain` nên slide hiện ra dưới dạng văn bản thô thay vì trình chiếu.
- **CI (`smoke`):** thêm 2 cửa kiểm mới chống lệch số liệu:
  - *"Danh mục nghiệp vụ phải khớp số liệu tài liệu"* — chốt 12 toà nhà / 54 phòng
    / 67 vị trí / 79 loại sự cố.
  - *"Dữ liệu demo phải đủ 34 tài sản"* — chốt 17 máy tính / 5 màn hình / 3 máy in
    / 9 thiết bị mạng / 10 phần mềm / 14 phiếu, và **không thiết bị nào thiếu vị trí**
    (chính là lỗi JOIN ở trên).
  - CI cũng mount thêm `tai-lieu/` và `README.md` khi chạy `nginx -t` cho khớp
    `docker-compose.yml`.
- **`tai-lieu/anh-giao-dien/`:** bổ sung ảnh minh chứng cho các hạng mục mới.

### Dọn dẹp (giữ lại đúng thứ cần thiết)

- Xoá **rác sinh ra khi chạy**: `node_modules/` (28 MB), `.tmp-anh/` (66 MB),
  `.tmp-check/`, `.tmp-locale/`, `scripts/__pycache__/`, chứng chỉ tự ký trong
  `nginx/ssl/` (`.crt`/`.key`/`.bak` — start.sh tự sinh lại).
- Xoá **workspace tạm của công cụ**: `.impeccable/` (14 MB), `.playwright-mcp/`,
  `.backup-landing-cu/`, cùng các thư mục ghi chú nội bộ `.claude/`, `.omp/`.
- Xoá **ảnh chụp nháp ở gốc repo** (`nghiem-thu-*`, `soi-*`, `toi-*`, `xem-*.png`).
- Xoá **`output-qr/`** (kết quả sinh QR mẫu) và các **bản sao lưu CSDL cũ** trong
  `backup/`. Chạy lại `python scripts/sinh-ma-qr.py` sẽ tự tạo lại thư mục
  `output-qr/` khi cần (script có `os.makedirs(..., exist_ok=True)`).
- **Giữ nguyên** `tai-lieu/` (tài liệu + ảnh minh chứng), toàn bộ mã nguồn, script,
  cấu hình, font, logo và các tệp mô tả dự án. Kích thước cây làm việc giảm từ
  ~120 MB xuống **~6 MB**; 129 tệp được version hoá.
- Cập nhật `README.md`: bỏ dòng `output-qr/` khỏi sơ đồ cấu trúc thư mục.

### Ghi chú

- Bản 0.1.0 ghi "443 thuật ngữ / 30,6%" là **đúng tại thời điểm đó**; các mục
  trong nhật ký là bản ghi lịch sử, không sửa lại.
- Việc kiểm chứng được thực hiện bằng cách **xoá sạch volume** rồi cài lại từ đầu
  (`docker compose down -v` → `up -d` → `cai-dat-tat-ca.sh`), không dựa vào dữ
  liệu còn sót lại từ lần chạy trước.

---

## [0.2.0] — 2026-10-02 — "Từ lý thuyết sang nghiệp vụ thật"

**Bối cảnh:** sau báo cáo tiến độ lần 1, giảng viên hướng dẫn nhận xét đồ án
*"còn lý thuyết, chưa thực tế"* và đặt câu hỏi trực diện: *"Nếu sinh viên spam
thì sao? Cơ chế để sinh viên nộp ticket là gì? Đồ án giải quyết nhu cầu gì của
trường?"*. Bản phát hành này trả lời trực tiếp ba câu hỏi đó.

### Thêm mới

**Tài liệu nghiệp vụ**
- `tai-lieu/BAI-TOAN-NGHIEP-VU.md` — bài toán thực tế với dữ kiện công khai có
  nguồn: 5 nhân sự Trung tâm CNTT (ITC) phục vụ 14.500+ người học, kênh tiếp nhận
  chỉ mở 7h30–16h30 thứ 2–6. Phân loại rõ 🟢 dữ kiện / 🟡 suy luận / 🔴 giả định.
- `tai-lieu/CHONG-LAM-DUNG.md` — sáu tầng chống lạm dụng nộp phiếu, ghi rõ tầng nào
  đã dựng thật, tầng nào còn ở mức quy trình.
- `tai-lieu/CAU-HOI-PHAN-BIEN.md` — 25 câu hỏi hội đồng thường hỏi + cách trả lời
  kèm bằng chứng; chỉ rõ ba câu phải trả lời bằng sự thật.
- `tai-lieu/KICH-BAN-DEMO.md` — kịch bản trình diễn 7 phút chia theo phút, kèm
  phương án dự phòng khi mất mạng hoặc Docker không chạy.
- `tai-lieu/slide-bao-ve.html` — 7 slide tự chứa, chạy ngoại tuyến hoàn toàn,
  dùng bảng màu Đà Lạt trích từ logo DLU.

**Cơ chế chống lạm dụng (đã dựng thật)**
- Rate limit cho endpoint nộp phiếu: zone `ticket_zone` (30 request/phút mỗi IP)
  áp cho `/front/ticket.form.php` và `/api/` — **vá lỗ hổng trước đây chỉ rate-limit
  ở trang đăng nhập**.
- `scripts/seed-sla-va-chong-lam-dung.sql` — tạo 5 định nghĩa SLA thật trong CSDL
  (trước đây README tuyên bố "cam kết SLA" nhưng CSDL rỗng), bảng hạn mức
  `glpi_plugin_pinedesk_limits`, bảng nhật ký `glpi_plugin_pinedesk_ticketlog`,
  view đếm phiếu đang mở, và phiếu quá hạn để demo cảnh báo.
- `scripts/nap-sla-va-chong-lam-dung.sh` — nạp cấu hình trên, có kiểm chứng.
- `scripts/kiem-tra-lam-dung.sh` — phát hiện vượt hạn mức, phiếu trùng, nộp quá
  nhanh theo **tài khoản** (không theo IP, vì trường dùng NAT chung).

**Bảo trì định kỳ + mượn/trả thiết bị (đã dựng thật)**
- 2 lịch bảo trì dùng cơ chế **gốc** `glpi_ticketrecurrents` (bảo trì phòng máy
  hàng tháng, kiểm tra thiết bị mạng hàng quý) kèm 2 mẫu phiếu điền sẵn tiêu đề,
  nội dung, danh mục và ưu tiên. Cron `ticketrecurrent` của GLPI tự sinh phiếu.
- 2 laptop vào diện đặt mượn + 2 lượt mượn mẫu (1 đang mượn, 1 đã trả) + 1 phiếu
  yêu cầu mượn — dùng `glpi_reservationitems`/`glpi_reservations` gốc, **không**
  tạo bảng riêng.
- Sửa **2 lỗi schema thật** phát hiện khi chạy cài đặt lần đầu:
  - `DATE_SUB(@now, INTERVAL 3 DAY - INTERVAL 2 HOUR)` — MySQL không hỗ trợ trừ
    hai `INTERVAL`; đổi thành `INTERVAL 70 HOUR`.
  - `glpi_slalevels.exec_time` **không tồn tại** (đúng là `execution_time`), và
    `glpi_slas.type` là `NOT NULL` (TTO=1/TTR=0) → lỗi 1054 chặn cả bước 5.
    Viết lại Phần A: 10 SLA (5 mức ưu tiên × 2 loại) + dọn bản ghi cũ khi nạp lại.

**Kiểm thử tự động**
- CI thêm 3 bước trong job `smoke`: bắt buộc phát hiện HTTP 429 khi spam endpoint
  nộp phiếu; kiểm tra bảng SLA có dữ liệu sau khi nạp; chạy script kiểm lạm dụng.

### Thay đổi

- `scripts/cai-dat-tat-ca.sh`: từ 5 bước lên **6 bước**, thêm bước nạp SLA + chống
  lạm dụng.
- `README.md`: bỏ tuyên bố suông "cam kết SLA"; thêm dòng minh bạch rằng các mức
  SLA là **đề xuất kỹ thuật, chưa được Trường ban hành**; thêm mục chống lạm dụng.
- `tai-lieu/SO-SANH-VOI-GLPI-GOC.md`: viết lại mục "Những điều chưa làm" thành hai
  phần — giới hạn kỹ thuật và **giới hạn nghiệp vụ** (10 điểm, nói thẳng).
- `landing/index.html`: bổ sung liên kết tới 3 tài liệu nghiệp vụ mới (từ 6 lên 9).

### Sửa

- **Đính chính tên đơn vị:** toàn bộ tài liệu đổi "Phòng Công nghệ thông tin" →
  **"Trung tâm Công nghệ thông tin (ITC)"** — tên đúng theo công bố chính thức.
- **Đính chính tên miền:** `cict.dlu.edu.vn` → `itc.dlu.edu.vn` (miền cũ chuyển
  hướng 301).
- **Đính chính tên phòng ban** theo danh mục hiện hành của Trường: "Phòng Cơ sở
  Vật chất" → "Phòng Quản trị Cơ sở vật chất"; "Phòng Chính trị và Công tác Sinh
  viên" → "Phòng Công tác sinh viên"; và 4 tên khác.
- Xoá nhánh nhánh cũ đã lỗi thời `sua-4-van-de-muc-thap`.

### Ghi chú

Ba điều đồ án **chưa** chứng minh được, ghi rõ để không tuyên bố quá mức:
1. Chưa gặp ITC để xác nhận nhu cầu (đồ án chưa được phê duyệt);
2. Chưa có số sự cố thực tế mỗi tuần của trường;
3. Chưa đo hiệu năng khi nhiều người cùng nộp.

### Số liệu đo được trên máy thật (2026-10-02)

| Chỉ số | Kết quả | Cách đo |
|---|---|---|
| Thời gian cài đặt trọn gói (6 bước) | **90 giây** | `time bash scripts/cai-dat-tat-ca.sh` |
| Độ phủ Việt hoá thực tế | **31,8%** (2.070/6.511 chuỗi) | `python scripts/do-do-phu-tieng-viet.py` |
| Thời gian phản hồi trang (5 lần) | **~55 ms** (52–64 ms) | `curl -w "%{time_total}"` |
| Thời gian phản hồi CSS tĩnh | **45 ms** | `curl -w "%{time_total}"` |

**Nói rõ để không hiểu sai:** 31,8% là tỉ lệ trên *toàn bộ catalog chuỗi của GLPI*
(GLPI chỉ đóng gói sẵn ~32% bản dịch tiếng Việt chính thức). Menu, biểu mẫu và
nhãn bảng điều khiển — phần người dùng thực sự nhìn thấy — đã Việt hoá 100%.
Con số 90 giây và 55 ms đo trên máy cá nhân, KHÔNG phải đo tải nhiều người
cùng lúc; đồ án chưa kiểm thử hiệu năng.


---

## [0.1.0] — 2026-09-22 — "Hoàn thiện nền tảng"

- Việt hoá bổ sung 443 thuật ngữ + 212 mục dạng số nhiều (phủ 30,6% catalog;
  menu, biểu mẫu và nhãn dashboard 100%).
- Giao diện "Đà Lạt" (`plugins/dlubrand/`) — bảng màu trích từ logo DLU.
- Plugin Barcode/QR: cài đặt, vá 2 lỗi, giải mã kiểm chứng.
- Hạ tầng 4 container Docker + Nginx gateway + HTTPS có SAN.
- Landing page chạy ngoại tuyến (16 font `.woff2` tự lưu).
- Dữ liệu nền 23 nhóm danh mục + dữ liệu demo (17 máy tính, 13 phiếu, 6 tài khoản).
- CI 6 nhóm job gồm smoke test khởi động thật 4 container.
- 5 tài liệu tiếng Việt + 19 ảnh minh chứng giao diện.
- Xử lý rò rỉ bí mật: quét theo hình dạng, không chứa mật khẩu thật.
