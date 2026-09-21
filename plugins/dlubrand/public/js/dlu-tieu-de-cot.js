/*!
 * -----------------------------------------------------------------------------
 *  dlubrand — Gỡ tiêu đề cột bị lặp hai lần
 * -----------------------------------------------------------------------------
 *  VẤN ĐỀ
 *
 *  Trong bảng kết quả tìm kiếm, GLPI dựng tiêu đề cột theo mẫu:
 *
 *      templates/components/search/table.html.twig
 *        {% set col_name = col['name'] %}
 *        {% if col['groupname'] is defined %}
 *           {% set col_name = __('%1$s - %2$s')|format(groupname, col['name']) %}
 *        {% endif %}
 *
 *  Tức là luôn ghép "<tên nhóm> - <tên cột>". Với cột "Người yêu cầu" thì cả
 *  hai vế đều là cùng một chuỗi (nhóm cũng tên là Requester, cột cũng tên là
 *  Requester), nên tiêu đề in ra thành:
 *
 *      Những người yêu cầu - Những người yêu cầu
 *
 *  Nhìn là thấy sai, mà lại nằm ngay cột đầu của danh sách phiếu — chỗ người
 *  dùng nhìn nhiều nhất.
 *
 *  VÌ SAO KHÔNG SỬA TEMPLATE?
 *    Vì đó là file lõi. Sửa vào là nâng cấp GLPI sẽ mất, đúng thứ mà plugin
 *    này sinh ra để tránh (xem ghi chú đầu setup.php). Vả lại đây là lỗi của
 *    lõi, không phải của bản dịch: bản tiếng Anh cũng in "Requester -
 *    Requester" y hệt.
 *
 *  CÁCH CHỮA
 *    Quét các ô tiêu đề, hễ gặp dạng "X - X" (hai vế giống nhau sau khi đã
 *    chuẩn hoá khoảng trắng) thì rút gọn còn "X".
 *
 *  PHÉP VÁ BẤT ĐỘNG (idempotent): chỉ ghi khi hai vế thực sự giống nhau. Chạy
 *  lại lần hai thì tiêu đề đã là "X" nên không khớp mẫu nữa, không làm gì.
 *
 *  GIỚI HẠN CÓ CHỦ Ý: chỉ gỡ khi HAI VẾ GIỐNG HỆT NHAU. Các tiêu đề ghép thật
 *  sự có nghĩa — "Giao cho - Kỹ thuật viên", "Người yêu cầu - Nhóm" — giữ
 *  nguyên, vì đó là thông tin, không phải lỗi.
 * -----------------------------------------------------------------------------
 */
(function () {
    'use strict';

    // Dấu phân cách lõi GLPI dùng ở chuỗi '%1$s - %2$s'.
    var PHAN_CACH = ' - ';

    function goTieuDeCot() {
        var cacO = document.querySelectorAll('th');

        for (var i = 0; i < cacO.length; i++) {
            var o = cacO[i];

            // Bỏ qua ô có nội dung phức tạp (có nút sắp xếp lồng bên trong) để
            // không ghi đè lên phần tử con. Tiêu đề cột có nút sắp xếp là thẻ
            // <span>, không phải text node trần, nên ta chỉ đụng vào text node.
            var di = document.createTreeWalker(o, NodeFilter.SHOW_TEXT, null);
            var n;
            while ((n = di.nextNode())) {
                var goc = n.nodeValue;
                var gon = goc.trim();

                if (gon === '' || gon.indexOf(PHAN_CACH) === -1) {
                    continue;
                }

                var phan = gon.split(PHAN_CACH);
                // Chỉ xử lý đúng dạng hai vế. Ba vế trở lên để yên.
                if (phan.length !== 2) {
                    continue;
                }

                var trai = phan[0].trim();
                var phai = phan[1].trim();

                if (trai !== '' && trai === phai) {
                    // Giữ lại khoảng trắng đầu/cuối của node gốc.
                    var truoc = goc.slice(0, goc.indexOf(gon));
                    var sau = goc.slice(goc.indexOf(gon) + gon.length);
                    n.nodeValue = truoc + trai + sau;
                }
            }
        }
    }

    function batDau() {
        goTieuDeCot();

        if (typeof MutationObserver !== 'function') {
            return;
        }

        // Bảng kết quả được dựng lại mỗi lần đổi tiêu chí tìm kiếm hoặc sắp
        // xếp, nên phải vá lại. Gộp nhiều thay đổi trong cùng một khung hình.
        var hen = false;
        var theoDoi = new MutationObserver(function () {
            if (hen) {
                return;
            }
            hen = true;
            requestAnimationFrame(function () {
                hen = false;
                goTieuDeCot();
            });
        });

        theoDoi.observe(document.body, { childList: true, subtree: true });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', batDau);
    } else {
        batDau();
    }
})();
