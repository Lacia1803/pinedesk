#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script xây dựng Báo cáo thực tập tốt nghiệp hoàn chỉnh chuẩn Đại học Đà Lạt (DLU)
Định dạng xuất bản Word (.docx): BAO-CAO-THUC-TAP-FINAL.docx
Sinh viên: Phùng Võ Quốc Hiển (MSSV: 2212364, Lớp: CTK46-PM, Khóa K46)
Khoa Công nghệ Thông tin - Trường Đại học Đà Lạt
"""

import os
import re
import sys
import docx
from docx.shared import Inches, Pt, Cm, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn

# --- BẢNG MÀU CHUẨN THƯƠNG HIỆU & HỌC THUẬT ---
COLOR_NAVY = RGBColor(27, 54, 93)       # #1B365D - Xanh truyền thống ĐH Đà Lạt
COLOR_PINE = RGBColor(96, 120, 36)      # #607824 - Xanh thông Đà Lạt
COLOR_DARK = RGBColor(44, 62, 80)       # #2C3E50 - Xám đen Slate
COLOR_BODY = RGBColor(30, 30, 30)       # #1E1E1E - Chữ thân bài
COLOR_MUTED = RGBColor(115, 115, 115)   # #737373 - Chú thích
COLOR_BORDER = "CCCCCC"                 # Viền bảng
COLOR_HEADER_BG = "1B365D"              # Nền tiêu đề bảng
COLOR_ZEBRA_BG = "F8F9FA"               # Nền dòng chẵn
COLOR_CALLOUT_BG = "FAF9F5"             # Nền Claude Warmth
COLOR_CODE_BG = "F4F6F7"                # Nền code khối

WORKSPACE_DIR = r"D:\glpi-helpdesk"
MD_FILE_PATH = os.path.join(WORKSPACE_DIR, "tai-lieu", "BAO-CAO-THUC-TAP.md")
OUT_DOCX_PATH = os.path.join(WORKSPACE_DIR, "tai-lieu", "BAO-CAO-THUC-TAP-FINAL.docx")
LOGO_PATH = os.path.join(WORKSPACE_DIR, "themes", "pics", "logos", "logo-DLU-250.png")
IMG_DIR = os.path.join(WORKSPACE_DIR, "tai-lieu", "anh-giao-dien")

def clear_hf(hf):
    """Xóa nội dung mặc định của Header hoặc Footer."""
    for p in hf.paragraphs:
        p.text = ''

def setup_page_geometry(section):
    """Thiết lập khổ giấy A4 và lề chuẩn Đại học Đà Lạt (Lề trái 3.5cm để đóng gáy)."""
    section.page_width = Cm(21.0)
    section.page_height = Cm(29.7)
    section.top_margin = Cm(2.0)
    section.bottom_margin = Cm(2.0)
    section.left_margin = Cm(3.5)
    section.right_margin = Cm(2.0)
    section.header_distance = Cm(1.2)
    section.footer_distance = Cm(1.2)

def set_cell_margins(cell, top=100, bottom=100, left=150, right=150):
    """Thiết lập padding cho ô trong bảng (1pt = 20dxa)."""
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = parse_xml(
        f'<w:tcMar {nsdecls("w")}>'
        f'<w:top w:w="{top}" w:type="dxa"/>'
        f'<w:bottom w:w="{bottom}" w:type="dxa"/>'
        f'<w:left w:w="{left}" w:type="dxa"/>'
        f'<w:right w:w="{right}" w:type="dxa"/>'
        f'</w:tcMar>'
    )
    tcPr.append(tcMar)

def set_cell_shading(cell, color_hex):
    """Thiết lập màu nền cho ô."""
    tcPr = cell._tc.get_or_add_tcPr()
    shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{color_hex}"/>')
    tcPr.append(shd)

def set_table_borders(table, color="CCCCCC", sz="4", val="single"):
    """Đường viền bảng trang nhã chuẩn bài báo khoa học."""
    tblPr = table._tbl.tblPr
    borders = parse_xml(
        f'<w:tblBorders {nsdecls("w")}>'
        f'<w:top w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>'
        f'<w:bottom w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>'
        f'<w:insideH w:val="{val}" w:sz="3" w:space="0" w:color="E5E7EB"/>'
        f'<w:insideV w:val="none"/>'
        f'<w:left w:val="none"/>'
        f'<w:right w:val="none"/>'
        f'</w:tblBorders>'
    )
    tblPr.append(borders)

def add_page_number_to_run(run):
    """Thêm trường PAGE động vào run trong Footer."""
    fldChar1 = parse_xml(r'<w:fldChar %s w:fldCharType="begin"/>' % nsdecls('w'))
    instrText = parse_xml(r'<w:instrText %s xml:space="preserve"> PAGE </w:instrText>' % nsdecls('w'))
    fldChar2 = parse_xml(r'<w:fldChar %s w:fldCharType="separate"/>' % nsdecls('w'))
    fldChar3 = parse_xml(r'<w:fldChar %s w:fldCharType="end"/>' % nsdecls('w'))
    run._r.append(fldChar1)
    run._r.append(instrText)
    run._r.append(fldChar2)
    run._r.append(fldChar3)

def add_formatted_text(paragraph, text, default_color=None, default_size=Pt(13), default_font="Times New Roman"):
    """Phân tích markdown inline (**đậm**, *nghiêng*, `mã lệnh`) thành các run định dạng."""
    parts = re.split(r'(\*\*.*?\*\*|\*.*?\*|`.*?`)', text)
    for part in parts:
        if not part:
            continue
        if part.startswith('**') and part.endswith('**'):
            run = paragraph.add_run(part[2:-2])
            run.bold = True
            run.font.name = default_font
            run.font.size = default_size
            if default_color:
                run.font.color.rgb = default_color
        elif part.startswith('*') and part.endswith('*'):
            run = paragraph.add_run(part[1:-1])
            run.italic = True
            run.font.name = default_font
            run.font.size = default_size
            if default_color:
                run.font.color.rgb = default_color
        elif part.startswith('`') and part.endswith('`'):
            run = paragraph.add_run(part[1:-1])
            run.font.name = "Consolas"
            run.font.size = Pt(11)
            run.font.color.rgb = RGBColor(170, 30, 30)
        else:
            run = paragraph.add_run(part)
            run.font.name = default_font
            run.font.size = default_size
            if default_color:
                run.font.color.rgb = default_color

def set_paragraph_spacing(p, before=0, after=6, line_spacing=1.3):
    """Thiết lập giãn dòng 1.3 và khoảng cách đoạn chuẩn DLU."""
    pPr = p._p.get_or_add_pPr()
    spPr = parse_xml(
        f'<w:spacing {nsdecls("w")} w:before="{int(before*20)}" w:after="{int(after*20)}" '
        f'w:line="{int(line_spacing*240)}" w:lineRule="auto"/>'
    )
    pPr.append(spPr)

def create_callout_box(doc, text_lines, border_color="1B365D", bg_color=COLOR_CALLOUT_BG):
    """Tạo hộp trích dẫn / ghi chú nhấn mạnh với viền trái và nền ấm."""
    table = doc.add_table(rows=1, cols=1)
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.autofit = False

    cell = table.cell(0, 0)
    cell.width = Cm(15.5)
    set_cell_margins(cell, top=140, bottom=140, left=200, right=180)
    set_cell_shading(cell, bg_color)

    tcPr = cell._tc.get_or_add_tcPr()
    borders = parse_xml(
        f'<w:tcBorders {nsdecls("w")}>'
        f'<w:top w:val="none"/>'
        f'<w:left w:val="single" w:sz="24" w:space="0" w:color="{border_color}"/>'
        f'<w:bottom w:val="none"/>'
        f'<w:right w:val="none"/>'
        f'</w:tcBorders>'
    )
    tcPr.append(borders)

    p = cell.paragraphs[0]
    p.paragraph_format.first_line_indent = Inches(0)
    set_paragraph_spacing(p, before=2, after=4, line_spacing=1.2)
    add_formatted_text(p, text_lines[0], default_size=Pt(12), default_color=COLOR_DARK)
    if p.runs:
        p.runs[0].italic = True

    for line in text_lines[1:]:
        p2 = cell.add_paragraph()
        p2.paragraph_format.first_line_indent = Inches(0)
        set_paragraph_spacing(p2, before=2, after=4, line_spacing=1.2)
        add_formatted_text(p2, line, default_size=Pt(12), default_color=COLOR_DARK)

    p_spacer = doc.add_paragraph()
    set_paragraph_spacing(p_spacer, before=0, after=4, line_spacing=1.0)
    p_spacer.paragraph_format.first_line_indent = Inches(0)

def create_code_block(doc, code_lines):
    """Tạo hộp hiển thị mã lệnh / cấu hình với font Consolas và viền kép."""
    table = doc.add_table(rows=1, cols=1)
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.autofit = False

    cell = table.cell(0, 0)
    cell.width = Cm(15.5)
    set_cell_margins(cell, top=120, bottom=120, left=180, right=150)
    set_cell_shading(cell, COLOR_CODE_BG)

    tcPr = cell._tc.get_or_add_tcPr()
    borders = parse_xml(
        f'<w:tcBorders {nsdecls("w")}>'
        f'<w:top w:val="single" w:sz="4" w:space="0" w:color="BDC3C7"/>'
        f'<w:left w:val="single" w:sz="20" w:space="0" w:color="607824"/>'
        f'<w:bottom w:val="single" w:sz="4" w:space="0" w:color="BDC3C7"/>'
        f'<w:right w:val="single" w:sz="4" w:space="0" w:color="BDC3C7"/>'
        f'</w:tcBorders>'
    )
    tcPr.append(borders)

    p = cell.paragraphs[0]
    p.paragraph_format.first_line_indent = Inches(0)
    set_paragraph_spacing(p, before=1, after=1, line_spacing=1.1)

    for i, line in enumerate(code_lines):
        if i > 0:
            p = cell.add_paragraph()
            p.paragraph_format.first_line_indent = Inches(0)
            set_paragraph_spacing(p, before=1, after=1, line_spacing=1.1)
        r = p.add_run(line)
        r.font.name = "Consolas"
        r.font.size = Pt(10)
        r.font.color.rgb = RGBColor(30, 30, 30)

    p_spacer = doc.add_paragraph()
    set_paragraph_spacing(p_spacer, before=0, after=4, line_spacing=1.0)
    p_spacer.paragraph_format.first_line_indent = Inches(0)

def render_markdown_table(doc, table_md_lines):
    """Chuyển đổi bảng Markdown thành bảng Word chuyên nghiệp."""
    rows_data = []
    alignments = []

    for line in table_md_lines:
        line = line.strip()
        if not line or not line.startswith('|'):
            continue
        cells = [c.strip() for c in line.split('|')[1:-1]]

        # Nhận diện dòng phân cách căn lề
        if all(re.match(r'^:?-+:?$', c) for c in cells):
            for c in cells:
                if c.startswith(':') and c.endswith(':'):
                    alignments.append(WD_ALIGN_PARAGRAPH.CENTER)
                elif c.endswith(':'):
                    alignments.append(WD_ALIGN_PARAGRAPH.RIGHT)
                else:
                    alignments.append(WD_ALIGN_PARAGRAPH.LEFT)
            continue
        rows_data.append(cells)

    if not rows_data:
        return

    num_cols = len(rows_data[0])
    table = doc.add_table(rows=len(rows_data), cols=num_cols)
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    set_table_borders(table)

    col_widths = [Cm(15.5 / num_cols)] * num_cols
    if num_cols == 2:
        col_widths = [Cm(5.0), Cm(10.5)]
    elif num_cols == 3:
        col_widths = [Cm(2.2), Cm(6.5), Cm(6.8)]
    elif num_cols == 4:
        col_widths = [Cm(1.5), Cm(6.0), Cm(4.0), Cm(4.0)]
    elif num_cols == 5:
        col_widths = [Cm(1.2), Cm(4.3), Cm(4.0), Cm(3.0), Cm(3.0)]

    for row_idx, row in enumerate(table.rows):
        row._tr.get_or_add_trPr().append(parse_xml(f'<w:cantSplit {nsdecls("w")}/>'))
        is_header = (row_idx == 0)
        if is_header:
            row._tr.get_or_add_trPr().append(parse_xml(f'<w:tblHeader {nsdecls("w")}/>'))

        data_cells = rows_data[row_idx] if row_idx < len(rows_data) else []
        for col_idx, cell in enumerate(row.cells):
            cell.width = col_widths[col_idx] if col_idx < len(col_widths) else Cm(2.0)
            cell.vertical_alignment = WD_ALIGN_VERTICAL.CENTER
            set_cell_margins(cell, top=100, bottom=100, left=130, right=130)

            p = cell.paragraphs[0]
            p.paragraph_format.first_line_indent = Inches(0)
            set_paragraph_spacing(p, before=2, after=2, line_spacing=1.15)

            if col_idx < len(alignments):
                p.alignment = alignments[col_idx]
            if is_header:
                p.alignment = WD_ALIGN_PARAGRAPH.CENTER
                set_cell_shading(cell, COLOR_HEADER_BG)
            elif row_idx % 2 == 1:
                set_cell_shading(cell, "FFFFFF")
            else:
                set_cell_shading(cell, COLOR_ZEBRA_BG)

            cell_text = data_cells[col_idx] if col_idx < len(data_cells) else ""
            if is_header:
                add_formatted_text(p, cell_text, default_color=RGBColor(255, 255, 255), default_size=Pt(11.5))
                for r in p.runs:
                    r.bold = True
            else:
                add_formatted_text(p, cell_text, default_size=Pt(11.5), default_color=COLOR_BODY)

    p_spacer = doc.add_paragraph()
    set_paragraph_spacing(p_spacer, before=0, after=6, line_spacing=1.0)
    p_spacer.paragraph_format.first_line_indent = Inches(0)

# --- CẤU HÌNH MỤC LỤC & ĐIỀU HƯỚNG TƯƠNG TÁC (HYPERLINK + PAGEREF) ---

TOC_ITEMS = [
    # (level, title, bm_id, bm_name, page_default, is_bold)
    (1, "Lời cảm ơn", 101, "bm_loicamon", "i", False),
    (1, "Phiếu đánh giá của đơn vị thực tập", 102, "bm_danhgiacq", "ii", False),
    (1, "Phiếu đánh giá của giảng viên hướng dẫn", 103, "bm_danhgiagv", "iii", False),
    (1, "Mục lục", 104, "bm_mucluc", "iv", False),
    (1, "Danh mục các từ viết tắt", 105, "bm_viettat", "vi", False),
    (1, "Danh mục bảng biểu", 106, "bm_bangbieu", "vii", False),
    (1, "Danh mục hình ảnh", 107, "bm_hinhanh", "viii", False),
    (1, "PHẦN MỞ ĐẦU", 108, "bm_modau", "1", True),
    (2, "1. Lý do chọn đề tài", 109, "bm_m1", "1", False),
    (2, "2. Mục tiêu của đề tài", 110, "bm_m2", "2", False),
    (2, "3. Đối tượng và phạm vi nghiên cứu", 111, "bm_m3", "2", False),
    (2, "4. Phương pháp thực hiện", 112, "bm_m4", "3", False),
    (2, "5. Bố cục của báo cáo", 113, "bm_m5", "3", False),
    (1, "CHƯƠNG 1. TỔNG QUAN VỀ ĐƠN VỊ THỰC TẬP", 114, "bm_c1", "4", True),
    (2, "1.1. Trường Đại học Đà Lạt", 115, "bm_c1_1", "4", False),
    (2, "1.2. Khoa Công nghệ Thông tin", 116, "bm_c1_2", "5", False),
    (2, "1.3. Trung tâm Công nghệ thông tin (ITC)", 117, "bm_c1_3", "5", False),
    (2, "1.4. Hiện trạng tiếp nhận sự cố CNTT của Trường", 118, "bm_c1_4", "6", False),
    (3, "1.4.1. Ba mâu thuẫn", 119, "bm_c1_4_1", "6", False),
    (3, "1.4.2. Hệ quả của kênh phi cấu trúc", 120, "bm_c1_4_2", "7", False),
    (3, "1.4.3. PineDesk đáp ứng gì", 121, "bm_c1_4_3", "7", False),
    (3, "1.4.4. Vì sao không dùng công cụ sẵn có", 122, "bm_c1_4_4", "8", False),
    (1, "CHƯƠNG 2. CƠ SỞ LÝ THUYẾT VÀ CÔNG NGHỆ SỬ DỤNG", 123, "bm_c2", "9", True),
    (2, "2.1. ITSM và ITIL", 124, "bm_c2_1", "9", False),
    (2, "2.2. GLPI", 125, "bm_c2_2", "9", False),
    (2, "2.3. Container hóa với Docker và Docker Compose", 126, "bm_c2_3", "10", False),
    (2, "2.4. Cổng giao tiếp Nginx Gateway và SSL/TLS", 127, "bm_c2_4", "11", False),
    (2, "2.5. Công cụ hỗ trợ phát triển", 128, "bm_c2_5", "11", False),
    (1, "CHƯƠNG 3. PHÂN TÍCH VÀ THIẾT KẾ HỆ THỐNG", 129, "bm_c3", "13", True),
    (2, "3.1. Phân tích yêu cầu", 130, "bm_c3_1", "13", False),
    (2, "3.2. Kiến trúc tổng thể", 131, "bm_c3_2", "16", False),
    (2, "3.3. Nguyên tắc thiết kế: tùy biến nằm ngoài lõi", 132, "bm_c3_3", "17", False),
    (2, "3.4. Hệ thống thiết kế giao diện: Apple Precision, Claude Warmth và Bản sắc Đà Lạt", 133, "bm_c3_4", "18", False),
    (2, "3.5. Cấu trúc mã nguồn", 134, "bm_c3_5", "19", False),
    (2, "3.6. Bảng đối chiếu đóng góp kỹ thuật so với GLPI 11 gốc", 135, "bm_c3_6", "20", False),
    (1, "CHƯƠNG 4. TRIỂN KHAI VÀ KIỂM THỬ", 136, "bm_c4", "22", True),
    (2, "4.1. Kế hoạch và tiến độ thực hiện 10 tuần thực tập", 137, "bm_c4_1", "22", False),
    (3, "4.1.1. Kế hoạch thực hiện theo 10 tuần", 138, "bm_c4_1_1", "22", False),
    (3, "4.1.2. Các giai đoạn phát triển và mốc phát hành phiên bản", 139, "bm_c4_1_2", "25", False),
    (2, "4.2. Các chức năng đã triển khai trên thực tế", 140, "bm_c4_2", "26", False),
    (3, "4.2.1. Quản lý tài sản phòng máy", 141, "bm_c4_2_1", "26", False),
    (3, "4.2.2. Tiếp nhận và xử lý phiếu sự cố", 142, "bm_c4_2_2", "27", False),
    (3, "4.2.3. Mức thời gian đề xuất (SLA)", 143, "bm_c4_2_3", "29", False),
    (3, "4.2.4. Mã QR cho thiết bị", 144, "bm_c4_2_4", "30", False),
    (3, "4.2.5. Chống lạm dụng nộp phiếu", 145, "bm_c4_2_5", "31", False),
    (3, "4.2.6. Việt hóa", 146, "bm_c4_2_6", "33", False),
    (3, "4.2.7. Giao diện", 147, "bm_c4_2_7", "33", False),
    (3, "4.2.8. Tự động hóa cài đặt", 148, "bm_c4_2_8", "34", False),
    (2, "4.3. Kiểm thử và kết quả", 149, "bm_c4_3", "34", False),
    (3, "4.3.1. Cách kiểm thử", 150, "bm_c4_3_1", "34", False),
    (3, "4.3.2. Kết quả kiểm tra chức năng theo vai trò", 151, "bm_c4_3_2", "34", False),
    (3, "4.3.3. Kết quả kiểm tra chống lạm dụng", 152, "bm_c4_3_3", "35", False),
    (3, "4.3.4. Pipeline kiểm tra tự động", 153, "bm_c4_3_4", "36", False),
    (3, "4.3.5. Lỗi đã tìm ra và sửa", 154, "bm_c4_3_5", "37", False),
    (3, "4.3.6. Rà soát chất lượng sau khi hoàn thiện", 155, "bm_c4_3_6", "37", False),
    (3, "4.3.7. Đo tải định lượng hệ thống bằng wrk", 156, "bm_c4_3_7", "39", False),
    (1, "CHƯƠNG 5. ĐÁNH GIÁ, HẠN CHẾ VÀ HƯỚNG PHÁT TRIỂN", 157, "bm_c5", "40", True),
    (2, "5.1. Kết quả đạt được", 158, "bm_c5_1", "40", False),
    (2, "5.2. Hạn chế của đề tài", 159, "bm_c5_2", "41", False),
    (2, "5.3. Hướng phát triển", 160, "bm_c5_3", "42", False),
    (2, "5.4. Bài học kinh nghiệm", 161, "bm_c5_4", "43", False),
    (1, "KẾT LUẬN VÀ KIẾN NGHỊ", 162, "bm_ketluan", "44", True),
    (2, "Kết luận", 163, "bm_kl_ketluan", "44", False),
    (2, "Kiến nghị", 164, "bm_kl_kiennghi", "45", False),
    (1, "TÀI LIỆU THAM KHẢO", 165, "bm_tailieu", "46", True),
    (2, "A. Văn bản pháp lý và số liệu khảo sát thực tế", 166, "bm_tl_a", "46", False),
    (2, "B. Tiêu chuẩn ngành và tài liệu kỹ thuật quốc tế", 167, "bm_tl_b", "46", False),
    (2, "C. Hồ sơ kỹ thuật của đề tài PineDesk", 168, "bm_tl_c", "47", False),
    (1, "PHỤ LỤC", 169, "bm_phuluc", "48", True),
    (2, "Phụ lục A. Bảng thông số kỹ thuật 10 phòng máy thực tế Trung tâm CNTT", 170, "bm_pl_a", "48", False),
    (2, "Phụ lục B. Tài khoản thử nghiệm và phân quyền vai trò", 171, "bm_pl_b", "50", False),
    (2, "Phụ lục C. Hướng dẫn cài đặt và vận hành hệ thống một lệnh", 172, "bm_pl_c", "51", False),
    (2, "Phụ lục D. Danh mục 18 ảnh minh chứng giao diện", 173, "bm_pl_d", "52", False),
    (2, "Phụ lục E. Kế hoạch chi tiết 10 tuần thực tập tốt nghiệp", 174, "bm_pl_e", "54", False),
    (2, "Phụ lục F. Bộ câu hỏi và trả lời phản biện chuyên sâu trước Hội đồng", 175, "bm_pl_f", "56", False),
]

TABLES_DATA = [
    ("Bảng 2.1", "Bốn dịch vụ container trong hệ thống", 201, "bm_tbl_2_1", "10"),
    ("Bảng 3.1", "Ba mâu thuẫn nghiệp vụ và dữ kiện khảo sát thực tế", 202, "bm_tbl_3_1", "14"),
    ("Bảng 3.2", "Hệ màu bản sắc Đà Lạt kết hợp phong cách Apple Precision và Claude Warmth", 203, "bm_tbl_3_2", "18"),
    ("Bảng 3.3", "Phân bố mã nguồn dự án theo phân loại ngôn ngữ", 204, "bm_tbl_3_3", "19"),
    ("Bảng 3.4", "Đối chiếu 20 đóng góp kỹ thuật của PineDesk so với GLPI 11 nguyên bản", 205, "bm_tbl_3_4", "20"),
    ("Bảng 4.1", "Kế hoạch và tiến độ thực hiện 10 tuần thực tập tốt nghiệp", 206, "bm_tbl_4_1", "22"),
    ("Bảng 4.2", "Thống kê cơ sở vật chất 10 phòng máy tính thực tế do Trung tâm CNTT quản lý", 207, "bm_tbl_4_2", "26"),
    ("Bảng 4.3", "Phân bố phiếu sự cố mẫu theo trạng thái chuẩn ITIL", 208, "bm_tbl_4_3", "28"),
    ("Bảng 4.4", "Năm mức thời gian phản hồi và xử lý đề xuất (SLA kỹ thuật)", 209, "bm_tbl_4_4", "29"),
    ("Bảng 4.5", "Sáu tầng phòng thủ chống lạm dụng nộp phiếu sự cố", 210, "bm_tbl_4_5", "30"),
    ("Bảng 4.6", "Các tham số hạn mức nghiệp vụ chống spam", 211, "bm_tbl_4_6", "31"),
    ("Bảng 4.7", "Kết quả kiểm thử chức năng theo vai trò người dùng", 212, "bm_tbl_4_7", "34"),
    ("Bảng 4.8", "Sáu nhóm kiểm tra tự động trong pipeline CI", 213, "bm_tbl_4_8", "36"),
    ("Bảng 4.9", "Mười ba vấn đề phát hiện khi rà soát chất lượng và giải pháp xử lý", 214, "bm_tbl_4_9", "37"),
    ("Bảng 4.10", "Kết quả kiểm chứng toàn diện sau đợt rà soát chất lượng", 215, "bm_tbl_4_10", "38"),
    ("Bảng 4.11", "Kết quả đo tải định lượng hệ thống bằng công cụ wrk", 216, "bm_tbl_4_11", "39"),
    ("Bảng 5.1", "Tổng hợp các hạn chế còn tồn tại của đề tài", 217, "bm_tbl_5_1", "41"),
]

FIGURES_DATA = [
    ("Hình 3.1", "Kiến trúc tổng thể hệ thống PineDesk", 301, "bm_fig_3_1", "16"),
    ("Hình 3.2", "Cây thư mục tổ chức mã nguồn và tài liệu", 302, "bm_fig_3_2", "19"),
    ("Hình 4.1", "Giao diện trang đăng nhập hệ thống PineDesk", 303, "bm_fig_4_1", "26"),
    ("Hình 4.2", "Bảng điều khiển trung tâm dành cho kỹ thuật viên", 304, "bm_fig_4_2", "27"),
    ("Hình 4.3", "Danh mục quản lý 482 máy tính phòng thực hành", 305, "bm_fig_4_3", "27"),
    ("Hình 4.4", "Danh mục quản lý 487 màn hình LCD và Smart Tivi", 306, "bm_fig_4_4", "28"),
    ("Hình 4.5", "Danh mục quản lý thiết bị mạng và tủ rack", 307, "bm_fig_4_5", "28"),
    ("Hình 4.6", "Danh mục quản lý máy in laser Canon LBP2900", 308, "bm_fig_4_6", "29"),
    ("Hình 4.7", "Danh mục quản lý phần mềm bản quyền", 309, "bm_fig_4_7", "29"),
    ("Hình 4.8", "Danh sách phiếu sự cố theo dõi theo trạng thái ITIL", 310, "bm_fig_4_8", "30"),
    ("Hình 4.9", "Biểu mẫu tiếp nhận và tạo phiếu sự cố mới", 311, "bm_fig_4_9", "31"),
    ("Hình 4.10", "Giao diện thêm mới thiết bị vào cơ sở dữ liệu tài sản", 312, "bm_fig_4_10", "32"),
    ("Hình 4.11", "Danh mục cơ cấu tổ chức 16 khoa và phòng ban DLU", 313, "bm_fig_4_11", "32"),
    ("Hình 4.12", "Chi tiết hồ sơ quản lý một thiết bị máy tính", 314, "bm_fig_4_12", "33"),
    ("Hình 4.13", "Danh sách tài khoản người dùng theo vai trò", 315, "bm_fig_4_13", "33"),
    ("Hình 4.14", "Menu các hành động quản lý hàng loạt", 316, "bm_fig_4_14", "34"),
    ("Hình 4.15", "Giao diện cấu hình nhãn in mã QR", 317, "bm_fig_4_15", "34"),
    ("Hình 4.16", "Thẻ mã QR định danh in trên hồ sơ thiết bị", 318, "bm_fig_4_16", "35"),
    ("Hình 4.17", "Kết quả sinh mã QR thiết bị hàng loạt", 319, "bm_fig_4_17", "35"),
    ("Hình 4.18", "Bảng thống kê toàn cầu tình hình tài sản và sự cố", 320, "bm_fig_4_18", "36"),
]

def normalize_title(t):
    return re.sub(r'\s+', ' ', t.replace('**', '')).strip().upper()

HEADING_LOOKUP = {}
for lvl, title, bmid, bmname, pg, bold in TOC_ITEMS:
    k = normalize_title(title)
    HEADING_LOOKUP[k] = (lvl, bmid, bmname)

TABLE_LOOKUP = {t[0]: (t[2], t[3]) for t in TABLES_DATA}
FIGURE_LOOKUP = {f[0]: (f[2], f[3]) for f in FIGURES_DATA}

def render_interactive_toc(doc, toc_items):
    """
    Tạo mục lục tương tác học thuật chuyên nghiệp chuẩn Microsoft Word.
    Mỗi dòng gồm tiêu đề, tab dẫn dấu chấm (. . .) và trường số trang PAGEREF tự động.
    Được bọc trong thẻ <w:hyperlink> cho phép nhấn giữ Ctrl và nhấp chuột nhảy ngay tới trang đích!
    """
    p_note = doc.add_paragraph()
    p_note.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_note.paragraph_format.first_line_indent = Inches(0)
    set_paragraph_spacing(p_note, before=2, after=14, line_spacing=1.15)
    r_note = p_note.add_run("*(Nhấn giữ Ctrl và nhấp chuột hoặc nhấp chuột vào mục bất kỳ để chuyển nhanh đến trang tương ứng)*")
    r_note.font.name = "Times New Roman"
    r_note.font.size = Pt(10)
    r_note.font.italic = True
    r_note.font.color.rgb = COLOR_MUTED

    for level, title, bm_id, bm_name, page_def, is_bold in toc_items:
        p = doc.add_paragraph()
        pPr = p._p.get_or_add_pPr()
        pPr.append(parse_xml(f'<w:tabs {nsdecls("w")}><w:tab w:val="right" w:leader="dot" w:pos="8790"/></w:tabs>'))

        if level == 1:
            p.paragraph_format.left_indent = Inches(0)
            p.paragraph_format.first_line_indent = Inches(0)
            set_paragraph_spacing(p, before=4, after=2, line_spacing=1.15)
            sz_val = "24"      # 12pt
            color_hex = "1B365D" # Navy
        elif level == 2:
            p.paragraph_format.left_indent = Cm(0.6)
            p.paragraph_format.first_line_indent = Inches(0)
            set_paragraph_spacing(p, before=1.5, after=1.5, line_spacing=1.15)
            sz_val = "23"      # 11.5pt
            color_hex = "2C3E50" # Dark slate
        else:
            p.paragraph_format.left_indent = Cm(1.1)
            p.paragraph_format.first_line_indent = Inches(0)
            set_paragraph_spacing(p, before=1, after=1, line_spacing=1.15)
            sz_val = "22"      # 11pt
            color_hex = "4B5563" # Muted gray

        bold_xml = "<w:b/>" if is_bold else ""
        escaped_title = title.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')

        hl_xml = (
            f'<w:hyperlink {nsdecls("w")} w:anchor="{bm_name}" w:history="1">'
            f'<w:r><w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman"/>'
            f'{bold_xml}<w:sz w:val="{sz_val}"/><w:color w:val="{color_hex}"/><w:u w:val="none"/></w:rPr>'
            f'<w:t>{escaped_title}</w:t></w:r>'
            f'<w:r><w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman"/>'
            f'<w:sz w:val="{sz_val}"/><w:color w:val="737373"/><w:u w:val="none"/></w:rPr><w:tab/></w:r>'
            f'<w:fldSimple {nsdecls("w")} w:instr="PAGEREF {bm_name} \\h">'
            f'<w:r><w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman"/>'
            f'{bold_xml}<w:sz w:val="{sz_val}"/><w:color w:val="{color_hex}"/><w:u w:val="none"/></w:rPr>'
            f'<w:t>{page_def}</w:t></w:r>'
            f'</w:fldSimple>'
            f'</w:hyperlink>'
        )
        p._p.append(parse_xml(hl_xml))

    p_spacer = doc.add_paragraph()
    set_paragraph_spacing(p_spacer, before=0, after=6, line_spacing=1.0)
    p_spacer.paragraph_format.first_line_indent = Inches(0)

def render_interactive_list(doc, items, kind="tbl"):
    """
    Tạo danh mục bảng hoặc hình ảnh tương tác có dot leader và hyperlink điều hướng.
    """
    p_note = doc.add_paragraph()
    p_note.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_note.paragraph_format.first_line_indent = Inches(0)
    set_paragraph_spacing(p_note, before=2, after=12, line_spacing=1.15)
    entity_name = "bảng" if kind == "tbl" else "hình ảnh"
    r_note = p_note.add_run(f"*(Nhấn giữ Ctrl và nhấp chuột vào {entity_name} bất kỳ để chuyển nhanh đến vị trí tương ứng)*")
    r_note.font.name = "Times New Roman"
    r_note.font.size = Pt(10)
    r_note.font.italic = True
    r_note.font.color.rgb = COLOR_MUTED

    for code, title, bm_id, bm_name, page_def in items:
        p = doc.add_paragraph()
        pPr = p._p.get_or_add_pPr()
        pPr.append(parse_xml(f'<w:tabs {nsdecls("w")}><w:tab w:val="right" w:leader="dot" w:pos="8790"/></w:tabs>'))
        set_paragraph_spacing(p, before=2, after=2, line_spacing=1.15)
        p.paragraph_format.left_indent = Inches(0)

        escaped_code = code.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
        escaped_title = title.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')

        hl_xml = (
            f'<w:hyperlink {nsdecls("w")} w:anchor="{bm_name}" w:history="1">'
            f'<w:r><w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman"/>'
            f'<w:b/><w:sz w:val="23"/><w:color w:val="1B365D"/><w:u w:val="none"/></w:rPr>'
            f'<w:t>{escaped_code}: </w:t></w:r>'
            f'<w:r><w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman"/>'
            f'<w:sz w:val="23"/><w:color w:val="2C3E50"/><w:u w:val="none"/></w:rPr>'
            f'<w:t>{escaped_title}</w:t></w:r>'
            f'<w:r><w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman"/>'
            f'<w:sz w:val="23"/><w:color w:val="737373"/><w:u w:val="none"/></w:rPr><w:tab/></w:r>'
            f'<w:fldSimple {nsdecls("w")} w:instr="PAGEREF {bm_name} \\h">'
            f'<w:r><w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman"/>'
            f'<w:sz w:val="23"/><w:color w:val="2C3E50"/><w:u w:val="none"/></w:rPr>'
            f'<w:t>{page_def}</w:t></w:r>'
            f'</w:fldSimple>'
            f'</w:hyperlink>'
        )
        p._p.append(parse_xml(hl_xml))

    p_spacer = doc.add_paragraph()
    set_paragraph_spacing(p_spacer, before=0, after=6, line_spacing=1.0)
    p_spacer.paragraph_format.first_line_indent = Inches(0)

def embed_screenshot_with_caption(doc, img_filename, caption_text, width_cm=14.5):
    """Chèn ảnh chụp thực tế vào tài liệu Word kèm chú thích chuẩn và bookmark điều hướng."""
    img_path = os.path.join(IMG_DIR, img_filename)
    if not os.path.exists(img_path):
        print(f"  [CANH BAO] Khong tim thay anh: {img_path}")
        return

    p_img = doc.add_paragraph()
    p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_img.paragraph_format.first_line_indent = Inches(0)
    set_paragraph_spacing(p_img, before=6, after=4, line_spacing=1.0)
    run_img = p_img.add_run()
    run_img.add_picture(img_path, width=Cm(width_cm))

    p_cap = doc.add_paragraph()
    p_cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_cap.paragraph_format.first_line_indent = Inches(0)
    set_paragraph_spacing(p_cap, before=2, after=8, line_spacing=1.1)

    # Gắn bookmark cho hình ảnh nếu có trong danh mục
    m_fig = re.search(r'Hình\s+(\d+\.\d+)', caption_text)
    bm_id, bm_name = None, None
    if m_fig:
        code_key = f"Hình {m_fig.group(1)}"
        if code_key in FIGURE_LOOKUP:
            bm_id, bm_name = FIGURE_LOOKUP[code_key]
            bm_start = parse_xml(f'<w:bookmarkStart {nsdecls("w")} w:id="{bm_id}" w:name="{bm_name}"/>')
            p_cap._p.append(bm_start)

    r_cap = p_cap.add_run(caption_text)
    r_cap.font.name = "Times New Roman"
    r_cap.font.size = Pt(11)
    r_cap.font.italic = True
    r_cap.font.color.rgb = COLOR_DARK

    if bm_id is not None:
        bm_end = parse_xml(f'<w:bookmarkEnd {nsdecls("w")} w:id="{bm_id}"/>')
        p_cap._p.append(bm_end)

def build_cover_page(doc):
    """Tạo trang bìa chính (Section 0) với khung viền đôi học thuật DLU."""
    sec = doc.sections[0]
    setup_page_geometry(sec)
    sec.header.is_linked_to_previous = False
    sec.footer.is_linked_to_previous = False
    clear_hf(sec.header)
    clear_hf(sec.footer)

    pgBorders = parse_xml(
        f'<w:pgBorders {nsdecls("w")} w:offsetFrom="page">'
        f'<w:top w:val="double" w:sz="24" w:space="24" w:color="1B365D"/>'
        f'<w:left w:val="double" w:sz="24" w:space="24" w:color="1B365D"/>'
        f'<w:bottom w:val="double" w:sz="24" w:space="24" w:color="1B365D"/>'
        f'<w:right w:val="double" w:sz="24" w:space="24" w:color="1B365D"/>'
        f'</w:pgBorders>'
    )
    sec._sectPr.append(pgBorders)

    p1 = doc.add_paragraph()
    p1.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p1.paragraph_format.first_line_indent = Inches(0)
    set_paragraph_spacing(p1, before=0, after=2, line_spacing=1.15)
    r1 = p1.add_run("BỘ GIÁO DỤC VÀ ĐÀO TẠO")
    r1.font.name = "Times New Roman"
    r1.font.size = Pt(13)
    r1.font.color.rgb = COLOR_BODY

    p2 = doc.add_paragraph()
    p2.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p2.paragraph_format.first_line_indent = Inches(0)
    set_paragraph_spacing(p2, before=2, after=2, line_spacing=1.15)
    r2 = p2.add_run("TRƯỜNG ĐẠI HỌC ĐÀ LẠT")
    r2.font.name = "Times New Roman"
    r2.font.size = Pt(14)
    r2.bold = True
    r2.font.color.rgb = COLOR_NAVY

    p3 = doc.add_paragraph()
    p3.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p3.paragraph_format.first_line_indent = Inches(0)
    set_paragraph_spacing(p3, before=2, after=12, line_spacing=1.15)
    r3 = p3.add_run("KHOA CÔNG NGHỆ THÔNG TIN")
    r3.font.name = "Times New Roman"
    r3.font.size = Pt(14)
    r3.bold = True
    r3.font.color.rgb = COLOR_NAVY

    p_line = doc.add_paragraph()
    p_line.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_line.paragraph_format.first_line_indent = Inches(0)
    set_paragraph_spacing(p_line, before=0, after=14, line_spacing=1.0)
    r_line = p_line.add_run("━━━━━━━ ★ ━━━━━━━")
    r_line.font.name = "Times New Roman"
    r_line.font.size = Pt(11)
    r_line.font.color.rgb = COLOR_PINE

    if os.path.exists(LOGO_PATH):
        p_logo = doc.add_paragraph()
        p_logo.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_logo.paragraph_format.first_line_indent = Inches(0)
        set_paragraph_spacing(p_logo, before=4, after=16, line_spacing=1.0)
        r_logo = p_logo.add_run()
        r_logo.add_picture(LOGO_PATH, width=Cm(4.2))

    p_bc = doc.add_paragraph()
    p_bc.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_bc.paragraph_format.first_line_indent = Inches(0)
    set_paragraph_spacing(p_bc, before=10, after=4, line_spacing=1.2)
    r_bc = p_bc.add_run("BÁO CÁO THỰC TẬP TỐT NGHIỆP")
    r_bc.font.name = "Times New Roman"
    r_bc.font.size = Pt(18)
    r_bc.bold = True
    r_bc.font.color.rgb = COLOR_NAVY

    p_cn = doc.add_paragraph()
    p_cn.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_cn.paragraph_format.first_line_indent = Inches(0)
    set_paragraph_spacing(p_cn, before=2, after=14, line_spacing=1.15)
    r_cn = p_cn.add_run("CHUYÊN NGÀNH: KỸ THUẬT PHẦN MỀM")
    r_cn.font.name = "Times New Roman"
    r_cn.font.size = Pt(13.5)
    r_cn.bold = True
    r_cn.font.color.rgb = COLOR_PINE

    p_dt_lbl = doc.add_paragraph()
    p_dt_lbl.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_dt_lbl.paragraph_format.first_line_indent = Inches(0)
    set_paragraph_spacing(p_dt_lbl, before=6, after=4, line_spacing=1.15)
    r_dt_lbl = p_dt_lbl.add_run("ĐỀ TÀI:")
    r_dt_lbl.font.name = "Times New Roman"
    r_dt_lbl.font.size = Pt(13)
    r_dt_lbl.bold = True
    r_dt_lbl.font.color.rgb = COLOR_BODY

    p_title = doc.add_paragraph()
    p_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_title.paragraph_format.first_line_indent = Inches(0)
    set_paragraph_spacing(p_title, before=4, after=30, line_spacing=1.25)
    r_title = p_title.add_run("XÂY DỰNG HỆ THỐNG HỖ TRỢ KỸ THUẬT (IT HELPDESK)\nCHO TRƯỜNG ĐẠI HỌC ĐÀ LẠT TRÊN NỀN TẢNG MÃ NGUỒN MỞ GLPI 11")
    r_title.font.name = "Times New Roman"
    r_title.font.size = Pt(15.5)
    r_title.bold = True
    r_title.font.color.rgb = COLOR_NAVY

    info_table = doc.add_table(rows=6, cols=2)
    info_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    for row in info_table.rows:
        row._tr.get_or_add_trPr().append(parse_xml(f'<w:cantSplit {nsdecls("w")}/>'))

    info_data = [
        ("Sinh viên thực hiện:", "PHÙNG VÕ QUỐC HIỂN"),
        ("Mã số sinh viên:", "2212364"),
        ("Lớp / Khóa học:", "CTK46-PM  —  Khóa K46 (2022 – 2026)"),
        ("Giảng viên hướng dẫn:", "ThS. LA QUỐC THẮNG"),
        ("Cán bộ hướng dẫn đơn vị:", "ThS. ĐẶNG QUỐC PHI"),
        ("Đơn vị thực tập:", "Trung tâm Công nghệ thông tin – Trường ĐH Đà Lạt"),
    ]

    col_w = [Cm(5.2), Cm(9.5)]
    for r_idx, (lbl, val) in enumerate(info_data):
        c0, c1 = info_table.rows[r_idx].cells
        c0.width, c1.width = col_w[0], col_w[1]
        set_cell_margins(c0, top=40, bottom=40, left=80, right=40)
        set_cell_margins(c1, top=40, bottom=40, left=40, right=80)

        p0 = c0.paragraphs[0]
        p0.paragraph_format.first_line_indent = Inches(0)
        set_paragraph_spacing(p0, before=1, after=1, line_spacing=1.15)
        r0 = p0.add_run(lbl)
        r0.font.name = "Times New Roman"
        r0.font.size = Pt(12.5)
        r0.font.color.rgb = COLOR_BODY

        p1 = c1.paragraphs[0]
        p1.paragraph_format.first_line_indent = Inches(0)
        set_paragraph_spacing(p1, before=1, after=1, line_spacing=1.15)
        r1 = p1.add_run(val)
        r1.font.name = "Times New Roman"
        r1.font.size = Pt(12.5)
        r1.bold = True
        r1.font.color.rgb = COLOR_NAVY if "ThS" in val or "PHÙNG" in val else COLOR_BODY

    p_loc = doc.add_paragraph()
    p_loc.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_loc.paragraph_format.first_line_indent = Inches(0)
    set_paragraph_spacing(p_loc, before=35, after=0, line_spacing=1.15)
    r_loc = p_loc.add_run("ĐÀ LẠT, THÁNG 10 NĂM 2026")
    r_loc.font.name = "Times New Roman"
    r_loc.font.size = Pt(13)
    r_loc.bold = True
    r_loc.font.color.rgb = COLOR_BODY

def build_subcover_page(doc):
    """Tạo trang bìa phụ (Section 1) không có khung viền."""
    s1 = doc.add_section()
    setup_page_geometry(s1)

    b1 = s1._sectPr.find(qn('w:pgBorders'))
    if b1 is not None:
        s1._sectPr.remove(b1)

    s1.header.is_linked_to_previous = False
    s1.footer.is_linked_to_previous = False
    clear_hf(s1.header)
    clear_hf(s1.footer)

    p1 = doc.add_paragraph()
    p1.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p1.paragraph_format.first_line_indent = Inches(0)
    set_paragraph_spacing(p1, before=10, after=2, line_spacing=1.15)
    r1 = p1.add_run("BỘ GIÁO DỤC VÀ ĐÀO TẠO\nTRƯỜNG ĐẠI HỌC ĐÀ LẠT\nKHOA CÔNG NGHỆ THÔNG TIN")
    r1.font.name = "Times New Roman"
    r1.font.size = Pt(13)
    r1.bold = True
    r1.font.color.rgb = COLOR_NAVY

    p_line = doc.add_paragraph()
    p_line.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_line.paragraph_format.first_line_indent = Inches(0)
    set_paragraph_spacing(p_line, before=4, after=30, line_spacing=1.0)
    r_line = p_line.add_run("━━━━━━━━━━━━━━━━━━━")
    r_line.font.name = "Times New Roman"
    r_line.font.size = Pt(11)
    r_line.font.color.rgb = COLOR_PINE

    p_bc = doc.add_paragraph()
    p_bc.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_bc.paragraph_format.first_line_indent = Inches(0)
    set_paragraph_spacing(p_bc, before=15, after=6, line_spacing=1.2)
    r_bc = p_bc.add_run("BÁO CÁO THỰC TẬP TỐT NGHIỆP")
    r_bc.font.name = "Times New Roman"
    r_bc.font.size = Pt(17)
    r_bc.bold = True
    r_bc.font.color.rgb = COLOR_NAVY

    p_title = doc.add_paragraph()
    p_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_title.paragraph_format.first_line_indent = Inches(0)
    set_paragraph_spacing(p_title, before=8, after=35, line_spacing=1.25)
    r_title = p_title.add_run("XÂY DỰNG HỆ THỐNG HỖ TRỢ KỸ THUẬT (IT HELPDESK)\nCHO TRƯỜNG ĐẠI HỌC ĐÀ LẠT TRÊN NỀN TẢNG MÃ NGUỒN MỞ GLPI 11")
    r_title.font.name = "Times New Roman"
    r_title.font.size = Pt(15)
    r_title.bold = True
    r_title.font.color.rgb = COLOR_DARK

    info_table = doc.add_table(rows=6, cols=2)
    info_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    info_data = [
        ("Sinh viên thực hiện:", "Phùng Võ Quốc Hiển"),
        ("Mã số sinh viên:", "2212364"),
        ("Lớp / Chuyên ngành:", "CTK46-PM — Kỹ thuật phần mềm"),
        ("Khóa đào tạo:", "Khóa 46 (2022 – 2026)"),
        ("Giảng viên hướng dẫn:", "ThS. La Quốc Thắng"),
        ("Cán bộ hướng dẫn tại đơn vị:", "ThS. Đặng Quốc Phi"),
    ]
    col_w = [Cm(5.5), Cm(9.0)]
    for r_idx, (lbl, val) in enumerate(info_data):
        c0, c1 = info_table.rows[r_idx].cells
        c0.width, c1.width = col_w[0], col_w[1]
        set_cell_margins(c0, top=50, bottom=50, left=80, right=40)
        set_cell_margins(c1, top=50, bottom=50, left=40, right=80)

        p0 = c0.paragraphs[0]
        p0.paragraph_format.first_line_indent = Inches(0)
        set_paragraph_spacing(p0, before=2, after=2, line_spacing=1.15)
        p0.add_run(lbl).font.name = "Times New Roman"

        p1 = c1.paragraphs[0]
        p1.paragraph_format.first_line_indent = Inches(0)
        set_paragraph_spacing(p1, before=2, after=2, line_spacing=1.15)
        r1 = p1.add_run(val)
        r1.font.name = "Times New Roman"
        r1.bold = True

    p_loc = doc.add_paragraph()
    p_loc.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_loc.paragraph_format.first_line_indent = Inches(0)
    set_paragraph_spacing(p_loc, before=45, after=0, line_spacing=1.15)
    r_loc = p_loc.add_run("ĐÀ LẠT, THÁNG 10 NĂM 2026")
    r_loc.font.name = "Times New Roman"
    r_loc.font.size = Pt(13)
    r_loc.bold = True

def parse_and_build_body(doc, md_text):
    """
    Phân tích Markdown của BAO-CAO-THUC-TAP.md và kết xuất toàn bộ
    vào Section 2 (Trang sơ bộ: i, ii...) và Section 3 (Thân bài: 1, 2...).
    Đồng thời nhúng toàn diện 18 ảnh minh chứng giao diện thực tế.
    """
    lines = md_text.split('\n')

    start_idx = 0
    for i, line in enumerate(lines):
        if line.strip() == "## LỜI CẢM ƠN":
            start_idx = i
            break

    # --- SECTION 2: TRANG SƠ BỘ (PRELIMINARY: i, ii, iii...) ---
    sec_prelim = doc.add_section()
    setup_page_geometry(sec_prelim)

    b2 = sec_prelim._sectPr.find(qn('w:pgBorders'))
    if b2 is not None:
        sec_prelim._sectPr.remove(b2)

    sec_prelim.footer.is_linked_to_previous = False
    sec_prelim.header.is_linked_to_previous = False
    clear_hf(sec_prelim.header)
    clear_hf(sec_prelim.footer)

    hdr_p = sec_prelim.header.paragraphs[0]
    hdr_p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    hdr_r = hdr_p.add_run("TRƯỜNG ĐẠI HỌC ĐÀ LẠT  |  KHOA CÔNG NGHỆ THÔNG TIN")
    hdr_r.font.name = "Times New Roman"
    hdr_r.font.size = Pt(9)
    hdr_r.font.italic = True
    hdr_r.font.color.rgb = COLOR_MUTED

    ftr_p = sec_prelim.footer.paragraphs[0]
    ftr_p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    ftr_r = ftr_p.add_run()
    ftr_r.font.name = "Times New Roman"
    ftr_r.font.size = Pt(10)
    ftr_r.font.color.rgb = COLOR_DARK
    add_page_number_to_run(ftr_r)

    pgNumType_prelim = parse_xml(f'<w:pgNumType {nsdecls("w")} w:fmt="lowerRoman" w:start="1"/>')
    sec_prelim._sectPr.append(pgNumType_prelim)

    current_section = "prelim"
    current_subheading = ""
    current_heading_title = ""
    i = start_idx
    n = len(lines)

    embedded_images = set()

    while i < n:
        line = lines[i]
        stripped = line.strip()

        # 1. Chuyển sang Section Thân bài chính (Mở đầu -> Kết luận & Phụ lục)
        if stripped == "# PHẦN MỞ ĐẦU":
            sec_body = doc.add_section()
            setup_page_geometry(sec_body)

            b3 = sec_body._sectPr.find(qn('w:pgBorders'))
            if b3 is not None:
                sec_body._sectPr.remove(b3)

            sec_body.footer.is_linked_to_previous = False
            sec_body.header.is_linked_to_previous = False
            clear_hf(sec_body.header)
            clear_hf(sec_body.footer)

            bhdr_p = sec_body.header.paragraphs[0]
            bhdr_p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
            bhdr_r = bhdr_p.add_run("Báo cáo thực tập tốt nghiệp: Hệ thống IT Helpdesk PineDesk")
            bhdr_r.font.name = "Times New Roman"
            bhdr_r.font.size = Pt(9)
            bhdr_r.font.italic = True
            bhdr_r.font.color.rgb = COLOR_MUTED

            bftr_p = sec_body.footer.paragraphs[0]
            bftr_p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
            bftr_r = bftr_p.add_run()
            bftr_r.font.name = "Times New Roman"
            bftr_r.font.size = Pt(10)
            bftr_r.font.color.rgb = COLOR_DARK
            add_page_number_to_run(bftr_r)

            pgNumType_body = parse_xml(f'<w:pgNumType {nsdecls("w")} w:fmt="decimal" w:start="1"/>')
            sec_body._sectPr.append(pgNumType_body)
            current_section = "body"

        # 2. Xử lý đường phân cách ngang
        if stripped == "---":
            if current_section == "prelim":
                doc.add_page_break()
            i += 1
            continue

        # 3. Bỏ qua dòng trống
        if not stripped:
            i += 1
            continue

        # 4. Heading cấp 1 (# TIÊU ĐỀ CHƯƠNG)
        if line.startswith('# '):
            title = line[2:].strip()
            current_heading_title = title
            p = doc.add_paragraph()
            p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p.paragraph_format.first_line_indent = Inches(0)
            if current_section == "body" and stripped != "# PHẦN MỞ ĐẦU":
                p.paragraph_format.page_break_before = True
            set_paragraph_spacing(p, before=18, after=14, line_spacing=1.2)

            pPr = p._p.get_or_add_pPr()
            pPr.append(parse_xml(f'<w:outlineLvl {nsdecls("w")} w:val="0"/>'))

            norm_t = normalize_title(title)
            bm_id, bm_name = None, None
            if norm_t in HEADING_LOOKUP:
                _, bm_id, bm_name = HEADING_LOOKUP[norm_t]
                bm_start = parse_xml(f'<w:bookmarkStart {nsdecls("w")} w:id="{bm_id}" w:name="{bm_name}"/>')
                p._p.append(bm_start)

            r = p.add_run(title)
            r.font.name = "Times New Roman"
            r.font.size = Pt(16)
            r.bold = True
            r.font.color.rgb = COLOR_NAVY

            if bm_id is not None:
                bm_end = parse_xml(f'<w:bookmarkEnd {nsdecls("w")} w:id="{bm_id}"/>')
                p._p.append(bm_end)

            i += 1
            continue

        # 5. Heading cấp 2 (## TIÊU ĐỀ MỤC)
        if line.startswith('## '):
            title = line[3:].strip()
            current_heading_title = title
            current_subheading = title
            p = doc.add_paragraph()
            p.paragraph_format.keep_with_next = True
            p.paragraph_format.first_line_indent = Inches(0)

            pPr = p._p.get_or_add_pPr()
            pPr.append(parse_xml(f'<w:outlineLvl {nsdecls("w")} w:val="1"/>'))

            norm_t = normalize_title(title)
            bm_id, bm_name = None, None
            if norm_t in HEADING_LOOKUP:
                _, bm_id, bm_name = HEADING_LOOKUP[norm_t]
                bm_start = parse_xml(f'<w:bookmarkStart {nsdecls("w")} w:id="{bm_id}" w:name="{bm_name}"/>')
                p._p.append(bm_start)

            if current_section == "prelim":
                p.alignment = WD_ALIGN_PARAGRAPH.CENTER
                set_paragraph_spacing(p, before=14, after=12, line_spacing=1.2)
                r = p.add_run(title)
                r.font.name = "Times New Roman"
                r.font.size = Pt(15)
                r.bold = True
                r.font.color.rgb = COLOR_NAVY
            else:
                p.alignment = WD_ALIGN_PARAGRAPH.LEFT
                set_paragraph_spacing(p, before=12, after=5, line_spacing=1.2)
                r = p.add_run(title)
                r.font.name = "Times New Roman"
                r.font.size = Pt(14)
                r.bold = True
                r.font.color.rgb = COLOR_NAVY

            if bm_id is not None:
                bm_end = parse_xml(f'<w:bookmarkEnd {nsdecls("w")} w:id="{bm_id}"/>')
                p._p.append(bm_end)

            i += 1
            continue

        # 6. Heading cấp 3 (### TIÊU ĐỀ TIỂU MỤC)
        if line.startswith('### '):
            title = line[4:].strip()
            current_heading_title = title
            current_subheading = title
            p = doc.add_paragraph()
            p.paragraph_format.keep_with_next = True
            p.paragraph_format.first_line_indent = Inches(0)
            p.alignment = WD_ALIGN_PARAGRAPH.LEFT
            set_paragraph_spacing(p, before=8, after=3, line_spacing=1.2)

            pPr = p._p.get_or_add_pPr()
            pPr.append(parse_xml(f'<w:outlineLvl {nsdecls("w")} w:val="2"/>'))

            norm_t = normalize_title(title)
            bm_id, bm_name = None, None
            if norm_t in HEADING_LOOKUP:
                _, bm_id, bm_name = HEADING_LOOKUP[norm_t]
                bm_start = parse_xml(f'<w:bookmarkStart {nsdecls("w")} w:id="{bm_id}" w:name="{bm_name}"/>')
                p._p.append(bm_start)

            r = p.add_run(title)
            r.font.name = "Times New Roman"
            r.font.size = Pt(13)
            r.bold = True
            r.font.color.rgb = COLOR_DARK

            if bm_id is not None:
                bm_end = parse_xml(f'<w:bookmarkEnd {nsdecls("w")} w:id="{bm_id}"/>')
                p._p.append(bm_end)

            i += 1
            continue

        # 7. Heading cấp 4 (#### TIÊU ĐỀ NHỎ)
        if line.startswith('#### '):
            title = line[5:].strip()
            current_heading_title = title
            p = doc.add_paragraph()
            p.paragraph_format.keep_with_next = True
            p.paragraph_format.first_line_indent = Inches(0)
            p.alignment = WD_ALIGN_PARAGRAPH.LEFT
            set_paragraph_spacing(p, before=6, after=2, line_spacing=1.2)

            pPr = p._p.get_or_add_pPr()
            pPr.append(parse_xml(f'<w:outlineLvl {nsdecls("w")} w:val="3"/>'))

            r = p.add_run(title)
            r.font.name = "Times New Roman"
            r.font.size = Pt(13)
            r.bold = True
            r.font.italic = True
            r.font.color.rgb = COLOR_DARK
            i += 1
            continue

        # 8. Bảng biểu (Markdown Table)
        if stripped.startswith('|'):
            table_lines = []
            while i < n and lines[i].strip().startswith('|'):
                table_lines.append(lines[i])
                i += 1

            norm_sec = normalize_title(current_heading_title)
            if "MỤC LỤC" in norm_sec:
                render_interactive_toc(doc, TOC_ITEMS)
                continue
            elif "DANH MỤC BẢNG BIỂU" in norm_sec:
                render_interactive_list(doc, TABLES_DATA, "tbl")
                continue
            elif "DANH MỤC HÌNH ẢNH" in norm_sec:
                render_interactive_list(doc, FIGURES_DATA, "fig")
                continue

            render_markdown_table(doc, table_lines)

            # Sau một số bảng đặc thù, chèn các ảnh liên quan
            check_and_embed_images_after_table(doc, current_subheading, table_lines, embedded_images)
            continue

        # 9. Callout / Blockquote (> Trích dẫn)
        if stripped.startswith('>'):
            quote_lines = []
            while i < n and (lines[i].strip().startswith('>') or (lines[i].strip() and not lines[i].startswith('#') and not lines[i].startswith('|'))):
                qline = lines[i].strip()
                if qline.startswith('>'):
                    qline = qline[1:].strip()
                quote_lines.append(qline)
                i += 1
                if i < n and not lines[i].strip():
                    break
            create_callout_box(doc, quote_lines)
            continue

        # 10. Khối mã nguồn (```code```)
        if stripped.startswith('```'):
            code_lines = []
            i += 1
            while i < n and not lines[i].strip().startswith('```'):
                code_lines.append(lines[i])
                i += 1
            i += 1
            create_code_block(doc, code_lines)
            continue

        # 11. Danh sách không thứ tự (- hoặc *)
        if re.match(r'^[\-\*]\s+', stripped):
            item_text = re.sub(r'^[\-\*]\s+', '', stripped)
            p = doc.add_paragraph()
            p.paragraph_format.left_indent = Cm(1.2)
            p.paragraph_format.first_line_indent = Cm(-0.5)
            set_paragraph_spacing(p, before=1, after=3, line_spacing=1.25)
            r_bullet = p.add_run("•  ")
            r_bullet.font.name = "Times New Roman"
            r_bullet.font.size = Pt(12)
            r_bullet.bold = True
            r_bullet.font.color.rgb = COLOR_PINE
            add_formatted_text(p, item_text, default_size=Pt(13), default_color=COLOR_BODY)
            i += 1
            continue

        # 12. Danh sách có thứ tự (1. hoặc [1])
        if re.match(r'^\d+\.\s+', stripped) or re.match(r'^\[\d+\]\s+', stripped):
            p = doc.add_paragraph()
            p.paragraph_format.left_indent = Cm(1.2)
            p.paragraph_format.first_line_indent = Cm(-0.6)
            set_paragraph_spacing(p, before=2, after=4, line_spacing=1.25)

            m = re.match(r'^(\d+\.|\[\d+\])\s+(.*)', stripped)
            if m:
                num_part, content_part = m.group(1), m.group(2)
                r_num = p.add_run(num_part + " ")
                r_num.font.name = "Times New Roman"
                r_num.font.size = Pt(13)
                r_num.bold = True
                r_num.font.color.rgb = COLOR_NAVY
                add_formatted_text(p, content_part, default_size=Pt(13), default_color=COLOR_BODY)
            else:
                add_formatted_text(p, stripped, default_size=Pt(13), default_color=COLOR_BODY)
            i += 1
            continue

        # 13. Đoạn văn thường
        # Bỏ qua dòng ghi chú hướng dẫn dưới Mục lục (đã được tạo chuẩn bên trong render_interactive_toc)
        if "MỤC LỤC" in normalize_title(current_heading_title) and ("Ctrl" in stripped or "nhấp chuột" in stripped):
            i += 1
            continue

        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
        p.paragraph_format.first_line_indent = Cm(1.0)
        set_paragraph_spacing(p, before=0, after=6, line_spacing=1.3)
        add_formatted_text(p, stripped, default_size=Pt(13), default_color=COLOR_BODY)

        # Nhận diện caption bảng biểu và hình vẽ markdown để định dạng căn giữa in nghiêng và gắn bookmark
        if (stripped.startswith('*Hình ') or stripped.startswith('*Bảng ')) and stripped.endswith('*'):
            p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p.paragraph_format.first_line_indent = Inches(0)
            set_paragraph_spacing(p, before=2, after=8, line_spacing=1.1)
            for r in p.runs:
                r.font.size = Pt(11)
                r.font.italic = True
                r.font.color.rgb = COLOR_DARK

            m_fig = re.search(r'Hình\s+(\d+\.\d+)', stripped)
            if m_fig:
                code_key = f"Hình {m_fig.group(1)}"
                if code_key in FIGURE_LOOKUP:
                    f_id, f_bm = FIGURE_LOOKUP[code_key]
                    bm_start = parse_xml(f'<w:bookmarkStart {nsdecls("w")} w:id="{f_id}" w:name="{f_bm}"/>')
                    bm_end = parse_xml(f'<w:bookmarkEnd {nsdecls("w")} w:id="{f_id}"/>')
                    p._p.append(bm_start)
                    p._p.append(bm_end)

            m_tbl = re.search(r'Bảng\s+(\d+\.\d+)', stripped)
            if m_tbl:
                code_key = f"Bảng {m_tbl.group(1)}"
                if code_key in TABLE_LOOKUP:
                    t_id, t_bm = TABLE_LOOKUP[code_key]
                    bm_start = parse_xml(f'<w:bookmarkStart {nsdecls("w")} w:id="{t_id}" w:name="{t_bm}"/>')
                    bm_end = parse_xml(f'<w:bookmarkEnd {nsdecls("w")} w:id="{t_id}"/>')
                    p._p.append(bm_start)
                    p._p.append(bm_end)

        # Chèn ảnh dựa trên từ khóa trong đoạn văn
        check_and_embed_images_in_body(doc, current_subheading, stripped, embedded_images)
        i += 1

def check_and_embed_images_after_table(doc, subheading, table_lines, embedded_set):
    """Chèn các ảnh tương ứng ngay sau bảng số liệu liên quan."""
    sh_lower = subheading.lower()

    # Bảng 4.2: Thống kê cơ sở vật chất 10 phòng máy -> Chèn ảnh danh sách máy tính, màn hình, mạng, máy in, phần mềm
    if "4.2.1" in sh_lower:
        tbl_text = " ".join(table_lines).lower()
        if "a24.1" in tbl_text and "471" in tbl_text:
            if "03-danh-sach-may-tinh.png" not in embedded_set:
                embed_screenshot_with_caption(
                    doc, "03-danh-sach-may-tinh.png",
                    "Hình 4.3: Danh mục quản lý 482 máy tính thuộc 10 phòng thực hành Trung tâm CNTT",
                    width_cm=14.5
                )
                embedded_set.add("03-danh-sach-may-tinh.png")
            if "03b-danh-sach-man-hinh.png" not in embedded_set:
                embed_screenshot_with_caption(
                    doc, "03b-danh-sach-man-hinh.png",
                    "Hình 4.4: Danh mục quản lý 487 màn hình LCD và Smart Tivi giảng dạy",
                    width_cm=14.5
                )
                embedded_set.add("03b-danh-sach-man-hinh.png")
            if "03c-thiet-bi-mang.png" not in embedded_set:
                embed_screenshot_with_caption(
                    doc, "03c-thiet-bi-mang.png",
                    "Hình 4.5: Danh mục 17 thiết bị mạng gồm Switch Cisco, Unifi AP và Tủ Rack Core",
                    width_cm=14.5
                )
                embedded_set.add("03c-thiet-bi-mang.png")
            if "03d-danh-sach-may-in.png" not in embedded_set:
                embed_screenshot_with_caption(
                    doc, "03d-danh-sach-may-in.png",
                    "Hình 4.6: Danh mục máy in laser Canon LBP2900 phục vụ in ấn nội bộ",
                    width_cm=14.5
                )
                embedded_set.add("03d-danh-sach-may-in.png")
            if "03e-danh-sach-phan-mem.png" not in embedded_set:
                embed_screenshot_with_caption(
                    doc, "03e-danh-sach-phan-mem.png",
                    "Hình 4.7: Danh mục phần mềm bản quyền cài đặt tại các phòng thực hành máy tính",
                    width_cm=14.5
                )
                embedded_set.add("03e-danh-sach-phan-mem.png")

    # Bảng 4.3: Phân bố phiếu sự cố -> Chèn ảnh danh sách phiếu và tạo phiếu
    if "4.2.2" in sh_lower:
        tbl_text = " ".join(table_lines).lower()
        if "đã giải quyết" in tbl_text and "đã đóng" in tbl_text:
            if "04-danh-sach-phieu-yeu-cau.png" not in embedded_set:
                embed_screenshot_with_caption(
                    doc, "04-danh-sach-phieu-yeu-cau.png",
                    "Hình 4.8: Danh sách phiếu sự cố phân bổ theo các trạng thái vòng đời chuẩn ITIL",
                    width_cm=14.5
                )
                embedded_set.add("04-danh-sach-phieu-yeu-cau.png")
            if "05-tao-phieu-moi.png" not in embedded_set:
                embed_screenshot_with_caption(
                    doc, "05-tao-phieu-moi.png",
                    "Hình 4.9: Biểu mẫu tiếp nhận và gửi phiếu yêu cầu hỗ trợ mới dành cho người dùng",
                    width_cm=14.5
                )
                embedded_set.add("05-tao-phieu-moi.png")

    # Bảng 4.7: Kiểm thử theo vai trò -> Chèn ảnh danh sách người dùng
    if "4.3.2" in sh_lower:
        if "08-danh-sach-nguoi-dung.png" not in embedded_set:
            embed_screenshot_with_caption(
                doc, "08-danh-sach-nguoi-dung.png",
                "Hình 4.13: Danh sách tài khoản người dùng và phân quyền theo vai trò (Super-Admin, Technician, Self-Service)",
                width_cm=14.5
            )
            embedded_set.add("08-danh-sach-nguoi-dung.png")

def check_and_embed_images_in_body(doc, subheading, text, embedded_set):
    """Chèn các ảnh chụp thực tế dựa trên nội dung phân tích trong thân bài."""
    sh_lower = subheading.lower()
    t_lower = text.lower()

    # 4.2.1 Quản lý tài sản: Thêm thiết bị, Cơ cấu tổ chức, Chi tiết thiết bị, Hành động hàng loạt
    if "4.2.1" in sh_lower:
        if "16 khoa" in t_lower and "06-nhom-co-cau-to-chuc.png" not in embedded_set:
            embed_screenshot_with_caption(
                doc, "06-nhom-co-cau-to-chuc.png",
                "Hình 4.11: Danh mục cơ cấu tổ chức 16 khoa đào tạo và các phòng ban Đại học Đà Lạt",
                width_cm=14.5
            )
            embedded_set.add("06-nhom-co-cau-to-chuc.png")

        if ("thêm mới" in t_lower or "tạo thiết bị" in t_lower) and "06-tao-thiet-bi.png" not in embedded_set:
            embed_screenshot_with_caption(
                doc, "06-tao-thiet-bi.png",
                "Hình 4.10: Giao diện thêm mới và quản lý thông số kỹ thuật thiết bị",
                width_cm=14.5
            )
            embedded_set.add("06-tao-thiet-bi.png")

        if ("chi tiết" in t_lower or "hồ sơ" in t_lower or "lịch sử" in t_lower) and "07-chi-tiet-thiet-bi.png" not in embedded_set:
            embed_screenshot_with_caption(
                doc, "07-chi-tiet-thiet-bi.png",
                "Hình 4.12: Hồ sơ chi tiết một máy tính kèm lịch sử sự cố và nhật ký bảo trì",
                width_cm=14.5
            )
            embedded_set.add("07-chi-tiet-thiet-bi.png")

        if ("hàng loạt" in t_lower or "menu" in t_lower or "thao tác" in t_lower) and "10-menu-cac-hanh-dong.png" not in embedded_set:
            embed_screenshot_with_caption(
                doc, "10-menu-cac-hanh-dong.png",
                "Hình 4.14: Menu thực thi các hành động hàng loạt trên danh sách thiết bị",
                width_cm=14.5
            )
            embedded_set.add("10-menu-cac-hanh-dong.png")

    # 4.2.4 Mã QR cho thiết bị: Cấu hình nhãn, Thẻ mã QR, Kết quả sinh QR
    if "4.2.4" in sh_lower:
        if "11-cau-hinh-nhan-qr.png" not in embedded_set:
            embed_screenshot_with_caption(
                doc, "11-cau-hinh-nhan-qr.png",
                "Hình 4.15: Giao diện cấu hình mẫu nhãn in mã QR cho thiết bị",
                width_cm=14.5
            )
            embedded_set.add("11-cau-hinh-nhan-qr.png")

        if "11-ma-qr-thiet-bi.png" not in embedded_set:
            embed_screenshot_with_caption(
                doc, "11-ma-qr-thiet-bi.png",
                "Hình 4.16: Thẻ mã QR định danh trực tiếp trên hồ sơ thiết bị phục vụ quét nhanh",
                width_cm=6.0
            )
            embedded_set.add("11-ma-qr-thiet-bi.png")

        if "12-ket-qua-sinh-qr.png" not in embedded_set:
            embed_screenshot_with_caption(
                doc, "12-ket-qua-sinh-qr.png",
                "Hình 4.17: Bản in mẫu nhãn mã QR sinh ra phục vụ dán lên máy tính và màn hình",
                width_cm=10.5
            )
            embedded_set.add("12-ket-qua-sinh-qr.png")

    # 4.2.7 Giao diện: Đăng nhập, Bảng điều khiển
    if "4.2.7" in sh_lower:
        if "01-trang-dang-nhap.png" not in embedded_set:
            embed_screenshot_with_caption(
                doc, "01-trang-dang-nhap.png",
                "Hình 4.1: Giao diện đăng nhập hệ thống PineDesk với nhận diện thương hiệu Đà Lạt",
                width_cm=14.5
            )
            embedded_set.add("01-trang-dang-nhap.png")

        if "02-bang-dieu-khien.png" not in embedded_set:
            embed_screenshot_with_caption(
                doc, "02-bang-dieu-khien.png",
                "Hình 4.2: Bảng điều khiển trung tâm dành cho kỹ thuật viên và quản trị viên",
                width_cm=14.5
            )
            embedded_set.add("02-bang-dieu-khien.png")

    # Báo cáo thống kê toàn cầu
    if ("thống kê" in t_lower or "toàn cầu" in t_lower or "báo cáo tổng hợp" in t_lower) and "13-thong-ke-toan-cau.png" not in embedded_set:
        if "4.2.2" in sh_lower or "4.3" in sh_lower:
            embed_screenshot_with_caption(
                doc, "13-thong-ke-toan-cau.png",
                "Hình 4.18: Báo cáo thống kê toàn cầu về tài sản và tình hình tiếp nhận sự cố",
                width_cm=14.5
            )
            embedded_set.add("13-thong-ke-toan-cau.png")

def main():
    print("================================================================================")
    print(" BẮT ĐẦU TẠO BÁO CÁO THỰC TẬP TỐT NGHIỆP WORD CHUẨN ĐẠI HỌC ĐÀ LẠT (DLU)")
    print(" Đề tài: XÂY DỰNG HỆ THỐNG HỖ TRỢ KỸ THUẬT (IT HELPDESK) PINEDESK")
    print(" Sinh viên: Phùng Võ Quốc Hiển | MSSV: 2212364 | Lớp: CTK46-PM")
    print("================================================================================")

    if not os.path.exists(MD_FILE_PATH):
        print(f"[LOI] Khong tim thay file: {MD_FILE_PATH}")
        sys.exit(1)

    with open(MD_FILE_PATH, 'r', encoding='utf-8') as f:
        md_content = f.read()

    doc = docx.Document()

    # 1. Trang bìa chính (Section 0)
    print("-> Dang tao Trang bia chinh (Double Border, Logo DLU, Metadata Khoa CNTT)...")
    build_cover_page(doc)

    # 2. Trang bìa phụ (Section 1)
    print("-> Dang tao Trang bia phu (Sub-cover)...")
    build_subcover_page(doc)

    # 3. Phân tích văn bản Markdown và kết xuất Section 2 (Sơ bộ) & Section 3 (Thân bài)
    print("-> Dang phan tich va ket xuat noi dung chi tiet (Bang bieu, 18 anh that, Phu luc)...")
    parse_and_build_body(doc, md_content)

    # 4. Lưu tệp Word cuối cùng
    os.makedirs(os.path.dirname(OUT_DOCX_PATH), exist_ok=True)
    doc.save(OUT_DOCX_PATH)
    file_size_mb = os.path.getsize(OUT_DOCX_PATH) / (1024 * 1024)
    print(f"-> Luu thanh cong tai: {OUT_DOCX_PATH}")
    print(f"   Dung luong tep: {file_size_mb:.2f} MB")
    print("================================================================================")
    print(" HOÀN THÀNH TẠO BÁO CÁO WORD FINAL ĐẠT CHUẨN XUẤT BẢN KHOA HỌC DLU!")
    print("================================================================================")

if __name__ == "__main__":
    main()
