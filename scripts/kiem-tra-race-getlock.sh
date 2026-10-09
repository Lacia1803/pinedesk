#!/usr/bin/env bash
# ==============================================================================
#  KIEM TRA RACE CONDITION — GET_LOCK (T3a song song)
# ==============================================================================
#  Chung minh rang GET_LOCK cua MariaDB ngan chan TOCTOU khi 2 request cua
#  cung mot tai khoan tao phieu CUNG LUC tai nut sat tran:
#    - Tao 1 user tam (Self-Service) de kiem thu.
#    - Ha tam max_open xuong 1.
#    - Bat 2 tien trinh PHP song song, moi tien trinh bootstrap GLPI dung cach
#      (Kernel::boot() + Auth + Session::init) roi tao 1 phieu.
#    - Ket qua mong doi: CHI 1 phieu duoc ghi; tien trinh kia bi GET_LOCK chan.
#
#  Yeu cau: container pinedesk-glpi dang chay.
#  Chay:  bash scripts/kiem-tra-race-getlock.sh
#  Tich hop CI: xem .github/workflows/ci.yml buoc "race test".
# ==============================================================================
set -euo pipefail

CONTAINER="pinedesk-glpi"

# MSYS_NO_PATHCONV=1: ngan Git Bash chuyen doi duong dan Linux thanh duong dan
# Windows khi truyen qua docker exec (van de chi tren Windows / Git Bash).
export MSYS_NO_PATHCONV=1

# Duong dan trong container den file PHP tao phieu.
# plugins/pinedesk duoc mount tu host nen tao file tren host la
# du — khong can docker cp, tranh van de Git Bash doi path.
PHP_SCRIPT_INSIDE="/var/www/glpi/plugins/pinedesk/tests/race-tao-phieu.php"

# Duong dan tuong duong tren host (tinh tu vi tri script)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PHP_HOST="$SCRIPT_DIR/../plugins/pinedesk/tests/race-tao-phieu.php"

# Kiem tra container dang chay
if ! docker inspect --format '{{.State.Running}}' "$CONTAINER" 2>/dev/null | grep -q '^true$'; then
    echo "[LOI] Container '$CONTAINER' chua chay." >&2
    exit 1
fi

echo "=== Kiem tra race condition (GET_LOCK) ==="
echo ""

# ---- Tao file PHP tao phieu (trong thu muc tests, da duoc mount vao container) ---
# File PHP nhan tham so: $argv[1] = user_id (user tam)
# Bootstrap dung cach theo mau kiem-thu-han-muc.php
cat > "$PHP_HOST" <<'PHPEOF'
<?php
// Script tao phieu cho kiem tra race condition GET_LOCK.
// Tham so: php race-tao-phieu.php <user_id>
// In "OK:<id>" hoac "BLOCKED" ra stdout.

ob_start();

require_once '/var/www/glpi/vendor/autoload.php';

use Glpi\Kernel\Kernel;

$kernel = new Kernel();
$kernel->boot();

require_once '/var/www/glpi/plugins/pinedesk/hook.php';

global $DB;

$user_id = isset($argv[1]) ? (int) $argv[1] : 0;
if ($user_id <= 0) {
    ob_end_clean();
    echo "ERROR\n";
    exit(1);
}

// Dang nhap dung cach (Kernel::boot + Auth + Session::init)
$user = new User();
$user->getFromDB($user_id);

$auth = new Auth();
$auth->auth_succeded = true;
$auth->user = $user;
Session::init($auth);

// Tao phieu — hook PRE_ITEM_ADD se chay GET_LOCK + kiem tra han muc
$t = new Ticket();
$id = $t->add([
    'name'    => '[RACE] Phieu test song song',
    'content' => 'Race condition test - GET_LOCK',
    'type'    => 1,
    'urgency' => 3,
    'impact'  => 3,
]);

ob_end_clean();

if ($id > 0) {
    echo "OK:$id\n";
} else {
    echo "BLOCKED\n";
}
PHPEOF

# ---- Bien luu trang thai cleanup -------------------------------------------
RACE_UID=0
TMP1=""
TMP2=""

cleanup() {
    local exit_code=$?

    # Khoi phuc max_open ve mac dinh
    docker exec -u www-data "$CONTAINER" php -r "
ob_start();
require_once '/var/www/glpi/vendor/autoload.php';
\$k = new Glpi\Kernel\Kernel(); \$k->boot();
global \$DB;
\$DB->doQuery(\"UPDATE glpi_plugin_pinedesk_limits SET so_phieu_mo_toi_da = 5 WHERE rule_name = 'mac_dinh'\");
ob_end_clean();
" 2>/dev/null || true

    # Don dep phieu race test
    docker exec -u www-data "$CONTAINER" php -r "
ob_start();
require_once '/var/www/glpi/vendor/autoload.php';
\$k = new Glpi\Kernel\Kernel(); \$k->boot();
global \$DB;
\$DB->doQuery(\"DELETE FROM glpi_tickets WHERE name LIKE '[RACE]%'\");
ob_end_clean();
" 2>/dev/null || true

    # Don dep user tam (can dang nhap super-admin de co quyen xoa)
    if [ "$RACE_UID" -gt 0 ]; then
        local uid_copy="$RACE_UID"
        docker exec -u www-data "$CONTAINER" php -r "
ob_start();
require_once '/var/www/glpi/vendor/autoload.php';
\$k = new Glpi\Kernel\Kernel(); \$k->boot();
global \$DB;
\$res = \$DB->doQuery(\"SELECT u.id FROM glpi_users u JOIN glpi_profiles_users pu ON pu.users_id = u.id WHERE pu.profiles_id = 4 AND u.is_active = 1 ORDER BY u.id LIMIT 1\");
\$row = \$res ? \$DB->fetchAssoc(\$res) : null;
\$admin_id = \$row ? (int)\$row['id'] : 2;
\$user = new User(); \$user->getFromDB(\$admin_id);
\$auth = new Auth(); \$auth->auth_succeded = true; \$auth->user = \$user;
Session::init(\$auth);
\$u = new User();
if (\$u->getFromDB($uid_copy)) { \$u->delete(['id' => $uid_copy], true); }
ob_end_clean();
" 2>/dev/null || true
    fi

    # Don dep file PHP tam
    rm -f "$PHP_HOST"

    # Don dep file tam cua host
    [ -n "$TMP1" ] && rm -f "$TMP1" || true
    [ -n "$TMP2" ] && rm -f "$TMP2" || true

    exit "$exit_code"
}
trap cleanup EXIT

# ---- Tao user tam (Self-Service, profile 1) --------------------------------
echo "  [1] Tao user tam cho race test..."
SUFFIX=$(date +%s | tail -c 7)
UNAME="race.test.$SUFFIX"

RACE_UID=$(docker exec -u www-data "$CONTAINER" php -r "
ob_start();
require_once '/var/www/glpi/vendor/autoload.php';
\$k = new Glpi\Kernel\Kernel(); \$k->boot();
global \$DB;
\$res = \$DB->doQuery(\"SELECT u.id FROM glpi_users u JOIN glpi_profiles_users pu ON pu.users_id = u.id WHERE pu.profiles_id = 4 AND u.is_active = 1 ORDER BY u.id LIMIT 1\");
\$row = \$res ? \$DB->fetchAssoc(\$res) : null;
\$admin_id = \$row ? (int)\$row['id'] : 2;
\$user = new User(); \$user->getFromDB(\$admin_id);
\$auth = new Auth(); \$auth->auth_succeded = true; \$auth->user = \$user;
Session::init(\$auth);
\$u = new User();
\$uid = \$u->add(['name' => '$UNAME', 'password' => 'Race@$SUFFIX', 'password2' => 'Race@$SUFFIX', '_profiles_id' => 1, 'is_active' => 1]);
ob_end_clean();
echo \$uid > 0 ? \$uid : 0;
" 2>/dev/null)

if [ -z "$RACE_UID" ] || [ "$RACE_UID" -le 0 ]; then
    echo "  [LOI] Khong tao duoc user tam." >&2
    exit 1
fi
echo "  [1] Da tao user tam '$UNAME' (id=$RACE_UID)."

# ---- Ha tam max_open = 1 ---------------------------------------------------
docker exec -u www-data "$CONTAINER" php -r "
ob_start();
require_once '/var/www/glpi/vendor/autoload.php';
\$k = new Glpi\Kernel\Kernel(); \$k->boot();
global \$DB;
\$DB->doQuery(\"UPDATE glpi_plugin_pinedesk_limits SET so_phieu_mo_toi_da = 1 WHERE rule_name = 'mac_dinh'\");
ob_end_clean();
echo 'OK';
" 2>/dev/null | grep -q 'OK' || { echo "  [LOI] Khong the ha max_open." >&2; exit 1; }

echo "  [2] Da ha tam max_open xuong 1."

# ---- Chay 2 request song song ----------------------------------------------
TMP1=$(mktemp)
TMP2=$(mktemp)

echo "  [3] Khoi dong 2 request song song..."

docker exec -u www-data "$CONTAINER" php "$PHP_SCRIPT_INSIDE" "$RACE_UID" > "$TMP1" 2>/dev/null &
PID1=$!

docker exec -u www-data "$CONTAINER" php "$PHP_SCRIPT_INSIDE" "$RACE_UID" > "$TMP2" 2>/dev/null &
PID2=$!

# || true: tranh set -e tat script khi PHP exit != 0 (BLOCKED case)
wait $PID1 || true
wait $PID2 || true

R1=$(tr -d '[:space:]' < "$TMP1")
R2=$(tr -d '[:space:]' < "$TMP2")

echo "  [4] Ket qua: request-1='$R1'  request-2='$R2'"

# ---- Dem so request thanh cong ---------------------------------------------
OK_COUNT=0
[[ "$R1" == OK:* ]] && OK_COUNT=$((OK_COUNT + 1))
[[ "$R2" == OK:* ]] && OK_COUNT=$((OK_COUNT + 1))

echo ""
echo "  [5] So request tao phieu thanh cong: $OK_COUNT / 2"

if [ "$OK_COUNT" -eq 1 ]; then
    echo ""
    echo "  KET QUA: DAT — GET_LOCK ngan duoc race (chi 1/2 request thanh cong)"
    echo "============================================================"
    exit 0
else
    echo ""
    echo "  KET QUA: THAT BAI — mong doi 1/2 thanh cong, nhan duoc $OK_COUNT"
    echo "  (Co the do: GET_LOCK khong hoat dong, hoac max_open chua ap dung)"
    echo "============================================================"
    exit 1
fi
