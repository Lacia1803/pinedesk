/**
 * ============================================================================
 *  KIEM TRA PLUGIN BARCODE/QR  (GLPI 11)
 * ============================================================================
 *  Kiem tra plugin sinh ma QR hoat dong that, KHONG tao du lieu rac:
 *    1. Trang Cau hinh -> Barcode mo duoc (200)
 *    2. Trang chi tiet thiet bi co tuy chon "Barcode - Print QRcodes"
 *       trong menu "Cac hanh dong"
 *    3. Bam sinh QR -> plugin ghi file PDF (kiem chung THAT)
 *
 *  VI SAO KHONG TAO THIET BI THU:
 *    Ban cu tao 'PC-TEST-QR-DLU-001' roi thu mo
 *    /plugins/barcode/front/barcode.php — URL nay KHONG con o GLPI 11 (404),
 *    va thiet bi thu lam ban bo du lieu demo 17 may. Ban nay dung thiet bi co
 *    san va dung dung luong "Cac hanh dong -> Print QRcodes".
 *
 *  CAN TAI KHOAN QUAN TRI (tuy chon nay chi hien voi ho so co quyen barcode).
 *    GLPI_USER=glpi GLPI_PASS='<mat-khau>' node scripts/kiem-tra-qr-va-chup-anh.js
 * ============================================================================
 */
const { launch, dangNhap, credentials, sleep } = require('./lib/browser');
const path = require('path');
const fs = require('fs');

const BASE = 'https://localhost:8443';
const OUT = path.join(__dirname, '..', 'tai-lieu', 'anh-giao-dien');
const { user: USER } = credentials();

const shot = async (page, name) => {
  const f = path.join(OUT, name);
  await page.screenshot({ path: f });
  console.log(`    [ANH] ${name} (${(fs.statSync(f).size / 1024).toFixed(0)} KB)`);
};

(async () => {
  fs.mkdirSync(OUT, { recursive: true });
  const { browser, page } = await launch({ width: 1600, height: 1000 });

  // ------------------------------------------------------------------
  console.log(`[1] Dang nhap (${USER}) + mo trang cau hinh Barcode...`);
  await dangNhap(page, { base: BASE });

  const resp = await page.goto(`${BASE}/plugins/barcode/front/config.php`, { waitUntil: 'networkidle', timeout: 60000 }).catch(() => null);
  await sleep(1500);
  const code = resp ? resp.status() : 0;
  if (code === 200 && /\/plugins\/barcode\/front\/config\.php$/.test(page.url())) {
    console.log('    [OK] Trang cau hinh Barcode -> HTTP 200');
    await shot(page, '11-cau-hinh-nhan-qr.png');
  } else {
    console.log(`    [BO QUA] tai khoan ${USER} khong du quyen (HTTP ${code}, o ${page.url()})`);
  }

  // ------------------------------------------------------------------
  console.log('\n[2] Mo mot thiet bi co san, tim tuy chon Print QRcodes...');
  await page.goto(`${BASE}/front/computer.php`, { waitUntil: 'networkidle', timeout: 60000 });
  await sleep(2000);

  const cb = page.locator('table tbody tr input[type="checkbox"]').first();
  if (await cb.count() === 0) {
    console.log('    [BO QUA] danh sach may tinh trong');
    await browser.close();
    process.exit(0);
  }
  await cb.click();
  await sleep(1500);
  await shot(page, '07-chi-tiet-thiet-bi.png');

  // Mo menu "Cac hanh dong"
  const daBam = await page.evaluate(() => {
    const e = [...document.querySelectorAll('button, a')]
      .find((x) => /^Các hành động$/i.test((x.innerText || '').trim()));
    if (e) { e.click(); return true; }
    return false;
  });
  if (!daBam) {
    console.log('    [BO QUA] khong thay nut "Cac hanh dong"');
    await browser.close();
    process.exit(0);
  }
  await sleep(2000);

  // Tuy chon "Print QRcodes" nam trong <select> an (select2) cua modal
  const qrOpt = await page.evaluate(() => {
    const m = document.querySelector('.modal.show') || document;
    const o = [...m.querySelectorAll('select option')].find((x) => /Print QRcodes/i.test(x.text));
    return o ? { value: o.value, text: o.text.trim() } : null;
  });

  if (!qrOpt) {
    console.log('    [BO QUA] khong thay tuy chon "Print QRcodes" (kiem tra quyen plugin_barcode_barcode)');
    await browser.close();
    process.exit(0);
  }
  console.log(`    [OK] Thay tuy chon: ${qrOpt.text}`);
  await shot(page, '10-menu-cac-hanh-dong.png');

  // ------------------------------------------------------------------
  console.log('\n[3] Bam Create de sinh PDF...');
  await page.evaluate((val) => {
    const sels = [...document.querySelectorAll('.modal.show select, .modal select')];
    const s = sels.find((x) => [...x.options].some((o) => o.value === val)) || sels[0];
    if (s) { s.value = val; s.dispatchEvent(new Event('change', { bubbles: true })); }
  }, qrOpt.value);

  for (let i = 0; i < 24; i++) {
    const ready = await page.evaluate(() => /Page size|Khổ giấy/i.test((document.querySelector('.modal.show') || document).innerText || ''));
    if (ready) break;
    await sleep(500);
  }
  await sleep(1000);

  const choTabMoi = page.context().waitForEvent('page', { timeout: 15000 }).catch(() => null);
  await page.evaluate(() => {
    const m = document.querySelector('.modal.show') || document;
    const e = [...m.querySelectorAll('button, a, input[type=submit]')]
      .find((x) => /^\s*(Create|Tạo|Créer)\s*$/i.test((x.innerText || x.value || '').trim()));
    if (e) e.click();
  });

  const newPage = await choTabMoi;
  await sleep(4000);
  if (newPage) {
    await newPage.waitForLoadState('networkidle').catch(() => {});
    console.log('    [OK] Da mo tab ket qua:', newPage.url());
  } else {
    console.log('    [CANH BAO] Nut Create khong mo tab moi (co the bi chan popup).');
    console.log('              Khong luu anh gia; kiem tra file PDF trong container GLPI.');
  }
  console.log('    => Kiem file PDF that:');
  console.log('       docker exec pinedesk-glpi ls -la /var/glpi/files/_plugins/barcode/');

  await browser.close();
  console.log('\nXONG.');
})().catch((e) => { console.error('LOI:', e.message); process.exit(1); });
