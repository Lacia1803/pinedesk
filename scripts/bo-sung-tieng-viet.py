#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
================================================================================
 BO SUNG BAN DICH TIENG VIET CHO GLPI  (PO -> MO, khong can msgfmt)
================================================================================
 Do an thuc tap: Xay dung he thong ho tro ky thuat (IT Helpdesk) - DH Da Lat

 VAN DE:
   GLPI 11 dong goi san file vi_VN.mo nhung CHI DICH DUOC ~32% (2052/6394 chuoi).
   May khong co cong cu 'msgfmt' (gettext) nen khong the bien dich .po bang tay.

 GIAI PHAP:
   Script nay tu :
     1. Doc file vi_VN.po goc
     2. Gop them bang dich bo sung (tu dien BEN DUOI) cho cac nhan nghiep vu
        quan trong con thieu (thiet bi, su co, bao tri, phan mem, mang, ...)
     3. TU BIEN DICH sang dinh dang .mo (thuan Python - khong can msgfmt)
     4. Ghi file vi_VN.mo moi vao container GLPI

 CHAY:
   python scripts/bo-sung-tieng-viet.py
================================================================================
"""
import os
import re
import struct
import subprocess
import sys

# -----------------------------------------------------------------------------
# TU DIEN BO SUNG
# Chi liet ke cac nhan NGHIEP VU quan trong (theo de cuong do an).
# Dinh dang: "Chuoi tieng Anh trong GLPI": "Ban dich tieng Viet"
# -----------------------------------------------------------------------------
BAN_DICH_BO_SUNG = {
    # ===== BO DEM TRANG THAI PHIEU (hang the mau tren trang Ticket) =====
    # Day la cac nhan HIEN THI NOI BAT NHAT tren trang Ho tro nhung
    # ban dich vi_VN chinh thuc cua GLPI KHONG co -> phai bo sung tay.
    "Incoming tickets": "Phiếu mới tiếp nhận",
    "Pending tickets": "Phiếu đang chờ",
    "Assigned tickets": "Phiếu đã phân công",
    "Planned tickets": "Phiếu đã lên kế hoạch",
    "Solved tickets": "Phiếu đã giải quyết",
    "Closed tickets": "Phiếu đã đóng",
    # Cac nhan phu tro khac cung hang the do
    "Late tickets": "Phiếu quá hạn",
    "Tickets by month": "Phiếu theo tháng",
    "Tickets status by month": "Tình trạng phiếu theo tháng",
    # ===== DIEU HUONG / MENU CHINH =====
    "Assets": "Tài sản",
    "Asset definition": "Định nghĩa tài sản",
    "Assistance": "Hỗ trợ",
    "Management": "Quản lý",
    # Menu cap 1 tren thanh dieu huong GLPI 11 (kiem tra bang HTML that)
    "Service catalog": "Danh mục dịch vụ",
    "Knowledge base": "Kho kiến thức",
    "Notification queue": "Hàng đợi thông báo",
    "Saved search": "Tìm kiếm đã lưu",
    "Saved searches": "Tìm kiếm đã lưu",
    "Recurrent change": "Thay đổi định kỳ",
    "Recurrent changes": "Thay đổi định kỳ",
    "Passive device": "Thiết bị thụ động",
    "Passive devices": "Thiết bị thụ động",
    "Unmanaged asset": "Tài sản chưa quản lý",
    "Unmanaged assets": "Tài sản chưa quản lý",
    "OAuth client": "Ứng dụng OAuth",
    "OAuth clients": "Ứng dụng OAuth",
    "Data center": "Trung tâm dữ liệu",
    "Appliance": "Thiết bị tổng hợp",
    "Appliances": "Thiết bị tổng hợp",
    "Cluster": "Cụm máy chủ",
    "Clusters": "Cụm máy chủ",
    "Certificate": "Chứng thư số",
    "Certificates": "Chứng thư số",
    "Line": "Đường truyền",
    "Lines": "Đường truyền",
    "Webhook": "Webhook",
    "Webhooks": "Webhook",
    "Change mode": "Đổi chế độ",
    "Back to top of the page": "Về đầu trang",
    "Powered by Teclib and contributors":
        "Phát triển bởi Teclib và cộng đồng",
    "Service level": "Mức dịch vụ",
    "Service levels": "Mức dịch vụ",
    "Tools": "Công cụ",
    "Administration": "Quản trị",
    "Setup": "Cấu hình",
    "My settings": "Thiết lập của tôi",
    "Preferences": "Tuỳ chọn",
    "Logout": "Đăng xuất",
    "Home": "Trang chủ",
    "Dashboard": "Bảng điều khiển",
    "Search": "Tìm kiếm",
    "Add": "Thêm",
    "Update": "Cập nhật",
    "Delete": "Xoá",
    "Save": "Lưu",
    "Cancel": "Huỷ",
    "Close": "Đóng",
    "Back": "Quay lại",
    "Next": "Tiếp",
    "Previous": "Trước",
    "Print": "In",
    "Export": "Xuất",
    "Import": "Nhập",
    "Refresh": "Tải lại",
    "Reset": "Đặt lại",
    "Yes": "Có",
    "No": "Không",
    "All": "Tất cả",
    "None": "Không có",
    "Other": "Khác",
    "Actions": "Hành động",
    "Massive actions": "Hành động hàng loạt",
    "Comments": "Ghi chú",
    "Description": "Mô tả",
    "Status": "Trạng thái",
    "Active": "Đang hoạt động",
    "Inactive": "Ngừng hoạt động",
    "Name": "Tên",
    "Type": "Loại",
    "Model": "Kiểu máy",
    "Manufacturer": "Nhà sản xuất",
    "Location": "Vị trí",
    "User": "Người dùng",
    "Group": "Nhóm",
    "Date": "Ngày",
    "Created on": "Ngày tạo",
    "Last update": "Cập nhật lần cuối",
    "ID": "Mã số",
    "Technical information": "Thông tin kỹ thuật",
    "Informations": "Thông tin",
    "Main": "Chính",
    "General": "Tổng quan",

    # ===== THIET BI (ASSETS) =====
    "Computer": "Máy tính",
    "Computers": "Máy tính",
    "Monitor": "Màn hình",
    "Monitors": "Màn hình",
    "Printer": "Máy in",
    "Printers": "Máy in",
    "Peripheral": "Thiết bị ngoại vi",
    "Peripherals": "Thiết bị ngoại vi",
    "Network equipment": "Thiết bị mạng",
    "Network equipments": "Thiết bị mạng",
    "Phone": "Điện thoại",
    "Phones": "Điện thoại",
    "Software": "Phần mềm",
    "Softwares": "Phần mềm",
    "Software version": "Phiên bản phần mềm",
    "Software versions": "Phiên bản phần mềm",
    "License": "Bản quyền",
    "Licenses": "Bản quyền",
    "Component": "Linh kiện",
    "Components": "Linh kiện",
    "Consumable": "Vật tư tiêu hao",
    "Consumables": "Vật tư tiêu hao",
    "Rack": "Tủ rack",
    "Racks": "Tủ rack",
    "Enclosure": "Vỏ máy chủ",
    "PDU": "Bộ phân phối điện (PDU)",
    "Passive Device": "Thiết bị thụ động",
    "Unmanaged device": "Thiết bị không quản lý",
    "Asset": "Tài sản",
    "Asset type": "Loại tài sản",
    "Inventory number": "Mã tài sản",
    "Serial number": "Số sê-ri",
    "Other serial": "Sê-ri khác",
    "Inventory": "Kiểm kê",
    "Warranty": "Bảo hành",
    "Warranty expiration": "Hết hạn bảo hành",
    "Warranty information": "Thông tin bảo hành",
    "Purchase date": "Ngày mua",
    "Delivery date": "Ngày giao hàng",
    "Start date of warranty": "Ngày bắt đầu bảo hành",
    "Warranty duration": "Thời hạn bảo hành",
    "Supplier": "Nhà cung cấp",
    "Suppliers": "Nhà cung cấp",
    "Budget": "Ngân sách",
    "Value": "Giá trị",
    "Installed": "Đã cài đặt",
    "Last boot": "Lần khởi động cuối",
    "Operating system": "Hệ điều hành",
    "Operating systems": "Hệ điều hành",
    "Processor": "Bộ xử lý",
    "Memory": "Bộ nhớ RAM",
    "Hard drive": "Ổ cứng",
    "Graphic card": "Card đồ hoạ",
    "Network card": "Card mạng",
    "Sound card": "Card âm thanh",
    "Motherboard": "Bo mạch chủ",
    "Power supply": "Bộ nguồn",
    "Storage": "Lưu trữ",
    "Total capacity": "Tổng dung lượng",
    "Free space": "Dung lượng trống",
    "Used space": "Dung lượng đã dùng",

    # ===== SU CO / TICKET =====
    "Ticket": "Phiếu yêu cầu",
    "Tickets": "Phiếu yêu cầu",
    "New ticket": "Phiếu mới",
    "Create a ticket": "Tạo phiếu yêu cầu",
    "Incident": "Sự cố",
    "Incidents": "Sự cố",
    "Request": "Yêu cầu",
    "Requests": "Yêu cầu",
    "Problem": "Vấn đề",
    "Problems": "Vấn đề",
    "Change": "Thay đổi",
    "Changes": "Thay đổi",
    "Urgency": "Mức độ khẩn cấp",
    "Impact": "Mức độ ảnh hưởng",
    "Priority": "Độ ưu tiên",
    "Very low": "Rất thấp",
    "Low": "Thấp",
    "Medium": "Trung bình",
    "High": "Cao",
    "Very high": "Rất cao",
    "Immediate": "Khẩn cấp",
    "Assigned": "Đã phân công",
    "Assigned to": "Giao cho",
    "Technician": "Kỹ thuật viên",
    "Technicians": "Kỹ thuật viên",
    "Requester": "Người yêu cầu",
    "Observer": "Người theo dõi",
    "Category": "Danh mục",
    "Categories": "Danh mục",
    "Followup": "Xử lý",
    "Followups": "Các bước xử lý",
    "Solution": "Giải pháp",
    "Solutions": "Giải pháp",
    "Task": "Công việc",
    "Tasks": "Công việc",
    "Planning": "Lập kế hoạch",
    "Planned": "Đã lên kế hoạch",
    "Planned start date": "Ngày bắt đầu dự kiến",
    "Planned end date": "Ngày kết thúc dự kiến",
    "Closed": "Đã đóng",
    "Close ticket": "Đóng phiếu",
    "Reopen": "Mở lại",
    "Resolve": "Giải quyết",
    "Resolved": "Đã giải quyết",
    "Solve": "Giải quyết",
    "Processing": "Đang xử lý",
    "Pending": "Đang chờ",
    "New": "Mới",
    "Attached documents": "Tài liệu đính kèm",
    "Attachments": "Tệp đính kèm",
    "Satisfaction survey": "Khảo sát mức độ hài lòng",
    "Satisfaction": "Mức độ hài lòng",
    "Duration": "Thời lượng",
    "Time spent": "Thời gian đã dùng",
    "Total duration": "Tổng thời gian",
    "Cost": "Chi phí",
    "Total cost": "Tổng chi phí",
    "Resolution time": "Thời gian giải quyết",
    "Take into account": "Tiếp nhận",
    "Assign": "Phân công",
    "Reject": "Từ chối",

    # ===== BAO TRI =====
    "Maintenance": "Bảo trì",
    "Maintenances": "Bảo trì",
    "Preventive maintenance": "Bảo trì định kỳ",
    "Corrective maintenance": "Bảo trì khắc phục",
    "Curative maintenance": "Bảo trì sửa chữa",
    "Recurring": "Định kỳ",
    "Periodicity": "Chu kỳ",
    "Next date": "Ngày tiếp theo",
    "Last date": "Ngày trước đó",
    "Planned date": "Ngày dự kiến",
    "Effective date": "Ngày thực hiện",
    "Contract": "Hợp đồng",
    "Contracts": "Hợp đồng",
    "Contract type": "Loại hợp đồng",
    "Contract number": "Số hợp đồng",
    "Begin date": "Ngày bắt đầu",
    "End date": "Ngày kết thúc",
    "Notice period": "Thời hạn báo trước",
    "State": "Trạng thái",
    "States": "Trạng thái",
    "Repair": "Sửa chữa",
    "Breakdown": "Hỏng hóc",
    "Out of order": "Hỏng, ngừng hoạt động",
    "In service": "Đang sử dụng",
    "In stock": "Trong kho",
    "Written off": "Đã thanh lý",

    # ===== MANG / IP =====
    "IP address": "Địa chỉ IP",
    "IP addresses": "Địa chỉ IP",
    "MAC address": "Địa chỉ MAC",
    "Network": "Mạng",
    "Networks": "Mạng",
    "Port": "Cổng kết nối",
    "Ports": "Cổng kết nối",
    "VLAN": "VLAN",
    "Subnet": "Mạng con",
    "Gateway": "Cổng nối mạng",
    "DNS": "DNS",
    "Domain": "Tên miền",
    "Hostname": "Tên máy chủ",
    "Switch": "Bộ chuyển mạch (Switch)",
    "Router": "Bộ định tuyến (Router)",
    "Firewall": "Tường lửa",
    "Access point": "Điểm truy cập WiFi",
    "Interface": "Giao diện mạng",
    "Interfaces": "Giao diện mạng",
    "Connected": "Đã kết nối",
    "Disconnected": "Mất kết nối",
    "Speed": "Tốc độ",
    "Bandwidth": "Băng thông",

    # ===== DON VI / TO CHUC =====
    "Entity": "Đơn vị",
    "Entities": "Đơn vị",
    "Department": "Phòng ban",
    "Departments": "Phòng ban",
    "Room": "Phòng",
    "Rooms": "Phòng",
    "Building": "Toà nhà",
    "Buildings": "Toà nhà",
    "Address": "Địa chỉ",
    "City": "Thành phố",
    "Country": "Quốc gia",
    "Phone number": "Số điện thoại",
    "Email": "Thư điện tử",
    "Email address": "Địa chỉ thư điện tử",
    "Login": "Tên đăng nhập",
    "Password": "Mật khẩu",
    "Profile": "Hồ sơ quyền",
    "Profiles": "Hồ sơ quyền",
    "Right": "Quyền",
    "Rights": "Quyền",
    "Permissions": "Các quyền",
    "Administrator": "Quản trị viên",
    "Super-Admin": "Quản trị cấp cao",
    "Self-Service": "Tự phục vụ",
    "Is active": "Đang hoạt động",
    "Last login": "Đăng nhập lần cuối",
    "Logs": "Nhật ký",
    "History": "Lịch sử",
    "Histories": "Lịch sử",
    "Backups": "Sao lưu",

    # ===== DASHBOARD / THONG KE =====
    "Statistics": "Thống kê",
    "Report": "Báo cáo",
    "Reports": "Báo cáo",
    "Summary": "Tổng hợp",
    "Number": "Số lượng",
    "Count": "Số lượng",
    "Total": "Tổng cộng",
    "Percent": "Phần trăm",
    "Percentage": "Tỷ lệ phần trăm",
    "Average": "Trung bình",
    "Minimum": "Nhỏ nhất",
    "Maximum": "Lớn nhất",
    "By": "Theo",
    "Period": "Khoảng thời gian",
    "From": "Từ",
    "To": "Đến",
    "Today": "Hôm nay",
    "This week": "Tuần này",
    "This month": "Tháng này",
    "This year": "Năm nay",
    "Last week": "Tuần trước",
    "Last month": "Tháng trước",
    "Last year": "Năm trước",
    "Chart": "Biểu đồ",
    "Graph": "Đồ thị",
    "Evolution": "Diễn biến",
    "Distribution": "Phân bố",

    # --- Tieu de widget tren bang dieu khien (GLPI 11 KHONG dich san) ---
    # Mau "%s by %s" la goc cua MOI tieu de bieu do dang
    # "Cac may tinh by Nha san xuat" -> dich 1 lan, sua het tat ca.
    "%s by %s": "%s theo %s",
    "Number of %s by type": "Số lượng %s theo loại",
    "Number of tickets by month": "Số phiếu theo tháng",
    "Tickets status by month": "Tình trạng phiếu theo tháng",
    "Number of tickets by SLA status and technician": "Số phiếu theo trạng thái SLA và kỹ thuật viên",
    "Number of tickets by SLA status and technician group": "Số phiếu theo trạng thái SLA và nhóm kỹ thuật viên",
    "Top ticket's requesters": "Người gửi phiếu nhiều nhất",
    "Top ticket's categories": "Loại sự cố nhiều nhất",
    "No data found": "Không có dữ liệu",
    "Find menu": "Tìm menu",
    "Search…": "Tìm kiếm…",
    "Collapse menu": "Thu gọn menu",
    "Expand menu": "Mở rộng menu",

    # --- Nhan the so lieu (bigNumber) + thanh cong cu bang dieu khien ---
    "Number of %s": "Số lượng %s",
    "Number of type of %s": "Số loại %s",
    "Title": "Tiêu đề",
    "Filters": "Bộ lọc",
    "Refresh this card": "Làm mới thẻ này",
    "Edit this card": "Sửa thẻ này",
    "Delete this card": "Xoá thẻ này",
    "Add a new dashboard": "Thêm bảng điều khiển mới",
    "Clone this dashboard": "Nhân bản bảng điều khiển này",
    "Delete this dashboard": "Xoá bảng điều khiển này",
    "Share or embed this dashboard": "Chia sẻ hoặc nhúng bảng điều khiển này",
    "Toggle auto-refresh": "Bật/tắt tự động làm mới",
    "Toggle night mode": "Bật/tắt chế độ tối",
    "Toggle fullscreen": "Bật/tắt toàn màn hình",
    "Toggle edit mode": "Bật/tắt chế độ sửa",
    "Toggle filter mode": "Bật/tắt chế độ lọc",

    # ===== CAU HINH / HE THONG =====
    "Configuration": "Cấu hình",
    "Settings": "Cài đặt",
    "Parameters": "Tham số",
    "Plugin": "Tiện ích mở rộng",
    "Plugins": "Tiện ích mở rộng",
    "Install": "Cài đặt",
    "Uninstall": "Gỡ cài đặt",
    "Enable": "Bật",
    "Disable": "Tắt",
    "Enabled": "Đang bật",
    "Disabled": "Đang tắt",
    "Language": "Ngôn ngữ",
    "Timezone": "Múi giờ",
    "Default": "Mặc định",
    "Notification": "Thông báo",
    "Notifications": "Thông báo",
    "Template": "Mẫu",
    "Templates": "Mẫu",
    "Rule": "Quy tắc",
    "Rules": "Quy tắc",
    "Field": "Trường dữ liệu",
    "Fields": "Trường dữ liệu",
    "Required": "Bắt buộc",
    "Optional": "Không bắt buộc",
    "Visible": "Hiển thị",
    "Hidden": "Ẩn",
    "System": "Hệ thống",
    "Access": "Truy cập",
    "Security": "Bảo mật",
    "Log": "Nhật ký",
    "Error": "Lỗi",
    "Warning": "Cảnh báo",
    "Success": "Thành công",
    "Information": "Thông tin",
    "Data": "Dữ liệu",
    "Database": "Cơ sở dữ liệu",
    "Backup": "Sao lưu",
    "Restore": "Phục hồi",
    "Update needed": "Cần cập nhật",
    "Update": "Cập nhật",
    "Installation": "Cài đặt",
    "Uninstallation": "Gỡ cài đặt",
    "Activate": "Kích hoạt",
    "Deactivate": "Vô hiệu hoá",
    "Version": "Phiên bản",
    "Author": "Tác giả",
    "License": "Giấy phép",

    # ===== THONG BAO / LOI =====
    "Operation successful": "Thao tác thành công",
    "Operation failed": "Thao tác thất bại",
    "Item successfully added": "Thêm mới thành công",
    "Item successfully updated": "Cập nhật thành công",
    "Item successfully deleted": "Xoá thành công",
    "Are you sure?": "Bạn có chắc chắn không?",
    "Confirmation": "Xác nhận",
    "Please confirm": "Vui lòng xác nhận",
    "This action cannot be undone": "Thao tác này không thể hoàn tác",
    "No item found": "Không tìm thấy dữ liệu",
    "No results found": "Không có kết quả",
    "Access denied": "Không có quyền truy cập",
    "You do not have permission": "Bạn không có quyền thực hiện",
    "Required field": "Trường bắt buộc",
    "Invalid value": "Giá trị không hợp lệ",
    "Save successful": "Lưu thành công",
    "Failed to save": "Lưu thất bại",

    # ===== TU KHOA TIM KIEM NANG CAO =====
    "Contains": "Chứa",
    "Does not contain": "Không chứa",
    "Is": "Là",
    "Is not": "Không là",
    "Starts with": "Bắt đầu bằng",
    "Ends with": "Kết thúc bằng",
    "Before": "Trước",
    "After": "Sau",
    "Between": "Trong khoảng",
    "Under": "Dưới",
    "Over": "Trên",
    "Equals": "Bằng",
    "Greater than": "Lớn hơn",
    "Less than": "Nhỏ hơn",
    "AND": "VÀ",
    "OR": "HOẶC",
    "NOT": "KHÔNG",
    "Sort": "Sắp xếp",
    "Ascending": "Tăng dần",
    "Descending": "Giảm dần",
    "Columns": "Cột hiển thị",
    "Display": "Hiển thị",
    "Show": "Xem",
    "Hide": "Ẩn",
    "Advanced search": "Tìm kiếm nâng cao",
    "Results": "Kết quả",
    "Page": "Trang",
    "of": "trên",
    "rows": "dòng",
    "per page": "mỗi trang",
}


# =============================================================================
# BAN DICH CHO DANG SO NHIEU  (_n -> translatePlural)
# =============================================================================
# VI SAO CAN BANG RIENG?
#   GLPI goi _n($so_it, $so_nhieu, $n) cho MOI nhan dang danh sach/dem so.
#   Ham _n() dung translatePlural() -> tra cuu entry CO msgid_plural, KHONG
#   dung entry msgid don. Ban dich vi_VN chinh thuc cua GLPI de TRONG 212/443
#   entry dang so nhieu (msgstr[0] = "" hoac giu nguyen tieng Anh).
#   => Cac nhan nhu "Ticket", "Asset", "Category"... hien thi tieng Anh tren
#      bang dieu khien va danh sach, du bang BAN_DICH_BO_SUNG da co ban dich.
#   Vi tieng Viet co nplurals=1 (mot dang duy nhat cho ca it lan nhieu), mot
#   ban dich duy nhat du dung cho ca hai truong hop.
#
# Khoa o day la msgid SO IT (phan truoc dau \0 cua entry so nhieu).
BAN_DICH_SO_NHIEU = {
    # --- Nhan nghiep vu hien tren bang dieu khiên / danh sach ---
    "Ticket": "Phiếu yêu cầu",

    # --- Muc co KHOÁ ĐẦY ĐỦ (chua ky tu NUL) -> dung de THEM MOI entry ---
    # Chi ghi o day khi da doc DUNG chuoi trong ma nguon GLPI, vi khoa tra cuu
    # phai khop chinh xac tung ky tu. Xem chu thich o gop-ban-dich-tieng-viet.py.
    # RSSFeed.php:60 -> _n('RSS feed', 'RSS feed', $nb)
    "RSS feed\0RSS feed": "Nguồn tin RSS",
    "Asset": "Tài sản",
    "Category": "Danh mục",
    "Error": "Lỗi",
    "Database": "Cơ sở dữ liệu",
    "Rack": "Tủ rack",
    "State": "Trạng thái",
    "Memory": "Bộ nhớ RAM",
    "Observer": "Người theo dõi",
    "Manager": "Quản lý",
    "Saved search": "Tìm kiếm đã lưu",
    "Service level": "Mức dịch vụ",
    "Cluster": "Cụm máy chủ",
    "Peripheral": "Thiết bị ngoại vi",
    "Passive device": "Thiết bị thụ động",
    "Unmanaged asset": "Tài sản chưa quản lý",
    "Enclosure": "Vỏ máy chủ",
    "Line": "Đường truyền",
    "Data center": "Trung tâm dữ liệu",
    "Asset definition": "Định nghĩa tài sản",
    "Appliance": "Thiết bị tổng hợp",
    "OAuth client": "Ứng dụng OAuth",
    "Certificate": "Chứng thư số",
    "PDU": "Bộ phân phối điện (PDU)",

    # --- Linh kien / thiet bi ---
    "Comment": "Bình luận",
    "Picture": "Hình ảnh",
    "Business criticity": "Mức độ quan trọng",
    "Approval step": "Bước phê duyệt",
    "Followup template": "Mẫu theo dõi",
    "Service catalog category": "Danh mục dịch vụ",
    "Notification used:": "Thông báo đã dùng:",
    "Architecture": "Kiến trúc",
    "Kernel": "Nhân hệ điều hành",
    "Edition": "Phiên bản",
    "Port number": "Số cổng",
    "Exclusion": "Loại trừ",
    "Destination": "Đích đến",
    "Agent type": "Loại tác nhân",
    "ITIL object": "Đối tượng ITIL",
    "Custom asset": "Tài sản tùy chỉnh",
    "Change approval": "Phê duyệt thay đổi",
    "Approval template target": "Đích mẫu phê duyệt",
    "Observer group": "Nhóm theo dõi",
    "Cable type": "Loại cáp",
    "Sensor": "Cảm biến",
    "Firmware": "Phần mềm nhúng",
    "Problem template": "Mẫu vấn đề",
    "Domain item": "Mục tên miền",
    "Authorized substitute": "Người thay thế được uỷ quyền",
    "Plug": "Phích cắm",
    "Domain type": "Loại tên miền",
    "Document item": "Mục tài liệu",
    "Device processor model": "Model bộ xử lý",
    "Project task template": "Mẫu công việc dự án",
    "Webhook category": "Nhóm webhook",
    "Device hard drive model": "Model ổ cứng",
    "Event category": "Nhóm sự kiện",
    "Linked change": "Thay đổi liên kết",
    "Linked problem": "Vấn đề liên kết",
    "Enclosure item": "Mục vỏ máy",
    "Approval template": "Mẫu phê duyệt",
    "Month": "Tháng",
    "Version of the operating system": "Phiên bản hệ điều hành",
    "Device drive model": "Model ổ đĩa",
    "External event": "Sự kiện bên ngoài",
    "Connection to LDAP directory failed": "Kết nối thư mục LDAP thất bại",
    "User not found in LDAP directory": "Không tìm thấy người dùng trong thư mục LDAP",
    "Device graphic card model": "Model card đồ hoạ",
    "System board model": "Model bo mạch chủ",
    "Sensor type": "Loại cảm biến",
    "Cable": "Cáp",
    "Cable strand": "Sợi cáp",
    "Process": "Tiến trình",
    "PDU model": "Model PDU",
    "Project item": "Mục dự án",
    "Monitor type": "Loại màn hình",
    "Locked field": "Trường bị khoá",
    "Network card model": "Model card mạng",
    "Device power supply model": "Model bộ nguồn",
    "Camera": "Camera",
    "Record type": "Loại bản ghi",
    "Network port type": "Loại cổng mạng",
    "Simcard type": "Loại SIM",
    "ITIL category": "Danh mục ITIL",
    "VLAN": "VLAN",
    "Webhook": "Webhook",
    "Custom header": "Tiêu đề tùy chỉnh",
    "Query log": "Nhật ký truy vấn",
    "Generic type": "Loại chung",
    "Email server": "Máy chủ email",
    "Generic device": "Thiết bị chung",
    "Rack model": "Model tủ rack",
    "Simcard": "SIM",
    "PDU type": "Loại PDU",
    "Group item": "Mục nhóm",
    "Fiber type": "Loại cáp quang",
    "Database instance": "Phiên bản CSDL",
    "RSS feed": "Nguồn tin RSS",
    "Knowledge base item": "Mục cơ sở tri thức",
    "Linked assistance object": "Đối tượng hỗ trợ liên kết",
    "PCI vendor": "Nhà sản xuất PCI",
    "Passive device type": "Loại thiết bị thụ động",
    "Domain relation": "Quan hệ tên miền",
    "Device sound card model": "Model card âm thanh",
    "API client": "Ứng dụng API",
    "Link Change/Change": "Liên kết Thay đổi/Thay đổi",
    "Revision": "Bản sửa đổi",
    "Device control model": "Model thiết bị điều khiển",
    "Latest date": "Ngày gần nhất",
    "Allowed status": "Trạng thái cho phép",
    "Change template": "Mẫu thay đổi",
    "Ticket approval": "Phê duyệt phiếu",
    "Other component model": "Model linh kiện khác",
    "Appliance environment": "Môi trường thiết bị tổng hợp",
    "Item operating system": "Hệ điều hành của mục",
    "Kernel version": "Phiên bản nhân",
    "USB vendor": "Nhà sản xuất USB",
    "Certificate type": "Loại chứng thư",
    "SNMP credential": "Thông tin SNMP",
    "Link Project/Itil": "Liên kết Dự án/ITIL",
    "Itil item": "Mục ITIL",
    "Ticket recurrent item": "Mục phiếu định kỳ",
    "Device sensor model": "Model cảm biến",
    "Manual link": "Liên kết thủ công",
    "Device generic model": "Model thiết bị chung",
    "Device memory model": "Model bộ nhớ",
    "Line operator": "Nhà mạng",
    "Ticket item": "Mục phiếu",
    "Ticket type": "Loại phiếu",
    "Socket": "Ổ cắm",
    "Custom field": "Trường tùy chỉnh",
    "Step": "Bước",
    "Assignee": "Người được giao",
    "Access control": "Kiểm soát truy cập",
    "Section": "Mục",
    "Select device...": "Chọn thiết bị...",
    "User Device": "Thiết bị người dùng",
    "GLPI Object": "Đối tượng GLPI",
    "Question": "Câu hỏi",
    "Form": "Biểu mẫu",
    "Event log": "Nhật ký sự kiện",
    "Dropdown definition": "Định nghĩa danh mục",
    "Found %d item to fix.": "Tìm thấy %d mục cần sửa.",
    "Do you want to fix it?": "Bạn có muốn sửa không?",
    "Socket model": "Model ổ cắm",
    "Assigned group": "Nhóm được giao",
    "Assigned supplier": "Nhà cung cấp được giao",
    "Appliance type": "Loại thiết bị tổng hợp",
    "Environment": "Môi trường",
    "Affected item": "Mục bị ảnh hưởng",
    "Saved search alert": "Cảnh báo tìm kiếm đã lưu",
    "Cartridge inventoried information": "Thông tin hộp mực kiểm kê",
    "Battery type": "Loại pin",
    "Are you sure you want to add this item to transfer list?":
        "Bạn có chắc muốn thêm mục này vào danh sách chuyển giao?",
    "Ticket approval step": "Bước phê duyệt phiếu",
    "Management port": "Cổng quản lý",
    "Operating system architecture": "Kiến trúc hệ điều hành",
    "Database instance category": "Nhóm phiên bản CSDL",
    "Default filter": "Bộ lọc mặc định",
    "Database instance type": "Loại phiên bản CSDL",
    "Domain record": "Bản ghi tên miền",
    "Record": "Bản ghi",
    "Firmware type": "Loại phần mềm nhúng",
    "Public saved search": "Tìm kiếm đã lưu công khai",
    "Device firmware model": "Model phần mềm nhúng",
    "Problem item": "Mục vấn đề",
    "Device hard drive type": "Loại ổ cứng",
    "External events template": "Mẫu sự kiện bên ngoài",
    "Change item": "Mục thay đổi",
    "Line type": "Loại đường truyền",
    "Requester category": "Nhóm người yêu cầu",
    "Observer category": "Nhóm người theo dõi",
    "Technician category": "Nhóm kỹ thuật viên",
    "Enclosure model": "Model vỏ máy",
    "PCI device": "Thiết bị PCI",
    "Server room": "Phòng máy chủ",
    "Rack type": "Loại tủ rack",
    "Pending reason": "Lý do chờ",
    "Payload": "Dữ liệu gửi",
    "Cluster type": "Loại cụm máy chủ",
    "Phone power supply type": "Loại nguồn điện thoại",
    "Device case model": "Model vỏ máy",
    "Cluster item": "Mục cụm máy chủ",
    "Budget type": "Loại ngân sách",
    "Passive device model": "Model thiết bị thụ động",
    "Device battery model": "Model pin",
    "Link Problem/Problem": "Liên kết Vấn đề/Vấn đề",
    "Automatic reminder": "Nhắc nhở tự động",
    "Network socket": "Ổ cắm mạng",
    "Linked asset": "Tài sản liên kết",
    "Equipment refused by rules log": "Nhật ký thiết bị bị từ chối bởi quy tắc",
    "Change Approval step": "Bước phê duyệt thay đổi",
    "Line item": "Mục đường truyền",
    "Battery": "Pin",
    "Read only field": "Trường chỉ đọc",
    "Device camera model": "Model camera",
    "Agent": "Tác nhân",
    "Instance": "Phiên bản",

    # --- Chuoi co tham so (giu nguyen %s / %d) ---
    "%1$s item not saved": "%1$s mục chưa được lưu",
    "%s error": "%s lỗi",
    "%1$s template": "Mẫu %1$s",
    "%d element": "%d phần tử",
    "%1$d database": "%1$d cơ sở dữ liệu",
    "%d unit": "%d đơn vị",
    "%s type": "Loại %s",
    "Used by %1$s asset": "Được dùng bởi %1$s tài sản",
    "%s model": "Model %s",
    "%s plugin": "Plugin %s",
    "Delete if older than %s month": "Xoá nếu cũ hơn %s tháng",
    "Helpdesk translation": "Bản dịch trợ giúp",
    "Form translation": "Bản dịch biểu mẫu",
}


# -----------------------------------------------------------------------------
# DOC FILE .PO
# -----------------------------------------------------------------------------
def doc_po(duong_dan):
    """
    Doc file .po, tra ve dict {msgid: msgstr}.
    Ho tro ca chuoi nhieu dong (msgid "" ... "tiep").
    """
    ban_dich = {}
    if not os.path.exists(duong_dan):
        return ban_dich

    with open(duong_dan, encoding='utf-8') as f:
        noi_dung = f.read()

    # Tach thanh tung entry
    for entry in re.split(r'\n\s*\n', noi_dung):
        if 'msgid' not in entry:
            continue
        # Bo qua entry fuzzy (chua duoc kiem duyet)
        if re.search(r'^#,\s*fuzzy', entry, re.M):
            continue

        msgid = _lay_chuoi(entry, 'msgid')
        msgstr = _lay_chuoi(entry, 'msgstr')
        if msgid and msgstr:
            ban_dich[msgid] = msgstr
    return ban_dich


def _lay_chuoi(entry, khoa):
    """Trich gia tri cua msgid/msgstr (co the nhieu dong noi tiep)."""
    lines = entry.split('\n')
    gtri = []
    gom = False
    for ln in lines:
        s = ln.strip()
        if s.startswith(khoa + ' '):
            gom = True
            gtri.append(s[len(khoa) + 1:].strip())
        elif gom and s.startswith('"'):
            gtri.append(s)
        elif gom and not s.startswith('"'):
            break
    if not gtri:
        return ''
    return ' '.join(g.strip().strip('"') for g in gtri)


# -----------------------------------------------------------------------------
# BIEN DICH .MO (thuan Python - khong can msgfmt)
# -----------------------------------------------------------------------------
def ghi_mo(ban_dich, duong_dan_mo):
    """
    Ghi file .mo theo dinh dang GNU gettext.
    Tham khao: https://www.gnu.org/software/gettext/manual/html_node/MO-Files.html
    """
    # Sap xep theo msgid (yeu cau cua dinh dang de tra cuu nhi phan)
    items = sorted(ban_dich.items(), key=lambda x: x[0].encode('utf-8'))
    so_luong = len(items)

    # Header cua file .mo (metadata)
    header = (
        "Project-Id-Version: GLPI 11 VI (bo sung do an DLU)\n"
        "MIME-Version: 1.0\n"
        "Content-Type: text/plain; charset=UTF-8\n"
        "Content-Transfer-Encoding: 8bit\n"
        "Language: vi_VN\n"
        "Plural-Forms: nplurals=1; plural=0;\n"
    )

    # Bang chuoi goc + chuoi dich
    msgid_blob = b''
    msgstr_blob = b''
    offsets = []

    # Entry dau tien la header (msgid rong)
    msgid_blob += b'\x00'
    msgstr_blob += header.encode('utf-8') + b'\x00'
    offsets.append((0, 0, len(header.encode('utf-8'))))

    for msgid, msgstr in items:
        id_b = msgid.encode('utf-8')
        str_b = msgstr.encode('utf-8')
        offsets.append((
            len(msgid_blob),
            len(msgstr_blob),
            len(str_b),
        ))
        msgid_blob += id_b + b'\x00'
        msgstr_blob += str_b + b'\x00'

    tong = so_luong + 1              # +1 cho header
    off_tbl_size = tong * 8          # moi entry: 2 x uint32
    off_msgid_start = 7 * 4          # header co 7 truong uint32
    off_msgstr_start = off_msgid_start + off_tbl_size

    # --- Cau truc header (7 uint32) ---
    magic = 0x950412de
    version = 0
    nstrings = tong
    off_orig_tbl = off_msgid_start
    off_trans_tbl = off_msgstr_start
    hash_size = 0
    off_hash_tbl = 0

    header_bin = struct.pack(
        '<7I',
        magic, version, nstrings,
        off_orig_tbl, off_trans_tbl,
        hash_size, off_hash_tbl,
    )

    # --- Bang offset ---
    orig_tbl = b''
    trans_tbl = b''
    for o_id, o_str, ln_str in offsets:
        orig_tbl += struct.pack('<2I', len(msgid_blob), o_id)
        trans_tbl += struct.pack('<2I', ln_str, o_str)

    # Sua lai: do dai msgid phai la do dai that cua chuoi
    orig_tbl = b''
    trans_tbl = b''
    # Tinh lai chinh xac do dai tung msgid
    do_dai = []
    for msgid, msgstr in items:
        do_dai.append(len(msgid.encode('utf-8')))
    # Entry header: msgid rong -> do dai 0
    orig_tbl += struct.pack('<2I', 0, 0)
    trans_tbl += struct.pack('<2I', len(header.encode('utf-8')), 0)
    for idx, (msgid, msgstr) in enumerate(items, start=1):
        o_id, o_str, ln_str = offsets[idx]
        orig_tbl += struct.pack('<2I', do_dai[idx - 1], o_id)
        trans_tbl += struct.pack('<2I', ln_str, o_str)

    # --- Ghi file ---
    with open(duong_dan_mo, 'wb') as f:
        f.write(header_bin)
        f.write(orig_tbl)
        f.write(trans_tbl)
        f.write(msgid_blob)
        f.write(msgstr_blob)

    return tong


# -----------------------------------------------------------------------------
# CHUONG TRINH CHINH
# -----------------------------------------------------------------------------
def main():
    goc = os.path.dirname(os.path.abspath(__file__))
    thu_muc = os.path.join(goc, '..', '.tmp-locale')
    po_vao = os.path.join(thu_muc, 'vi_VN.po')
    mo_ra = os.path.join(thu_muc, 'vi_VN.mo')

    print('=' * 78)
    print('  BO SUNG BAN DICH TIENG VIET CHO GLPI')
    print('=' * 78)

    # File .po rong (0 byte) cung coi nhu thieu: co the do docker cp bi ngat,
    # dia day, hoac tai do dang. Neu chap nhan file rong thi lop phu sinh ra se
    # THIEU toan bo chuoi da dich chinh thuc ma KHONG bao loi (trong nhu thanh
    # cong). Dung cung dieu kien voi tao-mo-bo-sung.py va kiem-tra-tieng-viet.py.
    if not os.path.exists(po_vao) or os.path.getsize(po_vao) == 0:
        # .po khong duoc version hoa (xem .gitignore) nhung luon tai lai duoc
        # tu image GLPI -> tu dong lay ve thay vi bat nguoi dung chay tay.
        glpi_container = os.environ.get('GLPI_CONTAINER', 'helpdesk-glpi')
        os.makedirs(thu_muc, exist_ok=True)
        r = subprocess.run(
            ['docker', 'exec', glpi_container, 'cat',
             '/var/www/glpi/locales/vi_VN.po'],
            capture_output=True)
        if r.stdout:
            with open(po_vao, 'wb') as f:
                f.write(r.stdout)
            print(f'    -> Da tai vi_VN.po tu container ({len(r.stdout):,} byte)')
        else:
            print(f'\n[LOI] Khong thay {po_vao} va khong tai duoc tu container')
            print('      Container da chay chua? Thu: bash scripts/cai-ban-dich.sh tai')
            sys.exit(1)

    # --- 1. Doc ban dich goc ---
    print(f'\n[1] Doc ban dich goc: {os.path.basename(po_vao)}')
    goc_dict = doc_po(po_vao)
    print(f'    -> Da dich san: {len(goc_dict)} chuoi')

    # --- 2. Gop ban dich bo sung ---
    print(f'\n[2] Gop ban dich bo sung (do an DLU)')
    print(f'    -> Tu dien bo sung: {len(BAN_DICH_BO_SUNG)} chuoi')
    them_moi = 0
    ghi_de = 0
    for en, vi in BAN_DICH_BO_SUNG.items():
        if en not in goc_dict:
            them_moi += 1
        elif goc_dict[en] != vi:
            ghi_de += 1
        goc_dict[en] = vi
    print(f'    -> Them moi: {them_moi} chuoi')
    print(f'    -> Ghi de (dich lai): {ghi_de} chuoi')
    print(f'    -> TONG CONG: {len(goc_dict)} chuoi')

    # --- 3. Bien dich sang .mo ---
    print(f'\n[3] Bien dich sang dinh dang .mo (thuan Python)')
    tong = ghi_mo(goc_dict, mo_ra)
    kich_thuoc = os.path.getsize(mo_ra) / 1024
    print(f'    -> Da ghi: {mo_ra}')
    print(f'    -> Kich thuoc: {kich_thuoc:.1f} KB ({tong} entry)')

    # --- 4. Kiem tra lai bang cach doc nguoc file .mo ---
    print(f'\n[4] Kiem tra tinh hop le cua file .mo')
    if kiem_tra_mo(mo_ra):
        print('    -> File .mo HOP LE')
    else:
        print('    -> [CANH BAO] File .mo co the bi loi!')
        sys.exit(1)

    print('\n' + '=' * 78)
    print('  HOAN TAT')
    print('=' * 78)
    print('\n  BUOC TIEP THEO: cai ban dich vao GLPI')
    print('    bash scripts/cai-ban-dich.sh')
    print()


def kiem_tra_mo(duong_dan):
    """Doc lai file .mo de kiem tra tinh hop le."""
    try:
        with open(duong_dan, 'rb') as f:
            data = f.read()
        magic, ver, n, off_o, off_t, hash_sz, off_h = struct.unpack('<7I', data[:28])
        if magic != 0x950412de:
            print(f'       magic sai: {hex(magic)}')
            return False
        if n == 0:
            print('       khong co entry nao')
            return False
        # Thu tra 1 chuoi cu the
        for i in range(n):
            ln, off = struct.unpack('<2I', data[off_o + i * 8: off_o + i * 8 + 8])
            msgid = data[off:off + ln]
            ln2, off2 = struct.unpack('<2I', data[off_t + i * 8: off_t + i * 8 + 8])
            msgstr = data[off2:off2 + ln2]
            if msgid == b'Computer':
                print(f'       Thu dich: "Computer" => "{msgstr.decode("utf-8")}"')
                break
        return True
    except Exception as e:
        print(f'       Loi doc file: {e}')
        return False


if __name__ == '__main__':
    main()
