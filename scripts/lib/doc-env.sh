#!/usr/bin/env bash
# ==============================================================================
#  DOC FILE .env MOT CACH AN TOAN (khong thuc thi nhu shell script)
# ==============================================================================
#  VAN DE (da bi chi ra khi phan bien):
#    Cac script cu dung `source .env` hoac `. .env` — tuc la NHO shell
#    THUC THI file cau hinh nhu ma lenh. Hau qua that:
#      - Gia tri chua $() hoac backtick bi THUC THI (lo hong thuc thi ma neu
#        .env bi sua doi hoac lay tu noi khac).
#      - Mat khau chua ky tu dac biet ($, ;, ...) bi shell cat cut hoac hieu
#        sai -> am tham sai gia tri (da kiem chung voi mat khau mau).
#      - `source .env 2>/dev/null || true` nuot moi loi -> khong ai biet file
#        cau hinh hong.
#    Du an da co bo doc an toan trong backup/backup.sh; file nay dua bo doc do
#    thanh MOT nguon su that duy nhat cho moi script (truoc day co 5 ban doc
#    .env khac nhau, trong do 3 ban dung `source`).
#
#  CACH DUNG:
#    . "$(dirname "${BASH_SOURCE[0]}")/lib/doc-env.sh"   # tu scripts/<ten>.sh
#    . "$PROJECT_DIR/scripts/lib/doc-env.sh"             # tu start.sh
#    doc_env [duong-dan-file]                            # mac dinh: .env
#
#  TRA VE: 0 = da doc xong (file ton tai); 1 = khong tim thay file.
#  Dong khong hop le duoc CANH BAO ro rang (khong nuot im lang).
# ==============================================================================

doc_env() {
    local file="${1:-.env}"

    if [ ! -f "$file" ]; then
        echo "  [LOI] Khong tim thay file cau hinh: $file" >&2
        return 1
    fi

    local _key _val
    # `|| [ -n "$_key" ]`: dong cuoi file thieu ky tu xuong dong van duoc doc.
    # IFS='=' tach tai dau '=' DAU TIEN; phan con lai (co the chua '=') giu
    # nguyen trong _val.
    while IFS='=' read -r _key _val || [ -n "$_key" ]; do
        # Windows (Notepad) ghi CRLF -> bo \r o cuoi de gia tri sach.
        _key="${_key%$'\r'}"
        _val="${_val%$'\r'}"
        case "$_key" in
            ''|\#*) continue ;;
        esac
        # Chi nhan ten bien hop le ([A-Za-z_][A-Za-z0-9_]*). Dong la (vd
        # "FOO BAR=x" do go nham) duoc bao ro rang thay vi de `export` bao
        # kho hieu hoac bo qua im lang.
        case "$_key" in
            [!A-Za-z_]*|*[!A-Za-z0-9_]*)
                echo "  [CANH BAO] Bo qua dong khong hop le trong $file: $_key" >&2
                continue
                ;;
        esac
        export "$_key=$_val"
    done < "$file"

    return 0
}
