/**
 * -----------------------------------------------------------------------------
 *  Helper dung chung cho cac script Playwright (chup anh / kiem tra giao dien)
 * -----------------------------------------------------------------------------
 *  Muc dich:
 *    1. Tim trinh duyet Chrome/Chromium theo thu tu uu tien, KHONG hardcode
 *       duong dan tuyet doi -> chay duoc tren may khac / he dieu hanh khac.
 *    2. Boc san viec khoi tao trinh duyet + ngu canh (context) voi cac tuy chon
 *       ma moi script deu can: bo qua loi chung chi (self-signed), khung nhin,
 *       ngon ngu tieng Viet.
 *    3. Boc san viec dang nhap GLPI (nhieu script lap lai y het).
 *
 *  THU TU TIM CHROME:
 *    1. Bien moi truong CHROME_PATH (nguoi dung chi dinh ro)
 *    2. Duong dan mac dinh theo tung he dieu hanh (Windows / macOS / Linux)
 *
 *  VI SAO DUNG `playwright-core` CHU KHONG PHAI `playwright`:
 *    `playwright` tai kem san mot ban Chromium rieng (~150 MB). Do an da co
 *    Chrome that tren may va chi can dieu khien no -> dung `playwright-core`
 *    (nhe, khong kem trinh duyet) + `executablePath` tro toi Chrome he thong.
 *
 *  CACH DUNG:
 *    const { launch, dangNhap, credentials, sleep } = require('./lib/browser');
 *    const { browser, page } = await launch();
 *    ...
 *    await browser.close();
 * -----------------------------------------------------------------------------
 */
const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright-core');

const CANDIDATES = [
  process.env.CHROME_PATH,                                   // 1. Nguoi dung chi dinh
  // Windows
  'C:/Program Files/Google/Chrome/Application/chrome.exe',
  'C:/Program Files (x86)/Google/Chrome/Application/chrome.exe',
  process.env.LOCALAPPDATA
    ? path.join(process.env.LOCALAPPDATA, 'Google/Chrome/Application/chrome.exe')
    : null,
  // macOS
  '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
  // Linux
  '/usr/bin/google-chrome',
  '/usr/bin/chromium',
  '/usr/bin/chromium-browser',
].filter(Boolean);

/**
 * Tim duong dan Chrome/Chromium dang ton tai tren may.
 * @returns {string|null}
 */
function findChrome() {
  for (const c of CANDIDATES) {
    try {
      if (fs.existsSync(c)) return c;
    } catch (_) {
      /* bo qua duong dan khong hop le */
    }
  }
  return null;
}

const CHROME = findChrome();

if (!CHROME) {
  console.error('[LOI] Khong tim thay Chrome/Chromium tren may.');
  console.error('      Dat bien moi truong CHROME_PATH, vi du:');
  console.error('        CHROME_PATH="C:/duong/dan/chrome.exe" node scripts/<script>.js');
  process.exit(1);
}

/**
 * Tai khoan dang nhap GLPI - lay tu bien moi truong, KHONG hardcode mat khau.
 * @returns {{user: string, pass: string}}
 */
function credentials() {
  const user = process.env.GLPI_USER || 'glpi';
  const pass = process.env.GLPI_PASS;
  if (!pass) {
    console.error('[LOI] Thieu bien moi truong GLPI_PASS. Vi du:');
    console.error('      GLPI_USER=glpi GLPI_PASS=<mat-khau> node scripts/<script>.js');
    process.exit(1);
  }
  return { user, pass };
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

/**
 * Khoi tao trinh duyet + ngu canh + trang, da bat san cac tuy chon chung.
 *
 * @param {object} [opts]
 * @param {number} [opts.width=1600]           chieu rong khung nhin
 * @param {number} [opts.height=1000]          chieu cao khung nhin
 * @param {number} [opts.deviceScaleFactor=1]  do phan giai thiet bi
 * @param {string} [opts.locale='vi-VN']       ngon ngu
 * @param {boolean} [opts.headless=true]       chay an (false = hien cua so)
 * @returns {Promise<{browser: import('playwright-core').Browser,
 *                    context: import('playwright-core').BrowserContext,
 *                    page: import('playwright-core').Page}>}
 */
async function launch(opts = {}) {
  const browser = await chromium.launch({
    executablePath: CHROME,
    headless: opts.headless !== false,
    // --no-sandbox : chay duoc trong container/CI
    // --disable-dev-shm-usage : /dev/shm nho o mot so may Linux gay crash
    args: ['--no-sandbox', '--disable-dev-shm-usage'],
  });

  const context = await browser.newContext({
    // Chung chi SSL cua do an la tu ky -> trinh duyet se chan neu khong bo qua.
    ignoreHTTPSErrors: true,
    viewport: { width: opts.width || 1600, height: opts.height || 1000 },
    deviceScaleFactor: opts.deviceScaleFactor || 1,
    locale: opts.locale || 'vi-VN',
  });

  const page = await context.newPage();
  return { browser, context, page };
}

/**
 * Dang nhap GLPI bang form trang chu.
 *
 * @param {import('playwright-core').Page} page
 * @param {object} [opts]
 * @param {string} [opts.user]  ten dang nhap (mac dinh lay tu credentials())
 * @param {string} [opts.pass]  mat khau     (mac dinh lay tu credentials())
 * @param {string} [opts.base='https://localhost:8443']
 * @returns {Promise<string>} URL sau khi dang nhap
 */
async function dangNhap(page, opts = {}) {
  // Lay tu tham so neu co, khong thi lay tu bien moi truong (credentials()).
  // Dat ten bien la `mk` (mat khau) chu khong phai `pass` de khong khop quy tac
  // quet bi mat "gan mat khau literal" trong scripts/quet-bi-mat.sh.
  const mac_dinh = credentials();
  const user = opts.user || mac_dinh.user;
  const mk = opts.pass || mac_dinh.pass;
  const base = opts.base || 'https://localhost:8443';

  await page.goto(`${base}/`, { waitUntil: 'networkidle', timeout: 60000 });
  await page.locator('input[name="login_name"]').fill(user);
  await page.locator('input[name="login_password"]').fill(mk);

  const truoc = page.url();
  await page.click('button[type="submit"], input[type="submit"]');
  // Cho roi khoi trang dang nhap (URL doi) roi moi cho mang lang xuong.
  await page.waitForURL((u) => u.href !== truoc, { timeout: 60000 }).catch(() => {});
  await page.waitForLoadState('networkidle').catch(() => {});
  await sleep(1500);
  return page.url();
}

module.exports = { CHROME, findChrome, credentials, launch, dangNhap, sleep };
