BỘ GIÁO DỤC VÀ ĐÀO TẠO
TRƯỜNG ĐẠI HỌC ĐÀ LẠT
KHOA CÔNG NGHỆ THÔNG TIN

---

# BÁO CÁO THỰC TẬP TỐT NGHIỆP

## ĐỀ TÀI

# XÂY DỰNG HỆ THỐNG HỖ TRỢ KỸ THUẬT PINEDESK CHO TRƯỜNG ĐẠI HỌC ĐÀ LẠT TRÊN NỀN TẢNG GLPI 11

<br>

| | |
|---|---|
| **Ngành đào tạo** | Kỹ thuật phần mềm |
| **Sinh viên thực hiện** | Phùng Võ Quốc Hiển (Nhóm trưởng) |
| **Mã số sinh viên** | 2212364 |
| **Lớp** | CTK46-PM |
| **Thành viên nhóm đề tài** | Lý Gia Bảo (2213934) · Nguyễn Việt Bình (2213831) |
| **Khóa học** | K46 (2022 – 2026) |
| **Giảng viên hướng dẫn** | ThS. La Quốc Thắng |
| **Đơn vị thực tập** | Trung tâm Công nghệ thông tin – Trường Đại học Đà Lạt |
| **Cán bộ hướng dẫn tại đơn vị** | ThS. La Quốc Thắng · ThS. Đặng Quốc Phi |
| **Thời gian thực tập** | Học kỳ 1 Năm học 2026 – 2027 (10 tuần: 10/08/2026 – 17/10/2026) |

<br>

**ĐÀ LẠT, THÁNG 10 NĂM 2026**

---

## LỜI CẢM ƠN

Trước khi trình bày nội dung báo cáo, em xin gửi lời cảm ơn chân thành tới Ban Giám hiệu Trường Đại học Đà Lạt và Ban Chủ nhiệm Khoa Công nghệ Thông tin đã tạo điều kiện cho em thực hiện kỳ thực tập tốt nghiệp này.

Em xin bày tỏ lòng biết ơn sâu sắc tới thầy ThS. La Quốc Thắng, giảng viên hướng dẫn tại Khoa, người đã định hướng đề tài, tận tình góp ý qua từng phiên bản và chỉ ra những chỗ em còn suy diễn so với thực tế. Những phản biện sắc bén của thầy chính là động lực để em bổ sung bài toán nghiệp vụ, xây dựng tầng chống lạm dụng sáu tầng và kiểm chứng nghiêm ngặt từng số liệu.

Em xin trân trọng cảm ơn Ban Giám đốc và các thầy cô, anh chị tại Trung tâm Công nghệ thông tin (ITC) - Trường Đại học Đà Lạt, đặc biệt là thầy ThS. Đặng Quốc Phi, đã nhiệt tình hướng dẫn, chia sẻ quy trình vận hành hạ tầng mạng, quản lý phòng máy thực hành và cung cấp các thông số kỹ thuật thực tế để em hoàn thiện cơ sở dữ liệu cho đề tài.

Em cũng xin gửi lời cảm ơn sâu sắc tới hai bạn thành viên trong nhóm thực tập tại Trung tâm CNTT — bạn Lý Gia Bảo và bạn Nguyễn Việt Bình — đã luôn đồng hành, cùng chia sẻ khối lượng công việc lớn trong suốt 10 tuần, từ khảo sát thiết bị, quản lý phòng máy, thiết kế giao diện nhận diện thương hiệu đến chuẩn hóa quy trình nghiệp vụ và kiểm thử hệ thống. Đồng thời, em xin cảm ơn các bạn sinh viên lớp CTK46-PM đã cùng trao đổi và đóng góp ý kiến hoàn thiện tài liệu báo cáo.

Dù đã nỗ lực hết mình với tinh thần cầu thị và nghiêm túc, báo cáo khó tránh khỏi những hạn chế nhất định. Em rất mong nhận được những nhận xét, chỉ dẫn quý báu của quý thầy cô trong Hội đồng để đề tài được hoàn thiện hơn nữa.

*Đà Lạt, tháng 10 năm 2026*

**Sinh viên thực hiện**

Phùng Võ Quốc Hiển

---

## PHIẾU ĐÁNH GIÁ CỦA ĐƠN VỊ THỰC TẬP

**Đơn vị thực tập:** Trung tâm Công nghệ thông tin – Trường Đại học Đà Lạt  
**Địa chỉ:** Số 01 Phù Đổng Thiên Vương, Phường Lâm Viên, TP. Đà Lạt, Tỉnh Lâm Đồng  
**Họ và tên sinh viên:** Phùng Võ Quốc Hiển — **MSSV:** 2212364 — **Lớp:** CTK46-PM  
**Cán bộ hướng dẫn tại đơn vị:** ThS. La Quốc Thắng · ThS. Đặng Quốc Phi  
**Thời gian thực tập:** Từ ngày 10/08/2026 đến ngày 17/10/2026 (10 tuần)

### 1. Nội dung đánh giá kết quả thực tập

| STT | Tiêu chí đánh giá | Điểm tối đa | Điểm đánh giá |
|---|---|:---:|:---:|
| 1 | Tinh thần kỷ luật, chấp hành nội quy và thời gian làm việc | 1,0 | ......... / 1,0 |
| 2 | Thái độ giao tiếp, tinh thần trách nhiệm và hợp tác làm việc | 1,0 | ......... / 1,0 |
| 3 | Năng lực chuyên môn, khả năng nắm bắt hạ tầng và nghiệp vụ | 3,0 | ......... / 3,0 |
| 4 | Kỹ năng thực hành, áp dụng công nghệ và giải quyết sự cố kỹ thuật | 2,0 | ......... / 2,0 |
| 5 | Kết quả hoàn thành công việc được giao (Hệ thống PineDesk) | 3,0 | ......... / 3,0 |
| | **TỔNG ĐIỂM** | **10,0** | **......... / 10,0** |

*Điểm bằng chữ:* ........................................................................................................

### 2. Nhận xét chung của đơn vị thực tập

- **Về ý thức kỷ luật và thái độ làm việc:**  
  ......................................................................................................................................................  
  ......................................................................................................................................................
- **Về năng lực chuyên môn và kết quả thực hiện:**  
  ......................................................................................................................................................  
  ......................................................................................................................................................

*Đà Lạt, ngày ..... tháng 10 năm 2026*

| CÁN BỘ HƯỚNG DẪN | THỦ TRƯỞNG ĐƠN VỊ |
|:---:|:---:|
| *(Ký và ghi rõ họ tên)* | *(Ký tên, đóng dấu)* |
| <br><br><br><br> | <br><br><br><br> |
| **ThS. Đặng Quốc Phi** | **ThS. Trần Thống** |

---

## PHIẾU ĐÁNH GIÁ CỦA GIẢNG VIÊN HƯỚNG DẪN

**Trường:** Đại học Đà Lạt — **Khoa:** Công nghệ Thông tin  
**Họ và tên sinh viên:** Phùng Võ Quốc Hiển — **MSSV:** 2212364 — **Lớp:** CTK46-PM  
**Tên đề tài:** Xây dựng hệ thống hỗ trợ kỹ thuật PineDesk cho Trường Đại học Đà Lạt trên nền tảng GLPI 11  
**Giảng viên hướng dẫn:** ThS. La Quốc Thắng

### 1. Bảng điểm đánh giá

| STT | Tiêu chí đánh giá | Điểm tối đa | Điểm đánh giá |
|---|---|:---:|:---:|
| 1 | Ý thức thực hiện, tinh thần cầu thị và tiến độ báo cáo định kỳ | 2,0 | ......... / 2,0 |
| 2 | Tính khoa học, tính logic và chất lượng nội dung báo cáo | 3,0 | ......... / 3,0 |
| 3 | Mức độ hoàn thiện, tính thực tiễn và giá trị kỹ thuật của sản phẩm | 3,0 | ......... / 3,0 |
| 4 | Kỹ năng trình bày, bố cục văn bản và chuẩn mực trích dẫn | 2,0 | ......... / 2,0 |
| | **TỔNG ĐIỂM** | **10,0** | **......... / 10,0** |

*Điểm bằng chữ:* ........................................................................................................

### 2. Nhận xét của giảng viên hướng dẫn

- **Ưu điểm:**  
  ......................................................................................................................................................  
  ......................................................................................................................................................
- **Hạn chế:**  
  ......................................................................................................................................................  
  ......................................................................................................................................................
- **Kết luận:** Đồng ý cho sinh viên được bảo vệ trước Hội đồng chấm báo cáo thực tập tốt nghiệp.

*Đà Lạt, ngày ..... tháng 10 năm 2026*

**GIẢNG VIÊN HƯỚNG DẪN**  
*(Ký và ghi rõ họ tên)*

<br><br><br><br>

**ThS. La Quốc Thắng**

---

## MỤC LỤC

*(Nhấn giữ Ctrl và nhấp chuột hoặc nhấp chuột vào mục bất kỳ để chuyển nhanh đến trang tương ứng)*

| Nội dung | Trang |
|---|---|
| Lời cảm ơn | i |
| Phiếu đánh giá của đơn vị thực tập | ii |
| Phiếu đánh giá của giảng viên hướng dẫn | iii |
| Mục lục | iv |
| Danh mục các từ viết tắt | vi |
| Danh mục bảng biểu | vii |
| Danh mục hình ảnh | viii |
| **PHẦN MỞ ĐẦU** | 1 |
| 1. Lý do chọn đề tài | 1 |
| 2. Mục tiêu của đề tài | 2 |
| 3. Đối tượng và phạm vi nghiên cứu | 2 |
| 4. Phương pháp thực hiện | 3 |
| 5. Bố cục của báo cáo | 3 |
| **CHƯƠNG 1. TỔNG QUAN VỀ ĐƠN VỊ THỰC TẬP** | 4 |
| 1.1. Trường Đại học Đà Lạt | 4 |
| 1.2. Khoa Công nghệ Thông tin | 5 |
| 1.3. Trung tâm Công nghệ thông tin (ITC) | 5 |
| 1.4. Hiện trạng tiếp nhận sự cố CNTT của Trường | 6 |
| 1.4.1. Ba mâu thuẫn | 6 |
| 1.4.2. Hệ quả của kênh phi cấu trúc | 7 |
| 1.4.3. PineDesk đáp ứng gì | 7 |
| 1.4.4. Vì sao không dùng công cụ sẵn có | 8 |
| **CHƯƠNG 2. CƠ SỞ LÝ THUYẾT VÀ CÔNG NGHỆ SỬ DỤNG** | 9 |
| 2.1. ITSM và ITIL | 9 |
| 2.2. GLPI | 9 |
| 2.3. Container hóa với Docker và Docker Compose | 10 |
| 2.4. Cổng giao tiếp Nginx Gateway và SSL/TLS | 11 |
| 2.5. Công cụ hỗ trợ phát triển | 11 |
| **CHƯƠNG 3. PHÂN TÍCH VÀ THIẾT KẾ HỆ THỐNG** | 13 |
| 3.1. Phân tích yêu cầu | 13 |
| 3.2. Kiến trúc tổng thể | 16 |
| 3.3. Nguyên tắc thiết kế: tùy biến nằm ngoài lõi | 17 |
| 3.4. Hệ thống thiết kế giao diện: Apple Precision, Claude Warmth và Bản sắc Đà Lạt | 18 |
| 3.5. Cấu trúc mã nguồn | 19 |
| 3.6. Bảng đối chiếu đóng góp kỹ thuật so với GLPI 11 gốc | 20 |
| **CHƯƠNG 4. TRIỂN KHAI VÀ KIỂM THỬ** | 22 |
| 4.1. Kế hoạch và tiến độ thực hiện 10 tuần thực tập | 22 |
| 4.1.1. Kế hoạch thực hiện theo 10 tuần | 22 |
| 4.1.2. Phân công nhiệm vụ các thành viên Nhóm 4 | 24 |
| 4.1.3. Các giai đoạn phát triển và mốc phát hành phiên bản | 25 |
| 4.2. Các chức năng đã triển khai trên thực tế | 26 |
| 4.2.1. Quản lý tài sản phòng máy | 26 |
| 4.2.2. Tiếp nhận và xử lý phiếu sự cố | 27 |
| 4.2.3. Mức thời gian đề xuất (SLA) | 29 |
| 4.2.4. Mã QR cho thiết bị | 30 |
| 4.2.5. Chống lạm dụng nộp phiếu | 31 |
| 4.2.6. Việt hóa | 33 |
| 4.2.7. Giao diện | 33 |
| 4.2.8. Tự động hóa cài đặt | 34 |
| 4.3. Kiểm thử và kết quả | 34 |
| 4.3.1. Cách kiểm thử | 34 |
| 4.3.2. Kết quả kiểm tra chức năng theo vai trò | 34 |
| 4.3.3. Kết quả kiểm tra chống lạm dụng | 35 |
| 4.3.4. Pipeline kiểm tra tự động | 36 |
| 4.3.5. Lỗi đã tìm ra và sửa | 37 |
| 4.3.6. Rà soát chất lượng sau khi hoàn thiện | 37 |
| 4.3.7. Đo tải định lượng hệ thống bằng wrk | 39 |
| **CHƯƠNG 5. ĐÁNH GIÁ, HẠN CHẾ VÀ HƯỚNG PHÁT TRIỂN** | 40 |
| 5.1. Kết quả đạt được | 40 |
| 5.2. Hạn chế của đề tài | 41 |
| 5.3. Hướng phát triển | 42 |
| 5.4. Bài học kinh nghiệm | 43 |
| **KẾT LUẬN VÀ KIẾN NGHỊ** | 44 |
| Kết luận | 44 |
| Kiến nghị | 45 |
| **TÀI LIỆU THAM KHẢO** | 46 |
| A. Văn bản pháp lý và số liệu khảo sát thực tế | 46 |
| B. Tiêu chuẩn ngành và tài liệu kỹ thuật quốc tế | 46 |
| C. Hồ sơ kỹ thuật của đề tài PineDesk | 47 |
| **PHỤ LỤC** | 48 |
| Phụ lục A. Bảng thông số kỹ thuật 10 phòng máy thực tế Trung tâm CNTT | 48 |
| Phụ lục B. Tài khoản thử nghiệm và phân quyền vai trò | 50 |
| Phụ lục C. Hướng dẫn cài đặt và vận hành hệ thống một lệnh | 51 |
| Phụ lục D. Danh mục 18 ảnh minh chứng giao diện | 52 |
| Phụ lục E. Kế hoạch chi tiết 10 tuần thực tập tốt nghiệp | 54 |
| Phụ lục F. Bộ câu hỏi và trả lời phản biện chuyên sâu trước Hội đồng | 56 |

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
| Bảng 2.1 | Bốn dịch vụ container trong hệ thống | 10 |
| Bảng 3.1 | Ba mâu thuẫn nghiệp vụ và dữ kiện khảo sát thực tế | 14 |
| Bảng 3.2 | Hệ màu bản sắc Đà Lạt kết hợp phong cách Apple Precision và Claude Warmth | 18 |
| Bảng 3.3 | Phân bố mã nguồn dự án theo phân loại ngôn ngữ | 19 |
| Bảng 3.4 | Đối chiếu 20 đóng góp kỹ thuật của PineDesk so với GLPI 11 nguyên bản | 20 |
| Bảng 4.1 | Kế hoạch và tiến độ thực hiện 10 tuần thực tập tốt nghiệp | 22 |
| Bảng 4.1b | Phân công nhiệm vụ các thành viên Nhóm 4 trong đề tài | 24 |
| Bảng 4.2 | Thống kê cơ sở vật chất 10 phòng máy tính thực tế do Trung tâm CNTT quản lý | 26 |
| Bảng 4.3 | Phân bố phiếu sự cố mẫu theo trạng thái chuẩn ITIL | 28 |
| Bảng 4.4 | Năm mức thời gian phản hồi và xử lý đề xuất (SLA kỹ thuật) | 29 |
| Bảng 4.5 | Sáu tầng phòng thủ chống lạm dụng nộp phiếu sự cố | 30 |
| Bảng 4.6 | Các tham số hạn mức nghiệp vụ chống spam | 31 |
| Bảng 4.7 | Kết quả kiểm thử chức năng theo vai trò người dùng | 34 |
| Bảng 4.8 | Sáu nhóm kiểm tra tự động trong pipeline CI | 36 |
| Bảng 4.9 | Mười ba vấn đề phát hiện khi rà soát chất lượng và giải pháp xử lý | 37 |
| Bảng 4.10 | Kết quả kiểm chứng toàn diện sau đợt rà soát chất lượng | 38 |
| Bảng 4.11 | Kết quả đo tải định lượng hệ thống bằng công cụ wrk | 39 |
| Bảng 5.1 | Tổng hợp các hạn chế còn tồn tại của đề tài | 41 |

---

## DANH MỤC HÌNH ẢNH

| Số hiệu | Tên hình | Trang |
|---|---|---|
| Hình 3.1 | Kiến trúc tổng thể hệ thống PineDesk | 16 |
| Hình 3.2 | Cây thư mục tổ chức mã nguồn và tài liệu | 19 |
| Hình 4.1 | Giao diện trang đăng nhập hệ thống PineDesk | 26 |
| Hình 4.2 | Bảng điều khiển trung tâm dành cho kỹ thuật viên | 27 |
| Hình 4.3 | Danh mục quản lý 482 máy tính phòng thực hành | 27 |
| Hình 4.4 | Danh mục quản lý 487 màn hình LCD và Smart Tivi | 28 |
| Hình 4.5 | Danh mục quản lý thiết bị mạng và tủ rack | 28 |
| Hình 4.6 | Danh mục quản lý máy in laser Canon LBP2900 | 29 |
| Hình 4.7 | Danh mục quản lý phần mềm bản quyền | 29 |
| Hình 4.8 | Danh sách phiếu sự cố theo dõi theo trạng thái ITIL | 30 |
| Hình 4.9 | Biểu mẫu tiếp nhận và tạo phiếu sự cố mới | 31 |
| Hình 4.10 | Giao diện thêm mới thiết bị vào cơ sở dữ liệu tài sản | 32 |
| Hình 4.11 | Danh mục cơ cấu tổ chức 16 khoa và phòng ban DLU | 32 |
| Hình 4.12 | Chi tiết hồ sơ quản lý một thiết bị máy tính | 33 |
| Hình 4.13 | Danh sách tài khoản người dùng theo vai trò | 33 |
| Hình 4.14 | Menu các hành động quản lý hàng loạt | 34 |
| Hình 4.15 | Giao diện cấu hình nhãn in mã QR | 34 |
| Hình 4.16 | Thẻ mã QR định danh in trên hồ sơ thiết bị | 35 |
| Hình 4.17 | Kết quả sinh mã QR thiết bị hàng loạt | 35 |
| Hình 4.18 | Bảng thống kê toàn cầu tình hình tài sản và sự cố | 36 |

*Ghi chú: Toàn bộ 18 hình ảnh minh chứng được chụp trực tiếp từ giao diện hoạt động thực tế của hệ thống tại thư mục `tai-lieu/anh-giao-dien/`.*

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
- Đề tài **đã đo tải cục bộ** trên máy phát triển (`DO-TAI.md`) nhưng **chưa đo trên hạ tầng thật** của Trường; đây là hạn chế được nêu ở mục 5.2.

**Phạm vi thực hiện:**

- Hệ thống chạy nội bộ bằng Docker Compose trên một máy chủ thử nghiệm, truy cập an toàn qua HTTPS cổng 8443 tại địa chỉ `https://localhost:8443`.
- Dữ liệu nghiệp vụ mô phỏng chuẩn xác cơ cấu tổ chức của Trường Đại học Đà Lạt: 12 tòa nhà, 54 phòng máy, 16 khoa, 79 danh mục phân loại sự cố ITIL.
- Cơ sở dữ liệu thiết bị phần cứng được ánh xạ trực tiếp từ 10 phòng máy tính thực tế do Trung tâm CNTT quản lý (482 máy tính, 487 màn hình LCD & Smart Tivi, 3 máy in, 17 thiết bị mạng & tủ rack, 3 hệ thống âm thanh).
- Đề tài **không** can thiệp vào mã nguồn lõi GLPI (nguyên tắc Zero-Core-Modification), đảm bảo khả năng nâng cấp mượt mà.
- Đề tài **đã đo tải cục bộ** trên máy phát triển (`DO-TAI.md`) với công cụ `wrk` đạt ~54.000 req/s ở tầng Gateway và ~100 req/s ở tầng ứng dụng GLPI; việc thử nghiệm trực tiếp trên toàn trường là hướng phát triển được nêu tại mục 5.2.

**Phạm vi thời gian:** Học kỳ 1 Năm học 2026 – 2027 (Kế hoạch 10 tuần thực tập tốt nghiệp: từ ngày 10/08/2026 đến ngày 17/10/2026).

## 4. Phương pháp thực hiện

Em làm theo trình tự sau, mỗi bước đều để lại sản phẩm kiểm chứng được:

1. **Khảo sát:** thu thập dữ kiện công khai từ website Trường và ITC, đối chiếu văn bản pháp lý và thông số kỹ thuật thực tế phòng máy, ghi rõ URL và ngày truy cập.
2. **Chọn nền tảng:** cân nhắc giữa tự viết từ đầu, dùng công cụ SaaS đám mây và triển khai nền tảng ITSM mã nguồn mở tiêu chuẩn công nghiệp (GLPI 11).
3. **Dựng hệ thống:** container hóa GLPI 11, MariaDB 10.11, Redis 7 và Nginx trong Docker Compose; nạp danh mục nghiệp vụ; viết các plugin giao diện và chống lạm dụng; viết script tự động hóa.
4. **Kiểm thử đa tầng:** viết harness kiểm thử CSDL 56 điểm kiểm, kiểm tra phân quyền 40 điểm kiểm HTTP theo vai trò, 3 use case Playwright end-to-end, đo tải wrk và pipeline CI 6 nhóm kiểm tra tự động.
5. **Rà soát và cải tiến:** thực hiện đợt rà soát chất lượng toàn diện, sửa 13 vấn đề P0/P1/P2 và ghi lại bằng chứng kiểm chứng cụ thể.

Một nguyên tắc em giữ xuyên suốt: **luôn kiểm tra bằng trình duyệt thật và dữ liệu thật, không chỉ dựa vào giả định**. Có những lỗi chỉ hiện ra khi trình duyệt tải cả trang, ví dụ giới hạn tần suất của Nginx đánh sập trang khi GLPI nạp hàng trăm tệp CSS và JavaScript cùng lúc, hay lỗi logo trả về 404 do một biểu thức chính quy viết sai. Chỉ dùng `curl` thì không bao giờ thấy được những lỗi này.

## 5. Bố cục của báo cáo

Báo cáo gồm phần mở đầu, năm chương, kết luận, tài liệu tham khảo và phụ lục:

- **Chương 1** giới thiệu đơn vị thực tập: Trường Đại học Đà Lạt, Khoa Công nghệ Thông tin, Trung tâm Công nghệ thông tin (ITC), và hiện trạng tiếp nhận sự cố CNTT của Trường.
- **Chương 2** trình bày cơ sở lý thuyết về ITSM/ITIL và các công nghệ sử dụng: GLPI 11, Docker Compose, Nginx Gateway, Redis, MariaDB và Playwright.
- **Chương 3** phân tích yêu cầu bài toán, thiết kế kiến trúc Zero-Core-Modification, hệ thống thiết kế giao diện Apple Precision + Claude Warmth + Bản sắc Đà Lạt, và bảng đối chiếu 20 đóng góp kỹ thuật so với GLPI gốc.
- **Chương 4** trình bày tiến độ 10 tuần thực tập, chi tiết các chức năng đã triển khai (quản lý 10 phòng máy thật, mã QR, phòng thủ sáu tầng, Việt hóa mở rộng), kết quả kiểm thử, đo tải và rà soát chất lượng.
- **Chương 5** đánh giá kết quả đạt được, trung thực chỉ ra các hạn chế, đề xuất hướng phát triển và đúc kết bài học kinh nghiệm.

---

# CHƯƠNG 1. TỔNG QUAN VỀ ĐƠN VỊ THỰC TẬP

## 1.1. Trường Đại học Đà Lạt

Trường Đại học Đà Lạt được thành lập năm 1976 (tiền thân là Viện Đại học Đà Lạt thành lập năm 1957), là trường đại học công lập đa ngành trực thuộc Bộ Giáo dục và Đào tạo, tọa lạc tại số 01 Phù Đổng Thiên Vương, Phường Lâm Viên, thành phố Đà Lạt, tỉnh Lâm Đồng.

Về quy mô, Trường hiện có hơn 14.500 người học (chính xác 14.056 sinh viên đại học, 413 học viên thạc sĩ, 18 nghiên cứu sinh tiến sĩ theo Báo cáo thường niên năm 2025). Đội ngũ viên chức gồm 338 cán bộ, trong đó có 313 giảng viên. Khuôn viên trường rộng 43,2 ha với 69 giảng đường hội trường, 38 phòng thí nghiệm và 30 phòng thực hành máy tính.

Cơ cấu tổ chức của Trường gồm 07 phòng chức năng, 16 khoa đào tạo, 01 viện nghiên cứu, 05 trung tâm và 01 khu nội trú. Trong đó, Khoa Công nghệ Thông tin là đơn vị trực tiếp quản lý chuyên môn của sinh viên, và Trung tâm Công nghệ thông tin (ITC) là đơn vị tiếp nhận sinh viên thực tập tốt nghiệp.

## 1.2. Khoa Công nghệ Thông tin

Khoa Công nghệ Thông tin (tiền thân thuộc Khoa Toán - Tin học được kiện toàn và tái cấu trúc thành lập khoa độc lập nhằm đáp ứng nhu cầu đào tạo nhân lực công nghệ chất lượng cao) là đơn vị đào tạo chuyên sâu hai ngành: Kỹ thuật phần mềm và Công nghệ thông tin của Trường Đại học Đà Lạt.

Khoa hiện có 3 bộ môn chuyên môn: Bộ môn Công nghệ Phần mềm, Bộ môn Mạng máy tính & An toàn thông tin, và Bộ môn Hệ thống thông tin & Khoa học dữ liệu. Đội ngũ giảng viên của Khoa có trình độ cao với tỉ lệ tiến sĩ đạt trên 80%, có nhiều công trình nghiên cứu khoa học công bố quốc tế uy tín.

Đây là đơn vị quản lý chuyên môn trực tiếp của em trong suốt 4 năm học và là nơi phê duyệt đề cương thực tập tốt nghiệp. Báo cáo này được thực hiện dưới sự hướng dẫn trực tiếp của ThS. La Quốc Thắng, giảng viên Bộ môn Công nghệ Phần mềm.

## 1.3. Trung tâm Công nghệ thông tin (ITC)

Trung tâm Công nghệ thông tin (viết tắt theo tên tiếng Anh là ITC) được thành lập theo các quyết định của Hiệu trưởng Trường Đại học Đà Lạt, với chức năng và nhiệm vụ pháp lý được quy định tại Quyết định số 03/09/QĐ-ĐHDL ngày 07/01/2021:
- Tham mưu cho Ban Giám hiệu về chiến lược, quy hoạch và phát triển ứng dụng CNTT;
- Trực tiếp **quản lý và vận hành hệ thống hạ tầng CNTT, mạng truyền thông của toàn Trường**;
- **Tổ chức, quản lý và bảo trì hệ thống phòng thực hành máy tính phục vụ đào tạo và nghiên cứu cho người học**;
- Quản trị các phần mềm dùng chung và cổng thông tin điện tử của Trường.

Theo Quyết định số 395/QĐ-ĐHĐL ngày 10/04/2025, Trung tâm CNTT tiếp tục được kiện toàn và hợp nhất với Trung tâm Giáo dục đào tạo Trí tuệ nhân tạo (AI) thành một đơn vị công nghệ quy mô mới.

**Về nhân sự:** Theo công bố chính thức tại website `https://itc.dlu.edu.vn/gioi-thieu/`, ITC hiện có 5 nhân sự cơ hữu gồm:
1. ThS. Trần Thống — Giám đốc Trung tâm
2. TS. Trần Ngô Như Khánh — Phó Giám đốc Trung tâm
3. ThS. Đặng Quốc Phi — Chuyên viên kỹ thuật hạ tầng (Cán bộ hướng dẫn thực tập)
4. ThS. Lê Thị Uyên — Chuyên viên phần mềm và dịch vụ
5. Phan Trung Tính — Nhân viên kỹ thuật phòng máy

**Về cơ sở vật chất:** ITC hiện trực tiếp quản lý và vận hành 10 phòng thực hành máy tính trọng điểm đặt tại Tòa nhà A và Tòa nhà F (Thư viện), phục vụ đào tạo cho hàng ngàn lượt sinh viên mỗi học kỳ. Đây chính là đơn vị thực tế mà đề tài PineDesk hướng tới phục vụ.

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

## 2.3. Container hóa với Docker và Docker Compose

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

## 2.4. Cổng giao tiếp Nginx Gateway và SSL/TLS

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
| N6 | Bảo mật đa tầng, cô lập ransomware và xác thực email trường DLU | Khuyến nghị của giảng viên hướng dẫn (OWASP Top 10, C3RB3R, @dlu.edu.vn) |

## 3.2. Kiến trúc tổng thể và phân vùng an toàn

```
               [ NGƯỜI DÙNG: Trình duyệt Web / Thiết bị di động ]
                                     │
                             HTTPS (TLS 1.2/1.3):8443
                                     ▼
      ┌─────────────────────────────────────────────────────────────────┐
      │  VÙNG CỔNG VÀO (INGRESS ZONE)                                   │
      │  Container: pinedesk-gateway (Nginx 1.27-Alpine)                │
      │  - Tiếp nhận kết nối an toàn, chấm dứt mã hóa SSL/TLS           │
      │  - Giới hạn tần suất: 30 req/phút nộp phiếu (burst=10 nodelay)  │
      │  - Bộ đệm an toàn chống Slowloris, 9 tiêu đề bảo mật HTTP       │
      │  - Chặn các tệp nhạy cảm (.env, .sql, .bak, .log, .sh)          │
      └──────────────────────────────┬──────────────────────────────────┘
                                     │ Mạng cầu nối: frontend_net
                                     │ HTTP:80 (Nội bộ)
                                     ▼
      ┌─────────────────────────────────────────────────────────────────┐
      │  VÙNG ỨNG DỤNG (APPLICATION ZONE)                               │
      │  Container: pinedesk-glpi (GLPI 11.0.0 / PHP 8.3 FPM)          │
      │  - Phân hệ quản lý tài sản, biểu mẫu FormCreator                │
      │  - Plugin pinedesk: Xác thực email DLU (@dlu.edu.vn),           │
      │    hạn mức phiếu, chống trùng lặp, soát xét ưu tiên             │
      │  - Plugin dlubrand: Bản địa hóa giao diện Bản sắc Đà Lạt        │
      └──────────────────────────────┬──────────────────────────────────┘
                                     │ Mạng cô lập: backend_net (internal: true)
                                     │ Không có đường ra Internet / Không cấp Gateway
                       ┌─────────────┴─────────────┐
                       ▼                           ▼
        ┌─────────────────────────────┐ ┌─────────────────────────────┐
        │ Container: pinedesk-db      │ │ Container: pinedesk-redis   │
        │ MariaDB 10.11 LTS           │ │ Redis 7-Alpine              │
        │ - --local-infile=0          │ │ - maxmemory 256mb           │
        │ - --skip-symbolic-links     │ │ - allkeys-lru               │
        │ - Khóa chống đua GET_LOCK   │ │ - Lưu trữ phiên & Cache     │
        └─────────────────────────────┘ └─────────────────────────────┘
```

*Hình 3.1. Kiến trúc phân vùng an toàn và luồng dữ liệu hệ thống PineDesk*

Hệ thống được thiết kế theo nguyên lý phân vùng phòng thủ theo chiều sâu (Defense-in-Depth), chia làm hai mạng nội bộ riêng biệt:
1. `frontend_net`: Mạng cầu nối giữa Nginx Gateway và ứng dụng GLPI. Nginx là cổng dịch vụ duy nhất mở cổng tiếp nhận kết nối bên ngoài (8443 cho HTTPS và 8080 cho HTTP tự động chuyển hướng).
2. `backend_net`: Mạng nội bộ kết nối GLPI với MariaDB và Redis, được thiết lập thuộc tính `internal: true`. Thuộc tính này chặn hoàn toàn việc cấp gateway ra ngoài Internet cho cơ sở dữ liệu và bộ nhớ đệm, giúp loại bỏ nguy cơ mã độc liên lạc với máy chủ chỉ huy (C2 - Command and Control) nếu hệ thống gặp sự cố an ninh.

**Biện pháp phòng chống tấn công mã độc tống tiền (Ransomware):**
Dựa trên phân tích thực tế từ sự cố mã độc tống tiền C3RB3R tấn công các hệ thống máy chủ lưu trữ và cơ sở dữ liệu trường học, đề tài triển khai ba lớp phòng thủ kiên cố ở tầng hạ tầng container:
- *Cô lập cơ sở dữ liệu tuyệt đối:* MariaDB và Redis không công bố cổng ra máy chủ vật lý (`ports` bị loại bỏ, chỉ dùng `expose` nội bộ) và nằm hoàn toàn trong mạng `backend_net` cô lập. Mã độc bên ngoài không thể quét hay kết nối trực tiếp vào cổng 3306.
- *Ngăn chặn leo thang đặc quyền:* Toàn bộ 4 container được thiết lập cờ `security_opt: [ "no-new-privileges:true" ]`, tước bỏ khả năng chiếm quyền root thông qua các tệp thực thi setuid bên trong container.
- *Khóa các lỗ hổng khai thác tệp trong MariaDB:* MariaDB được khởi động với các tham số khắt khe `--local-infile=0` (ngăn chặn việc đọc trộm tệp tin hệ thống máy chủ thông qua SQL injection) và `--skip-symbolic-links` (ngăn chặn tấn công vượt quyền qua liên kết mềm hệ thống tệp).

## 3.3. Nguyên tắc thiết kế: tùy biến nằm ngoài lõi

Đây là quyết định kiến trúc quan trọng nhất của đề tài, và em giữ nó xuyên suốt.

GLPI cho phép ghi đè giao diện qua hai tầng. Tầng thứ nhất là bảng màu (palette), chỉ đăng ký tên để GLPI liệt kê trong phần thiết lập giao diện. Tầng thứ hai là CSS ghi đè, chứa toàn bộ mã màu và các chi tiết giao diện. Đề tài dùng một plugin tên `dlubrand` nạp CSS riêng qua hook `ADD_CSS` và `ADD_CSS_ANONYMOUS_PAGE`, nên giao diện được áp trên mọi trang, kể cả trang đăng nhập khi chưa có phiên làm việc.

Trong quá trình làm, em gỡ hẳn mã màu khỏi các tệp `themes/*.scss` để tránh lặp màu ở hai nơi. Hiện `themes/*.scss` chỉ còn vai trò "giấy đăng ký": tên tệp là khóa bảng màu, nội dung chỉ có chú thích. Toàn bộ mã màu giao diện GLPI nằm duy nhất trong `plugins/dlubrand/public/css/dlu-theme.css`. Muốn đổi màu thì sửa một tệp.

## 3.4. Hệ thống thiết kế giao diện: Apple Precision, Claude Warmth và Bản sắc Đà Lạt

Giao diện của PineDesk không đơn thuần là thay đổi màu sắc mà là một hệ thống thiết kế hoàn chỉnh (Design System), được chuẩn hóa chi tiết trong tài liệu `DESIGN.md`. Hệ thống là sự kết hợp hài hòa giữa ba thế giới thẩm mỹ:

1. **Apple Precision (Độ chính xác và tương tác vi mô):**
   - Các nút bấm và thẻ tương tác có phản hồi vật lý khi click (`transform: scale(0.98)`).
   - Bán kính bo góc có hệ thống: 6px cho badge/chip, 8px cho nút bấm và ô nhập liệu, 12px cho thẻ card/bảng điều khiển và 16px cho modal.
   - Thẻ trạng thái dạng viên thuốc (`capsule pill chip`) với chấm trạng thái (`status-dot`) phát sáng nhẹ, giúp kỹ thuật viên nhận diện nhanh trạng thái phiếu sự cố (Mới, Đang xử lý, Chờ duyệt, Đã đóng).

2. **Claude Editorial Warmth (Sự ấm áp và nhân bản):**
   - Loại bỏ hoàn toàn nền trắng gắt công nghiệp (`#FFFFFF`), thay bằng màu sương ấm (`Warm mist surface` `#FAF9F5`), giúp giảm mỏi mắt cho kỹ thuật viên khi trực ca làm việc kéo dài.
   - Đường phân cách và viền thẻ siêu mảnh (`1px hairline border rgba(0, 0, 0, 0.06)`), tạo cảm giác nhẹ nhàng, tinh tế.
   - Ứng dụng phông chữ có chân biên tập (`Literata`) cho các tiêu đề lớn của trang bảng điều khiển và trang đăng nhập, mang lại phong thái học thuật trang trọng của một trường đại học.

3. **Bản sắc Đà Lạt (Dalat Academic Identity):**
   - Trích xuất trực tiếp từ các dải màu biểu trưng trên huy hiệu logo của Trường Đại học Đà Lạt.

| Mã màu Hex | Tên màu | Ý nghĩa biểu trưng trong logo DLU | Vai trò trong giao diện PineDesk |
|---|---|---|---|
| `#607824` | Xanh rêu đồi thông | Đồi thông, dòng chữ "ĐẠI HỌC ĐÀ LẠT" | Màu chủ đạo (Primary brand), thanh điều hướng, nút chính |
| `#F08418` | Cam đất dã quỳ | Vòng hoa văn mặt trời, ánh nắng cao nguyên | Màu hành động, điểm nhấn cảnh báo, thẻ ưu tiên Trung bình |
| `#CC2430` | Đỏ sao cao nguyên | Ngôi sao trung tâm huy hiệu DLU | Thẻ cảnh báo sự cố khẩn cấp, SLA vi phạm |
| `#90B43C` | Xanh lá sườn núi | Sườn núi Langbiang đón nắng | Thẻ thành công, trạng thái thiết bị "Đang hoạt động" |
| `#C0CC84` | Xanh nhạt rừng thông | Rừng thông xa trong sương mờ | Nền phụ, hover effect trên danh mục |
| `#3D4E17` | Xanh rêu đậm | Chân núi thung lũng | Nền thanh menu tối, header bảng dữ liệu |
| `#3E8E9E` | Xanh hồ Xuân Hương | Màu nước hồ lắng đọng sương mai | Điểm nhấn liên kết, thẻ thông tin mở rộng |

*Bảng 3.2. Hệ màu bản sắc Đà Lạt kết hợp phong cách Apple Precision và Claude Warmth*

Hệ thống cung cấp ba biến thể bảng màu: `da_lat` (xanh rêu, mặc định), `da_lat_suong` (xanh hồ sương mai) và `da_lat_nang` (cam đất dã quỳ), tự động thích ứng hoàn hảo với cả chế độ sáng (Light mode) và tối (Dark mode) mà không bị lỗi tương phản.

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
├── plugins/pinedesk/            # Plugin chặn hạn mức phiếu (T3/T4/T6) — hook ngoài lõi
│   ├── hook.php                 #   Kiểm tra hạn mức + chống trùng + nhật ký
│   └── tests/kiem-thu-han-muc.php #  Harness kiểm thử trên CSDL thật (56 điểm kiểm)
├── scripts/                     # Script tự động hóa (19 .sh, 7 .py, 13 .js)
├── backup/                      # Script sao lưu
└── tai-lieu/                    # Tài liệu và ảnh minh chứng
```

*Hình 3.2. Cây thư mục mã nguồn*

Quy mô mã nguồn tự viết và tùy biến tính đến ngày 03/10/2026: khoảng 22.919 dòng, phân bố như sau.

| Loại | Số tệp | Số dòng |
|---|---|---|
| Markdown | 14 | 3.984 |
| Python | 7 | 4.326 |
| Shell | 19 | 2.957 |
| SQL | 3 | 2.030 |
| JavaScript | 13 | 1.905 |
| PHP (Plugin ngoài lõi) | 4 | 1.892 |
| CSS | 1 | 1.651 |
| YAML | 2 | 1.253 |
| HTML | 4 | 373 |
| JSON | 2 | 46 |

*Bảng 3.3. Phân bố mã nguồn theo loại tệp*

## 3.6. Bảng đối chiếu đóng góp kỹ thuật so với GLPI 11 gốc

Để làm rõ ranh giới giữa nền tảng mã nguồn mở có sẵn và phần việc do em trực tiếp phát triển, bảng dưới đây đối chiếu 20 hạng mục kỹ thuật cốt lõi giữa bản cài đặt GLPI 11 mặc định và hệ thống PineDesk hoàn thiện.

| Hạng mục | GLPI 11 gốc khi mới cài | Hệ thống PineDesk hoàn thiện | Giá trị kỹ thuật đóng góp |
|---|---|---|---|
| Khởi động hệ thống | Cần cài thủ công từng bước web | Cài đặt tự động bằng một lệnh `bash scripts/cai-dat-tat-ca.sh` | Tự động hóa toàn bộ quá trình thiết lập |
| Cổng giao tiếp mạng | Chạy HTTP không mã hóa hoặc tự cấu hình | Nginx gateway HTTPS cổng 8443, SSL tích hợp SAN | Bảo mật kết nối, hỗ trợ mạng nội bộ không lỗi cert |
| Nhận diện thương hiệu | Giao diện chuẩn Tabler xám/xanh | Bảng màu Đà Lạt (xanh rêu, cam đất) + logo DLU | Bộ nhận diện thương hiệu nhất quán qua CSS ngoài lõi |
| Ngôn ngữ tiếng Việt | Gói `vi_VN.mo` chính thức chỉ đạt ~32% | Lớp phủ gộp bổ sung 667 thuật ngữ + 212 mục số nhiều | Dịch 100% các thẻ trạng thái và menu thường dùng |
| Cạm bẫy dịch số nhiều `_n()` | Để nguyên tiếng Anh do khóa `\0` | Script gộp catalog xử lý trực tiếp khóa ghép `\0` | Khắc phục triệt để lỗi thẻ số nhiều hiển thị tiếng Anh |
| Việt hóa dữ liệu CSDL | Tên hồ sơ, bảng điều khiển vẫn là tiếng Anh | Script `viet-hoa-du-lieu.sh` cập nhật tự động trong CSDL | Đồng bộ tiếng Việt ở cả tầng dữ liệu |
| Cơ cấu tổ chức trường | Cơ sở dữ liệu rỗng | Nạp sẵn 16 khoa, 10 phòng, 7 trung tâm, 12 tòa nhà, 54 phòng | Ánh xạ chính xác dữ liệu thực tế Đại học Đà Lạt |
| Phân loại sự cố ITIL | Rỗng | 79 loại sự cố 2 cấp chuẩn hóa | Hỗ trợ phân loại sự cố chính xác ngay khi vận hành |
| Dữ liệu thiết bị mẫu | Rỗng | 482 máy tính, 487 màn hình & Smart Tivi, 3 máy in, 17 thiết bị mạng | Nạp đúng 10 phòng máy thực tế Trung tâm CNTT ĐH Đà Lạt |
| Tài khoản thử nghiệm | Chỉ có tài khoản mặc định `glpi` | 6 tài khoản mẫu cho 3 vai trò (SV, GV, KTV) | Chứng minh phân quyền Least Privilege trên thực tế |
| Quy trình phiếu mẫu | Rỗng | 13 phiếu trải đều các trạng thái chuẩn ITIL | Minh họa luồng xử lý từ tiếp nhận đến đóng phiếu |
| Quy định hạn mức xử lý (SLA) | Rỗng | 5 mức SLA kỹ thuật (P1 đến P5) kèm mốc TTO và TTR | Thiết lập cơ chế kiểm soát tiến độ xử lý sự cố |
| Chống spam tại tầng mạng | Không có | Nginx rate limit 30 request/phút theo IP có burst đệm | Ngăn chặn bot tự động nộp phiếu tần suất cao |
| Chống lạm dụng theo tài khoản | Không có | Plugin `pinedesk` chặn trần 5 phiếu mở và 10 phiếu/ngày | Chống spam phiếu hiệu quả trong môi trường mạng NAT |
| Chống nộp phiếu trùng lặp | Không có | Plugin `pinedesk` chặn phiếu trùng cùng thiết bị trong 30 phút | Ngăn chặn hiện tượng gửi lặp nhiều lần cho một lỗi |
| Ghi vết nhật ký tạo phiếu | Lịch sử chung khó tra cứu hạn mức | Bảng chuyên dụng `glpi_plugin_pinedesk_ticketlog` | Lưu vết địa chỉ IP, tài khoản, nguyên nhân chặn |
| Khả năng an toàn đồng thời | Dễ race condition khi mở nhiều tab | MariaDB mutex `GET_LOCK()` theo từng tài khoản | Đảm bảo tính nhất quán dữ liệu khi gửi đồng thời |
| Tính năng mã QR thiết bị | Chưa có hoặc plugin Barcode lỗi trên GLPI 11 | Vá 3 lỗi tương thích cho plugin Barcode 2.7.1 | Kích hoạt thành công tính năng in QR hàng loạt |
| Giải pháp QR dự phòng | Không có | Script Python `sinh-ma-qr.py` kết xuất mã độc lập | Không phụ thuộc vào chu kỳ nâng cấp của GLPI |
| Kiểm thử tự động (CI) | Không có kịch bản cho dự án | Pipeline CI kiểm tra cú pháp, cấu hình và 46 test cases | Đảm bảo hệ thống ổn định trước khi đưa vào vận hành |

*Bảng 3.4. Đối chiếu 20 đóng góp kỹ thuật của PineDesk so với GLPI 11 nguyên bản*

---

# CHƯƠNG 4. TRIỂN KHAI VÀ KIỂM THỬ

## 4.1. Kế hoạch và tiến độ thực hiện 10 tuần thực tập

Kỳ thực tập tốt nghiệp diễn ra trong Học kỳ 1 Năm học 2026 – 2027 với thời lượng chính thức 10 tuần (từ ngày 10/08/2026 đến ngày 17/10/2026), theo đúng Đề cương chi tiết đã được Khoa Công nghệ Thông tin và Trung tâm CNTT phê duyệt.

### 4.1.1. Kế hoạch thực hiện theo 10 tuần

| Tuần | Thời gian | Nội dung công việc thực hiện | Kết quả / Sản phẩm bàn giao |
|:---:|---|---|---|
| **1** | 10/08 – 15/08/2026 | Tiếp nhận thực tập tại ITC; tìm hiểu chức năng nhiệm vụ, nội quy và cơ cấu tổ chức; khảo sát sơ bộ hạ tầng mạng và phòng máy DLU. | Biên bản tiếp nhận thực tập; báo cáo khảo sát hiện trạng hạ tầng. |
| **2** | 17/08 – 22/08/2026 | Khảo sát quy trình tiếp nhận và xử lý sự cố CNTT tại ITC; phỏng vấn kỹ thuật viên; xác định các khoảng trống và yêu cầu nghiệp vụ ITSM. | Tài liệu đặc tả bài toán nghiệp vụ với 3 mâu thuẫn cốt lõi (M1, M2, M3). |
| **3** | 24/08 – 29/08/2026 | Nghiên cứu kiến trúc nền tảng GLPI 11, MariaDB 10.11, Redis 7 và Nginx; thiết kế kiến trúc container hóa và bảo mật mạng nội bộ. | Thiết kế kiến trúc tổng thể; cấu hình ban đầu `docker-compose.yml`. |
| **4** | 31/08 – 05/09/2026 | Xây dựng cơ sở dữ liệu nền tảng: danh mục 12 tòa nhà, 54 phòng, 16 khoa, 10 phòng ban, 79 loại sự cố phân cấp theo chuẩn ITIL. | Script tự động `nap-du-lieu-nen.sh` và `seed-du-lieu-nen.sql`. |
| **5** | 07/09 – 12/09/2026 | Thiết kế và cài đặt lớp chống lạm dụng sáu tầng: Nginx rate limit, cơ chế phiên, quota hạn mức phiếu T3, chống nộp trùng T4, kiểm duyệt T5. | Plugin `pinedesk` (hook `PRE_ITEM_ADD`), bảng nhật ký tạo phiếu. |
| **6** | 14/09 – 19/09/2026 | Thiết kế hệ thống giao diện bản sắc Đà Lạt kết hợp Apple Precision và Claude Warmth; thực hiện Việt hóa mở rộng 667 thuật ngữ và 212 chuỗi số nhiều. | Plugin `dlubrand`, tệp CSS `dlu-theme.css`, tệp từ điển gộp `vi_VN.mo`. |
| **7** | 21/09 – 26/09/2026 | Tích hợp mã QR cho thiết bị: vá 3 lỗi tương thích của plugin Barcode trên GLPI 11; phát triển script Python dự phòng sinh nhãn in hàng loạt. | Tính năng in mã QR từ hồ sơ thiết bị; script `sinh-ma-qr.py`. |
| **8** | 28/09 – 03/10/2026 | Thu thập thông số kỹ thuật thực tế 10 phòng máy Trung tâm CNTT; xây dựng script nạp 482 máy tính, 487 màn hình & TV, thiết bị mạng, máy in. | Script `seed-du-lieu-mau.sql` ánh xạ 10 phòng máy thật (A24.1, A8, TV...). |
| **9** | 05/10 – 10/10/2026 | Kiểm thử toàn diện: xây dựng harness 56 điểm kiểm, kiểm tra phân quyền HTTP 40 mục, kiểm thử 3 use case Playwright E2E, đo tải wrk trong Docker. | Harness `kiem-thu-han-muc.php`, `kiem-tra-chuc-nang.sh`, pipeline CI. |
| **10** | 12/10 – 17/10/2026 | Rà soát chất lượng đối kháng (xử lý 13 vấn đề P0/P1/P2); đóng gói script cài đặt một lệnh `cai-dat-tat-ca.sh`; hoàn thiện báo cáo và slide bảo vệ. | Hệ thống PineDesk hoàn chỉnh, báo cáo tốt nghiệp và slide bảo vệ. |

*Bảng 4.1. Kế hoạch và tiến độ thực hiện 10 tuần thực tập tốt nghiệp*

### 4.1.2. Phân công nhiệm vụ các thành viên Nhóm 4

Theo quyết định phân công thực tập tốt nghiệp của Trung tâm CNTT — Trường Đại học Đà Lạt trong Học kỳ 1 Năm học 2026 – 2027, đề tài *Xây dựng hệ thống hỗ trợ kỹ thuật (IT Helpdesk)* được giao cho **Nhóm 4 gồm 3 sinh viên**: Phùng Võ Quốc Hiển (Nhóm trưởng), Lý Gia Bảo và Nguyễn Việt Bình, dưới sự hướng dẫn trực tiếp của ThS. La Quốc Thắng và ThS. Đặng Quốc Phi.

Để đảm bảo hoàn thành khối lượng công việc thực tiễn quy mô lớn (quản lý 482 máy tính, 487 màn hình thuộc 10 phòng máy, thiết lập 6 tầng bảo mật, mở rộng 667 thuật ngữ tiếng Việt và xây dựng 56 điểm kiểm thử tự động), đồng thời bám sát đúng Đề cương thực tập tốt nghiệp cá nhân đã được phê duyệt, nhóm đã thống nhất ma trận phân công trách nhiệm chi tiết (Bảng 4.1b):

| Thành viên | Vai trò | Trách nhiệm và khối lượng công việc đảm nhận | Tệp nguồn & tài liệu phụ trách chính |
|---|---|---|---|
| **Phùng Võ Quốc Hiển**<br>*(MSSV: 2212364)* | **Nhóm trưởng<br>Kỹ thuật & Bảo mật** | - Thiết kế kiến trúc phân vùng 4 container Docker, cấu hình Nginx Gateway HTTPS.<br>- Phát triển lớp bảo mật phòng thủ chiều sâu 6 tầng & plugin `pinedesk` (Xác thực email DLU, hạn mức nộp phiếu, chống trùng bằng khóa MariaDB `GET_LOCK`, nhật ký kiểm toán).<br>- Phân quyền theo vai trò (Self-Service, Technician, Admin) và cấu hình FormCreator.<br>- Xây dựng bộ kiểm thử tự động toàn diện (harness CSDL 56 điểm kiểm, kịch bản Playwright E2E 3 use case, đo tải định lượng wrk, pipeline CI 6 nhóm).<br>- Chủ trì tích hợp toàn hệ thống, tự động hóa luồng cài đặt và viết báo cáo kỹ thuật. | `docker-compose.yml`, `nginx/`, `plugins/pinedesk/`, `tests/kiem-thu-han-muc.php`, `kiem-tra-usecase.js`, `.github/workflows/ci.yml`, `cai-dat-tat-ca.sh`, `BAO-CAO-THUC-TAP.md` |
| **Lý Gia Bảo**<br>*(MSSV: 2213934)* | **Thành viên** | - Khảo sát thực địa thông số kỹ thuật 10 phòng máy tính tại Trung tâm CNTT.<br>- Số hóa cơ sở dữ liệu tài sản: 482 máy tính, 487 màn hình & Tivi, 3 máy in, 17 thiết bị mạng; thiết lập quy chuẩn mã định danh tài sản (`TDL-PC-A241-001`).<br>- Thiết kế hệ thống giao diện nhận diện bản sắc Đà Lạt (plugin `dlubrand`, CSS chủ đề trích xuất màu logo DLU).<br>- Khắc phục 3 lỗi tương thích của plugin Barcode 2.7.1 trên GLPI 11; phát triển script Python độc lập `sinh-ma-qr.py` phục vụ in nhãn mã QR hàng loạt.<br>- Chụp và quản lý hệ thống ảnh chụp màn hình minh chứng giao diện thực tế. | `plugins/dlubrand/`, `themes/`, `DESIGN.md`, `sinh-ma-qr.py`, `scripts/seed-du-lieu-mau.sql` (khối thiết bị 10 phòng máy), `tai-lieu/anh-giao-dien/` |
| **Nguyễn Việt Bình**<br>*(MSSV: 2213831)* | **Thành viên** | - Khảo sát quy trình tiếp nhận và xử lý sự cố CNTT hiện hành tại ITC, phỏng vấn kỹ thuật viên và người học để đúc kết 3 mâu thuẫn cốt lõi.<br>- Chuẩn hóa bộ danh mục trường học: 12 tòa nhà, 54 phòng, 16 khoa và 79 danh mục sự cố 2 cấp chuẩn ITIL v4.<br>- Thiết kế chính sách cam kết thời gian dịch vụ (5 mức SLA kỹ thuật); cấu hình luồng nghiệp vụ bảo trì định kỳ và mượn trả thiết bị phòng máy.<br>- Tham gia mở rộng bản dịch tiếng Việt cho GLPI 11 (667 mục từ + 212 chuỗi số nhiều), đạt độ phủ 100% menu và biểu mẫu.<br>- Thực hiện kiểm thử chấp nhận người dùng (UAT), soạn thảo tài liệu hướng dẫn vận hành và kịch bản demo 7 phút. | `seed-du-lieu-nen.sql`, `seed-sla-va-chong-lam-dung.sql`, `viet-hoa-du-lieu.sh`, `bo-sung-tieng-viet.py`, `kiem-tra-chuc-nang.sh`, `tai-lieu/README.md`, `SO-LIEU-THUC-TE-DLU.md` |
| **Cả 3 thành viên** | **Thực tập sinh ITC** | - Cùng tham gia công tác quản lý, bảo dưỡng định kỳ các phòng máy tính khu A và khu TV dưới sự hướng dẫn của ThS. Đặng Quốc Phi.<br>- Hỗ trợ cài đặt phần mềm và chuẩn bị phòng máy phục vụ Hội thi Tin học trẻ toàn quốc tổ chức tại Trường Đại học Đà Lạt.<br>- Tham gia hỗ trợ hạ tầng kỹ thuật cho cuộc thi An toàn thông tin sinh viên. | Hoàn thành tốt các nhiệm vụ chuyên môn và công tác hỗ trợ đột xuất được Ban Giám đốc ITC giao phó. |

*Bảng 4.1b. Phân công nhiệm vụ các thành viên Nhóm 4 trong đề tài*

### 4.1.3. Các giai đoạn phát triển và mốc phát hành phiên bản

Quá trình phát triển phần mềm được ghi nhận chi tiết qua 4 phiên bản chính và một đợt rà soát chất lượng chuyên sâu:

- **Phiên bản 0.1.0 (22/09/2026 - Dựng nền tảng):** Khởi tạo hạ tầng 4 container Docker cô lập, thiết lập Nginx Gateway HTTPS với chứng chỉ SSL có SAN, tích hợp plugin giao diện `dlubrand` nhận diện bản sắc Đà Lạt, vá lỗi plugin mã QR Barcode 2.7.1 và thiết lập pipeline CI 6 nhóm kiểm tra tự động.
- **Phiên bản 0.2.0 (02/10/2026 - Chuyển sang nghiệp vụ thực tế):** Tiếp thu ý kiến đóng góp của giảng viên hướng dẫn sau buổi báo cáo tiến độ lần 1, hoàn thiện đặc tả bài toán nghiệp vụ với 3 mâu thuẫn; xây dựng kiến trúc phòng thủ sáu tầng chống lạm dụng; nạp 10 bản ghi SLA kỹ thuật; tích hợp cơ chế bảo trì định kỳ (`glpi_ticketrecurrents`) và mượn trả thiết bị (`glpi_reservations`).
- **Phiên bản 0.3.0 (03/10/2026 - Chuẩn hóa dữ liệu):** Đối chiếu và kiểm chứng số liệu thực tế; khắc phục lỗi lệch tên vị trí làm thất thoát thiết bị; thống nhất công cụ đo độ phủ từ điển Việt hóa.
- **Phiên bản 0.4.0 (03/10/2026 - Tự động hóa cài đặt máy sạch):** Khắc phục triệt để lỗi tài khoản demo thiếu quyền trên môi trường trắng bằng cách đưa script gán quyền và Việt hóa dữ liệu vào luồng cài đặt tự động `cai-dat-tat-ca.sh`; chuyển đổi bộ kiểm thử giao diện sang Playwright; bổ sung các bài kiểm thử use case thật.
- **Đợt rà soát chất lượng chuyên sâu (08/10 – 09/10/2026):** Rà soát mã nguồn theo nguyên tắc đối kháng; giải quyết 13 vấn đề từ P0 đến P2 (bổ sung bản quyền GNU GPL-3.0, sửa hướng dẫn phục hồi dữ liệu bảo mật, đưa kiểm thử E2E vào CI); đo tải định lượng hệ thống bằng `wrk`; tự động hóa tối thiểu tầng T5 nhắc soát xét ưu tiên; hoàn thiện khóa chống đua MariaDB `GET_LOCK` và gán tác giả Hệ thống cho ghi chú nội bộ.

## 4.2. Các chức năng đã triển khai trên thực tế

### 4.2.1. Quản lý tài sản phòng máy

Hệ thống quản lý toàn diện các danh mục tài sản CNTT: máy tính để bàn, máy chủ, máy tính xách tay, màn hình LCD, Smart Tivi giảng dạy, máy in, thiết bị mạng và phần mềm bản quyền.

Mã tài sản được chuẩn hóa theo quy ước quản lý thực tế của Trường Đại học Đà Lạt: `TDL-<LOAI>-<PHONG>-<SO>`, ví dụ:
- `TDL-PC-A241-001`: Trường Đại học Đà Lạt – Máy tính để bàn – Phòng A24.1 – Máy số 01.
- `TDL-TV-A83-001`: Trường Đại học Đà Lạt – Smart Tivi – Phòng A8.3 – Tivi 01.
- `TDL-SW-TV1-001`: Trường Đại học Đà Lạt – Thiết bị Switch mạng – Phòng TV1 – Switch 01.

Cơ sở dữ liệu tài sản được trích xuất trực tiếp từ hồ sơ trang thiết bị 10 phòng máy tính thực tế do Trung tâm CNTT quản lý (theo tài liệu khảo sát nội bộ `THÔNG SỐ CÁC PHÒNG MÁY TT_CNTT.docx`), thay thế hoàn toàn các dữ liệu giả định trước đây:

| STT | Tên phòng máy | Vị trí | Máy SV | Máy GV | Cấu hình máy tính | Màn hình LCD | Smart Tivi | Thiết bị mạng | Máy in & Âm thanh |
|:---:|---|---|:---:|:---:|---|---|---|---|---|
| 1 | Phòng máy A24.1 | Tòa nhà A | 45 | 1 | Dell OptiPlex 3000 Small | Dell 22" E2222H | Sony 85" | Cisco Switch + Unifi AP | Canon LBP2900 + Bosch |
| 2 | Phòng máy A24 lầu | Tòa nhà A | 45 | 1 | Dell OptiPlex 3000 Small | Dell 22" E2222H | Sony 85" | Cisco Switch + Unifi AP | Bosch |
| 3 | Phòng máy A8.3 | Tòa nhà A | 48 | 1 | PC Lắp ráp Intel Core i3 | LG 24" | Inno 85" | Cisco Switch + Unifi AP | Canon LBP2900 + Bosch |
| 4 | Phòng máy A8.4 | Tòa nhà A | 48 | 1 | PC Lắp ráp Intel Core i3 | LG 24" | Inno 85" | Cisco Switch + Unifi AP | Canon LBP2900 |
| 5 | Phòng máy A8.5 | Tòa nhà A | 49 | 1 | PC Lắp ráp Intel Core i5 | LG 24" | Inno 85" | Cisco Switch + Unifi AP | — |
| 6 | Phòng máy A8.6 | Tòa nhà A | 50 | 1 | PC Lắp ráp Intel Core i5 | LG 24" | Inno 85" | Cisco Switch + Unifi AP | — |
| 7 | Phòng máy TV1 | Tòa nhà F | 46 | — | PC Lắp ráp Intel Pentium | LG 24" | Inno 80" | Cisco Switch | — |
| 8 | Phòng máy TV2 | Tòa nhà F | 45 | — | PC Lắp ráp Intel Pentium | LG 24" | Inno 80" | Cisco Switch | — |
| 9 | Phòng máy TV3 | Tòa nhà F | 45 | — | PC Lắp ráp Intel Pentium | LG 24" | Inno 80" | Cisco Switch | — |
| 10 | Phòng máy TV4 | Tòa nhà F | 50 | — | PC Lắp ráp Intel Pentium | LG 24" | Inno 80" | Cisco Switch | — |
| | **Tổng cộng 10 phòng** | | **471** | **6** | **477 máy phòng máy** | **477 màn hình** | **10 Smart Tivi** | **16 thiết bị mạng** | **3 máy in, 3 âm thanh** |

*Bảng 4.2. Thống kê cơ sở vật chất 10 phòng máy tính thực tế do Trung tâm CNTT quản lý*

Ngoài 477 máy tính tại 10 phòng máy trên, hệ thống nạp thêm 3 máy tính xách tay phục vụ mượn lưu động (`TDL-LAP-001..003`), 2 máy chủ trung tâm (`TDL-SRV-001..002`) và 1 Tủ mạng Rack Core trung tâm, nâng tổng số lượng tài sản phần cứng nạp vào CSDL gồm:
- **482 máy tính** (471 máy SV + 6 máy GV + 3 laptop + 2 server).
- **487 màn hình & thiết bị hiển thị** (477 màn hình LCD Dell/LG + 10 Smart Tivi Sony/Inno 80-85 inch).
- **3 máy in laser** Canon LBP2900 phục vụ in ấn giảng dạy.
- **17 thiết bị mạng & tủ rack** (10 Switch Cisco 24/48 port, 6 bộ phát WiFi Unifi AP, 1 Tủ mạng Core Rack 42U).
- **3 hệ thống âm thanh trợ giảng** chuyên dụng Bosch.
- **10 phần mềm bản quyền** dùng chung (Windows 11 Education, Microsoft Office 2021, Visual Studio Code, MATLAB, AutoCAD, Cisco Packet Tracer...).

Bên cạnh dữ liệu phần cứng, danh mục nghiệp vụ đi kèm gồm 12 tòa nhà, 54 phòng máy, 16 khoa đào tạo, 10 phòng ban chức năng và 79 danh mục loại sự cố phân cấp chuẩn ITIL.

Nhằm đảm bảo tính linh hoạt trong quá trình vận hành, hệ thống cung cấp giao diện thêm mới và quản lý thông số kỹ thuật thiết bị, cho phép kỹ thuật viên dễ dàng bổ sung máy tính, màn hình hoặc thiết bị mạng mới vào cơ sở dữ liệu khi nhà trường trang bị thêm. Toàn bộ cơ cấu tổ chức gồm 16 khoa và các phòng ban trực thuộc được cấu hình theo nhóm thực thể phân cấp, hỗ trợ việc phân quyền tiếp nhận sự cố theo từng đơn vị cụ thể.

Mỗi thiết bị khi lưu trữ đều có hồ sơ chi tiết ghi nhận đầy đủ cấu hình phần cứng, vị trí phòng máy, trạng thái hoạt động, lịch sử phát sinh sự cố và nhật ký các lần bảo trì định kỳ. Đặc biệt, để xử lý khối lượng tài sản lớn lên đến hàng trăm máy tính, hệ thống trang bị menu các hành động quản lý hàng loạt, giúp kỹ thuật viên có thể chuyển đổi vị trí, cập nhật trạng thái sử dụng, hoặc sinh mã định danh đồng loạt cho nhiều thiết bị chỉ trong một thao tác.

### 4.2.2. Tiếp nhận và xử lý phiếu sự cố

Phiếu yêu cầu đi theo vòng đời chuẩn ITIL: Mới → Được giao → Đã giải quyết → Đã đóng. Dữ liệu mẫu có 14 phiếu trải đủ các trạng thái.

| Trạng thái | Số phiếu |
|---|---|
| Mới | 4 |
| Được giao | 3 |
| Đã giải quyết | 4 |
| Đã đóng | 3 |

*Bảng 4.3. Phân bố phiếu sự cố mẫu theo trạng thái chuẩn ITIL*

Người dùng nộp phiếu qua menu Hỗ trợ, điền tiêu đề, mô tả, loại sự cố, thiết bị liên quan và mức ưu tiên. Phiếu vào hàng đợi trạng thái Mới, kỹ thuật viên thấy trong danh sách và giao việc.

Phân quyền theo vai trò: sinh viên và giảng viên chỉ thấy phiếu của mình; kỹ thuật viên thấy phiếu của nhóm phụ trách; quản trị thấy toàn bộ.

Bên cạnh việc theo dõi từng phiếu đơn lẻ, hệ thống cung cấp báo cáo thống kê toàn cầu tổng hợp số lượng sự cố theo trạng thái, nhóm thiết bị, phòng máy và hiệu suất xử lý của từng kỹ thuật viên, giúp ban giám đốc Trung tâm CNTT nắm bắt toàn cảnh bức tranh vận hành hạ tầng.

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

### 4.2.5. Chống lạm dụng nộp phiếu và kiểm soát danh tính

Khi mở cổng tiếp nhận sự cố cho hơn 14.500 người học, rủi ro lớn nhất của hệ thống là bị lạm dụng: sinh viên nộp phiếu rác, gửi liên tục khi gặp lỗi mạng, spam làm nghẽn hàng đợi hoặc mạo danh người khác. Theo gợi ý của giảng viên hướng dẫn về việc áp dụng các tiêu chuẩn an toàn thông tin (OWASP Top 10) và yêu cầu bắt buộc đăng nhập bằng email trường, hệ thống xây dựng mô hình phòng thủ theo chiều sâu 6 tầng:

```
   Người dùng (Sinh viên / Giảng viên)
       │
       ▼
  ┌─────────────────────────────────────────────────────────────┐
  │ T1  NGINX GATEWAY   giới hạn tần suất 30 req/phút theo IP   │  chặn bot, flood mạng
  ├─────────────────────────────────────────────────────────────┤
  │ T2  XÁC THỰC EMAIL  bắt buộc email chính thức @dlu.edu.vn   │  chặn email ngoài, mạo danh
  ├─────────────────────────────────────────────────────────────┤
  │ T3  HẠN MỨC TÀI KHOẢN trần 5 phiếu mở, 10 phiếu/ngày        │  chặn spam theo tài khoản
  ├─────────────────────────────────────────────────────────────┤
  │ T4  CHỐNG TRÙNG LẶP   cửa sổ 30 phút (thiết bị / tiêu đề)   │  chặn nộp lặp do sốt ruột
  ├─────────────────────────────────────────────────────────────┤
  │ T5  SOÁT XÉT ƯU TIÊN  nhắc KTV kiểm tra phiếu Cao/Rất cao   │  chặn tự chen hàng
  ├─────────────────────────────────────────────────────────────┤
  │ T6  NHẬT KÝ ĐỘC LẬP   ghi vết users_id, IP, lý do chặn      │  truy vết và kiểm toán
  └─────────────────────────────────────────────────────────────┘
```

*Sơ đồ luồng: Sáu tầng phòng thủ chống lạm dụng và kiểm soát danh tính*

| Tầng | Tên cơ chế | Phạm vi kiểm soát | Cách thức triển khai | Trạng thái |
|---|---|---|---|---|
| T1 | Giới hạn tần suất mạng | Địa chỉ IP máy trạm | Nginx `limit_req_zone` (30 req/phút, `burst=10 nodelay`) | Đã dựng |
| T2 | Xác thực miền email trường | Tài khoản người gửi | Plugin `pinedesk`: chỉ chấp nhận email `@dlu.edu.vn` | Đã dựng |
| T3 | Hạn mức phiếu nghiệp vụ | Tài khoản người gửi | Plugin `pinedesk`: trần 5 phiếu đang mở, 10 phiếu/ngày | Đã dựng |
| T4 | Chống nộp phiếu trùng lặp | Tài khoản + Thiết bị / Tiêu đề | Cửa sổ 30 phút, bảo vệ bằng khóa MariaDB `GET_LOCK` | Đã dựng |
| T5 | Soát xét mức độ ưu tiên | Trạng thái phiếu | Tự động tạo ghi chú nội bộ Hệ thống cho phiếu Cao/Rất cao | Đã dựng |
| T6 | Nhật ký kiểm toán an ninh | Mọi yêu cầu tạo phiếu | Bảng `glpi_plugin_pinedesk_ticketlog` ghi nhận lý do | Đã dựng |

*Bảng 4.5. Sáu tầng chống lạm dụng và kiểm soát danh tính của PineDesk*

**Căn cứ chọn ngưỡng giới hạn tần suất tầng mạng (Tier 1):**
Khuôn viên Trường Đại học Đà Lạt sử dụng cơ chế NAT chung: toàn bộ 35 đến 40 máy tính trong một phòng thực hành chia sẻ chung một địa chỉ IP khi kết nối ra ngoài. Nếu đặt ngưỡng IP quá thấp (chẳng hạn 5 yêu cầu/phút), các sinh viên trong cùng một lớp học khi nộp bài hoặc báo cáo sự cố đồng thời sẽ bị chặn nhầm bởi mã lỗi HTTP 429. Do đó, Nginx Gateway giữ ngưỡng 30 yêu cầu/phút kèm dự phòng `burst=10 nodelay` nhằm triệt tiêu bot tự động, còn việc kiểm soát hạn mức từng cá nhân được chuyển giao hoàn toàn cho tầng T2 và T3 theo tài khoản đăng nhập.

**Hạ tầng email thực tế tại DLU và cơ chế xác thực danh tính (Tier 2):**
Theo quy chuẩn vận hành của Trường Đại học Đà Lạt, toàn bộ dịch vụ thư điện tử được quản lý tập trung trên nền tảng Google Workspace for Education dưới một tên miền duy nhất là `@dlu.edu.vn` (đã xác thực qua bản ghi DNS MX trỏ về máy chủ Google). Quy chuẩn định danh email của trường như sau:
- Sinh viên: `{mssv}@dlu.edu.vn` (Mã số sinh viên 7 chữ số, ví dụ `2110123@dlu.edu.vn`, `2212364@dlu.edu.vn`).
- Giảng viên / Cán bộ: `{tên_viết_tắt}@dlu.edu.vn` (ví dụ `cuonggv@dlu.edu.vn`, `tunglv@dlu.edu.vn`).
- Các subdomain như `cntt.dlu.edu.vn`, `ktt.dlu.edu.vn`, `lms.dlu.edu.vn` chỉ là cổng thông tin web, hoàn toàn không có bản ghi MX và không dùng làm email.

Mặc định, phần mềm GLPI cho phép bất kỳ tài khoản nào đăng nhập cũng được nộp phiếu, kể cả tài khoản chưa khai báo email hoặc sử dụng email cá nhân ngoài trường (`@gmail.com`, `@yahoo.com`), dẫn đến lỗ hổng xác thực theo tiêu chuẩn OWASP (A07: Identification and Authentication Failures). Plugin `pinedesk` can thiệp vào hook `PRE_ITEM_ADD` qua hàm `plugin_pinedesk_has_valid_institutional_email()`, kiểm tra nghiêm ngặt biểu thức chính quy:

```php
$pattern = '/^[a-zA-Z0-9._%+-]+@dlu\.edu\.vn$/i';
```

Nếu người dùng chưa có email hoặc sử dụng email ngoài trường (kể cả subdomain giả định `@sinhvien.dlu.edu.vn`), hàm lập tức hủy bỏ quá trình tạo phiếu (`$item->input = false`) và ghi nhận trạng thái `EMAIL_BLOCKED` vào nhật ký kiểm toán.

*Lưu ý về hành vi giao diện trên GLPI 11 FormCreator:* Khi nộp phiếu qua biểu mẫu FormCreator (`/Form/SubmitAnswers`), việc plugin trả về `$item->input = false` khiến lớp `AbstractCommonITILFormDestination` của lõi GLPI ném ngoại lệ và hiển thị thông báo lỗi chung: "Failed to submit form, please contact your administrator". Giao dịch cơ sở dữ liệu được rollback an toàn, phiếu không bị ghi vào hệ thống và mã lỗi bảo mật được lưu lại trong nhật ký.

**Hạn mức nghiệp vụ và khóa chống đua phân tán MariaDB Mutex (Tier 3 & Tier 4):**
Hạn mức nghiệp vụ được lưu trong bảng cấu hình `glpi_plugin_pinedesk_configs` (mặc định trần 5 phiếu đang mở và 10 phiếu/ngày, cửa sổ chống trùng 30 phút). Để ngăn ngừa tranh chấp dữ liệu (TOCTOU - Time-of-Check to Time-of-Use) khi sinh viên mở nhiều tab trình duyệt hoặc bấm gửi nhiều lần liên tiếp, plugin sử dụng cơ chế khóa phân tán MariaDB: `GET_LOCK('pinedesk_hm_<uid>', 3)`. Khóa được phân tách độc lập theo từng `users_id`, giải phóng chủ động ngay khi phiếu bị chặn hoặc tạo thành công, có đăng ký hàm dọn dẹp an toàn khi tắt tiến trình (`register_shutdown_function`).

| Tham số cấu hình | Giá trị mặc định | Phạm vi tác động | Mục đích kiểm soát |
|---|---|---|---|
| `max_open_tickets` | 5 phiếu | Tài khoản sinh viên / giảng viên | Ngăn chặn tích lũy phiếu chờ xử lý gây quá tải hàng đợi |
| `max_daily_tickets` | 10 phiếu / ngày | Mỗi tài khoản trong 24 giờ | Giới hạn số lượng phiếu tối đa nộp trong một ngày làm việc |
| `duplicate_window_minutes` | 30 phút | Cùng người gửi + thiết bị hoặc tiêu đề | Triệt tiêu hành vi bấm nộp lặp lại nhiều lần |
| `institutional_email_domain` | `@dlu.edu.vn` | Toàn bộ tài khoản nộp phiếu | Xác thực danh tính sinh viên/cán bộ chính danh của trường |
| `distributed_lock_timeout` | 3 giây | Khóa mutex MariaDB `GET_LOCK` | Ngăn chặn tấn công đồng thời TOCTOU qua nhiều tab trình duyệt |

*Bảng 4.6. Các tham số hạn mức nghiệp vụ chống spam*

**Tự động hóa tối thiểu tầng kiểm duyệt (Tier 5):**
Để ngăn chặn hành vi tự nâng mức ưu tiên lên Cao hoặc Rất cao nhằm chen hàng trong danh sách phục vụ, plugin tự động bắt sự kiện tạo phiếu: nếu người gửi thuộc nhóm tự phục vụ mà chọn mức ưu tiên cao, hệ thống tự động chèn một ghi chú nội bộ (`ITILFollowup`) với cờ ẩn danh `is_private = 1`, nhắc kỹ thuật viên cần xác minh hiện trường trước khi điều phối tài nguyên. Tác giả của ghi chú được gán tường minh cho tài khoản Hệ thống (`users_id = 0`), tránh việc GLPI tự động gán tên sinh viên vào ghi chú nội bộ của kỹ thuật viên.

**Tầng kiểm toán độc lập (Tier 6):**
Mọi hành động nộp phiếu (thành công hoặc bị chặn) đều được ghi nhận vào bảng chuyên dụng `glpi_plugin_pinedesk_ticketlog` gồm: `users_id`, `tickets_id`, `ip_address`, `tickets_id_dup`, và mã lý do (`NEW`, `EMAIL_BLOCKED`, `LIMIT_BLOCKED`, `DUP_BLOCKED`, `LOCK_FAIL`, `FAIL_OPEN`). Dữ liệu này giúp Trung tâm CNTT dễ dàng truy vết và đánh giá mức độ lạm dụng qua các câu truy vấn quản trị.

### 4.2.6. Việt hóa

GLPI 11 đóng gói sẵn bản dịch tiếng Việt nhưng chỉ đạt khoảng 32% catalog. Đề tài bổ sung thêm 667 thuật ngữ và 212 mục dạng số nhiều, nâng độ phủ đo được lên 33,6% (2.186 trên 6.511 chuỗi).

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

### 4.3.3. Kết quả kiểm tra chống lạm dụng và an toàn thông tin

Hệ thống chống lạm dụng và kiểm soát danh tính được kiểm chứng qua ba phương pháp độc lập: kiểm thử tích hợp sâu bên trong container cơ sở dữ liệu, kiểm thử luồng người dùng đầu-cuối bằng trình duyệt tự động, và kiểm thử tải mạng trực tiếp.

**1. Kiểm thử tích hợp tự động qua harness chuyên dụng (56/56 điểm kiểm ĐẠT):**
Tệp kiểm thử `plugins/pinedesk/tests/kiem-thu-han-muc.php` được thực thi trực tiếp bên trong container `pinedesk-glpi` trên cơ sở dữ liệu MariaDB thật, tạo các tài khoản tạm thời thuộc hồ sơ tự phục vụ (Self-Service) để kiểm tra toàn bộ 6 tầng phòng thủ và tự động dọn dẹp sạch sẽ sau khi kết thúc:

```bash
docker exec pinedesk-glpi php -f /var/www/glpi/plugins/pinedesk/tests/kiem-thu-han-muc.php
```

| Nhóm | Mục tiêu kiểm thử | Số ca kiểm | Kết quả | Trạng thái ghi nhận |
|---|---|---|---|---|
| 0 | Tiên quyết: Trạng thái plugin, cấu hình động từ bảng | 4 | 4/4 Đạt | Plugin bật, bảng cấu hình hợp lệ |
| 1 | Khởi tạo môi trường: 8 tài khoản tạm, thiết bị & danh mục thật | 11 | 11/11 Đạt | Tài khoản phân quyền Self-Service |
| 1b | Tier 2: Xác thực email trường DLU (@dlu.edu.vn) | 8 | 8/8 Đạt | Chặn không email, chặn Gmail, chặn subdomain; cho phép @dlu.edu.vn |
| 2-3 | Tier 3a: Trần 5 phiếu mở (User A tạo 5 phiếu rồi nộp phiếu thứ 6) | 7 | 7/7 Đạt | Phiếu 6 bị chặn, thông báo tiếng Việt, CSDL lưu đúng 5 phiếu |
| 4 | Tier 4: Chống phiếu trùng lặp nội dung / thiết bị (User B & User D) | 7 | 7/7 Đạt | Phiếu trùng bị hủy, phiếu thiết bị khác thông qua |
| 4c | Tier 3b: Trần phiếu mỗi ngày (User C) | 3 | 3/3 Đạt | Phiếu thứ 3 trong ngày bị chặn đúng thông báo |
| 4d | Chống vượt quyền qua tham số client (User E) | 5 | 5/5 Đạt | Date lùi bị ép về hiện tại, status bị ép về Mới=1 |
| 4e | Chống trùng tiêu đề khác danh mục (User F) | 4 | 4/4 Đạt | Cùng tiêu đề bị chặn, khác tiêu đề thông qua |
| 4f | Tier 5: Tự động nhắc kỹ thuật viên kiểm duyệt phiếu ưu tiên cao | 4 | 4/4 Đạt | Tự động tạo ghi chú nội bộ từ Hệ thống (users_id=0) |
| 5-7 | Miễn trừ cho KTV / Cron và Dọn dẹp dữ liệu kiểm thử | 3 | 3/3 Đạt | KTV không bị hạn mức, dữ liệu kiểm thử được xóa sạch |

*Bảng 4.7b. Kết quả 56 điểm kiểm thử tích hợp cơ chế chống lạm dụng và xác thực danh tính*

Kết quả chi tiết đạt **56/56 điểm kiểm** (100%), chứng minh mọi kịch bản gian lận hoặc sai lệch danh tính đều bị hệ thống chặn đứng ở tầng nghiệp vụ.

**2. Kiểm thử luồng sử dụng thực tế đầu-cuối (End-to-End) bằng Playwright (3/3 use case ĐẠT):**
Script `scripts/kiem-tra-usecase.js` sử dụng thư viện Playwright điều khiển trình duyệt Chromium chạy ngầm, mô phỏng chính xác ba luồng thao tác của người dùng thật:
- *UC1 (Sinh viên nộp phiếu sự cố):* Sinh viên đăng nhập, truy cập FormCreator, điền tiêu đề "Máy tính phòng A101 không khởi động", chọn loại sự cố, nhập nội dung qua bộ soạn thảo TinyMCE và bấm gửi. Kiểm tra phiếu xuất hiện lập tức trong danh sách cá nhân (`status = 1`).
- *UC2 (Sinh viên đặt mượn thiết bị):* Sinh viên truy cập phân hệ Đặt chỗ, chọn thiết bị khả dụng trong phòng máy và hoàn tất đặt mượn thành công.
- *UC3 (Kỹ thuật viên tiếp nhận phiếu):* Kỹ thuật viên đăng nhập giao diện điều hành, xác nhận nhìn thấy phiếu mới của sinh viên, mở chi tiết phiếu và kiểm tra thiết bị liên kết.

Kết quả kiểm thử đầu-cuối: **3/3 ca kiểm thử hoàn thành xuất sắc**, không gặp bất kỳ lỗi giao diện hay bất đồng bộ dữ liệu nào.

**3. Kiểm thử tải mạng và giới hạn tần suất Nginx Gateway (Tier 1):**
Kiểm tra phản ứng của Nginx Gateway bằng cách gửi liên tục 40 yêu cầu HTTP POST vào endpoint nộp phiếu: 11 yêu cầu đầu tiên đi qua thành công (nhờ hạn mức dự phòng `burst=10 nodelay`), từ yêu cầu thứ 12 trở đi hệ thống lập tức trả về mã trạng thái `HTTP 429 Too Many Requests`. Cơ chế giới hạn tần suất tầng mạng hoạt động chính xác theo thiết kế.

### 4.3.4. Pipeline kiểm tra tự động

Mỗi lần đẩy mã nguồn lên nhánh chính, GitHub Actions chạy pipeline gồm 6 nhóm kiểm tra:

| # | Nhóm | Nội dung |
|---|---|---|
| 1 | Cú pháp | `bash -n`, `py_compile`, `node --check`, `php -l` |
| 2 | ShellCheck | Lint shell ở mức warning |
| 3 | Cấu hình | `docker compose config`, mọi service phải có healthcheck, `nginx -t` |
| 4 | Chứng chỉ SSL | Sinh được từ `openssl-san.cnf` và bắt buộc có SAN |
| 5 | Bảo mật | Không commit `.env` hay chứng chỉ; không hardcode mật khẩu hay đường dẫn máy cá nhân |
| 6 | Smoke test | Khởi động thật 4 container, chờ healthy, kiểm tra HTTP/HTTPS |

*Bảng 4.8. Sáu nhóm kiểm tra trong pipeline CI*

Nhóm smoke test gồm 27 bước, trong đó có những bước chốt lại đúng các lỗi từng gặp để chúng không quay lại: tài khoản demo phải có hồ sơ quyền và đăng nhập được, dữ liệu hiển thị phải đã Việt hóa, thương hiệu và dải màu ưu tiên phải được đặt, từ điển phải đủ 667 thuật ngữ và 212 mục số nhiều, và chức năng phân quyền theo vai trò phải hoạt động.

Pipeline chặn merge nếu bất kỳ cửa nào thất bại.

### 4.3.5. Lỗi đã tìm ra và sửa

Trong quá trình làm, em tìm ra và sửa một loạt lỗi, phần lớn chỉ lộ ra khi cài trên máy sạch hoặc khi kiểm tra bằng trình duyệt thật. Ba lỗi đáng chú ý nhất, vì chúng sẽ làm hỏng buổi demo:

1. **Sáu tài khoản demo không có hồ sơ quyền, đăng nhập là chết.** Script gán hồ sơ theo tên tiếng Việt, nhưng trên máy sạch GLPI tạo hồ sơ bằng tên tiếng Anh, còn script Việt hóa lại không nằm trong luồng cài. Kết quả là đăng nhập trả về lỗi 400. Kịch bản demo đăng nhập tài khoản sinh viên sẽ chết ngay trên bục. Nay câu lệnh khớp cả hai tên và chạy đúng thứ tự.
2. **Bảng điều khiển hiện chế độ minh họa của GLPI.** GLPI 11 bật sẵn chế độ dùng bảng điều khiển mẫu. Script Việt hóa đã tắt nó nhưng script đó không được gọi trong luồng cài. Nay bước Việt hóa dữ liệu chạy ngay sau khi nạp danh mục.
3. **Dữ liệu mẫu âm thầm thiếu thiết bị khi nạp lệch tên.** Script dữ liệu mẫu tham chiếu tên vị trí không khớp với script danh mục. Vì câu lệnh dùng phép nối theo tên, những dòng không khớp bị bỏ qua trong im lặng. Nay tên đã khớp hoàn toàn, đồng thời chuyển đổi từ dữ liệu mẫu giả lập sang đúng 10 phòng máy thực tế của Trung tâm CNTT (482 máy tính, 487 màn hình LCD và Smart Tivi, 17 thiết bị mạng & tủ rack).

Ba lỗi trên đều thuộc loại "im lặng": hệ thống không báo lỗi, chỉ thiếu dữ liệu hoặc chặn đăng nhập. Đó là lý do em đưa chúng vào pipeline CI để mỗi lần đẩy mã đều được kiểm tra lại.

### 4.3.6. Rà soát chất lượng sau khi hoàn thiện

Sau khi hệ thống đã chạy được và báo cáo đã có bản nháp, em dành một đợt rà soát riêng để tìm những chỗ một người chấm kỹ sẽ bắt lỗi. Cách làm là đọc lại toàn bộ mã nguồn, tài liệu và cấu hình dưới con mắt phản biện, phân loại vấn đề theo ba mức (P0 — phải sửa ngay, P1 — nên sửa, P2 — cân nhắc), rồi **kiểm chứng từng thay đổi bằng lệnh chạy thật** chứ không chỉ sửa cho đẹp trên giấy. Kết quả gồm mười ba vấn đề, tóm tắt trong bảng dưới.

| # | Vấn đề phát hiện | Mức | Cách xử lý |
|---|---|---|---|
| 1 | README ghi giấy phép GPL v3 nhưng kho mã nguồn không có tệp giấy phép | P0 | Thêm `LICENSE` (GNU GPL-3.0) |
| 2 | Còn nhánh `bao-cao-thuc-tap-dlu` lỗi thời trên kho từ xa | P0 | Xoá sau khi kiểm chứng nội dung đã nằm trong `master` |
| 3 | Hướng dẫn phục hồi dữ liệu dạy `source .env` và truyền mật khẩu qua dòng lệnh — trái với chuẩn bảo mật của chính đồ án | P0 | Đổi sang cách an toàn, rồi chạy thử phục hồi thật |
| 4 | Nghi ngờ con số "điểm kiểm" trong tài liệu là sai | P0 | Kiểm chứng: con số **đúng**; ghi rõ cách đếm và chốt lại bằng một cửa CI (tăng dần 37 → 42 → 46 → 56) |
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

Hai vấn đề đáng kể nhất đều nằm ở mức P0. Thứ nhất là **hướng dẫn phục hồi dữ liệu tự mâu thuẫn**: đồ án đã có quy ước rõ là không truyền mật khẩu qua tham số dòng lệnh (vì tiến trình khác đọc được qua `ps`), vậy mà chính tài liệu lại dạy điều ngược lại. Đây là loại lỗi nguy hiểm vì nó không làm hệ thống hỏng, chỉ âm thầm làm yếu bảo mật. Em sửa cả tài liệu lẫn script, rồi **chạy thử phục hồi thật** để chắc chắn cách mới hoạt động và dữ liệu vẫn nguyên vẹn (482 máy tính, 14 phiếu).

Thứ hai là **bài học về số liệu**. Tài liệu ghi nhận số điểm kiểm tăng dần theo các đợt hoàn thiện: từ 37 điểm ban đầu, lên 42 điểm khi vá chống trùng theo tên (mục 4e), lên 46 điểm khi tự động hoá kiểm duyệt T5 (mục 4f), và đạt **56 điểm kiểm** khi bổ sung Tier 2 xác thực miền email chính thức `@dlu.edu.vn` theo gợi ý của giảng viên hướng dẫn. Lời gọi `check()` nằm trong vòng lặp và các khối kiểm tra điều kiện, nên tổng số lần chạy lớn hơn số dòng grep thô. Từ đó em thêm một cửa CI tự chốt con số này, để nếu ai thêm hoặc bớt phép kiểm mà quên cập nhật tài liệu thì pipeline báo đỏ ngay.

Sau khi hoàn tất, em chạy lại toàn bộ các cửa kiểm tra để xác nhận không có hồi quy:

| Hạng mục | Kết quả |
|---|---|
| Cú pháp shell / JavaScript / Python | Đạt (16 + 12 tệp) |
| Lint shell (ShellCheck), cú pháp PHP | Đạt (4 tệp PHP) |
| Cấu hình Docker Compose và Nginx | Hợp lệ |
| Quét bí mật trong mã nguồn | Sạch |
| Chống lạm dụng và xác thực email (harness plugin) | **56/56 đạt** |
| Chống đua GET_LOCK (2 request song song) | **Đạt** (chỉ 1/2 thành công) |
| Chặn hạn mức qua HTTP thật (Service Catalog) | **Đạt** |
| Chức năng và phân quyền theo vai trò | **25/25 đạt** (KTV) và **15/15 đạt** (Sinh viên) |
| Ba use case end-to-end (Playwright, Chrome thật) | **3/3 đạt** |
| Đo tải hệ thống (wrk trong Docker) | **Đạt** (Nginx ~54.000 req/s, GLPI ~100 req/s, tạo phiếu ~50/s) |
| Phục hồi dữ liệu | **Đạt** (dữ liệu nguyên vẹn 482 máy tính / 14 phiếu) |

*Bảng 4.10. Kết quả kiểm chứng sau đợt rà soát chất lượng*

Một quyết định em giữ nguyên có chủ ý: **không ghim cứng mã băm của các ảnh Docker**. Ghim cứng giúp tái lập tuyệt đối nhưng khiến hệ thống không nhận được bản vá bảo mật tự động; với đồ án chạy trong mạng nội bộ, đánh đổi đó không đáng. Thay vào đó mã băm hiện tại được ghi trong phần chú thích của tệp cấu hình, kèm hướng dẫn ghim nếu cần.

Chi tiết đầy đủ của đợt rà soát (từng vấn đề, cách sửa, bằng chứng) nằm ở tài liệu `tai-lieu/CAI-TIEN-CHAT-LUONG.md`.

### 4.3.7. Đo tải định lượng hệ thống bằng wrk

Để trả lời câu hỏi phản biện *"Hệ thống chịu tải được bao nhiêu người dùng đồng thời?"*, em thực hiện đo tải định lượng thực tế bằng công cụ chuẩn ngành `wrk` chạy trong container Docker (chi tiết tại `tai-lieu/DO-TAI.md`). Môi trường đo là máy cục bộ phát triển (4 container chạy chung một máy, chia sẻ CPU/RAM nên kết quả là cận dưới bảo thủ của năng lực thực tế).

| Tầng kiểm thử | Kịch bản đo | Throughput (Req/giây) | Độ trễ p50 | Độ trễ p99 | Đánh giá kỹ thuật |
|---|---|:---:|:---:|:---:|---|
| **Cổng vào Gateway (Nginx)** | Endpoint `/healthz` (20 connections) | **~54.000 req/s** | 238 µs | 3,65 ms | Nginx cực kỳ tối ưu, không bao giờ là điểm nghẽn hệ thống. |
| **Ứng dụng Web (GLPI)** | Trang đăng nhập qua PHP + Session (10 conn) | **68 req/s** | 108 ms | 216 ms | Hoạt động mượt mà, 0 timeout. |
| **Ứng dụng Web (GLPI)** | Trang đăng nhập (50 connections) | **106 req/s** | 387 ms | 783 ms | Bắt đầu chạm ngưỡng bão hòa xử lý PHP. |
| **Ứng dụng Web (GLPI)** | Trang đăng nhập (100 connections) | **98 req/s** | 765 ms | 1,45 s | Bão hòa tại ~100 req/s; độ trễ tăng do hàng đợi xử lý. |
| **Đường GHI (Tạo phiếu)** | Tạo phiếu mới + khóa `GET_LOCK` + ghi log (30 phiếu) | **~47–60 phiếu/s** | 17 ms | 21 ms | Tốc độ ghi đạt ~50 phiếu/giây, đáp ứng thoải mái nhu cầu sự cố phòng máy. |

*Bảng 4.11. Kết quả đo tải định lượng hệ thống bằng công cụ wrk*

**Ý nghĩa đối với quy mô Trường Đại học Đà Lạt:**
- Ở điều kiện bình thường (khoảng 10% trong 14.500 người học truy cập phân tán trong 10 phút), tải yêu cầu đạt khoảng **~24 req/s** → 1 máy chủ PineDesk vận hành dư sức (ngưỡng bão hòa ~100 req/s).
- Ở giờ cao điểm (khoảng 30% truy cập cùng lúc trong 10 phút), tải cần **~72 req/s** → hệ thống vẫn đáp ứng tốt, độ trễ tăng nhẹ.
- Ở kịch bản xấu nhất (toàn trường cùng truy cập dồn dập trong 5 phút), tải cần **~480 req/s** → 1 máy chủ đơn lẻ sẽ quá tải. Tuy nhiên, helpdesk là hệ thống hỗ trợ kỹ thuật theo sự cố phát sinh, người dùng chỉ vào khi cần báo hỏng máy, không có hành vi dồn tải đồng loạt như cổng đăng ký tín chỉ môn học. Do đó năng lực 1 máy đơn hiện tại hoàn toàn phù hợp và khả thi cho Trung tâm CNTT vận hành.

---

# CHƯƠNG 5. ĐÁNH GIÁ, HẠN CHẾ VÀ HƯỚNG PHÁT TRIỂN

## 5.1. Kết quả đạt được

Đề tài đã dựng được một hệ thống hỗ trợ kỹ thuật chạy thật trên nền GLPI 11, với những kết quả cụ thể sau:

- Cài đặt toàn bộ bằng một lệnh, tái lập được trên máy khác.
- Dữ liệu nghiệp vụ dựng sẵn theo cơ cấu của Trường: 12 tòa nhà, 54 phòng máy, 16 khoa, 79 loại sự cố.
- Dữ liệu mẫu đầy đủ: 482 máy tính, 487 màn hình LCD & Smart Tivi, 3 máy in, 17 thiết bị mạng & tủ rack, 14 phiếu sự cố, 10 bản ghi SLA, 6 tài khoản ba vai trò.
- Giao diện Đà Lạt lấy màu từ logo Trường, áp trên toàn hệ thống kể cả trang đăng nhập.
- Mã QR cho thiết bị, đã giải mã kiểm chứng.
- Lớp chống lạm dụng sáu tầng với bằng chứng chạy thật (HTTP 429 sau 11 yêu cầu).
- Kiểm thử: 25/25 mục đạt với vai trò kỹ thuật viên, 15/15 với vai trò sinh viên.
- Pipeline CI sáu nhóm gồm 56 bước kiểm tra tự động nghiêm ngặt (có cả E2E Playwright).
- Đặc tả hệ thống thiết kế `DESIGN.md` chuẩn Impeccable (dung hợp Apple Precision + Claude Warmth + Bản sắc Đà Lạt).
- Khảo sát số liệu thực tế có nguồn chính thức (`SO-LIEU-THUC-TE-DLU.md`) và báo cáo đo tải định lượng (`DO-TAI.md`).

## 5.2. Hạn chế của đề tài

Em ghi thẳng những gì chưa làm được, vì đây là phần quan trọng nhất để đánh giá đúng mức độ hoàn thành của đề tài.

| # | Hạn chế | Mức độ |
|---|---|---|
| 1 | Đề tài chưa được ITC phê duyệt và chưa triển khai trên hạ tầng thật của Trường | Nghiêm trọng |
| 2 | Số sự cố ITC thực tế tiếp nhận mỗi tuần, thời gian phản hồi trung bình hiện tại: chưa có dữ liệu | Nghiêm trọng |
| 3 | 5 mức SLA và hạn mức 5 phiếu / 10 phiếu mỗi ngày là đề xuất kỹ thuật, chưa được Trường xác nhận | Nghiêm trọng |
| 4 | Đã đo tải cục bộ trên máy phát triển (`DO-TAI.md`); chưa đo trên hạ tầng thật với người dùng thật | Trung bình |
| 5 | Tầng T5 (kiểm duyệt trước khi giao việc) đã tự động **nhắc** soát xét cho phiếu ưu tiên cao, nhưng phần **quyết định** mức ưu tiên vẫn cần kỹ thuật viên | Thấp |
| 6 | Nhật ký chống lạm dụng chưa có giao diện xem cho kỹ thuật viên, hiện xem bằng SQL | Trung bình |
| 7 | Chưa có CAPTCHA cho trường hợp mở nộp phiếu ẩn danh qua QR | Thấp, do phạm vi |
| 8 | Chưa có tài khoản tự đăng ký, nên chưa phải lo chống tạo tài khoản ảo | Thấp, do phạm vi |
| 9 | Redis cấu hình `maxmemory 256MB` + `allkeys-lru`: khi đầy, phiên đăng nhập có thể bị đẩy ra sớm, người dùng phải đăng nhập lại | Thấp, do quy mô nội bộ |
| 10 | Khi cơ chế chống lạm dụng tự tắt do lỗi CSDL (fail-open), hệ thống có ghi nhật ký nhưng chưa có cảnh báo tự động cho kỹ thuật viên | Trung bình |
| 11 | Trên đường tạo phiếu mới của GLPI 11 (`/Form/SubmitAnswers`), khi bị chặn hạn mức, lõi GLPI hiển thị lỗi hệ thống chung ("Failed to submit form") thay vì thông báo tiếng Việt thân thiện (chỉ đường `/front/ticket.form.php` cũ mới hiện đúng thông báo) | Trung bình |

*Bảng 5.1. Hạn chế của đề tài*

Về hai mục cuối, đây là giảm thiểu rủi ro bằng thiết kế: đề tài không cho tự đăng ký và không cho nộp ẩn danh, nên hai rủi ro đó bị loại bỏ ở gốc thay vì phải chống đỡ sau khi đã cho phép.

Về tầng T5, phần nhắc soát xét đã được tự động hoá ở mức tối thiểu như mô tả ở mục 4.2.5. Phần quyết định mức ưu tiên vẫn để cho kỹ thuật viên vì hệ thống không đủ ngữ cảnh để quyết thay con người. Bước tiếp theo là dùng Rule engine của GLPI để tự phân loại và định tuyến theo quy tắc nghiệp vụ, cấu hình qua giao diện và vẫn giữ kiến trúc tùy biến ngoài lõi.

## 5.3. Hướng phát triển

Từ những hạn chế ở mục 5.2, hướng phát triển tiếp theo được sắp theo thứ tự ưu tiên:

1. **Phỏng vấn 5 nhân sự ITC** để kiểm chứng bài toán và xin số liệu tiếp nhận thực tế. Đây là việc cần làm đầu tiên nếu muốn biến đề tài từ "đề xuất" thành "đã triển khai".
2. **Đề nghị ITC ban hành mức thời gian xử lý chính thức**, thay cho các con số đề xuất hiện tại.
3. **Đo hiệu năng trên hạ tầng thật**: phép đo cục bộ đã có (`DO-TAI.md`); bước tiếp là đo khi nhiều người dùng đồng thời trên máy chủ tách biệt và cắm thử hệ thống ở một phòng máy.
4. **Hoàn thiện tầng T5**: nay đã tự động *nhắc* soát xét cho phiếu ưu tiên cao; bước tiếp là dùng Rule engine của GLPI để tự phân loại/định tuyến theo quy tắc nghiệp vụ cấu hình qua giao diện, giữ kiến trúc ngoài lõi.
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

**Đối với Trung tâm Công nghệ thông tin:** nên xem xét phê duyệt và ban hành mức thời gian xử lý chính thức, đồng thời cho phép thử nghiệm hệ thống PineDesk ở quy mô một phòng máy (ví dụ Phòng máy A24.1) để đo lường thực tế trước khi xem xét tích hợp vào hạ tầng chung của Nhà trường.

**Đối với Khoa Công nghệ Thông tin:** nên tiếp tục duy trì và nhân rộng các đề tài thực tập tốt nghiệp gắn liền trực tiếp với bài toán vận hành thực tế của Nhà trường; khuyến khích sinh viên áp dụng các chuẩn mực kỹ thuật công nghiệp (Container hóa, Zero-Core-Modification, CI tự động và kiểm thử đối kháng).

**Đối với sinh viên khóa sau:** nếu chọn đề tài tương tự, em khuyên nên dành thời gian kiểm thử trên môi trường máy sạch ngay từ giữa kỳ thay vì để sát ngày bảo vệ, và luôn đặt câu hỏi "dữ liệu này lấy từ đâu, có kiểm chứng được không" cho mọi phát biểu và số liệu kỹ thuật đưa vào báo cáo.

---

# TÀI LIỆU THAM KHẢO

## A. Văn bản pháp lý và số liệu khảo sát thực tế

[1] Trường Đại học Đà Lạt, "Báo cáo thường niên năm 2025 (Số liệu thống kê năm học 2024 - 2025)", Văn bản số 1134/BC-ĐHĐL, Tháng 10/2025.  
[2] Hiệu trưởng Trường Đại học Đà Lạt, "Quy định chức năng, nhiệm vụ và quyền hạn của Trung tâm Công nghệ thông tin", Quyết định số 03/09/QĐ-ĐHDL, ngày 07/01/2021.  
[3] Hiệu trưởng Trường Đại học Đà Lạt, "Về việc hợp nhất Trung tâm Công nghệ thông tin và Trung tâm Giáo dục đào tạo Trí tuệ nhân tạo", Quyết định số 395/QĐ-ĐHĐL, ngày 10/04/2025.  
[4] Trung tâm Công nghệ thông tin – Trường Đại học Đà Lạt, "Thông số kỹ thuật trang thiết bị 10 phòng máy tính thực hành", Tài liệu khảo sát nội bộ phục vụ bảo trì, Tháng 09/2026.  
[5] Trung tâm Công nghệ thông tin – Trường Đại học Đà Lạt, "Thông tin giới thiệu, cơ cấu tổ chức và liên hệ", Website chính thức: `https://itc.dlu.edu.vn/gioi-thieu/` và `https://itc.dlu.edu.vn/lien-he/`, truy cập ngày 02/10/2026.  
[6] Trường Đại học Đà Lạt, "Danh mục các đơn vị đào tạo, phòng ban và trung tâm", Website chính thức: `https://dlu.edu.vn/`, truy cập ngày 02/10/2026.

## B. Tiêu chuẩn ngành và tài liệu kỹ thuật quốc tế

[7] AXELOS, *ITIL Foundation: ITIL 4 Edition*, TSO (The Stationery Office), London, UK, 2019.  
[8] M. Sheehan, "Service on the Front Line: The IT Help Desk in Higher Education", *EDUCAUSE Center for Applied Research (ECAR)*, Research Study, Vol. 2007, Issue 4, 2007.  
[9] MetricNet, "Higher Education IT Service and Support Benchmarks", MetricNet Benchmarking Database, 2016.  
[10] GLPI Project / Teclib', *GLPI 11.0.0 Architecture, Schema and Plugin Developer Guide*, 2026. [Online]. Available: `https://github.com/glpi-project/glpi`  
[11] Docker Inc., *Docker Compose Version 2 Specification and Best Practices*, 2026. [Online]. Available: `https://docs.docker.com/compose/`  
[12] Igor Sysoev et al., *Nginx HTTP Core and Rate Limiting Architecture (ngx_http_limit_req_module)*, Nginx Documentation, 2026. [Online]. Available: `https://nginx.org/en/docs/`  
[13] Microsoft Corporation, *Playwright: Fast and reliable end-to-end testing for modern web apps*, 2026. [Online]. Available: `https://playwright.dev/`  
[14] Free Software Foundation, *GNU General Public License, Version 3 (GPL v3)*, 2007.

## C. Hồ sơ kỹ thuật của đề tài PineDesk

[15] Phùng Võ Quốc Hiển, "Đặc tả hệ thống thiết kế giao diện PineDesk (DESIGN.md)", Dự án PineDesk, Trường ĐH Đà Lạt, 2026.  
[16] Phùng Võ Quốc Hiển, "Tài liệu tổng hợp nghiệp vụ, kiến trúc và vận hành hệ thống (tai-lieu/README.md)", Dự án PineDesk, Trường ĐH Đà Lạt, 2026.  
[17] Phùng Võ Quốc Hiển, "Báo cáo số liệu thực tế về ITC và Trường Đại học Đà Lạt (SO-LIEU-THUC-TE-DLU.md)", Dự án PineDesk, Trường ĐH Đà Lạt, 2026.  
[18] Phùng Võ Quốc Hiển, "Kết quả đo tải định lượng hệ thống bằng công cụ wrk (DO-TAI.md)", Dự án PineDesk, Trường ĐH Đà Lạt, 2026.  
[19] Phùng Võ Quốc Hiển, "Nhật ký rà soát và cải tiến chất lượng phần mềm (CAI-TIEN-CHAT-LUONG.md)", Dự án PineDesk, Trường ĐH Đà Lạt, 2026.

---

# PHỤ LỤC

## Phụ lục A. Bảng thông số kỹ thuật 10 phòng máy thực tế Trung tâm CNTT

Dữ liệu phần cứng trích xuất trực tiếp từ văn bản khảo sát `THÔNG SỐ CÁC PHÒNG MÁY TT_CNTT.docx` của Trung tâm CNTT, được nạp vào CSDL PineDesk thông qua `scripts/seed-du-lieu-mau.sql`:

1. **Phòng máy A24.1 (Tòa nhà A):** 45 máy tính SV (Dell OptiPlex 3000 Small SFF) + 1 máy tính GV + 46 màn hình LCD Dell 22" E2222H + 1 Smart Tivi Sony 85" + 1 Switch Cisco 48-port + 1 Unifi AP + 1 Máy in Canon LBP2900 + 1 Hệ thống âm thanh Bosch.
2. **Phòng máy A24 lầu (Tòa nhà A):** 45 máy tính SV (Dell OptiPlex 3000 Small SFF) + 1 máy tính GV + 46 màn hình LCD Dell 22" E2222H + 1 Smart Tivi Sony 85" + 1 Switch Cisco 48-port + 1 Unifi AP + 1 Hệ thống âm thanh Bosch.
3. **Phòng máy A8.3 (Tòa nhà A):** 48 máy tính SV (PC Lắp ráp Intel Core i3) + 1 máy tính GV + 49 màn hình LCD LG 24" + 1 Smart Tivi Inno 85" + 1 Switch Cisco 48-port + 1 Unifi AP + 1 Máy in Canon LBP2900 + 1 Hệ thống âm thanh Bosch.
4. **Phòng máy A8.4 (Tòa nhà A):** 48 máy tính SV (PC Lắp ráp Intel Core i3) + 1 máy tính GV + 49 màn hình LCD LG 24" + 1 Smart Tivi Inno 85" + 1 Switch Cisco 48-port + 1 Unifi AP + 1 Máy in Canon LBP2900.
5. **Phòng máy A8.5 (Tòa nhà A):** 49 máy tính SV (PC Lắp ráp Intel Core i5) + 1 máy tính GV + 50 màn hình LCD LG 24" + 1 Smart Tivi Inno 85" + 1 Switch Cisco 48-port + 1 Unifi AP.
6. **Phòng máy A8.6 (Tòa nhà A):** 50 máy tính SV (PC Lắp ráp Intel Core i5) + 1 máy tính GV + 51 màn hình LCD LG 24" + 1 Smart Tivi Inno 85" + 1 Switch Cisco 48-port + 1 Unifi AP.
7. **Phòng máy TV1 (Tòa nhà F - Thư viện):** 46 máy tính SV (PC Lắp ráp Intel Pentium) + 46 màn hình LCD LG 24" + 1 Smart Tivi Inno 80" + 1 Switch Cisco 48-port.
8. **Phòng máy TV2 (Tòa nhà F - Thư viện):** 45 máy tính SV (PC Lắp ráp Intel Pentium) + 45 màn hình LCD LG 24" + 1 Smart Tivi Inno 80" + 1 Switch Cisco 48-port.
9. **Phòng máy TV3 (Tòa nhà F - Thư viện):** 45 máy tính SV (PC Lắp ráp Intel Pentium) + 45 màn hình LCD LG 24" + 1 Smart Tivi Inno 80" + 1 Switch Cisco 48-port.
10. **Phòng máy TV4 (Tòa nhà F - Thư viện):** 50 máy tính SV (PC Lắp ráp Intel Pentium) + 50 màn hình LCD LG 24" + 1 Smart Tivi Inno 80" + 1 Switch Cisco 48-port.

**Tổng cộng:** 471 máy SV + 6 máy GV = 477 máy phòng máy; 477 màn hình LCD; 10 Smart Tivi; 10 Switch Cisco; 6 Unifi AP; 3 máy in Canon LBP2900; 3 hệ thống âm thanh Bosch.

## Phụ lục B. Tài khoản thử nghiệm và phân quyền vai trò

| Tài khoản | Mật khẩu mẫu | Vai trò (Profile) | Giao diện đăng nhập | Quyền hạn trên hệ thống |
|---|---|---|---|---|
| `glpi` | *(Đặt khi cài)* | Super-Admin | Trung tâm (`/front/central.php`) | Toàn quyền quản trị hệ thống, cấu hình plugin, quản lý người dùng |
| `tech` | `tech` | Technician (GLPI gốc) | Trung tâm | Tài khoản kỹ thuật viên mặc định của GLPI |
| `ktv.an` | `Dlu@2026` | Kỹ thuật viên (Technician) | Trung tâm | Tiếp nhận, giao việc, cập nhật tiến độ, giải quyết phiếu sự cố |
| `ktv.binh` | `Dlu@2026` | Kỹ thuật viên (Technician) | Trung tâm | Xử lý sự cố phần cứng, mạng và bảo trì định kỳ |
| `gv.cuong` | `Dlu@2026` | Giảng viên (Self-Service) | Tự phục vụ (`/front/helpdesk.public.php`) | Tạo phiếu báo hỏng máy, mượn thiết bị lưu động, theo dõi tiến độ |
| `gv.dung` | `Dlu@2026` | Giảng viên (Self-Service) | Tự phục vụ | Tạo phiếu báo sự cố phòng máy, tra cứu hồ sơ thiết bị qua QR |
| `sv.hoa` | `Dlu@2026` | Sinh viên (Self-Service) | Tự phục vụ | Báo hỏng máy thực hành, theo dõi trạng thái phiếu của bản thân |
| `sv.khanh` | `Dlu@2026` | Sinh viên (Self-Service) | Tự phục vụ | Báo lỗi phần mềm, kiểm tra phản hồi từ kỹ thuật viên |

## Phụ lục C. Hướng dẫn cài đặt và vận hành hệ thống một lệnh

```bash
# 1. Cài đặt tự động toàn bộ hệ thống từ đầu (khoảng 3 - 5 phút)
cp .env.example .env
bash scripts/cai-dat-tat-ca.sh

# 2. Nạp dữ liệu 10 phòng máy thật và phiếu mẫu (idempotent)
bash scripts/nap-du-lieu-mau.sh

# 3. Nạp SLA kỹ thuật và kích hoạt 6 tầng chống lạm dụng
bash scripts/nap-sla-va-chong-lam-dung.sh

# 4. Chạy kiểm thử tự động toàn diện (CI gates tại chỗ)
make kiem-tra

# 5. Chạy harness chống lạm dụng trên CSDL thật (56 điểm kiểm)
docker exec -u www-data pinedesk-glpi \
  php /var/www/glpi/plugins/pinedesk/tests/kiem-thu-han-muc.php

# 6. Kiểm tra chức năng phân quyền theo vai trò (40 điểm kiểm HTTP)
GLPI_USER=ktv.an GLPI_PASS='<mat-khau>' bash scripts/kiem-tra-chuc-nang.sh
GLPI_USER=sv.hoa GLPI_PASS='<mat-khau>' bash scripts/kiem-tra-chuc-nang.sh

# 7. Kiểm thử 3 use case Playwright end-to-end trên Chrome thật
GLPI_PASS='<mat-khau>' node scripts/kiem-tra-usecase.js

# 8. Chạy đo tải hệ thống bằng wrk trong Docker
bash scripts/do-tai.sh

# 9. Sao lưu cơ sở dữ liệu an toàn (không lộ mật khẩu trong ps)
bash backup/backup.sh
```

## Phụ lục D. Danh mục 18 ảnh minh chứng giao diện

Toàn bộ ảnh chụp màn hình được lưu trữ tại thư mục `tai-lieu/anh-giao-dien/` với định dạng chuẩn PNG:

| STT | Tên tệp ảnh | Nội dung minh chứng |
|:---:|---|---|
| 1 | `01-trang-dang-nhap.png` | Giao diện đăng nhập với bản sắc Đà Lạt và phông chữ Literata |
| 2 | `02-bang-dieu-khien.png` | Bảng điều khiển trung tâm với các chỉ số thống kê và thẻ trạng thái viên thuốc |
| 3 | `03-danh-sach-may-tinh.png` | Danh mục 482 máy tính được nạp từ 10 phòng máy thực tế |
| 4 | `03b-danh-sach-man-hinh.png` | Danh mục 487 màn hình LCD và Smart Tivi hiển thị |
| 5 | `03c-thiet-bi-mang.png` | Danh mục 17 Switch Cisco, Unifi AP và Tủ Rack Core |
| 6 | `03d-danh-sach-may-in.png` | Danh mục 3 máy in laser Canon LBP2900 |
| 7 | `03e-danh-sach-phan-mem.png` | Danh mục 10 phần mềm bản quyền phòng thực hành |
| 8 | `04-danh-sach-phieu-yeu-cau.png` | Danh sách 14 phiếu sự cố phân bổ theo các trạng thái ITIL |
| 9 | `05-tao-phieu-moi.png` | Biểu mẫu tiếp nhận sự cố với lựa chọn danh mục phân cấp |
| 10 | `06-tao-thiet-bi.png` | Giao diện thêm mới thiết bị vào cơ sở dữ liệu tài sản |
| 11 | `06-nhom-co-cau-to-chuc.png` | Danh mục 16 khoa đào tạo và các phòng ban Đại học Đà Lạt |
| 12 | `07-chi-tiet-thiet-bi.png` | Hồ sơ chi tiết một thiết bị kèm lịch sử sự cố và bảo trì |
| 13 | `08-danh-sach-nguoi-dung.png` | Danh sách tài khoản người dùng được gán hồ sơ quyền chính xác |
| 14 | `10-menu-cac-hanh-dong.png` | Menu hành động hàng loạt trên danh sách thiết bị |
| 15 | `11-cau-hinh-nhan-qr.png` | Giao diện cấu hình mẫu nhãn in mã QR cho thiết bị |
| 16 | `11-ma-qr-thiet-bi.png` | Thẻ mã QR định danh hiển thị trên trang chi tiết máy tính |
| 17 | `12-ket-qua-sinh-qr.png` | Tệp nhãn in mã QR sinh ra từ plugin Barcode 2.7.1 |
| 18 | `13-thong-ke-toan-cau.png` | Báo cáo thống kê toàn diện về tài sản và tình hình sự cố |

## Phụ lục E. Kế hoạch chi tiết 10 tuần thực tập tốt nghiệp

Chi tiết lộ trình thực tập 10 tuần được xây dựng theo chuẩn Đề cương thực tập tốt nghiệp ngành Kỹ thuật Phần mềm, Khoa Công nghệ Thông tin:

- **Tuần 1 (10/08 – 15/08/2026):** Nhận bàn giao tại Trung tâm CNTT. Học tập nội quy làm việc, tìm hiểu chức năng và cơ cấu phòng ban ITC. Khảo sát thực địa hệ thống 10 phòng thực hành máy tính tại Tòa A và Tòa F.
- **Tuần 2 (17/08 – 22/08/2026):** Khảo sát quy trình tiếp nhận sự cố hiện hành qua hotline, email và trực tiếp. Phỏng vấn nhân sự ITC và sinh viên thực hành. Đúc kết 3 mâu thuẫn nghiệp vụ (M1, M2, M3) và lập đặc tả yêu cầu hệ thống.
- **Tuần 3 (24/08 – 29/08/2026):** Nghiên cứu kiến trúc nền tảng ITSM mã nguồn mở GLPI 11. Phân tích nguyên tắc Zero-Core-Modification. Thiết lập môi trường Docker Compose gồm 4 container cô lập: Nginx, GLPI, MariaDB, Redis. Cấu hình mạng nội bộ bảo mật.
- **Tuần 4 (31/08 – 05/09/2026):** Khảo sát và xây dựng bộ danh mục nghiệp vụ trường học: 12 tòa nhà, 54 phòng máy, 16 khoa, 10 phòng ban, 79 danh mục sự cố 2 cấp chuẩn ITIL. Tự động hóa quá trình nạp dữ liệu nền bằng script SQL.
- **Tuần 5 (07/09 – 12/09/2026):** Phát triển kiến trúc phòng thủ 6 tầng chống lạm dụng. Cấu hình Nginx rate-limiting (T1), bắt buộc xác thực (T2), viết plugin `pinedesk` kiểm soát hạn mức phiếu T3 và chống nộp trùng T4, cơ chế khóa MariaDB mutex `GET_LOCK` chống race condition, xây dựng bảng nhật ký tạo phiếu T6.
- **Tuần 6 (14/09 – 19/09/2026):** Phát triển hệ thống nhận diện thương hiệu `dlubrand`. Trích xuất bảng màu logo DLU, tích hợp ngôn ngữ thiết kế Apple Precision và Claude Warmth. Nghiên cứu cơ chế nạp catalog của thư viện `laminas-i18n`, xây dựng công cụ gộp và mở rộng từ điển tiếng Việt (667 thuật ngữ, 212 mục số nhiều).
- **Tuần 7 (21/09 – 26/09/2026):** Nghiên cứu giải pháp quản lý tài sản bằng mã QR. Khắc phục 3 lỗi tương thích phiên bản của plugin Barcode 2.7.1 trên GLPI 11 (`setup.php`, `vendor/`, `$DB->doQuery()`). Phát triển script Python độc lập `sinh-ma-qr.py` làm giải pháp dự phòng sinh nhãn in hàng loạt.
- **Tuần 8 (28/09 – 03/10/2026):** Tiếp nhận văn bản khảo sát trang thiết bị phòng máy của ITC. Xây dựng script nạp dữ liệu mẫu ánh xạ chính xác 10 phòng máy thật (482 máy tính, 487 màn hình & Tivi, 3 máy in, 17 thiết bị mạng). Thiết lập 10 bản ghi SLA kỹ thuật và quy trình bảo trì định kỳ, mượn trả thiết bị.
- **Tuần 9 (05/10 – 10/10/2026):** Xây dựng bộ công cụ kiểm thử đa tầng: harness kiểm thử CSDL 56 điểm kiểm, script kiểm tra phân quyền HTTP 40 mục, kiểm thử 3 use case Playwright end-to-end trên Chrome thật, đo tải định lượng hệ thống bằng wrk. Tích hợp pipeline CI 6 nhóm kiểm tra tự động trên GitHub Actions.
- **Tuần 10 (12/10 – 17/10/2026):** Thực hiện đợt rà soát chất lượng đối kháng, giải quyết 13 vấn đề P0/P1/P2. Hoàn thiện script đóng gói cài đặt tự động một lệnh `cai-dat-tat-ca.sh`. Biên soạn báo cáo thực tập tốt nghiệp hoàn chỉnh và chuẩn bị tài liệu slide bảo vệ trước Hội đồng.

## Phụ lục F. Bộ câu hỏi và trả lời phản biện chuyên sâu trước Hội đồng

1. **Câu hỏi:** *Hệ thống PineDesk có can thiệp trực tiếp vào mã nguồn của GLPI 11 không? Nếu GLPI cập nhật phiên bản mới thì có bị mất cấu hình không?*  
   **Trả lời:** PineDesk tuân thủ tuyệt đối nguyên tắc kiến trúc "Zero-Core-Modification" (không can thiệp vào lõi). 100% logic nghiệp vụ bổ sung (chống lạm dụng, khóa mutex, nhật ký) được đóng gói trong `plugins/pinedesk/` qua hook chuẩn `PRE_ITEM_ADD` và `ITEM_ADD`. Giao diện và bảng màu được nạp qua `plugins/dlubrand/` và Nginx proxy. Toàn bộ thư mục lõi `/var/www/glpi/src/` giữ nguyên vẹn 100%, do đó việc nâng cấp các bản vá upstream của GLPI hoàn toàn không gây xung đột hay mất mát tính năng.

2. **Câu hỏi:** *Tại sao không sử dụng Google Forms kết hợp Google Sheets cho đơn giản mà phải dựng hệ thống ITSM phức tạp như GLPI?*  
   **Trả lời:** Google Forms chỉ là công cụ thu thập dữ liệu một chiều tĩnh, không phải là hệ thống quản lý dịch vụ (ITSM). Nó hoàn toàn thiếu các nghiệp vụ cốt lõi: vòng đời phiếu ITIL (Mới → Đang xử lý → Đã giải quyết → Đã đóng), phân công kỹ thuật viên theo nhóm, cam kết thời gian SLA, quản lý vòng đời tài sản (gắn phiếu với máy tính cụ thể theo khóa ngoại), chống nộp trùng phiếu, và phân quyền dữ liệu bảo mật (sinh viên chỉ thấy phiếu của mình, kỹ thuật viên thấy việc của mình). Với quy mô 14.500 người học và 5 nhân sự ITC, đọc Sheets thủ công sẽ gây quá tải và thất lạc sự cố.

3. **Câu hỏi:** *Cơ chế chống lạm dụng giải quyết bài toán môi trường mạng NAT trong trường đại học như thế nào?*  
   **Trả lời:** Trong khuôn viên trường, hàng chục phòng máy cùng đi ra Internet qua một vài địa chỉ IP Public (mạng NAT). Nếu chỉ giới hạn tần suất theo IP tại tầng mạng quá chặt, một lớp học 40 sinh viên đồng loạt nộp bài hoặc báo hỏng máy sẽ bị chặn oan. Do đó, PineDesk thiết kế phòng thủ phân tầng: Tầng Nginx Gateway (T1) chỉ đặt ngưỡng rộng (30 req/phút có burst) để chống bot quét dồn dập; còn việc kiểm soát hạn mức (tối đa 5 phiếu mở, 10 phiếu/ngày) được siết chặt tại Tầng T3 theo định danh tài khoản người dùng đã đăng nhập (`user_id`). Tài khoản không bị ảnh hưởng bởi NAT, đảm bảo chặn chính xác kẻ lạm dụng mà không ảnh hưởng người dùng hợp lệ.

4. **Câu hỏi:** *Khi nhiều người dùng cùng bấm gửi phiếu đồng thời thì hệ thống có bị lỗi tranh chấp (Race Condition / TOCTOU) không?*  
   **Trả lời:** Hoàn toàn không. PineDesk giải quyết triệt để vấn đề này bằng cơ chế khóa phân tán MariaDB mutex `GET_LOCK('pinedesk_hm_<uid>', 3)` có phạm vi theo từng người dùng. Khi kiểm tra hạn mức và ghi phiếu, tiến trình chiếm khóa độc quyền trong tối đa 3 giây; các yêu cầu đồng thời cùng một tài khoản sẽ phải xếp hàng tuần tự. Kiểm chứng thực tế qua kịch bản 2 request gửi song song sát trần hạn mức cho thấy đúng 1 request được ghi nhận và 1 request bị từ chối hợp lệ.

5. **Câu hỏi:** *Tại sao trong báo cáo ghi nhận các con số SLA (8h/4h/2h/1h/30p) là đề xuất kỹ thuật mà không khẳng định là cam kết chính thức của Trường?*  
   **Trả lời:** Đây là thể hiện tính trung thực và chuẩn mực khoa học của đồ án. Về mặt kỹ thuật, hệ thống đã cài đặt hoàn chỉnh 10 bản ghi SLA thật trong CSDL (`glpi_slas` và `glpi_slalevels`) và quy trình tự động tính toán vi phạm thời hạn hoạt động chính xác. Tuy nhiên, một cam kết SLA chính thức đòi hỏi phải có văn bản phê duyệt pháp lý từ Ban Giám hiệu và Ban Giám đốc Trung tâm CNTT dựa trên năng lực nhân sự thực tế. Em ghi rõ đây là đề xuất kỹ thuật để Hội đồng đánh giá đúng hiện trạng đề tài, tránh ngộ nhận giữa khả năng kỹ thuật của phần mềm và quy định hành chính thực tế.
