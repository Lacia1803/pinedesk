/*!
 * -----------------------------------------------------------------------------
 *  dlubrand — Việt hoá hộp thoại tìm kiếm nhanh (Ctrl + Alt + G)
 * -----------------------------------------------------------------------------
 *  VẤN ĐỀ
 *
 *  Hộp thoại "Tìm kiếm nhanh" được viết bằng Vue (single-file component). Các
 *  chuỗi trong đó được dịch NGAY LÚC MODULE ĐƯỢC NẠP:
 *
 *      const header_message   = __('Go to menu');
 *      const placeholder      = __("Start typing to find a menu");
 *      const shortcut_message = __("Tip: You can call this modal with %s keys combination")
 *                                   .replace('%s', '<kbd>Ctrl</kbd> + ...');
 *
 *  Mà module Vue được nạp TRƯỚC khi bản dịch tiếng Việt về tới trình duyệt (bản
 *  dịch đi bằng một request AJAX riêng tới /front/locale.php). Lúc module chạy
 *  thì hàm __() còn là bản tiếng Anh, nên ba chuỗi trên bị "đóng băng" vĩnh viễn
 *  ở dạng tiếng Anh — mở lại hộp thoại bao nhiêu lần cũng vẫn tiếng Anh, dù sau
 *  đó window.__() đã trả về đúng tiếng Việt.
 *
 *  Đây là lỗi thứ tự nạp của lõi GLPI, không phải lỗi bản dịch: chuỗi nằm trong
 *  hộp thoại thì bị đóng băng, còn cùng chuỗi đó gọi lúc chạy thì ra tiếng Việt.
 *
 *  CÁCH CHỮA
 *
 *  Không sửa được thứ tự nạp (module Vue là của lõi), nên vá lại sau khi trang
 *  đã tải: chờ hộp thoại có trong DOM rồi thay đúng ba chỗ đó bằng bản dịch lấy
 *  từ window.__() — tức là vẫn đi qua hệ thống bản dịch, không chép cứng chữ
 *  tiếng Việt vào đây. Sau này sửa bản dịch trong .po thì chỗ này tự đổi.
 *
 *  Hộp thoại do Vue quản lý nên mỗi lần mở lại, Vue có thể dựng lại DOM và trả
 *  chữ về tiếng Anh. Vì vậy có thêm MutationObserver: hễ DOM đổi thì vá lại.
 *
 *  QUAN TRỌNG — PHÉP VÁ PHẢI "BẤT ĐỘNG" (idempotent):
 *  Mỗi phép vá chỉ ghi khi giá trị hiện tại còn ĐÚNG LÀ chuỗi tiếng Anh gốc.
 *  Nhờ vậy lần chạy thứ hai không tìm thấy chuỗi tiếng Anh nữa nên không làm
 *  gì, và MutationObserver tự lặng đi thay vì ăn mòn dần nội dung.
 *  (Bản đầu tiên vá theo kiểu "text node cuối cùng" nên mỗi vòng lặp lại xoá
 *   thêm một mẩu chữ, tới lúc cả câu chỉ còn "CtrlAltG".)
 * -----------------------------------------------------------------------------
 */
(function () {
    'use strict';

    // Lấy bản dịch qua hàm __() của GLPI. Nếu vì lý do nào đó hàm chưa có, trả
    // lại nguyên chuỗi tiếng Anh để giao diện vẫn hiển thị được, không vỡ.
    function dich(chuoi) {
        try {
            return (typeof window['__'] === 'function') ? window['__'](chuoi) : chuoi;
        } catch (e) {
            return chuoi;
        }
    }

    /**
     * Thay một chuỗi tiếng Anh bằng bản dịch, CHỈ khi chuỗi đó còn nguyên trong
     * text node. Giữ lại khoảng trắng đầu/cuối của node (Vue chèn một dấu cách
     * trước tiêu đề).
     *
     * @return {boolean} có thay gì không
     */
    function thayChu(phanTu, tiengAnh, tiengViet) {
        if (!phanTu || tiengAnh === tiengViet) {
            return false;
        }
        var di = document.createTreeWalker(phanTu, NodeFilter.SHOW_TEXT, null);
        var n;
        while ((n = di.nextNode())) {
            if (n.nodeValue.indexOf(tiengAnh) !== -1) {
                n.nodeValue = n.nodeValue.split(tiengAnh).join(tiengViet);
                return true;
            }
        }
        return false;
    }

    function vaCacChuoiLoi() {
        // 0. Nút xoá tìm kiếm trong bảng lưu (lõi GLPI 11 quên gọi __() trong saved_searches.html.twig)
        var cacClear = document.querySelectorAll('.clear-text[title="Clear search"]');
        for (var c = 0; c < cacClear.length; c++) {
            cacClear[c].setAttribute('title', dich('Clear search'));
        }
    }

    function vaHopThoai() {
        vaCacChuoiLoi();
        var dlg = document.getElementById('fuzzysearch');
        if (!dlg) {
            return;
        }

        // 1. Tiêu đề "Go to menu" (giữ nguyên thẻ <i> biểu tượng mũi tên).
        var tieuDe = dlg.querySelector('.modal-title');
        if (tieuDe) {
            thayChu(tieuDe, 'Go to menu', dich('Go to menu'));
        }

        // 2. Ô nhập: placeholder "Start typing to find a menu".
        var oNhap = dlg.querySelector('input[placeholder]');
        if (oNhap) {
            var phMoi = dich('Start typing to find a menu');
            if (oNhap.getAttribute('placeholder') === 'Start typing to find a menu'
                && phMoi !== 'Start typing to find a menu') {
                oNhap.setAttribute('placeholder', phMoi);
            }
        }

        // 3. Câu mẹo. Vue đổ cả câu bằng innerHTML, trong đó các phím nằm ở thẻ
        //    <kbd> và dấu %s đã bị thay bằng chúng ngay lúc nạp module. Vì vậy
        //    phải dựng lại: lấy bản dịch, thay %s bằng chính các thẻ <kbd> đang
        //    có (giữ đúng biến thể Ctrl/Alt/G hay ⌥/⌘/G trên máy Mac).
        var canhBao = dlg.querySelector('.alert p');
        if (canhBao && canhBao.textContent.indexOf('Tip: You can call this modal with') !== -1) {
            var cauDich = dich('Tip: You can call this modal with %s keys combination');
            // Chỉ dựng lại khi bản dịch thực sự có chỗ điền %s; nếu không thì
            // thà để nguyên câu tiếng Anh còn hơn ra câu cụt.
            if (cauDich.indexOf('%s') !== -1) {
                var phim = [];
                var cacKbd = canhBao.querySelectorAll('kbd');
                for (var i = 0; i < cacKbd.length; i++) {
                    phim.push(cacKbd[i].outerHTML);
                }
                canhBao.innerHTML = cauDich.replace('%s', phim.join(' + '));
            }
        }
    }

    function batDauTheoDoi() {
        vaHopThoai();

        if (typeof MutationObserver !== 'function') {
            // Trình duyệt quá cũ: vá một lần, chấp nhận không vá lại khi mở lại.
            return;
        }

        var hen = false;
        var theoDoi = new MutationObserver(function () {
            // Gộp nhiều thay đổi trong cùng một khung hình thành một lần vá.
            if (hen) {
                return;
            }
            hen = true;
            requestAnimationFrame(function () {
                hen = false;
                vaHopThoai();
            });
        });

        theoDoi.observe(document.body, {
            childList: true,
            subtree: true,
            characterData: true,
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', batDauTheoDoi);
    } else {
        batDauTheoDoi();
    }
})();
