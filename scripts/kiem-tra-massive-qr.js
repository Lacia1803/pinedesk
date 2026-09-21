/**
 * Kiem tra day du: tich chon thiet bi -> Cac hanh dong -> chon Print QRcodes
 * GLPI 11 dung MODAL voi dropdown <select>, khong phai menu dropdown.
 */
const puppeteer = require('puppeteer-core');
const path = require('path');
const fs = require('fs');

// Duong dan Chrome + tai khoan dang nhap: lay tu scripts/lib/browser.js
const { CHROME, credentials } = require('./lib/browser');
const BASE = 'https://localhost:8443';
const OUT = path.join(__dirname, '..', 'tai-lieu', 'anh-giao-dien');
const { user: USER, pass: PASS } = credentials();

const shot = async (page, name) => {
  const f = path.join(OUT, name);
  await page.screenshot({ path: f });
  console.log(`    [ANH] ${name} (${(fs.statSync(f).size / 1024).toFixed(0)} KB)`);
};

(async () => {
  const browser = await puppeteer.launch({
    executablePath: CHROME,
    headless: 'new',
    args: ['--ignore-certificate-errors', '--no-sandbox', '--window-size=1600,1000'],
    defaultViewport: { width: 1600, height: 1000 },
  });
  const page = await browser.newPage();

  await page.goto(`${BASE}/`, { waitUntil: 'networkidle2' });
  await page.type('input[name="login_name"]', USER, { delay: 20 });
  await page.type('input[name="login_password"]', PASS, { delay: 20 });
  await Promise.all([
    page.waitForNavigation({ waitUntil: 'networkidle2' }).catch(() => {}),
    page.click('button[type="submit"], input[type="submit"]'),
  ]);
  await new Promise((r) => setTimeout(r, 1500));

  console.log('[1] Mo danh sach may tinh, tich chon thiet bi...');
  await page.goto(`${BASE}/front/computer.php`, { waitUntil: 'networkidle2' });
  await new Promise((r) => setTimeout(r, 2500));
  const cb = await page.$('table tbody tr input[type="checkbox"]');
  if (!cb) { console.log('    khong co thiet bi'); await browser.close(); return; }
  await cb.click();
  await new Promise((r) => setTimeout(r, 3000));

  console.log('\n[2] Mo modal "Các hành động"...');
  const btn = await page.evaluateHandle(() => {
    const all = [...document.querySelectorAll('button, a')];
    return all.find((e) => /^Các hành động$/i.test((e.innerText || '').trim()));
  });
  if (!btn || !btn.asElement()) { console.log('    khong thay nut'); await browser.close(); return; }
  await btn.asElement().click();
  await new Promise((r) => setTimeout(r, 2500));

  // Liet ke cac option trong dropdown cua modal
  const opts = await page.evaluate(() => {
    const m = document.querySelector('.modal.show') || document;
    return [...m.querySelectorAll('select option')]
      .map((o) => ({ value: o.value, text: o.text.trim() }))
      .filter((o) => o.text);
  });
  console.log('    So tuy chon:', opts.length);
  opts.forEach((o) => console.log(`      [${o.value}] ${o.text}`));

  const qrOpt = opts.find((o) => /Print QRcodes/i.test(o.text));
  console.log('\n    => Tuy chon QR:', qrOpt ? `CO ✅ (${qrOpt.text})` : 'KHONG ❌');

  if (qrOpt) {
    console.log('\n[3] Chon "Print QRcodes"...');
    // GLPI 11 dung <select> an (select2) - chon bang cach set value + dispatch event
    await page.evaluate((val) => {
      const sels = [...document.querySelectorAll('.modal.show select, .modal select')];
      const s = sels.find((x) => [...x.options].some((o) => o.value === val)) || sels[0];
      if (s) {
        s.value = val;
        s.dispatchEvent(new Event('change', { bubbles: true }));
      }
    }, qrOpt.value);

    // Cho form cau hinh hien ra
    for (let i = 0; i < 20; i++) {
      const ready = await page.evaluate(() => {
        const m = document.querySelector('.modal.show') || document;
        return /Page size|Khổ giấy/i.test(m.innerText || '');
      });
      if (ready) break;
      await new Promise((r) => setTimeout(r, 500));
    }
    await new Promise((r) => setTimeout(r, 1500));
    await shot(page, '11-cau-hinh-nhan-qr.png');

    const info0 = await page.evaluate(() => {
      const m = document.querySelector('.modal.show') || document;
      return {
        coCauHinh: /Page size|Khổ giấy/i.test(m.innerText || ''),
        nut: [...m.querySelectorAll('button')].map((b) => (b.innerText || '').trim()).filter(Boolean).slice(0, 10),
      };
    });
    console.log('    Form cau hinh nhan hien ra:', info0.coCauHinh ? 'CO ✅' : 'KHONG');
    console.log('    cac nut:', JSON.stringify(info0.nut));

    console.log('\n[4] Bam "Create" de sinh ma QR...');
    const goBtn = await page.evaluateHandle(() => {
      const m = document.querySelector('.modal.show') || document;
      const all = [...m.querySelectorAll('button, input[type=submit]')];
      return all.find((e) => /^\s*(Create|Tạo|Créer)\s*$/i.test(e.innerText || e.value || ''));
    });
    if (goBtn && goBtn.asElement()) {
      // Nut Create co the mo tab moi -> bat popup
      const newPage = await new Promise((resolve) => {
        browser.once('targetcreated', async (t) => {
          const np = await t.page();
          resolve(np);
        });
        goBtn.asElement().click();
        setTimeout(() => resolve(null), 15000);
      });

      const workPage = newPage || page;
      await new Promise((r) => setTimeout(r, 5000));
      if (newPage) {
        await newPage.waitForNavigation({ waitUntil: 'networkidle2', timeout: 30000 }).catch(() => {});
      }
      console.log('    URL trang ket qua:', workPage.url());
      await shot(workPage, '12-ket-qua-sinh-qr.png');

      const info = await workPage.evaluate(() => ({
        title: document.title,
        imgs: [...document.querySelectorAll('img')].map((i) => i.src)
          .filter((s) => /barcode|qr|\.png|document/i.test(s)).slice(0, 5),
      }));
      console.log('    title:', info.title);
      console.log('    anh QR:', JSON.stringify(info.imgs));
    }
  }

  await browser.close();
  console.log('\nXONG.');
})().catch((e) => { console.error('LOI:', e.message); process.exit(1); });
