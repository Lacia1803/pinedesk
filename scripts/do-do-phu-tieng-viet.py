#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
================================================================================
 DO DO PHU BAN DICH TIENG VIET CUA GLPI  (do chinh xac, doc .mo thuc te)
================================================================================
 Do an thuc tap: Xay dung he thong ho tro ky thuat (IT Helpdesk) - DH Da Lat

 Script nay do TI LE THAT cua ban dich dang duoc GLPI su dung, bang cach:
   1. Lay tap hop "chuoi goc" (msgid) tu file .po nguon cua GLPI
      -> day la toan bo chuoi GLPI can dich (khong ke header)
   2. Doc file .mo THUC TE dang cai trong container
      (/var/glpi/files/_locales/core/vi_VN.mo)
   3. Dem so chuoi da co ban dich (msgstr khac rong va khac chinh msgid)
   4. Bao cao ti le + nhom chuoi con thieu theo chu de nghiep vu

 KHAC BIET voi ban cu:
   Ban cu do tren file .po (chi phan anh ban dich CHINH THUC cua GLPI ~32%).
   Ban nay do tren file .mo DA GOP (moi duoc cai dat) -> phan anh dung
   nhung gi nguoi dung thuc su nhin thay tren giao dien.

 CHAY:
   python scripts/do-do-phu-tieng-viet.py
   python scripts/do-do-phu-tieng-viet.py --chi-tiet   # liet ke chuoi thieu
================================================================================
"""
import os
import re
import struct
import subprocess
import sys

GLPI_CONTAINER = os.environ.get('GLPI_CONTAINER', 'helpdesk-glpi')
MO_THUC_TE = '/var/glpi/files/_locales/core/vi_VN.mo'
PO_NGUON = '/var/www/glpi/locales/vi_VN.po'
PO_NGUON_LOCAL = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..', '.tmp-locale', 'vi_VN.po'
)

# Cac nhom chu de nghiep vu -> tu khoa nhan dien (chi de phan loai bao cao)
NHOM_NGHIEP_VU = {
    'Su co / Phieu':        ['ticket', 'incident', 'request', 'problem', 'change',
                             'followup', 'solution', 'urgency', 'impact', 'priority'],
    'Thiet bi / Tai san':   ['asset', 'computer', 'monitor', 'printer', 'peripheral',
                             'device', 'equipment', 'hardware', 'model', 'brand',
                             'inventory', 'phone', 'laptop'],
    'Phan mem / Ban quyen': ['software', 'license', 'version', 'antivirus',
                             'application', 'operating system'],
    'Mang / Ket noi':       ['network', 'ip', 'port', 'switch', 'router', 'wifi',
                             'vlan', 'socket', 'ethernet', 'cable', 'domain'],
    'Bao tri / Hop dong':   ['maintenance', 'contract', 'supplier', 'warranty',
                             'budget', 'cost', 'financial'],
    'Thong ke / Dashboard': ['dashboard', 'report', 'statistic', 'chart', 'graph',
                             'summary', 'count', 'metric'],
    'Nguoi dung / Quyen':   ['user', 'group', 'profile', 'right', 'permission',
                             'role', 'authentication', 'password', 'login'],
    'Cau hinh / He thong':  ['config', 'setting', 'parameter', 'setup', 'log',
                             'notification', 'entity', 'rule', 'cron'],
}

GREEN = '\033[0;32m'; YELLOW = '\033[1;33m'; RED = '\033[0;31m'
CYAN = '\033[0;36m'; BOLD = '\033[1m'; NC = '\033[0m'


def doc_mo(du_lieu: bytes) -> dict:
    """Doc file .mo gettext -> dict {msgid: msgstr}."""
    if len(du_lieu) < 28:
        return {}
    magic, _rev, n, off_orig, off_trans, _hs, _ht = struct.unpack('<7I', du_lieu[:28])
    if magic not in (0x950412de, 0xde120495):
        raise ValueError('File .mo khong hop le')

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


def doc_po_msgids(duong_dan: str) -> set:
    """Doc tap hop msgid tu file .po. msgid la toan bo chuoi goc can dich."""
    msgids = set()
    if not os.path.exists(duong_dan):
        return msgids
    with open(duong_dan, encoding='utf-8') as f:
        noi_dung = f.read()

    for entry in re.split(r'\n\s*\n', noi_dung):
        if 'msgid' not in entry:
            continue
        # Trong .po, khoi "msgid" vien nguoc la msgid_plural. Bo qua plural
        # bang cach chi lay dong bat dau bang 'msgid "' hoac "msgid ".
        lines = entry.split('\n')
        buf, gom = [], False
        for ln in lines:
            s = ln.strip()
            if s.startswith('msgid_plural') or s.startswith('msgctxt'):
                gom = False
                continue
            if s.startswith('msgid '):
                gom = True
                buf.append(s[len('msgid '):].strip())
            elif s.startswith('msgstr'):
                gom = False
            elif gom and s.startswith('"'):
                buf.append(s)
            elif gom:
                gom = False
        if buf:
            txt = ' '.join(x.strip().strip('"') for x in buf)
            if txt:
                msgids.add(txt)
    return msgids


def phan_loai(chuoi: str) -> str:
    """Gan 1 chuoi vao nhom chu de nghiep vu (chi de bao cao)."""
    low = chuoi.lower()
    for nhom, tu_khoa in NHOM_NGHIEP_VU.items():
        for tu in tu_khoa:
            if tu in low:
                return nhom
    return 'Khac'


def main():
    chi_tiet = '--chi-tiet' in sys.argv

    print('=' * 74)
    print('  DO DO PHU BAN DICH TIENG VIET (doc file .mo thuc te trong GLPI)')
    print('=' * 74)
    print()

    # --- 1. Tap hop chuoi goc tu .po ----------------------------------------
    # .po khong duoc version hoa (xem .gitignore) nhung luon tai lai duoc tu
    # image GLPI -> tu dong lay ve khi thieu (cung co che voi cac script dich).
    po_path = PO_NGUON_LOCAL
    if not os.path.exists(po_path) or os.path.getsize(po_path) == 0:
        os.makedirs(os.path.dirname(po_path), exist_ok=True)
        r = subprocess.run(['docker', 'exec', GLPI_CONTAINER, 'cat', PO_NGUON],
                           capture_output=True)
        if r.stdout:
            with open(po_path, 'wb') as f:
                f.write(r.stdout)
            print(f'{CYAN}[INFO]{NC} Da tai vi_VN.po tu container ({len(r.stdout):,} byte)')
        else:
            po_path = PO_NGUON
    msgids = doc_po_msgids(po_path)
    if not msgids:
        print(f'{RED}[LOI]{NC} Khong doc duoc file .po nguon: {po_path}')
        return 1
    print(f'{CYAN}[1]{NC} Chuoi goc can dich (tu .po)   : {len(msgids):>6,}')

    # --- 2. Doc .mo thuc te dang dung ---------------------------------------
    tmp = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..',
                       '.tmp-check', '_coverage.mo')
    os.makedirs(os.path.dirname(tmp), exist_ok=True)
    try:
        with open(tmp, 'wb') as f:
            subprocess.run(['docker', 'exec', GLPI_CONTAINER, 'cat', MO_THUC_TE],
                           stdout=f, check=True)
        with open(tmp, 'rb') as f:
            ban_dich = doc_mo(f.read())
    except (subprocess.CalledProcessError, OSError, ValueError) as e:
        print(f'{RED}[LOI]{NC} Khong doc duoc {MO_THUC_TE}: {e}')
        return 1
    print(f'{CYAN}[2]{NC} Ban dich dang dung trong GLPI     : {len(ban_dich):>6,}')

    # --- 3. Tinh do phu -----------------------------------------------------
    # Mot chuoi duoc coi la DA DICH neu:
    #   - co msgid trong .po nguon
    #   - VA ban dich khac rong, khac chinh chuoi goc
    da_dich, thieu = set(), []
    for mid in msgids:
        dich = ban_dich.get(mid, '')
        if dich and dich != mid:
            da_dich.add(mid)
        else:
            thieu.append(mid)

    tong = len(msgids)
    so_da = len(da_dich)
    ti_le = so_da / tong * 100 if tong else 0

    print()
    print(f'{BOLD}[3] DO PHU THUC TE TREN GIAO DIEN{NC}')
    print(f'    Da dich              : {so_da:>6,} / {tong:,}')
    print(f'    Con thieu            : {len(thieu):>6,}')
    print(f'    => Ti le             : {BOLD}{ti_le:.1f}%{NC}')

    # Thanh truc quan
    day = int(ti_le / 2)
    mau = GREEN if ti_le >= 80 else (YELLOW if ti_le >= 50 else RED)
    print(f'    {mau}[{"#" * day}{" " * (50 - day)}]{NC} {ti_le:.1f}%')

    # --- 4. Phan nhom chuoi con thieu --------------------------------------
    print()
    print(f'{BOLD}[4] CHUOI CON THIEU THEO NHOM NGHIEP VU{NC}')
    dem = {}
    for mid in thieu:
        dem[phan_loai(mid)] = dem.get(phan_loai(mid), 0) + 1
    for nhom, so in sorted(dem.items(), key=lambda x: -x[1]):
        pct = so / len(thieu) * 100 if thieu else 0
        print(f'    {nhom:<24} {so:>5} chuoi  ({pct:4.1f}%)')

    # --- 5. Liet ke chi tiet (neu can) --------------------------------------
    if chi_tiet:
        print()
        print(f'{BOLD}[5] DANH SACH CHUOI CON THIEU (100 dau tien){NC}')
        for mid in sorted(thieu)[:100]:
            print(f'    - {mid}')

    # --- 6. Ket luan --------------------------------------------------------
    print()
    print('=' * 74)
    print(f'{BOLD}  KET LUAN{NC}')
    print('=' * 74)
    if ti_le >= 99:
        print(f'  {GREEN}=> DAT: gan nhu 100% tieng Viet.{NC}')
    elif ti_le >= 80:
        print(f'  {GREEN}=> TOT: {ti_le:.1f}% da duoc Viet hoa.{NC}')
    else:
        print(f'  {YELLOW}=> Trung binh: {ti_le:.1f}% da duoc Viet hoa.{NC}')
    print(f'  File dang dung : {MO_THUC_TE}')
    print(f'  Goc tham chieu : {po_path}')
    print()
    print('  LUU Y: GLPI chi dong goi san ~32% ban dich tieng Viet chinh thuc.')
    print('  Con lai phai bo sung thu cong vao BAN_DICH_BO_SUNG, sau do chay:')
    print('    python scripts/gop-ban-dich-tieng-viet.py')
    print()
    return 0


if __name__ == '__main__':
    sys.exit(main())
