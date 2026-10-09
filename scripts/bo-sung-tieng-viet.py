#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
================================================================================
 BO SUNG BAN DICH TIENG VIET CHO GLPI  (PO -> MO, khong can msgfmt)
================================================================================
 Do an thuc tap: Xay dung he thong ho tro ky thuat (PineDesk) - DH Da Lat

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
import gettext
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
    # ===== TRANG TU PHUC VU (Helpdesk) =====
    # Trang sinh vien / giang vien dung de bao su co. Ban dich vi_VN chinh thuc
    # cua GLPI 11 BO TRONG toan bo cac nhan nay (msgstr = ""), nen tren man
    # hinh demo trang nay hien gan nhu 100% tieng Anh. Bo sung tay tai day.
    "How can we help you?": "Chúng tôi có thể giúp gì cho bạn?",
    "Browse help articles": "Xem các bài viết trợ giúp",
    "See all available help articles and our FAQ.": "Xem toàn bộ bài viết trợ giúp và các câu hỏi thường gặp.",
    "Report an issue": "Báo cáo sự cố",
    "Ask for support from our helpdesk team.": "Yêu cầu hỗ trợ từ đội ngũ trợ giúp.",
    "Request a service": "Yêu cầu một dịch vụ",
    "Ask for a service to be provided by our team.": "Yêu cầu đội ngũ cung cấp một dịch vụ.",
    "See your tickets": "Xem phiếu của bạn",
    "View all the tickets that you have created.": "Xem toàn bộ phiếu yêu cầu bạn đã tạo.",
    "Make a reservation": "Đặt mượn thiết bị",
    "Pick an available asset and reserve it for a given date.": "Chọn một thiết bị còn trống và đặt mượn theo ngày.",
    "Search for knowledge base entries or forms": "Tìm bài viết trong kho kiến thức hoặc biểu mẫu",
    "Request support": "Yêu cầu hỗ trợ",
    "Go to our service catalog and pick a form to create a new ticket.": "Mở danh mục dịch vụ và chọn biểu mẫu để tạo phiếu mới.",
    "Ongoing tickets": "Phiếu đang xử lý",
    "I need an account": "Tôi cần một tài khoản",
    "Back to login": "Quay lại đăng nhập",
    "You are not allowed to see this item.": "Bạn không có quyền xem mục này.",
    "You are not allowed to update this item.": "Bạn không có quyền cập nhật mục này.",
    "You are not allowed to create this item.": "Bạn không có quyền tạo mục này.",
    "You are not allowed to delete this item.": "Bạn không có quyền xoá mục này.",
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
    # Cac nut che do xem tren thanh cong cu danh sach phieu. Ban dich vi_VN
    # chinh thuc cua GLPI de trong (msgstr = "") nen nut van hien tieng Anh
    # giua mot giao dien da Viet hoa hoan toan.
    "Global Kanban": "Bảng Kanban",
    "Kanban": "Kanban",
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

    # ===== THANH PHAN TRANG + NHAN TRONG BIEU MAU =====
    # Cung loai loi nhu khoi SLA: ban dich vi_VN chinh thuc de msgstr = ""
    # nen cac chuoi nay roi ve tieng Anh. Chung nam ngay duoi bang du lieu
    # ("Showing 1 to 7 of 7 rows") hoac trong the "Actors" cua bieu mau, tuc
    # la cho nguoi dung nhin thay moi lan cuon trang.
    # Giu nguyen %s vi GLPI thay bang so that.
    "Showing %s to %s of %s rows": "Hiển thị %s đến %s trong %s dòng",
    "Sorted by %s": "Sắp xếp theo %s",
    "Rows per page": "Số dòng mỗi trang",
    "No results": "Không có kết quả",
    "Actors": "Các bên liên quan",
    "Linked object": "Đối tượng liên kết",
    "External File": "Tệp bên ngoài",
    "External files": "Tệp bên ngoài",
    "Room": "Phòng",
    # KHONG them "Entity" / "Rack": ca hai la msgid SO NHIEU trong .po goc
    # (msgid_plural "Entities" / "Racks") va "Entity" da co ban dich
    # "Các đối tượng". Them mot khoa so it se ghi de sai dang.

    # ===== SUA BAN DICH SAI NGHIA (khong phai chuoi trong) =====
    # Khac voi cac khoi tren (msgstr rong -> roi ve tieng Anh), day la cac
    # entry CO ban dich nhung dich SAI. Chuoi goc la "Login source" (nguon
    # xac thuc: CSDL noi bo / LDAP / SSO). Ban dich chinh thuc cua GLPI la
    # "Đăng nhập dữ liệu" — doc nhu "login data", vo nghia voi nguoi dung.
    # Nhan nay hien ngay tren trang dang nhap, canh o chon nguon xac thuc.
    "Login source": "Nguồn xác thực",
    # "GLPI internal database" bi dich thanh "GLPI cơ sở dữ liệu nội bộ" —
    # thieu gioi tu, doc nhu ten rieng. Day la MOT lua chon trong o chon
    # nguon xac thuc o tren.
    "GLPI internal database": "Cơ sở dữ liệu nội bộ của GLPI",

    # --- Chuoi con sot, quet tu giao dien that ---
    # "Server room" va "Linked assistance object" la msgid SO NHIEU trong .po
    # goc; ham va_so_nhieu() se tu lay ban dich so it nay ap cho ca dang nhieu.
    "Server room": "Phòng máy chủ",
    "Linked assistance object": "Đối tượng hỗ trợ liên kết",
    "Current page": "Trang hiện tại",
    "Top of the page": "Đầu trang",
    "rows / page": "dòng / trang",
    "Notifications are disabled in this entity.": "Thông báo đang bị tắt trong đơn vị này.",
    "%1$s will be added in entity %2$s": "%1$s sẽ được thêm vào đơn vị %2$s",
    # Khoi ly do tat thong bao, hien trong the "Cac ben lien quan" cua bieu mau
    # phieu. Ba cau nay nam lien nhau trong templates/components/itilobject/
    # actors/main.html.twig va deu co msgstr rong trong ban dich chinh thuc.
    "Notifications are disabled because:": "Thông báo bị tắt vì:",
    "User does not have an email address.": "Người dùng chưa có địa chỉ email.",
    "User has disabled notifications from its preferences.":
        "Người dùng đã tắt thông báo trong phần thiết lập cá nhân.",
    # Goi y trong hop thoai tim kiem nhanh (Ctrl+Alt+G). %s la to hop phim.
    "Tip: You can call this modal with %s keys combination":
        "Mẹo: mở hộp thoại này bằng tổ hợp phím %s",
    # Nhan trong hop thoai tim kiem nhanh va lien ket trong the thong bao.
    # Ca hai deu co msgstr rong trong ban dich chinh thuc.
    "Go to menu": "Tới menu",
    "Edit notification settings": "Sửa thiết lập thông báo",
    # Chu goi y trong o nhap cua hop thoai tim kiem nhanh. Ban dich chinh thuc
    # de TRONG, va chuoi nay con bi "dong bang" luc nap module Vue (xem
    # plugins/dlubrand/public/js/dlu-chu-vue.js).
    "Start typing to find a menu": "Gõ để tìm mục trong menu",
    # Chu thich cua nut mo lich chon ngay. Ban dich chinh thuc cung de TRONG.
    "Show date picker": "Mở lịch chọn ngày",
    # Nut them mot dieu kien sap xep trong thanh tim kiem nang cao (bam vao
    # bieu tuong ba gach ngang tren tieu de cot). Ban dich chinh thuc de TRONG
    # (locales/vi_VN.po dong 3779, msgstr = ""), nen nut van hien tieng Anh
    # giua mot thanh tim kiem da Viet hoa hoan toan.
    "Add another sort": "Thêm điều kiện sắp xếp",
    "Escalations defined in the OLA will be triggered under this new date.":
        "Các bước leo thang đã định trong OLA sẽ được kích hoạt theo mốc thời gian mới này.",

    # ===== CAM KET DICH VU (SLA) — thoi gian xu ly / tiep nhan =====
    # Cac nhan nay hien ngay tren danh sach phieu va trong bieu mau phieu.
    # Ban dich vi_VN chinh thuc cua GLPI de TRONG (msgstr = "") nen truoc day
    # cot van hien "Time to resolve" giua mot bang toan tieng Viet.
    # Giu nguyen chu viet tat TTO/TTR vi do la thuat ngu quoc te, ky thuat vien
    # van dung hang ngay; dich dai dong se lam tieu de cot bi cat.
    "Time to resolve": "Thời gian giải quyết",
    "Time to own": "Thời gian tiếp nhận",
    "Time to resolve + Progress": "Thời gian giải quyết + Tiến độ",
    "Time to resolve exceeded": "Quá hạn giải quyết",
    "Internal TTO": "TTO nội bộ",
    "Internal TTR": "TTR nội bộ",
    "Internal Time to own": "Thời gian tiếp nhận nội bộ",
    "Internal Time to resolve": "Thời gian giải quyết nội bộ",
    "TTO": "TTO",
    "TTR": "TTR",
    "OLA": "OLA",
    "SLA": "SLA",
    "Service level": "Mức dịch vụ",
    "Service levels": "Các mức dịch vụ",
    "Next escalation: %s": "Leo thang kế tiếp: %s",

    # ===== CHUOI CON SOT, QUET TU GIAO DIEN THAT (vong 2) =====
    # Quet bang trinh duyet tren 31 trang da dang nhap, loc ra chuoi ASCII
    # hien nguyen tieng Anh. Moi muc duoi day deu da doi chieu lai voi
    # locales/vi_VN.po cua GLPI: msgid co that, msgstr rong.

    # --- Tieu de cot trong bang danh sach tai san ---
    # Cac cot nay do GLPI sinh theo mot khuon chung cho MOI loai tai san,
    # nen sua mot lan la hien dung o tat ca danh sach.
    "Location code": "Mã vị trí",
    "Location alias": "Tên khác của vị trí",
    "Group in charge": "Nhóm phụ trách",
    "not contains": "không chứa",
    "Copy names to clipboard": "Sao chép tên vào bộ nhớ tạm",
    "All pages": "Tất cả các trang",

    # --- Cot thoi gian xu ly tren danh sach phieu ---
    # Nhom nhan nay thuoc SLA/OLA. Giu nguyen chu "OLA"/"SLA" vi do la ten
    # rieng cua khai niem trong GLPI, khong phai chu tieng Anh thong thuong.
    "Time to own exceeded": "Quá hạn tiếp nhận",
    "Internal time to own": "Thời gian tiếp nhận nội bộ",
    "Internal time to own exceeded": "Quá hạn tiếp nhận nội bộ",
    "Internal time to resolve": "Thời gian giải quyết nội bộ",
    "Internal time to resolve exceeded": "Quá hạn giải quyết nội bộ",
    "OLA Internal time to own": "OLA - Thời gian tiếp nhận nội bộ",
    "OLA Internal time to resolve": "OLA - Thời gian giải quyết nội bộ",
    "Next escalation level": "Cấp leo thang kế tiếp",
    "Substitute of a member of approver group": "Người thay thế của một thành viên nhóm phê duyệt",

    # --- Quan he phieu cha/con, dem so luong tren trang chi tiet ---
    "Number of sons tickets": "Số phiếu con",
    "Number of parent tickets": "Số phiếu cha",
    "Son of": "Phiếu con của",
    "Parent of": "Phiếu cha của",

    # --- Cau huong dan hien ngay tren bieu mau phieu ---
    "However, you can reactivate the notifications for this ticket.": "Tuy nhiên, bạn có thể bật lại thông báo cho phiếu này.",
    "The assignment of a SLA to a ticket causes the recalculation of the date.": "Gán một SLA cho phiếu sẽ khiến ngày được tính lại.",
    "The assignment of an OLA to a ticket causes the recalculation of the date.": "Gán một OLA cho phiếu sẽ khiến ngày được tính lại.",

    # --- Trang chi tiet may tinh: dem linh kien, thong so bo xu ly ---
    "Number of monitors": "Số màn hình",
    "Number of peripherals": "Số thiết bị ngoại vi",
    "Number of printers": "Số máy in",
    "Number of phones": "Số điện thoại",
    "processor: number of cores": "bộ xử lý: số nhân",
    "processor: number of threads": "bộ xử lý: số luồng",
    "Virtual machine Comment": "Ghi chú máy ảo",

    # --- Bieu mau nguoi dung: khoi mat khau ---
    "Passwords and access keys": "Mật khẩu và khoá truy cập",
    "Send an email to the user to set their own new password.": "Gửi email để người dùng tự đặt mật khẩu mới.",

    # --- Bieu mau nhom ---
    "Can be in charge of a task": "Có thể phụ trách một công việc",
    "Group code": "Mã nhóm",

    # --- Nhan dem so luong trong tab cua trang chi tiet ---
    # Nhung nhan nay KHONG goi __() ma goi _x('quantity', '...'). Ham _x()
    # tra cuu bang khoa "quantity\x04<nhan>" (ky tu \x04 = \004 trong PHP,
    # xem src/autoload/i18n.php). Vi vay phai ghi ca ngu canh vao khoa,
    # khong duoc chi ghi "Number of users".
    # Nguon: src/Group_User.php:654, Monitor.php:534, Peripheral.php:443,
    #        Phone.php:558, Printer.php:744
    "quantity\x04Number of users": "Số người dùng",
    "quantity\x04Number of monitors": "Số màn hình",
    "quantity\x04Number of peripherals": "Số thiết bị ngoại vi",
    "quantity\x04Number of phones": "Số điện thoại",
    "quantity\x04Number of printers": "Số máy in",
    # (Dang khong ngu canh "Number of ..." da co san o khoi tren, khong
    #  khai bao lai o day.)

    # --- Bieu mau don vi ---
    "No-Reply address": "Địa chỉ không trả lời",
    "No-Reply name": "Tên không trả lời",

    # --- Trang quan ly phan mem ---
    "Technician in charge of the software": "Kỹ thuật viên phụ trách phần mềm",

    # --- Nut quay lai o cac trang cau hinh / hop dong / ngan sach ---
    "Return to previous page": "Quay lại trang trước",

    # --- Trang Quy tac (rules): tieu de nhom va mo ta tung loai quy tac ---
    # Day la trang quan tri, nguoi dung thuong khong vao, nhung ten nhom quy
    # tac hien ngay tren menu trai nen van can doc duoc.
    "Location rules": "Quy tắc vị trí",
    "Apply a location by checking common criteria": "Gán vị trí theo các tiêu chí chung",
    "Rules for import and link equipments": "Quy tắc nhập và liên kết thiết bị",
    "Match data with an existing asset, create a new asset, or deny the import": "Khớp dữ liệu với tài sản đã có, tạo tài sản mới, hoặc từ chối nhập",
    "Normalize sub-data (like softwares, OS and models)": "Chuẩn hoá dữ liệu con (như phần mềm, hệ điều hành và model)",
    "Business rules for assets": "Quy tắc nghiệp vụ cho tài sản",
    "The asset is created or updated in GLPI": "Tài sản được tạo hoặc cập nhật trong GLPI",
    "Other rules": "Quy tắc khác",
    "Override the asset to another custom definition (like Servers)": "Chuyển tài sản sang một định nghĩa tuỳ chỉnh khác (như Máy chủ)",
    "Set an entity with some criteria (by its tag for example)": "Gán đơn vị theo tiêu chí (ví dụ theo thẻ tag)",

    # --- Muc menu nguoi dung (goc phai tren) ---
    # "About" nam trong menu xo ra khi bam ten nguoi dung. Dong ban quyen
    # "GLPI 11.0.0 Copyright (C) 2015-2025 Teclib' and contributors" nam
    # ngay duoi muc nay va CO Y de nguyen tieng Anh: do la dong ghi cong
    # phap ly cua tac gia, khong phai chu giao dien.
    "About": "Giới thiệu",

    # ===== CHUOI GIAO DIEN CON SOT — QUET THUC TE VONG 3 (TOAN BO TRANG MAT TIEN) =====
    # Quet tu 16 trang giao dien that (ticket, computer, monitor, printer, network,
    # software, user, group, location, itilcategory, stat, reservation, helpdesk, central,
    # chi tiet may tinh, chi tiet phieu).
    # Tat ca deu da doi chieu voi locales/vi_VN.po: msgid ton tai, msgstr rong.

    # --- Thanh dieu huong, menu nguoi dung va ho so ---
    "Change profile": "Đổi hồ sơ quyền",
    "User menu": "Menu người dùng",
    "Quick Access": "Truy cập nhanh",
    "Search results": "Kết quả tìm kiếm",
    "Community": "Cộng đồng",
    "Toggle browse": "Bật/tắt duyệt danh mục",
    "Support": "Hỗ trợ kỹ thuật",
    "Supervisor": "Giám sát viên",

    # --- Tim kiem, loc va thao tac bang du lieu ---
    "Clear search": "Xóa bộ lọc tìm kiếm",
    "Filter list": "Lọc danh sách",
    "Close the panel": "Đóng bảng điều khiển",
    "Pin this panel for the current page": "Ghim bảng này cho trang hiện tại",
    "Manage all saved searches": "Quản lý tìm kiếm đã lưu",
    "Show saved searches": "Hiển thị tìm kiếm đã lưu",
    "Save current search": "Lưu tìm kiếm hiện tại",
    "Reset sort": "Đặt lại sắp xếp",
    "Delete a rule": "Xóa quy tắc",
    "Delete a sort": "Xóa sắp xếp",
    "Show the trashbin": "Hiển thị thùng rác",
    "Show as table": "Hiển thị dạng bảng",
    "Show as map": "Hiển thị dạng bản đồ",
    "Select item": "Chọn mục",
    "Landscape PDF": "PDF khổ ngang",
    "Portrait PDF": "PDF khổ dọc",
    "Filter": "Lọc",
    "Reload": "Tải lại",
    "Apply": "Áp dụng",
    "Submit": "Gửi",
    "Upload": "Tải lên",
    "Approve": "Phê duyệt",
    "Refuse": "Từ chối",
    "Accept": "Chấp nhận",
    "Remove": "Gỡ bỏ",
    "Lock": "Khoá",
    "Verify": "Xác minh",
    "Configure": "Cấu hình",
    "Log in": "Đăng nhập",
    "Skip": "Bỏ qua",
    "Expand": "Mở rộng",
    "Collapse": "Thu gọn",
    "Show all": "Hiển thị tất cả",
    "View all": "Xem tất cả",
    "Close window": "Đóng cửa sổ",
    "Direct link": "Liên kết trực tiếp",
    "All items": "Tất cả các mục",
    "Global search": "Tìm kiếm toàn cục",

    # --- Tieu chi tim kiem & Thuoc tinh phieu (Ticket Criteria) ---
    "Answers": "Câu trả lời",
    "Child tickets": "Phiếu con",
    "Parent tickets": "Phiếu cha",
    "External ID": "Mã định danh bên ngoài",
    "Product ID": "Mã sản phẩm",
    "Device id": "Mã thiết bị",
    "Reservable": "Có thể đặt mượn",
    "Any solution status": "Mọi trạng thái giải pháp",
    "Last solution status": "Trạng thái giải pháp cuối",
    "Approval status by users": "Trạng thái phê duyệt của người dùng",
    "Approver group": "Nhóm phê duyệt",
    "Approver substitute": "Người phê duyệt thay thế",
    "Technician in charge": "Kỹ thuật viên phụ trách",
    "Town": "Tỉnh / Thành phố",
    "is empty": "đang trống",
    "Last name": "Họ",
    "Last contact": "Liên lạc cuối",
    "Last boot date": "Ngày khởi động cuối",
    "Last inventory date": "Ngày kiểm kê cuối",
    "Substitution start date": "Ngày bắt đầu thay thế",
    "Substitution end date": "Ngày kết thúc thay thế",
    "Synchronization field": "Trường đồng bộ hóa",
    "Recursive membership": "Thành viên đệ quy",

    # --- Phan cung, mang & Bao mat thiet bi ---
    "Encryption algorithm": "Thuật toán mã hóa",
    "Encryption status": "Trạng thái mã hóa",
    "Encryption tool": "Công cụ mã hóa",
    "Encryption type": "Loại mã hóa",
    "Ethernet socket": "Cổng Ethernet",
    "Network fiber socket": "Cổng cáp quang",
    "Wiring side": "Phía đấu dây",
    "processor number": "Số bộ vi xử lý",
    "Public contact address": "Địa chỉ liên hệ công khai",
    "global rule": "quy tắc toàn cục",
    "group": "nhóm",
    "rule": "quy tắc",
    "Useragent": "Tác nhân người dùng",

    # --- Tab chi tiet thiet bi (Computer / Asset Details) ---
    "Add a domain": "Thêm tên miền",
    "Add a line": "Thêm một dòng",
    "Add note": "Thêm ghi chú",
    "Amend comment": "Sửa bình luận",
    "Associate to an appliance": "Liên kết với thiết bị ứng dụng",
    "Clone": "Tạo bản sao",
    "Create template": "Tạo biểu mẫu mẫu",
    "Impact analysis": "Phân tích tác động",
    "Remote management": "Quản lý từ xa",
    "Remove from a rack": "Gỡ khỏi tủ rack",
    "Virtualization": "Ảo hóa",
    "Add a component": "Thêm một thành phần",
    "Add a description": "Thêm mô tả",
    "Add a comment": "Thêm bình luận",
    "Add a contract": "Thêm hợp đồng",
    "Add a document": "Thêm tài liệu",
    "Add a link": "Thêm liên kết",
    "Add a network port": "Thêm cổng mạng",
    "Add a software": "Thêm phần mềm",
    "Add an item": "Thêm một mục",
    "Add a note": "Thêm một ghi chú",
    "Add a filter": "Thêm một bộ lọc",
    "Add a section": "Thêm một mục",
    "Add a question": "Thêm một câu hỏi",
    "Add a template": "Thêm một mẫu",
    "Add a solution": "Thêm một giải pháp",
    "Add a licence": "Thêm một giấy phép",
    "Add a calendar": "Thêm một lịch",
    "Add a dashboard": "Thêm một bảng điều khiển",

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
    """
    Trich gia tri cua msgid/msgstr (co the nhieu dong noi tiep).

    VI SAO NOI BANG CHUOI RONG (khong phai dau cach):
      Dinh dang .po cho phep cat mot chuoi dai qua nhieu dong:
          msgid ""
          "The assignment of a SLA to a ticket causes the recalculation "
          "of the date."
      Cac manh nay noi lai KHONG co phan cach nao. Dong dau tien lai luon
      rong (""), nen neu noi bang dau cach thi moi khoa sinh ra deu bi them
      mot dau cach o dau (" The assignment..."). Khoa do khong bao gio khop
      khi GLPI tra cuu -> ban dich nam trong .mo nhung khong dung duoc.
      Do duoc: 41 entry nhu vay trong ban vi_VN cua GLPI.
    """
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
    # .strip('"') go cap nhay ngoai cung; giu nguyen khoang trang BEN TRONG
    # chuoi vi chung la mot phan cua ban dich ("Hello " + "World").
    return ''.join(g.strip().strip('"') for g in gtri)


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
    do_dai = []                      # do dai THAT (byte) cua tung msgid

    # Entry dau tien la header (msgid rong)
    msgid_blob += b'\x00'
    msgstr_blob += header.encode('utf-8') + b'\x00'
    offsets.append((0, 0, len(header.encode('utf-8'))))
    do_dai.append(0)                 # msgid rong -> do dai 0

    for msgid, msgstr in items:
        id_b = msgid.encode('utf-8')
        str_b = msgstr.encode('utf-8')
        offsets.append((
            len(msgid_blob),
            len(msgstr_blob),
            len(str_b),
        ))
        do_dai.append(len(id_b))
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
    #
    # CANH BAO — LOI DA GAP THAT:
    #   Truong 'offset' trong bang phai la vi tri TUYET DOI tinh tu DAU FILE,
    #   khong phai vi tri tuong doi trong blob. Ban dau ham nay ghi offset
    #   tuong doi, sinh ra file .mo ma Python gettext KHONG doc duoc
    #   (UnicodeDecodeError ngay dong dau) va GLPI am tham bo qua.
    #   Vi vay phai cong them moc bat dau cua tung blob.
    blob_id_start = off_trans_tbl + tong * 8
    blob_str_start = blob_id_start + len(msgid_blob)

    orig_tbl = b''
    trans_tbl = b''
    for idx in range(tong):
        o_id, o_str, ln_str = offsets[idx]
        do_dai_id = do_dai[idx]
        orig_tbl += struct.pack('<2I', do_dai_id, blob_id_start + o_id)
        trans_tbl += struct.pack('<2I', ln_str, blob_str_start + o_str)

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

    # Console Windows (cp1252/cp437) khong in duoc dau tieng Viet -> ep UTF-8
    # de dong "Thu dich" khong lam script chet giua chung.
    try:
        sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    except (AttributeError, ValueError):
        pass

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
        glpi_container = os.environ.get('GLPI_CONTAINER', 'pinedesk-glpi')
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
    print()
    print('  CANH BAO — DAY KHONG PHAI BUOC CUOI CUNG.')
    print('  File vua tao la LOP PHU (chi chua chuoi moi/ghi de), KHONG phai')
    print('  catalog day du. Cai thang lop phu nay de len vi tri catalog goc se')
    print('  LAM MAT ~2000 chuoi da dich chinh thuc cua GLPI.')
    print()
    print('  BUOC TIEP THEO — gop lop phu vao catalog day du:')
    print('    python scripts/tao-mo-bo-sung.py')
    print('    python scripts/gop-ban-dich-tieng-viet.py')
    print()


def kiem_tra_mo(duong_dan):
    """
    Doc lai file .mo bang chinh bo doc gettext cua Python.

    VI SAO KHONG TU DOC BANG TAY:
      Ban truoc tu doc offset va luon tra ve True, nen mot file .mo hong
      (offset tuong doi thay vi tuyet doi) VAN BAO "HOP LE" — trong khi
      gettext that su nem UnicodeDecodeError. Dung gettext.GNUTranslations
      de kiem tra dung cai ma GLPI se dung.
    """
    try:
        with open(duong_dan, 'rb') as f:
            dich = gettext.GNUTranslations(f)

        # Vai chuoi chot: phai dich duoc, va ban dich phai KHAC ban goc.
        for goc, mong_doi in (
            ('Computer', 'Máy tính'),
            ('Status', 'Trạng thái'),
            ('Time to resolve', 'Thời gian giải quyết'),
        ):
            ket_qua = dich.gettext(goc)
            if ket_qua == goc:
                print(f'       [LOI] "{goc}" khong duoc dich (van la tieng Anh)')
                return False
            print(f'       Thu dich: "{goc}" => "{ket_qua}"')
        return True
    except Exception as e:
        print(f'       Loi doc file: {type(e).__name__}: {e}')
        return False


if __name__ == '__main__':
    main()
