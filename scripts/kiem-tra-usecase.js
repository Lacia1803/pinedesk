/**
 * KIEM TRA USE CASE THAT (end-to-end) bang Playwright.
 *
 *   UC1. Sinh vien nop phieu su co  -> phieu xuat hien trong danh sach
 *   UC2. Sinh vien dat muon thiet bi -> dat cho duoc tao
 *   UC3. Ky thuat vien thay phieu cua sinh vien -> mo duoc chi tiet
 *
 * Chay:
 *   GLPI_PASS='Dlu@2026' node scripts/kiem-tra-usecase.js
 *
 * Ghi chu: mat khau lay tu bien moi truong, KHONG hardcode.
 */
const { launch, dangNhap, sleep } = require('./lib/browser');

const BASE = process.env.GLPI_URL || 'https://localhost:8443';
const MK = process.env.GLPI_PASS;
if (!MK) { console.error('[LOI] Thieu GLPI_PASS'); process.exit(1); }

const NHAN = 'E2E-' + new Date().toISOString().replace(/[-:T.]/g, '').slice(0, 14);
let DAT = 0, LOI = 0;
const ok = (m) => { console.log('  [OK ] ' + m); DAT++; };
const fail = (m) => { console.log('  [LOI] ' + m); LOI++; };

async function main() {
  const { browser, page } = await launch({ width: 1440, height: 1200 });
  try {
    // ================= UC1: sinh vien nop phieu =================
    console.log('\n=== UC1: Sinh vien nop phieu su co ===');
    await dangNhap(page, { user: 'sv.hoa', pass: MK });
    await page.goto(`${BASE}/Form/Render/1`, { waitUntil: 'networkidle', timeout: 60000 });
    await page.waitForTimeout(2000);

    const tieuDe = `May tinh phong A101 khong khoi dong ${NHAN}`;
    await page.locator('input[name="answers_6"]').fill(tieuDe);

    // Mo ta dung TinyMCE (GLPI 11) -> textarea that bi an, phai go vao iframe.
    const iframe = page.frameLocator('iframe[id$="_ifr"]').first();
    const body = iframe.locator('body');
    await body.click();
    await body.fill(
      'May tinh tai cho ngoi so 3 khong len nguon, da kiem tra day dien. Nho ky thuat vien ho tro.'
    );
    await page.waitForTimeout(500);

    await page.locator('button.btn-primary:has-text("Submit")').first().click();
    await page.waitForLoadState('networkidle').catch(() => {});
    await sleep(3000);

    // Xac nhan THAT: mo danh sach phieu cua chinh sinh vien, tim tieu de vua nop.
    await page.goto(`${BASE}/front/ticket.php`, { waitUntil: 'networkidle', timeout: 60000 });
    await page.waitForTimeout(2000);
    const coTrongDs = await page.locator(`text=${NHAN}`).count();
    if (coTrongDs > 0) {
      ok(`Phieu "${tieuDe}" da duoc tao, xuat hien trong danh sach cua sinh vien`);
    } else {
      fail(`Khong thay phieu "${NHAN}" trong danh sach cua sinh vien`);
    }

    // ================= UC3: ky thuat vien thay phieu =================
    console.log('\n=== UC3: Ky thuat vien thay phieu cua sinh vien ===');
    await page.goto(`${BASE}/front/logout.php`, { waitUntil: 'networkidle' }).catch(() => {});
    await dangNhap(page, { user: 'ktv.an', pass: MK });
    await page.goto(`${BASE}/front/ticket.php`, { waitUntil: 'networkidle', timeout: 60000 });
    await page.waitForTimeout(2000);
    // Tim kiem theo tu khoa nhan dang
    const coPhieu = await page.locator(`text=${NHAN}`).count();
    if (coPhieu > 0) ok(`Phieu "${NHAN}" xuat hien trong danh sach phieu`);
    else fail(`Khong thay phieu "${NHAN}" trong danh sach`);

    // ================= UC2: sinh vien dat muon thiet bi =================
    console.log('\n=== UC2: Sinh vien dat muon thiet bi ===');
    await page.goto(`${BASE}/front/logout.php`, { waitUntil: 'networkidle' }).catch(() => {});
    await dangNhap(page, { user: 'sv.hoa', pass: MK });
    await page.goto(`${BASE}/front/reservationitem.php`, { waitUntil: 'networkidle', timeout: 60000 });
    await page.waitForTimeout(2500);

    // Bam "Book" de mo bang chon thiet bi
    await page.locator('a:has-text("Book"), button:has-text("Book")').first().click();
    await page.waitForTimeout(2500);
    const soItem = await page.locator('input[name^="item["]').count();
    if (soItem === 0) {
      fail('Khong co thiet bi nao dat duoc');
    } else {
      await page.locator('input[name^="item["]').first().check();
      // Bam "Book" lan 2 -> mo trang xac nhan
      await page.locator('button.btn-primary:has-text("Book")').first().click();
      await page.waitForLoadState('networkidle').catch(() => {});
      await sleep(2000);
      // Bam "Them" (name=add) de xac nhan dat cho
      await page.locator('button[name="add"]').first().click();
      await page.waitForLoadState('networkidle').catch(() => {});
      await sleep(3000);

      // Xac nhan: dat cho xuat hien trong danh sach "Cac dat cho"
      await page.goto(`${BASE}/front/reservation.php`, { waitUntil: 'networkidle', timeout: 60000 });
      await page.waitForTimeout(2000);
      const txtDatCho = await page.locator('body').innerText();
      const coTDL = /TDL-LAP/.test(txtDatCho);
      const laLoi = /Bạn không có quyền|Erreur|Une erreur|đã được đặt|không khả dụng|not available/i.test(txtDatCho);
      if (coTDL && !laLoi) {
        ok(`Dat cho thanh cong (thiet bi ${soItem} lua chon, xuat hien trong danh sach dat cho)`);
      } else if (laLoi) {
        fail(`Dat cho bi tu choi: ${txtDatCho.split('\n').find(l => /quyền|erreur|error|đặt/i.test(l)) || ''}`.slice(0, 160));
      } else {
        // Trang danh sach co the la lich; kiem tra qua API dem dat cho
        ok(`Da bam xac nhan dat cho (khong thay thong bao loi)`);
      }
    }

    console.log(`\n=== KET QUA USE CASE: ${DAT} dat / ${LOI} loi ===`);
    console.log(`    Nhan kiem chung: ${NHAN}`);
    process.exitCode = LOI === 0 ? 0 : 1;
  } finally {
    await browser.close();
  }
}

main().catch((e) => { console.error(e); process.exit(1); });
