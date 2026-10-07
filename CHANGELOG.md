# NHẬT KÝ THAY ĐỔI — PINEDESK

Định dạng theo [Keep a Changelog](https://keepachangelog.com/vi/1.1.0/).
Phiên bản theo [Semantic Versioning](https://semver.org/lang/vi/).

## [Chưa phát hành]

### Thay đổi

- **Gộp 9 tài liệu rời thành một tài liệu tổng hợp duy nhất**
  `tai-lieu/README.md` (644 dòng, 10 mục lớn, 33 mục con): bài toán nghiệp vụ,
  cơ cấu tổ chức DLU, kiến trúc so với GLPI gốc, 6 tầng phòng thủ chống lạm dụng,
  giao diện & Việt hoá, quản lý mã QR, triển khai & vận hành, kịch bản demo 7 phút
  và bộ 25 câu hỏi phản biện. Thay cho 9 tệp cũ
  (`BAI-TOAN-NGHIEP-VU.md`, `CAU-HOI-PHAN-BIEN.md`, `CHONG-LAM-DUNG.md`,
  `HUONG-DAN-GIAO-DIEN-VA-VIET-HOA.md`, `HUONG-DAN-PLUGIN-QRCODE.md`,
  `HUONG-DAN-TRIEN-KHAI.md`, `KICH-BAN-DEMO.md`, `SO-SANH-VOI-GLPI-GOC.md`,
  `THONG-TIN-DAI-HOC-DA-LAT.md` — tổng 4.008 dòng). Một điểm đến duy nhất cho
  hội đồng, không còn tình trạng số liệu lệch nhau giữa các tệp.
  Các tham chiếu hướng dẫn trong `README.md`, slide bảo vệ, script cài đặt/vận hành,
  `backup/backup.sh` và cấu hình nginx đã trỏ về `tai-lieu/README.md` kèm số mục cụ thể.
- Tài liệu **cá nhân** của người làm đồ án (`DeCuongTTNN_*.docx`,
  `Danh sách thực tập *.xlsx`, `MoTaDeTai.txt`) chuyển từ `tai-lieu/` ra
  `tai-lieu-ca-nhan/` và thêm thư mục này vào `.gitignore`. Trước đây chúng nằm
  trong thư mục nginx mount read-only; dù đã được chặn 2 lớp (allowlist
  `.md/.png/.html` ở gateway + cửa kiểm tra trong CI) nhưng vẫn nên tách hẳn
  khỏi vùng phục vụ công khai.
- **Chuyển bộ script chụp ảnh/kiểm thử từ Puppeteer sang Playwright.** Thêm
  `package.json` khai báo `playwright-core` (điều khiển Chrome có sẵn trên máy,
  không tải kèm trình duyệt ~150 MB) cùng 6 lệnh npm; viết lại
  `scripts/lib/browser.js` thành helper dùng chung `launch`/`dangNhap`/`sleep`;
  cập nhật cả 5 script chụp ảnh và kiểm thử hiện có. Thêm
  `scripts/kiem-tra-usecase.js`: ba use case thật end-to-end (sinh viên nộp
  phiếu, đặt mượn thiết bị, kỹ thuật viên mở phiếu của sinh viên).
- **Vá 3 script QR không còn lưu ảnh giả.** `chup-anh-qr-admin.js`,
  `kiem-tra-massive-qr.js` và `kiem-tra-qr-va-chup-anh.js` trước đây chụp trang
  hiện tại khi plugin không mở tab mới (popup bị chặn) nên ảnh sai nội dung.
  Nay chỉ chụp khi tab kết quả thật sự mở ra, còn lại cảnh báo và hướng dẫn
  kiểm file PDF trong container GLPI. `kiem-tra-qr-va-chup-anh.js` cũng không
  còn tạo thiết bị rác `PC-TEST-QR-DLU-001` — dùng thiết bị có sẵn.
- **Thêm `tai-lieu/BAO-CAO-THUC-TAP.md`** (báo cáo thực tập tốt nghiệp đầy đủ,
  bản in) và ảnh minh chứng `11-cau-hinh-nhan-qr.png`; Phụ lục C chốt đúng
  danh mục **18 ảnh** chụp giao diện thật. Đồng bộ `README.md`, `PRODUCT.md`,
  `tai-lieu/README.md` và báo cáo theo cấu trúc tài liệu mới.
- **CI:** nâng phiên bản các action `checkout@v7`, `setup-python@v7`,
  `setup-node@v7` (v4/v5 đã cũ).
- **`.gitignore`:** thêm `output-qr/` — thư mục sinh ra khi chạy
  `scripts/sinh-ma-qr.py`, từng bị xoá ở `be0bf0a` nhưng chưa được ignore nên
  dễ lọt vào git khi chạy lại script.

### Đã xoá

- Bỏ trang giới thiệu dự án (`landing/`): loại bỏ route `/landing/` tại Nginx gateway; favicon chuyển sang lấy trực tiếp từ `themes/pics/logos/`.
- Dọn dẹp các script kiểm thử và công cụ phục vụ trang giới thiệu (`scripts/kiem-tra-landing.js`, `scripts/chup-anh-tung-khu.js`, `scripts/chup-anh-dashboard.js`, `scripts/tai-font.py`, `scripts/kiem-tra-font.py`).

## [0.4.0] — 2026-10-05 — "Chặn lạm dụng thật và vá lỗ hổng toàn hệ thống"

**Bối cảnh:** sau báo cáo lần 2, đồ án rà lại toàn bộ điểm yếu đã biết và đọc
kỹ mã nguồn thêm một lượt. Ba việc chính: biến tuyên bố "6 tầng chống lạm dụng"
thành cơ chế chặn thật chạy ngay trong luồng tạo phiếu, vá các lỗ hổng tìm thấy
khi soát nginx và bộ script cài đặt, và mở rộng CI đủ chặt để pipeline đỏ nếu
cơ chế bị gỡ.

### Thêm mới

- **Plugin `pinedesk` (T3/T4/T6) chặn thật ngoài lõi.** Đăng ký hook công khai
  `PRE_ITEM_ADD` và `ITEM_ADD` của GLPI 11, kiểm tra trước khi phiếu được ghi và
  huỷ thao tác nếu vi phạm, không sửa một dòng nào trong lõi:
  - T3a: trần phiếu đang mở (mặc định 5) đếm theo trạng thái 1 đến 4;
  - T3b: trần phiếu/ngày (mặc định 10) đếm từ 0h hôm nay;
  - T4: chặn phiếu trùng trong cửa sổ 30 phút (cùng thiết bị, hoặc cùng loại sự
    cố và cùng vị trí), chỉ luôn sang phiếu cũ kèm thông báo tiếng Việt;
  - T6: nhật ký mọi lần tạo phiếu, kể cả lần bị chặn (`reason` = `NEW`,
    `DUP_BLOCKED`, `LIMIT_BLOCKED`).
  - Hạn mức nằm trong bảng `glpi_plugin_pinedesk_limits`, sửa bằng một câu UPDATE.
  - Miễn trừ: cron, tài khoản hệ thống, người có quyền cập nhật phiếu (kỹ thuật
    viên, quản trị).
  - Chống đua bằng `GET_LOCK` của MariaDB theo từng tài khoản; truy vấn lỗi thì
    cho phiếu đi qua (fail-open) và ghi `pinedesk.log`, ưu tiên không chặn oan.
- **Harness `plugins/pinedesk/tests/kiem-thu-han-muc.php`:** 686 dòng, 37 điểm
  kiểm chạy trên CSDL thật (tạo đủ 5 phiếu, phiếu thứ 6 bị chặn, phiếu trùng bị
  chặn, kỹ thuật viên và cron không bị chặn, nhật ký đúng), tự dọn dẹp sau khi
  chạy. CI chạy harness trong job `smoke`.
- **`scripts/kiem-tra-chuc-nang.sh`:** kiểm thử chức năng theo vai trò (quản trị,
  kỹ thuật, tự phục vụ), xác thực bằng biến môi trường `GLPI_USER`/`GLPI_PASS`.
- **Thư viện dùng chung:** `scripts/lib/doc-env.sh` (đọc `.env` an toàn, không
  `source`, xử lý CRLF) và `scripts/lib/ssl-cert.sh` (sinh chứng chỉ SAN, dùng
  chung cho `start.sh` và script cài đặt).
- **CI mở rộng từ 32 lên 43 bước** (936 dòng), thêm các cửa: PHP lint bằng
  `php:8.4-cli` khớp PHP 8.4.13 trong container, kiểm guard `:?` của compose,
  Redis cache, chạy harness plugin, chống giả mạo `X-Forwarded-For`, 429 cho
  đường PATH_INFO, 429 cho `/Form/SubmitAnswers`, seed chạy lại không nhân đôi,
  hợp đồng ngày tháng, đăng nhập tài khoản demo, từ điển 556 + 212. Thêm
  `timeout-minutes: 20` để job dừng thay vì treo vô hạn.

### Sửa (lỗ hổng và lỗi thật)

- **nginx, đường lách rate limit:** các location khớp chính xác bị lách bằng hậu
  tố (`/front/login.php/x`). Thêm neo `(/|$)` cho mọi location nghiệp vụ.
- **nginx, `/Form/SubmitAnswers` hở:** đường biểu mẫu GLPI 11 rơi vào
  `general_zone` (600 request/phút) thay vì `ticket_zone`. Đo trên hệ thống đang
  chạy: 12 POST liên tiếp cho 0 lần 429; sau khi thêm location, 429 ngay ở
  request thứ 12, khớp đường `/front/ticket.form.php`.
- **nginx, regex API chết:** mẫu `^/api/` không bao giờ khớp; sửa thành
  `^/(apirest|api)\.php(/|$)` để giới hạn đúng đường API.
- **nginx, giả mạo `X-Forwarded-For`:** ghi đè bằng `$remote_addr` nên IP giả từ
  client bị loại bỏ trước khi GLPI đọc.
- **nginx, `/tai-lieu/` phục vụ mọi tệp:** thêm allowlist chỉ `.md`, `.png`,
  `.html`; các tệp khác trả 404 (trước đây tệp `.docx` cá nhân lộ ra ngoài).
- **nginx, HTTPS_PORT và header:** chuyển cấu hình sang template `envsubst` để
  đổi cổng không cần sửa file; health endpoint dùng `default_type`; bỏ
  `add_header` ở chỗ làm mất header bảo mật.
- **`docker-compose.yml`:** mọi mật khẩu bắt buộc có guard `:?` (thiếu là compose
  từ chối chạy ngay); log GLPI vào named volume `pinedesk-glpi-logs` (sống sót
  qua `down -v`); mount plugin `pinedesk`.
- **Cài đặt trên máy sạch:** kiểm tra `.env` trước khi khởi động, từ chối mật khẩu
  còn nguyên chuỗi mẫu `<DOI_MAT_KHAU_MANH_TAI_DAY>` (trước đây compose nhận
  chuỗi mẫu như mật khẩu thật); kiểm tra `HTTPS_PORT` đúng dạng số; sinh chứng chỉ
  SSL trước `compose up`; cấu hình Redis `cache:configure` qua DSN truyền bằng
  stdin; đặt `url_base`; thêm bước dữ liệu demo, Việt hoá dữ liệu và giao diện vào
  luồng cài; lỗi dịch đặt `LOI=1`.
- **Dữ liệu mẫu, tài khoản demo:** JOIN hồ sơ quyền chỉ khớp tên tiếng Anh nên
  trên máy cài giao diện tiếng Việt, 6 tài khoản demo không được gán hồ sơ và
  đăng nhập trả HTTP 400. Nay JOIN khớp cả tên tiếng Anh lẫn tiếng Việt.
- **Dữ liệu mẫu, tra cứu theo tên:** thay id hardcode bằng tra cứu theo tên
  (`requesttypes_id`, tài khoản kỹ thuật) để seed không lệch khi id đổi.
- **Dữ liệu mẫu, hợp đồng ngày tháng:** mọi phiếu mẫu có `date_creation` bằng
  `date`; 16 phiếu trước đây lệch 216 đến 672 giờ. Mục §6.5 vá hồi tố chỉ áp cho
  13 phiếu demo theo tên, không đụng phiếu người dùng thật. CI chốt 0 vi phạm
  (`date_creation > date`, `solvedate < date_creation`, `time_to_own < date_creation`).
- **Dữ liệu mẫu, dọn dẹp:** xoá vị trí mồ côi và 6 nhóm mồ côi (có kiểm tra thay
  thế trước khi xoá); chốt bất biến đúng một loại yêu cầu mặc định.
- **`backup/backup.sh`:** `--keep` phải là số nguyên từ 1 trở lên (trước đây giá
  trị lạ có thể xoá luôn bản vừa sao lưu); giữ theo từng bộ theo timestamp; bỏ
  che stderr để lỗi thật hiện ra. Toàn bộ script đọc mật khẩu qua `MYSQL_PWD`
  trong `docker exec sh -c`, không truyền qua tham số dòng lệnh.
- **`plugins/dlubrand`:** bỏ hook ngôn ngữ chết (không thể chạy do thứ tự
  `LoadLanguage` của GLPI, có ghi chú lý do); vá lỗi NaN trong `dlu-canh.js`;
  thêm mức ưu tiên 6 "Chính"; logo thu gọn cho thanh điều hướng.
- **`scripts/viet-hoa-du-lieu.sh`:** tắt dashboard demo giả (114,7K phần mềm /
  1,5K phiếu) và banner demo; Việt hoá mức CSDL cho ô helpdesk và biểu mẫu (GLPI
  ghi tiếng Anh lúc cài trước khi lớp phủ `.mo` kịp nạp).
- **`scripts/kiem-tra-lam-dung.sh`:** logic phát hiện trùng viết lại khớp ngữ nghĩa
  plugin (self-join theo phút bằng `TIMESTAMPDIFF`); thêm kiểm tra dạng số cho
  hạn mức; cờ `--thuc-thi` ghi nhật ký vi phạm.
- **`scripts/quet-bi-mat.sh`:** loại trừ mẫu `login_password=%s` (báo động giả).

### Thay đổi

- Tài liệu cập nhật trạng thái thật từng tầng: `CHONG-LAM-DUNG.md` (T3/T4/T6
  chuyển sang "đã dựng thật"), `CAU-HOI-PHAN-BIEN.md` (B1, B3, B4, B5), slide bảo
  vệ, `KICH-BAN-DEMO.md`. Đính chính câu "muốn tự động hoá T5 phải móc vào lõi
  GLPI": không đúng, hook công khai đã chứng minh ngược lại.
- `README.md`, `PRODUCT.md`, landing page: 556 thuật ngữ dịch bổ sung + 212 mục
  dạng số nhiều, độ phủ 32,0% (2.084/6.511 chuỗi).
- CI ghi rõ hai mốc số phiếu: 13 phiếu demo ở bước dữ liệu mẫu, 14 sau khi bước
  SLA thêm 1 phiếu mượn thiết bị.

### Ghi chú

- Các con số trong nhật ký này đo trên hệ thống chạy thật: harness 37/37, hợp
  đồng ngày tháng 0 vi phạm, 12 POST `/Form/SubmitAnswers` bị chặn từ request
  thứ 12.
- Hạn mức 5 phiếu mở / 10 phiếu ngày và cửa sổ 30 phút vẫn là đề xuất kỹ thuật,
  cần Trung tâm CNTT xác nhận trước khi dùng thật.
- Không sửa một dòng nào trong lõi GLPI; toàn bộ thay đổi nằm ở plugin, cấu hình,
  script và dữ liệu.

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
