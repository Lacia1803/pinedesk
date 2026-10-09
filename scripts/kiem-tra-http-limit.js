/**
 * KIEM TRA CHAN HAN MUC QUA DUONG HTTP THAT (end-to-end).
 *
 * VI SAO CAN TEP NAY (khac harness kiem-thu-han-muc.php):
 *   Harness chay IN-PROCESS: goi thang `new Ticket(); $t->add(...)` trong PHP CLI.
 *   No KHONG di qua Nginx, KHONG qua phien HTTP, KHONG qua
 *   Session::callAsSystem — trong khi duong tao phieu THAT cua nguoi dung la
 *   POST /Form/SubmitAnswers (Service Catalog). Comment trong hook.php da canh
 *   bao `callAsSystem` pha `haveRight`, nen hanh vi tren duong THAT co the khac.
 *
 *   Tep nay chung minh co che chan HOAT DONG THAT tren duong nguoi dung dung:
 *   khi tai khoan da cham tran phieu mo, phieu moi gui qua Service Catalog
 *   KHONG duoc ghi vao CSDL.
 *
 * PHAT HIEN KEM THEO (khong phai loi cua tep nay):
 *   Tren duong Service Catalog, khi bi chan, loi GLPI hien thi la thong bao
 *   he thong chung ("Failed to submit form...") thay vi thong bao tieng Viet
 *   than man. Day la hanh vi cua loi GLPI (AbstractCommonITILFormDestination
 *   nem Exception khi add() tra false), khong sua duoc neu khong dung loi.
 *   Tep nay CHI khang dinh "phieu khong duoc tao" (dieu that su quan trong),
 *   va IN CANH BAO ve thong bao neu gap.
 *
 * YEU CAU TRUOC KHI CHAY: max_open phai da duoc ha xuong 1 (wrapper shell
 * scripts/kiem-tra-http-limit.sh lo viec ha/khoi phuc).
 *
 * Chay:  GLPI_PASS='<mk>' node scripts/kiem-tra-http-limit.js
 */
const { launch, dangNhap, sleep } = require('./lib/browser');

const BASE = process.env.GLPI_URL || 'https://localhost:8443';
const MK = process.env.GLPI_PASS;
const USER = process.env.GLPI_USER || 'sv.hoa';
if (!MK) { console.error('[LOI] Thieu GLPI_PASS'); process.exit(1); }

const NHAN = 'HTTPLIMIT-' + new Date().toISOString().replace(/[-:T.]/g, '').slice(0, 14);
let DAT = 0, LOI = 0;
const ok = (m) => { console.log('  [OK ] ' + m); DAT++; };
const fail = (m) => { console.log('  [LOI] ' + m); LOI++; };

async function main() {
  const { browser, page } = await launch({ width: 1440, height: 1200 });
  try {
    console.log('\n=== KIEM TRA CHAN HAN MUC QUA HTTP THAT ===');
    await dangNhap(page, { user: USER, pass: MK });

    await page.goto(`${BASE}/Form/Render/1`, { waitUntil: 'networkidle', timeout: 60000 });
    await page.waitForTimeout(2000);

    const tieuDe = `Phieu kiem tra chan qua HTTP ${NHAN}`;
    await page.locator('input[name="answers_6"]').fill(tieuDe);
    const iframe = page.frameLocator('iframe[id$="_ifr"]').first();
    const body = iframe.locator('body');
    await body.click();
    await body.fill('Kiem tra co che chan han muc co hoat dong tren duong HTTP that khong.');
    await page.waitForTimeout(500);

    await page.locator('button.btn-primary:has-text("Submit")').first().click();
    await page.waitForLoadState('networkidle').catch(() => {});
    await sleep(3000);

    const noiDung = await page.locator('body').innerText();
    const coLoiChan = /Failed to submit|hạn mức|Bạn đang có|Vui lòng chờ/i.test(noiDung);

    // Khang dinh CHINH: phieu KHONG duoc tao (mo danh sach, tim tieu de).
    await page.goto(`${BASE}/front/ticket.php`, { waitUntil: 'networkidle', timeout: 60000 });
    await page.waitForTimeout(2000);
    const coPhieuMoi = await page.locator(`text=${NHAN}`).count();

    if (coPhieuMoi === 0 && coLoiChan) {
      ok('Phieu KHONG duoc tao qua HTTP that khi da cham tran (co che chan hoat dong)');
      // Canh bao ve thong bao (khong tinh la loi cua test)
      if (/Failed to submit/i.test(noiDung)) {
        console.log('  [CHU Y] Thong bao hien thi la loi he thong chung (tieng Anh),');
        console.log('          khong phai thong bao tieng Viet than man. Day la hanh vi');
        console.log('          cua loi GLPI tren duong Service Catalog (da ghi trong tai lieu).');
      } else {
        ok('Thong bao chan hien thi dung tieng Viet than man');
      }
    } else if (coPhieuMoi > 0) {
      fail(`Phieu VAN DUOC TAO qua HTTP (tim thay "${NHAN}") -> co che chan KHONG hoat dong tren duong that`);
    } else {
      fail('Khong thay dau hieu bi chan va cung khong thay phieu moi (ket qua mo ho)');
    }

    console.log(`\n=== KET QUA KIEM TRA HTTP LIMIT: ${DAT} dat / ${LOI} loi ===`);
    process.exitCode = LOI === 0 ? 0 : 1;
  } finally {
    await browser.close();
  }
}

main().catch((e) => { console.error(e); process.exit(1); });
