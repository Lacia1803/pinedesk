#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
================================================================================
 SINH MA QR CHO THIET BI GLPI  (PHUONG AN DU PHONG)
 Do an thuc tap: Xay dung he thong ho tro ky thuat (IT Helpdesk) - DH Da Lat
================================================================================

 Script nay doc danh sach thiet bi tu GLPI (qua REST API hoac tu file CSV),
 roi sinh:
   - Anh PNG ma QR cho tung thiet bi
   - File PDF gom nhieu nhan de in tren giay decal A4

 Uu diem: KHONG phu thuoc plugin barcode => khong so GLPI nang cap lam hong.
          Tu do bo cuc nhan (chen logo DLU, ten phong, ten khoa...).

--------------------------------------------------------------------------------
 CAI DAT (da lam san trong venv cua WorkBuddy):
   pip install qrcode[pil] reportlab requests

 CHAY:
   # Cach 1: doc tu GLPI API (can bat API + token)
   python scripts/sinh-ma-qr.py --api

   # Cach 2: doc tu file CSV xuat tu GLPI (an toan, khong can API)
   python scripts/sinh-ma-qr.py --csv danh-sach-thiet-bi.csv
================================================================================
"""
import argparse
import csv
import os
import re
import sys
from datetime import datetime

try:
    import qrcode
    from qrcode.constants import ERROR_CORRECT_M
    import qrcode.image.pil
except ImportError:
    print("Thieu thu vien. Chay: pip install qrcode[pil]")
    sys.exit(1)

try:
    from reportlab.lib.pagesizes import A4
    from reportlab.lib.units import mm
    from reportlab.lib import colors
    from reportlab.pdfgen import canvas
    from reportlab.pdfbase import pdfmetrics
    from reportlab.pdfbase.ttfonts import TTFont
except ImportError:
    print("Thieu reportlab. Chay: pip install reportlab")
    sys.exit(1)

# -----------------------------------------------------------------------------
# CAU HINH NHAN IN
# -----------------------------------------------------------------------------
NhanCauHinh = {
    'rong': 60 * mm,        # chieu rong 1 nhan
    'cao': 35 * mm,         # chieu cao 1 nhan
    'le_tren': 10 * mm,     # le tren trang
    'le_trai': 8 * mm,      # le trai trang
    'khoang_cach': 1.5 * mm,  # khe giua cac nhan
    'ten_don_vi': 'TRUONG DAI HOC DA LAT',
    'ten_he_thong': 'He thong Ho tro Ky thuat (IT Helpdesk)',
}

# Thu muc xuat
THU_MUC_XUAT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'output-qr')


# -----------------------------------------------------------------------------
# 1. TAO MAU DU LIEU (dung khi khong co API/CSV)
# -----------------------------------------------------------------------------
def tao_du_lieu_mau():
    """Tao danh sach thiet bi mau theo thuc te phong may DLU."""
    return [
        {'ma': 'ITC-PC-A101-001', 'ten': 'May tinh Dell OptiPlex 7010', 'phong': 'Phong may A101', 'khoa': 'Trung tam CNTT'},
        {'ma': 'ITC-PC-A101-002', 'ten': 'May tinh Dell OptiPlex 7010', 'phong': 'Phong may A101', 'khoa': 'Trung tam CNTT'},
        {'ma': 'ITC-PC-A101-003', 'ten': 'May tinh HP ProDesk 400 G7', 'phong': 'Phong may A101', 'khoa': 'Trung tam CNTT'},
        {'ma': 'ITC-SW-A101-01', 'ten': 'Switch Cisco Catalyst 2960', 'phong': 'Phong may A101', 'khoa': 'Trung tam CNTT'},
        {'ma': 'ITC-MON-A102-001', 'ten': 'Man hinh Dell P2419H', 'phong': 'Phong may A102', 'khoa': 'Trung tam CNTT'},
        {'ma': 'KTT-PC-B203-001', 'ten': 'May tinh Dell OptiPlex 3080', 'phong': 'Phong may B203', 'khoa': 'Khoa Toan - Tin hoc'},
        {'ma': 'KTT-PR-B203-03', 'ten': 'May in HP LaserJet Pro M404', 'phong': 'Phong may B203', 'khoa': 'Khoa Toan - Tin hoc'},
        {'ma': 'KCNTT-PC-C301-001', 'ten': 'May tinh Lenovo ThinkCentre', 'phong': 'Phong may C301', 'khoa': 'Khoa Cong nghe Thong tin'},
        {'ma': 'H1-MON-H105-012', 'ten': 'Man hinh LG 24MP400', 'phong': 'Phong H105', 'khoa': 'Khu hanh chinh H1'},
        {'ma': 'TT-PC-TL01-001', 'ten': 'May tra cuu thu vien', 'phong': 'Phong doc Thu vien', 'khoa': 'Trung tam Thong tin - Thu vien'},
    ]


# -----------------------------------------------------------------------------
# 2. DOC DU LIEU TU GLPI API
# -----------------------------------------------------------------------------
def doc_tu_api(base_url, app_token, user_token, limit=500):
    """
    Doc danh sach Computer tu GLPI REST API.
    Can bat API trong GLPI:  Cau hinh -> Chung -> API
    """
    import requests

    base_url = base_url.rstrip('/')
    session = requests.Session()
    session.headers.update({
        'App-Token': app_token,
        'Authorization': f'user_token {user_token}',
        'Content-Type': 'application/json',
    })

    # Khoi tao phien API
    r = session.get(f'{base_url}/apirest.php/initSession', verify=False)
    if r.status_code != 200:
        print(f"Loi khoi tao API ({r.status_code}): {r.text[:200]}")
        return []
    sess_token = r.json().get('session_token')
    session.headers['Session-Token'] = sess_token

    # Lay danh sach may tinh (co phan trang)
    ket_qua = []
    start = 0
    while len(ket_qua) < limit:
        r = session.get(
            f'{base_url}/apirest.php/Computer',
            params={
                'range': f'{start}-{start + 99}',
                'expand_dropdowns': 'true',
                'is_deleted': 0,
            },
            verify=False,
        )
        if r.status_code not in (200, 206):
            break
        batch = r.json()
        if not batch:
            break
        for it in batch:
            ket_qua.append({
                'ma': it.get('otherserial') or it.get('name') or f'PC-{it.get("id")}',
                'ten': it.get('name', ''),
                'phong': it.get('location', '') or it.get('locations_id', ''),
                'khoa': it.get('entities_id', ''),
            })
        start += 100

    session.get(f'{base_url}/apirest.php/killSession', verify=False)
    return ket_qua


# -----------------------------------------------------------------------------
# 3. DOC DU LIEU TU CSV
# -----------------------------------------------------------------------------
def doc_tu_csv(duong_dan):
    """
    Doc danh sach tu CSV xuat tu GLPI.
    Chap nhan cac ten cot: name, otherserial/inventory_number, location, entity
    """
    ket_qua = []
    with open(duong_dan, encoding='utf-8-sig', newline='') as f:
        reader = csv.DictReader(f)
        for row in reader:
            # Chuan hoa ten cot (GLPI xuat tieng Viet co dau)
            def lay(*ten):
                for t in ten:
                    if t in row and row[t]:
                        return str(row[t]).strip()
                return ''

            ket_qua.append({
                'ma': lay('otherserial', 'Inventory number', 'Ma tai san', 'Mã tài sản', 'name', 'Name'),
                'ten': lay('name', 'Name', 'Ten thiet bi', 'Tên thiết bị'),
                'phong': lay('location', 'Location', 'Vi tri', 'Vị trí'),
                'khoa': lay('entity', 'Entity', 'Don vi', 'Đơn vị'),
            })
    return ket_qua


# -----------------------------------------------------------------------------
# 4. SINH MA QR + XUAT PDF
# -----------------------------------------------------------------------------
def tao_anh_qr(noi_dung, duong_dan_png, kich_thuoc=4):
    """Tao anh PNG ma QR tu chuoi noi dung."""
    qr = qrcode.QRCode(
        version=None,                 # tu dong chon phien ban
        error_correction=ERROR_CORRECT_M,  # sua loi 15% - can bang giua do net & kich thuoc
        box_size=kich_thuoc,
        border=2,
    )
    qr.add_data(noi_dung)
    qr.make(fit=True)
    img = qr.make_image(fill_color='black', back_color='white')
    img.save(duong_dan_png)
    return duong_dan_png


def rut_gon_chuoi(s, n):
    """Cat bot chuoi qua dai de vua nhan."""
    s = re.sub(r'\s+', ' ', str(s)).strip()
    return s if len(s) <= n else s[:n - 1] + '…'


def xuat_pdf(danh_sach, duong_dan_pdf, thu_muc_anh):
    """Xuat PDF gom nhieu nhan, bo cuc luoi tren khau giay A4."""
    cfg = NhanCauHinh
    rong_trang, cao_trang = A4

    # Tinh so nhan vua trang
    so_cot = int((rong_trang - 2 * cfg['le_trai'] + cfg['khoang_cach'])
                 // (cfg['rong'] + cfg['khoang_cach']))
    so_hang = int((cao_trang - 2 * cfg['le_tren'] + cfg['khoang_cach'])
                  // (cfg['cao'] + cfg['khoang_cach']))
    so_nhan_trang = so_cot * so_hang

    c = canvas.Canvas(str(duong_dan_pdf), pagesize=A4)
    c.setTitle('Nhan ma QR thiet bi - DH Da Lat')

    for idx, tb in enumerate(danh_sach):
        vi_tri = idx % so_nhan_trang
        if idx > 0 and vi_tri == 0:
            c.showPage()   # sang trang moi

        cot = vi_tri % so_cot
        hang = vi_tri // so_cot

        x = cfg['le_trai'] + cot * (cfg['rong'] + cfg['khoang_cach'])
        y = cao_trang - cfg['le_tren'] - (hang + 1) * cfg['cao'] - hang * cfg['khoang_cach']

        # --- Khung vien nhan ---
        c.setStrokeColor(colors.HexColor('#B0BEC5'))
        c.setLineWidth(0.4)
        c.rect(x, y, cfg['rong'], cfg['cao'])

        # --- Vach mau nhan dien DLU (xanh reu) ben trai ---
        c.setFillColor(colors.HexColor('#2E7D5B'))
        c.rect(x, y, 2.2 * mm, cfg['cao'], stroke=0, fill=1)

        # --- Anh ma QR ---
        ten_anh = f'qr_{idx:04d}.png'
        duong_anh = os.path.join(thu_muc_anh, ten_anh)
        tao_anh_qr(tb['ma'], duong_anh)

        kich_qr = 22 * mm
        c.drawImage(duong_anh, x + 4 * mm, y + 5 * mm,
                    width=kich_qr, height=kich_qr, preserveAspectRatio=True)

        # --- Phan chu ben phai ma QR ---
        tx = x + 4 * mm + kich_qr + 3 * mm
        ty = y + cfg['cao'] - 7 * mm

        c.setFillColor(colors.HexColor('#1B5E20'))
        c.setFont('Helvetica-Bold', 5.4)
        c.drawString(tx, ty, rut_gon_chuoi(cfg['ten_don_vi'], 26))

        c.setFillColor(colors.HexColor('#37474F'))
        c.setFont('Helvetica-Bold', 7.5)
        c.drawString(tx, ty - 4.6 * mm, rut_gon_chuoi(tb['ma'], 20))

        c.setFont('Helvetica', 6)
        c.setFillColor(colors.HexColor('#546E7A'))
        c.drawString(tx, ty - 9 * mm, rut_gon_chuoi(tb['ten'], 24))
        c.drawString(tx, ty - 13 * mm, rut_gon_chuoi(tb['phong'], 24))

        # --- Dong chan nhan ---
        c.setFillColor(colors.HexColor('#78909C'))
        c.setFont('Helvetica-Oblique', 4.6)
        c.drawString(x + 4 * mm, y + 2 * mm, cfg['ten_he_thong'])

    c.save()
    return str(duong_dan_pdf)


# -----------------------------------------------------------------------------
# 5. CHUONG TRINH CHINH
# -----------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(
        description='Sinh ma QR cho thiet bi GLPI (phuong an du phong)')
    parser.add_argument('--csv', help='Duong dan file CSV xuat tu GLPI')
    parser.add_argument('--api', action='store_true',
                        help='Doc truc tiep tu GLPI REST API')
    parser.add_argument('--url', default='http://localhost:8080',
                        help='Dia chi GLPI (mac dinh http://localhost:8080)')
    parser.add_argument('--app-token', default=os.environ.get('GLPI_APP_TOKEN', ''))
    parser.add_argument('--user-token', default=os.environ.get('GLPI_USER_TOKEN', ''))
    parser.add_argument('--out', default=None, help='Duong dan file PDF xuat ra')
    args = parser.parse_args()

    print('=' * 78)
    print('  SINH MA QR THIET BI - HE THONG IT HELPDESK DH DA LAT')
    print('=' * 78)

    # --- Lay du lieu ---
    if args.api:
        if not args.app_token or not args.user_token:
            print('\n[LOI] Can --app-token va --user-token (hoac bien moi truong).')
            print('      Lay token tai: GLPI -> Cau hinh -> Chung -> API')
            print('      Hoac dung --csv de doc tu file CSV thay the.')
            sys.exit(1)
        print(f'\n[1] Doc du lieu tu GLPI API: {args.url}')
        import urllib3
        urllib3.disable_warnings()
        danh_sach = doc_tu_api(args.url, args.app_token, args.user_token)
    elif args.csv:
        print(f'\n[1] Doc du lieu tu CSV: {args.csv}')
        if not os.path.exists(args.csv):
            print(f'[LOI] Khong tim thay file: {args.csv}')
            sys.exit(1)
        danh_sach = doc_tu_csv(args.csv)
    else:
        print('\n[1] Khong co --api / --csv -> dung DU LIEU MAU de minh hoa.')
        print('    (Du lieu mau mo phong phong may thuc te tai DLU)')
        danh_sach = tao_du_lieu_mau()

    if not danh_sach:
        print('\n[LOI] Khong co thiet bi nao de xu ly.')
        sys.exit(1) 
    print(f'    -> Tim thay {len(danh_sach)} thiet bi')

    # --- Tao thu muc xuat ---
    os.makedirs(THU_MUC_XUAT, exist_ok=True)
    thu_muc_anh = os.path.join(THU_MUC_XUAT, 'anh-qr')
    os.makedirs(thu_muc_anh, exist_ok=True)

    # --- Sinh PDF ---
    print(f'\n[2] Dang sinh nhan QR...')
    ten_pdf = args.out or os.path.join(
        THU_MUC_XUAT,
        f'nhan-qr-thiet-bi_{datetime.now().strftime("%Y%m%d_%H%M%S")}.pdf')
    duong_pdf = xuat_pdf(danh_sach, ten_pdf, thu_muc_anh)
    print(f'    -> Da tao PDF: {duong_pdf}')
    print(f'    -> Anh QR rieng le: {thu_muc_anh}')

    # --- Thong ke ---
    print(f'\n[3] KET QUA:')
    print(f'    - So nhan: {len(danh_sach)}')
    print(f'    - File PDF: {os.path.getsize(duong_pdf) / 1024:.1f} KB')
    print(f'    - Thu muc xuat: {os.path.abspath(THU_MUC_XUAT)}')
    print()
    print('  GOI Y: In tren giay decal A4 (3 cot x 8 hang), cat roi dan len thiet bi.')
    print('=' * 78)


if __name__ == '__main__':
    main()
