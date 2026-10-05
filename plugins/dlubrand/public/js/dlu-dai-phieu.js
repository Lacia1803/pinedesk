/**
 * Dải ưu tiên bên hông phiếu yêu cầu — plugin dlubrand.
 *
 * VÌ SAO PHẢI CÓ TỆP NÀY:
 *   Bảng danh sách phiếu của GLPI hiển thị độ ưu tiên bằng một khối màu nhỏ
 *   nằm giữa cột "Độ ưu tiên". Muốn quét mắt xuống danh sách để biết phiếu nào
 *   gấp thì phải đọc từng ô — chậm, và ở màn hình 1366px thì cột đó nằm tít
 *   bên phải, gần như phải cuộn ngang mới thấy.
 *
 *   Tệp này kéo độ ưu tiên ra thành một dải màu 3px ở mép trái của từng dòng.
 *   Mép trái là nơi mắt đã bám sẵn khi quét danh sách, nên chỉ cần liếc một cái
 *   là thấy ngay dòng nào đỏ, dòng nào xám.
 *
 * VÌ SAO KHÔNG LÀM BẰNG CSS THUẦN:
 *   GLPI không gắn lớp ngữ nghĩa nào cho độ ưu tiên. Ô đó chỉ là
 *       <td data-searchopt-content-id="3">
 *           <div class="badge_block" style="border-color: #F6D9A8">
 *               <span style="background: #F6D9A8"></span>&nbsp;Trung bình
 *           </div>
 *       </td>
 *   Màu nằm thẳng trong thuộc tính style, lại đổi theo bảng màu đang chọn, nên
 *   không có bộ chọn CSS nào bám vào được. Đành đọc nhãn chữ rồi tự suy ra bậc.
 *
 * VÌ SAO ĐỌC NHÃN CHỮ MÀ KHÔNG ĐỌC MÃ MÀU:
 *   Nhãn chữ ("Trung bình", "Cao"...) là dữ liệu do bộ dịch sinh ra, ổn định
 *   hơn mã màu. Mã màu còn phải đổi theo từng bảng màu; nhãn thì không.
 *   Đổi lại, tệp này phụ thuộc vào bản dịch tiếng Việt — nếu sau này chạy ở
 *   ngôn ngữ khác thì dải sẽ không hiện, và đó là hỏng theo hướng an toàn:
 *   bảng vẫn nguyên vẹn, chỉ mất dải màu.
 *
 * VÌ SAO PHẢI KIỂM TRA TIÊU ĐỀ CỘT TRƯỚC KHI TÔ:
 *   "3" chỉ là số hiệu cột TRONG BẢNG DANH SÁCH PHIẾU. Các bảng danh sách khác
 *   của GLPI dùng chung cách đánh số đó nhưng gán cho cột khác hẳn:
 *       ticket.php   -> cột 3 là "Độ ưu tiên"
 *       computer.php -> cột 3 là "Vị trí"
 *       user.php     -> cột 3 là "Vị trí"
 *   Nếu cứ thấy data-searchopt-content-id="3" là tô, dải màu sẽ mọc lên cả
 *   danh sách máy tính và người dùng, nơi chẳng có độ ưu tiên nào. Tệ hơn: một
 *   vị trí tên kiểu "... Tòa nhà Cao tầng" có chứa chữ "Cao" nên sẽ bị nhận
 *   nhầm thành mức ưu tiên "Cao". Vì vậy phải đọc tiêu đề cột và chỉ chạy khi
 *   tiêu đề đúng là "Độ ưu tiên" (hoặc "Priority" nếu chạy tiếng Anh).
 *
 * GIỚI HẠN CÓ CHỦ Ý:
 *   - Chỉ áp cho bảng danh sách có cột độ ưu tiên THẬT (phiếu yêu cầu, vấn đề,
 *     yêu cầu thay đổi). Bảng Kanban dựng thẻ bằng cấu trúc khác nên không xử lý.
 *   - Không đụng vào lõi GLPI, không sửa CSDL, không đổi dữ liệu phiếu.
 *   - Chạy lại nhiều lần vô hại: chỉ ghi đè đúng một thuộc tính trên thẻ <tr>,
 *     và bỏ qua nếu giá trị không đổi.
 */
(function () {
    'use strict';

    /* Nhãn tiếng Việt -> bậc ưu tiên (1 = rất thấp, 6 = Chính).
       Khớp với locales/vi_VN.po: "Very low", "Low", "Medium", "High",
       "Very high", "Major" (mức 6 = "Chính"). */
    var NHAN_SANG_BAC = {
        'Rất thấp': 1,
        'Thấp': 2,
        'Trung bình': 3,
        'Cao': 4,
        'Rất cao': 5,
        'Chính': 6
    };

    /* Số hiệu cột "Độ ưu tiên" trong bảng danh sách của GLPI. */
    var COT_UU_TIEN = '3';

    /* Từ khoá nhận diện tiêu đề cột độ ưu tiên. Có cả tiếng Anh để không vỡ
       nếu có trang chạy ngôn ngữ khác. */
    var TU_KHOA_TIEU_DE = ['ưu tiên', 'priority'];

    /* Thuộc tính đánh dấu trên thẻ <tr>; phần CSS đọc lại để tô màu. */
    var THUOC_TINH = 'data-dlu-uu-tien';

    /* Cột số COT_UU_TIEN có thật sự là "Độ ưu tiên" không? */
    function cotLaUuTien() {
        var th = document.querySelector(
            'th[data-searchopt-id="' + COT_UU_TIEN + '"]'
        );
        if (!th) {
            return false;
        }
        var ten = (th.textContent || '').toLowerCase();
        for (var i = 0; i < TU_KHOA_TIEU_DE.length; i++) {
            if (ten.indexOf(TU_KHOA_TIEU_DE[i]) !== -1) {
                return true;
            }
        }
        return false;
    }

    function docBac(thanh) {
        /* Chuẩn hoá: đổi khoảng trắng không ngắt (nbsp, U+00A0) thành dấu cách
           thường, gộp mọi khoảng trắng liền nhau, rồi cắt hai đầu.
           Ký tự đó được viết bằng escape để không lẫn với dấu cách thường:
           để nguyên ký tự thật thì không ai đọc ra sự khác biệt trong mã nguồn. */
        var chu = (thanh.textContent || '')
            .replace(/\u00a0/g, ' ')
            .replace(/\s+/g, ' ')
            .trim();

        /* Bỏ phần trong ngoặc nếu có, ví dụ "Trung bình (3)". */
        chu = chu.replace(/\s*\([^)]*\)\s*$/, '').trim();

        /* CHỈ khớp khi chuỗi còn lại ĐÚNG BẰNG một nhãn. Không dò chuỗi con:
           một vị trí hay danh mục tình cờ chứa chữ "Cao" sẽ bị nhận nhầm. */
        if (Object.prototype.hasOwnProperty.call(NHAN_SANG_BAC, chu)) {
            return NHAN_SANG_BAC[chu];
        }
        return 0;
    }

    function sonDai() {
        if (!cotLaUuTien()) {
            return;
        }
        var cacO = document.querySelectorAll(
            'td[data-searchopt-content-id="' + COT_UU_TIEN + '"]'
        );
        for (var i = 0; i < cacO.length; i++) {
            var o = cacO[i];
            var hang = o.parentNode;
            while (hang && hang.tagName !== 'TR') {
                hang = hang.parentNode;
            }
            if (!hang || hang.tagName !== 'TR') {
                continue;
            }

            var bac = docBac(o);
            var dangCo = hang.getAttribute(THUOC_TINH);

            if (bac === 0) {
                /* Không đọc ra bậc (đổi ngôn ngữ, hoặc ô trống): gỡ dải đi. */
                if (dangCo !== null) {
                    hang.removeAttribute(THUOC_TINH);
                }
                continue;
            }

            if (dangCo !== String(bac)) {
                hang.setAttribute(THUOC_TINH, String(bac));
            }
        }
    }

    function batDau() {
        sonDai();
        if (typeof MutationObserver !== 'function') {
            return;
        }
        /* Bảng GLPI tự vẽ lại sau khi lọc, sắp xếp, chuyển trang. Theo dõi thay
           đổi cấu trúc (không theo dõi thuộc tính) nên việc ghi thuộc tính ở
           trên không kích hoạt vòng lặp vô tận. */
        var hen = false;
        var theoDoi = new MutationObserver(function () {
            if (hen) {
                return;
            }
            hen = true;
            requestAnimationFrame(function () {
                hen = false;
                sonDai();
            });
        });
        theoDoi.observe(document.body, { childList: true, subtree: true });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', batDau);
    } else {
        batDau();
    }
}());
