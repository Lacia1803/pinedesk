#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
================================================================================
 GOP BAN DICH TIENG VIET CHO GLPI  (MO + MO -> MO, khong can msgfmt)
================================================================================
 Do an thuc tap: Xay dung he thong ho tro ky thuat (PineDesk) - DH Da Lat
 Truong Dai hoc Da Lat

 ------------------------------------------------------------------------------
 VAN DE (da gap phai):
   GLPI 11 dong goi san /var/www/glpi/locales/vi_VN.mo voi ~2351 chuoi da dich.
   De bo sung them thuat ngu nghiep vu, ta dat mot file .mo "ghi de" vao
   files/_locales/core/vi_VN.mo.

   NHUNG: laminas-i18n khi nap cung domain+locale se THAY THE catalog cu,
   chu khong gop. Vi vay file ghi de KHONG DUOC PHEP thieu bat ky chuoi nao
   cua file goc - neu thieu, cac chuoi do se hien thi tieng Anh tro lai.
   (Tung bi loi: tieu de trang dang nhap "Authentication" bi mat ban dich
    chi vi file ghi de thieu entry nay.)

 ------------------------------------------------------------------------------
 GIAI PHAP (script nay):
   1. Doc file .mo GOC (day du) tu container        -> catalog nen
   2. Doc file .mo BO SUNG (chi chua thuat ngu moi) -> lop phu
   3. GOP: moi khoa trong lop phu de len catalog nen
   4. Ghi ra .mo hoan chinh (khong mat entry nao)
   5. Cai vao files/_locales/core/vi_VN.mo trong container
   6. Kiem tra lai: so entry >= ban goc, va cac chuoi quan trong co ban dich

 CHAY:
   python scripts/gop-ban-dich-tieng-viet.py            # gop + cai dat
   python scripts/gop-ban-dich-tieng-viet.py --chi-kiem-tra
================================================================================
"""
import importlib.util
import os
import re
import struct
import subprocess
import sys

# -----------------------------------------------------------------------------
# CAU HINH
# -----------------------------------------------------------------------------
GLPI_CONTAINER = os.environ.get('GLPI_CONTAINER', 'pinedesk-glpi')

# File .mo goc day du trong image GLPI
MO_GOC_TRONG_CONTAINER = '/var/www/glpi/locales/vi_VN.mo'
# File .mo bo sung (lop phu) do nguoi dung tao
MO_BO_SUNG_TRONG_CONTAINER = '/var/glpi/files/_locales/bo_sung/vi_VN.mo'
# Dich cai dat (GLPI se nap file nay SAU CUNG -> co quyen uu tien)
MO_DICH_TRONG_CONTAINER = '/var/glpi/files/_locales/core/vi_VN.mo'

HOST_TMP = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '.tmp-locale')

# Cac chuoi NGHIEP VU quan trong bat buoc phai co ban dich tieng Viet.
# Dung de kiem tra ket qua sau khi gop (tranh tai dien loi thieu entry).
CHUOI_KIEM_TRA = [
    'Authentication',            # Tieu de trang dang nhap
    'Login',                     # Nhan o ten dang nhap
    'Password',                  # Nhan o mat khau
    'Login to your account',     # Tieu de the dang nhap
    'Remember me',               # Hop kiem ghi nho
    'Forgotten password?',       # Lien ket quen mat khau
    'Dashboard',                 # Bang dieu khien
    'Assets',                    # Tai san / thiet bi
    'Assistance',                # Ho tro
    'Management',                # Quan ly
    'Tickets',                   # Phieu yeu cau
    'Computer',                  # May tinh
    'Software',                  # Phan mem
    'Network',                   # Mang
    'Maintenance',               # Bao tri
    'Location',                  # Vi tri
    'Status',                    # Trang thai
]

def nap_tu_dien_so_nhieu() -> dict:
    """
    Nap BAN_DICH_SO_NHIEU tu file tu dien dung chung (bo-sung-tieng-viet.py).

    Dung importlib vi ten file co dau gach ngang (khong import kieu thuong duoc).
    Tra ve dict rong neu khong nap duoc -> script van chay binh thuong.
    """
    duong_dan = os.path.join(
        os.path.dirname(os.path.abspath(__file__)), 'bo-sung-tieng-viet.py'
    )
    if not os.path.exists(duong_dan):
        return {}
    try:
        spec = importlib.util.spec_from_file_location('tu_dien_vn', duong_dan)
        mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mod)
        return getattr(mod, 'BAN_DICH_SO_NHIEU', {}) or {}
    except Exception:
        return {}


def nap_khoa_so_nhieu_tu_po(duong_dan: str) -> list:
    """
    Doc file .po, tra ve danh sach khoa SO NHIEU day du ("so_it\\0so_nhieu").

    VI SAO CAN DOC .po CHU KHONG DUNG .mo:
      msgfmt BO HAN entry co msgstr rong. Voi entry so nhieu, chi can
      msgstr[0] rong la ca entry bien mat khoi .mo. Do duoc tren ban vi_VN
      cua GLPI: .po co 452 entry so nhieu, .mo dong goi chi con 231.
      221 entry bi mat khoi catalog, nen _n() tra ve nguyen chuoi tieng Anh
      DU ban dich so it da co trong tu dien.
      Chi .po moi con giu du khoa cua so entry da mat do.
    """
    if not os.path.exists(duong_dan):
        return []

    with open(duong_dan, encoding='utf-8') as f:
        noi_dung = f.read()

    khoa = []
    for entry in re.split(r'\n\s*\n', noi_dung):
        if 'msgid' not in entry:
            continue
        if re.search(r'^#,\s*fuzzy', entry, re.M):
            continue
        if re.search(r'^msgctxt\s', entry, re.M):
            continue
        so_it = _lay_po(entry, 'msgid')
        so_nhieu = _lay_po(entry, 'msgid_plural')
        if so_it and so_nhieu:
            khoa.append(so_it + '\0' + so_nhieu)
    return khoa


def _lay_po(entry: str, khoa: str) -> str:
    """
    Trich msgid/msgid_plural tu mot entry .po.

    Noi cac dong noi tiep bang chuoi RONG: .po cat chuoi dai qua nhieu dong
    ma khong them phan cach, va dong dau luon rong. Noi bang dau cach se
    lam khoa sinh ra co them mot dau cach o dau -> khong bao gio khop.
    """
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
    return ''.join(x.strip().strip('"') for x in phan)


def cuu_entry_so_nhieu_bi_mat(ban_dich: dict, khoa_tu_po: list, tu_dien: dict) -> tuple:
    """
    Them lai cac entry SO NHIEU bi msgfmt bo khoi .mo, neu suy ra duoc ban dich.

    Nguon ban dich, theo thu tu uu tien:
      1. BAN_DICH_SO_NHIEU[so_it]   - ban dich viet tay cho dang so nhieu
      2. ban_dich[so_it]            - ban dich so it da co trong catalog

    Tra ve (dict, so_them).
    """
    so_them = 0
    for k in khoa_tu_po:
        if k in ban_dich:
            continue
        so_it, so_nhieu = k.split('\0', 1)
        moi = tu_dien.get(so_it) or ban_dich.get(so_it)
        if moi and moi not in (so_it, so_nhieu):
            ban_dich[k] = moi
            so_them += 1
    return ban_dich, so_them


def va_entry_so_nhieu(ban_dich: dict, tu_dien: dict) -> tuple:
    """
    Va cac entry dang SO NHIEU (khoa co chua ky tu \\0).

    VI SAO CAN:
      GLPI goi _n($it, $nhieu, $n) -> translatePlural() -> tra cuu entry co
      msgid_plural. Ban dich vi_VN chinh thuc cua GLPI de TRONG 212/443 entry
      dang nay (msgstr[0] = "" hoac van la tieng Anh), nen cac nhan nhu
      "Ticket", "Asset", "Category" hien thi tieng Anh du BAN_DICH_BO_SUNG
      da co ban dich (vi bang do chi tac dong len entry msgid DON).

    Cach va (theo thu tu uu tien):
      1. BAN_DICH_SO_NHIEU[msgid_so_it]      - ban dich viet tay
      2. ban_dich[msgid_so_it]               - tan dung ban dich so it da co
    Chi va khi ban dich hien tai RONG hoac van la tieng Anh.

    Tra ve (dict da va, so_entry_da_va, so_entry_con_thieu).
    """
    so_va = 0
    con_thieu = []

    for k in list(ban_dich):
        if '\0' not in k:
            continue

        so_it, so_nhieu = k.split('\0', 1)
        hien_tai = ban_dich[k]

        # Da co ban dich that su (khac ca hai dang tieng Anh) -> giu nguyen
        if hien_tai and hien_tai not in (so_it, so_nhieu, ''):
            continue

        moi = tu_dien.get(so_it) or ban_dich.get(so_it)
        if moi and moi not in (so_it, so_nhieu):
            ban_dich[k] = moi
            so_va += 1
        else:
            con_thieu.append(so_it)

    return ban_dich, so_va, con_thieu


GREEN = '\033[0;32m'; YELLOW = '\033[1;33m'; RED = '\033[0;31m'
CYAN = '\033[0;36m'; NC = '\033[0m'


def ok(msg):   print(f'{GREEN}[ OK ]{NC} {msg}')
def info(msg): print(f'{CYAN}[INFO]{NC} {msg}')
def warn(msg): print(f'{YELLOW}[CANH BAO]{NC} {msg}')
def err(msg):  print(f'{RED}[LOI]{NC} {msg}')


# -----------------------------------------------------------------------------
# DOC / GHI FILE .MO
# -----------------------------------------------------------------------------
def doc_mo(du_lieu: bytes) -> dict:
    """
    Doc file .mo (dinh dang GNU gettext), tra ve dict {msgid: msgstr}.

    Cau truc file .mo:
      - 7 truong uint32 o dau file: magic, revision, nstrings,
        offset_orig_table, offset_trans_table, hash_size, offset_hash_table
      - Bang "original" va "translation": moi entry 2 uint32 (length, offset)
      - Blob chuoi nam sau cac bang
    """
    if len(du_lieu) < 28:
        return {}
    magic, rev, n, off_orig, off_trans, _hs, _ht = struct.unpack('<7I', du_lieu[:28])
    if magic not in (0x950412de, 0xde120495):
        raise ValueError(
            f'File .mo khong hop le (magic=0x{magic:08x}). '
            'Phai la file gettext .mo nhi phan.'
        )

    def lay_chuoi(offset):
        length, pos = struct.unpack('<2I', du_lieu[offset:offset + 8])
        return du_lieu[pos:pos + length]

    ban_dich = {}
    for i in range(n):
        k = lay_chuoi(off_orig + i * 8)
        v = lay_chuoi(off_trans + i * 8)
        # msgid rong = header metadata, bo qua
        if k == b'':
            continue
        ban_dich[k.decode('utf-8', 'replace')] = v.decode('utf-8', 'replace')
    return ban_dich


def ghi_mo(ban_dich: dict, duong_dan: str):
    """
    Ghi file .mo theo dinh dang GNU gettext.
    Sap xep msgid theo thu tu byte de GLPI tra cuu nhi phan dung.
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

    # Blob chuoi: entry dau tien la header (msgid rong)
    id_blob = b'\x00'
    str_blob = header + b'\x00'
    offsets = [(0, 0, len(header))]

    for msgid, msgstr in items:
        id_b = msgid.encode('utf-8')
        str_b = msgstr.encode('utf-8')
        offsets.append((len(id_blob), len(str_blob), len(str_b)))
        id_blob += id_b + b'\x00'
        str_blob += str_b + b'\x00'

    tong = so_luong + 1
    off_orig_table = 7 * 4
    off_trans_table = off_orig_table + tong * 8
    off_blob = off_trans_table + tong * 8

    # Do dai cua tung msgid (entry 0 la header voi msgid rong)
    lengths_id = [0]
    for msgid, _ in items:
        lengths_id.append(len(msgid.encode('utf-8')))

    # Bang original (msgid) va translation (msgstr)
    orig_tbl = b''
    trans_tbl = b''
    id_cursor = off_blob
    str_cursor = off_blob + len(id_blob)
    for idx, (_id_off, _s_off, s_len) in enumerate(offsets):
        orig_tbl += struct.pack('<2I', lengths_id[idx], id_cursor)
        trans_tbl += struct.pack('<2I', s_len, str_cursor)
        id_cursor += lengths_id[idx] + 1
        str_cursor += s_len + 1

    out = struct.pack(
        '<7I',
        0x950412de,
        0,
        tong,
        off_orig_table,
        off_trans_table,
        0,
        0,
    )
    out += orig_tbl + trans_tbl + id_blob + str_blob

    with open(duong_dan, 'wb') as f:
        f.write(out)
    return so_luong


def doc_mo_tu_container(duong_dan_trong_container: str, duong_dan_tam: str) -> bool:
    """Copy file .mo tu container ra host."""
    try:
        with open(duong_dan_tam, 'wb') as f:
            subprocess.run(
                ['docker', 'exec', GLPI_CONTAINER, 'cat', duong_dan_trong_container],
                stdout=f, check=True,
            )
        return os.path.getsize(duong_dan_tam) > 0
    except (subprocess.CalledProcessError, OSError):
        return False


# -----------------------------------------------------------------------------
# KIEM TRA
# -----------------------------------------------------------------------------
def kiem_tra_ban_dich(ban_dich: dict) -> list:
    """Tra ve danh sach cac chuoi quan trong bi thieu ban dich."""
    thieu = []
    for chuoi in CHUOI_KIEM_TRA:
        dich = ban_dich.get(chuoi, '')
        if not dich or dich == chuoi:
            thieu.append(chuoi)
    return thieu


# -----------------------------------------------------------------------------
# MAIN
# -----------------------------------------------------------------------------
def main():
    chi_kiem_tra = '--chi-kiem-tra' in sys.argv

    print('=' * 72)
    print('  GOP BAN DICH TIENG VIET CHO GLPI')
    print('=' * 72)

    os.makedirs(HOST_TMP, exist_ok=True)

    # --- 1. Doc catalog GOC (day du) ----------------------------------------
    info('Buoc 1: Doc file .mo goc day du tu GLPI...')
    goc_tam = os.path.join(HOST_TMP, '_goc.mo')
    if not doc_mo_tu_container(MO_GOC_TRONG_CONTAINER, goc_tam):
        err(f'Khong doc duoc {MO_GOC_TRONG_CONTAINER} tu container "{GLPI_CONTAINER}".')
        err('Kiem tra container dang chay: docker ps')
        return 1

    with open(goc_tam, 'rb') as f:
        ban_goc = doc_mo(f.read())
    ok(f'Catalog goc: {len(ban_goc)} chuoi da dich')

    # --- 2. Doc lop phu (neu co) -------------------------------------------
    info('Buoc 2: Doc file .mo bo sung (lop phu)...')
    lop_phu = {}
    lop_phu_tam = os.path.join(HOST_TMP, '_bo_sung.mo')
    if doc_mo_tu_container(MO_BO_SUNG_TRONG_CONTAINER, lop_phu_tam):
        with open(lop_phu_tam, 'rb') as f:
            lop_phu = doc_mo(f.read())
        ok(f'Lop phu: {len(lop_phu)} chuoi')
    else:
        warn('Chua co file .mo bo sung -> chi giu nguyen catalog goc.')
        warn(f'  Tao file tai: {MO_BO_SUNG_TRONG_CONTAINER}')

    # --- 3. GOP -------------------------------------------------------------
    info('Buoc 3: Gop (lop phu de len catalog goc)...')
    ban_gop = dict(ban_goc)          # giu nguyen TOAN BO chuoi goc
    so_moi = 0
    so_de = 0
    for k, v in lop_phu.items():
        if not v:
            continue                  # bo qua ban dich rong
        if k in ban_gop:
            if ban_gop[k] != v:
                so_de += 1
        else:
            so_moi += 1
        ban_gop[k] = v
    ok(f'Ket qua: {len(ban_gop)} chuoi ({so_moi} moi, {so_de} ghi de)')

    # --- 3b. Va cac entry dang SO NHIEU -------------------------------------
    info('Buoc 3b: Va cac entry SO NHIEU (GLPI dung _n -> translatePlural)...')
    tu_dien_so_nhieu = nap_tu_dien_so_nhieu()
    if not tu_dien_so_nhieu:
        warn('Khong nap duoc BAN_DICH_SO_NHIEU -> bo qua buoc nay.')
    else:
        ban_gop, so_va, con_thieu = va_entry_so_nhieu(ban_gop, tu_dien_so_nhieu)
        ok(f'Da va {so_va} entry so nhieu (tu dien: {len(tu_dien_so_nhieu)} muc)')
        if con_thieu:
            warn(f'Con {len(con_thieu)} entry so nhieu chua dich duoc. Vi du: '
                 f'{con_thieu[:6]}')

        # Buoc 3c: THEM MOI entry so nhieu — CHI khi biet chac khoa day du.
        #
        # VI SAO PHAI THAN TRONG:
        #   Khoa tra cuu cua entry so nhieu la "so_it\\0so_NHIEU" voi so_NHIEU lay
        #   DUNG theo chuoi trong ma nguon GLPI (vd _n('Asset','Assets',$n) ->
        #   khoa "Asset\\0Assets"). Neu chi doan so nhieu (vd dat "Asset\\0Asset")
        #   thi gettext se KHONG BAO GIO tra cuu toi -> entry chet, lam phinh tep
        #   ma khong co tac dung gi.
        #   Vi vay chi nhan nhung muc ghi ro ca hai dang, ngan cach bang ky tu NUL
        #   ngay trong tu dien. Cac muc chi co so it o tren chi dung de VA entry
        #   da ton tai, khong dung de them moi.
        so_them = 0
        for khoa, ban_dich_moi in tu_dien_so_nhieu.items():
            if '\0' not in khoa:
                continue          # chi la so it -> khong du thong tin de them
            if khoa in ban_gop:
                continue          # da co san
            ban_gop[khoa] = ban_dich_moi
            so_them += 1
        if so_them:
            ok(f'Da THEM MOI {so_them} entry so nhieu (khoa day du da biet)')
        else:
            info('Khong co entry so nhieu nao can them moi.')

    # --- 3d. CUU cac entry so nhieu bi msgfmt bo khoi .mo ------------------
    #
    # VI SAO CAN BUOC RIENG:
    #   Buoc 3b/3c chi lam viec tren nhung entry CON trong catalog. Nhung
    #   msgfmt bo HAN entry co msgstr rong, va voi entry so nhieu thi chi can
    #   msgstr[0] rong la ca entry bien mat. Do tren ban vi_VN cua GLPI: .po
    #   co 452 entry so nhieu, .mo dong goi chi con 231.
    #   => 221 entry vang mat khoi catalog. _n() tra ve nguyen chuoi tieng
    #      Anh, du ban dich so it da co trong tu dien.
    #   Chi .po moi con giu khoa cua so entry da mat do, nen phai doc .po.
    info('Buoc 3d: Cuu cac entry so nhieu bi msgfmt bo khoi .mo...')
    po_nguon = os.path.join(HOST_TMP, 'vi_VN.po')
    if not os.path.exists(po_nguon) or os.path.getsize(po_nguon) == 0:
        # .po khong duoc version hoa nhung luon tai lai duoc tu image GLPI.
        r = subprocess.run(
            ['docker', 'exec', GLPI_CONTAINER, 'cat',
             '/var/www/glpi/locales/vi_VN.po'],
            capture_output=True)
        if r.stdout:
            with open(po_nguon, 'wb') as f:
                f.write(r.stdout)
            ok(f'Da tai vi_VN.po tu container ({len(r.stdout):,} byte)')
    khoa_po = nap_khoa_so_nhieu_tu_po(po_nguon)
    if khoa_po:
        ban_gop, so_cuu = cuu_entry_so_nhieu_bi_mat(
            ban_gop, khoa_po, tu_dien_so_nhieu)
        ok(f'Da cuu {so_cuu} entry so nhieu bi thieu '
           f'(.po co {len(khoa_po)} khoa so nhieu)')
    else:
        warn(f'Khong doc duoc khoa so nhieu tu {po_nguon} -> bo qua buoc nay.')

    # Kiem tra khong mat chuoi nao so voi ban goc
    mat = set(ban_goc) - set(ban_gop)
    if mat:
        err(f'MAT {len(mat)} chuoi so voi ban goc! Vi du: {list(mat)[:5]}')
        return 1
    ok('Khong mat chuoi nao so voi ban goc')

    # --- 4. Kiem tra chat luong --------------------------------------------
    info('Buoc 4: Kiem tra cac chuoi nghiep vu quan trong...')
    thieu = kiem_tra_ban_dich(ban_gop)
    if thieu:
        warn(f'{len(thieu)} chuoi quan trong chua co ban dich:')
        for t in thieu:
            warn(f'    - {t}')
    else:
        ok(f'Ca {len(CHUOI_KIEM_TRA)} chuoi quan trong deu da duoc dich')

    if chi_kiem_tra:
        print()
        info('Che do --chi-kiem-tra: khong ghi file.')
        return 0

    # --- 5. Ghi file .mo hoan chinh ----------------------------------------
    info('Buoc 5: Ghi file .mo hoan chinh...')
    mo_hoan_chinh = os.path.join(HOST_TMP, 'vi_VN_hoan_chinh.mo')
    so_ghi = ghi_mo(ban_gop, mo_hoan_chinh)
    kich_thuoc = os.path.getsize(mo_hoan_chinh)
    ok(f'Da ghi: {so_ghi} chuoi, {kich_thuoc:,} byte')

    # Doc lai de chac chan file hop le
    with open(mo_hoan_chinh, 'rb') as f:
        kiem_tra_lai = doc_mo(f.read())
    if len(kiem_tra_lai) != so_ghi:
        err(f'File ghi ra khong doc lai duoc day du ({len(kiem_tra_lai)} != {so_ghi})')
        return 1
    ok('Doc lai file thanh cong')

    # --- 6. Cai vao container ----------------------------------------------
    info('Buoc 6: Cai vao GLPI (files/_locales/core/vi_VN.mo)...')
    mo_win = os.path.abspath(mo_hoan_chinh).replace('/', '\\')
    # Dam bao thu muc ton tai
    subprocess.run(
        ['docker', 'exec', GLPI_CONTAINER, 'sh', '-c',
         'mkdir -p /var/glpi/files/_locales/core && chown -R www-data:www-data /var/glpi/files/_locales'],
        check=True,
    )
    subprocess.run(
        ['docker', 'cp', mo_win, f'{GLPI_CONTAINER}:{MO_DICH_TRONG_CONTAINER}'],
        check=True,
    )
    subprocess.run(
        ['docker', 'exec', GLPI_CONTAINER, 'sh', '-c',
         'chown www-data:www-data /var/glpi/files/_locales/core/vi_VN.mo'],
        check=True,
    )
    ok(f'Da cai: {MO_DICH_TRONG_CONTAINER}')

    # --- 7. Xoa cache -------------------------------------------------------
    info('Buoc 7: Xoa cache de GLPI nap lai ban dich...')
    subprocess.run(
        ['docker', 'exec', GLPI_CONTAINER, 'sh', '-c',
         'rm -rf /var/glpi/files/_cache/* 2>/dev/null; true'],
        check=False,
    )
    ok('Da xoa cache')

    print()
    print('=' * 72)
    print('  HOAN TAT')
    print('=' * 72)
    print(f'  Tong so chuoi dich : {so_ghi}')
    print(f'  File cai dat       : {MO_DICH_TRONG_CONTAINER}')
    print()
    print('  KIEM TRA: mo trinh duyet (che do an danh) -> trang dang nhap')
    print('  phai hien tieng Viet, ke ca tieu de tab "Xac thuc - GLPI".')
    print()
    return 0


if __name__ == '__main__':
    sys.exit(main())
