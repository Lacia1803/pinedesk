<?php

/**
 * -----------------------------------------------------------------------------
 *  Plugin "pinedesk" — Thực thi hạn mức nộp phiếu (T3/T4/T6)
 * -----------------------------------------------------------------------------
 *  Đồ án thực tập: Xây dựng hệ thống hỗ trợ kỹ thuật (PineDesk)
 *  Trường Đại học Đà Lạt
 *
 *  MỤC ĐÍCH:
 *    Biến bảng cấu hình hạn mức (glpi_plugin_pinedesk_limits) từ "trang trí"
 *    thành cơ chế CHẶN THẬT ngay tại thời điểm tạo phiếu:
 *      - T3: trần số phiếu đang mở + trần số phiếu mỗi ngày
 *      - T4: chặn phiếu trùng (cùng người + loại + vị trí trong cửa sổ cấu hình)
 *      - T6: ghi nhật ký MỌI lần tạo phiếu / bị chặn vào ticketlog
 *
 *  VÌ SAO LÀ PLUGIN NGOÀI LÕI:
 *    Dùng hook công khai PRE_ITEM_ADD / ITEM_ADD của GLPI. Khi nâng cấp GLPI,
 *    plugin vẫn nằm nguyên trong plugins/pinedesk/ — không sửa một dòng lõi nào.
 *
 *  CƠ CHẾ CHẶN (đã đọc mã nguồn GLPI 11 để xác minh):
 *    CommonDBTM::add() gọi hook PRE_ITEM_ADD (dòng 1334). Nếu hook gán
 *    $item->input = false thì add() dừng ngay, trả về false — phiếu KHÔNG được
 *    ghi vào CSDL. Xem thêm hook.php.
 *
 *  ĐỐI TƯỢNG ÁP DỤNG:
 *    Chỉ người dùng KHÔNG có quyền cập nhật phiếu (Self-Service: sinh viên,
 *    giảng viên). Kỹ thuật viên / quản trị (có quyền UPDATE) được miễn trừ.
 *    Phiếu do cron tự sinh (bảo trì định kỳ) cũng được miễn trừ.
 * -----------------------------------------------------------------------------
 */

use Glpi\Plugin\Hooks;

define('PLUGIN_PINEDESK_VERSION', '1.0.0');
define('PLUGIN_PINEDESK_MIN_GLPI', '11.0.0');
define('PLUGIN_PINEDESK_MAX_GLPI', '99.0.99');

// Tên bảng — khai báo một lần, dùng chung cho setup.php và hook.php
define('PLUGIN_PINEDESK_TABLE_LIMITS', 'glpi_plugin_pinedesk_limits');
define('PLUGIN_PINEDESK_TABLE_LOG', 'glpi_plugin_pinedesk_ticketlog');

/**
 * Khởi tạo plugin — đăng ký hook với GLPI
 *
 * @return void
 */
function plugin_init_pinedesk(): void
{
    global $PLUGIN_HOOKS;

    $plugin = new Plugin();
    if (!$plugin->isActivated('pinedesk')) {
        return;
    }

    // PRE_ITEM_ADD: kiểm tra hạn mức TRƯỚC khi phiếu được ghi.
    // Format: [itemtype => callable] — GLPI chỉ gọi khi item là Ticket.
    $PLUGIN_HOOKS[Hooks::PRE_ITEM_ADD]['pinedesk'] = [
        'Ticket' => 'plugin_pinedesk_check_limits',
    ];

    // ITEM_ADD: sau khi phiếu đã ghi thành công -> ghi nhật ký T6 (reason=NEW).
    $PLUGIN_HOOKS[Hooks::ITEM_ADD]['pinedesk'] = [
        'Ticket' => 'plugin_pinedesk_log_created',
    ];

    // Nhả khóa chống đua (GET_LOCK, xem hook.php) khi request kết thúc.
    // GET_LOCK gắn với kết nối CSDL; nhả ngay sau request để request sau của
    // cùng người dùng không phải chờ hết 3 giây timeout.
    //
    // Bọc trong closure + function_exists vì hook.php chỉ được GLPI nạp
    // "lười" (lần đầu có hook thật chạy — Plugin::doHook -> includeHook),
    // không nạp sẵn lúc plugin_init. Truyền thẳng tên hàm vào
    // register_shutdown_function lúc này sẽ fatal "not found" (PHP 8.4 kiểm
    // tra callback ngay khi đăng ký). Nếu hook.php chưa từng được nạp thì
    // cũng chưa từng có khóa nào -> no-op là đúng.
    register_shutdown_function(static function (): void {
        if (function_exists('plugin_pinedesk_release_lock')) {
            plugin_pinedesk_release_lock();
        }
    });
}

/**
 * Thông tin phiên bản plugin — GLPI dùng để kiểm tra tương thích
 *
 * @return array
 */
function plugin_version_pinedesk(): array
{
    return [
        'name'           => 'PineDesk — Hạn mức nộp phiếu',
        'version'        => PLUGIN_PINEDESK_VERSION,
        'author'         => 'Đồ án thực tập DLU',
        'license'        => 'GPLv3+',
        'homepage'       => '',
        'requirements'   => [
            'glpi' => [
                'min' => PLUGIN_PINEDESK_MIN_GLPI,
                'max' => PLUGIN_PINEDESK_MAX_GLPI,
            ],
        ],
    ];
}

/**
 * Kiểm tra điều kiện tiên quyết trước khi cài
 *
 * @return bool
 */
function plugin_pinedesk_check_prerequisites(): bool
{
    if (version_compare(GLPI_VERSION, PLUGIN_PINEDESK_MIN_GLPI, '<')) {
        echo 'Plugin này cần GLPI >= ' . PLUGIN_PINEDESK_MIN_GLPI;
        return false;
    }
    return true;
}

/**
 * Kiểm tra cấu hình — plugin chạy được ngay cả khi bảng chưa có
 * (hook sẽ tự dùng giá trị mặc định, xem hook.php)
 *
 * @return bool
 */
function plugin_pinedesk_check_config(): bool
{
    return true;
}

/**
 * Cài đặt plugin — tạo bảng nếu script SQL chưa chạy.
 *
 * Bảng do scripts/seed-sla-va-chong-lam-dung.sql tạo trước đó là bình thường;
 * ở đây dùng CREATE TABLE IF NOT EXISTS nên chạy đè không mất dữ liệu.
 *
 * @return bool
 */
function plugin_pinedesk_install(): bool
{
    global $DB;

    $charset = 'DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci';

    $DB->doQuery("CREATE TABLE IF NOT EXISTS `" . PLUGIN_PINEDESK_TABLE_LIMITS . "` (
        id                    INT UNSIGNED NOT NULL AUTO_INCREMENT,
        rule_name             VARCHAR(64)  NOT NULL,
        mo_ta                 VARCHAR(255)     NULL,
        so_phieu_mo_toi_da    INT          NOT NULL DEFAULT 5,
        so_phieu_ngay_toi_da  INT          NOT NULL DEFAULT 10,
        cua_so_trung_phut     INT          NOT NULL DEFAULT 30,
        is_active             TINYINT(1)   NOT NULL DEFAULT 1,
        date_mod              TIMESTAMP        NULL DEFAULT NULL,
        PRIMARY KEY (id),
        UNIQUE KEY uq_rule (rule_name)
    ) ENGINE=InnoDB $charset");

    $DB->doQuery("CREATE TABLE IF NOT EXISTS `" . PLUGIN_PINEDESK_TABLE_LOG . "` (
        id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
        users_id       INT UNSIGNED NOT NULL DEFAULT 0,
        tickets_id     INT UNSIGNED NOT NULL DEFAULT 0,
        ip_address     VARCHAR(45)      NULL,
        tickets_id_dup INT UNSIGNED     NOT NULL DEFAULT 0,
        reason         VARCHAR(64)      NULL COMMENT 'ly do: NEW / DUP_BLOCKED / LIMIT_BLOCKED',
        date_creation  TIMESTAMP        NULL DEFAULT NULL,
        PRIMARY KEY (id),
        KEY idx_user_date (users_id, date_creation),
        KEY idx_tickets   (tickets_id)
    ) ENGINE=InnoDB $charset");

    // Hạn mức mặc định — chỉ chèn khi chưa có dòng nào
    $res = $DB->doQuery("SELECT COUNT(*) AS n FROM `" . PLUGIN_PINEDESK_TABLE_LIMITS . "`");
    $row = $res->fetch_assoc();
    if ((int)($row['n'] ?? 0) === 0) {
        $DB->doQuery(
            "INSERT INTO `" . PLUGIN_PINEDESK_TABLE_LIMITS . "`
                (rule_name, mo_ta, so_phieu_mo_toi_da, so_phieu_ngay_toi_da,
                 cua_so_trung_phut, is_active, date_mod)
             VALUES ('mac_dinh',
                     'Hạn mức mặc định: tối đa 5 phiếu mở cùng lúc, 10 phiếu/ngày, cửa sổ chống trùng 30 phút',
                     5, 10, 30, 1, NOW())"
        );
    }

    return true;
}

/**
 * Gỡ cài đặt plugin — KHÔNG xoá bảng (giữ nhật ký + cấu hình cho người dùng)
 *
 * @return bool
 */
function plugin_pinedesk_uninstall(): bool
{
    return true;
}
