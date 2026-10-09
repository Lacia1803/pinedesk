#!/usr/bin/env bash
# ==============================================================================
#  KIEM TRA CHAN HAN MUC QUA DUONG HTTP THAT (wrapper)
# ==============================================================================
#  Muc dich: chung minh co che chan han muc hoat dong tren DUONG NGUOI DUNG
#  THAT (POST /Form/SubmitAnswers qua trinh duyet), khong chi in-process.
#
#  Cach lam:
#    1. Ha tam so_phieu_mo_toi_da xuong 1 (dam bao tai khoan test chac chan cham tran).
#    2. Chay scripts/kiem-tra-http-limit.js (Playwright + Chrome that).
#    3. Khoi phuc han muc ve gia tri goc (trap, ke ca khi loi).
#
#  Yeu cau: container pinedesk-glpi + Chrome tren may + GLPI_PASS trong moi truong.
#  Chay:  GLPI_PASS='<mk>' bash scripts/kiem-tra-http-limit.sh
# ==============================================================================
set -uo pipefail

CONTAINER="${GLPI_CONTAINER:-pinedesk-glpi}"
DB_CONTAINER="${DB_CONTAINER:-pinedesk-db}"

export MSYS_NO_PATHCONV=1

# Duong dan thu muc chua script nay (de goi file .js cung thu muc).
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if ! docker inspect --format '{{.State.Running}}' "$CONTAINER" 2>/dev/null | grep -q '^true$'; then
    echo "[LOI] Container '$CONTAINER' chua chay." >&2
    exit 1
fi

# Ham chay SQL qua container DB (mat khau do shell trong container tu doc).
q() {
    docker exec "$DB_CONTAINER" sh -c \
        'MYSQL_PWD="$MARIADB_ROOT_PASSWORD" mariadb -u root glpi -N -B -e "$1"' _ "$1"
}

# Luu gia tri goc de khoi phuc
GOC="$(q "SELECT so_phieu_mo_toi_da FROM glpi_plugin_pinedesk_limits WHERE rule_name='mac_dinh';" | tr -d '\r')"
[ -n "$GOC" ] || GOC=5

khoi_phuc() {
    q "UPDATE glpi_plugin_pinedesk_limits SET so_phieu_mo_toi_da=${GOC} WHERE rule_name='mac_dinh';" >/dev/null 2>&1 || true
    # Don phieu test con sot (neu co)
    q "DELETE FROM glpi_items_tickets WHERE tickets_id IN (SELECT id FROM glpi_tickets WHERE name LIKE 'Phieu kiem tra chan qua HTTP HTTPLIMIT-%');" >/dev/null 2>&1 || true
    q "DELETE FROM glpi_tickets WHERE name LIKE 'Phieu kiem tra chan qua HTTP HTTPLIMIT-%';" >/dev/null 2>&1 || true
}
trap khoi_phuc EXIT

echo "=== KIEM TRA CHAN HAN MUC QUA HTTP THAT ==="
echo "  Han muc goc: so_phieu_mo_toi_da=$GOC"
q "UPDATE glpi_plugin_pinedesk_limits SET so_phieu_mo_toi_da=1 WHERE rule_name='mac_dinh';" >/dev/null
echo "  Da ha tam so_phieu_mo_toi_da=1 (dam bao tai khoan test cham tran)."

# Dam bao tai khoan test co >= 1 phieu mo (de cham tran 1)
USER_TEST="${GLPI_USER:-sv.hoa}"
MO="$(q "SELECT COUNT(*) FROM glpi_tickets t JOIN glpi_users u ON u.id=t.users_id_recipient WHERE u.name='${USER_TEST}' AND t.is_deleted=0 AND t.status IN (1,2,3,4);" | tr -d '\r')"
echo "  Tai khoan ${USER_TEST} dang co ${MO} phieu mo (can >= 1 de cham tran)."
if [ "${MO:-0}" -lt 1 ]; then
    echo "  [CANH BAO] Tai khoan nay chua co phieu mo -> tran 1 co the khong kich hoat."
    echo "             Hay chay tren tai khoan da co san phieu (mac dinh sv.hoa)."
fi

echo ""
# cd vao scripts/ roi goi ten file TUONG DOI: tranh loi duong dan kieu /d/...
# (Git Bash tra ve /d/... nhung Node tren Windows hieu sai thanh D:\d\...).
cd "$SCRIPT_DIR" || exit 1
GLPI_USER="$USER_TEST" node ./kiem-tra-http-limit.js
RC=$?

echo ""
if [ "$RC" -eq 0 ]; then
    echo "  KET QUA: DAT — co che chan hoat dong tren duong HTTP that"
else
    echo "  KET QUA: THAT BAI (xem chi tiet phia tren)"
fi
exit "$RC"
