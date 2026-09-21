/**
 * ============================================================================
 *  CHUP ANH MINH CHUNG PHAN QR  (CAN TAI KHOAN QUAN TRI)
 * ============================================================================
 *  Do an thuc tap: Xay dung he thong ho tro ky thuat (PineDesk) - DH Da Lat
 *
 *  VI SAO PHAI TACH RIENG
 *    Tuy chon "Barcode - Print QRcodes" chi hien voi ho so co quyen
 *    plugin_barcode_barcode (mac dinh: Super-Admin). Tai khoan ky thuat vien
 *    khong thay tuy chon nay, nen scripts/chup-lai-anh-minh-chung.js bo qua
 *    va khong tao ra anh gia.
 *
 *  CHAY (thay <mat-khau-quan-tri> bang mat khau that):
 *    NODE_PATH="$PWD/node_modules" GLPI_USER=glpi GLPI_PASS='<mat-khau-quan-tri>' \
 *      node scripts/chup-anh-qr-admin.js
 *
 *  TAO RA
 *    - 11-cau-hinh-nhan-qr.png  : trang Cau hinh -> Barcode (form cau hinh nhan)
 *    - 13-phieu-qr-da-sinh.png  : ket qua sinh QR hang loat (file PDF)
 * ============================================================================
 */
const puppeteer = require('puppeteer-core');
const path = require('path');
const fs = require('fs');

const { CHROME, credentials } = require('./lib/browser');
const BASE = 'https://localhost:8443';
const OUT = path.join(__dirname, '..', 'tai-lieu', 'anh-giao-dien');
const { user: USER, pass: PASS } = credentials();

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

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
  const dem = { ok: 0, bo: 0 };

  const luu = async (ten, target = page) => {
    const f = path.join(OUT, ten);
    await target.screenshot({ path: f });
    console.log(`   [ANH] ${ten} (${(fs.statSync(f).size / 1024).toFixed(0)} KB)`);
    dem.ok++;
  };

  // ------------------------------------------------------------------
  console.log('\n[1] Dang nhap (' + USER + ')...');
  await page.goto(`${BASE}/`, { waitUntil: 'networkidle2', timeout: 60000 });
  await sleep(1500);
  await page.type('input[name="login_name"]', USER, { delay: 25 });
  await page.type('input[name="login_password"]', PASS, { delay: 25 });
  await Promise.all([
    page.waitForNavigation({ waitUntil: 'networkidle2', timeout: 60000 }).catch(() => {}),
    page.click('button[type="submit"], input[type="submit"]'),
  ]);
  await sleep(2500);

  const s0 = await page.evaluate(() => ({ title: document.title, path: location.pathname }));
  if (!/central/i.test(s0.path)) {
    console.error(`[LOI] Dang nhap that bai (dung o ${s0.path}). Kiem tra GLPI_USER/GLPI_PASS.`);
    await browser.close();
    process.exit(1);
  }

  // ------------------------------------------------------------------
  console.log('\n[2] Trang Cau hinh -> Barcode...');
  await page.goto(`${BASE}/plugins/barcode/front/config.php`, { waitUntil: 'networkidle2', timeout: 60000 });
  await sleep(2200);
  const cfg = await page.evaluate(() => ({
    path: location.pathname,
    denied: /không có quyền/i.test((document.title || '') + (document.body.innerText || '')),
  }));
  if (cfg.denied || cfg.path !== '/plugins/barcode/front/config.php') {
    console.log(`   [BO QUA] 11-cau-hinh-nhan-qr.png: tai khoan nay khong du quyen (dung -> ${cfg.path})`);
    dem.bo++;
  } else {
    await luu('11-cau-hinh-nhan-qr.png');
  }

  // ------------------------------------------------------------------
  console.log('\n[3] Sinh QR hang loat: tich chon may -> Cac hanh dong...');
  await page.goto(`${BASE}/front/computer.php`, { waitUntil: 'networkidle2', timeout: 60000 });
  await sleep(2500);
  const cb = await page.$('table tbody tr input[type="checkbox"]');
  if (!cb) {
    console.log('   [BO QUA] danh sach may tinh trong, khong co gi de tich chon');
    dem.bo++;
    await browser.close();
    process.exit(0);
  }
  await cb.click();
  await sleep(2500);

  const nut = await page.evaluateHandle(() => {
    const all = [...document.querySelectorAll('button, a')];
    return all.find((e) => /^Các hành động$/i.test((e.innerText || '').trim()));
  });
  if (!nut || !nut.asElement()) {
    console.log('   [BO QUA] khong thay nut "Cac hanh dong"');
    dem.bo++;
    await browser.close();
    process.exit(0);
  }
  await nut.asElement().click();
  await sleep(2500);

  // GLPI 11 dung <select> an (select2) trong modal
  const qrOpt = await page.evaluate(() => {
    const m = document.querySelector('.modal.show') || document;
    const o = [...m.querySelectorAll('select option')].find((x) => /Print QRcodes/i.test(x.text));
    return o ? { value: o.value, text: o.text.trim() } : null;
  });
  if (!qrOpt) {
    console.log('   [BO QUA] tai khoan nay khong thay tuy chon "Print QRcodes"');
    console.log('           (kiem tra quyen plugin_barcode_barcode cho ho so nay)');
    dem.bo++;
    await browser.close();
    process.exit(0);
  }
  console.log(`   -> chon: ${qrOpt.text}`);

  await page.evaluate((val) => {
    const sels = [...document.querySelectorAll('.modal.show select, .modal select')];
    const s = sels.find((x) => [...x.options].some((o) => o.value === val)) || sels[0];
    if (s) {
      s.value = val;
      s.dispatchEvent(new Event('change', { bubbles: true }));
    }
  }, qrOpt.value);

  // Cho form cau hinh nhan hien ra
  for (let i = 0; i < 24; i++) {
    const ready = await page.evaluate(() => {
      const m = document.querySelector('.modal.show') || document;
      return /Page size|Khổ giấy/i.test(m.innerText || '');
    });
    if (ready) break;
    await sleep(500);
  }
  await sleep(1500);

  // ------------------------------------------------------------------
  console.log('\n[4] Bam Create de sinh PDF...');
  const goBtn = await page.evaluateHandle(() => {
    const m = document.querySelector('.modal.show') || document;
    const all = [...m.querySelectorAll('button, input[type=submit]')];
    return all.find((e) => /^\s*(Create|Tạo|Créer)\s*$/i.test(e.innerText || e.value || ''));
  });

  if (!goBtn || !goBtn.asElement()) {
    console.log('   [BO QUA] khong thay nut Create');
    dem.bo++;
    await browser.close();
    process.exit(0);
  }

  // Nut Create co the mo tab moi -> bat popup
  const newPage = await new Promise((resolve) => {
    browser.once('targetcreated', async (t) => resolve(await t.page()));
    goBtn.asElement().click();
    setTimeout(() => resolve(null), 15000);
  });

  const work = newPage || page;
  await sleep(5000);
  if (newPage) {
    await newPage.waitForNavigation({ waitUntil: 'networkidle2', timeout: 30000 }).catch(() => {});
  }
  console.log('   URL ket qua:', work.url());
  await luu('13-phieu-qr-da-sinh.png', work);

  await browser.close();
  console.log('\n' + '='.repeat(70));
  console.log(`  XONG: ${dem.ok} anh, ${dem.bo} muc bo qua`);
  console.log('='.repeat(70) + '\n');
})().catch((e) => {
  console.error('LOI:', e.message);
  process.exit(1);
});
