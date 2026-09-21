/**
 * ============================================================================
 *  CHUP ANH GIAO DIEN GLPI  (bang chung truc quan cho bao cao do an)
 * ============================================================================
 *  Do an thuc tap: Xay dung he thong ho tro ky thuat (PineDesk) - DH Da Lat
 *
 *  Script nay:
 *    1. Mo trang dang nhap  -> chup anh (kiem tra tieng Viet + giao dien DLU)
 *    2. Dang nhap bang tai khoan quan tri
 *    3. Mo bang dieu khien   -> chup anh (giao dien da dang nhap)
 *    4. Mo danh sach tai san -> chup anh
 *
 *  CHAY:
 *    NODE_PATH=<duong-dan-toi>/node_modules node scripts/chup-anh-giao-dien.js
 *  (dat GLPI_PASS trong bien moi truong; CHROME_PATH neu Chrome khong o mac dinh)
 * ============================================================================
 */
const puppeteer = require('puppeteer-core');
const path = require('path');
const fs = require('fs');

// Duong dan Chrome + tai khoan dang nhap: lay tu scripts/lib/browser.js
const { CHROME, credentials } = require('./lib/browser');
const BASE = 'https://localhost:8443';
const OUT = path.join(__dirname, '..', 'tai-lieu', 'anh-giao-dien');
const { user: USER, pass: PASS } = credentials();

(async () => {
  fs.mkdirSync(OUT, { recursive: true });

  const browser = await puppeteer.launch({
    executablePath: CHROME,
    headless: 'new',
    args: [
      '--ignore-certificate-errors',
      '--no-sandbox',
      '--disable-dev-shm-usage',
      '--window-size=1600,1000',
      '--lang=vi-VN',
    ],
    defaultViewport: { width: 1600, height: 1000, deviceScaleFactor: 1 },
  });

  const page = await browser.newPage();
  const errors = [];
  page.on('console', (m) => { if (m.type() === 'error') errors.push(m.text()); });
  page.on('pageerror', (e) => errors.push(String(e)));

  const shot = async (name, opts = {}) => {
    const f = path.join(OUT, name);
    await page.screenshot({ path: f, fullPage: !!opts.full });
    console.log(`  [ANH] ${name}  (${(fs.statSync(f).size / 1024).toFixed(0)} KB)`);
  };

  // ---------------------------------------------------------------------
  // 1. TRANG DANG NHAP
  // ---------------------------------------------------------------------
  console.log('\n[1] Trang dang nhap (chua dang nhap)...');
  await page.goto(`${BASE}/`, { waitUntil: 'networkidle2', timeout: 60000 });
  await new Promise((r) => setTimeout(r, 1200));

  const loginInfo = await page.evaluate(() => ({
    lang: document.documentElement.lang,
    theme: document.documentElement.getAttribute('data-glpi-theme'),
    title: document.title,
    h2: (document.querySelector('h2') || {}).innerText || '',
    labels: [...document.querySelectorAll('label')].map((l) => l.innerText.trim()).filter(Boolean),
    buttons: [...document.querySelectorAll('button[type=submit], .btn-primary')]
      .map((b) => b.innerText.trim()).filter(Boolean),
    cssLoaded: [...document.styleSheets].some((s) => (s.href || '').includes('dlubrand')),
  }));
  console.log('    html lang  :', loginInfo.lang);
  console.log('    theme      :', loginInfo.theme);
  console.log('    title      :', loginInfo.title);
  console.log('    heading    :', loginInfo.h2);
  console.log('    nhan       :', JSON.stringify(loginInfo.labels));
  console.log('    nut        :', JSON.stringify(loginInfo.buttons));
  console.log('    CSS DLU    :', loginInfo.cssLoaded ? 'da nap' : 'KHONG NAP');

  await shot('01-trang-dang-nhap.png');
  await shot('01b-trang-dang-nhap-toan-trang.png', { full: true });

  // ---------------------------------------------------------------------
  // 2. DANG NHAP
  // ---------------------------------------------------------------------
  console.log('\n[2] Dang nhap bang tai khoan quan tri...');
  await page.type('input[name="login_name"]', USER, { delay: 30 });
  await page.type('input[name="login_password"]', PASS, { delay: 30 });
  await Promise.all([
    page.waitForNavigation({ waitUntil: 'networkidle2', timeout: 60000 }).catch(() => {}),
    page.click('button[type="submit"], input[type="submit"]'),
  ]);
  await new Promise((r) => setTimeout(r, 2500));
  console.log('    URL hien tai:', page.url());

  // ---------------------------------------------------------------------
  // 3. BANG DIEU KHIEN
  // ---------------------------------------------------------------------
  console.log('\n[3] Bang dieu khien...');
  await page.goto(`${BASE}/front/central.php`, { waitUntil: 'networkidle2', timeout: 60000 });
  await new Promise((r) => setTimeout(r, 2500));

  const dashInfo = await page.evaluate(() => {
    const nav = [...document.querySelectorAll('.navbar-nav .nav-link, #menu-content a, .mainmenu a')]
      .map((a) => a.innerText.trim()).filter(Boolean);
    const titles = [...document.querySelectorAll('[title]')]
      .map((e) => e.getAttribute('title'))
      .filter((t) => t && t.length > 2 && t.length < 45);
    return {
      lang: document.documentElement.lang,
      theme: document.documentElement.getAttribute('data-glpi-theme'),
      title: document.title,
      menu: [...new Set(nav)].slice(0, 25),
      uniqTitles: [...new Set(titles)].length,
    };
  });
  console.log('    html lang  :', dashInfo.lang);
  console.log('    theme      :', dashInfo.theme);
  console.log('    title      :', dashInfo.title);
  console.log('    menu       :', JSON.stringify(dashInfo.menu));

  await shot('02-bang-dieu-khien.png');
  await shot('02b-bang-dieu-khien-toan-trang.png', { full: true });

  // ---------------------------------------------------------------------
  // 4. DANH SACH TAI SAN (may tinh)
  // ---------------------------------------------------------------------
  console.log('\n[4] Danh sach may tinh (tai san)...');
  await page.goto(`${BASE}/front/computer.php`, { waitUntil: 'networkidle2', timeout: 60000 });
  await new Promise((r) => setTimeout(r, 1800));
  await shot('03-danh-sach-may-tinh.png');

  // ---------------------------------------------------------------------
  // 5. DANH SACH PHIEU YEU CAU (ticket)
  // ---------------------------------------------------------------------
  console.log('\n[5] Danh sach phieu yeu cau (ticket)...');
  await page.goto(`${BASE}/front/ticket.php`, { waitUntil: 'networkidle2', timeout: 60000 });
  await new Promise((r) => setTimeout(r, 1800));
  const ticketInfo = await page.evaluate(() => ({
    title: document.title,
    h1: (document.querySelector('h1, .card-title, .page-title') || {}).innerText || '',
    headers: [...document.querySelectorAll('table thead th')]
      .map((t) => t.innerText.trim()).filter(Boolean).slice(0, 12),
  }));
  console.log('    title      :', ticketInfo.title);
  console.log('    tieu de    :', ticketInfo.h1.trim().replace(/\s+/g, ' '));
  console.log('    cot bang   :', JSON.stringify(ticketInfo.headers));
  await shot('04-danh-sach-phieu-yeu-cau.png');

  // ---------------------------------------------------------------------
  // 6. TAO PHIEU MOI
  // ---------------------------------------------------------------------
  console.log('\n[6] Form tao phieu yeu cau moi...');
  await page.goto(`${BASE}/front/ticket.form.php`, { waitUntil: 'networkidle2', timeout: 60000 });
  await new Promise((r) => setTimeout(r, 1800));
  await shot('05-tao-phieu-moi.png');

  if (errors.length) {
    console.log('\n[CANH BAO] Loi console (' + errors.length + '):');
    errors.slice(0, 5).forEach((e) => console.log('   -', e.slice(0, 160)));
  }

  await browser.close();
  console.log('\n' + '='.repeat(70));
  console.log('  XONG. Anh luu tai: ' + OUT);
  console.log('='.repeat(70) + '\n');
})().catch((e) => {
  console.error('LOI:', e.message);
  process.exit(1);
});
