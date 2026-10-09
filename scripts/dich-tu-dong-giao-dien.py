import sys
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
================================================================================
 DICH TU DONG GIAO DIEN GLPI SANG TIENG VIET
================================================================================
 Do an thuc tap: Xay dung he thong ho tro ky thuat (PineDesk) - DH Da Lat

 BOI CANH:
   GLPI 11 chi dong goi ~30% ban dich tieng Viet chinh thuc (1941/6511 chuoi).
   Phan con thieu chu yeu la cac nhan giao dien ngan gon lap di lap lai
   ("Add a user", "Delete", "Search", "Network", ...) va cac thong bao
   ky thuat noi bo.

 CHIEN LUOC:
   Script nay dich theo 3 tang, uu tien tu cao xuong thap:

   TANG 1 — TU DIEN LOI (tu dien chinh xac cao)
     Cac tu/cum tu giao dien pho bien nhat: Add, Delete, Update, Search,
     Computer, Ticket, Network, ... (~400 muc)

   TANG 2 — MAU CAU TRUC (sinh tu dong)
     Cac khuon mau lap lai nhieu lan trong GLPI:
       "Add a X"        -> "Thêm X"
       "Add an X"       -> "Thêm X"
       "Delete a X"     -> "Xoá X"
       "X management"   -> "Quản lý X"
       "New X"          -> "X mới"
       "X list"         -> "Danh sách X"
       "Show X"         -> "Hiển thị X"
       "No X"           -> "Không có X"
     trong do X duoc tra tu TU DIEN LOI. Cach nay phu duoc hang tram chuoi
     chi voi vai chuc muc tu dien.

   TANG 3 — BO QUA
     Cac chuoi ky thuat noi bo (loi migration, tham so dong lenh, canh bao
     PHP/LDAP, chuoi co bien dinh dang phuc tap) se DUOC GIU NGUYEN tieng Anh
     de tranh dich sai gay hieu nham khi van hanh he thong.

 KET QUA: ghi vao file .mo bo sung, sau do gop bang:
     python scripts/gop-ban-dich-tieng-viet.py

 CHAY:
   python scripts/dich-tu-dong-giao-dien.py
   python scripts/dich-tu-dong-giao-dien.py --xem-truoc   # chi xem, khong ghi
================================================================================
"""
import os
import re
import struct
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
TMP = os.path.join(ROOT, '.tmp-locale')
GLPI_CONTAINER = os.environ.get('GLPI_CONTAINER', 'pinedesk-glpi')

MO_DICH = '/var/glpi/files/_locales/core/vi_VN.mo'
MO_RA = os.path.join(TMP, 'vi_VN_auto.mo')
DICH_CONTAINER = '/var/glpi/files/_locales/bo_sung/vi_VN.mo'

GREEN = '\033[0;32m'; YELLOW = '\033[1;33m'; RED = '\033[0;31m'
CYAN = '\033[0;36m'; BOLD = '\033[1m'; NC = '\033[0m'


def ok(m):   print(f'{GREEN}[ OK ]{NC} {m}')
def info(m): print(f'{CYAN}[INFO]{NC} {m}')
def warn(m): print(f'{YELLOW}[CANH BAO]{NC} {m}')
def err(m):  print(f'{RED}[LOI]{NC} {m}')


# =============================================================================
#  TANG 1 — TU DIEN LOI
#  Cac tu/cum tu giao dien xuat hien nhieu nhat trong GLPI.
#  Sap xep theo chu de de de bao tri.
# =============================================================================
TU_DIEN = {
    # ---------- Dong tu hanh dong (nhieu nhat) ----------
    'Add': 'Thêm',
    'Add a': 'Thêm một',
    'Add an': 'Thêm một',
    'Create': 'Tạo',
    'Update': 'Cập nhật',
    'Delete': 'Xoá',
    'Remove': 'Gỡ bỏ',
    'Edit': 'Sửa',
    'Modify': 'Chỉnh sửa',
    'Save': 'Lưu',
    'Cancel': 'Huỷ',
    'Close': 'Đóng',
    'Open': 'Mở',
    'Confirm': 'Xác nhận',
    'Accept': 'Chấp nhận',
    'Reject': 'Từ chối',
    'Refuse': 'Từ chối',
    'Approve': 'Phê duyệt',
    'Validate': 'Xác nhận',
    'Search': 'Tìm kiếm',
    'Select': 'Chọn',
    'Choose': 'Chọn',
    'Show': 'Hiển thị',
    'Hide': 'Ẩn',
    'Display': 'Hiển thị',
    'Import': 'Nhập dữ liệu',
    'Export': 'Xuất dữ liệu',
    'Upload': 'Tải lên',
    'Download': 'Tải xuống',
    'Print': 'In',
    'Copy': 'Sao chép',
    'Move': 'Di chuyển',
    'Duplicate': 'Nhân bản',
    'Restore': 'Phục hồi',
    'Enable': 'Bật',
    'Disable': 'Tắt',
    'Activate': 'Kích hoạt',
    'Deactivate': 'Vô hiệu hoá',
    'Install': 'Cài đặt',
    'Uninstall': 'Gỡ cài đặt',
    'Send': 'Gửi',
    'Submit': 'Gửi',
    'Apply': 'Áp dụng',
    'Reset': 'Đặt lại',
    'Refresh': 'Làm mới',
    'Reload': 'Tải lại',
    'Filter': 'Lọc',
    'Sort': 'Sắp xếp',
    'Connect': 'Kết nối',
    'Disconnect': 'Ngắt kết nối',
    'Lock': 'Khoá',
    'Unlock': 'Mở khoá',
    'Assign': 'Phân công',
    'Unassign': 'Bỏ phân công',
    'Merge': 'Gộp',
    'Split': 'Tách',
    'Test': 'Kiểm tra',
    'Verify': 'Xác minh',
    'Check': 'Kiểm tra',
    'Configure': 'Cấu hình',
    'Customize': 'Tuỳ chỉnh',
    'Generate': 'Tạo',
    'Preview': 'Xem trước',
    'View': 'Xem',
    'Manage': 'Quản lý',
    'Track': 'Theo dõi',
    'Follow': 'Theo dõi',
    'Subscribe': 'Đăng ký theo dõi',
    'Unsubscribe': 'Bỏ theo dõi',
    'Sign in': 'Đăng nhập',
    'Sign out': 'Đăng xuất',
    'Log in': 'Đăng nhập',
    'Log out': 'Đăng xuất',
    'Login': 'Tên đăng nhập',
    'Logout': 'Đăng xuất',
    'Register': 'Đăng ký',
    'Continue': 'Tiếp tục',
    'Finish': 'Hoàn tất',
    'Start': 'Bắt đầu',
    'Stop': 'Dừng',
    'Restart': 'Khởi động lại',
    'Pause': 'Tạm dừng',
    'Resume': 'Tiếp tục',
    'Retry': 'Thử lại',
    'Skip': 'Bỏ qua',
    'Back': 'Quay lại',
    'Next': 'Tiếp',
    'Previous': 'Trước',
    'Expand': 'Mở rộng',
    'Collapse': 'Thu gọn',
    'Select all': 'Chọn tất cả',
    'Deselect all': 'Bỏ chọn tất cả',
    'Select a file': 'Chọn một tệp',
    'Add a file': 'Thêm một tệp',
    'Add a note': 'Thêm một ghi chú',
    'Add a comment': 'Thêm một bình luận',
    'Add a task': 'Thêm một công việc',
    'Add a document': 'Thêm một tài liệu',
    'Add a filter': 'Thêm một bộ lọc',
    'Add a criteria': 'Thêm một tiêu chí',
    'Add a section': 'Thêm một mục',
    'Add a question': 'Thêm một câu hỏi',
    'Add a template': 'Thêm một mẫu',
    'Add a version': 'Thêm một phiên bản',
    'Add a description': 'Thêm một mô tả',
    'Add a solution': 'Thêm một giải pháp',
    'Add a user': 'Thêm một người dùng',
    'Add a group': 'Thêm một nhóm',
    'Add a licence': 'Thêm một giấy phép',
    'Add a license': 'Thêm một giấy phép',
    'Add a contract': 'Thêm một hợp đồng',
    'Add a calendar': 'Thêm một lịch',
    'Add a dashboard': 'Thêm một bảng điều khiển',
    'Add a database': 'Thêm một cơ sở dữ liệu',
    'Add a domain': 'Thêm một miền',
    'Add a manager': 'Thêm một người quản lý',
    'Add a delegatee': 'Thêm một người được uỷ quyền',
    'Add a component': 'Thêm một thành phần',
    'Add a line': 'Thêm một dòng',
    'Add a slot': 'Thêm một khe cắm',
    'Add a card': 'Thêm một thẻ',
    'Add a version': 'Thêm một phiên bản',
    'Add an alert': 'Thêm một cảnh báo',
    'Add an answer': 'Thêm một câu trả lời',
    'Add an event': 'Thêm một sự kiện',
    'Add a URI': 'Thêm một URI',
    'Add a PDU': 'Thêm một PDU',
    'Add another criteria': 'Thêm tiêu chí khác',
    'Add another sort': 'Thêm sắp xếp khác',
    'Add column': 'Thêm cột',
    'Add filter': 'Thêm bộ lọc',
    'Add global lock': 'Thêm khoá toàn cục',
    'Add group': 'Thêm nhóm',
    'Add language': 'Thêm ngôn ngữ',
    'Add more fields': 'Thêm trường',
    'Add asset': 'Thêm tài sản',
    'Add assets': 'Thêm tài sản',
    'Add component': 'Thêm thành phần',
    'Add consumables': 'Thêm vật tư tiêu hao',
    'Add contract': 'Thêm hợp đồng',
    'Add documents': 'Thêm tài liệu',

    # ---------- Danh tu nghiep vu (doi tuong GLPI) ----------
    'Assets': 'Tài sản',
    'Asset': 'Tài sản',
    'Computer': 'Máy tính',
    'Computers': 'Máy tính',
    'Monitor': 'Màn hình',
    'Monitors': 'Màn hình',
    'Printer': 'Máy in',
    'Printers': 'Máy in',
    'Peripheral': 'Thiết bị ngoại vi',
    'Peripherals': 'Thiết bị ngoại vi',
    'Phone': 'Điện thoại',
    'Phones': 'Điện thoại',
    'Network device': 'Thiết bị mạng',
    'Network devices': 'Thiết bị mạng',
    'Network': 'Mạng',
    'Networks': 'Mạng',
    'Software': 'Phần mềm',
    'Software version': 'Phiên bản phần mềm',
    'License': 'Giấy phép',
    'Licence': 'Giấy phép',
    'Licenses': 'Giấy phép',
    'Licences': 'Giấy phép',
    'Device': 'Thiết bị',
    'Devices': 'Thiết bị',
    'Equipment': 'Trang thiết bị',
    'Hardware': 'Phần cứng',
    'Component': 'Thành phần',
    'Components': 'Thành phần',
    'Consumable': 'Vật tư tiêu hao',
    'Consumables': 'Vật tư tiêu hao',
    'Cartridge': 'Hộp mực',
    'Ticket': 'Phiếu yêu cầu',
    'Tickets': 'Phiếu yêu cầu',
    'Problem': 'Vấn đề',
    'Problems': 'Vấn đề',
    'Change': 'Thay đổi',
    'Changes': 'Thay đổi',
    'Incident': 'Sự cố',
    'Incidents': 'Sự cố',
    'Request': 'Yêu cầu',
    'Requests': 'Yêu cầu',
    'Assistance': 'Hỗ trợ',
    'Helpdesk': 'Bộ phận hỗ trợ',
    'Service desk': 'Bộ phận hỗ trợ',
    'Maintenance': 'Bảo trì',
    'Contract': 'Hợp đồng',
    'Contracts': 'Hợp đồng',
    'Supplier': 'Nhà cung cấp',
    'Suppliers': 'Nhà cung cấp',
    'Manufacturer': 'Nhà sản xuất',
    'Manufacturers': 'Nhà sản xuất',
    'Warranty': 'Bảo hành',
    'Budget': 'Ngân sách',
    'Budgets': 'Ngân sách',
    'Cost': 'Chi phí',
    'Costs': 'Chi phí',
    'Location': 'Vị trí',
    'Locations': 'Vị trí',
    'Room': 'Phòng',
    'Rooms': 'Phòng',
    'Building': 'Toà nhà',
    'Building': 'Toà nhà',
    'Floor': 'Tầng',
    'State': 'Trạng thái',
    'States': 'Trạng thái',
    'Status': 'Trạng thái',
    'Category': 'Danh mục',
    'Categories': 'Danh mục',
    'Type': 'Loại',
    'Types': 'Loại',
    'Model': 'Model',
    'Models': 'Model',
    'Brand': 'Thương hiệu',
    'Manufacturer': 'Nhà sản xuất',
    'Serial number': 'Số sê-ri',
    'Inventory number': 'Mã tài sản',
    'Tag': 'Thẻ',
    'Tags': 'Thẻ',
    'Comment': 'Bình luận',
    'Comments': 'Bình luận',
    'Note': 'Ghi chú',
    'Notes': 'Ghi chú',
    'Description': 'Mô tả',
    'Title': 'Tiêu đề',
    'Name': 'Tên',
    'Date': 'Ngày',
    'Dates': 'Ngày',
    'Time': 'Thời gian',
    'Duration': 'Thời lượng',
    'Priority': 'Độ ưu tiên',
    'Urgency': 'Độ khẩn cấp',
    'Impact': 'Mức ảnh hưởng',
    'Severity': 'Mức nghiêm trọng',
    'Level': 'Mức',
    'Result': 'Kết quả',
    'Results': 'Kết quả',
    'Solution': 'Giải pháp',
    'Solutions': 'Giải pháp',
    'Task': 'Công việc',
    'Tasks': 'Công việc',
    'Planning': 'Kế hoạch',
    'Calendar': 'Lịch',
    'Event': 'Sự kiện',
    'Events': 'Sự kiện',
    'Document': 'Tài liệu',
    'Documents': 'Tài liệu',
    'File': 'Tệp',
    'Files': 'Tệp',
    'Attachment': 'Tệp đính kèm',
    'Attachments': 'Tệp đính kèm',
    'User': 'Người dùng',
    'Users': 'Người dùng',
    'Group': 'Nhóm',
    'Groups': 'Nhóm',
    'Team': 'Nhóm',
    'Profile': 'Hồ sơ quyền',
    'Profiles': 'Hồ sơ quyền',
    'Entity': 'Đơn vị',
    'Entities': 'Đơn vị',
    'Rule': 'Quy tắc',
    'Rules': 'Quy tắc',
    'Notification': 'Thông báo',
    'Notifications': 'Thông báo',
    'Email': 'Thư điện tử',
    'Password': 'Mật khẩu',
    'Role': 'Vai trò',
    'Roles': 'Vai trò',
    'Right': 'Quyền',
    'Rights': 'Quyền',
    'Permission': 'Quyền',
    'Permissions': 'Quyền',
    'Log': 'Nhật ký',
    'Logs': 'Nhật ký',
    'History': 'Lịch sử',
    'Report': 'Báo cáo',
    'Reports': 'Báo cáo',
    'Dashboard': 'Bảng điều khiển',
    'Statistics': 'Thống kê',
    'Chart': 'Biểu đồ',
    'Charts': 'Biểu đồ',
    'Summary': 'Tổng quan',
    'Setting': 'Thiết lập',
    'Settings': 'Thiết lập',
    'Configuration': 'Cấu hình',
    'Parameter': 'Tham số',
    'Parameters': 'Tham số',
    'Option': 'Tuỳ chọn',
    'Options': 'Tuỳ chọn',
    'Field': 'Trường',
    'Fields': 'Trường',
    'Column': 'Cột',
    'Columns': 'Cột',
    'Row': 'Dòng',
    'Rows': 'Dòng',
    'Table': 'Bảng',
    'Tables': 'Bảng',
    'Database': 'Cơ sở dữ liệu',
    'Server': 'Máy chủ',
    'Client': 'Máy khách',
    'Account': 'Tài khoản',
    'Accounts': 'Tài khoản',
    'Address': 'Địa chỉ',
    'Phone number': 'Số điện thoại',
    'Mobile': 'Di động',
    'Fax': 'Fax',
    'Website': 'Trang web',
    'URL': 'Đường dẫn',
    'IP address': 'Địa chỉ IP',
    'MAC address': 'Địa chỉ MAC',
    'Port': 'Cổng',
    'Protocol': 'Giao thức',
    'Domain': 'Miền',
    'Subnet': 'Mạng con',
    'VLAN': 'VLAN',
    'Switch': 'Bộ chuyển mạch',
    'Router': 'Bộ định tuyến',
    'Firewall': 'Tường lửa',
    'Access point': 'Điểm truy cập',
    'Socket': 'Ổ cắm mạng',
    'Cable': 'Cáp',
    'Power supply': 'Bộ nguồn',
    'Battery': 'Pin',
    'Memory': 'Bộ nhớ',
    'Processor': 'Bộ xử lý',
    'Storage': 'Lưu trữ',
    'Disk': 'Ổ đĩa',
    'Operating system': 'Hệ điều hành',
    'Antivirus': 'Phần mềm diệt virus',
    'Application': 'Ứng dụng',
    'Version': 'Phiên bản',
    'Backup': 'Sao lưu',
    'Update': 'Cập nhật',
    'Upgrade': 'Nâng cấp',
    'Migration': 'Di trú dữ liệu',
    'Plugin': 'Tiện ích mở rộng',
    'Plugins': 'Tiện ích mở rộng',
    'Marketplace': 'Kho tiện ích',
    'Module': 'Mô-đun',
    'Template': 'Mẫu',
    'Templates': 'Mẫu',
    'Form': 'Biểu mẫu',
    'Forms': 'Biểu mẫu',
    'Question': 'Câu hỏi',
    'Questions': 'Câu hỏi',
    'Answer': 'Câu trả lời',
    'Answers': 'Câu trả lời',
    'Section': 'Mục',
    'Sections': 'Mục',
    'Approval': 'Phê duyệt',
    'Approvals': 'Phê duyệt',
    'Validation': 'Xác nhận',
    'Actor': 'Người tham gia',
    'Actors': 'Người tham gia',
    'Requester': 'Người yêu cầu',
    'Observer': 'Người theo dõi',
    'Technician': 'Kỹ thuật viên',
    'Supervisor': 'Người giám sát',
    'Administrator': 'Quản trị viên',
    'Admin': 'Quản trị',
    'Root': 'Gốc',

    # ---------- Trang thai / ket qua ----------
    'Active': 'Đang hoạt động',
    'Inactive': 'Ngừng hoạt động',
    'Enabled': 'Đã bật',
    'Disabled': 'Đã tắt',
    'New': 'Mới',
    'Old': 'Cũ',
    'Pending': 'Đang chờ',
    'Planned': 'Đã lên kế hoạch',
    'Assigned': 'Đã phân công',
    'Solved': 'Đã giải quyết',
    'Closed': 'Đã đóng',
    'Opened': 'Đã mở',
    'Processing': 'Đang xử lý',
    'In progress': 'Đang thực hiện',
    'Completed': 'Đã hoàn thành',
    'Finished': 'Đã xong',
    'Cancelled': 'Đã huỷ',
    'Canceled': 'Đã huỷ',
    'Aborted': 'Đã hủy bỏ',
    'Failed': 'Thất bại',
    'Success': 'Thành công',
    'Error': 'Lỗi',
    'Warning': 'Cảnh báo',
    'Warning': 'Cảnh báo',
    'Critical': 'Nghiêm trọng',
    'High': 'Cao',
    'Medium': 'Trung bình',
    'Low': 'Thấp',
    'Very high': 'Rất cao',
    'Very low': 'Rất thấp',
    'Normal': 'Bình thường',
    'Default': 'Mặc định',
    'Automatic': 'Tự động',
    'Manual': 'Thủ công',
    'Yes': 'Có',
    'No': 'Không',
    'None': 'Không có',
    'All': 'Tất cả',
    'Any': 'Bất kỳ',
    'Other': 'Khác',
    'Others': 'Khác',
    'Unknown': 'Không rõ',
    'Empty': 'Trống',
    'Full': 'Đầy đủ',
    'Optional': 'Không bắt buộc',
    'Required': 'Bắt buộc',
    'Mandatory': 'Bắt buộc',
    'Private': 'Riêng tư',
    'Public': 'Công khai',
    'Visible': 'Hiển thị',
    'Hidden': 'Đã ẩn',
    'Valid': 'Hợp lệ',
    'Invalid': 'Không hợp lệ',
    'Available': 'Có sẵn',
    'Unavailable': 'Không có sẵn',
    'Used': 'Đã dùng',
    'Free': 'Trống',
    'Total': 'Tổng cộng',
    'Count': 'Số lượng',
    'Number': 'Số',
    'Quantity': 'Số lượng',
    'Amount': 'Số tiền',
    'Percentage': 'Tỷ lệ phần trăm',
    'Average': 'Trung bình',
    'Minimum': 'Tối thiểu',
    'Maximum': 'Tối đa',

    # ---------- Thoi gian ----------
    'Day': 'Ngày',
    'Days': 'Ngày',
    'Week': 'Tuần',
    'Weeks': 'Tuần',
    'Month': 'Tháng',
    'Months': 'Tháng',
    'Year': 'Năm',
    'Years': 'Năm',
    'Hour': 'Giờ',
    'Hours': 'Giờ',
    'Minute': 'Phút',
    'Minutes': 'Phút',
    'Second': 'Giây',
    'Seconds': 'Giây',
    'Today': 'Hôm nay',
    'Yesterday': 'Hôm qua',
    'Tomorrow': 'Ngày mai',
    'Now': 'Bây giờ',
    'Never': 'Không bao giờ',
    'Always': 'Luôn luôn',
    'Sometimes': 'Thỉnh thoảng',
    'Frequently': 'Thường xuyên',
    'Monthly': 'Hàng tháng',
    'Weekly': 'Hàng tuần',
    'Daily': 'Hàng ngày',
    'Yearly': 'Hàng năm',
    'Annual': 'Hàng năm',
    'Begin date': 'Ngày bắt đầu',
    'End date': 'Ngày kết thúc',
    'Start date': 'Ngày bắt đầu',
    'Due date': 'Ngày đến hạn',
    'Creation date': 'Ngày tạo',
    'Update date': 'Ngày cập nhật',
    'Last update': 'Cập nhật lần cuối',
    'Last modification': 'Sửa đổi lần cuối',
    'Expiration date': 'Ngày hết hạn',
    'Next': 'Tiếp theo',
    'Last': 'Cuối cùng',
    'First': 'Đầu tiên',

    # ---------- Giao dien / dieu huong ----------
    'Home': 'Trang chủ',
    'Dashboard': 'Bảng điều khiển',
    'Menu': 'Trình đơn',
    'Navigation': 'Điều hướng',
    'Preferences': 'Tuỳ chọn cá nhân',
    'My settings': 'Thiết lập của tôi',
    'My profile': 'Hồ sơ của tôi',
    'My account': 'Tài khoản của tôi',
    'Notifications': 'Thông báo',
    'Messages': 'Tin nhắn',
    'Message': 'Tin nhắn',
    'Help': 'Trợ giúp',
    'About': 'Giới thiệu',
    'Contact': 'Liên hệ',
    'Support': 'Hỗ trợ',
    'Documentation': 'Tài liệu hướng dẫn',
    'Manual': 'Hướng dẫn sử dụng',
    'User manual': 'Hướng dẫn sử dụng',
    'Getting started': 'Bắt đầu',
    'Tutorial': 'Hướng dẫn',
    'Example': 'Ví dụ',
    'Examples': 'Ví dụ',
    'Sample': 'Mẫu',
    'List': 'Danh sách',
    'Lists': 'Danh sách',
    'Details': 'Chi tiết',
    'Detail': 'Chi tiết',
    'Overview': 'Tổng quan',
    'Information': 'Thông tin',
    'Informations': 'Thông tin',
    'General': 'Chung',
    'Advanced': 'Nâng cao',
    'Basic': 'Cơ bản',
    'Simple': 'Đơn giản',
    'Custom': 'Tuỳ chỉnh',
    'Personal': 'Cá nhân',
    'Global': 'Toàn cục',
    'Local': 'Cục bộ',
    'Main': 'Chính',
    'Additional': 'Bổ sung',
    'Extra': 'Thêm',
    'Related': 'Liên quan',
    'Linked': 'Đã liên kết',
    'Children': 'Cấp con',
    'Parent': 'Cấp cha',
    'Sub-item': 'Mục con',
    'Root': 'Gốc',
    'Path': 'Đường dẫn',
    'Size': 'Kích thước',
    'Format': 'Định dạng',
    'Source': 'Nguồn',
    'Target': 'Đích',
    'Origin': 'Xuất xứ',
    'Destination': 'Điểm đến',
    'From': 'Từ',
    'To': 'Đến',
    'By': 'Bởi',
    'On': 'Vào',
    'At': 'Lúc',
    'In': 'Trong',
    'Out': 'Ngoài',
    'With': 'Với',
    'Without': 'Không có',
    'And': 'Và',
    'Or': 'Hoặc',
    'Not': 'Không',
    'If': 'Nếu',
    'Then': 'Thì',
    'Else': 'Ngược lại',
    'When': 'Khi',
    'Where': 'Ở đâu',
    'Why': 'Tại sao',
    'How': 'Như thế nào',
    'What': 'Cái gì',
    'Which': 'Cái nào',
    'Who': 'Ai',
    'Total': 'Tổng',
    'Count': 'Đếm',
    'Page': 'Trang',
    'Pages': 'Trang',
    'Item': 'Mục',
    'Items': 'Mục',
    'Record': 'Bản ghi',
    'Records': 'Bản ghi',
    'Entry': 'Mục nhập',
    'Entries': 'Mục nhập',
    'Value': 'Giá trị',
    'Values': 'Giá trị',
    'Key': 'Khoá',
    'Keys': 'Khoá',
    'Label': 'Nhãn',
    'Labels': 'Nhãn',
    'Text': 'Văn bản',
    'Number': 'Số',
    'Date': 'Ngày',
    'Boolean': 'Đúng/Sai',
    'Dropdown': 'Danh sách chọn',
    'Checkbox': 'Hộp kiểm',
    'Button': 'Nút',
    'Buttons': 'Nút',
    'Link': 'Liên kết',
    'Links': 'Liên kết',
    'Icon': 'Biểu tượng',
    'Icons': 'Biểu tượng',
    'Image': 'Hình ảnh',
    'Images': 'Hình ảnh',
    'Logo': 'Biểu trưng',
    'Color': 'Màu sắc',
    'Colors': 'Màu sắc',
    'Theme': 'Giao diện',
    'Palette': 'Bảng màu',
    'Layout': 'Bố cục',
    'Design': 'Thiết kế',
    'Style': 'Kiểu',
    'Language': 'Ngôn ngữ',
    'Languages': 'Ngôn ngữ',
    'Translation': 'Bản dịch',
    'Translations': 'Bản dịch',
    'Vietnamese': 'Tiếng Việt',
    'English': 'Tiếng Anh',
    'French': 'Tiếng Pháp',

    # ---------- Trang thai thao tac ----------
    'Loading': 'Đang tải',
    'Saving': 'Đang lưu',
    'Processing': 'Đang xử lý',
    'Searching': 'Đang tìm kiếm',
    'No result': 'Không có kết quả',
    'No results': 'Không có kết quả',
    'No data': 'Không có dữ liệu',
    'No item': 'Không có mục nào',
    'No items': 'Không có mục nào',
    'No record': 'Không có bản ghi',
    'No records': 'Không có bản ghi',
    'Not found': 'Không tìm thấy',
    'Not available': 'Không có sẵn',
    'Not set': 'Chưa đặt',
    'Not defined': 'Chưa xác định',
    'Not applicable': 'Không áp dụng',
    'Empty list': 'Danh sách trống',
    'Are you sure?': 'Bạn có chắc chắn không?',
    'Are you sure you want to delete this item?': 'Bạn có chắc chắn muốn xoá mục này không?',
    'Yes, delete': 'Có, xoá',
    'No, cancel': 'Không, huỷ',
    'Loading...': 'Đang tải...',
    'Please wait': 'Vui lòng đợi',
    'Please wait...': 'Vui lòng đợi...',
    'Successfully saved': 'Đã lưu thành công',
    'Successfully deleted': 'Đã xoá thành công',
    'Successfully updated': 'Đã cập nhật thành công',
    'Successfully created': 'Đã tạo thành công',
    'Successfully added': 'Đã thêm thành công',
    'Save successful': 'Lưu thành công',
    'Delete successful': 'Xoá thành công',
    'Operation successful': 'Thao tác thành công',
    'Operation failed': 'Thao tác thất bại',
    'Access denied': 'Truy cập bị từ chối',
    'Permission denied': 'Không có quyền truy cập',
    'Invalid data': 'Dữ liệu không hợp lệ',
    'Required field': 'Trường bắt buộc',
    'Required fields': 'Các trường bắt buộc',
    'This field is required': 'Trường này là bắt buộc',
    'Field is required': 'Trường là bắt buộc',
    'Please fill in this field': 'Vui lòng điền vào trường này',
    'Please select a value': 'Vui lòng chọn một giá trị',
    'Please select an item': 'Vui lòng chọn một mục',

    # ---------- Cau giao dien thong dung (xuat hien nhieu) ----------
    'Access to this item is restricted': 'Quyền truy cập mục này bị hạn chế',
    'Activate': 'Kích hoạt',
    'Add a new item': 'Thêm mục mới',
    'Add an item': 'Thêm một mục',
    'Add to a group': 'Thêm vào một nhóm',
    'All items': 'Tất cả các mục',
    'All rights reserved': 'Bảo lưu mọi quyền',
    'An error occurred': 'Đã xảy ra lỗi',
    'An unexpected error occurred': 'Đã xảy ra lỗi không mong đợi',
    'Are you sure you want to delete': 'Bạn có chắc chắn muốn xoá',
    'Are you sure you want to delete it?': 'Bạn có chắc chắn muốn xoá nó không?',
    'Are you sure you want to delete this item?': 'Bạn có chắc chắn muốn xoá mục này không?',
    'Are you sure you want to remove this item?': 'Bạn có chắc chắn muốn gỡ mục này không?',
    'Are you sure you want to purge it?': 'Bạn có chắc chắn muốn xoá vĩnh viễn không?',
    'Back to list': 'Quay lại danh sách',
    'Cannot be empty': 'Không được để trống',
    'Change the password': 'Đổi mật khẩu',
    'Change the status': 'Đổi trạng thái',
    'Choose a file': 'Chọn một tệp',
    'Choose a value': 'Chọn một giá trị',
    'Click here': 'Bấm vào đây',
    'Click here to': 'Bấm vào đây để',
    'Close the window': 'Đóng cửa sổ',
    'Configuration saved': 'Đã lưu cấu hình',
    'Creation date': 'Ngày tạo',
    'Current status': 'Trạng thái hiện tại',
    'Date of creation': 'Ngày tạo',
    'Date of modification': 'Ngày sửa đổi',
    'Default value': 'Giá trị mặc định',
    'Delete permanently': 'Xoá vĩnh viễn',
    'Delete this item': 'Xoá mục này',
    'Display the list': 'Hiển thị danh sách',
    'Do you want to continue?': 'Bạn có muốn tiếp tục không?',
    'Do you want to delete it?': 'Bạn có muốn xoá nó không?',
    'Documentation': 'Tài liệu hướng dẫn',
    'Edit the item': 'Sửa mục',
    'Element not found': 'Không tìm thấy phần tử',
    'Email address': 'Địa chỉ thư điện tử',
    'End of list': 'Hết danh sách',
    'Enter a value': 'Nhập một giá trị',
    'Enter the name': 'Nhập tên',
    'Enter your password': 'Nhập mật khẩu của bạn',
    'Enter your username': 'Nhập tên đăng nhập của bạn',
    'Error while saving': 'Lỗi khi lưu',
    'Export to CSV': 'Xuất ra CSV',
    'Export to PDF': 'Xuất ra PDF',
    'Field cannot be empty': 'Trường không được để trống',
    'Filter the results': 'Lọc kết quả',
    'For more information': 'Để biết thêm thông tin',
    'Forgot your password?': 'Quên mật khẩu?',
    'Forgotten password?': 'Quên mật khẩu?',
    'Go back': 'Quay lại',
    'Go to the item': 'Đi đến mục',
    'Here you can': 'Tại đây bạn có thể',
    'If you have any questions': 'Nếu bạn có bất kỳ câu hỏi nào',
    'In order to': 'Để',
    'Insert a new item': 'Chèn mục mới',
    'Invalid email address': 'Địa chỉ thư điện tử không hợp lệ',
    'Invalid password': 'Mật khẩu không hợp lệ',
    'Invalid username': 'Tên đăng nhập không hợp lệ',
    'It is not possible to': 'Không thể',
    'Last update': 'Cập nhật lần cuối',
    'List of items': 'Danh sách các mục',
    'Log in to your account': 'Đăng nhập vào tài khoản của bạn',
    'Login to your account': 'Đăng nhập vào tài khoản của bạn',
    'Login is required': 'Cần đăng nhập',
    'Maximum number of items': 'Số lượng mục tối đa',
    'Minimum number of items': 'Số lượng mục tối thiểu',
    'More information': 'Thông tin thêm',
    'More options': 'Thêm tuỳ chọn',
    'No item found': 'Không tìm thấy mục nào',
    'No items found': 'Không tìm thấy mục nào',
    'No result found': 'Không tìm thấy kết quả',
    'No results found': 'Không tìm thấy kết quả',
    'No data available': 'Không có dữ liệu',
    'No data found': 'Không tìm thấy dữ liệu',
    'No element found': 'Không tìm thấy phần tử',
    'No file selected': 'Chưa chọn tệp',
    'No items to display': 'Không có mục nào để hiển thị',
    'No items selected': 'Chưa chọn mục nào',
    'No results': 'Không có kết quả',
    'Not allowed': 'Không được phép',
    'Not enough rights': 'Không đủ quyền',
    'Number of items': 'Số lượng mục',
    'Number of results': 'Số lượng kết quả',
    'On this page': 'Trên trang này',
    'Once saved': 'Sau khi lưu',
    'Only the administrator can': 'Chỉ quản trị viên mới có thể',
    'Operation completed': 'Thao tác hoàn tất',
    'Optional information': 'Thông tin không bắt buộc',
    'Page not found': 'Không tìm thấy trang',
    'Please choose a value': 'Vui lòng chọn một giá trị',
    'Please confirm': 'Vui lòng xác nhận',
    'Please enter a name': 'Vui lòng nhập tên',
    'Please enter a value': 'Vui lòng nhập một giá trị',
    'Please enter your password': 'Vui lòng nhập mật khẩu của bạn',
    'Please enter your username': 'Vui lòng nhập tên đăng nhập',
    'Please note that': 'Xin lưu ý rằng',
    'Please select a file': 'Vui lòng chọn một tệp',
    'Please select an option': 'Vui lòng chọn một tuỳ chọn',
    'Please wait while': 'Vui lòng đợi trong khi',
    'Preparing the data': 'Đang chuẩn bị dữ liệu',
    'Print the list': 'In danh sách',
    'Purge permanently': 'Xoá vĩnh viễn',
    'Record saved': 'Đã lưu bản ghi',
    'Refresh the page': 'Làm mới trang',
    'Remember me': 'Ghi nhớ tôi',
    'Remove this item': 'Gỡ bỏ mục này',
    'Rights management': 'Quản lý quyền',
    'Save and close': 'Lưu và đóng',
    'Save the changes': 'Lưu các thay đổi',
    'Search in the list': 'Tìm kiếm trong danh sách',
    'Search results': 'Kết quả tìm kiếm',
    'Select a value': 'Chọn một giá trị',
    'Select an option': 'Chọn một tuỳ chọn',
    'Select the file': 'Chọn tệp',
    'Send by email': 'Gửi qua thư điện tử',
    'Show all': 'Hiển thị tất cả',
    'Show less': 'Hiển thị ít hơn',
    'Show more': 'Hiển thị thêm',
    'Sort by': 'Sắp xếp theo',
    'Sort by date': 'Sắp xếp theo ngày',
    'Sort by name': 'Sắp xếp theo tên',
    'Start date': 'Ngày bắt đầu',
    'The item has been saved': 'Mục đã được lưu',
    'The item has been deleted': 'Mục đã bị xoá',
    'The item has been updated': 'Mục đã được cập nhật',
    'The item has been created': 'Mục đã được tạo',
    'The operation failed': 'Thao tác thất bại',
    'The operation was successful': 'Thao tác thành công',
    'The requested page does not exist': 'Trang bạn yêu cầu không tồn tại',
    'There are no items': 'Không có mục nào',
    'There is no result': 'Không có kết quả',
    'This action cannot be undone': 'Thao tác này không thể hoàn tác',
    'This field cannot be empty': 'Trường này không được để trống',
    'This item cannot be deleted': 'Không thể xoá mục này',
    'This item does not exist': 'Mục này không tồn tại',
    'This item has been deleted': 'Mục này đã bị xoá',
    'This page is not available': 'Trang này không khả dụng',
    'Total number': 'Tổng số',
    'Unable to delete': 'Không thể xoá',
    'Unable to load': 'Không thể tải',
    'Unable to save': 'Không thể lưu',
    'Unable to update': 'Không thể cập nhật',
    'Unable to create': 'Không thể tạo',
    'Unable to connect': 'Không thể kết nối',
    'Unable to find': 'Không thể tìm thấy',
    'Unable to process': 'Không thể xử lý',
    'Unable to retrieve': 'Không thể truy xuất',
    'Unknown error': 'Lỗi không xác định',
    'Update the item': 'Cập nhật mục',
    'Update the status': 'Cập nhật trạng thái',
    'Upload a file': 'Tải lên một tệp',
    'Upload a document': 'Tải lên một tài liệu',
    'Use this option': 'Dùng tuỳ chọn này',
    'View all': 'Xem tất cả',
    'View details': 'Xem chi tiết',
    'View the list': 'Xem danh sách',
    'Warning: this action': 'Cảnh báo: thao tác này',
    'You are not allowed': 'Bạn không được phép',
    'You are not allowed to': 'Bạn không được phép',
    'You can also': 'Bạn cũng có thể',
    'You do not have permission': 'Bạn không có quyền',
    'You do not have the right': 'Bạn không có quyền',
    'You have to': 'Bạn phải',
    'You must be logged in': 'Bạn phải đăng nhập',
    'You must select a file': 'Bạn phải chọn một tệp',
    'You must specify a value': 'Bạn phải chỉ định một giá trị',
    'Your password': 'Mật khẩu của bạn',
    'Your username': 'Tên đăng nhập của bạn',

    # ---------- Thong bao he thong ----------
    'Account created': 'Đã tạo tài khoản',
    'Account updated': 'Đã cập nhật tài khoản',
    'Account deleted': 'Đã xoá tài khoản',
    'Changes saved': 'Đã lưu các thay đổi',
    'Connection failed': 'Kết nối thất bại',
    'Connection successful': 'Kết nối thành công',
    'Connection established': 'Đã thiết lập kết nối',
    'Data imported': 'Đã nhập dữ liệu',
    'Data exported': 'Đã xuất dữ liệu',
    'Database error': 'Lỗi cơ sở dữ liệu',
    'File uploaded': 'Đã tải tệp lên',
    'File downloaded': 'Đã tải tệp xuống',
    'File not found': 'Không tìm thấy tệp',
    'File too large': 'Tệp quá lớn',
    'Invalid file': 'Tệp không hợp lệ',
    'Missing data': 'Thiếu dữ liệu',
    'No access': 'Không có quyền truy cập',
    'Session expired': 'Phiên làm việc đã hết hạn',
    'Timeout': 'Hết thời gian chờ',
    'Updated successfully': 'Cập nhật thành công',
    'Deleted successfully': 'Xoá thành công',
    'Created successfully': 'Tạo thành công',
    'Saved successfully': 'Lưu thành công',
    'Sent successfully': 'Gửi thành công',
    'Imported successfully': 'Nhập thành công',
    'Exported successfully': 'Xuất thành công',
}


# =============================================================================
#  TANG 2 — MAU CAU TRUC
#  (regex, ham sinh ban dich tu TU_DIEN)
#  Moi mau tra ve None neu khong ap dung duoc.
# =============================================================================
def _dich_tu(tu: str) -> str:
    """Tra 1 tu/cum tu trong TU_DIEN (khong phan biet hoa thuong dau)."""
    if not tu:
        return ''
    if tu in TU_DIEN:
        return TU_DIEN[tu]
    # Thu dang chu thuong / chu hoa dau
    for bien_the in (tu.lower(), tu.capitalize(), tu.upper()):
        if bien_the in TU_DIEN:
            return TU_DIEN[bien_the]
    return ''


def _dich_cum(cum: str) -> str:
    """
    Dich mot cum danh tu bang cach tra tung tu trong TU_DIEN.
    Vi du: "network device" -> "thiết bị mạng"
    """
    cum = cum.strip()
    if not cum:
        return ''
    nguyen = _dich_tu(cum)
    if nguyen:
        return nguyen
    # Thu dich tung tu roi ghep lai (giu thu tu tieng Anh -> Viet)
    tu = cum.split()
    ket = []
    for t in tu:
        d = _dich_tu(t)
        ket.append(d if d else t)
    return ' '.join(ket)


CAC_MAU = [
    # "Add a X" / "Add an X" -> "Thêm một X"
    (re.compile(r'^Add an? (.+)$'),
     lambda m: 'Thêm ' + _dich_cum(m.group(1))),
    # "Delete a X" / "Delete X" -> "Xoá X"
    (re.compile(r'^Delete an? (.+)$'),
     lambda m: 'Xoá ' + _dich_cum(m.group(1))),
    (re.compile(r'^Delete (.+)$'),
     lambda m: 'Xoá ' + _dich_cum(m.group(1))),
    # "Remove a X" -> "Gỡ bỏ X"
    (re.compile(r'^Remove an? (.+)$'),
     lambda m: 'Gỡ bỏ ' + _dich_cum(m.group(1))),
    # "Create a X" -> "Tạo X"
    (re.compile(r'^Create an? (.+)$'),
     lambda m: 'Tạo ' + _dich_cum(m.group(1))),
    # "New X" -> "X mới"
    (re.compile(r'^New (.+)$'),
     lambda m: _dich_cum(m.group(1)) + ' mới'),
    # "X management" -> "Quản lý X"
    (re.compile(r'^(.+) management$'),
     lambda m: 'Quản lý ' + _dich_cum(m.group(1))),
    # "X list" / "List of X" -> "Danh sách X"
    (re.compile(r'^(.+) list$'),
     lambda m: 'Danh sách ' + _dich_cum(m.group(1))),
    (re.compile(r'^List of (.+)$'),
     lambda m: 'Danh sách ' + _dich_cum(m.group(1))),
    # "Show X" -> "Hiển thị X"
    (re.compile(r'^Show (.+)$'),
     lambda m: 'Hiển thị ' + _dich_cum(m.group(1))),
    # "X settings" / "X configuration" -> "Thiết lập X" / "Cấu hình X"
    (re.compile(r'^(.+) settings$'),
     lambda m: 'Thiết lập ' + _dich_cum(m.group(1))),
    (re.compile(r'^(.+) configuration$'),
     lambda m: 'Cấu hình ' + _dich_cum(m.group(1))),
    # "Add X" (khong co mang) -> "Thêm X"
    (re.compile(r'^Add (.+)$'),
     lambda m: 'Thêm ' + _dich_cum(m.group(1))),
    # "Update X" -> "Cập nhật X"
    (re.compile(r'^Update (.+)$'),
     lambda m: 'Cập nhật ' + _dich_cum(m.group(1))),
    # "Select X" -> "Chọn X"
    (re.compile(r'^Select an? (.+)$'),
     lambda m: 'Chọn ' + _dich_cum(m.group(1))),
    # "X type" / "X date" / "X number"
    (re.compile(r'^(.+) type$'),
     lambda m: 'Loại ' + _dich_cum(m.group(1))),
    (re.compile(r'^(.+) date$'),
     lambda m: 'Ngày ' + _dich_cum(m.group(1))),
    (re.compile(r'^(.+) number$'),
     lambda m: 'Số ' + _dich_cum(m.group(1))),
    (re.compile(r'^(.+) name$'),
     lambda m: 'Tên ' + _dich_cum(m.group(1))),
    # "X by Y"
    (re.compile(r'^(.+) by (.+)$'),
     lambda m: _dich_cum(m.group(1)) + ' theo ' + _dich_cum(m.group(2))),
]


def dich_tu_dong(chuoi: str):
    """
    Tra ve ban dich tieng Viet cho `chuoi`, hoac None neu khong dich duoc.

    Quy tac an toan:
      - Bo qua chuoi chua bien dinh dang (%) -> dich nguyen
      - Bo qua chuoi qua dai (> 80 ky tu) -> nhieu kha nang la van ban ky thuat
      - Bo qua chuoi nhieu dong
    """
    if not chuoi or len(chuoi) > 80 or '\n' in chuoi:
        return None
    # Chuoi co bien dinh dang: chi dich neu co trong TU_DIEN nguyen ban
    if '%' in chuoi:
        return TU_DIEN.get(chuoi)

    # Tang 1: khop nguyen ban
    if chuoi in TU_DIEN:
        return TU_DIEN[chuoi]

    # Tang 2: khop mau
    for mau, sinh in CAC_MAU:
        m = mau.match(chuoi)
        if m:
            try:
                ket = sinh(m)
            except Exception:
                continue
            if ket:
                # Kiem tra ket qua co that su duoc dich (khong con nguyen tieng Anh)
                goc_tu = [w for w in m.groups() if w][0].split()
                if all(_dich_tu(w) or w in TU_DIEN for w in goc_tu):
                    return ket
    return None


# =============================================================================
#  DOC / GHI .MO
# =============================================================================
def doc_mo(du_lieu: bytes) -> dict:
    if len(du_lieu) < 28:
        return {}
    magic, _r, n, oo, to, _hs, _ht = struct.unpack('<7I', du_lieu[:28])
    if magic not in (0x950412de, 0xde120495):
        raise ValueError('File .mo khong hop le')

    def s(off):
        l, p = struct.unpack('<2I', du_lieu[off:off + 8])
        return du_lieu[p:p + l]

    out = {}
    for i in range(n):
        k = s(oo + i * 8)
        v = s(to + i * 8)
        if k:
            out[k.decode('utf-8', 'replace')] = v.decode('utf-8', 'replace')
    return out


def ghi_mo(ban_dich: dict, duong_dan: str) -> int:
    items = sorted(ban_dich.items(), key=lambda x: x[0].encode('utf-8'))
    n_items = len(items)
    header = (
        'Project-Id-Version: GLPI 11 VI (do an DLU)\n'
        'MIME-Version: 1.0\n'
        'Content-Type: text/plain; charset=UTF-8\n'
        'Content-Transfer-Encoding: 8bit\n'
        'Language: vi_VN\n'
        'Plural-Forms: nplurals=1; plural=0;\n'
    ).encode('utf-8')

    id_blob = b'\x00'
    str_blob = header + b'\x00'
    len_id = [0]
    len_str = [len(header)]
    for k, v in items:
        kb, vb = k.encode('utf-8'), v.encode('utf-8')
        len_id.append(len(kb))
        len_str.append(len(vb))
        id_blob += kb + b'\x00'
        str_blob += vb + b'\x00'

    tong = n_items + 1
    off_ot = 28
    off_tt = off_ot + tong * 8
    off_blob = off_tt + tong * 8

    ot = b''
    tt = b''
    cid, cst = off_blob, off_blob + len(id_blob)
    for i in range(tong):
        ot += struct.pack('<2I', len_id[i], cid)
        tt += struct.pack('<2I', len_str[i], cst)
        cid += len_id[i] + 1
        cst += len_str[i] + 1

    out = struct.pack('<7I', 0x950412de, 0, tong, off_ot, off_tt, 0, 0)
    out += ot + tt + id_blob + str_blob
    with open(duong_dan, 'wb') as f:
        f.write(out)
    return n_items


# =============================================================================
#  MAIN
# =============================================================================
def main():
    xem_truoc = '--xem-truoc' in sys.argv

    print('=' * 74)
    print('  DICH TU DONG GIAO DIEN GLPI SANG TIENG VIET')
    print('=' * 74)
    print()

    os.makedirs(TMP, exist_ok=True)

    # 1. Doc ban dich hien tai + danh sach chuoi can dich
    info('Buoc 1: Doc trang thai hien tai...')
    raw = subprocess.run(['docker', 'exec', GLPI_CONTAINER, 'cat', MO_DICH],
                         capture_output=True).stdout
    hien_tai = doc_mo(raw)
    ok(f'Da dich hien tai: {len(hien_tai)} chuoi')

    sys.path.insert(0, HERE)
    import importlib.util
    spec = importlib.util.spec_from_file_location(
        'cov', os.path.join(HERE, 'do-do-phu-tieng-viet.py'))
    cov = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(cov)

    po = os.path.join(TMP, 'vi_VN.po')
    # .po khong duoc version hoa (xem .gitignore) nhung luon tai lai duoc tu
    # image GLPI -> tu dong lay ve khi thieu (cung co che voi cac script dich).
    if not os.path.exists(po) or os.path.getsize(po) == 0:
        os.makedirs(TMP, exist_ok=True)
        r = subprocess.run(
            ['docker', 'exec', GLPI_CONTAINER, 'cat',
             '/var/www/glpi/locales/vi_VN.po'],
            capture_output=True)
        if r.stdout:
            with open(po, 'wb') as f:
                f.write(r.stdout)
            info(f'Da tai vi_VN.po tu container ({len(r.stdout):,} byte)')
        else:
            warn(f'Khong thay {po} va khong tai duoc tu container '
                 f'-> se dich 0 chuoi. Chay: bash scripts/cai-ban-dich.sh tai')
    ids = cov.doc_po_msgids(po)
    can_dich = [k for k in sorted(ids)
                if not (hien_tai.get(k, '') and hien_tai.get(k) != k)]
    ok(f'Chuoi can dich   : {len(ids)}')
    ok(f'Con thieu        : {len(can_dich)}')

    # 2. Dich tu dong
    info('Buoc 2: Dich tu dong theo tu dien + mau cau truc...')
    moi = {}
    for k in can_dich:
        d = dich_tu_dong(k)
        if d and d != k:
            moi[k] = d
    ok(f'Dich duoc them   : {len(moi)} chuoi')

    # 3. Thong ke
    from collections import Counter
    nhom = Counter()
    for k in moi:
        nhom[k.split()[0] if k.split() else '?'] += 1
    print()
    print(f'{BOLD}  Vi du ket qua:{NC}')
    for k in list(moi)[:15]:
        print(f'    {k:42} -> {moi[k]}')
    print()

    if xem_truoc:
        info('Che do --xem-truoc: khong ghi file.')
        return 0

    # 4. Ghi file .mo bo sung (gop voi ban cu neu co)
    info('Buoc 3: Ghi file .mo bo sung...')
    cu = {}
    raw_cu = subprocess.run(
        ['docker', 'exec', GLPI_CONTAINER, 'cat', DICH_CONTAINER],
        capture_output=True).stdout
    if raw_cu:
        cu = doc_mo(raw_cu)
        ok(f'Da co san        : {len(cu)} chuoi bo sung (se gop them)')
    cu.update(moi)
    ghi_mo(cu, MO_RA)
    kt = doc_mo(open(MO_RA, 'rb').read())
    if kt != cu:
        err('File ghi ra khong khop!')
        return 1
    ok(f'Da ghi: {len(cu)} chuoi, {os.path.getsize(MO_RA):,} byte (kiem chung OK)')

    # 5. Cai vao container
    info('Buoc 4: Cai vao GLPI...')
    subprocess.run(['docker', 'exec', GLPI_CONTAINER, 'sh', '-c',
                    'mkdir -p /var/glpi/files/_locales/bo_sung'], check=True)
    win = os.path.abspath(MO_RA).replace('/', '\\')
    subprocess.run(['docker', 'cp', win, f'{GLPI_CONTAINER}:{DICH_CONTAINER}'],
                   check=True)
    subprocess.run(['docker', 'exec', GLPI_CONTAINER, 'sh', '-c',
                    'chown -R www-data:www-data /var/glpi/files/_locales'], check=True)
    ok(f'Da cai: {DICH_CONTAINER}')

    print()
    print('BUOC TIEP THEO:')
    print('   python scripts/gop-ban-dich-tieng-viet.py    # gop vao catalog chinh')
    print('   python scripts/do-do-phu-tieng-viet.py       # do lai do phu')
    print()
    return 0


if __name__ == '__main__':
    sys.exit(main())
