#!/usr/bin/env bash
# ==============================================================================
#  KIEM TRA CHUC NANG (smoke test nghiep vu that)
# ==============================================================================
#  Dang nhap THAT bang tai khoan GLPI roi GET tung trang chuc nang, bao cao
#  ma HTTP + kich thuoc. Chung minh 3 dieu:
#    1. Chuc nang hoat dong   : trang duoc phep -> 200 va co noi dung that
#    2. Phan quyen hoat dong  : trang khong duoc phep -> 403 (khong lo du lieu)
#    3. Tai nguyen tinh       : favicon, CSS, logo, tai lieu -> 200
#
#  Cach dung:
#     GLPI_USER=glpi    GLPI_PASS='<mk>' bash scripts/kiem-tra-chuc-nang.sh
#     GLPI_USER=ktv.an  GLPI_PASS='Dlu@2026' bash scripts/kiem-tra-chuc-nang.sh
#     GLPI_USER=sv.hoa  GLPI_PASS='Dlu@2026' bash scripts/kiem-tra-chuc-nang.sh
#
#  Vai tro duoc SUY RA tu ten tai khoan:
#     glpi / admin*      -> quan tri   : moi trang 200
#     ktv.* / tech*      -> ky thuat   : trang trung tam 200, trang Setup 403
#     sv.* / gv.*        -> tu phuc vu : trang helpdesk 200, trang trung tam 403
# ==============================================================================
set -u

BASE="${GLPI_URL:-https://localhost:8443}"
USER="${GLPI_USER:-glpi}"

# MAT KHAU: KHONG co gia tri mac dinh.
#   Ban cu dat PASS="${GLPI_PASS:-glpi}" -> sau khi nguoi dung doi mat khau admin
#   theo dung chi dan cua README ("Doi mat khau glpi ngay sau khi dang nhap lan
#   dau"), script am tham dang nhap bang 'glpi' va bao that bai kho hieu. Bat
#   buoc phai truyen GLPI_PASS, giong scripts/lib/browser.js.
if [ -z "${GLPI_PASS:-}" ]; then
    printf '%s\n' "[LOI] Thieu bien moi truong GLPI_PASS." \
                  "      Vi du:  GLPI_USER=ktv.an GLPI_PASS='<mat-khau>' bash $0" >&2
    exit 1
fi
PASS="$GLPI_PASS"
JAR="$(mktemp)"
BODY="$(mktemp)"
chmod 600 "$BODY"
trap 'rm -f "$JAR" "$BODY"' EXIT

PASS_N=0
FAIL_N=0
fail() { printf '  [LOI] %s\n' "$1"; FAIL_N=$((FAIL_N + 1)); }
ok()   { printf '  [OK ] %s\n' "$1"; PASS_N=$((PASS_N + 1)); }

# --- Suy ra vai tro -----------------------------------------------------------
case "$USER" in
  glpi|admin*) VAI_TRO="quan tri" ;;
  ktv.*|tech*) VAI_TRO="ky thuat" ;;
  sv.*|gv.*)   VAI_TRO="tu phuc vu" ;;
  *)           VAI_TRO="quan tri" ;;
esac

# --- Dang nhap ----------------------------------------------------------------
TOK=$(curl -sk -c "$JAR" "$BASE/" | grep -oE 'name="_glpi_csrf_token" value="[a-f0-9]+"' | head -1 | grep -oE '[a-f0-9]{64}')
if [ -z "$TOK" ]; then fail "Khong lay duoc CSRF token o trang dang nhap"; exit 1; fi

# Mat khau KHONG di qua argv (argv lo voi moi tien trinh cung may qua
# /proc/<pid>/cmdline). Ghi body vao file tam 0600 roi --data @file.
printf 'login_name=%s&login_password=%s&noAUTO=0&redirect=&_glpi_csrf_token=%s' \
  "$USER" "$PASS" "$TOK" > "$BODY"
CODE=$(curl -sk -b "$JAR" -c "$JAR" -o /dev/null -w '%{http_code}' \
  --data "@$BODY" "$BASE/front/login.php")
rm -f "$BODY"
if [ "$CODE" = "302" ]; then ok "Dang nhap ($USER) -> 302"; else fail "Dang nhap tra $CODE (mong doi 302)"; fi

# --- Kiem tra tung trang ------------------------------------------------------
# Moi dong: <nhan>|<duong dan>|<kich thuoc toi thieu>
# Ma HTTP mong doi duoc quyet dinh theo VAI TRO (xem vong lap ben duoi).
TRUNG_TAM=(
  "Bang dieu khien|/front/central.php|50000"
  "Danh sach phieu|/front/ticket.php|20000"
  "Tao phieu moi|/front/ticket.form.php|20000"
  "May tinh|/front/computer.php|20000"
  "Man hinh|/front/monitor.php|20000"
  "May in|/front/printer.php|20000"
  "Thiet bi mang|/front/networkequipment.php|20000"
  "Phan mem|/front/software.php|20000"
  "Nguoi dung|/front/user.php|20000"
  "Nhom - co cau to chuc|/front/group.php|20000"
  "Muc dich vu (SLA)|/front/sla.php|10000"
  "Vi tri - toa nha/phong|/front/location.php|10000"
  "Danh muc su co|/front/itilcategory.php|10000"
  "Bao tri dinh ky|/front/ticketrecurrent.php|10000"
  "Dat muon thiet bi|/front/reservation.php|10000"
  "Tim kiem|/front/search.php|10000"
  "Thong ke toan cau|/front/stat.php|10000"
  "Cau hinh chung|/front/config.form.php|10000"
)
# Cac trang Setup chi Super-Admin mo duoc (tai khoan khac phai 403)
SETUP=(
  "Vi tri - toa nha/phong|/front/location.php"
  "Danh muc su co|/front/itilcategory.php"
  "Cau hinh chung|/front/config.form.php"
)

printf '\n=== KIEM TRA CHUC NANG (%s) ===\n' "$BASE"
printf '    Tai khoan: %s   |   Vai tro: %s\n' "$USER" "$VAI_TRO"

# 1. Cac trang trung tam: chi kiem khi vai tro MO duoc (quan tri / ky thuat)
if [ "$VAI_TRO" = "tu phuc vu" ]; then
  printf '\n-- Cua vao tu phuc vu (phai 200 sau khi theo redirect) --\n'
  # GLPI 11 chuyen huong /front/helpdesk.public.php -> /Helpdesk va
  # /front/ticket.form.php -> /ServiceCatalog. Dung -L de theo het chuoi.
  for d in "Trang chu Helpdesk|/front/helpdesk.public.php" \
           "Danh muc dich vu|/front/ticket.form.php" \
           "Kho kien thuc (FAQ)|/front/helpdesk.faq.php"; do
    IFS='|' read -r NHAN DUONG <<<"$d"
    OUT=$(curl -skL -b "$JAR" -c "$JAR" -o /dev/null -w '%{http_code} %{size_download}' "$BASE$DUONG")
    C=${OUT% *}; S=${OUT#* }
    if [ "$C" = "200" ] && [ "$S" -ge 10000 ]; then ok "$NHAN ($C, ${S}B)"; else fail "$NHAN -> $C ${S}B (mong doi 200, >= 10000B)"; fi
  done

  printf '\n-- Trang trung tam (phai bi chan voi vai tro tu phuc vu) --\n'
  for d in "${SETUP[@]}" "May tinh|/front/computer.php" "Nguoi dung|/front/user.php"; do
    IFS='|' read -r NHAN DUONG <<<"$d"
    C=$(curl -sk -b "$JAR" -c "$JAR" -o /dev/null -w '%{http_code}' "$BASE$DUONG")
    if [ "$C" = "403" ]; then ok "$NHAN bi chan dung (403)"; else fail "$NHAN -> $C (mong doi 403)"; fi
  done
else
  printf '\n-- Trang trung tam (phai 200) --\n'
  for d in "${TRUNG_TAM[@]}"; do
    IFS='|' read -r NHAN DUONG MIN <<<"$d"
    IS_SETUP=0
    for s in "${SETUP[@]}"; do [ "${s#*|}" = "$DUONG" ] && IS_SETUP=1; done
    # Trang Setup: quan tri -> 200, ky thuat -> 403
    MONG=200
    if [ "$IS_SETUP" = "1" ] && [ "$VAI_TRO" = "ky thuat" ]; then MONG=403; fi
    OUT=$(curl -sk -b "$JAR" -c "$JAR" -o /dev/null -w '%{http_code} %{size_download}' "$BASE$DUONG")
    C=${OUT% *}; S=${OUT#* }
    if [ "$MONG" = "403" ]; then
      [ "$C" = "403" ] && ok "$NHAN bi chan dung (403)" || fail "$NHAN -> $C (mong doi 403)"
    elif [ "$C" = "$MONG" ] && [ "$S" -ge "$MIN" ]; then
      ok "$NHAN  ($C, ${S}B)"
    else
      fail "$NHAN  -> $C ${S}B (mong doi $MONG, >= ${MIN}B)"
    fi
  done
fi

# 2. Trang ca nhan (moi vai tro deu mo duoc)
printf '\n-- Trang ca nhan (moi vai tro) --\n'
C=$(curl -sk -b "$JAR" -c "$JAR" -o /dev/null -w '%{http_code}' "$BASE/front/preference.php")
[ "$C" = "200" ] && ok "Ho so ca nhan (200)" || fail "Ho so ca nhan -> $C (mong doi 200)"

# --- Trang tinh / tai nguyen --------------------------------------------------
printf '\n=== TAI NGUYEN TINH ===\n'
for d in "Favicon|/pics/favicon.ico|200" "CSS Da Lat|/plugins/dlubrand/css/dlu-theme.css|200" \
         "Logo DLU|/plugins/dlubrand/pics/logos/logo-DLU-100.png|200" \
         "README|/README.md|200" "Slide bao ve|/tai-lieu/slide-bao-ve.html|200"; do
  IFS='|' read -r NHAN DUONG MONG <<<"$d"
  C=$(curl -sk -o /dev/null -w '%{http_code}' "$BASE$DUONG")
  if [ "$C" = "$MONG" ]; then ok "$NHAN ($C)"; else fail "$NHAN -> $C"; fi
done

printf '\n=== KET QUA: %d dat / %d loi ===\n' "$PASS_N" "$FAIL_N"
[ "$FAIL_N" -eq 0 ]
