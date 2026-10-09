#!/usr/bin/env bash
# ==============================================================================
#  DO TAI HE THONG PINEDESK (dung wrk trong Docker, khong can cai gi tren may)
# ==============================================================================
#  Muc dich: tra loi cau hoi "he thong chiu duoc bao nhieu nguoi dung dong thoi?"
#  bang SO DO THAT, thay vi suy luan kien truc suong.
#
#  Cach lam:
#    1. Do Nginx (endpoint /healthz) -> tran tren cua tang gateway.
#    2. Do GLPI (trang dang nhap, qua PHP+session) o nhieu muc tai -> tim diem bao hoa.
#    3. Do duong GHI (tao phieu) bang script PHP trong container.
#
#  Yeu cau: Docker + 4 container pinedesk dang chay.
#  Chay:  bash scripts/do-tai.sh
# ==============================================================================
set -uo pipefail

NET="${PINEDESK_NET:-pinedesk-frontend-network}"
GLPI="${GLPI_CONTAINER:-pinedesk-glpi}"
WRK_IMAGE="williamyeh/wrk:latest"

echo "==================================================================="
echo "  DO TAI HE THONG PINEDESK"
echo "==================================================================="
echo ""

# --- 1. Nginx gateway (/healthz - khong cham GLPI) --------------------------
echo "[1/3] Nginx gateway (endpoint /healthz, chi Nginx tra loi)..."
docker run --rm --network "$NET" "$WRK_IMAGE" \
    -t2 -c20 -d10s --latency http://pinedesk-gateway/healthz 2>&1 \
    | grep -E "Latency|50%|99%|Requests/sec" | sed 's/^/    /'
echo ""

# --- 2. GLPI trang dang nhap, nhieu muc tai ---------------------------------
echo "[2/3] GLPI - trang dang nhap (qua PHP + phien), tim diem bao hoa..."
printf "    %-8s %-12s %-10s %-10s %-12s\n" "conc" "req/sec" "p50" "p99" "timeout"
for c in 10 30 50 100; do
    OUT=$(docker run --rm --network "$NET" "$WRK_IMAGE" \
        -t4 -c"$c" -d10s --latency \
        -H "Host: localhost" -H "X-Forwarded-Proto: https" \
        http://glpi:80/ 2>&1)
    RPS=$(printf '%s' "$OUT" | grep -oE 'Requests/sec:[[:space:]]+[0-9.]+' | grep -oE '[0-9.]+' | head -1)
    P50=$(printf '%s' "$OUT" | grep -E '^\s+50%' | awk '{print $2}')
    P99=$(printf '%s' "$OUT" | grep -E '^\s+99%' | awk '{print $2}')
    TO=$(printf '%s' "$OUT" | grep -oE 'timeout [0-9]+' | grep -oE '[0-9]+' | head -1)
    printf "    %-8s %-12s %-10s %-10s %-12s\n" "$c" "${RPS:-?}" "${P50:-?}" "${P99:-?}" "${TO:-0}"
done
echo ""

# --- 3. Duong GHI: tao phieu (INSERT + hook + thong bao) --------------------
echo "[3/3] Duong GHI - tao phieu (nang nhat)..."
docker exec -u www-data "$GLPI" php -r '
require_once "/var/www/glpi/vendor/autoload.php";
$k = new Glpi\Kernel\Kernel(); $k->boot();
require_once "/var/www/glpi/plugins/pinedesk/hook.php";
global $DB;
$r = $DB->doQuery("SELECT u.id FROM glpi_users u JOIN glpi_profiles_users pu ON pu.users_id=u.id WHERE pu.profiles_id=4 AND u.is_active=1 ORDER BY u.id LIMIT 1");
$row = $r ? $DB->fetchAssoc($r) : null; $admin = (int)($row["id"] ?? 2);
$u = new User(); $u->getFromDB($admin);
$a = new Auth(); $a->auth_succeded = true; $a->user = $u; Session::init($a);
$N = 30; $t0 = microtime(true);
for ($i = 0; $i < $N; $i++) { $t = new Ticket(); $t->add(["name"=>"[DOTAI] $i","content"=>"do tai","type"=>1,"urgency"=>3,"impact"=>3]); }
$dt = microtime(true) - $t0;
fwrite(STDERR, sprintf("    %d phieu trong %.2fs => %.1f phieu/giay (%.1f ms/phieu)\n", $N, $dt, $N/$dt, $dt/$N*1000));
$DB->doQuery("DELETE FROM glpi_items_tickets WHERE tickets_id IN (SELECT id FROM glpi_tickets WHERE name LIKE \"[DOTAI]%\")");
$DB->doQuery("DELETE FROM glpi_tickets WHERE name LIKE \"[DOTAI]%\"");
' 2>&1 | grep -E "phieu/giay|phieu trong" | sed 's/^/    /'
echo ""
echo "==================================================================="
echo "  XONG. Xem tai-lieu/DO-TAI.md de biet cach doc so lieu."
echo "==================================================================="
