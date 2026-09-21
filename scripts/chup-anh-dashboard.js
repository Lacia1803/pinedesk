const puppeteer = require('puppeteer-core');
const CHROME = 'C:/Program Files/Google/Chrome/Application/chrome.exe';
const BASE = 'https://localhost:8443';

// Tai khoan dang nhap: lay tu bien moi truong, KHONG hardcode mat khau.
//   GLPI_USER=glpi GLPI_PASS=... node scripts/chup-anh-dashboard.js
const USER = process.env.GLPI_USER || 'glpi';
const PASS = process.env.GLPI_PASS;
if (!PASS) {
  console.error('Thieu bien moi truong GLPI_PASS. Vi du:');
  console.error('  GLPI_USER=glpi GLPI_PASS=<mat-khau> node scripts/chup-anh-dashboard.js');
  process.exit(1);
}

(async () => {
  const b = await puppeteer.launch({
    executablePath: CHROME,
    headless: 'new',
    args: ['--ignore-certificate-errors', '--no-sandbox'],
    defaultViewport: { width: 1600, height: 1100, deviceScaleFactor: 1 },
  });
  const p = await b.newPage();

  // Dang nhap
  await p.goto(`${BASE}/`, { waitUntil: 'networkidle2', timeout: 60000 });
  await new Promise(r => setTimeout(r, 1200));
  await p.type('input[name="login_name"]', USER, { delay: 20 });
  await p.type('input[name="login_password"]', PASS, { delay: 20 });
  await Promise.all([
    p.waitForNavigation({ waitUntil: 'networkidle2', timeout: 60000 }).catch(() => {}),
    p.click('button[type="submit"], input[type="submit"]'),
  ]);
  await new Promise(r => setTimeout(r, 4000));

  console.log('URL sau dang nhap:', p.url());

  // Vao bang dieu khien
  await p.goto(`${BASE}/front/central.php`, { waitUntil: 'networkidle2', timeout: 60000 });
  await new Promise(r => setTimeout(r, 6000));

  // Kiem tra con banner "demonstration data" khong
  const txt = await p.evaluate(() => document.body.innerText || '');
  const hasDemo = /demonstration data|dữ liệu minh họa|Disable demonstration/i.test(txt);
  console.log('Con banner du lieu demo?', hasDemo ? 'CO (xau)' : 'KHONG (tot)');

  // An bang canh bao ky thuat truoc khi chup anh xem truoc.
  // GLPI hien .message-area > .alert-warning voi 2 noi dung:
  //   1. Nhac doi mat khau tai khoan mac dinh (root-only, tech, normal)
  //   2. Goi y chay migration unsigned_keys
  // Day KHONG phai loi cua do an va se tu het sau khi doi mat khau -> khong
  // nen de trong anh gioi thieu san pham.
  // Dung selector theo CLASS (on dinh) thay vi khop chuoi tieng Viet.
  const daAn = await p.evaluate(() => {
    let n = 0;
    document.querySelectorAll('.message-area, .alert-warning, .alert-important').forEach(a => {
      a.style.display = 'none';
      n++;
    });
    return n;
  });
  console.log('Da an', daAn, 'bang canh bao');
  await new Promise(r => setTimeout(r, 800));

  // Lay vai con so that
  const nums = await p.evaluate(() => {
    const out = [];
    document.querySelectorAll('.card, .card-body, [class*="card"]').forEach(c => {
      const t = (c.innerText || '').replace(/\s+/g, ' ').trim();
      if (t && t.length < 120) out.push(t);
    });
    return out.slice(0, 14);
  });
  console.log('=== THE SO LIEU ===');
  nums.forEach(n => console.log('  -', n));

  await p.screenshot({ path: 'landing/dashboard-preview.png' });
  console.log('-> da ghi landing/dashboard-preview.png');
  await b.close();
})().catch(e => { console.error('LOI:', e.message); process.exit(1); });
