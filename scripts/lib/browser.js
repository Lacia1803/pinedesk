/**
 * -----------------------------------------------------------------------------
 *  Helper dung chung cho cac script Puppeteer (chup anh / kiem tra giao dien)
 * -----------------------------------------------------------------------------
 *  Muc dich: tim trinh duyet Chrome/Chromium theo thu tu uu tien, KHONG
 *  hardcode duong dan tuyet doi -> chay duoc tren may khac / he dieu hanh khac.
 *
 *  THU TU TIM:
 *    1. Bien moi truong CHROME_PATH (nguoi dung chi dinh ro)
 *    2. Duong dan mac dinh theo tung he dieu hanh (Windows / macOS / Linux)
 *
 *  CACH DUNG:
 *    const { CHROME, USER, PASS, requirePass } = require('./lib/browser');
 * -----------------------------------------------------------------------------
 */
const fs = require('fs');
const path = require('path');

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

module.exports = { CHROME, findChrome, credentials };
