<?php

/**
 * -----------------------------------------------------------------------------
 *  HARNESS KIỂM THỬ — Plugin pinedesk (thực thi hạn mức nộp phiếu)
 * -----------------------------------------------------------------------------
 *  Chạy TRONG container GLPI:
 *
 *      docker exec -u www-data pinedesk-glpi \
 *          php /var/www/glpi/plugins/pinedesk/tests/kiem-thu-han-muc.php
 *
 *  Kịch bản (chạy trên CSDL THẬT, tự dọn dẹp sau khi xong):
 *
 *    1. Tạo 5 user tạm (Self-Service — quyền ticket không có UPDATE)
 *    2. User A tạo 5 phiếu hợp lệ -> tất cả phải thành công
 *    3. User A tạo phiếu thứ 6 -> PHẢI BỊ CHẶN (LIMIT_BLOCKED) — trần phiếu mở
 *    4. User B tạo phiếu trùng loại + vị trí -> PHẢI BỊ CHẶN (DUP_BLOCKED)
 *    4b. User D: trùng theo THIẾT BỊ (không vị trí); thiết bị khác và
 *        "không thiết bị/không vị trí" -> KHÔNG bị chặn (không chặn oan)
 *    4c. User C: hạ tạm trần ngày xuống 2 -> phiếu thứ 3 trong ngày bị chặn (T3b)
 *    4d. User E: gửi kèm date lùi / status=6 / _skip_auto_assign / _auto_import
 *        -> phiếu vẫn tạo được nhưng các trường bị ép về giá trị chuẩn
 *    5. User có quyền UPDATE (kỹ thuật viên profile 6) tạo phiếu -> KHÔNG bị chặn
 *    6. Phiếu do cron tạo -> KHÔNG bị chặn
 *    7. Kiểm tra nhật ký T6 + dọn dẹp: xoá phiếu, user tạm, MỌI dòng nhật ký
 *       phát sinh trong lần chạy (theo mốc id đầu lần chạy)
 *
 *  Kết quả: exit 0 nếu mọi kịch bản đạt, exit 1 nếu có kịch bản thất bại.
 * -----------------------------------------------------------------------------
 */

define('PLUGIN_PINEDESK_TEST_TAG', '[TEST-HAN-MUC]');

// Bat output buffering NGAY tu dau: Session::init() goi session_start() sau khi
// da co output se vo (headers already sent). Giu buffer den het script -> khong
// bao gio headers_sent() = true, ke ca khi dang xuat / dang nhap lai nhieu lan.
ob_start();

$failures = [];
$checks   = 0;

/**
 * In dòng kiểm tra và ghi nhận thất bại.
 */
function check(bool $ok, string $label): void
{
    global $failures, $checks;
    $checks++;
    if ($ok) {
        echo "  [OK]  $label\n";
    } else {
        echo "  [FAIL] $label\n";
        $failures[] = $label;
    }
}

echo "=====================================================\n";
echo "  KIEM THU PLUGIN PINEDESK — HAN MUC NOP PHIEU\n";
echo "=====================================================\n\n";

// -----------------------------------------------------------------------------
// Bootstrap GLPI (khong co output truoc session_start)
// -----------------------------------------------------------------------------
require_once '/var/www/glpi/vendor/autoload.php';

use Glpi\Kernel\Kernel;

$kernel = new Kernel();
$kernel->boot();

// Nap hook.php de goi truc tiep cac ham kiem tra (GLPI chi include hook.php
// khi co hook that su chay; harness goi ham nen phai nap truoc).
require_once '/var/www/glpi/plugins/pinedesk/hook.php';

global $DB;

// Moc nhat ky truoc khi chay: buoc don dep se xoa MOI dong ticketlog co id lon
// hon moc nay. Ban cu chi xoa theo users_id ($uid_a, $uid_b) nen dong do
// KTV/super-admin tao ra trong luc kiem thu bi bo sot (ro ri 1 dong/lan chay).
$res = $DB->doQuery("SELECT COALESCE(MAX(id), 0) AS m FROM " . PLUGIN_PINEDESK_TABLE_LOG);
$row = $res ? $DB->fetchAssoc($res) : null;
$log_id_before = is_array($row) ? (int) ($row['m'] ?? 0) : 0;

// Anh chup han muc dang ap dung — de khoi phuc sau khi kiem thu tam doi so.
$res = $DB->doQuery(
    "SELECT so_phieu_mo_toi_da, so_phieu_ngay_toi_da, cua_so_trung_phut
       FROM " . PLUGIN_PINEDESK_TABLE_LIMITS . "
      WHERE rule_name = 'mac_dinh' LIMIT 1"
);
$lim_row = $res ? $DB->fetchAssoc($res) : null;
$LIM_SNAP = [
    'open' => is_array($lim_row) ? (int) ($lim_row['so_phieu_mo_toi_da'] ?? 5) : 5,
    'day'  => is_array($lim_row) ? (int) ($lim_row['so_phieu_ngay_toi_da'] ?? 10) : 10,
    'win'  => is_array($lim_row) ? (int) ($lim_row['cua_so_trung_phut'] ?? 30) : 30,
];

// Ep han muc ve bo mac dinh cua do an (5/10/30) trong suot lan kiem thu:
// mot lan chay truoc bi chet giua chung (chua kip khoi phuc) khong lam sai
// ket qua lan nay.
$DB->doQuery(
    "UPDATE " . PLUGIN_PINEDESK_TABLE_LIMITS . "
        SET so_phieu_mo_toi_da = 5, so_phieu_ngay_toi_da = 10, cua_so_trung_phut = 30
      WHERE rule_name = 'mac_dinh'"
);

// Luoi an toan: neu script chet giua chung, van khoi phuc han muc goc.
register_shutdown_function(static function () use ($DB, $LIM_SNAP): void {
    try {
        $DB->doQuery(
            "UPDATE " . PLUGIN_PINEDESK_TABLE_LIMITS . "
                SET so_phieu_mo_toi_da = " . $LIM_SNAP['open'] . ",
                    so_phieu_ngay_toi_da = " . $LIM_SNAP['day'] . ",
                    cua_so_trung_phut = " . $LIM_SNAP['win'] . "
              WHERE rule_name = 'mac_dinh'"
        );
    } catch (\Throwable $e) {
        // Khong the khoi phuc (vd: mat ket noi) — bo qua.
    }
});

/**
 * Dang nhap mot user theo id.
 */
function test_login(int $user_id): void
{
    $user = new User();
    $user->getFromDB($user_id);

    $auth = new Auth();
    $auth->auth_succeded = true;
    $auth->user = $user;
    Session::init($auth);
}

/**
 * Dang xuat (xoa phien).
 */
function test_logout(): void
{
    Session::destroy();
    session_unset();
}

// -----------------------------------------------------------------------------
// 0. Tien quyet: plugin da bat + bang ton tai
// -----------------------------------------------------------------------------
echo "--- 0. Tien quyet ---\n";

$plugin = new Plugin();
check($plugin->isActivated('pinedesk'), 'Plugin pinedesk da duoc bat');
check($DB->tableExists(PLUGIN_PINEDESK_TABLE_LIMITS), 'Bang han muc ton tai');
check($DB->tableExists(PLUGIN_PINEDESK_TABLE_LOG), 'Bang nhat ky ton tai');

// Kiem chung ham doc THAT SU tu bang (khong phai gia tri mac dinh hardcode):
// tam doi "so phieu mo toi da" 5 -> 7; ham phai tra ve 7, roi khoi phuc.
// Cach cu (check === 5) khong chung minh duoc gi vi gia tri mac dinh trong
// hook.php cung la 5 — cau assert cu luon PASS ke ca khi bang bi thieu.
$DB->doQuery("UPDATE " . PLUGIN_PINEDESK_TABLE_LIMITS . " SET so_phieu_mo_toi_da = 7 WHERE rule_name = 'mac_dinh'");
$probe = plugin_pinedesk_get_limits();
check($probe['max_open'] === 7, 'get_limits doc tu bang: doi so 5 -> 7, ham tra ve ' . $probe['max_open']);
$DB->doQuery("UPDATE " . PLUGIN_PINEDESK_TABLE_LIMITS . " SET so_phieu_mo_toi_da = 5 WHERE rule_name = 'mac_dinh'");

$limits = plugin_pinedesk_get_limits();
echo "  Han muc hien hanh: mo=${limits['max_open']} ngay=${limits['max_day']} cua_so=${limits['window_min']}p\n";

// Luu gia tri de kich ban dung so that
$MAX_OPEN = $limits['max_open'];
$WIN_MIN  = $limits['window_min'];

// -----------------------------------------------------------------------------
// 1. Tao user tam (Self-Service)
// -----------------------------------------------------------------------------
echo "\n--- 1. Tao 5 user tam (Self-Service) ---\n";

$suffix  = substr((string) time(), -6);
$uname_a = 'test.hm.a.' . $suffix;
$uname_b = 'test.hm.b.' . $suffix;
$uname_c = 'test.hm.c.' . $suffix;
$uname_d = 'test.hm.d.' . $suffix;
$uname_e = 'test.hm.e.' . $suffix;

$profile_self = 1;   // "Nguoi dung" (Self-Service) — da kiem chung quyen ticket = 5

$ids = [];
foreach (['a' => $uname_a, 'b' => $uname_b, 'c' => $uname_c, 'd' => $uname_d, 'e' => $uname_e] as $key => $uname) {
    $u = new User();
    $uid = $u->add([
        'name'         => $uname,
        'password'     => 'Test@' . $suffix,
        'password2'    => 'Test@' . $suffix,
        '_profiles_id' => $profile_self,
        'is_active'    => 1,
    ]);
    $ids[$key] = (int) $uid;
    check($uid > 0, "Tao user tam '$uname' (id=$uid)");
}
$uid_a = $ids['a'];
$uid_b = $ids['b'];
$uid_c = $ids['c'];
$uid_d = $ids['d'];
$uid_e = $ids['e'];

// Tim super-admin (profile 4) — de loai khoi vai tro KTV
$admin_id = 0;
$res = $DB->doQuery(
    "SELECT u.id FROM glpi_users u
      JOIN glpi_profiles_users pu ON pu.users_id = u.id
     WHERE pu.profiles_id = 4 AND u.is_active = 1
     ORDER BY u.id LIMIT 1"
);
if ($res && ($row = $DB->fetchAssoc($res))) {
    $admin_id = (int) $row['id'];
}

// Tim ky thuat vien THAT: profile 6 (Ky thuat vien), KHONG phai super-admin.
// Ban cu khong loc profile nen ham y chon trung super-admin (id=2) — mien tru
// van dung nhung khong dai dien cho vai tro KTV that.
$ktv_id = 0;
$res = $DB->doQuery(
    "SELECT u.id FROM glpi_users u
      JOIN glpi_profiles_users pu ON pu.users_id = u.id
      JOIN glpi_profilerights r ON r.profiles_id = pu.profiles_id
     WHERE r.name = 'ticket' AND (r.rights & 2) = 2
       AND pu.profiles_id = 6
       AND u.is_active = 1
     ORDER BY u.id LIMIT 1"
);
if ($res && ($row = $DB->fetchAssoc($res))) {
    $ktv_id = (int) $row['id'];
}
check($ktv_id > 0 && $ktv_id !== $admin_id, "Tim duoc KTV that (profile 6, khong phai super-admin, id=$ktv_id)");

// Danh muc de tao phieu: lay 1 category + 1 location that
$cat_id = 0;
$res = $DB->doQuery("SELECT id FROM glpi_itilcategories WHERE name = 'Bảo trì phòng máy' LIMIT 1");
if ($res && ($row = $DB->fetchAssoc($res))) {
    $cat_id = (int) $row['id'];
}
if ($cat_id === 0) {
    $res = $DB->doQuery("SELECT id FROM glpi_itilcategories WHERE is_request = 1 LIMIT 1");
    if ($res && ($row = $DB->fetchAssoc($res))) {
        $cat_id = (int) $row['id'];
    }
}
check($cat_id > 0, "Co loai su co that (id=$cat_id)");

$loc_id = 0;
$res = $DB->doQuery("SELECT id FROM glpi_locations WHERE level = 3 LIMIT 1");
if ($res && ($row = $DB->fetchAssoc($res))) {
    $loc_id = (int) $row['id'];
}

// Hai thiet bi that (cho kich ban trung theo thiet bi — T4 nhanh items_id)
$comp1_id = 0;
$comp2_id = 0;
$res = $DB->doQuery("SELECT id FROM glpi_computers WHERE is_deleted = 0 AND is_template = 0 ORDER BY id LIMIT 2");
if ($res) {
    $rows = [];
    while ($row = $DB->fetchAssoc($res)) {
        $rows[] = (int) $row['id'];
    }
    $comp1_id = $rows[0] ?? 0;
    $comp2_id = $rows[1] ?? 0;
}
check($comp1_id > 0 && $comp2_id > 0, "Co 2 thiet bi that de kiem trung theo thiet bi (id=$comp1_id, $comp2_id)");

// -----------------------------------------------------------------------------
// 2. User A: tao $MAX_OPEN phieu -> thanh cong het
// -----------------------------------------------------------------------------
echo "\n--- 2. User A tao $MAX_OPEN phieu hop le ---\n";

test_login($uid_a);

$tickets_a = [];
$all_ok = true;
for ($i = 1; $i <= $MAX_OPEN; $i++) {
    $t = new Ticket();
    // Moi phieu mot loai su co KHAC NHAU + vi tri khac de tranh dinh T4
    $cat_i = $cat_id;
    $res = $DB->doQuery("SELECT id FROM glpi_itilcategories WHERE is_request = 1 ORDER BY id LIMIT 1 OFFSET " . ($i % 5));
    if ($res && ($row = $DB->fetchAssoc($res))) {
        $cat_i = (int) $row['id'];
    }
    $tid = $t->add([
        'name'               => PLUGIN_PINEDESK_TEST_TAG . " Phieu hop le $i",
        'content'            => 'Phieu kiem thu tu dong - se duoc xoa sau khi chay.',
        'type'               => 1, // Incident
        'itilcategories_id'  => $cat_i,
        'locations_id'       => $loc_id,
        'urgency'            => 3,
        'impact'             => 3,
    ]);
    if ($tid > 0) {
        $tickets_a[] = (int) $tid;
    } else {
        $all_ok = false;
    }
}
check($all_ok && count($tickets_a) === $MAX_OPEN, "Tao du $MAX_OPEN phiếu đầu tiên thành công (" . count($tickets_a) . "/$MAX_OPEN)");

// -----------------------------------------------------------------------------
// 3. User A: phieu thu ($MAX_OPEN + 1) -> PHAI BI CHAN
// -----------------------------------------------------------------------------
echo "\n--- 3. User A tao phieu thu " . ($MAX_OPEN + 1) . " (vuot tran) ---\n";

$t = new Ticket();
$blocked_id = $t->add([
    'name'              => PLUGIN_PINEDESK_TEST_TAG . ' Phieu thu ' . ($MAX_OPEN + 1) . ' (phai bi chan)',
    'content'           => 'Phieu nay phai bi chan boi tran phieu mo.',
    'type'              => 1,
    'itilcategories_id' => $cat_id,
    'urgency'           => 3,
    'impact'            => 3,
]);
check($blocked_id === false || $blocked_id === 0, "Phieu vuot tran BI CHAN (add tra ve " . var_export($blocked_id, true) . ")");

// Co thong bao loi tieng Viet trong session?
$msgs = $_SESSION['MESSAGE_AFTER_REDIRECT'][ERROR] ?? [];
$has_limit_msg = false;
foreach ($msgs as $m) {
    if (stripos($m, 'phiếu') !== false) {
        $has_limit_msg = true;
        break;
    }
}
check($has_limit_msg, 'Co thong bao loi tieng Viet hien cho nguoi dung');

// Nhat ky co dong LIMIT_BLOCKED?
$res = $DB->doQuery(
    "SELECT COUNT(*) AS n FROM " . PLUGIN_PINEDESK_TABLE_LOG . "
      WHERE users_id = $uid_a AND reason = 'LIMIT_BLOCKED'"
);
$row = $res ? $DB->fetchAssoc($res) : null;
check((int) ($row['n'] ?? 0) >= 1, 'Nhat ky T6 ghi nhan LIMIT_BLOCKED');

// Dem lai trong CSDL: user A chi co dung $MAX_OPEN phieu (phieu thu khong duoc ghi)
$res = $DB->doQuery(
    "SELECT COUNT(*) AS n FROM glpi_tickets
      WHERE users_id_recipient = $uid_a AND is_deleted = 0
        AND name LIKE '" . PLUGIN_PINEDESK_TEST_TAG . "%'"
);
$row = $res ? $DB->fetchAssoc($res) : null;
check((int) ($row['n'] ?? 0) === $MAX_OPEN, "CSDL chi co $MAX_OPEN phieu cua user A (phieu thu KHONG duoc ghi)");

// Nhat ky NEW: phai co >= $MAX_OPEN dong
$res = $DB->doQuery(
    "SELECT COUNT(*) AS n FROM " . PLUGIN_PINEDESK_TABLE_LOG . "
      WHERE users_id = $uid_a AND reason = 'NEW'"
);
$row = $res ? $DB->fetchAssoc($res) : null;
check((int) ($row['n'] ?? 0) >= $MAX_OPEN, 'Nhat ky T6 ghi nhan NEW cho tung phieu tao thanh cong');

// -----------------------------------------------------------------------------
// 4. User B: phieu TRUNG -> PHAI BI CHAN (DUP_BLOCKED)
// -----------------------------------------------------------------------------
echo "\n--- 4. User B: tao 2 phieu TRUNG nhau ---\n";

test_logout();
test_login($uid_b);

$t = new Ticket();
$dup_first = $t->add([
    'name'              => PLUGIN_PINEDESK_TEST_TAG . ' Phieu goc cua B',
    'content'           => 'Phieu goc — phieu tiep theo cung loai + vi tri phai bi chan.',
    'type'              => 1,
    'itilcategories_id' => $cat_id,
    'locations_id'      => $loc_id,
    'urgency'           => 3,
    'impact'            => 3,
]);
check($dup_first > 0, "Phieu goc cua B tao thanh cong (id=$dup_first)");

$t = new Ticket();
$dup_second = $t->add([
    'name'              => PLUGIN_PINEDESK_TEST_TAG . ' Phieu trung cua B (phai bi chan)',
    'content'           => 'Cung loai su co + cung vi tri, trong cua so -> phai bi chan.',
    'type'              => 1,
    'itilcategories_id' => $cat_id,
    'locations_id'      => $loc_id,
    'urgency'           => 3,
    'impact'            => 3,
]);
check($dup_second === false || $dup_second === 0, "Phieu trung BI CHAN (add tra ve " . var_export($dup_second, true) . ")");

$res = $DB->doQuery(
    "SELECT COUNT(*) AS n FROM " . PLUGIN_PINEDESK_TABLE_LOG . "
      WHERE users_id = $uid_b AND reason = 'DUP_BLOCKED'"
);
$row = $res ? $DB->fetchAssoc($res) : null;
check((int) ($row['n'] ?? 0) >= 1, 'Nhat ky T6 ghi nhan DUP_BLOCKED');

// -----------------------------------------------------------------------------
// 4b. User D: trung theo THIET BI (items_id) — nhanh thiet bi cua T4
// -----------------------------------------------------------------------------
echo "\n--- 4b. User D: trung theo thiet bi ---\n";

test_logout();
test_login($uid_d);

$t = new Ticket();
$d_first = $t->add([
    'name'              => PLUGIN_PINEDESK_TEST_TAG . ' Phieu goc cua D (thiet bi 1)',
    'content'           => 'Phieu goc gan thiet bi 1.',
    'type'              => 1,
    'itilcategories_id' => $cat_id,
    'items_id'          => ['Computer' => [$comp1_id]],
    'urgency'           => 3,
    'impact'            => 3,
]);
check($d_first > 0, "D: phieu gan thiet bi 1 tao thanh cong (id=" . var_export($d_first, true) . ")");

// Khong thiet bi, khong vi tri -> KHONG du can cu ket luan trung, khong chan
$t = new Ticket();
$d_no_anchor = $t->add([
    'name'              => PLUGIN_PINEDESK_TEST_TAG . ' Phieu D khong thiet bi/vi tri (khong duoc chan)',
    'content'           => 'Khong co thiet bi lan vi tri — phai duoc phep (tranh chan oan).',
    'type'              => 1,
    'itilcategories_id' => $cat_id,
    'urgency'           => 3,
    'impact'            => 3,
]);
check($d_no_anchor > 0, "D: phieu khong thiet bi/vi tri KHONG bi chan (id=" . var_export($d_no_anchor, true) . ")");

// Thiet bi KHAC -> khong trung
$t = new Ticket();
$d_other_device = $t->add([
    'name'              => PLUGIN_PINEDESK_TEST_TAG . ' Phieu D thiet bi 2 (khong duoc chan)',
    'content'           => 'Cung loai nhung thiet bi khac — phai duoc phep.',
    'type'              => 1,
    'itilcategories_id' => $cat_id,
    'items_id'          => ['Computer' => [$comp2_id]],
    'urgency'           => 3,
    'impact'            => 3,
]);
check($d_other_device > 0, "D: phieu thiet bi KHAC KHONG bi chan (id=" . var_export($d_other_device, true) . ")");

// Cung thiet bi 1 -> PHAI BI CHAN
$t = new Ticket();
$d_same_device = $t->add([
    'name'              => PLUGIN_PINEDESK_TEST_TAG . ' Phieu D trung thiet bi 1 (phai bi chan)',
    'content'           => 'Cung thiet bi 1 trong cua so — phai bi chan.',
    'type'              => 1,
    'itilcategories_id' => $cat_id,
    'items_id'          => ['Computer' => [$comp1_id]],
    'urgency'           => 3,
    'impact'            => 3,
]);
check($d_same_device === false || $d_same_device === 0, "D: phieu trung THIET BI BI CHAN (add tra ve " . var_export($d_same_device, true) . ")");

// -----------------------------------------------------------------------------
// 4c. User C: tran ngay (T3b) — ha tam max_day xuong 2
// -----------------------------------------------------------------------------
echo "\n--- 4c. User C: tran so phieu MOI NGAY ---\n";

$DB->doQuery(
    "UPDATE " . PLUGIN_PINEDESK_TABLE_LIMITS . "
        SET so_phieu_mo_toi_da = 50, so_phieu_ngay_toi_da = 2
      WHERE rule_name = 'mac_dinh'"
);

test_logout();
test_login($uid_c);

$c_tickets = [];
for ($i = 1; $i <= 2; $i++) {
    $t = new Ticket();
    $cat_i = $cat_id;
    $res = $DB->doQuery("SELECT id FROM glpi_itilcategories WHERE is_request = 1 ORDER BY id LIMIT 1 OFFSET " . ($i + 4));
    if ($res && ($row = $DB->fetchAssoc($res))) {
        $cat_i = (int) $row['id'];
    }
    $tid = $t->add([
        'name'              => PLUGIN_PINEDESK_TEST_TAG . " Phieu C trong ngay $i",
        'content'           => 'Phieu thu $i cua C trong ngay.',
        'type'              => 1,
        'itilcategories_id' => $cat_i,
        'urgency'           => 3,
        'impact'            => 3,
    ]);
    if ($tid > 0) {
        $c_tickets[] = (int) $tid;
    }
}
check(count($c_tickets) === 2, "C: 2 phieu dau trong ngay tao thanh cong (" . count($c_tickets) . "/2)");

// Phieu thu 3 trong ngay -> PHAI BI CHAN boi T3b
$t = new Ticket();
$c_third = $t->add([
    'name'              => PLUGIN_PINEDESK_TEST_TAG . ' Phieu C thu 3 trong ngay (phai bi chan)',
    'content'           => 'Vuot tran 2 phieu/ngay — phai bi chan.',
    'type'              => 1,
    'itilcategories_id' => $cat_id,
    'urgency'           => 3,
    'impact'            => 3,
]);
check($c_third === false || $c_third === 0, "C: phieu thu 3 trong ngay BI CHAN (add tra ve " . var_export($c_third, true) . ")");

// Thong bao phai la thong bao T3b ("Hom nay..."), khong phai T3a
$msgs = $_SESSION['MESSAGE_AFTER_REDIRECT'][ERROR] ?? [];
$has_day_msg = false;
foreach ($msgs as $m) {
    if (stripos($m, 'Hôm nay') !== false) {
        $has_day_msg = true;
        break;
    }
}
check($has_day_msg, 'C: thong bao dung loai T3b ("Hom nay da gui...")');

// Khoi phuc han muc
$DB->doQuery(
    "UPDATE " . PLUGIN_PINEDESK_TABLE_LIMITS . "
        SET so_phieu_mo_toi_da = 5, so_phieu_ngay_toi_da = 10
      WHERE rule_name = 'mac_dinh'"
);

// -----------------------------------------------------------------------------
// 4d. User E: client gui date lui / status=6 / co _skip_auto_assign /
//     _auto_import -> hook phai ep ve gia tri chuan, KHONG duoc mien tru
// -----------------------------------------------------------------------------
echo "\n--- 4d. User E: chong ne han muc bang truong client ---\n";

test_logout();
test_login($uid_e);

$t = new Ticket();
$e_ticket = $t->add([
    'name'               => PLUGIN_PINEDESK_TEST_TAG . ' Phieu E gui date lui + status=6 + co mien tru',
    'content'            => 'Thu ne tran bang date/status/co noi bo.',
    'type'               => 1,
    'itilcategories_id'  => $cat_id,
    'date'               => '2020-01-01 00:00:00',
    'status'             => 6,
    '_skip_auto_assign'  => 1,
    '_auto_import'       => 1,
    'urgency'            => 3,
    'impact'             => 3,
]);
check($e_ticket > 0, "E: phieu van tao duoc (khong crash, id=" . var_export($e_ticket, true) . ")");

if ($e_ticket > 0) {
    $t = new Ticket();
    $t->getFromDB((int) $e_ticket);

    $res = $DB->doQuery(
        "SELECT date >= CURDATE() AS d_ok, status, users_id_recipient
           FROM glpi_tickets WHERE id = " . (int) $e_ticket
    );
    $row = $res ? $DB->fetchAssoc($res) : null;
    check((int) ($row['d_ok'] ?? 0) === 1, 'E: cot date bi ep ve HOM NAY (date lui khong duoc chap nhan)');
    check((int) ($row['status'] ?? 0) === 1, 'E: status bi ep ve Moi=1 (status=6 gui len khong duoc chap nhan)');
    check((int) ($row['users_id_recipient'] ?? 0) === $uid_e, 'E: users_id_recipient = chinh nguoi dang nhap (co _skip_auto_assign khong tac dung)');

    $res = $DB->doQuery(
        "SELECT COUNT(*) AS n FROM " . PLUGIN_PINEDESK_TABLE_LOG . "
          WHERE users_id = $uid_e AND tickets_id = " . (int) $e_ticket . " AND reason = 'NEW'"
    );
    $row = $res ? $DB->fetchAssoc($res) : null;
    check((int) ($row['n'] ?? 0) >= 1, 'E: nhat ky T6 van ghi NEW (co _auto_import khong mien tru duoc)');
}

// -----------------------------------------------------------------------------
// 5. KTV (co quyen UPDATE) -> KHONG bi chan
// -----------------------------------------------------------------------------
echo "\n--- 5. Ky thuat vien tao phieu (mien tru) ---\n";

test_logout();
test_login($ktv_id);

$t = new Ticket();
$ktv_ticket = $t->add([
    'name'              => PLUGIN_PINEDESK_TEST_TAG . ' Phieu cua KTV (khong duoc chan)',
    'content'           => 'KTV tao phieu ho — phai duoc phep du han muc.',
    'type'              => 1,
    'itilcategories_id' => $cat_id,
    'urgency'           => 3,
    'impact'            => 3,
]);
check($ktv_ticket > 0, "Phieu cua KTV tao thanh cong, khong bi chan (id=" . var_export($ktv_ticket, true) . ")");

// -----------------------------------------------------------------------------
// 6. Cron -> KHONG bi chan (phieu bao tri tu dong)
// -----------------------------------------------------------------------------
echo "\n--- 6. Phieu do cron tao (mien tru) ---\n";

test_logout();
test_login($uid_a); // user A dang "day" phieu — neu khong mien tru se bi chan

$_SESSION['glpicronuserrunning'] = 'cron_test';
$t = new Ticket();
$cron_ticket = $t->add([
    'name'              => PLUGIN_PINEDESK_TEST_TAG . ' Phieu bao tri tu dong',
    'content'           => 'Phieu do cron tao — phai duoc mien tru han muc.',
    'type'              => 1,
    'itilcategories_id' => $cat_id,
    'urgency'           => 3,
    'impact'            => 3,
]);
unset($_SESSION['glpicronuserrunning']);
check($cron_ticket > 0, "Phieu cron tao thanh cong, khong bi chan (id=" . var_export($cron_ticket, true) . ")");

// -----------------------------------------------------------------------------
// 7. Don dep
// -----------------------------------------------------------------------------
echo "\n--- 7. Don dep ---\n";

test_logout();
// Tim super-admin that su (khong gia dinh id co dinh)
$admin_id = 0;
$res = $DB->doQuery(
    "SELECT u.id FROM glpi_users u
      JOIN glpi_profiles_users pu ON pu.users_id = u.id
     WHERE pu.profiles_id = 4 AND u.is_active = 1
     ORDER BY u.id LIMIT 1"
);
if ($res && ($row = $DB->fetchAssoc($res))) {
    $admin_id = (int) $row['id'];
}
test_login($admin_id > 0 ? $admin_id : 2); // glpi (super-admin) — xoa duoc moi thu

// Xoa cac phieu test
$to_delete = array_merge(
    $tickets_a,
    array_filter([
        $dup_first,
        $d_first,
        $d_no_anchor,
        $d_other_device,
        $e_ticket,
        $ktv_ticket,
        $cron_ticket,
    ]),
    $c_tickets
);
foreach ($to_delete as $tid) {
    if ($tid > 0) {
        $t = new Ticket();
        if ($t->getFromDB($tid)) {
            $t->delete(['id' => $tid], true);
        }
    }
}

// Xoa MOI dong nhat ky phat sinh trong lan chay nay (theo moc id dau lan chay).
// Xoa theo users_id nhu ban cu se bo sot dong do KTV/super-admin tao ra.
if ($log_id_before >= 0) {
    $DB->doQuery("DELETE FROM " . PLUGIN_PINEDESK_TABLE_LOG . " WHERE id > " . $log_id_before);
}

// Xoa 5 user tam (kem ho so)
foreach ([$uid_a, $uid_b, $uid_c, $uid_d, $uid_e] as $uid) {
    if ($uid > 0) {
        $u = new User();
        if ($u->getFromDB($uid)) {
            $u->delete(['id' => $uid], true);
        }
    }
}

$res = $DB->doQuery(
    "SELECT COUNT(*) AS n FROM glpi_tickets
      WHERE name LIKE '" . PLUGIN_PINEDESK_TEST_TAG . "%' AND is_deleted = 0"
);
$row = $res ? $DB->fetchAssoc($res) : null;
check((int) ($row['n'] ?? 0) === 0, 'Da xoa het phieu kiem thu (khong con dong nao)');

$res = $DB->doQuery("SELECT COUNT(*) AS n FROM glpi_users WHERE name LIKE 'test.hm.%'");
$row = $res ? $DB->fetchAssoc($res) : null;
check((int) ($row['n'] ?? 0) === 0, 'Da xoa het user tam');

// -----------------------------------------------------------------------------
// Ket qua
// -----------------------------------------------------------------------------
echo "\n=====================================================\n";
$passed = $checks - count($failures);
if (empty($failures)) {
    echo "  KET QUA: $passed/$checks dat — CO CHE CHAN HOAT DONG THAT\n";
    echo "=====================================================\n";
    exit(0);
} else {
    echo "  KET QUA: $passed/$checks dat — CO " . count($failures) . " MUC THAT BAI:\n";
    foreach ($failures as $f) {
        echo "    - $f\n";
    }
    echo "=====================================================\n";
    exit(1);
}
