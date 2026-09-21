/**
 * Kiem tra plugin Barcode/QR + chup anh minh chung
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
  const browser = await puppeteer.launch({
    executablePath: CHROME,
    headless: 'new',
    args: ['--ignore-certificate-errors', '--no-sandbox', '--window-size=1600,1000'],
    defaultViewport: { width: 1600, height: 1000 },
  });
  const page = await browser.newPage();

  // Dang nhap
  await page.goto(`${BASE}/`, { waitUntil: 'networkidle2' });
  await page.type('input[name="login_name"]', USER, { delay: 25 });
  await page.type('input[name="login_password"]', PASS, { delay: 25 });
  await Promise.all([
    page.waitForNavigation({ waitUntil: 'networkidle2' }).catch(() => {}),
    page.click('button[type="submit"], input[type="submit"]'),
  ]);
  await new Promise((r) => setTimeout(r, 2000));

  // --- 1. Tao 1 may tinh mau de thu sinh QR -------------------------------
  console.log('[1] Tao may tinh mau de thu sinh ma QR...');
  await page.goto(`${BASE}/front/computer.form.php`, { waitUntil: 'networkidle2' });
  await new Promise((r) => setTimeout(r, 1500));
  const nameField = await page.$('input[name="name"]');
  if (nameField) {
    await page.type('input[name="name"]', 'PC-TEST-QR-DLU-001', { delay: 20 });
    console.log('    da dien ten thiet bi');
  }
  await shot(page, '06-tao-thiet-bi.png');

  // Luu
  const saveBtn = await page.$('button[name="add"], input[name="add"]');
  if (saveBtn) {
    await Promise.all([
      page.waitForNavigation({ waitUntil: 'networkidle2', timeout: 30000 }).catch(() => {}),
      saveBtn.click(),
    ]);
    await new Promise((r) => setTimeout(r, 2000));
    console.log('    URL sau khi luu:', page.url());
  }

  // --- 2. Mo tab Barcode/QR ---------------------------------------------
  console.log('\n[2] Tim tab Barcode/QR tren trang thiet bi...');
  const tabs = await page.evaluate(() =>
    [...document.querySelectorAll('a.nav-link, .nav-item a, li.nav-item')]
      .map((a) => (a.innerText || '').trim())
      .filter((t) => t && t.length < 40)
  );
  console.log('    cac tab:', JSON.stringify([...new Set(tabs)].slice(0, 20)));

  const hasBarcode = tabs.some((t) => /barcode|qr|mã vạch/i.test(t));
  console.log('    co tab Barcode/QR:', hasBarcode ? 'CO' : 'KHONG');

  await shot(page, '07-chi-tiet-thiet-bi.png');

  // --- 3. Thu mo truc tiep trang barcode cua plugin ----------------------
  console.log('\n[3] Thu mo trang sinh ma QR cua plugin...');
  const url = page.url();
  const idMatch = url.match(/id=(\d+)/);
  if (idMatch) {
    const id = idMatch[1];
    for (const p of [
      `${BASE}/plugins/barcode/front/barcode.php?id=${id}&itemtype=Computer`,
      `${BASE}/plugins/barcode/front/barcode.form.php?itemtype=Computer&id=${id}`,
      `${BASE}/front/computer.form.php?id=${id}&forcetab=Barcode%241`,
    ]) {
      const resp = await page.goto(p, { waitUntil: 'networkidle2' }).catch(() => null);
      const code = resp ? resp.status() : 0;
      const info = await page.evaluate(() => ({
        title: document.title,
        imgs: [...document.querySelectorAll('img')]
          .map((i) => i.src).filter((s) => /barcode|qr|png/i.test(s)).slice(0, 3),
      }));
      console.log(`    ${p.replace(BASE, '')} -> HTTP ${code}`);
      if (info.imgs.length) console.log('       anh QR:', JSON.stringify(info.imgs));
      if (code === 200 && (info.imgs.length || /barcode/i.test(p))) {
        await shot(page, '08-ma-qr-thiet-bi.png');
        console.log('       => DA CHUP ANH MA QR');
      }
    }
  }

  await browser.close();
  console.log('\nXONG.');
})().catch((e) => { console.error('LOI:', e.message); process.exit(1); });

async function shot(page, name) {
  const f = path.join(OUT, name);
  await page.screenshot({ path: f });
  console.log(`    [ANH] ${name} (${(fs.statSync(f).size / 1024).toFixed(0)} KB)`);
}
