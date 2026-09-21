<?php

/**
 * -----------------------------------------------------------------------------
 *  Plugin "dlubrand" — Giao diện thương hiệu DLU cho GLPI
 * -----------------------------------------------------------------------------
 *  Đồ án thực tập: Xây dựng hệ thống hỗ trợ kỹ thuật (PineDesk)
 *  Trường Đại học Đà Lạt
 *
 *  MỤC ĐÍCH:
 *    Áp bảng màu "Đà Lạt" lên MỌI trang của GLPI — kể cả trang đăng nhập,
 *    nơi chưa có phiên làm việc (session).
 *
 *  VÌ SAO CẦN PLUGIN NÀY?
 *    Bảng màu tuỳ biến (files/_themes/*.scss) chỉ được nạp khi người dùng
 *    đã đăng nhập: template trang ẩn danh
 *    (templates/layout/page_card_notlogged.html.twig) dùng danh sách CSS cố
 *    định, KHÔNG có file palette tự tạo.
 *    (Lưu ý: trang đăng nhập VẪN mang data-glpi-theme="da_lat" vì phiên ẩn
 *     danh được nạp $_SESSION['glpipalette'] từ cấu hình chung
 *     glpi_configs.palette — nhưng thuộc tính đó KHÔNG kéo theo file .scss.)
 *    Giải pháp: dùng hook ADD_CSS_ANONYMOUS_PAGE + ADD_CSS để chèn thêm
 *    một file CSS ghi đè, được nạp ở CẢ trang ẩn danh lẫn trang đã đăng nhập.
 *
 *  ƯU ĐIỂM: KHÔNG sửa file lõi GLPI -> nâng cấp GLPI không mất tuỳ biến.
 * -----------------------------------------------------------------------------
 */

use Glpi\Plugin\Hooks;

define('PLUGIN_DLUBRAND_VERSION', '1.0.0');
define('PLUGIN_DLUBRAND_MIN_GLPI', '11.0.0');
define('PLUGIN_DLUBRAND_MAX_GLPI', '99.0.99');

/**
 * Khởi tạo plugin — đăng ký các hook với GLPI
 *
 * @return void
 */
function plugin_init_dlubrand(): void
{
    global $PLUGIN_HOOKS;

    // Chỉ đăng ký khi đã đăng nhập hợp lệ (tránh lỗi khi cài đặt)
    $plugin = new Plugin();
    if (!$plugin->isActivated('dlubrand')) {
        return;
    }

    // CSS ghi đè cho các trang đã đăng nhập
    $PLUGIN_HOOKS[Hooks::ADD_CSS]['dlubrand'] = [
        'css/dlu-theme.css',
    ];

    // CSS ghi đè cho các trang ẩn danh (đăng nhập, quên mật khẩu, ...)
    $PLUGIN_HOOKS[Hooks::ADD_CSS_ANONYMOUS_PAGE]['dlubrand'] = [
        'css/dlu-theme.css',
    ];

    // Lịch chọn ngày bằng tiếng Việt. GLPI gọi flatpickr bằng mã "vi" nhưng
    // thư viện lại đăng ký bản tiếng Việt dưới khoá "vn", nên lịch rơi về tiếng
    // Anh. File này bổ sung khoá "vi" còn thiếu (xem ghi chú đầu file).
    // Nạp ở CẢ hai loại trang: trong hệ thống (hạn tiếp nhận, hạn giải quyết,
    // ngày khai mạc) lẫn trang ẩn danh (biểu mẫu công khai có ô chọn ngày).
    // Dải ưu tiên bên hông phiếu (dlu-dai-phieu.js): kéo độ ưu tiên từ cột
    // giữa bảng ra mép trái từng dòng. Đây là tệp DUY NHẤT trong plugin can
    // thiệp vào bảng danh sách, nên nó chỉ được nạp ở trang đã đăng nhập —
    // khách ẩn danh không có bảng danh sách để cần.
    $PLUGIN_HOOKS[Hooks::ADD_JAVASCRIPT]['dlubrand'] = [
        'js/dlu-lich-viet.js',
        'js/dlu-chu-vue.js',
        'js/dlu-tieu-de-cot.js',
        'js/dlu-dai-phieu.js',
    ];
    $PLUGIN_HOOKS[Hooks::ADD_JAVASCRIPT_ANONYMOUS_PAGE]['dlubrand'] = [
        'js/dlu-canh.js',
        'js/dlu-lich-viet.js',
    ];

    // Ngôn ngữ mặc định cho trang ẩn danh (trang đăng nhập).
    $PLUGIN_HOOKS[Hooks::POST_INIT]['dlubrand'] = 'plugin_dlubrand_set_default_language';

    // GHI CHÚ QUAN TRỌNG — VÌ SAO KHÔNG XỬ LÝ NGÔN NGỮ TRANG ĐĂNG NHẬP Ở ĐÂY?
    //
    //   Thứ tự khởi động thật của GLPI 11 (src/Glpi/Kernel/ListenersPriority.php):
    //     SessionStart        (ưu tiên 130)
    //     LoadLanguage        (ưu tiên 120)   <-- ngôn ngữ được chốt tại đây
    //     InitializePlugins   (ưu tiên 110)   <-- plugin chỉ chạy từ đây
    //
    //   Nghĩa là khi plugin được nạp thì ngôn ngữ ĐÃ được quyết định xong.
    //   Mọi hook của plugin (kể cả POST_INIT) đều chạy SAU đó, nên không thể
    //   sửa được ngôn ngữ của trang đăng nhập.
    //
    //   Hàm Session::getPreferredLanguage() chọn ngôn ngữ theo header
    //   Accept-Language của TRÌNH DUYỆT trước, rồi mới tới ngôn ngữ mặc định
    //   trong Thiết lập chung. Vì vậy khách dùng trình duyệt cài tiếng Anh sẽ
    //   thấy trang đăng nhập bằng tiếng Anh.
    //
    //   => Đã xử lý ở tầng GATEWAY (nginx): ghi đè header Accept-Language
    //      thành "vi-VN,vi;q=0.9,en;q=0.8" cho các request trang đăng nhập.
    //      Xem nginx/conf.d/default.conf — khối `map $uri $dlu_accept_language`.
    //
    //   Cách này KHÔNG sửa mã nguồn lõi, và chỉ áp dụng cho khách chưa đăng
    //   nhập — người dùng đã đăng nhập vẫn giữ nguyên ngôn ngữ họ tự chọn.
}

/**
 * Đặt ngôn ngữ mặc định (từ cấu hình chung) cho phiên ẩn danh.
 *
 * VÌ SAO CẦN?
 *   Trang đăng nhập (chưa có phiên) dùng $_SESSION['glpilanguage'] trực tiếp.
 *   Nếu chưa có giá trị, GLPI hiển thị tiếng Anh — dù Thiết lập chung đã là
 *   vi_VN. Hàm này gán giá trị mặc định để "Việt hoá" cả trang đăng nhập.
 *
 * @param mixed $data Tham số do GLPI truyền vào (không dùng)
 * @return void
 */
function plugin_dlubrand_set_default_language($data = null): void
{
    global $CFG_GLPI;

    // Đã có ngôn ngữ trong phiên (người dùng đã chọn) -> tôn trọng
    if (!empty($_SESSION['glpilanguage'])) {
        return;
    }

    // Lấy ngôn ngữ mặc định từ Thiết lập chung
    $default = $CFG_GLPI['language'] ?? 'en_GB';

    // Chỉ áp dụng nếu ngôn ngữ đó thực sự có trong danh sách GLPI hỗ trợ
    if (!empty($default) && isset($CFG_GLPI['languages'][$default])) {
        $_SESSION['glpilanguage'] = $default;
        // Nạp ngay bản dịch để các chuỗi __() trên trang đăng nhập
        // (tiêu đề, nhãn ô nhập, nút bấm) hiển thị đúng tiếng Việt.
        \Session::loadLanguage();
    }
}

/**
 * Thông tin phiên bản plugin — GLPI dùng để kiểm tra tương thích
 *
 * @return array
 */
function plugin_version_dlubrand(): array
{
    return [
        'name'           => 'DLU Brand — Giao diện Đà Lạt',
        'version'        => PLUGIN_DLUBRAND_VERSION,
        'author'         => 'Đồ án thực tập DLU',
        'license'        => 'GPLv3+',
        'homepage'       => '',
        'requirements'   => [
            'glpi' => [
                'min' => PLUGIN_DLUBRAND_MIN_GLPI,
                'max' => PLUGIN_DLUBRAND_MAX_GLPI,
            ],
        ],
    ];
}

/**
 * Kiểm tra điều kiện tiên quyết trước khi cài
 *
 * @return bool
 */
function plugin_dlubrand_check_prerequisites(): bool
{
    if (version_compare(GLPI_VERSION, PLUGIN_DLUBRAND_MIN_GLPI, '<')) {
        echo 'Plugin này cần GLPI >= ' . PLUGIN_DLUBRAND_MIN_GLPI;
        return false;
    }
    return true;
}

/**
 * Kiểm tra cấu hình — plugin này không cần cấu hình gì
 *
 * @return bool
 */
function plugin_dlubrand_check_config(): bool
{
    return true;
}

/**
 * Cài đặt plugin
 *
 * @return bool
 */
function plugin_dlubrand_install(): bool
{
    return true;
}

/**
 * Gỡ cài đặt plugin
 *
 * @return bool
 */
function plugin_dlubrand_uninstall(): bool
{
    return true;
}
