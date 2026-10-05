<?php

/**
 * -----------------------------------------------------------------------------
 *  Plugin "pinedesk" — hook.php: thực thi hạn mức nộp phiếu
 * -----------------------------------------------------------------------------
 *  File này được GLPI nạp khi có hook của plugin 'pinedesk' được kích hoạt
 *  (xem Plugin::includeHook — GLPI include_once plugins/pinedesk/hook.php).
 *
 *  HAI HOOK ĐƯỢC ĐĂNG KÝ (trong setup.php):
 *
 *    1. PRE_ITEM_ADD  -> plugin_pinedesk_check_limits($item)
 *       Chạy TRƯỚC khi phiếu được ghi vào CSDL (CommonDBTM::add, dòng 1334).
 *       Nếu vi phạm hạn mức: gán $item->input = false -> add() dừng ngay,
 *       trả về false — phiếu KHÔNG được ghi. Đây là "chặn thật", không phải
 *       cảnh báo sau khi đã ghi.
 *
 *    2. ITEM_ADD      -> plugin_pinedesk_log_created($item)
 *       Chạy SAU khi phiếu đã ghi thành công (CommonDBTM::add, dòng 1430).
 *       Ghi nhật ký T6 (reason=NEW) — biết ai tạo phiếu, khi nào.
 *
 *  ĐỐI TƯỢNG ÁP DỤNG (mọi điều kiện phải đúng mới kiểm tra):
 *    - Là phiếu (Ticket) tạo qua giao diện bởi người dùng đã đăng nhập
 *    - KHÔNG phải phiếu do cron tự sinh (bảo trì định kỳ — T2/B2)
 *    - KHÔNG có quyền cập nhật phiếu (ticket+UPDATE=2), đọc từ hồ sơ ĐANG
 *      hoạt động trong phiên. Kỹ thuật viên / quản trị tạo phiếu hộ thì được
 *      miễn — họ là người xử lý, không phải nguồn spam.
 *
 *  VÌ SAO KHÔNG DÙNG Session::haveRight:
 *    GLPI 11 tạo phiếu từ biểu mẫu (Service Catalog) qua
 *    AbstractCommonITILFormDestination.php:185:
 *        $id = Session::callAsSystem(fn() => $itil_object->add($input));
 *    callAsSystem bật cờ bypass quyền (Session.php:2427), và
 *    Session::haveRight trả về true vô điều kiện khi cờ bật
 *    (Session.php:1442). Nếu hook hỏi haveRight, MỌI phiếu tạo từ biểu mẫu
 *    đều bị coi là "có quyền UPDATE" và bỏ qua T3/T4 — đúng đường tạo phiếu
 *    mà sinh viên/giảng viên dùng. Vì vậy quyền được đọc thẳng từ
 *    $_SESSION['glpiactiveprofile']['ticket'] (callAsSystem không đổi biến
 *    phiên này).
 *
 *  NGUYÊN TẮC AN TOÀN:
 *    - Bảng cấu hình thiếu -> dùng hạn mức mặc định (5/10/30), vẫn bảo vệ.
 *    - Lỗi bất ngờ khi truy vấn -> fail-open (cho phiếu đi qua) + ghi log lỗi.
 *      Cơ chế chống lạm dụng KHÔNG được phép làm hỏng chức năng cốt lõi.
 *      RIÊNG việc ghi nhật ký T6 nằm sau chốt chặn: lỗi ghi log không được
 *      làm mất chốt chặn.
 * -----------------------------------------------------------------------------
 */

/**
 * Hook PRE_ITEM_ADD — kiểm tra hạn mức trước khi phiếu được ghi.
 *
 * @param mixed $item Đối tượng đang được add (GLPI truyền vào)
 * @return void
 */
function plugin_pinedesk_check_limits($item): void
{
    // Chỉ áp dụng cho phiếu
    if (!($item instanceof Ticket)) {
        return;
    }

    // Input phải là mảng (nếu plugin khác đã chặn trước -> bỏ qua)
    if (!is_array($item->input)) {
        return;
    }

    // Phiếu do hệ thống tự sinh (cron bảo trì) -> miễn.
    // LƯU Ý: KHÔNG dùng cờ _auto_import / _skip_auto_assign từ input —
    // đây là các khóa do CLIENT gửi (front/ticket.form.php đưa nguyên $_POST
    // vào add()), thêm chúng vào POST là đủ để tự miễn trừ nếu tin.
    if (Session::isCron()) {
        return;
    }

    // Phải là người dùng đã đăng nhập (T2 đảm bảo điều này ở giao diện;
    // đây là chốt an toàn thứ hai)
    $uid = (int) Session::getLoginUserID();
    if ($uid <= 0) {
        return;
    }

    // Kỹ thuật viên / quản trị (có quyền UPDATE phiếu) -> miễn trừ.
    // Đọc thẳng từ phiên, KHÔNG qua haveRight (bị callAsSystem vô hiệu hóa —
    // xem ghi chú đầu file).
    $ticket_right = (int) ($_SESSION['glpiactiveprofile']['ticket'] ?? 0);
    if (($ticket_right & UPDATE) === UPDATE) {
        return;
    }

    // ---- Vệ sinh dữ liệu do client gửi trước khi kiểm tra ------------------
    // Cột `date` (và `date_creation`) do người dùng gửi được core chấp nhận
    // (checkFieldsConsistency chỉ kiểm định dạng; computeDefaultValuesForAdd
    // chỉ điền khi rỗng) -> người dùng có thể lùi ngày để né trần ngày và
    // cửa sổ chống trùng. `status` cũng do client gửi (không guard) -> tạo
    // phiếu status=6 (Đã đóng) để né trần phiếu mở.
    // Chặn đứng bằng cách ép các cột hệ thống về giá trị chuẩn:
    //   - date: luôn lấy giờ hiện tại của phiên (mọi phiếu tạo qua giao diện
    //     đều là "bây giờ"; nhập liệu lịch sử là việc của công cụ nhập liệu,
    //     không phải đường này)
    //   - date_creation: gỡ bỏ nếu có, để core tự điền
    //   - status: gỡ bỏ nếu client gửi, để core mặc định (Mới=1)
    if (isset($item->input['date'])) {
        $item->input['date'] = $_SESSION['glpi_currenttime'] ?? date('Y-m-d H:i:s');
    }
    if (isset($item->input['date_creation'])) {
        unset($item->input['date_creation']);
    }
    if (isset($item->input['status'])) {
        unset($item->input['status']);
    }

    // Khóa điều khiển nội bộ của GLPI: CLIENT KHÔNG ĐƯỢC gửi.
    //   - _auto_import: core bỏ qua việc gán users_id_recipient và miễn kiểm
    //     tra trường bắt buộc khi cờ có mặt -> phiếu lưu với recipient=0,
    //     vô hình với mọi truy vấn đếm của plugin (T3/T4 hụt).
    //   - _skip_auto_assign: core bỏ qua gán users_id_recipient -> recipient=0.
    // Gỡ trước khi core xử lý, để phiếu được đối xử như phiếu người dùng thường.
    unset($item->input['_auto_import'], $item->input['_skip_auto_assign']);

    // Ép người nhận = người đang đăng nhập: phiếu của ai tính cho người đó,
    // không thể tạo phiếu "vô chủ" để né hạn mức.
    $item->input['users_id_recipient'] = $uid;

    // Ghi nhớ khóa GET_LOCK đã lấy để nhả ở cuối request (xem
    // plugin_pinedesk_release_lock — đăng ký trong setup.php).
    global $DB, $PLUGIN_PINEDESK_LOCK_NAME;

    try {
        // ---- Khóa chống đua (TOCTOU) ---------------------------------------
        // Kiểm tra ở PRE_ITEM_ADD rồi mới INSERT (không transaction trong
        // CommonDBTM::add) -> 2 phiên song song cùng đọc count=4 < 5 rồi cùng
        // ghi. GET_LOCK của MariaDB là khóa liên kết (cross-connection): mỗi
        // người dùng có một khóa riêng, tuần tự hóa việc kiểm tra + ghi.
        // GET_LOCK lồng nhau trên cùng kết nối là reentrant (đã kiểm chứng
        // với MariaDB 10.11) nên an toàn khi 1 request tạo nhiều phiếu.
        // Không lấy được khóa trong 3s -> fail-open (không chặn oan).
        $lock = 'pinedesk_hm_' . $uid;
        $res  = $DB->doQuery("SELECT GET_LOCK('" . $DB->escape($lock) . "', 3) AS ok");
        $row  = $res ? $DB->fetchAssoc($res) : null;
        if ((int) ($row['ok'] ?? 0) !== 1) {
            Toolbox::logInFile('pinedesk', "Khong lay duoc khoa han muc cho user $uid — bo qua kiem tra", true);
            return;
        }
        $PLUGIN_PINEDESK_LOCK_NAME = $lock;

        $limits  = plugin_pinedesk_get_limits();
        $reason  = '';
        $message = '';
        $dup_id  = 0;

        // ---- T3a: trần số phiếu ĐANG MỞ -------------------------------------
        if ($limits['max_open'] > 0) {
            $open = plugin_pinedesk_count_open($uid);
            if ($open >= $limits['max_open']) {
                $reason  = 'LIMIT_BLOCKED';
                $message = sprintf(
                    'Bạn đang có %d phiếu chưa xử lý xong (hạn mức %d). '
                    . 'Vui lòng chờ kỹ thuật viên xử lý, hoặc bổ sung nội dung '
                    . 'vào phiếu đang mở thay vì tạo phiếu mới.',
                    $open,
                    $limits['max_open']
                );
            }
        }

        // ---- T3b: trần số phiếu MỖI NGÀY ------------------------------------
        if ($reason === '' && $limits['max_day'] > 0) {
            $today = plugin_pinedesk_count_today($uid);
            if ($today >= $limits['max_day']) {
                $reason  = 'LIMIT_BLOCKED';
                $message = sprintf(
                    'Hôm nay bạn đã gửi %d phiếu (hạn mức %d phiếu/ngày). '
                    . 'Vui lòng thử lại vào ngày mai, hoặc liên hệ trực tiếp '
                    . 'Trung tâm CNTT nếu sự cố khẩn cấp.',
                    $today,
                    $limits['max_day']
                );
            }
        }

        // ---- T4: phiếu TRÙNG (trong cửa sổ N phút) --------------------------
        // Trùng khi cùng người tạo VÀ:
        //   (a) cùng thiết bị (gắn qua items_id), hoặc
        //   (b) cùng loại sự cố + cùng vị trí (cả hai > 0).
        // Phiếu không có thiết bị, không có vị trí -> không đủ căn cứ kết luận
        // trùng, bỏ qua (tránh chặn oan — xem plugin_pinedesk_find_duplicate).
        if ($reason === '' && $limits['window_min'] > 0) {
            $cat      = (int) ($item->input['itilcategories_id'] ?? 0);
            $loc      = (int) ($item->input['locations_id'] ?? 0);
            $item_ids = plugin_pinedesk_extract_items($item->input);
            $dup_id   = plugin_pinedesk_find_duplicate($uid, $cat, $loc, $item_ids, $limits['window_min']);
            if ($dup_id > 0) {
                $reason  = 'DUP_BLOCKED';
                $message = sprintf(
                    'Bạn vừa gửi một phiếu trùng (cùng thiết bị, hoặc cùng loại sự cố và vị trí) '
                    . 'trong vòng %d phút qua (phiếu #%d). Vui lòng theo dõi '
                    . 'và bổ sung thông tin vào phiếu đó thay vì tạo phiếu mới.',
                    $limits['window_min'],
                    $dup_id
                );
            }
        }

        // ---- Vi phạm -> CHẶN trước, ghi nhật ký sau -------------------------
        // Chốt chặn phải được ghi TRƯỚC khi ghi log: nếu insert log ném lỗi
        // (DBmysql::doQuery throw RuntimeException khi query lỗi), catch
        // fail-open sẽ nuốt lỗi — nhưng khi đó phiếu vi phạm đã bị chặn rồi.
        if ($reason !== '') {
            // Chốt chặn: CommonDBTM::add() thấy input=false sẽ dừng và trả false
            $item->input = false;

            // Thông báo + nhật ký là việc phụ, lỗi ở đây không được phá chốt chặn
            try {
                Session::addMessageAfterRedirect($message, false, ERROR);
                plugin_pinedesk_write_log($uid, 0, $dup_id, $reason);
            } catch (\Throwable $e) {
                Toolbox::logInFile('pinedesk', 'Loi ghi nhat ky chan: ' . $e->getMessage(), true);
            }
        }
    } catch (\Throwable $e) {
        // Fail-open: cơ chế chống lạm dụng không được làm hỏng việc nộp phiếu
        Toolbox::logInFile('pinedesk', 'Loi kiem tra han muc: ' . $e->getMessage(), true);
    }
}

/**
 * Hook ITEM_ADD — ghi nhật ký T6 sau khi phiếu đã tạo thành công.
 *
 * @param mixed $item Đối tượng vừa được add
 * @return void
 */
function plugin_pinedesk_log_created($item): void
{
    if (!($item instanceof Ticket)) {
        return;
    }

    if (Session::isCron()) {
        return;
    }

    $uid = (int) Session::getLoginUserID();
    if ($uid <= 0) {
        return;
    }

    try {
        plugin_pinedesk_write_log($uid, (int) $item->getID(), 0, 'NEW');
    } catch (\Throwable $e) {
        Toolbox::logInFile('pinedesk', 'Loi ghi nhat ky tao phieu: ' . $e->getMessage(), true);
    }
}

/**
 * Nhả khóa GET_LOCK đã lấy ở PRE_ITEM_ADD (đăng ký vào sự kiện cuối request
 * trong setup.php). Đăng ký ở đây để lock không bị giữ đến lúc kết nối
 * đóng — nhả sớm giúp các request khác của cùng user không phải chờ.
 *
 * @return void
 */
function plugin_pinedesk_release_lock(): void
{
    global $DB, $PLUGIN_PINEDESK_LOCK_NAME;

    if (empty($PLUGIN_PINEDESK_LOCK_NAME)) {
        return;
    }

    $lock = $PLUGIN_PINEDESK_LOCK_NAME;
    $PLUGIN_PINEDESK_LOCK_NAME = null;

    try {
        if ($DB instanceof DBmysql) {
            $DB->doQuery("SELECT RELEASE_LOCK('" . $DB->escape($lock) . "')");
        }
    } catch (\Throwable $e) {
        // Nhả khóa thất bại: kết nối đóng sẽ tự nhả (GET_LOCK gắn với kết nối)
        Toolbox::logInFile('pinedesk', 'Loi nha khoa han muc: ' . $e->getMessage(), true);
    }
}

/**
 * Trích danh sách thiết bị (itemtype + items_id) từ input phiếu.
 * Hỗ trợ cả hai dạng:
 *   - items_id => ['Computer' => [16, 17], 'Monitor' => [3]]  (giao diện chuẩn + Form)
 *   - items_id => [16, 17] kèm itemtype => 'Computer'          (API cũ)
 *
 * @param array $input
 * @return array<int, array{itemtype:string, items_id:int}>
 */
function plugin_pinedesk_extract_items(array $input): array
{
    $items = [];

    $raw = $input['items_id'] ?? null;
    if (is_array($raw)) {
        // Dạng ['Computer' => [16, 17]] (mảng lồng theo itemtype)
        $is_nested = false;
        foreach ($raw as $k => $v) {
            if (is_string($k) && is_array($v)) {
                $is_nested = true;
                break;
            }
        }
        if ($is_nested) {
            foreach ($raw as $itemtype => $ids) {
                foreach ((array) $ids as $id) {
                    $id = (int) $id;
                    if ($id > 0) {
                        $items[] = ['itemtype' => (string) $itemtype, 'items_id' => $id];
                    }
                }
            }
        } else {
            // Dạng [16, 17] + itemtype riêng
            $itemtype = (string) ($input['itemtype'] ?? '');
            foreach ($raw as $id) {
                $id = (int) $id;
                if ($id > 0 && $itemtype !== '') {
                    $items[] = ['itemtype' => $itemtype, 'items_id' => $id];
                }
            }
        }
    }

    return $items;
}

/**
 * Đọc hạn mức đang áp dụng từ bảng cấu hình.
 * Thiếu bảng / thiếu dòng / lỗi -> dùng giá trị mặc định (5/10/30).
 *
 * @return array{max_open:int, max_day:int, window_min:int}
 */
function plugin_pinedesk_get_limits(): array
{
    $defaults = ['max_open' => 5, 'max_day' => 10, 'window_min' => 30];

    global $DB;

    if (!($DB instanceof DBmysql) || !$DB->tableExists(PLUGIN_PINEDESK_TABLE_LIMITS)) {
        return $defaults;
    }

    $res = $DB->doQuery(
        "SELECT so_phieu_mo_toi_da, so_phieu_ngay_toi_da, cua_so_trung_phut
           FROM `" . PLUGIN_PINEDESK_TABLE_LIMITS . "`
          WHERE rule_name = 'mac_dinh' AND is_active = 1
          LIMIT 1"
    );

    if (!$res || $DB->numrows($res) === 0) {
        return $defaults;
    }

    $row = $DB->fetchAssoc($res);
    if (!is_array($row)) {
        return $defaults;
    }

    return [
        'max_open'   => max(0, (int) ($row['so_phieu_mo_toi_da'] ?? $defaults['max_open'])),
        'max_day'    => max(0, (int) ($row['so_phieu_ngay_toi_da'] ?? $defaults['max_day'])),
        'window_min' => max(0, (int) ($row['cua_so_trung_phut'] ?? $defaults['window_min'])),
    ];
}

/**
 * Đếm số phiếu ĐANG MỞ của một người.
 * "Đang mở" = trạng thái Mới/Được giao/Đã lên kế hoạch/Chờ (1-4),
 * giống hệt view v_pinedesk_phieu_dang_mo.
 *
 * @param int $uid users_id
 * @return int
 */
function plugin_pinedesk_count_open(int $uid): int
{
    global $DB;

    $res = $DB->doQuery(
        "SELECT COUNT(*) AS n FROM glpi_tickets
          WHERE is_deleted = 0
            AND users_id_recipient = " . $uid . "
            AND status IN (1, 2, 3, 4)"
    );
    $row = $res ? $DB->fetchAssoc($res) : null;

    return (int) ($row['n'] ?? 0);
}

/**
 * Đếm số phiếu một người đã tạo TRONG NGÀY (tính từ 00:00 hôm nay).
 *
 * @param int $uid users_id
 * @return int
 */
function plugin_pinedesk_count_today(int $uid): int
{
    global $DB;

    $res = $DB->doQuery(
        "SELECT COUNT(*) AS n FROM glpi_tickets
          WHERE is_deleted = 0
            AND users_id_recipient = " . $uid . "
            AND date >= CURDATE()"
    );
    $row = $res ? $DB->fetchAssoc($res) : null;

    return (int) ($row['n'] ?? 0);
}

/**
 * Tìm phiếu CÒN MỞ trùng với phiếu đang tạo trong cửa sổ N phút:
 *   - Cùng người tạo
 *   - Cùng loại sự cố (nếu phiếu mới có loại)
 *   - Trùng khi: (a) cùng thiết bị (nếu phiếu mới có thiết bị), hoặc
 *                (b) cùng loại + cùng vị trí (cả hai > 0)
 *   - Phiếu mới không có cả thiết bị lẫn vị trí -> không đủ căn cứ kết luận
 *     trùng, trả 0 (tránh chặn oan phiếu chỉ trùng loại sự cố).
 *
 * Phiếu đã Giải quyết/Đã đóng (5,6) không tính — nộp lại sau khi xử lý
 * xong là hợp lệ.
 *
 * @param int   $uid        users_id
 * @param int   $cat        itilcategories_id (0 nếu không có)
 * @param int   $loc        locations_id (0 nếu không có)
 * @param array $items      [{itemtype, items_id}, ...] thiết bị của phiếu mới
 * @param int   $window_min cửa sổ phút
 * @return int tickets_id của phiếu trùng (0 nếu không có)
 */
function plugin_pinedesk_find_duplicate(int $uid, int $cat, int $loc, array $items, int $window_min): int
{
    global $DB;

    // Các phiếu còn mở của cùng người trong cửa sổ, cùng loại (nếu có loại)
    $where = "is_deleted = 0
            AND users_id_recipient = " . $uid . "
            AND status NOT IN (5, 6)
            AND date >= DATE_SUB(NOW(), INTERVAL " . $window_min . " MINUTE)";
    if ($cat > 0) {
        $where .= " AND itilcategories_id = " . $cat;
    }

    $res = $DB->doQuery("SELECT id FROM glpi_tickets WHERE $where ORDER BY id DESC LIMIT 50");
    if (!$res || $DB->numrows($res) === 0) {
        return 0;
    }

    $candidates = [];
    while ($row = $DB->fetchAssoc($res)) {
        $candidates[] = (int) $row['id'];
    }

    // Phiếu mới không có thiết bị lẫn vị trí -> không đủ căn cứ, bỏ qua
    if (count($items) === 0 && $loc <= 0) {
        return 0;
    }

    // (a) Cùng thiết bị: tra glpi_items_tickets của các phiếu ứng viên
    if (count($items) > 0) {
        $ids   = array_map('intval', $candidates);
        $pairs = [];
        foreach ($items as $it) {
            $pairs[] = "(`itemtype` = '" . $DB->escape($it['itemtype']) . "' AND `items_id` = " . (int) $it['items_id'] . ")";
        }

        $res = $DB->doQuery(
            "SELECT tickets_id FROM glpi_items_tickets
              WHERE tickets_id IN (" . implode(',', $ids) . ")
                AND (" . implode(' OR ', $pairs) . ")
              ORDER BY tickets_id DESC
              LIMIT 1"
        );
        $row = $res ? $DB->fetchAssoc($res) : null;
        if ((int) ($row['tickets_id'] ?? 0) > 0) {
            return (int) $row['tickets_id'];
        }
    }

    // (b) Cùng loại + cùng vị trí: cần cả hai > 0 (một mình vị trí là căn cứ
    // yếu — cùng phòng có thể là hai sự cố khác nhau; khớp với chỉ số T4 của
    // scripts/kiem-tra-lam-dung.sh: "cùng người + cùng loại + cùng vị trí").
    if ($cat > 0 && $loc > 0) {
        $res = $DB->doQuery(
            "SELECT id FROM glpi_tickets
              WHERE id IN (" . implode(',', array_map('intval', $candidates)) . ")
                AND locations_id = " . $loc . "
              ORDER BY id DESC
              LIMIT 1"
        );
        $row = $res ? $DB->fetchAssoc($res) : null;
        if ((int) ($row['id'] ?? 0) > 0) {
            return (int) $row['id'];
        }
    }

    return 0;
}

/**
 * Ghi một dòng nhật ký vào bảng ticketlog (T6).
 *
 * @param int    $uid       users_id
 * @param int    $ticket_id tickets_id (0 nếu phiếu bị chặn — chưa tồn tại)
 * @param int    $dup_id    tickets_id_dup (phiếu trùng, nếu có)
 * @param string $reason    NEW / LIMIT_BLOCKED / DUP_BLOCKED
 * @return void
 */
function plugin_pinedesk_write_log(int $uid, int $ticket_id, int $dup_id, string $reason): void
{
    global $DB;

    if (!($DB instanceof DBmysql) || !$DB->tableExists(PLUGIN_PINEDESK_TABLE_LOG)) {
        return;
    }

    // Dia chi IP that cua nguoi dung:
    //   - Khi request di qua nginx gateway (moi request deu qua), REMOTE_ADDR
    //     trong GLPI la IP NOI BO cua container nginx (172.x) -> vo nghia cho
    //     truy vet. nginx ghi dia chi that vao X-Forwarded-For (GHI DE bang
    //     $remote_addr, xem nginx/conf.d/default.conf) nen doc XFF la dung.
    //   - Doc XFF truoc, REMOTE_ADDR lam phuong an cuoi (vd: cron/noi bo).
    //   - Cat lay phan tu dau tien neu chuoi XFF co nhieu IP.
    $ip = $_SERVER['HTTP_X_FORWARDED_FOR']
        ?? $_SERVER['HTTP_X_REAL_IP']
        ?? $_SERVER['REMOTE_ADDR']
        ?? '';
    if (is_string($ip) && str_contains($ip, ',')) {
        $ip = trim(explode(',', $ip)[0]);
    }
    $ip = is_string($ip) && $ip !== '' ? substr($ip, 0, 45) : null;

    $now = $_SESSION['glpi_currenttime'] ?? date('Y-m-d H:i:s');

    $DB->insert(
        PLUGIN_PINEDESK_TABLE_LOG,
        [
            'users_id'       => $uid,
            'tickets_id'     => $ticket_id,
            'ip_address'     => $ip,
            'tickets_id_dup' => $dup_id,
            'reason'         => $reason,
            'date_creation'  => $now,
        ]
    );
}
