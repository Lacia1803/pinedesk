/**
 * ============================================================================
 *  CHUP LAI ANH MINH CHUNG GIAO DIEN  (PineDesk)
 * ============================================================================
 *  Do an thuc tap: Xay dung he thong ho tro ky thuat (PineDesk) - DH Da Lat
 *
 *  VI SAO CO SCRIPT NAY
 *    Bo anh trong tai-lieu/anh-giao-dien/ duoc chup ngay 19/09, truoc khi
 *    giao dien Da Lat duoc viet lai (21/09) va truoc khi doi ten thanh
 *    PineDesk. Anh cu con ghi "IT Helpdesk DLU" o tieu de trinh duyet.
 *
 *  NGUYEN TAC (da tung vi pham, sinh ra anh sai)
 *    1. MOT MAN HINH MOT ANH. Khong luu cung mot trang duoi nhieu ten file.
 *    2. KHONG luu anh gia. Nhieu trang GLPI CHUYEN HUONG IM LANG ve
 *       central.php khi thieu quyen; neu chi tim chu "khong co quyen" tren
 *       noi dung thi se luu nham anh bang dieu khien vao file khac. Script
 *       doi chieu ca URL that su dung lai lan <title>.
 *    3. Trang doi quyen quan tri thi BO QUA va bao ro, khong chup bua.
 *       Anh trang quan tri: scripts/chup-anh-qr-admin.js
 *
 *  CHAY
 *    GLPI_USER=ktv.an GLPI_PASS='<mat-khau>' node scripts/chup-lai-anh-minh-chung.js
 *
 *  ANH KHONG DO SCRIPT NAY TAO:
 *    - 12-ket-qua-sinh-qr.png  : do scripts/sinh-ma-qr.py xuat PDF roi render
 *    - 16/17-landing-*.png     : do scripts/kiem-tra-landing.js chup vao .tmp-check/
 *                                roi copy sang tai-lieu/anh-giao-dien/
 * ============================================================================
 */
const { launch, dangNhap, credentials, sleep } = require('./lib/browser');
const path = require('path');
const fs = require('fs');

const BASE = 'https://localhost:8443';
const OUT = path.join(__dirname, '..', 'tai-lieu', 'anh-giao-dien');
const { user: USER } = credentials();

(async () => {
  fs.mkdirSync(OUT, { recursive: true });

  const { browser, page } = await launch({
    width: 1600, height: 1000, deviceScaleFactor: 1,
  });

  const dem = { ok: 0, bo: 0 };
  const BO_QUA = [];

  // GLPI bao thieu quyen bang hai cau khac nhau tuy trang:
  //   - <title>   : "Khong co quyen truy cap"
  //   - noi dung  : "Ban khong co quyen thuc hien hanh dong nay"
  // Phai kiem tra CA HAI, neu khong se luu nham trang bao loi thanh minh chung.
  const state = () =>
    page.evaluate(() => ({
      path: location.pathname,
      title: document.title,
      denied: /không có quyền|access denied|không được phép/i.test(
        (document.title || '') + ' ' + (document.body.innerText || '')
      ),
    }));

  const luu = async (ten) => {
    const f = path.join(OUT, ten);
    await page.screenshot({ path: f });
    const kb = (fs.statSync(f).size / 1024).toFixed(0);
    console.log(`   [ANH] ${ten} (${kb} KB)`);
    dem.ok++;
  };

  const mo = async (duong_dan, cho = 1800) => {
    await page.goto(BASE + duong_dan, { waitUntil: 'networkidle', timeout: 60000 });
    await sleep(cho);
    return state();
  };

  // Chi luu khi URL that su dung lai VA khong bi chan quyen
  const chup = async (ten, duong_dan, cho) => {
    const s = await mo(duong_dan, cho);
    if (s.denied || s.path !== duong_dan) {
      console.log(`   [BO QUA] ${ten}: doi quyen quan tri (dung -> ${s.path})`);
      BO_QUA.push(ten);
      dem.bo++;
      return false;
    }
    await luu(ten);
    return true;
  };

  // -------------------------------------------------------------------
  // 1. TRANG DANG NHAP (chua dang nhap)
  // -------------------------------------------------------------------
  console.log('\n[1] Trang dang nhap...');
  await page.goto(`${BASE}/`, { waitUntil: 'networkidle', timeout: 60000 });
  await sleep(1500);
  await luu('01-trang-dang-nhap.png');

  // -------------------------------------------------------------------
  // 2. DANG NHAP
  // -------------------------------------------------------------------
  console.log('\n[2] Dang nhap (' + USER + ')...');
  await dangNhap(page, { base: BASE });

  // -------------------------------------------------------------------
  // 3. BANG DIEU KHIEN
  // -------------------------------------------------------------------
  console.log('\n[3] Bang dieu khien...');
  await chup('02-bang-dieu-khien.png', '/front/central.php', 2500);

  // -------------------------------------------------------------------
  // 4. QUAN LY TAI SAN (moi nhom mot anh)
  // -------------------------------------------------------------------
  console.log('\n[4] Quan ly tai san...');
  await chup('03-danh-sach-may-tinh.png', '/front/computer.php', 2000);
  await chup('03b-danh-sach-man-hinh.png', '/front/monitor.php', 1800);
  await chup('03c-thiet-bi-mang.png', '/front/networkequipment.php', 1800);
  await chup('03d-danh-sach-may-in.png', '/front/printer.php', 1800);
  await chup('03e-danh-sach-phan-mem.png', '/front/software.php', 1800);

  // -------------------------------------------------------------------
  // 5. TIEP NHAN SU CO (ticket)
  // -------------------------------------------------------------------
  console.log('\n[5] Tiep nhan su co...');
  await chup('04-danh-sach-phieu-yeu-cau.png', '/front/ticket.php', 2000);
  await chup('05-tao-phieu-moi.png', '/front/ticket.form.php', 2000);

  // -------------------------------------------------------------------
  // 6. NHAN SU / CO CAU TO CHUC
  // -------------------------------------------------------------------
  console.log('\n[6] Nhom / nguoi dung...');
  await chup('06-nhom-co-cau-to-chuc.png', '/front/group.php', 1800);
  await chup('08-danh-sach-nguoi-dung.png', '/front/user.php', 1800);

  // -------------------------------------------------------------------
  // 7. TAO + CHI TIET THIET BI (kem the ma QR)
  // -------------------------------------------------------------------
  console.log('\n[7] Form tao thiet bi...');
  await mo('/front/computer.form.php', 2000);
  const coForm = await page.locator('input[name="name"]').count() > 0;
  if (coForm) {
    await page.locator('input[name="name"]').fill('PC-MINH-CHUNG-PINEDESK');
    await sleep(700);
    await luu('06-tao-thiet-bi.png');
  } else {
    console.log('   [BO QUA] 06-tao-thiet-bi.png: khong thay form tao thiet bi');
    BO_QUA.push('06-tao-thiet-bi.png');
    dem.bo++;
  }

  console.log('\n[8] Chi tiet thiet bi + ma QR...');
  await mo('/front/computer.php', 1800);
  const daMo = await page.evaluate(() => {
    const a = document.querySelector('table tbody tr a[href*="computer.form.php"]');
    if (a) {
      a.click();
      return true;
    }
    return false;
  });
  if (daMo) {
    await sleep(2500);
    await luu('07-chi-tiet-thiet-bi.png');
    // The ma QR nam o cot phai ho so thiet bi -> chup rieng cho ro
    const qrCard = await page.evaluateHandle(() => {
      const img = [...document.querySelectorAll('img')].find(
        (i) => /^data:image\/png;base64/.test(i.src) && i.naturalWidth >= 150
      );
      return img ? img.closest('.card') || img.parentElement : null;
    });
    const el = qrCard.asElement();
    if (el) {
      const f = path.join(OUT, '11-ma-qr-thiet-bi.png');
      await el.screenshot({ path: f });
      console.log(`   [ANH] 11-ma-qr-thiet-bi.png (${(fs.statSync(f).size / 1024).toFixed(0)} KB)`);
      dem.ok++;
    } else {
      console.log('   [BO QUA] 11-ma-qr-thiet-bi.png: khong thay the ma QR');
      BO_QUA.push('11-ma-qr-thiet-bi.png');
      dem.bo++;
    }
  } else {
    console.log('   [BO QUA] 07-chi-tiet-thiet-bi.png, 11-ma-qr-thiet-bi.png: danh sach trong');
    BO_QUA.push('07-chi-tiet-thiet-bi.png', '11-ma-qr-thiet-bi.png');
    dem.bo += 2;
  }

  // -------------------------------------------------------------------
  // 9. MENU "CAC HANH DONG" (modal that, khac anh danh sach)
  // -------------------------------------------------------------------
  console.log('\n[9] Menu Cac hanh dong (modal)...');
  await mo('/front/computer.php', 2500);
  const cb = page.locator('table tbody tr input[type="checkbox"]').first();
  if (await cb.count() > 0) {
    await cb.click();
    await sleep(2500);
    const daBam = await page.evaluate(() => {
      const e = [...document.querySelectorAll('button, a')]
        .find((x) => /^Các hành động$/i.test((x.innerText || '').trim()));
      if (e) { e.click(); return true; }
      return false;
    });
    if (daBam) {
      await sleep(2200);
      await luu('10-menu-cac-hanh-dong.png');
    } else {
      console.log('   [BO QUA] 10-menu-cac-hanh-dong.png: khong thay nut Cac hanh dong');
      BO_QUA.push('10-menu-cac-hanh-dong.png');
      dem.bo++;
    }
  } else {
    console.log('   [BO QUA] 10-menu-cac-hanh-dong.png: danh sach trong');
    BO_QUA.push('10-menu-cac-hanh-dong.png');
    dem.bo++;
  }

  // -------------------------------------------------------------------
  // 10. THONG KE
  // -------------------------------------------------------------------
  console.log('\n[10] Thong ke...');
  await chup('13-thong-ke-toan-cau.png', '/front/stat.php', 2500);

  // -------------------------------------------------------------------
  if (BO_QUA.length) {
    console.log('\n[CAN QUYEN QUAN TRI - xem scripts/chup-anh-qr-admin.js]');
    BO_QUA.forEach((x) => console.log('   - ' + x));
  }

  await browser.close();

  console.log('\n' + '='.repeat(70));
  console.log(`  XONG: ${dem.ok} anh da chup, ${dem.bo} muc bo qua`);
  console.log('  Thu muc: ' + OUT);
  console.log('='.repeat(70) + '\n');
})().catch((e) => {
  console.error('LOI:', e.message);
  process.exit(1);
});
