#!/usr/bin/env bash
# ==============================================================================
#  BAO VE KHI KHOI DONG: phat hien thay doi co 'internal' cua MANG
# ==============================================================================
#  VAN DE (da tung gay loi that):
#    Docker KHONG doi duoc co 'internal' cua mot mang DANG TON TAI. Khi gia tri
#    nay trong docker-compose.yml thay doi, Compose se TAO LAI mang, nhung
#    container dang chay chi duoc GAN LAI ma KHONG dang ky lai "alias" dich vu
#    (vi du 'mariadb'). Hau qua: GLPI khong phan giai duoc ten 'mariadb' ->
#    "Unable to connect to database" -> tu cai dat lai -> restart loop.
#    (docker network inspect VAN thay container nam trong mang, nen rat kho doan.)
#
#  CACH XU LY: neu co 'internal' thuc te KHAC voi khai bao trong compose file,
#  phai chay 'docker compose down' TRUOC roi moi 'up -d'. Volume la named volume
#  nen KHONG mat du lieu.
#
#  File nay duoc 'source' tu start.sh va scripts/cai-dat-tat-ca.sh de tranh
#  lap lai logic o hai noi (quy uoc du an: mot nguon su that duy nhat).
# ==============================================================================

# Tim lenh Compose (ho tro ca 'docker compose' va 'docker-compose').
# Dat mang toan cuc COMPOSE_CMD. Tra ve 1 neu khong tim thay.
compose_cmd() {
    if docker compose version >/dev/null 2>&1; then
        COMPOSE_CMD=(docker compose)
        return 0
    fi
    if command -v docker-compose >/dev/null 2>&1; then
        COMPOSE_CMD=(docker-compose)
        return 0
    fi
    return 1
}

# Khoi dong he thong. Neu co 'internal' cua mang da doi -> 'down' truoc.
# Dung: compose_up_an_toan [python_binary]
compose_up_an_toan() {
    local py="${1:-}"
    if [ -z "$py" ]; then
        py="$(command -v python3 || command -v python || true)"
    fi

    if ! compose_cmd; then
        echo "  [LOI] Khong tim thay Docker Compose (docker compose / docker-compose)."
        return 1
    fi

    # --- Phat hien 'internal' da doi (chi khi co Python de doc JSON) ----------
    # LUU Y: canh bao (khong doc duoc config / loi inspect) phai in ra STDERR,
    # khong duoc lot vao $da_doi — neu lot vao, doan duoi se hieu nham la
    # "mang da doi" va tu dong chay `docker compose down` (hanh vi sai).
    # $da_doi chi chua CAC DONG CHENH LECH that su.
    local da_doi=""
    if [ -n "$py" ]; then
        da_doi="$(
            "${COMPOSE_CMD[@]}" config --format json 2>/dev/null | "$py" -c '
import json, subprocess, sys
try:
    cfg = json.load(sys.stdin)
except Exception:
    # Khong doc duoc cau hinh compose -> KHONG the kiem tra; bao dong de
    # nguoi dung biet (truoc day loi nay bi nuot im lang).
    print("  - [CANH BAO] Khong doc duoc `docker compose config` (JSON) -> bo qua kiem tra mang.", file=sys.stderr)
    sys.exit(0)
for key, net in (cfg.get("networks") or {}).items():
    name = net.get("name") or key
    want = bool(net.get("internal"))
    r = subprocess.run(
        ["docker", "network", "inspect", name, "--format", "{{.Internal}}"],
        capture_output=True, text=True)
    if r.returncode != 0:
        # Phan biet "mang chua ton tai" (binh thuong, bo qua) voi loi khac
        # (daemon loi, quyen...) - loi khac phai bao dong, khong duoc nuot.
        err = (r.stderr or "").lower()
        if "no such network" in err or "not found" in err:
            continue
        print(f"  - [CANH BAO] Khong kiem tra duoc mang {name}: {r.stderr.strip()}", file=sys.stderr)
        continue
    have = r.stdout.strip().lower() == "true"
    if want != have:
        print(f"  - {name}: khai bao internal={want}, thuc te={have}")
'
        )" || true
    else
        # Khong co Python -> kiem tra 'internal' bi BO QUA. Phai noi ro, neu
        # khong nguoi dung tuong he thong da duoc bao ve (false-negative im lang).
        echo "  [LUU Y] Khong tim thay Python (python3/python) -> bo qua kiem tra"
        echo "          co 'internal' cua mang. Neu vua doi gia tri nay trong"
        echo "          docker-compose.yml, hay chay 'docker compose down' thu cong"
        echo "          truoc khi 'up' de tranh loi mat ket noi CSDL."
    fi

    if [ -n "$da_doi" ]; then
        echo ""
        echo "  [CANH BAO] Co 'internal' cua MANG da thay doi so voi thuc te:"
        echo "$da_doi"
        echo "             Docker KHONG doi duoc co nay khi mang dang ton tai."
        echo "             -> Chay 'docker compose down' truoc de tao lai mang dung."
        echo "                (Volume la named volume nen KHONG mat du lieu)"
        echo ""
        "${COMPOSE_CMD[@]}" down || true
    fi

    "${COMPOSE_CMD[@]}" up -d
}
