/*!
 * -----------------------------------------------------------------------------
 *  dlubrand — Lịch chọn ngày bằng tiếng Việt
 * -----------------------------------------------------------------------------
 *  VÌ SAO CẦN FILE NÀY?
 *
 *  GLPI gọi thư viện lịch (flatpickr) bằng mã ngôn ngữ "vi":
 *      Html.php:2662   locale: getFlatPickerLocale("vi", "VN")
 *      common.js       getFlatPickerLocale("vi", "VN") -> "vi"
 *
 *  Nhưng flatpickr lại đăng ký bản tiếng Việt dưới khoá "vn", không phải "vi":
 *      /lib/flatpickr/l10n/vn.js   ->   fp.l10ns.vn = Vietnamese
 *
 *  Hệ quả: flatpickr không tìm thấy bản dịch, in cảnh báo ra console và lặng lẽ
 *  rơi về tiếng Anh. Mọi ô chọn ngày trong hệ thống — "Ngày khai mạc", hạn tiếp
 *  nhận, hạn giải quyết — đều hiện January…December và Sun…Sat, kèm tiêu đề nút
 *  "Show date picker". Giữa một giao diện toàn tiếng Việt, đây là chỗ hở rõ nhất
 *  còn sót lại.
 *
 *  CÁCH CHỮA: đăng ký thêm một bản sao dưới đúng khoá "vi" mà GLPI đang hỏi.
 *  Không sửa mã nguồn GLPI, không sửa thư viện — chỉ bổ sung một khoá còn thiếu.
 *
 *  VÌ SAO CHÉP DỮ LIỆU VÀO ĐÂY MÀ KHÔNG NẠP /lib/flatpickr/l10n/vn.js?
 *    Vì thứ tự nạp. File này chạy trong <head>, ngay sau flatpickr.js. Nếu nạp
 *    vn.js bằng thẻ <script> động thì nó về bất đồng bộ, có thể muộn hơn thời
 *    điểm GLPI khởi tạo lịch (trong $(function(){...})) — và lịch lại ra tiếng
 *    Anh, đúng cái lỗi đang muốn chữa. Chép thẳng dữ liệu vào đây thì khoá "vi"
 *    có mặt trước khi bất kỳ lịch nào được dựng, không phụ thuộc mạng.
 *
 *  Dữ liệu dưới đây lấy nguyên từ /lib/flatpickr/l10n/vn.js (flatpickr v4.6.13,
 *  giấy phép MIT). Nâng cấp flatpickr thì đối chiếu lại file đó.
 *
 *  Đây là khuôn mẫu lịch của thư viện, không phải chuỗi giao diện của GLPI, nên
 *  không đi qua hệ thống bản dịch .po — chép tại đây là đúng chỗ.
 * -----------------------------------------------------------------------------
 */
(function () {
    'use strict';

    function dangKyTiengViet() {
        if (!window.flatpickr || !window.flatpickr.l10ns) {
            return false;
        }

        // Đã có sẵn thì thôi (phòng khi bản flatpickr sau này tự sửa).
        if (window.flatpickr.l10ns.vi) {
            return true;
        }

        window.flatpickr.l10ns.vi = {
            weekdays: {
                shorthand: ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'],
                longhand: [
                    'Chủ nhật', 'Thứ hai', 'Thứ ba', 'Thứ tư',
                    'Thứ năm', 'Thứ sáu', 'Thứ bảy',
                ],
            },
            months: {
                shorthand: [
                    'Th1', 'Th2', 'Th3', 'Th4', 'Th5', 'Th6',
                    'Th7', 'Th8', 'Th9', 'Th10', 'Th11', 'Th12',
                ],
                longhand: [
                    'Tháng một', 'Tháng hai', 'Tháng ba', 'Tháng tư',
                    'Tháng năm', 'Tháng sáu', 'Tháng bảy', 'Tháng tám',
                    'Tháng chín', 'Tháng mười', 'Tháng mười một', 'Tháng mười hai',
                ],
            },
            // Tuần Việt Nam bắt đầu từ thứ Hai.
            firstDayOfWeek: 1,
            // Câu "từ ngày ... đến ngày ..." khi chọn một khoảng.
            rangeSeparator: ' đến ',
            // Nhãn cột số tuần. Bản gốc của thư viện đặt mặc định là "Wk" và
            // ngay cả bản tiếng Việt chính thức của flatpickr cũng bỏ sót khoá
            // này, nên cột đầu lịch vẫn hiện "Wk" giữa một lịch tiếng Việt.
            // Đây là chỗ duy nhất ở đây đi xa hơn bản gốc một chút, và là chủ ý.
            weekAbbreviation: 'Tuần',
        };

        return true;
    }

    // flatpickr.js được nạp ngay trước file này nên thường đã sẵn sàng. Vẫn thử
    // lại vài nhịp cho chắc, phòng khi thứ tự nạp thay đổi ở bản GLPI sau.
    if (!dangKyTiengViet()) {
        var soLan = 0;
        var hen = setInterval(function () {
            if (dangKyTiengViet() || ++soLan > 40) {
                clearInterval(hen);
            }
        }, 50);
    }
})();
