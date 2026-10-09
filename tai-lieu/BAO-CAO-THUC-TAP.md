BỘ GIÁO DỤC VÀ ĐÀO TẠO
TRƯỜNG ĐẠI HỌC ĐÀ LẠT
KHOA TOÁN - TIN HỌC

---

# BÁO CÁO THỰC TẬP TỐT NGHIỆP

## ĐỀ TÀI

# XÂY DỰNG HỆ THỐNG HỖ TRỢ KỸ THUẬT PINEDESK CHO TRƯỜNG ĐẠI HỌC ĐÀ LẠT TRÊN NỀN TẢNG GLPI 11

<br>

| | |
|---|---|
| **Chuyên ngành** | Công nghệ thông tin |
| **Sinh viên thực hiện** | Phùng Võ Quốc Hiển |
| **Mã số sinh viên** | 2212364 |
| **Lớp** | .................... |
| **Khóa** | .................... |
| **Giảng viên hướng dẫn** | .................................... |
| **Đơn vị thực tập** | Trường Đại học Đà Lạt |
| **Thời gian thực tập** | 21/09/2026 – 03/10/2026 |

<br>

**ĐÀ LẠT, THÁNG 10 NĂM 2026**

---

## LỜI CẢM ƠN

Trước khi trình bày nội dung báo cáo, em xin gửi lời cảm ơn chân thành tới Ban Giám hiệu Trường Đại học Đà Lạt và Ban Chủ nhiệm Khoa Toán - Tin học đã tạo điều kiện cho em thực hiện kỳ thực tập tốt nghiệp này.

Em cảm ơn giảng viên hướng dẫn đã dành thời gian định hướng đề tài, góp ý cho từng phiên bản và chỉ ra những chỗ em còn nói quá so với thực tế. Những nhận xét đó là lý do báo cáo này ghi rõ phần chưa làm được thay vì chỉ liệt kê kết quả.

Em cảm ơn các anh chị tại Trung tâm Công nghệ thông tin của Trường đã cung cấp thông tin về cách Trường đang vận hành hệ thống CNTT và tổ chức phòng thực hành máy tính.

Em cũng cảm ơn các bạn cùng lớp đã cùng trao đổi trong quá trình làm, đặc biệt ở phần kiểm thử giao diện và đọc lại báo cáo.

Do thời gian thực tập và kiến thức của bản thân còn hạn chế, báo cáo khó tránh khỏi thiếu sót. Em mong nhận được góp ý của quý thầy cô để hoàn thiện hơn.

*Đà Lạt, tháng 10 năm 2026*

**Sinh viên thực hiện**

Phùng Võ Quốc Hiển

---

## NHẬN XÉT CỦA ĐƠN VỊ THỰC TẬP

*(Phần này do Trung tâm Công nghệ thông tin, Trường Đại học Đà Lạt điền và ký xác nhận sau khi kết thúc kỳ thực tập.)*

<br><br><br><br><br><br><br><br><br><br>

**XÁC NHẬN CỦA ĐƠN VỊ THỰC TẬP**

*(Ký tên, đóng dấu)*

---

## MỤC LỤC

| Nội dung | Trang |
|---|---|
| Lời cảm ơn | i |
| Nhận xét của đơn vị thực tập | ii |
| Mục lục | iii |
| Danh mục các từ viết tắt | v |
| Danh mục bảng biểu | vi |
| Danh mục hình ảnh | vii |
| **PHẦN MỞ ĐẦU** | 1 |
| 1. Lý do chọn đề tài | 1 |
| 2. Mục tiêu của đề tài | 2 |
| 3. Đối tượng và phạm vi nghiên cứu | 2 |
| 4. Phương pháp thực hiện | 3 |
| 5. Bố cục của báo cáo | 3 |
| **CHƯƠNG 1. TỔNG QUAN VỀ ĐƠN VỊ THỰC TẬP** | 4 |
| 1.1. Trường Đại học Đà Lạt | 4 |
| 1.2. Khoa Toán - Tin học | 5 |
| 1.3. Trung tâm Công nghệ thông tin | 5 |
| 1.4. Hiện trạng tiếp nhận sự cố CNTT của Trường | 6 |
| **CHƯƠNG 2. CƠ SỞ LÝ THUYẾT VÀ CÔNG NGHỆ SỬ DỤNG** | 9 |
| 2.1. ITSM và ITIL | 9 |
| 2.2. GLPI | 9 |
| 2.3. Docker và Docker Compose | 10 |
| 2.4. Nginx | 11 |
| 2.5. Công cụ hỗ trợ phát triển | 11 |
| **CHƯƠNG 3. PHÂN TÍCH VÀ THIẾT KẾ HỆ THỐNG** | 13 |
| 3.1. Phân tích yêu cầu | 13 |
| 3.2. Kiến trúc tổng thể | 16 |
| 3.3. Nguyên tắc thiết kế: tùy biến nằm ngoài lõi | 17 |
| 3.4. Bảng màu Đà Lạt | 18 |
| 3.5. Cấu trúc mã nguồn | 19 |
| **CHƯƠNG 4. TRIỂN KHAI VÀ KIỂM THỬ** | 21 |
| 4.1. Tiến độ thực hiện từ đầu kỳ thực tập | 21 |
| 4.2. Các chức năng đã triển khai | 25 |
| 4.3. Kiểm thử và kết quả | 33 |
| **CHƯƠNG 5. ĐÁNH GIÁ, HẠN CHẾ VÀ HƯỚNG PHÁT TRIỂN** | 38 |
| 5.1. Kết quả đạt được | 38 |
| 5.2. Hạn chế của đề tài | 38 |
| 5.3. Hướng phát triển | 40 |
| 5.4. Bài học kinh nghiệm | 41 |
| **KẾT LUẬN VÀ KIẾN NGHỊ** | 42 |
| **TÀI LIỆU THAM KHẢO** | 44 |
| **PHỤ LỤC** | 46 |

---

## DANH MỤC CÁC TỪ VIẾT TẮT

| Từ viết tắt | Nghĩa đầy đủ | Nghĩa tiếng Việt |
|---|---|---|
| CI | Continuous Integration | Tích hợp liên tục |
| CNTT | — | Công nghệ thông tin |
| CSS | Cascading Style Sheets | Ngôn ngữ định kiểu trang |
| DLU | Dalat University | Trường Đại học Đà Lạt |
| GPL | GNU General Public License | Giấy phép công cộng GNU |
| HTTPS | HyperText Transfer Protocol Secure | Giao thức truyền siêu văn bản bảo mật |
| ITC | Information Technology Center | Trung tâm Công nghệ thông tin |
| ITIL | Information Technology Infrastructure Library | Thư viện hạ tầng công nghệ thông tin |
| ITSM | IT Service Management | Quản lý dịch vụ công nghệ thông tin |
| NAT | Network Address Translation | Chuyển đổi địa chỉ mạng |
| QR | Quick Response | Mã phản hồi nhanh |
| SAN | Subject Alternative Name | Tên thay thế trong chứng chỉ SSL |
| SLA | Service Level Agreement | Thỏa thuận mức dịch vụ |
| SSL | Secure Sockets Layer | Lớp bảo mật truyền thông |
| TTO | Time to Own | Thời gian phản hồi ban đầu |
| TTR | Time to Resolution | Thời gian giải quyết |

---

## DANH MỤC BẢNG BIỂU

| Số hiệu | Tên bảng | Trang |
|---|---|---|
| Bảng 2.1 | Bốn dịch vụ trong hệ thống | 10 |
| Bảng 3.1 | Ba mâu thuẫn và dữ kiện công khai | 13 |
| Bảng 3.2 | Bảng màu Đà Lạt trích từ logo Trường | 18 |
| Bảng 3.3 | Phân bố mã nguồn theo loại tệp | 19 |
| Bảng 4.1 | Nhật ký thực hiện theo giai đoạn | 21 |
| Bảng 4.2 | Số liệu tài sản trong dữ liệu mẫu | 26 |
| Bảng 4.3 | Phân bố phiếu sự cố theo trạng thái | 27 |
| Bảng 4.4 | Năm mức thời gian đề xuất | 28 |
| Bảng 4.5 | Sáu tầng chống lạm dụng nộp phiếu | 30 |
| Bảng 4.6 | Hạn mức nghiệp vụ | 31 |
| Bảng 4.7 | Kết quả kiểm tra chức năng theo vai trò | 34 |
| Bảng 4.8 | Sáu nhóm kiểm tra trong pipeline CI | 36 |
| Bảng 4.9 | Mười ba vấn đề phát hiện khi rà soát chất lượng và cách xử lý | 37 |
| Bảng 4.10 | Kết quả kiểm chứng sau đợt rà soát chất lượng | 37 |
| Bảng 5.1 | Hạn chế của đề tài | 38 |

---

## DANH MỤC HÌNH ẢNH

| Số hiệu | Tên hình | Trang |
|---|---|---|
| Hình 3.1 | Kiến trúc tổng thể hệ thống | 16 |
| Hình 3.2 | Cây thư mục mã nguồn | 19 |
| Hình 4.1 | Trang đăng nhập | 25 |
| Hình 4.2 | Bảng điều khiển | 26 |
| Hình 4.3 | Danh sách máy tính | 26 |
| Hình 4.4 | Chi tiết thiết bị | 27 |
| Hình 4.5 | Danh sách phiếu yêu cầu | 27 |
| Hình 4.6 | Biểu mẫu tạo phiếu mới | 28 |
| Hình 4.7 | Mã QR trên hồ sơ thiết bị | 29 |
| Hình 4.8 | Kết quả sinh mã QR hàng loạt | 29 |
| Hình 4.9 | Sơ đồ sáu tầng chống lạm dụng | 30 |
| Hình 4.10 | Cơ cấu tổ chức | 31 |
| Hình 4.11 | Thống kê toàn cầu | 32 |

*Ghi chú: hình ảnh minh chứng đầy đủ nằm trong thư mục `tai-lieu/anh-giao-dien/` của mã nguồn, gồm 18 ảnh chụp giao diện thật.*

---

# PHẦN MỞ ĐẦU

## 1. Lý do chọn đề tài

Trường Đại học Đà Lạt có hơn 14.500 người học, nhưng Trung tâm Công nghệ thông tin (ITC), đơn vị phụ trách vận hành hệ thống CNTT và tổ chức phòng thực hành máy tính, chỉ có 5 nhân sự. Theo công bố trên website của Trung tâm, kênh tiếp nhận sự cố gồm một hotline, một email và một form liên hệ, mở trong giờ hành chính từ 7h30 đến 16h30 các ngày thứ Hai đến thứ Sáu. Trường không công bố một hệ thống tiếp nhận sự cố nào có phân công, trạng thái hay cam kết thời gian xử lý.

Từ ba dữ kiện trên, em nhận thấy ba khoảng trống:

- Tỉ lệ nhân sự phục vụ khoảng 1 người cho 2.900 người học, cao hơn nhiều so với mức thông thường của một bộ phận hỗ trợ nội bộ.
- Khoảng 73% thời gian trong tuần nằm ngoài khung giờ tiếp nhận, trong khi sự cố phòng máy vẫn xảy ra vào lớp tối, cuối tuần và mùa thi.
- Yêu cầu đến qua kênh phi cấu trúc (điện thoại, email, gặp trực tiếp) nên dễ thất lạc, không đo được và không truy vết được.

Đây là lý do em chọn đề tài: dựng một hệ thống tiếp nhận và quản lý sự cố có cấu trúc, chạy được thật, phù hợp với cách Trường đang vận hành. Ba con số trên là dữ kiện công khai có nguồn, còn các suy luận rút ra từ chúng là lập luận chứ không phải số đo.

## 2. Mục tiêu của đề tài

1. Dựng một hệ thống hỗ trợ kỹ thuật hoàn chỉnh chạy trên nền GLPI 11: quản lý tài sản CNTT, tiếp nhận phiếu sự cố theo quy trình, phân công xử lý, theo dõi trạng thái và thống kê.
2. Bản địa hóa hệ thống cho Trường Đại học Đà Lạt: giao diện tiếng Việt, bảng màu lấy từ logo Trường, dữ liệu nghiệp vụ dựng sẵn theo cơ cấu thật.
3. Bổ sung lớp chống lạm dụng nhiều tầng, vì kênh nộp phiếu mở cho sinh viên nên phải tính đến việc bị spam.
4. Đóng gói toàn bộ thành một quy trình cài đặt một lệnh, kèm kiểm thử tự động, để hệ thống tái lập được trên máy khác.
5. Trung thực ghi lại những gì chưa làm được, vì đề tài chưa được ITC phê duyệt và nhiều con số vẫn là đề xuất.

## 3. Đối tượng và phạm vi nghiên cứu

**Đối tượng nghiên cứu:** quy trình tiếp nhận, phân công và theo dõi sự cố thiết bị CNTT trong môi trường phòng máy của một trường đại học.

**Phạm vi thực hiện:**

- Hệ thống chạy nội bộ bằng Docker Compose trên một máy, truy cập qua HTTPS tại `https://localhost:8443`.
- Dữ liệu nghiệp vụ mô phỏng theo cơ cấu của Trường (12 tòa nhà, 54 phòng máy, 16 khoa, 79 loại sự cố), không phải dữ liệu thật.
- Đề tài **không** triển khai trên hạ tầng thật của Trường và **chưa** được ITC phê duyệt.
- Đề tài **không** đo hiệu năng khi có nhiều người dùng đồng thời; đây là hạn chế được nêu ở mục 5.2.

**Phạm vi thời gian:** từ ngày 21/09/2026 đến ngày 03/10/2026.

## 4. Phương pháp thực hiện

Em làm theo trình tự sau, mỗi bước đều để lại sản phẩm kiểm chứng được:

1. **Khảo sát:** thu thập dữ kiện công khai từ website Trường và ITC, ghi rõ URL và ngày truy cập.
2. **Chọn nền tảng:** cân nhắc giữa tự viết, dùng công cụ đám mây và dùng một nền ITSM mã nguồn mở.
3. **Dựng hệ thống:** cài GLPI 11 trong Docker, cấu hình danh mục nghiệp vụ, viết plugin giao diện, viết script tự động hóa.
4. **Kiểm thử:** viết script kiểm tra chức năng theo từng vai trò, chạy use case thật bằng trình duyệt, dựng pipeline CI.
5. **Sửa lỗi và ghi lại:** mỗi lỗi tìm được đều được sửa và ghi vào nhật ký thay đổi, kèm cách tái hiện.

Một nguyên tắc em giữ xuyên suốt: **luôn kiểm tra bằng trình duyệt thật, không chỉ bằng dòng lệnh**. Có những lỗi chỉ hiện ra khi trình duyệt tải cả trang, ví dụ giới hạn tần suất của Nginx đánh sập trang khi GLPI nạp hàng trăm tệp CSS và JavaScript cùng lúc, hay lỗi logo trả về 404 do một biểu thức chính quy viết sai. Chỉ dùng `curl` thì không bao giờ thấy được những lỗi này.

## 5. Bố cục của báo cáo

Báo cáo gồm phần mở đầu, năm chương, kết luận, tài liệu tham khảo và phụ lục:

- **Chương 1** giới thiệu đơn vị thực tập: Trường Đại học Đà Lạt, Khoa Toán - Tin học, Trung tâm Công nghệ thông tin, và hiện trạng tiếp nhận sự cố CNTT của Trường.
- **Chương 2** trình bày cơ sở lý thuyết và các công nghệ đã dùng.
- **Chương 3** phân tích yêu cầu và thiết kế hệ thống.
- **Chương 4** trình bày tiến độ thực hiện từ đầu kỳ thực tập, các chức năng đã triển khai và kết quả kiểm thử.
- **Chương 5** đánh giá kết quả, nêu hạn chế và hướng phát triển.

---

# CHƯƠNG 1. TỔNG QUAN VỀ ĐƠN VỊ THỰC TẬP

## 1.1. Trường Đại học Đà Lạt

Trường Đại học Đà Lạt được thành lập năm 1976, là trường đại học công lập trực thuộc Bộ Giáo dục và Đào tạo, đóng tại số 01 Phù Đổng Thiên Vương, thành phố Đà Lạt, tỉnh Lâm Đồng.

Về quy mô, Trường có hơn 14.500 người học theo số liệu công bố trên website. Cơ cấu tổ chức gồm các khoa đào tạo, các phòng ban chức năng và các trung tâm. Trong đó, Khoa Toán - Tin học là khoa có chuyên ngành gần nhất với đề tài này, và Trung tâm Công nghệ thông tin là đơn vị vận hành hạ tầng CNTT cùng hệ thống phòng thực hành máy tính.

## 1.2. Khoa Toán - Tin học

Khoa Toán - Tin học là đơn vị đào tạo chuyên ngành Công nghệ thông tin và Toán học của Trường. Theo công bố trên website của Khoa, đơn vị có 15 cán bộ cơ hữu gồm 14 giảng viên và 1 chuyên viên hành chính; tỉ lệ giảng viên có trình độ tiến sĩ đạt 80%, trong đó có 1 Giáo sư và 2 Phó Giáo sư. Ngoài đội ngũ cơ hữu, Khoa còn có giảng viên biên chế Trường sinh hoạt chuyên môn tại Khoa và giảng viên thỉnh giảng.

Đây là đơn vị quản lý trực tiếp kỳ thực tập của em, đồng thời là nơi đặt đề tài. Báo cáo này được thực hiện dưới sự hướng dẫn của giảng viên thuộc Khoa.

## 1.3. Trung tâm Công nghệ thông tin

Trung tâm Công nghệ thông tin (viết tắt theo tên tiếng Anh là ITC) có chức năng chính thức là "đơn vị quản lý và vận hành hệ thống Công nghệ thông tin của Trường, tổ chức phòng thực hành máy tính cho người học". Đây là căn cứ để phạm vi đề tài nằm đúng trong nhiệm vụ của Trung tâm.

Nguồn: `https://itc.dlu.edu.vn/gioi-thieu/`, truy cập ngày 02/10/2026.

Trung tâm có 5 nhân sự, phục vụ hơn 14.500 người học. Với khối lượng công việc như vậy, mọi thao tác tiếp nhận và xử lý sự cố cần được tự động hóa và ghi lại dữ liệu, vì không thể mở rộng bằng cách làm thủ công.

## 1.4. Hiện trạng tiếp nhận sự cố CNTT của Trường

Phần này dựa trên tài liệu [`tai-lieu/README.md`](README.md) của đề tài. Tài liệu đó phân loại mỗi thông tin thành ba mức: dữ kiện công khai có nguồn, suy luận từ dữ kiện, và giả định chưa kiểm chứng. Báo cáo giữ nguyên cách phân loại đó.

### 1.4.1. Ba mâu thuẫn

| Mã | Mâu thuẫn | Dữ kiện công khai | Suy luận |
|---|---|---|---|
| M1 | Quá tải nhân sự | 14.500+ người học; ITC có 5 nhân sự | Tỉ lệ khoảng 1 : 2.900 |
| M2 | Cửa sổ tiếp nhận hẹp | Hotline mở thứ Hai đến thứ Sáu, 7h30–16h30 | Khoảng 73% thời gian trong tuần không có kênh tiếp nhận |
| M3 | Không có kênh có cấu trúc | ITC công bố hotline, email và form liên hệ; không công bố hệ thống ticket | Yêu cầu dễ thất lạc, không đo được, không truy vết |

*Bảng 3.1. Ba mâu thuẫn và dữ kiện công khai*

Về M2, em tính cụ thể: một tuần có 168 giờ; khung tiếp nhận là 5 ngày nhân 9 giờ, tức khoảng 45 giờ mỗi tuần. Phần còn lại, khoảng 123 giờ, không có kênh tiếp nhận chính thức.

### 1.4.2. Hệ quả của kênh phi cấu trúc

Khi yêu cầu đến qua điện thoại hoặc gặp trực tiếp, sáu hệ quả thường gặp là:

- Thất lạc: không có bản ghi, người nhận quên là mất.
- Không đo được: không có dữ liệu về thời gian phản hồi và số lượng theo tuần.
- Không truy vết: không biết một máy đã hỏng mấy lần và đã sửa gì.
- Không công bằng: ai gọi to hơn hoặc gặp đúng người thì được ưu tiên.
- Khó bàn giao: người phụ trách nghỉ thì không ai biết đang tồn việc gì.
- Không có số liệu để đề xuất đầu tư: muốn xin mua thiết bị mới phải chứng minh bằng tần suất hỏng, nhưng không có dữ liệu.

### 1.4.3. PineDesk đáp ứng gì

| Mâu thuẫn | Cách hệ thống đáp ứng |
|---|---|
| M1 | Vai trò tự phục vụ cho sinh viên và giảng viên: tự nộp phiếu, tự tra cứu tình trạng, tự quét mã QR xem hồ sơ thiết bị, giảm số lần phải gọi hotline |
| M2 | Hệ thống chạy 24/7 qua HTTPS, nộp phiếu bất kể giờ nào; phiếu nằm trong hàng đợi có trạng thái nên sáng hôm sau mở ra là thấy |
| M3 | Phiếu có mã, có trạng thái, có người yêu cầu, có thiết bị gắn kèm, có nhật ký; toàn bộ truy vết được và thống kê được |

### 1.4.4. Vì sao không dùng công cụ sẵn có

Đây là câu hỏi chắc chắn được đặt ra, nên em phân tích thẳng.

**Google Form + Google Sheet:** phù hợp để thu thập, không phù hợp để vận hành quy trình. Form không có hàng đợi phân công, không có trạng thái chuẩn ITIL, không có SLA, không liên kết được phiếu với thiết bị theo khóa ngoại, và không có nhật ký thay đổi. Với 5 nhân sự phục vụ hơn 14.500 người, mọi thao tác phải tự động và mọi dữ liệu phải truy vết được; đọc Sheet thủ công không mở rộng nổi.

**GLPI gốc dùng ngay:** GLPI 11 đóng gói sẵn bản dịch tiếng Việt nhưng chỉ đạt khoảng 32% catalog; cơ sở dữ liệu rỗng hoàn toàn; không có logo, bảng màu, chứng chỉ SSL hay quy trình cài một lệnh. Nói cách khác, GLPI gốc là nguyên liệu thô, và phần việc của đề tài là bản địa hóa, dựng dữ liệu nghiệp vụ và tự động hóa.

**iTop hoặc ServiceNow:** ServiceNow có chi phí bản quyền doanh nghiệp, không phù hợp ngân sách một đề tài nội bộ. iTop có bản cộng đồng nhưng vẫn phải Việt hóa và cấu hình từ đầu với khối lượng công việc tương tự, trong khi cộng đồng GLPI lớn hơn.

---

# CHƯƠNG 2. CƠ SỞ LÝ THUYẾT VÀ CÔNG NGHỆ SỬ DỤNG

## 2.1. ITSM và ITIL

ITSM (IT Service Management) là cách tổ chức hoạt động CNTT như một dịch vụ có quy trình, thay vì xử lý sự vụ tùy hứng. ITIL là bộ thực hành phổ biến nhất cho ITSM. Hai khái niệm của ITIL mà đề tài dùng trực tiếp:

- **Ticket (phiếu yêu cầu):** mọi yêu cầu đều có một bản ghi với mã, trạng thái, người yêu cầu, người xử lý và lịch sử thay đổi.
- **SLA (Service Level Agreement):** mức cam kết về thời gian, thường tách thành thời gian phản hồi (TTO) và thời gian giải quyết (TTR), gắn với mức ưu tiên.

Điểm cần nói về mặt thiết kế: ITIL không bắt buộc phải có phần mềm đắt tiền. Nó là quy trình, và GLPI là công cụ triển khai quy trình đó.

## 2.2. GLPI

GLPI là phần mềm ITSM mã nguồn mở, phát hành theo giấy phép GPL v3. Đề tài dùng GLPI 11.0.0, chạy trên PHP 8.4.13. GLPI cung cấp sẵn lõi nghiệp vụ mà đề tài cần: quản lý tài sản (máy tính, màn hình, máy in, thiết bị mạng, phần mềm), quy trình phiếu yêu cầu, định nghĩa SLA, phân quyền theo hồ sơ, và hệ thống plugin.

Điểm mấu chốt khiến đề tài chọn GLPI: toàn bộ phần tùy biến của đề tài nằm **ngoài lõi**. Đề tài không sửa một dòng nào trong mã nguồn GLPI. Nhờ vậy, khi GLPI ra bản mới, việc nâng cấp không làm mất công sức đã bỏ ra. Đây là khác biệt về kiến trúc so với việc tự viết lại từ đầu.

## 2.3. Docker và Docker Compose

Docker đóng gói mỗi thành phần vào một container riêng, có môi trường cố định. Docker Compose định nghĩa cả cụm dịch vụ trong một tệp YAML. Đề tài dùng cách này vì nó cho phép cài đặt lại toàn bộ hệ thống bằng một lệnh, và mỗi thành phần được cô lập nên dễ bảo trì.

Bốn dịch vụ trong hệ thống:

| Container | Image | Vai trò |
|---|---|---|
| `pinedesk-gateway` | `nginx:1.27-alpine` | Cổng vào HTTPS, giới hạn tần suất, chặn tệp nhạy cảm |
| `pinedesk-glpi` | `glpi/glpi:11.0.0` | Ứng dụng chính |
| `pinedesk-db` | `mariadb:10.11` | Cơ sở dữ liệu |
| `pinedesk-redis` | `redis:7-alpine` | Bộ nhớ đệm |

*Bảng 2.1. Bốn dịch vụ trong hệ thống*

Cơ sở dữ liệu và Redis chỉ giao tiếp trong mạng nội bộ Docker, không mở cổng ra ngoài.

## 2.4. Nginx

Nginx làm cổng vào duy nhất. Ngoài việc chuyển tiếp yêu cầu tới GLPI, Nginx còn gánh ba việc bảo mật: bắt buộc HTTPS, giới hạn tần suất theo IP, và chặn truy cập vào các tệp nhạy cảm như `.env`, `.git`, tệp `.sql`, tệp log. Phần giới hạn tần suất được trình bày kỹ ở mục 4.2.5.

## 2.5. Công cụ hỗ trợ phát triển

- **Playwright** (`playwright-core`): điều khiển Chrome có sẵn trên máy để chụp ảnh minh chứng và chạy kiểm thử giao diện. Đề tài chọn `playwright-core` thay vì `playwright` vì bản đầy đủ tải kèm một bản Chromium riêng nặng khoảng 150 MB, trong khi máy đã có Chrome và chỉ cần điều khiển nó.
- **Python:** các script Việt hóa (gộp bản dịch, đo độ phủ, sinh mã QR).
- **Bash:** các script cài đặt, nạp dữ liệu, kiểm tra.
- **GitHub Actions:** chạy kiểm thử tự động mỗi lần đẩy mã nguồn.

---

# CHƯƠNG 3. PHÂN TÍCH VÀ THIẾT KẾ HỆ THỐNG

## 3.1. Phân tích yêu cầu

Từ ba mâu thuẫn ở mục 1.4.1, đề tài rút ra các yêu cầu chức năng và phi chức năng sau.

**Yêu cầu chức năng:**

| Mã | Yêu cầu | Nguồn |
|---|---|---|
| F1 | Quản lý tài sản CNTT: máy tính, màn hình, máy in, thiết bị mạng, phần mềm | M3 |
| F2 | Tiếp nhận phiếu sự cố theo vòng đời chuẩn ITIL | M3 |
| F3 | Phân công phiếu cho kỹ thuật viên và theo dõi trạng thái | M3 |
| F4 | Gắn phiếu với thiết bị liên quan và tra cứu hồ sơ thiết bị bằng mã QR | M1, M3 |
| F5 | Thống kê số thiết bị, số sự cố, lịch bảo trì theo thời gian | M3 |
| F6 | Vai trò tự phục vụ cho sinh viên và giảng viên | M1 |
| F7 | Bảo trì định kỳ và luồng mượn/trả thiết bị | M3 |

**Yêu cầu phi chức năng:**

| Mã | Yêu cầu | Nguồn |
|---|---|---|
| N1 | Chạy 24/7, nộp phiếu bất kể giờ nào | M2 |
| N2 | Giao diện tiếng Việt, bảng màu theo nhận diện Trường | Bản địa hóa |
| N3 | Chống lạm dụng khi kênh nộp phiếu mở cho sinh viên | Câu hỏi phản biện của giảng viên hướng dẫn |
| N4 | Cài đặt lại được bằng một lệnh, có kiểm thử tự động | Yêu cầu tái lập |
| N5 | Tùy biến nằm ngoài lõi GLPI để nâng cấp an toàn | Quyết định kiến trúc |

## 3.2. Kiến trúc tổng thể

```
Người dùng --HTTPS:8443--> [ Nginx Gateway ]
                                  |
                        HTTP:80   |
                                  v
                          [ GLPI 11 ] <--> [ Redis Cache ]
                                  |
                                  v
                            [ MariaDB 10.11 ]
```

*Hình 3.1. Kiến trúc tổng thể hệ thống*

Mỗi thành phần chạy trong một container riêng. Nginx là cửa vào duy nhất, giữ vai trò chấm dứt kết nối HTTPS rồi chuyển tiếp vào GLPI qua HTTP trong mạng nội bộ. MariaDB và Redis không mở cổng ra ngoài máy chủ.

## 3.3. Nguyên tắc thiết kế: tùy biến nằm ngoài lõi

Đây là quyết định kiến trúc quan trọng nhất của đề tài, và em giữ nó xuyên suốt.

GLPI cho phép ghi đè giao diện qua hai tầng. Tầng thứ nhất là bảng màu (palette), chỉ đăng ký tên để GLPI liệt kê trong phần thiết lập giao diện. Tầng thứ hai là CSS ghi đè, chứa toàn bộ mã màu và các chi tiết giao diện. Đề tài dùng một plugin tên `dlubrand` nạp CSS riêng qua hook `ADD_CSS` và `ADD_CSS_ANONYMOUS_PAGE`, nên giao diện được áp trên mọi trang, kể cả trang đăng nhập khi chưa có phiên làm việc.

Trong quá trình làm, em gỡ hẳn mã màu khỏi các tệp `themes/*.scss` để tránh lặp màu ở hai nơi. Hiện `themes/*.scss` chỉ còn vai trò "giấy đăng ký": tên tệp là khóa bảng màu, nội dung chỉ có chú thích. Toàn bộ mã màu giao diện GLPI nằm duy nhất trong `plugins/dlubrand/public/css/dlu-theme.css`. Muốn đổi màu thì sửa một tệp.

## 3.4. Bảng màu Đà Lạt

Bảng màu được trích từ logo chính thức của Trường.

| Mã | Màu | Ý nghĩa trong logo |
|---|---|---|
| `#F08418` | Cam đất | Vòng hoa văn, mặt trời |
| `#607824` | Xanh rêu | Núi, dòng chữ "ĐẠI HỌC ĐÀ LẠT" |
| `#90B43C` | Xanh lá | Sườn núi sáng |
| `#C0CC84` | Xanh nhạt | Đồi thông |
| `#CC2430` | Đỏ | Ngôi sao |
| `#3D4E17` | Xanh rêu đậm | Thanh menu |
| `#3E8E9E` | Xanh hồ | Gợi màu hồ Xuân Hương |

*Bảng 3.2. Bảng màu Đà Lạt trích từ logo Trường*

Hệ thống có ba bảng màu: `da_lat` (xanh rêu, mặc định), `da_lat_suong` (xanh hồ) và `da_lat_nang` (cam đất).

## 3.5. Cấu trúc mã nguồn

```
pinedesk/
├── .github/workflows/ci.yml     # Pipeline kiểm tra tự động (6 nhóm)
├── docker-compose.yml           # Định nghĩa 4 dịch vụ
├── .env                         # Biến môi trường (chứa mật khẩu, không commit)
├── package.json                 # Khai báo playwright-core
├── config/                      # Cấu hình PHP
├── nginx/                       # Cổng vào: HTTPS, giới hạn tần suất, bảo mật
├── themes/                      # Đăng ký tên bảng màu (không chứa mã màu)
├── plugins/dlubrand/            # Plugin giao diện Đà Lạt (nguồn màu duy nhất)
├── scripts/                     # Script tự động hóa (14 .sh, 7 .py, 7 .js)
├── backup/                      # Script sao lưu
└── tai-lieu/                    # Tài liệu và ảnh minh chứng
```

*Hình 3.2. Cây thư mục mã nguồn*

Quy mô mã nguồn tính đến ngày 03/10/2026: khoảng 21.027 dòng, phân bố như sau.

| Loại | Số tệp | Số dòng |
|---|---|---|
| Markdown | 13 | 5.613 |
| Python | 9 | 4.503 |
| CSS | 3 | 2.992 |
| JavaScript | 15 | 2.161 |
| Shell | 14 | 2.146 |
| SQL | 3 | 1.741 |
| HTML | 2 | 1.066 |
| YAML | 2 | 784 |
| JSON | 1 | 21 |

*Bảng 3.3. Phân bố mã nguồn theo loại tệp*

---

# CHƯƠNG 4. TRIỂN KHAI VÀ KIỂM THỬ

## 4.1. Tiến độ thực hiện từ đầu kỳ thực tập

Kỳ thực tập diễn ra từ ngày 21/09/2026 đến ngày 03/10/2026. Toàn bộ quá trình được ghi lại trong 12 lần đóng góp mã nguồn (commit) và bốn phiên bản phát hành (0.1.0 đến 0.4.0). Phần này kể lại tiến độ đó theo đúng thứ tự đã xảy ra, kể cả những lần phải làm lại.

### 4.1.1. Giai đoạn 1 (21/09 – 22/09/2026): Dựng nền tảng

Đây là giai đoạn đưa hệ thống từ con số không lên một bản chạy được.

Ngày 21/09, em khởi tạo hệ thống với tên ban đầu là "IT Helpdesk DLU", dựng bốn container Docker, viết script cài đặt và tài liệu triển khai. Cùng ngày, em thêm pipeline CI, sinh chứng chỉ SSL có SAN, và gỡ các chỗ hardcode đường dẫn máy cá nhân cùng mật khẩu.

Sau khi có bản chạy được, em tự chạy một vòng review đối kháng: đặt mình vào vai người phản biện, tìm lỗi trong chính mã mình vừa viết. Vòng đó phát hiện bốn vấn đề mức thấp và sáu lỗi cụ thể, trong đó đáng chú ý là tài liệu phục hồi sao lưu ghi sai đường dẫn (phải là `/var/glpi` trong container chứ không phải đường dẫn trên máy), và một số tuyên bố trong README mạnh hơn thực tế.

Ngày 22/09, em phát hiện và xử lý một rò rỉ bí mật: mã nguồn có chứa mật khẩu thật. Cách xử lý là viết script quét theo hình dạng mật khẩu thay vì liệt kê giá trị cụ thể, vì liệt kê giá trị thật trong script quét thì chính script đó lại thành chỗ rò rỉ. Cũng trong giai đoạn này, hệ thống được đổi tên thành PineDesk, và ảnh minh chứng được đưa vào README.

Kết thúc giai đoạn 1, đề tài đạt phiên bản 0.1.0 với: hạ tầng bốn container, HTTPS có SAN, giao diện Đà Lạt, plugin QR đã vá lỗi và giải mã kiểm chứng, 443 thuật ngữ Việt hóa, dữ liệu nền 23 nhóm danh mục, CI sáu nhóm, 5 tài liệu tiếng Việt và 19 ảnh minh chứng.

### 4.1.2. Giai đoạn 2 (02/10/2026): Từ lý thuyết sang nghiệp vụ thật

Đây là giai đoạn bước ngoặt, xuất phát từ nhận xét của giảng viên hướng dẫn sau báo cáo tiến độ lần 1.

Thầy nhận xét đồ án "còn lý thuyết, chưa thực tế" và đặt ba câu hỏi trực diện: nếu sinh viên spam thì sao, cơ chế để sinh viên nộp phiếu là gì, và đồ án giải quyết nhu cầu gì của Trường. Ba câu hỏi này định hình lại toàn bộ hướng làm.

Em bắt đầu bằng việc trả lời câu hỏi thứ ba. Thay vì nói chung chung rằng hệ thống "hữu ích", em thu thập dữ kiện công khai từ website Trường và ITC, phân loại rõ đâu là dữ kiện có nguồn, đâu là suy luận, đâu là giả định. Kết quả là tài liệu bài toán nghiệp vụ với ba mâu thuẫn M1, M2, M3 như đã trình bày ở Chương 1.

Câu hỏi thứ hai và thứ nhất dẫn tới phần chống lạm dụng. Em dựng sáu tầng phòng thủ và viết tài liệu giải thích từng tầng, ghi rõ tầng nào đã dựng thật, tầng nào còn ở mức quy trình. Cùng lúc, em thay tuyên bố suông về SLA bằng SLA thật trong cơ sở dữ liệu: 5 mức ưu tiên nhân 2 mốc, tổng cộng 10 bản ghi.

Trong giai đoạn này em cũng dựng hai chức năng nghiệp vụ dùng cơ chế gốc của GLPI: lịch bảo trì định kỳ (dùng bảng `glpi_ticketrecurrents`) và luồng mượn/trả thiết bị (dùng `glpi_reservationitems` và `glpi_reservations`). Chủ ý là không tạo bảng riêng, để sau này nâng cấp GLPI vẫn dùng được.

Ở lần chạy cài đặt đầu tiên của giai đoạn này, em gặp hai lỗi schema thật. Thứ nhất, biểu thức `DATE_SUB(@now, INTERVAL 3 DAY - INTERVAL 2 HOUR)` không hợp lệ vì MySQL không hỗ trợ trừ hai `INTERVAL`; phải đổi thành `INTERVAL 70 HOUR`. Thứ hai, cột `glpi_slalevels.exec_time` không tồn tại (đúng là `execution_time`), và `glpi_slas.type` là `NOT NULL`; lỗi này chặn cả bước nạp SLA. Cả hai đều được sửa và ghi vào nhật ký thay đổi.

Cũng trong giai đoạn 2, em đính chính một loạt tên riêng cho đúng với công bố chính thức của Trường: "Phòng Công nghệ thông tin" thành "Trung tâm Công nghệ thông tin (ITC)", tên miền `cict.dlu.edu.vn` thành `itc.dlu.edu.vn`, và một số tên phòng ban khác.

Kết thúc giai đoạn 2, đề tài đạt phiên bản 0.2.0. Đây là lúc đồ án chuyển từ một bản demo kỹ thuật thành một đề xuất có bài toán nghiệp vụ rõ ràng.

### 4.1.3. Giai đoạn 3 (03/10/2026): Chuẩn hóa số liệu và vá lỗi cài trên máy sạch

Giai đoạn cuối là lúc em kiểm chứng lại toàn bộ đề tài bằng cách xóa sạch dữ liệu rồi cài lại từ đầu, thay vì tin vào dữ liệu còn sót lại từ lần chạy trước. Cách này lộ ra một loạt lỗi mà trước đó bị che khuất.

**Phiên bản 0.3.0.** Em đối chiếu từng con số trong tài liệu với hệ thống chạy thật và tìm ra ba vấn đề. Thứ nhất, dữ liệu mẫu âm thầm thiếu 4 thiết bị: script dữ liệu mẫu tham chiếu tên vị trí không khớp với script danh mục (`'Văn phòng Khoa Toán - Tin'` thiếu chữ "học", `'Phòng Lab C101'` thay vì `'Phòng thí nghiệm C101'`), nên câu lệnh nối theo tên bỏ qua những dòng đó trong im lặng, kết quả chỉ có 15 máy tính thay vì 17. Thứ hai, script kiểm tra trang giới thiệu đặt tên biến `URL` che khuất hàm `URL` toàn cục của Node, khiến phần kiểm liên kết luôn báo lỗi và bỏ qua toàn bộ phần kiểm còn lại. Thứ ba, hai script đo độ phủ Việt hóa đọc hai nguồn khác nhau nên ra hai con số mâu thuẫn; em viết lại để cả hai cùng đọc tệp `.mo` đang cài.

**Phiên bản 0.4.0.** Sau khi sửa số liệu, em chạy lại toàn bộ trên máy sạch và phát hiện ba lỗi nghiêm trọng hơn, đều thuộc loại "im lặng": hệ thống không báo lỗi, chỉ thiếu dữ liệu hoặc chặn đăng nhập.

- Sáu tài khoản demo không có hồ sơ quyền. Script gán hồ sơ theo tên tiếng Việt, nhưng trên máy sạch GLPI tạo hồ sơ bằng tên tiếng Anh, còn script Việt hóa lại không nằm trong luồng cài. Kết quả là đăng nhập trả về lỗi 400. Kịch bản demo đăng nhập tài khoản sinh viên sẽ chết ngay trên bục.
- Bảng điều khiển hiện chế độ minh họa của GLPI. GLPI 11 bật sẵn chế độ dùng dữ liệu mẫu cho bảng điều khiển; script tắt nó đã có nhưng không được gọi trong luồng cài.
- Thương hiệu và dải màu ưu tiên không được áp. Script đặt tên ứng dụng và dải màu ưu tiên cũng không được gọi, nên trên máy sạch thẻ trình duyệt hiện "... - GLPI" và dải màu ưu tiên vẫn là màu mặc định của GLPI.

Cả ba lỗi có cùng một nguyên nhân gốc: các script cần thiết đã có sẵn nhưng không nằm trong luồng cài đặt. Cách sửa là đưa chúng vào đúng thứ tự trong `cai-dat-tat-ca.sh`, và thêm năm cửa kiểm mới vào pipeline CI để những lỗi này không quay lại.

Khi đẩy lên GitHub, chính pipeline bắt thêm một lỗi thứ tư mà em chưa thấy khi chạy tay: bước nạp SLA bị đặt trước bước nạp dữ liệu mẫu. Phần mượn/trả trong tệp SLA dựa trên hai laptop và hai tài khoản do dữ liệu mẫu tạo ra, nên khi chạy sai thứ tự, các câu lệnh đó khớp 0 dòng mà không báo lỗi, và cửa kiểm "Dữ liệu bảo trì + mượn thiết bị" thấy 0 thiết bị cho mượn thay vì 2. Em đổi thứ tự cho danh mục và dữ liệu mẫu chạy trước, đồng thời cho script nạp SLA tự kiểm phần bảo trì và mượn/trả để báo rõ khi thiếu dữ liệu mẫu. Đây là lần đầu pipeline phát hiện một lỗi thật mà chạy tay trên máy em không lộ ra.

Cũng trong phiên bản 0.4.0, em chuyển công cụ trình duyệt từ Puppeteer sang Playwright, sửa hai lỗi giao diện chỉ lộ ra khi đo màu thật trên trình duyệt ở cả chế độ sáng và tối, viết thêm hai script kiểm thử mới (`kiem-tra-chuc-nang.sh` kiểm chức năng theo vai trò và `kiem-tra-usecase.js` chạy ba use case thật), và dọn dẹp toàn bộ rác sinh ra khi chạy.

Bảng dưới tóm tắt tiến độ theo giai đoạn.

| Giai đoạn | Thời gian | Số commit | Phiên bản | Kết quả chính |
|---|---|---|---|---|
| 1. Dựng nền tảng | 21/09 – 22/09/2026 | 6 | 0.1.0 | Hạ tầng 4 container, HTTPS, giao diện, plugin QR, CI |
| 2. Từ lý thuyết sang nghiệp vụ | 02/10/2026 | 4 | 0.2.0 | Bài toán nghiệp vụ, chống lạm dụng, SLA thật, bảo trì, mượn/trả |
| 3. Chuẩn hóa và vá lỗi máy sạch | 03/10/2026 | 2 | 0.3.0, 0.4.0 | Vá 7 lỗi, chuyển Playwright, thêm kiểm thử, dọn dẹp |

*Bảng 4.1. Nhật ký thực hiện theo giai đoạn*

## 4.2. Các chức năng đã triển khai

### 4.2.1. Quản lý tài sản

Hệ thống quản lý máy tính, màn hình, máy in, thiết bị mạng và phần mềm. Mã tài sản theo quy ước thật của Trường: `TDL-PC-A101-001`, đọc là Đại học Đà Lạt, máy tính, tòa A, phòng 101, máy số 01. Tiền tố `TDL` khớp mã trường của DLU.

Số liệu dữ liệu mẫu đang có trong hệ thống:

| Loại | Số lượng |
|---|---|
| Máy tính | 17 |
| Màn hình | 5 |
| Máy in | 3 |
| Thiết bị mạng | 9 |
| Phần mềm | 10 |
| **Tổng tài sản phần cứng** | **34** |

*Bảng 4.2. Số liệu tài sản trong dữ liệu mẫu*

Danh mục nghiệp vụ kèm theo: 12 tòa nhà, 54 phòng máy, 16 khoa, 79 loại sự cố phân loại sẵn.

### 4.2.2. Tiếp nhận và xử lý phiếu sự cố

Phiếu yêu cầu đi theo vòng đời chuẩn ITIL: Mới → Được giao → Đã giải quyết → Đã đóng. Dữ liệu mẫu có 14 phiếu trải đủ các trạng thái.

| Trạng thái | Số phiếu |
|---|---|
| Mới | 4 |
| Được giao | 3 |
| Đã giải quyết | 4 |
| Đã đóng | 3 |

*Bảng 4.3. Phân bố phiếu sự cố theo trạng thái*

Người dùng nộp phiếu qua menu Hỗ trợ, điền tiêu đề, mô tả, loại sự cố, thiết bị liên quan và mức ưu tiên. Phiếu vào hàng đợi trạng thái Mới, kỹ thuật viên thấy trong danh sách và giao việc.

Phân quyền theo vai trò: sinh viên và giảng viên chỉ thấy phiếu của mình; kỹ thuật viên thấy phiếu của nhóm phụ trách; quản trị thấy toàn bộ.

### 4.2.3. Mức thời gian đề xuất (SLA)

Hệ thống có 5 định nghĩa SLA trong cơ sở dữ liệu, khớp 5 mức ưu tiên, mỗi mức có hai mốc: thời gian phản hồi và thời gian giải quyết.

| Mức ưu tiên | Phản hồi | Giải quyết | Dùng cho |
|---|---|---|---|
| Rất thấp | 8 giờ | 48 giờ | Sự cố không gấp |
| Thấp | 4 giờ | 24 giờ | Ảnh hưởng một người |
| Trung bình | 2 giờ | 8 giờ | Ảnh hưởng một lớp học |
| Cao | 1 giờ | 4 giờ | Nhiều lớp hoặc thiết bị mạng |
| Rất cao | 30 phút | 2 giờ | Máy chủ hoặc hạ tầng |

*Bảng 4.4. Năm mức thời gian đề xuất*

Trong cơ sở dữ liệu hiện có 10 bản ghi SLA (5 mức nhân 2 mốc).

Em phải nói rõ một điều: **các con số này là đề xuất kỹ thuật của em, chưa phải cam kết đã được Trường ban hành.** Muốn trở thành SLA thật phải có văn bản phê duyệt của ITC. Trước khi có văn bản đó, cách gọi đúng là "mức thời gian đề xuất", không phải "cam kết dịch vụ".

### 4.2.4. Mã QR cho thiết bị

Mỗi thiết bị có một mã QR in ra dán lên máy; quét mã sẽ mở đúng hồ sơ thiết bị đó. Đề tài dùng plugin Barcode phiên bản 2.7.1, phát hành tháng 7/2022 và chỉ hỗ trợ GLPI 10.0.x.

Khi cài trên GLPI 11, plugin gặp ba lỗi tương thích:

| Lỗi | Nguyên nhân | Cách xử lý |
|---|---|---|
| Báo không tương thích phiên bản | `setup.php` khai báo phiên bản GLPI tối đa là 10.0.99 | Nới lên 99.0.99 |
| Thiếu thư viện `vendor/` | Bản tải từ nhánh phát triển thiếu thư mục này | Dùng bản phát hành chính thức đã đóng gói sẵn |
| "Executing direct queries is not allowed" | GLPI 11 vô hiệu hóa `$DB->query()`, plugin cũ vẫn dùng | Đổi 9 chỗ sang `$DB->doQuery()` |

Ngoài ba lỗi trên, em còn tìm ra hai lỗi âm thầm, nghĩa là chúng không hiện thông báo lỗi mà chỉ im lặng không ra kết quả:

1. Bấm Create xong quay về danh sách nhưng không có tệp PDF nào. Nguyên nhân: thư mục `/var/glpi/files/_plugins/barcode/` không tồn tại, hàm ghi tệp thất bại mà không xử lý lỗi. Cách sửa: tạo thư mục và đặt quyền cho `www-data`.
2. Menu "Các hành động" không có tùy chọn in mã QR. Nguyên nhân: GLPI chưa cấp quyền cho plugin. Cách sửa: cấp quyền trong bảng quyền của hồ sơ.

Mã QR sinh ra đã được giải mã để kiểm chứng, không chỉ nhìn thấy hình.

### 4.2.5. Chống lạm dụng nộp phiếu

Đây là phần trả lời trực tiếp câu hỏi phản biện "nếu sinh viên spam thì sao". Vì kênh nộp phiếu mở cho sinh viên, hệ thống cần phòng thủ nhiều tầng, mỗi tầng chặn một kiểu hành vi khác nhau.

```
   Người dùng
       │
       ▼
  ┌─────────────────────────────────────────────┐
  │ T1  NGINX      giới hạn tần suất theo IP    │  chặn bot, bấm liên tục
  ├─────────────────────────────────────────────┤
  │ T2  PHIÊN      bắt buộc đăng nhập           │  chặn người ngoài
  ├─────────────────────────────────────────────┤
  │ T3  NGHIỆP VỤ  trần phiếu mỗi người mỗi ngày│  chặn lạm dụng theo tài khoản
  ├─────────────────────────────────────────────┤
  │ T4  CHỐNG TRÙNG cùng người + thiết bị + loại│  chặn nộp lặp
  ├─────────────────────────────────────────────┤
  │ T5  KIỂM DUYỆT  kỹ thuật viên xác nhận      │  chặn tự nâng khẩn cấp
  ├─────────────────────────────────────────────┤
  │ T6  NHẬT KÝ     ghi ai, khi nào, từ đâu     │  truy vết, xử lý sau
  └─────────────────────────────────────────────┘
```

*Hình 4.9. Sơ đồ sáu tầng chống lạm dụng*

Trạng thái thật của từng tầng:

| Tầng | Cơ chế | Trạng thái |
|---|---|---|
| T1 | Giới hạn tần suất tại endpoint nộp phiếu | Đã dựng |
| T2 | Bắt buộc đăng nhập, không cho nộp ẩn danh | Có sẵn của GLPI |
| T3 | Trần phiếu đang mở và số phiếu mỗi ngày | Đã dựng |
| T4 | Phát hiện phiếu trùng | Đã dựng |
| T5 | Kiểm duyệt trước khi giao việc | Quy trình, chưa tự động hóa |
| T6 | Nhật ký tạo phiếu | Đã dựng |

*Bảng 4.5. Sáu tầng chống lạm dụng nộp phiếu*

**Vì sao chọn ngưỡng 30 request mỗi phút cho tầng mạng, không chặt hơn.** Khuôn viên trường dùng NAT chung, cả phòng máy 35 đến 40 máy đi ra ngoài bằng một địa chỉ IP. Nếu đặt ngưỡng theo IP quá thấp, một lớp học đang thao tác có thể bị chặn oan: sinh viên thứ sáu trong phòng bấm lưu sẽ bị chặn dù hoàn toàn hợp lệ. Vì vậy tầng mạng giữ ngưỡng rộng có chủ đích, còn tầng nghiệp vụ mới siết chính xác theo tài khoản, vì tài khoản không bị NAT. Đây là quyết định thiết kế có lý do, không phải bỏ sót.

**Hạn mức nghiệp vụ** nằm trong bảng cấu hình, không hardcode trong mã:

| Tham số | Giá trị | Ý nghĩa |
|---|---|---|
| Số phiếu mở tối đa | 5 | Một người tối đa 5 phiếu đang mở cùng lúc |
| Số phiếu mỗi ngày | 10 | Tối đa 10 phiếu mỗi ngày mỗi người |
| Cửa sổ chống trùng | 30 phút | Khoảng thời gian phát hiện phiếu trùng |

*Bảng 4.6. Hạn mức nghiệp vụ*

**Quyết định không tự xóa phiếu.** Script kiểm tra chỉ báo cáo, không tự động xóa hay chặn phiếu. Lý do: xóa tự động có thể xóa nhầm phiếu thật của người dùng hợp lệ, và việc phán đoán một phiếu có lạm dụng hay không cần con người quyết định. Nhật ký để lại bằng chứng, kỹ thuật viên xem rồi xử lý.

### 4.2.6. Việt hóa

GLPI 11 đóng gói sẵn bản dịch tiếng Việt nhưng chỉ đạt khoảng 32% catalog. Đề tài bổ sung thêm 556 thuật ngữ và 212 mục dạng số nhiều, nâng độ phủ đo được lên 32,0% (2.084 trên 6.511 chuỗi).

Con số 32% cần được hiểu đúng. Đây là tỉ lệ trên toàn bộ catalog, kể cả những chuỗi kỹ thuật dài mà người dùng cuối không bao giờ thấy, như thông báo lỗi dòng lệnh hay cảnh báo hệ thống. Phần giao diện mà người dùng thực sự chạm vào gần như đã là tiếng Việt: menu chính, thanh bên, tiêu đề bảng, nhãn biểu mẫu, nút bấm, nhãn trạng thái phiếu. Trang đăng nhập cũng đã Việt hóa.

Trong quá trình làm, em gặp hai cái bẫy kỹ thuật đáng ghi lại:

**Bẫy thứ nhất: thư viện dịch thay thế chứ không gộp.** Thư viện `laminas-i18n` mà GLPI dùng thay thế catalog khi trùng domain và locale. Nghĩa là nếu cài một tệp bản dịch chỉ chứa vài trăm chuỗi bổ sung, toàn bộ bản dịch lõi sẽ biến mất và chuỗi quay về tiếng Anh. Vì vậy quy trình bắt buộc là gộp bản dịch lõi với bản bổ sung rồi mới cài. Script gộp có kiểm tra "không mất chuỗi nào so với bản gốc".

**Bẫy thứ hai: GLPI có hai loại khóa dịch.** Với hàm dịch số ít, khóa là `msgid`. Với hàm dịch số nhiều, khóa thật là `"số ít\0số nhiều"`. Bản dịch chính thức của GLPI để nguyên phần số nhiều chưa dịch, nên từ điển chỉ tác động lên entry số ít thì dạng số nhiều không bao giờ được vá. Đây là lý do bảng điều khiển hiện "14 Ticket" trong khi mọi thẻ khác đã là tiếng Việt. Cách khắc phục là thêm bảng 212 mục dạng số nhiều và vá thẳng vào entry có ký tự đặc biệt.

Ngoài việc Việt hóa giao diện, đề tài còn Việt hóa dữ liệu, tức những chữ nằm trong cơ sở dữ liệu chứ không nằm trong tệp dịch: tên hồ sơ quyền, tên bảng điều khiển, tên đơn vị gốc. Việc này làm bằng script chạy lại được, không sửa tay một lần.

### 4.2.7. Giao diện

Trong quá trình kiểm tra giao diện bằng trình duyệt thật, em phát hiện và sửa hai lỗi:

1. **Thanh điều hướng trang tự phục vụ gần như tàng hình.** Trang helpdesk dùng `navbar-dark` với chữ màu kem trên nền giấy sáng, tương phản chỉ khoảng 1,06:1. Em đổi sang một token tự đổi giá trị theo sáng tối, đảm bảo tương phản đạt mức đọc được ở cả hai chế độ.
2. **Trang tự phục vụ hóa xanh dương khi bật chế độ tối.** Bảng màu tối của GLPI gán cứng ba dải nền đầu trang thành xanh dương, trong khi phần còn lại theo tông xanh rêu Đà Lạt. Em cho ba dải đó bám theo token của đề tài. Lỗi này chỉ lộ ra khi đo màu thật trên trình duyệt ở cả hai chế độ, không lộ ra khi đọc mã.

### 4.2.8. Tự động hóa cài đặt

Toàn bộ hệ thống cài bằng một lệnh: `bash scripts/cai-dat-tat-ca.sh`. Script làm sáu việc và báo kết quả từng bước:

1. Khởi động 4 container.
2. Nạp danh mục nghiệp vụ: 12 tòa nhà, 54 phòng máy, 16 khoa, 79 loại sự cố.
3. Bật plugin QR và plugin giao diện Đà Lạt.
4. Nạp bản dịch tiếng Việt (gộp bản chính thức với bản bổ sung).
5. Nạp SLA và cơ chế chống lạm dụng.
6. Kiểm tra sức khỏe hệ thống.

Dữ liệu mẫu nạp riêng bằng `bash scripts/nap-du-lieu-mau.sh`, và script này idempotent: chạy lại nhiều lần không nhân đôi dữ liệu.

Mật khẩu quản trị không lưu trong mã nguồn. Các script tự động hóa đọc mật khẩu từ biến môi trường `GLPI_PASS`, không truyền qua tham số dòng lệnh, vì tham số dòng lệnh có thể bị lộ trong lịch sử lệnh hoặc trong danh sách tiến trình.

## 4.3. Kiểm thử và kết quả

### 4.3.1. Cách kiểm thử

Em kiểm thử ở ba mức:

1. **Kiểm tra tĩnh:** cú pháp shell, Python, JavaScript; lint shell; cấu hình Docker Compose và Nginx.
2. **Kiểm tra chức năng:** đăng nhập thật bằng từng vai trò rồi mở từng trang, đối chiếu mã HTTP.
3. **Kiểm tra use case:** chạy một luồng nghiệp vụ thật từ đầu đến cuối bằng trình duyệt.

### 4.3.2. Kết quả kiểm tra chức năng theo vai trò

Kết quả chạy ngày 03/10/2026 trên hệ thống đang hoạt động:

| Vai trò | Tài khoản | Kết quả |
|---|---|---|
| Kỹ thuật viên | `ktv.an` | **25 đạt / 0 lỗi** |
| Sinh viên | `sv.hoa` | **15 đạt / 0 lỗi** |

*Bảng 4.7. Kết quả kiểm tra chức năng theo vai trò*

Với kỹ thuật viên, toàn bộ trang trung tâm trả về 200 và có nội dung thật (bảng điều khiển 194 KB, danh sách phiếu 304 KB), ba trang Setup bị chặn đúng với mã 403. Với sinh viên, ba cửa vào tự phục vụ trả về 200, năm trang trung tâm bị chặn đúng với mã 403.

Đây là bằng chứng cho hai điều cùng lúc: chức năng hoạt động, và phân quyền hoạt động.

### 4.3.3. Kết quả kiểm tra chống lạm dụng

Script kiểm tra chống lạm dụng báo cáo ba mục, tất cả đều đạt trên dữ liệu hiện có:

- Không có tài khoản nào vượt hạn mức phiếu đang mở.
- Không phát hiện phiếu trùng trong 7 ngày qua.
- Không phát hiện nộp quá nhanh.

Kiểm tra giới hạn tần suất ở tầng mạng bằng cách gửi 40 yêu cầu liên tiếp vào endpoint nộp phiếu: sau 11 yêu cầu đầu, hệ thống bắt đầu trả về mã 429. Điều này chứng minh tầng T1 hoạt động thật, không phải chỉ có trong cấu hình.

### 4.3.4. Pipeline kiểm tra tự động

Mỗi lần đẩy mã nguồn lên nhánh chính, GitHub Actions chạy pipeline gồm 6 nhóm kiểm tra:

| # | Nhóm | Nội dung |
|---|---|---|
| 1 | Cú pháp | `bash -n`, `py_compile`, `node --check` |
| 2 | ShellCheck | Lint shell ở mức warning |
| 3 | Cấu hình | `docker compose config`, mọi service phải có healthcheck, `nginx -t` |
| 4 | Chứng chỉ SSL | Sinh được từ `openssl-san.cnf` và bắt buộc có SAN |
| 5 | Bảo mật | Không commit `.env` hay chứng chỉ; không hardcode mật khẩu hay đường dẫn máy cá nhân |
| 6 | Smoke test | Khởi động thật 4 container, chờ healthy, kiểm tra HTTP/HTTPS |

*Bảng 4.8. Sáu nhóm kiểm tra trong pipeline CI*

Nhóm smoke test gồm 20 bước, trong đó có những bước chốt lại đúng các lỗi từng gặp để chúng không quay lại: tài khoản demo phải có hồ sơ quyền và đăng nhập được, dữ liệu hiển thị phải đã Việt hóa, thương hiệu và dải màu ưu tiên phải được đặt, từ điển phải đủ 556 thuật ngữ và 212 mục số nhiều, và chức năng phân quyền theo vai trò phải hoạt động.

Pipeline chặn merge nếu bất kỳ cửa nào thất bại.

### 4.3.5. Lỗi đã tìm ra và sửa

Trong quá trình làm, em tìm ra và sửa một loạt lỗi, phần lớn chỉ lộ ra khi cài trên máy sạch hoặc khi kiểm tra bằng trình duyệt thật. Ba lỗi đáng chú ý nhất, vì chúng sẽ làm hỏng buổi demo:

1. **Sáu tài khoản demo không có hồ sơ quyền, đăng nhập là chết.** Script gán hồ sơ theo tên tiếng Việt, nhưng trên máy sạch GLPI tạo hồ sơ bằng tên tiếng Anh, còn script Việt hóa lại không nằm trong luồng cài. Kết quả là đăng nhập trả về lỗi 400. Kịch bản demo đăng nhập tài khoản sinh viên sẽ chết ngay trên bục. Nay câu lệnh khớp cả hai tên và chạy đúng thứ tự.
2. **Bảng điều khiển hiện chế độ minh họa của GLPI.** GLPI 11 bật sẵn chế độ dùng bảng điều khiển mẫu. Script Việt hóa đã tắt nó nhưng script đó không được gọi trong luồng cài. Nay bước Việt hóa dữ liệu chạy ngay sau khi nạp danh mục.
3. **Dữ liệu mẫu âm thầm thiếu 4 thiết bị.** Script dữ liệu mẫu tham chiếu tên vị trí không khớp với script danh mục. Vì câu lệnh dùng phép nối theo tên, những dòng không khớp bị bỏ qua trong im lặng. Kết quả là thiếu 2 laptop, 1 máy in và 4 thiết bị mạng. Nay tên đã khớp và cài sạch cho đủ 34 tài sản.

Ba lỗi trên đều thuộc loại "im lặng": hệ thống không báo lỗi, chỉ thiếu dữ liệu hoặc chặn đăng nhập. Đó là lý do em đưa chúng vào pipeline CI để mỗi lần đẩy mã đều được kiểm tra lại.

### 4.3.6. Rà soát chất lượng sau khi hoàn thiện

Sau khi hệ thống đã chạy được và báo cáo đã có bản nháp, em dành một đợt rà soát riêng để tìm những chỗ một người chấm kỹ sẽ bắt lỗi. Cách làm là đọc lại toàn bộ mã nguồn, tài liệu và cấu hình dưới con mắt phản biện, phân loại vấn đề theo ba mức (P0 — phải sửa ngay, P1 — nên sửa, P2 — cân nhắc), rồi **kiểm chứng từng thay đổi bằng lệnh chạy thật** chứ không chỉ sửa cho đẹp trên giấy. Kết quả gồm mười ba vấn đề, tóm tắt trong bảng dưới.

| # | Vấn đề phát hiện | Mức | Cách xử lý |
|---|---|---|---|
| 1 | README ghi giấy phép GPL v3 nhưng kho mã nguồn không có tệp giấy phép | P0 | Thêm `LICENSE` (GNU GPL-3.0) |
| 2 | Còn nhánh `bao-cao-thuc-tap-dlu` lỗi thời trên kho từ xa | P0 | Xoá sau khi kiểm chứng nội dung đã nằm trong `master` |
| 3 | Hướng dẫn phục hồi dữ liệu dạy `source .env` và truyền mật khẩu qua dòng lệnh — trái với chuẩn bảo mật của chính đồ án | P0 | Đổi sang cách an toàn, rồi chạy thử phục hồi thật |
| 4 | Nghi ngờ con số "42 điểm kiểm" trong tài liệu là sai | P0 | Kiểm chứng: con số **đúng**; ghi rõ cách đếm và chốt lại bằng một cửa CI |
| 5 | Thiếu tệp khoá phiên bản phụ thuộc | P1 | Thêm `package-lock.json`, `requirements.txt`, `.dockerignore` |
| 6 | Pipeline CI ghim phiên bản công cụ bằng nhãn trôi nổi | P1 | Ghim theo mã băm commit |
| 7 | Nhật ký container không giới hạn dung lượng | P1 | Thêm giới hạn log cho cả bốn dịch vụ |
| 8 | Tài liệu còn dùng lệnh `docker-compose` phiên bản cũ | P1 | Thống nhất về `docker compose` |
| 9 | Script kiểm tra dùng mật khẩu mặc định, hỏng sau khi đổi mật khẩu quản trị | P1 | Bắt buộc truyền mật khẩu qua biến môi trường |
| 10 | Ảnh không còn dùng và thư mục rác trong kho mã nguồn | P1 | Dọn sạch (kiểm tra kỹ từng thứ trước khi xoá) |
| 11 | Kiểm thử end-to-end chạy tay, chưa vào pipeline | P2 | Đưa ba use case Playwright vào CI |
| 12 | Chưa có quy ước định dạng chung cho trình soạn thảo | P2 | Thêm `.editorconfig` |
| 13 | Bản vá plugin bên thứ ba không ghi rõ gắn với phiên bản nào | P2 | Ghi cảnh báo ràng buộc phiên bản |

*Bảng 4.9. Mười ba vấn đề phát hiện khi rà soát chất lượng và cách xử lý*

Hai vấn đề đáng kể nhất đều nằm ở mức P0. Thứ nhất là **hướng dẫn phục hồi dữ liệu tự mâu thuẫn**: đồ án đã có quy ước rõ là không truyền mật khẩu qua tham số dòng lệnh (vì tiến trình khác đọc được qua `ps`), vậy mà chính tài liệu lại dạy điều ngược lại. Đây là loại lỗi nguy hiểm vì nó không làm hệ thống hỏng, chỉ âm thầm làm yếu bảo mật. Em sửa cả tài liệu lẫn script, rồi **chạy thử phục hồi thật** để chắc chắn cách mới hoạt động và dữ liệu vẫn nguyên vẹn (17 máy tính, 14 phiếu).

Thứ hai là **bài học về số liệu**. Tài liệu ghi harness có "42 điểm kiểm", nhưng khi đếm bằng công cụ tìm kiếm chỉ thấy ít hơn. Thay vì sửa số liệu theo cảm tính, em phân tích kỹ và phát hiện con số 42 là **đúng**: lời gọi `check()` nằm trong vòng lặp tạo 6 tài khoản thử và trong một khối điều kiện, nên tổng số lần chạy lớn hơn số dòng grep được. Từ đó em thêm một cửa CI tự chốt con số này, để nếu ai thêm hoặc bớt phép kiểm mà quên cập nhật tài liệu thì pipeline báo đỏ ngay.

Sau khi hoàn tất, em chạy lại toàn bộ các cửa kiểm tra để xác nhận không có hồi quy:

| Hạng mục | Kết quả |
|---|---|
| Cú pháp shell / JavaScript / Python | Đạt (16 + 12 tệp) |
| Lint shell (ShellCheck), cú pháp PHP | Đạt (4 tệp PHP) |
| Cấu hình Docker Compose và Nginx | Hợp lệ |
| Quét bí mật trong mã nguồn | Sạch |
| Chống lạm dụng (harness plugin) | **42/42 đạt** |
| Chức năng và phân quyền theo vai trò | **25/25 đạt** |
| Ba use case end-to-end (Playwright, Chrome thật) | **3/3 đạt** |

*Bảng 4.10. Kết quả kiểm chứng sau đợt rà soát chất lượng*

Một quyết định em giữ nguyên có chủ ý: **không ghim cứng mã băm của các ảnh Docker**. Ghim cứng giúp tái lập tuyệt đối nhưng khiến hệ thống không nhận được bản vá bảo mật tự động; với đồ án chạy trong mạng nội bộ, đánh đổi đó không đáng. Thay vào đó mã băm hiện tại được ghi trong phần chú thích của tệp cấu hình, kèm hướng dẫn ghim nếu cần.

Chi tiết đầy đủ của đợt rà soát (từng vấn đề, cách sửa, bằng chứng) nằm ở tài liệu `tai-lieu/CAI-TIEN-CHAT-LUONG.md`.

---

# CHƯƠNG 5. ĐÁNH GIÁ, HẠN CHẾ VÀ HƯỚNG PHÁT TRIỂN

## 5.1. Kết quả đạt được

Đề tài đã dựng được một hệ thống hỗ trợ kỹ thuật chạy thật trên nền GLPI 11, với những kết quả cụ thể sau:

- Cài đặt toàn bộ bằng một lệnh, tái lập được trên máy khác.
- Dữ liệu nghiệp vụ dựng sẵn theo cơ cấu của Trường: 12 tòa nhà, 54 phòng máy, 16 khoa, 79 loại sự cố.
- Dữ liệu mẫu đầy đủ: 34 tài sản phần cứng, 14 phiếu sự cố, 10 bản ghi SLA, 6 tài khoản ba vai trò.
- Giao diện Đà Lạt lấy màu từ logo Trường, áp trên toàn hệ thống kể cả trang đăng nhập.
- Mã QR cho thiết bị, đã giải mã kiểm chứng.
- Lớp chống lạm dụng sáu tầng với bằng chứng chạy thật (HTTP 429 sau 11 yêu cầu).
- Kiểm thử: 25/25 mục đạt với vai trò kỹ thuật viên, 15/15 với vai trò sinh viên.
- Pipeline CI sáu nhóm, trong đó smoke test gồm 20 bước, chặn merge nếu có lỗi.

## 5.2. Hạn chế của đề tài

Em ghi thẳng những gì chưa làm được, vì đây là phần quan trọng nhất để đánh giá đúng mức độ hoàn thành của đề tài.

| # | Hạn chế | Mức độ |
|---|---|---|
| 1 | Đề tài chưa được ITC phê duyệt và chưa triển khai trên hạ tầng thật của Trường | Nghiêm trọng |
| 2 | Số sự cố ITC thực tế tiếp nhận mỗi tuần, thời gian phản hồi trung bình hiện tại: chưa có dữ liệu | Nghiêm trọng |
| 3 | 5 mức SLA và hạn mức 5 phiếu / 10 phiếu mỗi ngày là đề xuất kỹ thuật, chưa được Trường xác nhận | Nghiêm trọng |
| 4 | Chưa đo hiệu năng khi có nhiều người dùng đồng thời | Trung bình |
| 5 | Tầng T5 (kiểm duyệt trước khi giao việc) chưa tự động hóa bằng mã, hiện dựa trên quy trình | Trung bình |
| 6 | Nhật ký chống lạm dụng chưa có giao diện xem cho kỹ thuật viên, hiện xem bằng SQL | Trung bình |
| 7 | Chưa có CAPTCHA cho trường hợp mở nộp phiếu ẩn danh qua QR | Thấp, do phạm vi |
| 8 | Chưa có tài khoản tự đăng ký, nên chưa phải lo chống tạo tài khoản ảo | Thấp, do phạm vi |
| 9 | Redis cấu hình `maxmemory 256MB` + `allkeys-lru`: khi đầy, phiên đăng nhập có thể bị đẩy ra sớm, người dùng phải đăng nhập lại | Thấp, do quy mô nội bộ |
| 10 | Khi cơ chế chống lạm dụng tự tắt do lỗi CSDL (fail-open), hệ thống có ghi nhật ký nhưng chưa có cảnh báo tự động cho kỹ thuật viên | Trung bình |
| 11 | Trên đường tạo phiếu mới của GLPI 11 (`/Form/SubmitAnswers`), khi bị chặn hạn mức, lõi GLPI hiển thị lỗi hệ thống chung ("Failed to submit form") thay vì thông báo tiếng Việt thân thiện (chỉ đường `/front/ticket.form.php` cũ mới hiện đúng thông báo) | Trung bình |

*Bảng 5.1. Hạn chế của đề tài*

Về hai mục cuối, đây là giảm thiểu rủi ro bằng thiết kế: đề tài không cho tự đăng ký và không cho nộp ẩn danh, nên hai rủi ro đó bị loại bỏ ở gốc thay vì phải chống đỡ sau khi đã cho phép.

Về tầng T5, lý do không viết mã cho tầng này là muốn tự động chặn thì phải móc vào sự kiện tạo phiếu của GLPI, tức phải viết plugin sửa vào luồng lõi, làm mất tính "tùy biến ngoài lõi" vốn là mục tiêu cốt lõi của đề tài. Đây là đánh đổi có ý thức.

## 5.3. Hướng phát triển

Từ những hạn chế ở mục 5.2, hướng phát triển tiếp theo được sắp theo thứ tự ưu tiên:

1. **Phỏng vấn 5 nhân sự ITC** để kiểm chứng bài toán và xin số liệu tiếp nhận thực tế. Đây là việc cần làm đầu tiên nếu muốn biến đề tài từ "đề xuất" thành "đã triển khai".
2. **Đề nghị ITC ban hành mức thời gian xử lý chính thức**, thay cho các con số đề xuất hiện tại.
3. **Đo hiệu năng** khi có nhiều người dùng đồng thời, và cắm thử hệ thống ở một phòng máy để đo thực tế.
4. **Tự động hóa tầng T5** bằng quy tắc nghiệp vụ của GLPI cấu hình qua giao diện, giữ được kiến trúc ngoài lõi.
5. **Thêm giao diện xem nhật ký** cho kỹ thuật viên, để không phải truy vấn SQL.

## 5.4. Bài học kinh nghiệm

Qua kỳ thực tập, em rút ra bốn bài học.

Bài học đầu tiên là về kiểm chứng. Ba lỗi nghiêm trọng nhất của đề tài đều thuộc loại "im lặng": hệ thống không báo lỗi, chỉ thiếu dữ liệu hoặc chặn đăng nhập. Chúng chỉ lộ ra khi em xóa sạch dữ liệu rồi cài lại từ đầu, chứ không lộ ra khi đọc mã. Từ đó em hiểu rằng một hệ thống chạy được trên máy đã có dữ liệu chưa chắc chạy được trên máy sạch, và kiểm thử phải bắt đầu từ trạng thái trắng.

Nhận xét "còn lý thuyết, chưa thực tế" của giảng viên hướng dẫn là bài học thứ hai, về cách trả lời phản biện. Câu trả lời không thể là thêm chữ, mà phải là dữ kiện có nguồn và chức năng chạy thật. Tài liệu bài toán nghiệp vụ và phần chống lạm dụng ra đời từ đúng nhận xét đó.

Về kiến trúc, quyết định giữ mọi tùy biến ngoài lõi GLPI tốn công hơn lúc đầu, nhưng đổi lại việc nâng cấp không làm mất công sức. Đây là bài học em sẽ mang sang các dự án sau.

Bài học cuối là về sự trung thực. Việc ghi rõ "chưa được ITC phê duyệt" hay "SLA chỉ là đề xuất" khiến báo cáo bớt hào nhoáng hơn, nhưng đó là cách duy nhất để người đọc tin được phần còn lại.

---

# KẾT LUẬN VÀ KIẾN NGHỊ

## Kết luận

Đề tài đã hoàn thành mục tiêu đề ra: dựng được một hệ thống hỗ trợ kỹ thuật chạy thật trên nền GLPI 11, cài bằng một lệnh, có dữ liệu nghiệp vụ dựng sẵn theo cơ cấu của Trường, có giao diện Đà Lạt, có mã QR cho thiết bị, có SLA trong cơ sở dữ liệu, và có lớp chống lạm dụng sáu tầng với bằng chứng chạy thật.

Kết quả kiểm thử: 25/25 mục đạt với vai trò kỹ thuật viên, 15/15 với vai trò sinh viên, chống lạm dụng không phát hiện dấu hiệu bất thường, giới hạn tần suất trả về mã 429 đúng như thiết kế.

Điểm kỹ thuật em muốn nói rõ là quyết định kiến trúc: toàn bộ tùy biến nằm ngoài lõi GLPI. Nhờ vậy, nâng cấp GLPI không làm mất công sức đã bỏ ra, và hệ thống giữ được khả năng bảo trì lâu dài.

Em cũng cố gắng ghi rõ những gì chưa làm được. Đề tài chưa được ITC phê duyệt, các con số SLA và hạn mức còn là đề xuất, và chưa có số liệu thực tế về tần suất sự cố. Những điều này không làm giảm giá trị của phần đã hoàn thành, nhưng nếu bỏ qua thì báo cáo sẽ không còn đáng tin.

## Kiến nghị

**Đối với Trung tâm Công nghệ thông tin:** nên xem xét phê duyệt và ban hành mức thời gian xử lý chính thức, đồng thời cho phép thử nghiệm hệ thống ở một phòng máy để đo thực tế trước khi triển khai diện rộng.

**Đối với Khoa Toán - Tin học:** nên tiếp tục duy trì các đề tài có sản phẩm chạy được như thế này, vì kinh nghiệm làm một hệ thống thật khác với việc làm bài tập.

**Đối với sinh viên khóa sau:** nếu chọn đề tài tương tự, em khuyên nên dành thời gian kiểm thử trên máy sạch ngay từ giữa kỳ thay vì để cuối kỳ, và nên đặt câu hỏi "dữ liệu này lấy từ đâu" cho mọi con số mình viết ra.

---

# TÀI LIỆU THAM KHẢO

## A. Nguồn dữ kiện công khai

| # | Nội dung | URL | Truy cập |
|---|---|---|---|
| 1 | Trang chủ Trường: quy mô người học, chương trình đào tạo | https://dlu.edu.vn/ | 02/10/2026 |
| 2 | ITC: chức năng, nhiệm vụ, nhân sự | https://itc.dlu.edu.vn/gioi-thieu/ | 02/10/2026 |
| 3 | ITC: liên hệ, hotline, giờ làm việc | https://itc.dlu.edu.vn/lien-he/ | 02/10/2026 |
| 4 | Khoa Toán - Tin học: đội ngũ nhân sự | https://ktt.dlu.edu.vn/doi-ngu-nhan-su-khoa-toan-tin/ | 02/10/2026 |
| 5 | Danh mục đơn vị của Trường | https://dlu.edu.vn/cac-phong-khoa | 02/10/2026 |

## B. Tài liệu kỹ thuật

| # | Nội dung | Nguồn |
|---|---|---|
| 6 | GLPI 11 (GPL v3) | https://github.com/glpi-project/glpi |
| 7 | Plugin Barcode 2.7.1 (AGPL-3.0) | Kho plugin GLPI |
| 8 | Docker Compose | https://docs.docker.com/compose/ |
| 9 | Nginx: `limit_req` và `limit_req_zone` | https://nginx.org/en/docs/http/ngx_http_limit_req_module.html |
| 10 | Playwright | https://playwright.dev/ |

## C. Tài liệu của đề tài

| # | Tài liệu | Nội dung |
|---|---|---|
| 11 | [`README.md`](README.md) | Tài liệu tổng hợp toàn diện (10 mục) |
| 12 | [`BAO-CAO-THUC-TAP.md`](BAO-CAO-THUC-TAP.md) | Báo cáo thực tập tốt nghiệp (tài liệu này) |
| 13 | [`slide-bao-ve.html`](slide-bao-ve.html) | 8 slide bảo vệ, chạy ngoại tuyến |
| 14 | [`../CHANGELOG.md`](../CHANGELOG.md) | Nhật ký thay đổi theo phiên bản |

---

# PHỤ LỤC

## Phụ lục A. Tài khoản dữ liệu mẫu

| Tài khoản | Mật khẩu | Vai trò |
|---|---|---|
| `ktv.an`, `ktv.binh` | `Dlu@2026` | Kỹ thuật viên |
| `gv.cuong`, `gv.dung` | `Dlu@2026` | Giảng viên |
| `sv.hoa`, `sv.khanh` | `Dlu@2026` | Sinh viên |

Tài khoản `glpi` là tài khoản quản trị, mật khẩu do người cài đặt chọn và không lưu trong mã nguồn. Tài khoản `tech` do trình cài đặt GLPI tạo ra.

## Phụ lục B. Lệnh thường dùng

```bash
# Cài toàn bộ hệ thống
bash scripts/cai-dat-tat-ca.sh

# Nạp dữ liệu demo
bash scripts/nap-du-lieu-mau.sh

# Nạp SLA và cơ chế chống lạm dụng
bash scripts/nap-sla-va-chong-lam-dung.sh

# Kiểm tra chức năng theo vai trò
GLPI_USER=ktv.an GLPI_PASS='<mật khẩu>' bash scripts/kiem-tra-chuc-nang.sh
GLPI_USER=sv.hoa  GLPI_PASS='<mật khẩu>' bash scripts/kiem-tra-chuc-nang.sh

# Kiểm tra chống lạm dụng
bash scripts/kiem-tra-lam-dung.sh

# Đo độ phủ Việt hóa
python scripts/do-do-phu-tieng-viet.py
```

## Phụ lục C. Danh mục ảnh minh chứng

Thư mục `tai-lieu/anh-giao-dien/` có 18 ảnh chụp giao diện thật:

| # | Tệp | Nội dung |
|---|---|---|
| 1 | `01-trang-dang-nhap.png` | Trang đăng nhập |
| 2 | `02-bang-dieu-khien.png` | Bảng điều khiển |
| 3 | `03-danh-sach-may-tinh.png` | Danh sách máy tính |
| 4 | `03b-danh-sach-man-hinh.png` | Danh sách màn hình |
| 5 | `03c-thiet-bi-mang.png` | Thiết bị mạng |
| 6 | `03d-danh-sach-may-in.png` | Danh sách máy in |
| 7 | `03e-danh-sach-phan-mem.png` | Danh sách phần mềm |
| 8 | `04-danh-sach-phieu-yeu-cau.png` | Danh sách phiếu yêu cầu |
| 9 | `05-tao-phieu-moi.png` | Biểu mẫu tạo phiếu mới |
| 10 | `06-tao-thiet-bi.png` | Thêm thiết bị mới |
| 11 | `06-nhom-co-cau-to-chuc.png` | Nhóm cơ cấu tổ chức |
| 12 | `07-chi-tiet-thiet-bi.png` | Chi tiết thiết bị |
| 13 | `08-danh-sach-nguoi-dung.png` | Danh sách người dùng |
| 14 | `10-menu-cac-hanh-dong.png` | Menu hành động hàng loạt |
| 15 | `11-cau-hinh-nhan-qr.png` | Cấu hình nhãn QR |
| 16 | `11-ma-qr-thiet-bi.png` | Mã QR trên hồ sơ thiết bị |
| 17 | `12-ket-qua-sinh-qr.png` | Kết quả sinh mã QR |
| 18 | `13-thong-ke-toan-cau.png` | Thống kê toàn cầu |

## Phụ lục D. Thông tin phiên bản hệ thống

| Thành phần | Phiên bản |
|---|---|
| GLPI | 11.0.0 |
| PHP | 8.4.13 |
| MariaDB | 10.11 |
| Redis | 7 |
| Nginx | 1.27 |
| Plugin Barcode | 2.7.1 |
| Phiên bản đề tài | 0.4.0 |

## Phụ lục E. Nhật ký thay đổi theo phiên bản

| Phiên bản | Ngày | Nội dung chính |
|---|---|---|
| 0.1.0 | 22/09/2026 | Hoàn thiện nền tảng: hạ tầng, giao diện, Việt hóa, plugin QR, CI |
| 0.2.0 | 02/10/2026 | Từ lý thuyết sang nghiệp vụ thật: bài toán nghiệp vụ, chống lạm dụng, SLA, bảo trì, mượn/trả |
| 0.3.0 | 03/10/2026 | Chuẩn hóa số liệu và vá lỗi dữ liệu mẫu |
| 0.4.0 | 03/10/2026 | Vá ba lỗi cài máy sạch, sửa giao diện, Việt hóa dữ liệu, chuyển sang Playwright |
| Chưa phát hành | 08/10/2026 | Rà soát chất lượng: thêm giấy phép, sửa hướng dẫn bảo mật, khoá phiên bản phụ thuộc, đưa kiểm thử end-to-end vào CI (13 vấn đề — xem mục 4.3.6) |

Chi tiết đầy đủ từng phiên bản nằm trong [`../CHANGELOG.md`](../CHANGELOG.md).
