#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
================================================================================
 TAO FILE .MO BO SUNG TIENG VIET CHO GLPI  (tu .po + tu dien nghiep vu)
================================================================================
 Do an thuc tap: Xay dung he thong ho tro ky thuat (IT Helpdesk) - DH Da Lat

 MUC DICH:
   Tao file "lop phu" .mo chua cac ban dich BO SUNG (ngoai ban chinh thuc cua
   GLPI). File nay sau do duoc GOP vao catalog goc bang:
       python scripts/gop-ban-dich-tieng-viet.py

 NGUON BAN DICH:
   1. File .po cua GLPI  -> lay moi chuoi DA DUOC DICH (msgstr khac rong)
      va KHAC voi ban dich dang co trong .mo goc (tuc la ban .po day du hon)
   2. Tu dien BAN_DICH_BO_SUNG trong scripts/bo-sung-tieng-viet.py
      -> thuat ngu nghiep vu do an tu bo sung

 VI SAO PHAI TACH RIENG?
   - De co the bo sung dan theo thoi gian (them tu dien, chay lai)
   - De file gop luon GIU DU ban chinh thuc (khong bao gio mat chuoi)

 CHAY:
   python scripts/tao-mo-bo-sung.py
================================================================================
"""
import os
import re
import struct
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
TMP = os.path.join(ROOT, '.tmp-locale')
GLPI_CONTAINER = os.environ.get('GLPI_CONTAINER', 'helpdesk-glpi')

MO_GOC = '/var/www/glpi/locales/vi_VN.mo'
PO_NGUON = os.path.join(TMP, 'vi_VN.po')
SCRIPT_TU_DIEN = os.path.join(HERE, 'bo-sung-tieng-viet.py')
MO_BO_SUNG_RA = os.path.join(TMP, 'vi_VN_bo_sung.mo')
DICH_TRONG_CONTAINER = '/var/glpi/files/_locales/bo_sung/vi_VN.mo'

GREEN = '\033[0;32m'; YELLOW = '\033[1;33m'; RED = '\033[0;31m'
CYAN = '\033[0;36m'; NC = '\033[0m'


def ok(m):   print(f'{GREEN}[ OK ]{NC} {m}')
def info(m): print(f'{CYAN}[INFO]{NC} {m}')
def warn(m): print(f'{YELLOW}[CANH BAO]{NC} {m}')
def err(m):  print(f'{RED}[LOI]{NC} {m}')


# -----------------------------------------------------------------------------
# DOC / GHI .MO (ban da kiem chung bang round-trip)
# -----------------------------------------------------------------------------
def doc_mo(du_lieu: bytes) -> dict:
    """Doc file .mo gettext -> {msgid: msgstr}. Bo qua header (msgid rong)."""
    if len(du_lieu) < 28:
        return {}
    magic, _rev, n, off_orig, off_trans, _hs, _ht = struct.unpack('<7I', du_lieu[:28])
    if magic not in (0x950412de, 0xde120495):
        raise ValueError(f'File .mo khong hop le (magic=0x{magic:08x})')

    def s(off):
        length, pos = struct.unpack('<2I', du_lieu[off:off + 8])
        return du_lieu[pos:pos + length]

    out = {}
    for i in range(n):
        k = s(off_orig + i * 8)
        v = s(off_trans + i * 8)
        if k == b'':
            continue
        out[k.decode('utf-8', 'replace')] = v.decode('utf-8', 'replace')
    return out


def ghi_mo(ban_dich: dict, duong_dan: str) -> int:
    """
    Ghi file .mo chuan GNU gettext.

    Cau truc:
      [7 x uint32 header]
      [bang original:  n x (len, off)]
      [bang translation: n x (len, off)]
      [blob msgid: cac chuoi noi nhau bang \\x00]
      [blob msgstr: cac chuoi noi nhau bang \\x00]
    """
    items = sorted(ban_dich.items(), key=lambda x: x[0].encode('utf-8'))
    so_luong = len(items)

    header = (
        'Project-Id-Version: GLPI 11 VI (do an DLU)\n'
        'MIME-Version: 1.0\n'
        'Content-Type: text/plain; charset=UTF-8\n'
        'Content-Transfer-Encoding: 8bit\n'
        'Language: vi_VN\n'
        'Plural-Forms: nplurals=1; plural=0;\n'
    ).encode('utf-8')

    # Blob chuoi: entry 0 = header (msgid rong)
    id_blob = b'\x00'
    str_blob = header + b'\x00'
    lengths_id = [0]
    lengths_str = [len(header)]

    for msgid, msgstr in items:
        id_b = msgid.encode('utf-8')
        str_b = msgstr.encode('utf-8')
        lengths_id.append(len(id_b))
        lengths_str.append(len(str_b))
        id_blob += id_b + b'\x00'
        str_blob += str_b + b'\x00'

    tong = so_luong + 1
    off_orig_table = 7 * 4
    off_trans_table = off_orig_table + tong * 8
    off_blob = off_trans_table + tong * 8

    orig_tbl = b''
    trans_tbl = b''
    id_cursor = off_blob
    str_cursor = off_blob + len(id_blob)
    for idx in range(tong):
        orig_tbl += struct.pack('<2I', lengths_id[idx], id_cursor)
        trans_tbl += struct.pack('<2I', lengths_str[idx], str_cursor)
        id_cursor += lengths_id[idx] + 1
        str_cursor += lengths_str[idx] + 1

    out = struct.pack('<7I', 0x950412de, 0, tong,
                      off_orig_table, off_trans_table, 0, 0)
    out += orig_tbl + trans_tbl + id_blob + str_blob

    with open(duong_dan, 'wb') as f:
        f.write(out)
    return so_luong


# -----------------------------------------------------------------------------
# DOC .PO
# -----------------------------------------------------------------------------
def doc_po(duong_dan: str) -> dict:
    """Doc .po -> {msgid: msgstr}. Bo qua entry fuzzy va ban dich rong."""
    if not os.path.exists(duong_dan):
        return {}
    with open(duong_dan, encoding='utf-8') as f:
        noi_dung = f.read()

    ket_qua = {}
    for entry in re.split(r'\n\s*\n', noi_dung):
        if 'msgid' not in entry:
            continue
        if re.search(r'^#,\s*fuzzy', entry, re.M):
            continue
        # Bo qua entry co msgctxt (can key rieng, khong dung cho GLPI core)
        if re.search(r'^msgctxt\s', entry, re.M):
            continue

        msgid = _lay(entry, 'msgid')
        msgstr = _lay(entry, 'msgstr')
        if msgid and msgstr:
            ket_qua[msgid] = msgstr
    return ket_qua


def _lay(entry: str, khoa: str) -> str:
    """Trich gia tri msgid/msgstr (ho tro chuoi noi tiep nhieu dong)."""
    phan = []
    gom = False
    for ln in entry.split('\n'):
        s = ln.strip()
        if s.startswith(khoa + ' ') and not s.startswith(khoa + '_'):
            gom = True
            phan.append(s[len(khoa) + 1:].strip())
        elif gom and s.startswith('"'):
            phan.append(s)
        elif gom:
            break
    if not phan:
        return ''
    return ' '.join(x.strip().strip('"') for x in phan)


def doc_tu_dien_nghiep_vu(duong_dan: str) -> dict:
    """Doc dict BAN_DICH_BO_SUNG tu script bo-sung-tieng-viet.py."""
    if not os.path.exists(duong_dan):
        return {}
    src = open(duong_dan, encoding='utf-8').read()
    m = re.search(r'BAN_DICH_BO_SUNG\s*=\s*\{(.*?)\n\}', src, re.S)
    if not m:
        return {}
    d = {}
    for mm in re.finditer(
            r'"((?:[^"\\]|\\.)*)"\s*:\s*"((?:[^"\\]|\\.)*)"', m.group(1)):
        k = _giai_escape(mm.group(1))
        v = _giai_escape(mm.group(2))
        if k and v:
            d[k] = v
    return d


def _giai_escape(s: str) -> str:
    """
    Giai cac escape sequence trong chuoi Python literal.

    QUAN TRONG: khong dung unicode_escape vi no lam hong ky tu Unicode
    (vi du "Tên" -> "TÃªn"). Chi xu ly cac escape thuc su can thiet.
    """
    return (s
            .replace('\\"', '"')
            .replace('\\n', '\n')
            .replace('\\t', '\t')
            .replace('\\\\', '\\'))


# -----------------------------------------------------------------------------
# MAIN
# -----------------------------------------------------------------------------
def main():
    print('=' * 74)
    print('  TAO FILE .MO BO SUNG TIENG VIET')
    print('=' * 74)

    os.makedirs(TMP, exist_ok=True)

    # 1. Doc .mo goc
    info('Buoc 1: Doc ban dich goc cua GLPI...')
    raw = subprocess.run(['docker', 'exec', GLPI_CONTAINER, 'cat', MO_GOC],
                         capture_output=True).stdout
    if not raw:
        err(f'Khong doc duoc {MO_GOC}. Container "{GLPI_CONTAINER}" da chay chua?')
        return 1
    goc = doc_mo(raw)
    ok(f'Ban goc: {len(goc)} chuoi')

    # 2. Doc .po (ban day du hon)
    info('Buoc 2: Doc file .po cua GLPI...')
    tu_po = doc_po(PO_NGUON)
    if tu_po:
        ok(f'Tu .po: {len(tu_po)} chuoi da dich')
    else:
        warn(f'Khong thay {PO_NGUON} -> chi dung tu dien nghiep vu')

    # 3. Doc tu dien nghiep vu
    info('Buoc 3: Doc tu dien nghiep vu cua do an...')
    tu_dien = doc_tu_dien_nghiep_vu(SCRIPT_TU_DIEN)
    ok(f'Tu dien nghiep vu: {len(tu_dien)} thuat ngu')

    # 4. Gop thanh lop phu: chi giu chuoi MOI hoac KHAC ban goc
    info('Buoc 4: Loc ra cac ban dich bo sung...')
    lop_phu = {}
    for nguon in (tu_po, tu_dien):
        for k, v in nguon.items():
            if not v:
                continue
            if goc.get(k, '') != v:      # moi hoac khac ban goc
                lop_phu[k] = v
    ok(f'Lop phu: {len(lop_phu)} chuoi (moi + ghi de)')

    # 5. Ghi ra file
    info('Buoc 5: Ghi file .mo bo sung...')
    so = ghi_mo(lop_phu, MO_BO_SUNG_RA)
    kt = doc_mo(open(MO_BO_SUNG_RA, 'rb').read())
    if kt != lop_phu:
        err('File ghi ra khong khop khi doc lai!')
        return 1
    ok(f'Da ghi: {so} chuoi, {os.path.getsize(MO_BO_SUNG_RA):,} byte (kiem chung OK)')

    # 6. Cai vao container
    info('Buoc 6: Cai vao GLPI (files/_locales/bo_sung/)...')
    subprocess.run(['docker', 'exec', GLPI_CONTAINER, 'sh', '-c',
                    'mkdir -p /var/glpi/files/_locales/bo_sung'], check=True)
    win = os.path.abspath(MO_BO_SUNG_RA).replace('/', '\\')
    subprocess.run(['docker', 'cp', win,
                    f'{GLPI_CONTAINER}:{DICH_TRONG_CONTAINER}'], check=True)
    subprocess.run(['docker', 'exec', GLPI_CONTAINER, 'sh', '-c',
                    'chown -R www-data:www-data /var/glpi/files/_locales'], check=True)
    ok(f'Da cai: {DICH_TRONG_CONTAINER}')

    print()
    print('BUOC TIEP THEO: gop vao catalog chinh bang:')
    print('   python scripts/gop-ban-dich-tieng-viet.py')
    print()
    return 0


if __name__ == '__main__':
    sys.exit(main())
