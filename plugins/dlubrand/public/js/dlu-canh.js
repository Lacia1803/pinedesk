/*!
 * -----------------------------------------------------------------------------
 *  dlubrand — Cảnh đồi Đà Lạt cho trang đăng nhập
 * -----------------------------------------------------------------------------
 *  Dựng năm lớp đồi xếp lớp phía sau thẻ đăng nhập. Mỗi lớp trôi một nhịp khác
 *  nhau khi người dùng rê chuột, nên mắt đọc ra chiều sâu.
 *
 *  VÌ SAO CHỈ Ở TRANG ĐĂNG NHẬP?
 *    Đây là hiệu ứng chuyển động duy nhất của cả hệ thống, và nó chỉ có mặt ở
 *    mặt tiền. Bảng biểu, biểu mẫu, danh sách và dashboard bên trong không có
 *    parallax: ở đó người ta đang làm việc thật, chuyển động chỉ gây nhiễu và
 *    làm chậm thao tác. Chiều sâu ở những trang đó do bố cục và tương phản
 *    gánh, không do hiệu ứng.
 *
 *  Tắt JavaScript: trang vẫn nguyên vẹn, chỉ mất phần cảnh đồi.
 *  Bật "giảm chuyển động": cảnh vẫn hiện nhưng đứng yên.
 * -----------------------------------------------------------------------------
 */
(function () {
    'use strict';

    /* GLPI nạp JavaScript của plugin trong <head> của trang ẩn danh, lúc đó
       <body> chưa tồn tại. Phải đợi cây DOM dựng xong mới chèn được cảnh. */
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', khoiTao);
    } else {
        khoiTao();
    }

    function khoiTao() {
    var body = document.body;
    if (!body || !body.classList.contains('welcome-anonymous')) {
        return;
    }

    /* Chỉ dựng một lần, phòng trường hợp script bị nạp lặp. */
    if (document.querySelector('.dlu-canh')) {
        return;
    }

    var giamChuyenDong = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    /* Mỗi lớp đồi phủ trọn khung nhìn (xem .dlu-canh__lop trong CSS), và khung
       vẽ dùng đúng tỉ lệ đó. Nhờ vậy một toạ độ y trong khung vẽ rơi thẳng
       xuống cùng chỗ trên màn hình, ở mọi chiều cao cửa sổ, và cây thông không
       bị kéo giãn.

       Năm sống đồi trải trên nửa dưới: lớp xa nhất có sống cao nhất (y nhỏ),
       màu nhạt nhất như bị sương pha loãng, và trôi chậm nhất khi rê chuột.
       Nửa trên nhường trọn cho thẻ đăng nhập.

       `bien` là bề rộng đỉnh đồi, `pha` là độ lệch pha: hai lớp cạnh nhau lệch
       pha thì đỉnh nọ không nằm trên đỉnh kia, nên mắt đọc ra các dãy núi khác
       nhau chứ không phải mấy dải song song. */
    var CAO = 900;
    var LOP_DOI = [
        { mau: '#D3DEC2', sau: 7,  song: 372, bien: 46, pha: 0.00 },
        { mau: '#B6C89A', sau: 12, song: 462, bien: 58, pha: 0.35 },
        { mau: '#95AE6F', sau: 19, song: 552, bien: 66, pha: 0.72, thong: true },
        { mau: '#75914E', sau: 28, song: 642, bien: 52, pha: 0.18 },
        { mau: '#57742F', sau: 38, song: 732, bien: 40, pha: 0.58 }
    ];

    /* Cao độ của sống đồi tại một hoành độ. Đường vẽ và cây thông cùng dùng
       hàm này, nên cây luôn đứng đúng trên sống chứ không lơ lửng hay lún.
       Sóng có 1,5 chu kỳ ngang khung, lệch pha theo lớp. */
    function caoDoSong(lop, x) {
        var goc = (x / 1440) * Math.PI * 2 * 1.5 + lop.pha * Math.PI * 2;
        var song = Math.sin(goc) * 0.6 + Math.sin(goc * 2.3 + 1.1) * 0.4;
        return lop.song - lop.bien * song;
    }

    /* Vẽ sống đồi thành đường gấp khúc dày (48 đoạn ngang khung), rồi đổ
       xuống đáy khung. Dày vậy nên mắt không thấy góc cạnh. */
    function duongSong(lop) {
        var N = 48, d = '';
        for (var i = 0; i <= N; i++) {
            var x = Math.round((i / N) * 1440);
            var y = caoDoSong(lop, x).toFixed(1);
            d += (i ? ' L' : 'M') + x + ',' + y;
        }
        return d + ' L1440,' + CAO + ' L0,' + CAO + ' Z';
    }

    /* Cây thông đứng rải trên sống đồi của lớp giữa, so le cao thấp như rừng
       thật. Hoành độ lệch nhau không đều để rừng không trông như hàng rào. */
    var THONG = [
        [58, 0.85], [142, 1.10], [228, 0.92], [318, 1.22], [410, 1.00], [508, 1.18],
        [600, 0.88], [694, 1.14], [790, 0.96], [888, 1.26], [984, 1.02], [1080, 1.16],
        [1176, 0.90], [1272, 1.12], [1368, 1.00]
    ];

    var DEFS = "<defs><path id='cay' d='M0,-22 L7,-9 L4,-9 L10,4 L6,4 L13,18 L-13,18 L-6,4 L-10,4 L-4,-9 L-7,-9 Z'/></defs>";

    function svgCua(lop) {
        var svg = "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 1440 " + CAO + "'"
            + " preserveAspectRatio='none'>"
            + DEFS
            + "<path fill='" + lop.mau + "' d='" + duongSong(lop.song) + "'/>";

        if (lop.thong) {
            svg += "<g fill='#3D5222'>";
            THONG.forEach(function (t) {
                var y = caoDoSong(lop, t[0]).toFixed(1);
                svg += "<use href='#cay' transform='translate(" + t[0] + "," + y + ") scale(" + t[1] + ")'/>";
            });
            svg += "</g>";
        }
        return svg + "</svg>";
    }

    var canh = document.createElement('div');
    canh.className = 'dlu-canh';
    canh.setAttribute('aria-hidden', 'true');

    var cacLop = LOP_DOI.map(function (lop) {
        var el = document.createElement('div');
        el.className = 'dlu-canh__lop';
        el.style.backgroundImage = 'url("data:image/svg+xml,' + encodeURIComponent(svgCua(lop)) + '")';
        canh.appendChild(el);
        return { el: el, sau: lop.sau };
    });

    /* Hai dải sương nằm giữa các lớp đồi, trôi chậm bằng CSS. */
    var suong1 = document.createElement('div');
    suong1.className = 'dlu-canh__suong dlu-canh__suong--1';
    var suong2 = document.createElement('div');
    suong2.className = 'dlu-canh__suong dlu-canh__suong--2';
    canh.appendChild(suong1);
    canh.appendChild(suong2);

    body.insertBefore(canh, body.firstChild);

    if (giamChuyenDong || !window.matchMedia('(hover: hover) and (pointer: fine)').matches) {
        return;
    }

    /* Rê chuột: lớp càng gần càng nhích nhiều. Giá trị đích được đuổi dần theo
       từng khung hình nên cảnh trôi theo tay chứ không giật, và vòng lặp tự
       dừng khi đã đuổi kịp. */
    var dichX = 0, dichY = 0, nayX = 0, nayY = 0, dangChay = false;

    function ve() {
        nayX += (dichX - nayX) * 0.075;
        nayY += (dichY - nayY) * 0.075;

        cacLop.forEach(function (l) {
            var x = (-nayX * l.sau).toFixed(2);
            var y = (-nayY * l.sau * 0.45).toFixed(2);
            l.el.style.transform = 'translate3d(' + x + 'px,' + y + 'px,0)';
        });

        if (Math.abs(dichX - nayX) > 0.002 || Math.abs(dichY - nayY) > 0.002) {
            requestAnimationFrame(ve);
        } else {
            dangChay = false;
        }
    }

    function chay() {
        if (dangChay) { return; }
        dangChay = true;
        requestAnimationFrame(ve);
    }

    window.addEventListener('pointermove', function (e) {
        dichX = (e.clientX / window.innerWidth - 0.5) * 2;
        dichY = (e.clientY / window.innerHeight - 0.5) * 2;
        chay();
    }, { passive: true });

    window.addEventListener('pointerleave', function () {
        dichX = 0;
        dichY = 0;
        chay();
    }, { passive: true });
    }
})();
