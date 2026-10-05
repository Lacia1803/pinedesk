#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
 Do an thuc tap: Xay dung he thong ho tro ky thuat (PineDesk) - DH Da Lat

 Script nay CHI do mot chi so, dung nguon du lieu THAT:
   - catalog goc  : tap msgid tu file vi_VN.po cua GLPI  (= 6.511 chuoi)
   - ban dich dung: file /var/glpi/files/_locales/core/vi_VN.mo DANG cai
                    trong container GLPI
   => Ti le = so chuoi co ban dich khac rong VA khac chuoi goc / tong msgid

 LUU Y: day la cung cong thuc voi scripts/do-do-phu-tieng-viet.py. Hai script
        phai cho ra CUNG mot con so (hien tai 32,0%).

 CHAY:
   bash scripts/cai-ban-dich.sh tai   # (tuy chon) tai .po goc ve may
   python scripts/kiem-tra-tieng-viet.py
================================================================================
"""
import os
import re
import struct
import subprocess

import sys

GOC = os.path.dirname(os.path.abspath(__file__))
THU_MUC = os.path.join(GOC, '..', '.tmp-locale')
PO_VI = os.path.join(THU_MUC, 'vi_VN.po')
PO_FR = os.path.join(THU_MUC, 'fr_FR.po')

GLPI_CONTAINER = os.environ.get('GLPI_CONTAINER', 'pinedesk-glpi')
MO_THUC_TE = '/var/glpi/files/_locales/core/vi_VN.mo'


def dam_bao_po_nguon(ten_po):
    """
    Bao dam co file .po nguon trong .tmp-locale/, tai tu container neu thieu.

    .po khong duoc version hoa (xem .gitignore) nhung LUON tai lai duoc tu
    image GLPI (byte-identical). Dung 'docker exec ... cat' thay vi 'docker cp'
    de tranh loi dich duong dan kieu /g/... cua Git Bash.
    """
    dich = os.path.join(THU_MUC, ten_po)
    if os.path.exists(dich) and os.path.getsize(dich) > 0:
        return True
    os.makedirs(THU_MUC, exist_ok=True)
    nguon = '/var/www/glpi/locales/' + ten_po
    r = subprocess.run(['docker', 'exec', GLPI_CONTAINER, 'cat', nguon],
                       capture_output=True)
    if not r.stdout:
        return False
    with open(dich, 'wb') as f:
        f.write(r.stdout)
    print(f'  [INFO] Da tai {ten_po} tu container ({len(r.stdout):,} byte)')
    return True


def doc_po_day_du(path):
    """
    Doc tap msgid (chuoi goc can dich) tu file .po cua GLPI.
    Tra ve set cac chuoi can dich, hoac None neu khong doc duoc file.
    """
    if not os.path.exists(path):
        return None
    with open(path, encoding='utf-8') as f:
        txt = f.read()

    msgids = set()
    for entry in re.split(r'\n\s*\n', txt):
        if 'msgid' not in entry:
            continue
        # Bo qua khoi msgid_plural / msgctxt (cung cong thuc voi
        # scripts/do-do-phu-tieng-viet.py de hai script cho cung ket qua).
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
            txt_mid = ''.join(x.strip().strip('"') for x in buf)
            if txt_mid:
                msgids.add(txt_mid)
    return msgids


def doc_mo(du_lieu: bytes) -> dict:
    """Doc file .mo gettext -> dict {msgid: msgstr}."""
    magic = struct.unpack('<I', du_lieu[:4])[0]
    if magic != 0x950412de:
        raise ValueError('Khong phai file .mo hop le (sai magic)')
    n, off_orig = struct.unpack('<2I', du_lieu[8:16])
    off_trans = off_orig + n * 8
    ket_qua = {}
    for i in range(n):
        ln, lo = struct.unpack('<2I', du_lieu[off_orig + i * 8: off_orig + i * 8 + 8])
        mid = du_lieu[lo:lo + ln].decode('utf-8', 'replace')
        lt, lod = struct.unpack('<2I', du_lieu[off_trans + i * 8: off_trans + i * 8 + 8])
        mstr = du_lieu[lod:lod + lt].decode('utf-8', 'replace')
        ket_qua[mid] = mstr
    return ket_qua


def doc_mo_trong_container() -> dict:
    """Doc file .mo DANG cai trong GLPI (nguon du lieu that)."""
    r = subprocess.run(['docker', 'exec', GLPI_CONTAINER, 'cat', MO_THUC_TE],
                       capture_output=True)
    if not r.stdout:
        return {}
    return doc_mo(r.stdout)


def main():
    print('=' * 78)
    print('  DO DO PHU BAN DICH TIENG VIET - GLPI 11')
    print('=' * 78)

    # --- 1. Tap chuoi goc can dich (tu .po cua GLPI) --------------------
    dam_bao_po_nguon('vi_VN.po')
    msgids = doc_po_day_du(PO_VI)
    if not msgids:
        print(f'\n[LOI] Khong doc duoc file .po nguon: {PO_VI}')
        print('      Chay truoc:  bash scripts/cai-ban-dich.sh tai')
        sys.exit(1)
    total = len(msgids)

    # --- 2. Ban dich DANG dung trong GLPI (doc .mo that) ----------------
    ban_dich = doc_mo_trong_container()
    if not ban_dich:
        print(f'\n[LOI] Khong doc duoc {MO_THUC_TE} trong container {GLPI_CONTAINER}.')
        print('      He thong da chay chua? Da cai ban dich chua?')
        print('      Chay:  bash scripts/cai-dat-tat-ca.sh')
        sys.exit(1)

    # --- 3. Tinh do phu -------------------------------------------------
    # Mot chuoi la DA DICH khi co msgid trong .po VA ban dich khac rong,
    # khac chinh chuoi goc.
    da_dich, chua = 0, []
    for mid in msgids:
        dich = ban_dich.get(mid, '')
        if dich and dich != mid:
            da_dich += 1
        else:
            chua.append(mid)
    ti_le = da_dich * 100.0 / total if total else 0

    print('\n[1] DO PHU THUC TE TREN GIAO DIEN (doc .mo trong GLPI)')
    print(f'    Tong chuoi can dich : {total:>6}')
    print(f'    Da dich             : {da_dich:>6}')
    print(f'    Chua dich           : {len(chua):>6}')
    print(f'    => Ti le            : {ti_le:>5.1f}%')
    thanh = int(ti_le / 2.5)
    print(f'    [{("#" * thanh).ljust(40)}] ')

    # --- 4. So sanh voi cac ngon ngu khac -------------------------------
    print('\n[2] SO SANH VOI CAC NGON NGU KHAC')
    for ten, path in [
        ('Tieng Viet (vi_VN)', PO_VI),
        ('Tieng Phap (fr_FR)', PO_FR),
    ]:
        kq = doc_po_day_du(path)
        if kq:
            # .po cua ngon ngu khac chua chac da cai vao GLPI, nen day chi
            # dem so chuoi CO msgstr trong .po (khong doi chieu .mo).
            print(f'    %-22s {len(kq):>5} chuoi can dich' % (ten + ':'))

    # --- 5. Phan nhom chuoi con thieu -----------------------------------
    print('\n[3] CAC NHOM CHUOI CON THIEU (uu tien bo sung tiep)')
    dem = {}
    for s in chua:
        key = 'Khac'
        low = s.lower()
        for k, tu in [
            ('Thiet bi / Tai san', ('computer', 'monitor', 'printer', 'peripheral', 'asset', 'device', 'hardware', 'rack', 'enclosure')),
            ('Su co / Phieu', ('ticket', 'incident', 'problem', 'request', 'followup', 'solution', 'satisfaction')),
            ('Bao tri / Hop dong', ('maintenance', 'preventive', 'recurring', 'contract', 'warranty', 'repair')),
            ('Phan mem / Ban quyen', ('software', 'license', 'version')),
            ('Mang / Ket noi', ('network', 'port', 'vlan', 'switch', 'router', 'ip ', 'mac ')),
            ('Nguoi dung / Phan quyen', ('user', 'group', 'profile', 'entity', 'rule', 'right')),
            ('Cau hinh / He thong', ('setting', 'config', 'setup', 'install', 'plugin', 'field', 'dropdown', 'notification')),
            ('Thong ke / Dashboard', ('dashboard', 'report', 'stat', 'chart', 'count', 'graph')),
            ('Giao dien / Khac', ('display', 'show', 'hide', 'column', 'page', 'button', 'label')),
        ]:
            if any(t in low for t in tu):
                key = k
                break
        dem[key] = dem.get(key, 0) + 1
    for k, v in sorted(dem.items(), key=lambda x: -x[1]):
        pct = v * 100.0 / len(chua) if chua else 0
        print(f'    %-26s %5d chuoi  (%.0f%%)' % (k, v, pct))


    # --- 6. Ket luan ----------------------------------------------------
    print('\n[4] KET LUAN')
    if not chua:
        print('    => Da dich 100%.')
    else:
        print(f'    => CHUA dat 100% (con {len(chua)} chuoi).')
        print('    => Nguyen nhan: ban dich chinh thuc cua GLPI chua hoan thien.')
        print('    => Da xu ly:')
        print('       - Bo sung tu dien nghiep vu quan trong (thiet bi, su co, bao tri...)')
        print('       - Cai qua co che local i18n: files/_locales/core/vi_VN.mo')
        print('       - File goc duoc giu nguyen => nang cap GLPI khong mat ban dich')
        print('    => De dat 100%: bo sung them vao BAN_DICH_BO_SUNG trong')
        print('       scripts/bo-sung-tieng-viet.py roi chay lai.')
    print('=' * 78)


if __name__ == '__main__':
    main()
