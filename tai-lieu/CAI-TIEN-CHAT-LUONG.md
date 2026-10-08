# CẢI TIẾN CHẤT LƯỢNG DỰ ÁN PINEDESK

> **Tài liệu này để làm gì?**
> Ghi lại **một đợt rà soát chất lượng toàn diện** sau khi hệ thống đã chạy
> được: đã tìm ra vấn đề gì, sửa thế nào, và **kiểm chứng bằng gì**.
> Dùng để viết phần "Kiểm thử và cải tiến" trong báo cáo thực tập, và để
> trả lời câu hỏi phản biện "em đã kiểm tra chất lượng đồ án như thế nào?".
>
> Ngày thực hiện: **08/10/2026** · Commit: `18660f9` · Nhánh: `master`.

---

## 1. Vì sao có đợt rà soát này

Hệ thống đã chạy thật (4 container, 3 plugin, dữ liệu demo, CI 6 nhóm) và đã
có báo cáo. Nhưng "chạy được" chưa phải "chất lượng". Đợt rà soát này đi tìm
**những chỗ một người chấm kỹ sẽ bắt lỗi**, chia làm 3 mức:

| Mức | Ý nghĩa | Ví dụ |
|---|---|---|
| **P0** | Sai sót rõ ràng, phải sửa ngay | thiếu giấy phép, hướng dẫn tự mâu thuẫn |
| **P1** | Nên sửa để chuyên nghiệp hơn | thiếu lockfile, log không giới hạn |
| **P2** | Cân nhắc, không bắt buộc | pin digest, editorconfig |

**Nguyên tắc xuyên suốt:** mọi thay đổi phải **kiểm chứng được bằng lệnh chạy
thật**, không chỉ sửa cho đẹp trên giấy.

---

## 2. Bảng tổng hợp (nhìn nhanh)

| # | Vấn đề phát hiện | Mức | Trạng thái | Bằng chứng |
|---|---|---|---|---|
| 1 | README ghi "GPL v3" nhưng repo **không có** file giấy phép | P0 | Đã sửa | `LICENSE` (35 KB) |
| 2 | Nhánh `bao-cao-thuc-tap-dlu` lỗi thời, gây nhầm lẫn | P0 | Đã xử lý | `git ls-remote` chỉ còn `master` |
| 3 | Hướng dẫn phục hồi dạy `source .env` + `-p"$PW"` (tự mâu thuẫn bảo mật) | P0 | Đã sửa | Phục hồi thật, dữ liệu nguyên vẹn |
| 4 | Con số "37 điểm kiểm" nghi vấn sai | P0 | **Hoá ra ĐÚNG** — ghi rõ cách đếm + CI chốt | `KET QUA: 37/37 dat` |
| 5 | Không có lockfile / manifest phụ thuộc | P1 | Đã thêm | `npm ci` chạy OK |
| 6 | CI pin action bằng tag trôi nổi | P1 | Đã pin SHA | CI YAML hợp lệ |
| 7 | `docker-compose.yml` không giới hạn log | P1 | Đã thêm | `docker compose config` OK |
| 8 | Tài liệu dùng `docker-compose` v1 (đã EOL) | P1 | Đã thống nhất v2 | grep = 0 |
| 9 | `kiem-tra-chuc-nang.sh` mặc định mật khẩu `glpi` | P1 | Đã bắt buộc `GLPI_PASS` | Chạy thiếu biến → thoát 1 |
| 10 | Asset chết + rác workspace | P1 | Đã dọn | `git status` sạch |
| 11 | Test Playwright không chạy trong CI | P2 | Đã thêm vào CI | 3/3 use case đạt |
| 12 | Thiếu `.editorconfig` | P2 | Đã thêm | — |
| 13 | Bản vá plugin barcode không ghi rõ gắn với bản nào | P2 | Đã ghi cảnh báo | — |

---

## 3. Chi tiết từng thay đổi

### P0.1 — Thêm giấy phép `LICENSE`

**Vấn đề.** `README.md` ghi hệ thống theo **GPL v3** (vì dựa trên GLPI), nhưng
trong repo **không có tệp giấy phép nào**. Đây là lỗ hổng pháp lý: người dùng
không biết quyền và nghĩa vụ của mình.

**Đã làm.** Thêm `LICENSE` — văn bản GNU GPL-3.0 đầy đủ (35 KB), khớp với giấy
phép của GLPI mà hệ thống kế thừa.

**Bằng chứng.** `ls LICENSE` → có file; `README.md` mục "Giấy phép" nay trỏ
đúng.

---

### P0.2 — Xoá nhánh `bao-cao-thuc-tap-dlu` lỗi thời

**Vấn đề.** Remote còn một nhánh với **5 commit không nằm trong `master`**.
Nếu không rõ, người chấm có thể tưởng đồ án còn việc dang dở.

**Đã làm.** Trước khi xoá, **kiểm chứng nội dung nhánh đã nằm trong `master`**
(`git grep` các thay đổi chính: thứ tự nạp dữ liệu CI, `plugin:activate` không
nhận `-u`, fix copy plugin trên Linux — tất cả đều có trong `master`). Sau đó
xoá cả local lẫn remote.

**Bằng chứng.** `git ls-remote --heads origin` → chỉ còn `refs/heads/master`.

---

### P0.3 — Sửa hướng dẫn phục hồi tự mâu thuẫn với chuẩn bảo mật

**Vấn đề.** Dự án có quy ước rõ: **không truyền mật khẩu qua tham số dòng lệnh**
(vì `ps` đọc được). `scripts/lib/doc-env.sh` cấm `source .env`. Nhưng chính
tài liệu lại dạy ngược lại:

- `tai-lieu/README.md` dạy `set -a; . ./.env; set +a` (đúng cái bị cấm).
- `backup/backup.sh` in hướng dẫn `mariadb -p"$DB_ROOT_PASSWORD"` (lộ mật khẩu).

**Đã làm.** Cả hai nay dùng cách an toàn: shell **bên trong container** tự đọc
`$MARIADB_ROOT_PASSWORD` của chính nó rồi gán cho `MYSQL_PWD` — mật khẩu không
bao giờ xuất hiện trong `argv` của tiến trình nào trên máy host.

**Bằng chứng.** Chạy backup thật rồi **chạy đúng lệnh phục hồi mới**:

```
docker exec -i pinedesk-db sh -c \
  'MYSQL_PWD="$MARIADB_ROOT_PASSWORD" mariadb -u root "$1"' _ glpi < backup/..._db.sql
```

Kết quả: phục hồi thành công; kiểm tra lại CSDL vẫn đủ **17 máy tính / 14 phiếu**.

---

### P0.4 — Con số "37 điểm kiểm": đính chính cách đếm

**Vấn đề.** Tài liệu nói harness `kiem-thu-han-muc.php` có **37 điểm kiểm**.
Khi đếm bằng `grep` thấy chỉ **33 lời gọi `check()`** → nghi số liệu sai.

**Phát hiện.** Kiểm chứng bằng phân tích ngoặc: **37 là ĐÚNG**. Vì một lời gọi
nằm trong vòng lặp tạo **5 user tạm**:

> 32 lời gọi tĩnh + 5 lần chạy trong vòng lặp = **37**.

Đây là ví dụ cho thấy **không được sửa số liệu theo cảm tính** — phải chạy thật.

**Đã làm.**
1. Ghi chú cách đếm ngay đầu file harness để người sau không "sửa" nhầm.
2. **Thêm một cửa CI** chốt con số: chạy harness rồi bắt output phải khớp
   `KET QUA: n/37 dat` — ai thêm/bớt `check()` mà quên cập nhật tài liệu thì
   pipeline đỏ (cùng triết lý với cửa "Từ điển Việt hoá phải đủ 556 + 212").

**Bằng chứng.** Chạy thật trên hệ thống đang sống:

```
KET QUA: 37/37 dat — CO CHE CHAN HOAT DONG THAT
```

---

### P1.5 — Lockfile & manifest phụ thuộc

**Vấn đề.** `package.json` khai báo `playwright-core` nhưng **không có
lockfile** → cài đặt không tái lập được. Ba thư viện Python của
`scripts/sinh-ma-qr.py` (`qrcode`, `reportlab`, `requests`) chỉ nằm trong
chú thích. Không có `.dockerignore`.

**Đã làm.**
- `package-lock.json` đầy đủ (`resolved` + `integrity`), cài bằng `npm ci`.
- `requirements.txt` ghim khoảng phiên bản hợp lý.
- `.dockerignore` loại bí mật/rác khỏi build context.

**Bằng chứng.** `npm ci` → "added 1 package"; `package-lock.json` có dòng
`"integrity": "sha512-..."`.

---

### P1.6 — CI ghim action theo commit SHA

**Vấn đề.** `actions/checkout@v7`, `setup-python@v7`, `setup-node@v7` là **tag
trôi nổi** — có thể bị trỏ sang commit khác (rủi ro supply-chain).

**Đã làm.** Pin mỗi action theo **commit SHA** kèm chú thích phiên bản:
`actions/checkout@3d3c42e5... # v7.0.1` …

**Bằng chứng.** CI YAML parse hợp lệ; 6 job vẫn nguyên.

---

### P1.7 — Giới hạn log cho Docker

**Vấn đề.** Mặc định Docker dùng driver `json-file` **không giới hạn** → log
container phình vô hạn trên máy dev, có thể ngốn hàng GB.

**Đã làm.** Thêm anchor `x-logging` (json-file, 10 MB × 3 file) áp cho cả 4
service — khai báo một lần, sửa một chỗ là đổi hết.

**Bằng chứng.** `docker compose config` → cả 4 service đều có `logging`.

---

### P1.8 — Thống nhất `docker compose` v2

**Vấn đề.** README, `start.sh`, `scripts/viet-hoa-du-lieu.sh` còn dùng
`docker-compose` (v1, đã hết hỗ trợ), trong khi toàn bộ script khác dùng
`docker compose` (v2).

**Đã làm.** Đổi hết sang `docker compose`. Giữ fallback trong
`compose-guard.sh` (chấp nhận cả hai) — đó là chủ ý, không phải sót.

**Bằng chứng.** `grep -rn "docker-compose "` → 0 kết quả ngoài fallback.

---

### P1.9 — Script kiểm tra không dùng mật khẩu mặc định

**Vấn đề.** `scripts/kiem-tra-chuc-nang.sh` đặt `PASS="${GLPI_PASS:-glpi}"`.
Sau khi người dùng **đổi mật khẩu admin** (đúng như README yêu cầu), script
âm thầm đăng nhập bằng `glpi` và báo lỗi khó hiểu.

**Đã làm.** Bắt buộc `GLPI_PASS`, thiếu thì dừng kèm ví dụ (giống
`scripts/lib/browser.js`).

**Bằng chứng.** Chạy thiếu biến → in hướng dẫn và `EXIT=1`. Chạy đủ biến →
**25/25 kiểm tra đạt**.

---

### P1.10 — Dọn asset chết và rác workspace

**Vấn đề.** Tồn tại file/thư mục không dùng tới.

**Đã làm (có kiểm chứng từng thứ trước khi xoá):**
- Xoá `themes/dlu-logo.png` — grep toàn repo **không nơi nào tham chiếu**.
- Xoá 3 thư mục tên kỳ quặc `nginx/nginx.conf;C`, `nginx/conf.d/default.conf;C`,
  `nginx/ssl;C` (do lỗi sao chép trên Windows).
- Xoá `docs/`, `.tmp-check/`, `.playwright-mcp/`; thêm `docs/` vào `.gitignore`.

> **Lưu ý đã kiểm tra kỹ:** hai thư mục logo `themes/pics/logos/` và
> `plugins/dlubrand/public/pics/logos/` **không phải trùng lặp vô nghĩa** —
> chúng phục vụ **hai URL khác nhau** (favicon qua nginx vs logo qua CSS plugin).
> Ảnh `11-cau-hinh-nhan-qr.png` **cũng không xoá** vì có trong báo cáo. Việc
> "thấy trùng là xoá" sẽ làm hỏng giao diện — nên đã kiểm tra trước.

**Bằng chứng.** `git status` sạch; giao diện vẫn tải logo (kiểm tra chức năng
25/25 vẫn đạt mục "Logo DLU (200)").

---

### P2.11 — Đưa test end-to-end (Playwright) vào CI

**Vấn đề.** `scripts/kiem-tra-usecase.js` chạy 3 use case thật bằng trình duyệt
nhưng **chỉ chạy tay** — tài sản kiểm thử tốt bị bỏ phí.

**Đã làm.** Thêm bước "Use case thật end-to-end (Playwright)" vào job smoke.
Ba kịch bản: sinh viên nộp phiếu, sinh viên đặt mượn thiết bị, kỹ thuật viên mở
phiếu của sinh viên.

**Cẩn thận đã xử lý:** bước này **tạo phiếu thật** nên phải đặt **SAU** các
bước đếm số (SLA chốt "14 phiếu") và **TRƯỚC** các bước bom request; đồng thời
chờ 40 giây để xo rate-limit đăng nhập (`login_zone` 10r/m) tránh lỗi 429 giả.

**Bằng chứng.** Chạy thật (mô phỏng đúng thứ tự CI):

```
=== KET QUA USE CASE: 3 dat / 0 loi ===
```

---

### P2.12 — `.editorconfig`

**Đã làm.** Thống nhất thụt lề/charset/xuống dòng cho mọi trình soạn thảo.
`.gitattributes` lo lúc commit; file này lo lúc gõ.

---

### P2.13 — Ghi rõ bản vá plugin barcode

**Vấn đề.** `scripts/cai-plugin-qrcode.sh` vá plugin bên thứ ba bằng `sed`
(đổi `MAX_GLPI`, `$DB->query` → `doQuery`) — dễ vỡ khi plugin đổi phiên bản.

**Đã làm.** Thêm cảnh báo: bản vá viết riêng cho barcode **2.7.1**; nâng
`PLUGIN_VERSION` phải rà lại.

---

## 4. Cách tự kiểm chứng lại (cho hội đồng xem trực tiếp)

```bash
# 1. Kiểm tra nhanh toàn bộ (đúng các cửa CI, trừ smoke test)
make kiem-tra

# 2. Kiểm tra cú pháp PHP của plugin (cần Docker)
make cu-phap-php

# 3. Khởi động thật rồi chạy kiểm thử chức năng theo vai trò
make smoke
GLPI_USER=ktv.an GLPI_PASS='<mat-khau>' bash scripts/kiem-tra-chuc-nang.sh

# 4. Harness chống lạm dụng (37 điểm kiểm)
docker exec -u www-data pinedesk-glpi \
  php /var/www/glpi/plugins/pinedesk/tests/kiem-thu-han-muc.php

# 5. Ba use case end-to-end bằng trình duyệt thật
GLPI_PASS='<mat-khau>' node scripts/kiem-tra-usecase.js
```

---

## 5. Kết quả kiểm chứng sau khi hoàn tất

| Hạng mục | Lệnh | Kết quả |
|---|---|---|
| Cú pháp shell | `bash -n` (16 file) | ✅ đạt |
| Cú pháp JavaScript | `node --check` (12 file) | ✅ đạt |
| Cú pháp Python | `py_compile` | ✅ đạt |
| Lint shell nâng cao | ShellCheck `--severity=warning` | ✅ 0 lỗi |
| Cú pháp PHP plugin | `php -l` (4 file) | ✅ đạt |
| Cấu hình Docker | `docker compose config` | ✅ hợp lệ |
| Cấu hình Nginx | `nginx -t` trong container thật | ✅ hợp lệ |
| Quét bí mật | `scripts/quet-bi-mat.sh` | ✅ sạch |
| Chống lạm dụng | harness plugin | ✅ **37/37** |
| Chức năng & phân quyền | `kiem-tra-chuc-nang.sh` (2 vai trò) | ✅ **25/25** |
| Use case end-to-end | Playwright + Chrome thật | ✅ **3/3** |
| Phục hồi dữ liệu | lệnh phục hồi mới | ✅ dữ liệu nguyên vẹn |

---

## 6. Ghi chú về một quyết định có chủ ý

**Không pin cứng digest của image Docker.** Pin digest giúp tái lập tuyệt đối
nhưng **khiến hệ thống không nhận bản vá bảo mật tự động** của tag. Với đồ án
chạy trong mạng nội bộ, đánh đổi này không đáng. Thay vào đó, digest hiện tại
được **ghi trong chú thích** của `docker-compose.yml` kèm hướng dẫn pin nếu cần.

Đây là ví dụ cho thấy các quyết định kỹ thuật trong đồ án **đều có lý do**, không
phải làm theo thói quen.

---

*Tài liệu này mô tả commit `18660f9` trên nhánh `master`. Nhật ký thay đổi đầy
đủ (theo định dạng Keep a Changelog) nằm ở [`../CHANGELOG.md`](../CHANGELOG.md).*
