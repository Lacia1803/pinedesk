#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Kiểm tra font nội bộ có phủ đủ mọi ký tự dùng trên trang giới thiệu hay không.

VÌ SAO CẦN SCRIPT NÀY
---------------------
Google Fonts trả về NHIỀU @font-face cùng family/weight nhưng khác tập ký tự
(vietnamese, latin, latin-ext...). Mỗi tệp chỉ chứa một phần ký tự:
  - tệp *-latin.woff2       : đủ chữ Latin, THIẾU chữ có dấu tiếng Việt
  - tệp *-vietnamese.woff2  : đủ chữ có dấu, THIẾU phần lớn chữ Latin

Nếu tải về mà đặt trùng tên tệp (hoặc gán nhầm tệp cho một unicode-range),
chữ có dấu sẽ âm thầm rơi về font hệ thống trong khi chữ không dấu vẫn đúng —
chữ vẫn hiện ra nhưng khoảng cách sai lệch, rất khó phát hiện bằng mắt.

Không dùng được document.fonts.check() của trình duyệt: hàm đó chỉ đọc
unicode-range KHAI BÁO, không đọc bảng ký tự thật trong tệp.

Chạy: python scripts/kiem-tra-font.py
Thoát mã 1 nếu có ký tự nào bị thiếu.
"""
import os
import re
import sys
import html

from fontTools.ttLib import TTFont

ROOT = os.path.dirname(os.path.abspath(__file__))
LANDING = os.path.normpath(os.path.join(ROOT, '..', 'landing'))
FONTS_DIR = os.path.join(LANDING, 'fonts')
CSS = os.path.join(FONTS_DIR, 'fonts.css')
TRANG = os.path.join(LANDING, 'index.html')

GREEN, RED, YELLOW, NC = '\033[0;32m', '\033[0;31m', '\033[1;33m', '\033[0m'


def doc_unicode_range(s):
    """'U+0102-0103, U+1EA0-1EF9' -> set cac ma diem."""
    ra = set()
    for phan in s.split(','):
        phan = phan.strip()
        if not phan:
            continue
        m = re.match(r'U\+([0-9A-Fa-f]+)(?:-([0-9A-Fa-f]+))?$', phan)
        if not m:
            continue
        dau = int(m.group(1), 16)
        cuoi = int(m.group(2), 16) if m.group(2) else dau
        ra.update(range(dau, cuoi + 1))
    return ra


def doc_css():
    """Tra ve danh sach cac mat chu: family, dai weight, style, tep, unicode-range.

    LUU Y ve font bien thien: fonts.css khai bao `font-weight: 300 700` (mot tep
    dung cho ca dai) chu khong phai mot con so. Neu chi bat mot con so thi mat chu
    do se khong bao gio khop voi do dam nao dang dung -> am tham bo qua phep kiem.
    """
    src = open(CSS, encoding='utf-8').read()
    ra = []
    for blk in re.findall(r'@font-face\s*\{[^}]*\}', src):
        def lay(mau, mac_dinh=None):
            m = re.search(mau, blk)
            return m.group(1) if m else mac_dinh
        tep = lay(r"url\(\./([^)]+)\)")
        if not tep:
            continue
        mw = re.search(r'font-weight:\s*(\d+)(?:\s+(\d+))?', blk)
        w_min = int(mw.group(1)) if mw else 400
        w_max = int(mw.group(2)) if (mw and mw.group(2)) else w_min
        ra.append({
            'family': lay(r"font-family:\s*'([^']+)'"),
            'w_min': w_min,
            'w_max': w_max,
            'style': lay(r'font-style:\s*(\w+)', 'normal'),
            'tep': tep,
            'range': doc_unicode_range(lay(r'unicode-range:\s*([^;]+)', '')),
        })
    return ra


def doc_chu_trang():
    """Lay tap ky tu thuc su hien tren trang (bo qua ma nguon, SVG, the)."""
    s = open(TRANG, encoding='utf-8').read()
    s = re.sub(r'<script\b.*?</script>', ' ', s, flags=re.S | re.I)
    s = re.sub(r'<style\b.*?</style>', ' ', s, flags=re.S | re.I)
    s = re.sub(r'<svg\b.*?</svg>', ' ', s, flags=re.S | re.I)
    s = re.sub(r'<!--.*?-->', ' ', s, flags=re.S)
    s = re.sub(r'<[^>]+>', ' ', s)
    s = html.unescape(s)
    # Chi giu ky tu nhin thay duoc
    return {c for c in s if not c.isspace() and c.isprintable()}


def trong_so_dung():
    """Cac do dam font ma style.css thuc su dung (300 tai ve nhung khong dung)."""
    p = os.path.join(LANDING, 'assets', 'css', 'style.css')
    s = open(p, encoding='utf-8').read()
    ra = {400}  # mac dinh cua trinh duyet
    for m in re.finditer(r'font-weight:\s*(\d+)', s):
        ra.add(int(m.group(1)))
    for m in re.finditer(r'font-weight:\s*(bold|bolder|normal)', s):
        ra.add(700 if m.group(1) in ('bold', 'bolder') else 400)
    # b/strong/h1..h4 mac dinh la dam
    ra.add(700)
    return ra


def main():
    if not os.path.exists(CSS):
        print(f'{RED}Khong thay {CSS}{NC}')
        return 1

    mat = doc_css()
    print(f'[1/3] Doc duoc {len(mat)} mat chu trong fonts.css')

    # cmap cua tung tep (doc mot lan)
    cmap_theo_tep = {}
    for m in mat:
        p = os.path.join(FONTS_DIR, m['tep'])
        if m['tep'] in cmap_theo_tep:
            continue
        if not os.path.exists(p):
            print(f'{RED}  THIEU TEP: {m["tep"]}{NC}')
            cmap_theo_tep[m['tep']] = set()
            continue
        try:
            cmap_theo_tep[m['tep']] = set(TTFont(p).getBestCmap().keys())
        except Exception as e:
            print(f'{RED}  Khong doc duoc {m["tep"]}: {e}{NC}')
            cmap_theo_tep[m['tep']] = set()

    # Bao cao tung mat chu: tep co phu dung vung ky tu ma no khai bao khong.
    # LUU Y: ti le thap o day KHONG phai loi. Google khai bao unicode-range rong
    # hon so ky tu that co trong tep (nhieu ky tu Latin-1 font khong thiet ke).
    # Muc nay chi de tham khao — ket luan dua vao phep kiem o buoc [3/3].
    print('[2/3] Doi chieu tung mat chu voi bang ky tu that trong tep (chi de tham khao)')
    for m in mat:
        cm = cmap_theo_tep.get(m['tep'], set())
        quan_trong = {c for c in m['range'] if 0x20 <= c <= 0x2FFF}
        thieu = sorted(quan_trong - cm)
        w = (f"{m['w_min']}" if m['w_min'] == m['w_max']
             else f"{m['w_min']}-{m['w_max']}")
        nhan = f"{m['family']} {w}{' italic' if m['style'] == 'italic' else ''}"
        ty_le = 0 if not quan_trong else 100 * (1 - len(thieu) / len(quan_trong))
        print(f'       {nhan:38} {m["tep"]:46} phu {ty_le:5.1f}% vung khai bao')

    # PHEP KIEM CO Y NGHIA: moi ky tu dung tren trang phai duoc MOT mat chu phu,
    # xet RIENG theo tung cap (ho font, do dam, kieu).
    # Phai tach theo do dam: neu chi gop ca ho font thi mot khoi bi gan nham tep
    # van "lọt" nho cac khoi khac cung ho phu du ky tu do.
    chu = doc_chu_trang()
    dung = trong_so_dung()
    canh_bao = []
    print(f'[3/3] Kiem {len(chu)} ky tu tren trang, theo tung do dam (dung: {sorted(dung)})')
    for family in sorted({m['family'] for m in mat}):
        for weight in sorted(dung):
            for style in ('normal', 'italic'):
                # Font bien thien dung cho CA DAI weight (w_min..w_max);
                # font tinh chi dung cho dung mot do dam.
                nhom = [m for m in mat
                        if m['family'] == family
                        and m['w_min'] <= weight <= m['w_max']
                        and m['style'] == style]
                if not nhom:
                    continue
                thieu = []
                for c in sorted(chu):
                    cp = ord(c)
                    if not any(cp in m['range'] and cp in cmap_theo_tep.get(m['tep'], set())
                               for m in nhom):
                        thieu.append(c)
                nhan = f'{family} {weight}{" italic" if style == "italic" else ""}'
                if thieu:
                    print(f'  {RED}THIEU{NC} {nhan:34} {len(thieu)} ky tu -> {"".join(thieu[:40])}')
                    canh_bao.append((nhan, nhom[0]['tep'], len(thieu), len(chu)))
                else:
                    print(f'  {GREEN}OK{NC}   {nhan:34} phu du {len(chu)} ky tu')

    print()
    if canh_bao:
        print(f'{RED}KET LUAN: CO VAN DE VE FONT{NC}')
        for nhan, tep, n, tong in canh_bao:
            print(f'  - {nhan} / {tep}: thieu {n}/{tong}')
        return 1
    print(f'{GREEN}KET LUAN: Font noi bo phu du moi ky tu tren trang.{NC}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
