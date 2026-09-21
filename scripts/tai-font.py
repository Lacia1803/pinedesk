#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Tai font Google ve may de landing page chay duoc khi KHONG co mang.
Chi lay 2 subset: vietnamese (bat buoc, co dau) + latin.
Chay: python scripts/tai-font.py

Chu y ve font bien thien (variable font): Google tra ve CUNG mot tep .woff2
cho moi weight nam trong dai da yeu cau. Neu khai bao tung weight rieng thi
trang se tai trung cung mot tep nhieu lan. Script tu phat hien viec nay va
gop lai thanh mot khai bao voi dai font-weight.
"""
import os
import re
import urllib.request

UA = ('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')

# Chuoi truy van CSS2 cho tung ho font.
# Be Vietnam Pro la font TINH (khong co truc bien thien tren Google Fonts),
# nen phai liet ke tung weight; hai ho con lai la font bien thien.
#
# Vi sao van giu weight 700 cho Be Vietnam Pro du style.css chua dung:
#   the <strong>/<b> mac dinh cua trinh duyet la 700. Hien tai moi <strong>
#   tren trang deu duoc gan font-weight 600, nhung giu san tep 700 de sau nay
#   them <strong> vao bai thi trinh duyet dung bold THAT thay vi tu boi dam
#   gia tu weight gan nhat. Ton them ~34 KB, khong anh huong luc tai trang
#   (trinh duyet chi tai tep khi thuc su co chu o do dam do).
FAMILIES = [
    'Fraunces:opsz,wght@9..144,300..700',
    'Be+Vietnam+Pro:wght@400;500;600;700',
    'IBM+Plex+Mono:wght@400;500;600',
]

SUBSETS = ('vietnamese', 'latin')

ROOT = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.normpath(os.path.join(ROOT, '..', 'landing', 'fonts'))


def fetch(url):
    req = urllib.request.Request(url, headers={'User-Agent': UA})
    with urllib.request.urlopen(req, timeout=30) as r:
        return r.read()


def main():
    os.makedirs(OUT, exist_ok=True)
    q = '&'.join(f'family={f}' for f in FAMILIES)
    css = fetch(f'https://fonts.googleapis.com/css2?{q}&display=swap').decode()

    parts = re.split(r'/\*\s*([a-z0-9\-]+)\s*\*/', css)
    blocks = []
    for i in range(1, len(parts) - 1, 2):
        sub = parts[i].strip()
        if sub not in SUBSETS:
            continue
        for m in re.finditer(r'@font-face\s*\{[^}]*\}', parts[i + 1]):
            blocks.append((sub, m.group(0)))

    print(f'[1/3] Tim thay {len(blocks)} khoi @font-face (vietnamese + latin)')

    # Nhom theo (ho, subset, kieu) de phat hien font bien thien.
    nhom = {}
    for sub, blk in blocks:
        fam = re.search(r"font-family:\s*'([^']+)'", blk).group(1)
        wt = re.search(r'font-weight:\s*(\d+)', blk).group(1)
        st = re.search(r'font-style:\s*(\w+)', blk).group(1)
        u = re.search(r'url\((https://[^)]+\.woff2)\)', blk)
        if not u:
            continue
        nhom.setdefault((fam, sub, st), []).append((int(wt), u.group(1), blk))

    entries = []   # (ten tep, url, khoi @font-face)
    for (fam, sub, st), ds in sorted(nhom.items()):
        slug = re.sub(r'[^a-z0-9]+', '-', fam.lower()).strip('-')
        it = '-italic' if st == 'italic' else ''
        ds.sort(key=lambda x: x[0])
        if len({u for _, u, _ in ds}) == 1:
            # Font bien thien: mot tep dung cho ca dai weight.
            w_min, w_max = ds[0][0], ds[-1][0]
            blk = ds[0][2]
            if w_min != w_max:
                blk = re.sub(r'font-weight:\s*\d+', f'font-weight: {w_min} {w_max}', blk)
            entries.append((f'{slug}{it}-{sub}.woff2', ds[0][1], blk))
        else:
            for w, u, b in ds:
                entries.append((f'{slug}-{w}{it}-{sub}.woff2', u, b))

    out_css, n = [], 0
    for fname, url, blk in entries:
        data = fetch(url)
        with open(os.path.join(OUT, fname), 'wb') as f:
            f.write(data)
        n += 1
        print(f'      {fname:44} {len(data):>7,} bytes')
        out_css.append(blk.replace(url, f'./{fname}'))

    header = '/* Font noi bo - sinh bang scripts/tai-font.py (khong can Internet) */\n'
    with open(os.path.join(OUT, 'fonts.css'), 'w', encoding='utf-8') as f:
        f.write(header + '\n'.join(out_css) + '\n')

    # Don cac tep .woff2 cu khong con duoc dung.
    con_dung = {e[0] for e in entries}
    for ten in sorted(os.listdir(OUT)):
        if ten.endswith('.woff2') and ten not in con_dung:
            os.remove(os.path.join(OUT, ten))
            print(f'      da xoa tep cu: {ten}')

    print(f'[2/3] Da tai {n} file font -> {OUT}')
    print('[3/3] Da ghi fonts.css')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
