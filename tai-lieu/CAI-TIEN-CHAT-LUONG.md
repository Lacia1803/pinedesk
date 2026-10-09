# CẢI TIẾN CHẤT LƯỢNG DỰ ÁN PINEDESK

> **Tài liệu này để làm gì?**
> Ghi lại **một đợt rà soát chất lượng toàn diện** sau khi hệ thống đã chạy
> được: đã tìm ra vấn đề gì, sửa thế nào, và **kiểm chứng bằng gì**.
> Dùng để viết phần "Kiểm thử và cải tiến" trong báo cáo thực tập, và để
> trả lời câu hỏi phản biện "em đã kiểm tra chất lượng đồ án như thế nào?".
>
> Ngày thực hiện: **08–09/10/2026** · Nhánh: `master`.
> Gồm hai đợt: (1) rà soát chất lượng (mục 1–6), (2) phản biện đa tác nhân
> (mục 7).

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
| 4 | Con số "42 điểm kiểm" nghi vấn sai | P0 | **Hoá ra ĐÚNG** — ghi rõ cách đếm + CI chốt | `KET QUA: 42/42 dat` |
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

### P0.4 — Con số "42 điểm kiểm": đính chính cách đếm

**Vấn đề.** Tài liệu nói harness `kiem-thu-han-muc.php` có **42 điểm kiểm**.
Khi đếm bằng `grep` thấy ít hơn số đó → nghi số liệu sai.

**Phát hiện.** Kiểm chứng bằng phân tích ngoặc: **42 là ĐÚNG**. Vì một lời gọi
nằm trong vòng lặp tạo **6 user tạm**, và một số lời gọi khác nằm trong khối
điều kiện (chỉ chạy khi tạo được phiếu E):

> 32 lời gọi tĩnh + 6 lần chạy trong vòng lặp + 4 lời gọi trong khối điều kiện = **42**.

Đây là ví dụ cho thấy **không được sửa số liệu theo cảm tính** — phải chạy thật.

**Đã làm.**
1. Ghi chú cách đếm ngay đầu file harness để người sau không "sửa" nhầm.
2. **Thêm một cửa CI** chốt con số: chạy harness rồi bắt output phải khớp
   `KET QUA: n/42 dat` — ai thêm/bớt `check()` mà quên cập nhật tài liệu thì
   pipeline đỏ (cùng triết lý với cửa "Từ điển Việt hoá phải đủ 556 + 212").

**Bằng chứng.** Chạy thật trên hệ thống đang sống:

```
KET QUA: 42/42 dat — CO CHE CHAN HOAT DONG THAT
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

# 4. Harness chống lạm dụng (42 điểm kiểm)
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
| Chống lạm dụng | harness plugin | ✅ **42/42** |
| Chức năng & phân quyền | `kiem-tra-chuc-nang.sh` (2 vai trò) | ✅ **25/25** |
| Use case end-to-end | Playwright + Chrome thật | ✅ **3/3** |
| Chống race (GET_LOCK) | 2 request song song | ✅ **đạt** (1/2 tạo được) |
| Chặn hạn mức qua HTTP thật | Playwright + Service Catalog | ✅ **đạt** |
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

## 7. Đợt phản biện đa tác nhân (multi-agent) và các lỗi tìm thêm

Sau khi hoàn tất đợt rà soát ở mục 1–6, đồ án được đưa ra **phản biện độc lập
bởi nhiều tác nhân AI khác nhau**, mỗi tác nhân đọc mã nguồn thật và đưa ra ý
kiến riêng. Người làm đóng vai trò **kiểm chứng viên cuối cùng**: không tin lời
nhận xét, mà tự grep/đọc code để xác nhận từng cáo buộc trước khi sửa.

### 7.1. Các cáo buộc và kết quả kiểm chứng

| Cáo buộc | Kiểm chứng | Kết luận |
|---|---|---|
| Tài liệu ghi `GET_LOCK('pinedesk_user_'.$uid, 5)` nhưng code là `pinedesk_hm_$uid, 3` | Đúng | **Lỗi thật** → sửa tài liệu |
| Tài liệu nói T3a "dùng view", code query thẳng bảng | Đúng một phần | Sửa câu chữ |
| T4 (chống trùng) lách được bằng cách đổi loại sự cố mỗi lần | Đúng | **Lỗ hổng thật** → vá |
| `GET_LOCK` chưa từng được test 2 request song song | Đúng | Thiếu bằng chứng → thêm test |
| `fail-open` khi lỗi CSDL không có giám sát | Đúng | Thêm nhật ký `FAIL_OPEN`/`LOCK_FAIL` |
| Harness chạy in-process, chưa test đường HTTP thật | Đúng | Thêm test HTTP thật |
| **SQL injection** qua `$DB->escape()` + nối chuỗi | **SAI** — mọi biến đều ép `int` | Bác bỏ |
| Redis `allkeys-lru` có thể mất phiên | Đúng về cơ chế | Ghi vào hạn chế |

Hai cáo buộc mạnh đã được xác minh là **đúng và là lỗi thật** (T4 lách, thiếu
test race); một cáo buộc **sai** đã bị bác bỏ bằng bằng chứng (SQL injection).

### 7.2. Ba lỗi thật được sửa trong đợt này

**a) Lỗ hổng T4 (chống trùng) lách được.** T4 cũ chỉ chặn khi cùng thiết bị
hoặc cùng loại + vị trí, nên trong 5 phiếu được phép, người dùng vẫn gửi được
nhiều phiếu **cùng tiêu đề** bằng cách đổi loại sự cố mỗi lần. Đã mở rộng T4
thêm điều kiện (c): cùng người + tiêu đề giống nhau (chuẩn hoá khoảng
trắng/hoa-thường). Thêm mục kiểm 4e; harness tăng từ 37 lên **42 điểm**.

**b) Một bản "vá" trước đó là mã chết.** Có bản thử thêm "trần tổng phiếu
trong cửa sổ" (gọi là T4c) để chống spam đổi loại. Nhưng kiểm chứng bằng phân
tích tập hợp cho thấy đó là **dead code**: `count_window ⊆ count_open` nên T3a
(chạy trước) đã chặn, T4c không bao giờ là người chặn đầu tiên. Đã gỡ cả khối
lẫn hàm — đây là ví dụ cho thấy **phải kiểm chứng cả bản sửa**, không chỉ bản gốc.

**c) Chưa chứng minh chống race.** `GET_LOCK` được viết để chống TOCTOU nhưng
chưa từng được kiểm bằng 2 request song song. Đã thêm
`scripts/kiem-tra-race-getlock.sh`: chạy 2 tiến trình PHP song song tạo phiếu ở
mức sát trần, khẳng định chỉ 1/2 thành công. Đã tích hợp vào CI.

### 7.3. Phát hiện quan trọng nhờ test qua HTTP thật

Test chặn hạn mức qua đường người dùng thật (`/Form/SubmitAnswers` + Chrome) lộ
ra điều mà harness in-process bỏ sót: cơ chế chặn **có** hoạt động (phiếu không
được ghi), nhưng khi bị chặn, lõi GLPI hiển thị **lỗi hệ thống chung bằng tiếng
Anh** ("Failed to submit form, please contact your administrator") thay vì thông
báo tiếng Việt thân thiện. Nguyên nhân: GLPI ném
`Exception("Failed to create ...")` tại `AbstractCommonITILFormDestination.php:187`
khi `add()` trả `false`, nuốt mất thông báo của plugin. Đây là hành vi của lõi
GLPI, không sửa được nếu không đụng lõi → đã ghi trung thực vào **hạn chế số 11**
của báo cáo và sửa lại tài liệu cho khỏi tuyên bố quá.

### 7.4. Bài học

- **Không tin lời nhận xét, kể cả của chính bản sửa.** Cáo buộc SQL injection
  nghe rất "nặng" nhưng sai; bản vá T4c nghe rất "hợp lý" nhưng là mã chết. Chỉ
  có đọc code và chạy thật mới phân định được.
- **Test in-process ≠ test đường thật.** Cùng một cơ chế, chạy qua HTTP thật mới
  lộ ra vấn đề thông báo mà in-process che mất.
- **Số liệu phải tự chốt.** Con số "điểm kiểm" được đưa vào CI để không bao giờ
  lệch khỏi thực tế.

---

*Tài liệu này mô tả các commit cải tiến chất lượng trên nhánh `master`. Nhật ký
thay đổi đầy đủ (theo định dạng Keep a Changelog) nằm ở [`../CHANGELOG.md`](../CHANGELOG.md).*
