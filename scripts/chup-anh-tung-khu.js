/* Chụp riêng từng khu vực để soi chi tiết.
   Trang không còn hiệu ứng xuất hiện khi cuộn, nên chỉ cần cuộn tới đúng khu
   rồi chụp — không phải chờ khối hiện ra. */
const puppeteer = require('puppeteer-core');
const fs = require('fs');
// Duong dan Chrome: lay tu scripts/lib/browser.js (dat CHROME_PATH neu can)
const { CHROME } = require('./lib/browser');
const URL = 'https://localhost:8443/landing/';
const OUT = '.tmp-check';

const KHU = [
  ['nav',        '.nav'],
  ['mo-dau',     '.mo-dau__chu'],
  ['canh-nen',   '.canh'],
  ['cua-so',     '.cua-so'],
  ['quy-mo',     '.quy-mo'],
  ['tinh-nang',  '#tinh-nang'],
  ['tai-khoan',  '#tai-khoan'],
  ['kien-truc',  '#kien-truc'],
  ['tai-lieu',   '#tai-lieu'],
  ['moi',        '.moi'],
  ['chan-trang', '.chan'],
];

const cho = (ms) => new Promise(r => setTimeout(r, ms));

(async () => {
  fs.mkdirSync(OUT, { recursive: true });
  const b = await puppeteer.launch({
    executablePath: CHROME, headless: 'new',
    args: ['--ignore-certificate-errors', '--no-sandbox'],
    defaultViewport: { width: 1440, height: 1000 },
  });
  const p = await b.newPage();
  await p.goto(URL, { waitUntil: 'networkidle2', timeout: 60000 });

  for (const [ten, sel] of KHU) {
    const el = await p.$(sel);
    if (!el) { console.log('KHONG THAY', sel); continue; }

    // Cuon toi khu nay roi cho anh luoi (neu co) tai xong
    await p.evaluate(async (s) => {
      const e = document.querySelector(s);
      const dich = e.getBoundingClientRect().top + window.scrollY - 120;
      const dau = window.scrollY;
      for (let i = 1; i <= 8; i++) {
        window.scrollTo(0, dau + (dich - dau) * i / 8);
        await new Promise(r => setTimeout(r, 60));
      }
    }, sel);
    await cho(400);

    try {
      await el.screenshot({ path: `${OUT}/khu-${ten}.png` });
      console.log('OK', ten, '<-', sel);
    } catch (e) {
      console.log('LOI', ten, e.message);
    }
  }
  await b.close();
})().catch(e => { console.error('LOI:', e.message); process.exit(1); });
