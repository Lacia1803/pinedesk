/* ---------------------------------------------------------------------------
   Kiểm tra trang giới thiệu bằng trình duyệt thật (Chrome headless).
   Kiểm: tài nguyên tải được, kiểu chữ nội bộ, anchor, ảnh, lỗi console.
   Dùng:  node scripts/kiem-tra-landing.js
   --------------------------------------------------------------------------- */
const puppeteer = require('puppeteer-core');
const fs = require('fs');
const path = require('path');

// Duong dan Chrome: lay tu scripts/lib/browser.js (dat CHROME_PATH neu can)
const { CHROME } = require('./lib/browser');
const URL = 'https://localhost:8443/landing/';
const OUT = '.tmp-check';

(async () => {
  fs.mkdirSync(OUT, { recursive: true });

  const b = await puppeteer.launch({
    executablePath: CHROME,
    headless: 'new',
    args: ['--ignore-certificate-errors', '--no-sandbox'],
    defaultViewport: { width: 1440, height: 1000 },
  });
  const p = await b.newPage();

  const hong = [];          // request thất bại / trả mã lỗi
  const loiConsole = [];
  p.on('requestfailed', r => hong.push('THAT BAI ' + r.url()));
  p.on('response', r => { if (r.status() >= 400) hong.push(r.status() + ' ' + r.url()); });
  p.on('console', m => { if (m.type() === 'error') loiConsole.push(m.text().slice(0, 220)); });

  const resp = await p.goto(URL, { waitUntil: 'networkidle2', timeout: 60000 });
  await new Promise(r => setTimeout(r, 2500));

  console.log('HTTP:', resp.status());
  console.log('Tieu de:', await p.title());

  /* --- 1. Kiểu chữ nội bộ có nạp không -------------------------------- */
  /* Phép kiểm ở đây chỉ trả lời: "font riêng có được áp dụng không".
     Nó KHÔNG phát hiện được trường hợp tệp font bị thiếu ký tự có dấu —
     khi đó trình duyệt vẫn dùng font riêng cho phần lớn chuỗi nên chiều rộng
     vẫn khác font hệ thống, phép đo báo "đạt" một cách sai lệch.
     Muốn kiểm độ phủ ký tự, dùng: python scripts/kiem-tra-font.py
     (đọc thẳng bảng ký tự trong tệp .woff2 — đã kiểm chứng là bắt được lỗi). */
  const font = await p.evaluate(async () => {
    await document.fonts.ready;

    const rong = (family, text, weight) => {
      const s = document.createElement('span');
      s.style.cssText = 'position:absolute;top:-9999px;left:0;visibility:hidden;'
        + 'white-space:pre;font-size:60px;font-weight:' + weight + ';font-family:' + family;
      s.textContent = text;
      document.body.appendChild(s);
      const w = s.getBoundingClientRect().width;
      s.remove();
      return w;
    };

    /* Ten font chac chan khong ton tai. Khi do ca hai phep do deu roi ve
       CUNG mot font mac dinh cua trinh duyet, nen chenh lech chi co the do
       font rieng tao ra. */
    const KHONG_CO = '"ZZZ-Khong-Co-Font-Nay"';

    const dungFontRieng = (family, text, weight) => {
      const a = rong('"' + family + '", ' + KHONG_CO, text, weight);
      const b = rong(KHONG_CO, text, weight);
      return Math.abs(a - b) > 0.5;
    };

    return {
      soFont: document.fonts.size,
      bodyFont: getComputedStyle(document.body).fontFamily,
      h1Font: (() => { const h = document.querySelector('h1'); return h ? getComputedStyle(h).fontFamily : 'n/a'; })(),
      h1Size: (() => { const h = document.querySelector('h1'); return h ? getComputedStyle(h).fontSize : 'n/a'; })(),
      beVietnamCoDau: dungFontRieng('Be Vietnam Pro', 'Hệ thống Hỗ trợ', 400),
      beVietnamKhongDau: dungFontRieng('Be Vietnam Pro', 'Helpdesk', 400),
      frauncesCoDau: dungFontRieng('Fraunces', 'Hỗ trợ Kỹ thuật', 400),
      frauncesKhongDau: dungFontRieng('Fraunces', 'PineDesk', 400),
    };
  });
  console.log('');
  console.log('=== KIEU CHU ===');
  console.log('  So font da nap :', font.soFont);
  console.log('  Font than trang:', font.bodyFont);
  console.log('  Font tieu de   :', font.h1Font, '/', font.h1Size);
  console.log('  --- Font rieng co duoc ap dung? (do phu ky tu: xem scripts/kiem-tra-font.py) ---');
  const dong = [
    ['Be Vietnam Pro  chu co dau  ', font.beVietnamCoDau],
    ['Be Vietnam Pro  chu khong dau', font.beVietnamKhongDau],
    ['Fraunces        chu co dau  ', font.frauncesCoDau],
    ['Fraunces        chu khong dau', font.frauncesKhongDau],
  ];
  dong.forEach(([nhan, ok]) => console.log('  ', ok ? 'OK   ' : 'THIEU', nhan));

  /* --- 2. Bảng màu có áp không ---------------------------------------- */
  const mau = await p.evaluate(() => {
    const g = (sel, prop) => {
      const el = document.querySelector(sel);
      return el ? getComputedStyle(el)[prop] : 'khong co';
    };
    return {
      navPos: g('.nav', 'position'),
      nenTrang: getComputedStyle(document.body).backgroundColor,
      chuTrang: getComputedStyle(document.body).color,
      nutChinh: g('.nut--day', 'backgroundColor'),
      nenHero: g('.mo-dau', 'backgroundImage').slice(0, 60),
      nenMucToi: g('.muc--toi', 'backgroundColor'),
    };
  });
  console.log('');
  console.log('=== BANG MAU ===');
  console.log('  nav position  :', mau.navPos);
  console.log('  nen than trang:', mau.nenTrang);
  console.log('  chu than trang:', mau.chuTrang);
  console.log('  nut chinh     :', mau.nutChinh);
  console.log('  nen mo dau    :', mau.nenHero + '...');
  console.log('  nen muc toi   :', mau.nenMucToi);

  /* --- 3. Anchor có trỏ tới id tồn tại không -------------------------- */
  const anchor = await p.evaluate(() => {
    const ra = [];
    document.querySelectorAll('a[href^="#"]').forEach(a => {
      const id = a.getAttribute('href').slice(1);
      if (!id) return;
      if (!document.getElementById(id)) ra.push(id);
    });
    return { hong: [...new Set(ra)], tong: document.querySelectorAll('a[href^="#"]').length };
  });
  console.log('');
  console.log('=== ANCHOR ===');
  console.log('  Tong so link neo:', anchor.tong);
  console.log('  Neo hong        :', anchor.hong.length ? anchor.hong.join(', ') : '(khong co)');

  /* --- 4. Liên kết ngoài có hardcode localhost không ------------------ */
  const cung = await p.evaluate(() =>
    Array.from(document.querySelectorAll('a[href]'))
      .map(a => a.getAttribute('href'))
      .filter(h => /^https?:\/\//i.test(h))
  );
  console.log('');
  console.log('=== LIEN KET TUYET DOI (nen rong) ===');
  console.log(' ', cung.length ? cung.join(', ') : '(khong co)');

  /* --- 4b. Liên kết tài liệu (../tai-lieu/*.md) phải tải được --------- */
  /* nginx chi mount ./landing vao /usr/share/nginx/html/landing nen neu
     khong mount them tai-lieu/ va README.md thi cac the nay se 404. */
  const taiLieu = await p.evaluate(() =>
    Array.from(document.querySelectorAll('a[href$=".md"]'))
      .map(a => a.getAttribute('href'))
  );
  console.log('');
  console.log('=== LIEN KET TAI LIEU ===');
  if (!taiLieu.length) {
    console.log('  (khong co lien ket .md)');
  } else {
    for (const href of taiLieu) {
      const url = new URL(href, URL).href;
      const r = await p.evaluate(async (u) => {
        try { const x = await fetch(u); return x.status; }
        catch (e) { return 'LOI ' + e.message; }
      }, url);
      console.log(' ', r === 200 ? 'OK ' : 'HONG', String(r).padStart(4), href);
    }
  }

  /* --- 5. Cuộn hết trang để kích hoạt ảnh lười + hiệu ứng ------------- */
  await p.evaluate(async () => {
    const buoc = Math.round(window.innerHeight * 0.7);
    for (let y = 0; y < document.body.scrollHeight; y += buoc) {
      window.scrollTo(0, y);
      await new Promise(r => setTimeout(r, 130));
    }
    window.scrollTo(0, document.body.scrollHeight);
  });
  await new Promise(r => setTimeout(r, 1400));
  await p.evaluate(() => window.scrollTo(0, 0));
  await new Promise(r => setTimeout(r, 900));

  /* --- 6. Ảnh (đo sau khi đã cuộn qua toàn bộ trang) ------------------ */
  const anh = await p.evaluate(() =>
    Array.from(document.images).map(i => ({
      src: i.getAttribute('src'),
      ok: i.complete && i.naturalWidth > 0,
      w: i.naturalWidth,
    }))
  );
  console.log('');
  console.log('=== ANH (sau khi cuon het trang) ===');
  anh.forEach(i => console.log(' ', i.ok ? 'OK ' : 'LOI', String(i.w).padStart(5), i.src));

  /* --- 7. Nội dung dài bao nhiêu -------------------------------------- */
  const noiDung = await p.evaluate(() => ({
    cao: document.body.scrollHeight,
    soMuc: document.querySelectorAll('section').length,
    soThe: document.querySelectorAll('.the, .tl, .vai, .dv').length,
    soTaiKhoan: document.querySelectorAll('.tk').length,
    soLat: document.querySelectorAll('.lat').length,
    taiKhoan: Array.from(document.querySelectorAll('.tk__ma')).map(e => e.textContent.trim()),
  }));
  console.log('');
  console.log('=== NOI DUNG ===');
  console.log('  Chieu cao trang:', noiDung.cao, 'px');
  console.log('  So muc         :', noiDung.soMuc);
  console.log('  So the         :', noiDung.soThe);
  console.log('  So tai khoan   :', noiDung.soTaiKhoan, '->', noiDung.taiKhoan.join(', '));
  console.log('  So lat mat cat :', noiDung.soLat);

  /* --- 7b. Không được lẫn tài khoản bịa (không có trong seed) -------- */
  /* Du lieu mau that chi co: ktv.an, ktv.binh, gv.cuong, gv.dung,
     sv.hoa, sv.khanh (xem scripts/seed-du-lieu-mau.sql). */
  const THAT = ['ktv.an', 'ktv.binh', 'gv.cuong', 'gv.dung', 'sv.hoa', 'sv.khanh'];
  const la = noiDung.taiKhoan.filter(t => !THAT.includes(t));
  const thieu = THAT.filter(t => !noiDung.taiKhoan.includes(t));
  console.log('');
  console.log('=== TAI KHOAN DOI CHIEU SEED ===');
  console.log('  Tai khoan la (khong co trong seed):', la.length ? la.join(', ') : '(khong co)');
  console.log('  Tai khoan thieu                   :', thieu.length ? thieu.join(', ') : '(khong co)');

  console.log('');
  console.log('=== TAI NGUYEN LOI (4xx/5xx hoac that bai) ===');
  hong.length ? hong.forEach(f => console.log('  -', f)) : console.log('  (khong co)');
  console.log('=== LOI CONSOLE ===');
  loiConsole.length ? loiConsole.forEach(e => console.log('  -', e)) : console.log('  (khong co)');

  /* --- 8. Ảnh chụp ------------------------------------------------------ */
  await p.screenshot({ path: path.join(OUT, 'landing-dau-trang.png') });
  await p.screenshot({ path: path.join(OUT, 'landing-toan-trang.png'), fullPage: true });
  console.log('');
  console.log('-> da luu', path.join(OUT, 'landing-dau-trang.png'), 'va landing-toan-trang.png');

  await b.close();
})().catch(e => { console.error('LOI:', e.message); process.exit(1); });
