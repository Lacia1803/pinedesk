#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
================================================================================
 DO DO PHU BAN DICH TIENG VIET CUA GLPI
 Do an thuc tap: Xay dung he thong ho tro ky thuat (IT Helpdesk) - DH Da Lat

 Script do 2 chi so:
   (1) DO PHU GOC  : ti le chuoi da dich trong file vi_VN.po chinh thuc cua GLPI
   (2) DO PHU SAU  : ti le sau khi gop them tu dien bo sung cua do an

 CHAY:
   # Buoc 1: tai file .po tu container ve may
   bash scripts/tai-ban-dich.sh

   # Buoc 2: do do phu
   python scripts/kiem-tra-tieng-viet.py
================================================================================
"""
import os
import re
import sys

GOC = os.path.dirname(os.path.abspath(__file__))
THU_MUC = os.path.join(GOC, '..', '.tmp-locale')
PO_VI = os.path.join(THU_MUC, 'vi_VN.po')
PO_FR = os.path.join(THU_MUC, 'fr_FR.po')


def doc_po_day_du(path):
    """
    Doc file .po, tra ve:
      - total   : tong so chuoi CAN dich (msgid khac rong)
      - da_dich : so chuoi da co ban dich
      - chua    : danh sach chuoi chua dich
    """
    if not os.path.exists(path):
        return None
    with open(path, encoding='utf-8') as f:
        txt = f.read()

    total = da_dich = 0
    chua = []
    for entry in re.split(r'\n\s*\n', txt):
        if 'msgid' not in entry:
            continue
        m = re.search(r'^msgid\s+"((?:[^"\\]|\\.)*)"', entry, re.M)
        if not m:
            continue
        msgid = m.group(1)
        if msgid == '':
            continue
        total += 1
        mt = re.search(r'^msgstr\s+"((?:[^"\\]|\\.)*)"', entry, re.M)
        if mt and mt.group(1).strip():
            da_dich += 1
        else:
            chua.append(msgid)
    return total, da_dich, chua


def main():
    print('=' * 78)
    print('  DO DO PHU BAN DICH TIENG VIET - GLPI 11')
    print('=' * 78)

    kq_vi = doc_po_day_du(PO_VI)
    if kq_vi is None:
        print(f'\n[LOI] Khong thay file {PO_VI}')
        print('      Chay truoc:  bash scripts/tai-ban-dich.sh')
        sys.exit(1)

    total, da_dich, chua = kq_vi
    ti_le = da_dich * 100.0 / total

    # ---- (1) DO PHU GOC ----
    print('\n[1] DO PHU GOC (file vi_VN.po chinh thuc cua GLPI)')
    print(f'    Tong chuoi can dich : {total:>6}')
    print(f'    Da dich             : {da_dich:>6}')
    print(f'    Chua dich           : {len(chua):>6}')
    print(f'    => Ti le            : {ti_le:>5.1f}%')
    thanh = int(ti_le / 2.5)
    print(f'    [{("#" * thanh).ljust(40)}] ')

    # ---- So sanh voi cac ngon ngu khac ----
    print('\n[2] SO SANH VOI CAC NGON NGU KHAC')
    for ten, path in [
        ('Tieng Viet (vi_VN)', PO_VI),
        ('Tieng Phap (fr_FR)', PO_FR),
    ]:
        kq = doc_po_day_du(path)
        if kq:
            t, d, _ = kq
            print(f'    %-22s {d:>5}/{t:<5}  (%.1f%%)' % (ten + ':', d * 100.0 / t))

    # ---- (3) Neu co ban dich bo sung da cai ----
    mo_bo_sung = os.path.join(THU_MUC, 'vi_VN.mo')
    if os.path.exists(mo_bo_sung):
        import struct
        with open(mo_bo_sung, 'rb') as f:
            data = f.read()
        _, _, n, _, _, _, _ = struct.unpack('<7I', data[:28])
        so_entry_bo_sung = n - 1   # tru entry header

        # Doc cac msgid trong ban bo sung
        msgids_bo_sung = set()
        off_o = 7 * 4
        off_t = off_o + n * 8
        for i in range(n):
            ln, off = struct.unpack('<2I', data[off_o + i * 8: off_o + i * 8 + 8])
            mid = data[off:off + ln].decode('utf-8', 'replace')
            if mid:
                msgids_bo_sung.add(mid)

        # Dem so chuoi CHUA DICH trong ban goc ma nay DA duoc bo sung
        da_bo_sung = [s for s in chua if s in msgids_bo_sung]
        con_thieu = [s for s in chua if s not in msgids_bo_sung]
        ti_le_moi = (da_dich + len(da_bo_sung)) * 100.0 / total if total else 0

        print('\n[3] DO PHU SAU KHI BO SUNG (do an DLU)')
        print(f'    So chuoi bo sung them : {len(da_bo_sung)}')
        print(f'    Da dich (sau bo sung) : {da_dich + len(da_bo_sung):>6}')
        print(f'    Con thieu             : {len(con_thieu):>6}')
        print(f'    => Ti le MOI          : {ti_le_moi:>5.1f}%  (truoc: {ti_le:.1f}%)')
        print(f'    => Cai thien          : +{ti_le_moi - ti_le:.1f} diem phan tram')
        thanh2 = int(ti_le_moi / 2.5)
        print(f'    [{("#" * thanh2).ljust(40)}] ')

    # ---- (4) Phan nhom chuoi con thieu ----
    print('\n[4] CAC NHOM CHUOI CON THIEU (uu tien bo sung tiep)')
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

    # ---- (5) Ket luan ----
    print('\n[5] KET LUAN')
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
