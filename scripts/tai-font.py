#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Tai font Google ve may de landing page chay duoc khi KHONG co mang.
Chi lay 2 subset: vietnamese (bat buoc, co dau) + latin.
Chay: python scripts/tai-font.py
"""
import os
import re
import urllib.request

UA = ('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')

FAMILIES = [
    ('Playfair Display', 'ital,wght@0,500;0,600;0,700;1,500;1,600'),
    ('Be Vietnam Pro',   'wght@300;400;500;600;700'),
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
    q = '&'.join(f'family={n.replace(" ", "+")}:{s}' for n, s in FAMILIES)
    css = fetch(f'https://fonts.googleapis.com/css2?{q}&display=swap').decode()

    parts = re.split(r'/\*\s*([a-z\-]+)\s*\*/', css)
    blocks = []
    for i in range(1, len(parts) - 1, 2):
        sub = parts[i].strip()
        if sub not in SUBSETS:
            continue
        for m in re.finditer(r'@font-face\s*\{[^}]*\}', parts[i + 1]):
            blocks.append((sub, m.group(0)))

    print(f'[1/3] Tim thay {len(blocks)} khoi @font-face (vietnamese + latin)')

    out_css, n = [], 0
    for sub, blk in blocks:
        fam = re.search(r"font-family:\s*'([^']+)'", blk).group(1)
        wt = re.search(r'font-weight:\s*(\d+)', blk).group(1)
        st = re.search(r'font-style:\s*(\w+)', blk).group(1)
        u = re.search(r'url\((https://[^)]+\.woff2)\)', blk)
        if not u:
            continue
        slug = re.sub(r'[^a-z0-9]+', '-', fam.lower()).strip('-')
        # BAT BUOC ghi ten file theo ca subset: Google tra ve nhieu @font-face
        # cung family/weight nhung KHAC subset (vietnamese, latin, latin-ext...).
        # Neu dat trung ten, file sau ghi de file truoc -> thieu ky tu.
        fname = f'{slug}-{wt}{"-italic" if st == "italic" else ""}-{sub}.woff2'
        data = fetch(u.group(1))
        with open(os.path.join(OUT, fname), 'wb') as f:
            f.write(data)
        n += 1
        print(f'      {fname:44} {len(data):>7,} bytes  [{sub}]')
        out_css.append(blk.replace(u.group(1), f'./{fname}'))

    header = '/* Font noi bo - sinh bang scripts/tai-font.py (khong can Internet) */\n'
    with open(os.path.join(OUT, 'fonts.css'), 'w', encoding='utf-8') as f:
        f.write(header + '\n'.join(out_css) + '\n')

    print(f'[2/3] Da tai {n} file font -> {OUT}')
    print('[3/3] Da ghi fonts.css')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
