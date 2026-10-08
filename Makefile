# ==============================================================================
#  MAKEFILE — Lenh thuong dung cho PineDesk
# ==============================================================================
#  Muc dich: gom cac buoc "kiem tra chat luong" (giong CI) va lenh van hanh
#  thuong gap vao MOT noi, de nguoi lam chay truoc khi push ma khong phai
#  nho tung lenh roi rac trong README.
#
#  CACH DUNG:
#     make kiem-tra     # chay tat ca kiem tra nhanh (giong CI, tru smoke test)
#     make cu-phap      # chi kiem cu phap shell/Python/JS
#     make bien-dich    # chi chay cac script dich tieng Viet
#     make compose-kiem # validate docker-compose.yml + nginx -t
#     make bao-mat      # quet bi mat hardcode
#     make up / down / logs / sao-luu
#
#  LUU Y: `make kiem-tra` KHONG chay smoke test (khoi dong that 4 container,
#  ~5 phut) — do la viec cua CI. Chay `make smoke` neu muon thu tai may.
# ==============================================================================

SHELL := /bin/bash
.DEFAULT_GOAL := kiem-tra

# --- Kiem tra cu phap (giong job 'syntax' cua CI) -----------------------------
.PHONY: cu-phap
cu-phap:
	@echo "== Cu phap shell (bash -n) =="
	@set -e; \
	N=0; \
	while IFS= read -r f; do bash -n "$$f"; N=$$((N+1)); done \
	  < <(find . -name '*.sh' -not -path './node_modules/*'); \
	echo "  [OK] $$N file shell"
	@echo "== Cu phap Python (py_compile) =="
	@set -e; \
	FILES=$$(find . -name '*.py' -not -path './node_modules/*'); \
	python -m py_compile $$FILES; \
	echo "  [OK] $$(echo $$FILES | wc -w) file Python"
	@echo "== Cu phap JavaScript (node --check) =="
	@set -e; \
	N=0; \
	while IFS= read -r f; do node --check "$$f"; N=$$((N+1)); done \
	  < <(find . -name '*.js' -not -path './node_modules/*' -not -path './.git/*'); \
	echo "  [OK] $$N file JS"

# --- Cu phap PHP cua plugin (giong CI, can Docker) ----------------------------
.PHONY: cu-phap-php
cu-phap-php:
	@echo "== Cu phap PHP plugin (php -l trong container php:8.4-cli) =="
	@docker run --rm -v "$$PWD:/app" -w /app php:8.4-cli sh -c '\
	  set -e; N=0; \
	  for f in $$(find plugins -name "*.php" -not -path "*/vendor/*"); do \
	    php -l "$$f" >/dev/null; N=$$((N+1)); done; \
	  echo "  [OK] $$N file PHP"'

# --- ShellCheck (giong job 'shellcheck' cua CI) --------------------------------
.PHONY: shellcheck
shellcheck:
	@echo "== ShellCheck =="
	@if ! command -v shellcheck >/dev/null 2>&1; then \
	  echo "  [BO QUA] Chua cai shellcheck (apt/brew install shellcheck)"; \
	else \
	  shellcheck --severity=warning --shell=bash \
	    $$(find . -name '*.sh' -not -path './node_modules/*'); \
	  echo "  [OK] ShellCheck khong loi"; \
	fi

# --- Validate compose + nginx -t (giong job 'config') -------------------------
.PHONY: compose-kiem
compose-kiem:
	@echo "== docker compose config =="
	@docker compose config --quiet && echo "  [OK] docker-compose.yml hop le"
	@echo "== nginx -t (trong container that) =="
	@mkdir -p nginx/ssl
	@if [ ! -f nginx/ssl/glpi.crt ]; then \
	  openssl req -x509 -nodes -days 1 -newkey rsa:2048 \
	    -config nginx/ssl/openssl-san.cnf \
	    -keyout nginx/ssl/glpi.key -out nginx/ssl/glpi.crt 2>/dev/null; \
	fi
	@docker run --rm --add-host glpi:127.0.0.1 -e HTTPS_PORT=8443 \
	  -v "$$PWD/nginx/nginx.conf:/etc/nginx/nginx.conf:ro" \
	  -v "$$PWD/nginx/conf.d/default.conf:/etc/nginx/templates/default.conf.template:ro" \
	  -v "$$PWD/nginx/ssl:/etc/nginx/ssl:ro" \
	  -v "$$PWD/themes/pics/logos:/usr/share/nginx/html/logos:ro" \
	  -v "$$PWD/tai-lieu:/usr/share/nginx/html/tai-lieu:ro" \
	  -v "$$PWD/README.md:/usr/share/nginx/html/README.md:ro" \
	  nginx:1.27-alpine nginx -t

# --- Quet bi mat (giong job 'hygiene') ----------------------------------------
.PHONY: bao-mat
bao-mat:
	@echo "== Quet bi mat hardcode =="
	@bash scripts/quet-bi-mat.sh

# --- Bien dich lai ban dich tieng Viet ----------------------------------------
.PHONY: bien-dich
bien-dich:
	@echo "== Tao lop phu ban dich + gop =="
	@python scripts/tao-mo-bo-sung.py
	@python scripts/gop-ban-dich-tieng-viet.py
	@echo "== Do lai do phu tieng Viet =="
	@python scripts/do-do-phu-tieng-viet.py

# --- Kiem tra nhanh TONG HOP (truoc khi push) ---------------------------------
.PHONY: kiem-tra
kiem-tra: cu-phap shellcheck bao-mat compose-kiem
	@echo ""
	@echo "=============================================================="
	@echo "  KIEM TRA NHANH: XONG (chua chay smoke test)"
	@echo "=============================================================="
	@echo "  Muon thu khoi dong that: make smoke"
	@echo "  Muon kiem cu phap PHP plugin: make cu-phap-php"

# --- Smoke test (khoi dong that, ton ~5 phut) ---------------------------------
.PHONY: smoke
smoke:
	@echo "== Khoi dong he thong (docker compose up -d) =="
	@docker compose up -d
	@echo "  Cho cac container healthy..."
	@for i in $$(seq 1 60); do \
	  H=$$(docker ps --filter "name=pinedesk-" --filter "health=healthy" -q | wc -l); \
	  echo "  [$$i/60] healthy: $$H/4"; \
	  [ "$$H" -ge 4 ] && break; sleep 5; \
	done
	@curl -fsS http://localhost:8080/healthz && echo "  [OK] gateway tra loi"

# --- Van hanh thuong ngay -----------------------------------------------------
.PHONY: up down logs ps sao-luu
up:
	docker compose up -d
down:
	docker compose down
logs:
	docker compose logs -f glpi
ps:
	docker ps --filter "name=pinedesk-"
sao-luu:
	bash backup/backup.sh

.PHONY: giup
giup:
	@grep -E '^[a-zA-Z_-]+:' $(MAKEFILE_LIST) | sed 's/:.*//' | sort -u
