# scripts/sync_word_toc.ps1
# Dong bo so trang tu layout engine cua Microsoft Word vao bookmark_pages.json
# Dam bao 100% Muc luc tuong tac va loai bo hoan toan loi de so trang ve 4 (Word cross-section PAGEREF flaw)

$docxPath = "D:\glpi-helpdesk\tai-lieu\BAO-CAO-THUC-TAP-FINAL.docx"
$jsonPath = "D:\glpi-helpdesk\scripts\bookmark_pages.json"

if (-not (Test-Path $docxPath)) {
    Write-Error "Khong tim thay file: $docxPath"
    exit 1
}

Write-Host "================================================================================"
Write-Host " DONG BO SO TRANG CHINH XAC TU WORD COM LAYOUT ENGINE VAO MUC LUC TUONG TAC"
Write-Host "================================================================================"

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0

try {
    Write-Host "-> Dang mo tai lieu trong Microsoft Word de trich xuat layout..."
    $doc = $word.Documents.Open($docxPath)

    $totalPages = $doc.ComputeStatistics(2)       # wdStatisticPages = 2
    $totalWords = $doc.ComputeStatistics(0)       # wdStatisticWords = 0
    $totalChars = $doc.ComputeStatistics(5)       # wdStatisticCharactersWithSpaces = 5
    $bmCount = $doc.Bookmarks.Count
    $hlCount = $doc.Hyperlinks.Count

    Write-Host "-> Thong ke tai lieu thuc te:"
    Write-Host "   - Tong so trang in:      $totalPages trang"
    Write-Host "   - Tong so tu (Words):    $totalWords tu"
    Write-Host "   - Tong so ky tu:         $totalChars ky tu"
    Write-Host "   - Tong so Bookmark:      $bmCount bookmark"
    Write-Host "   - Tong so Hyperlink:     $hlCount lien ket tuong tac"

    # Trích xuất số trang thực tế của toàn bộ bookmark từ layout engine của Word
    $pages = @{}
    foreach ($bm in $doc.Bookmarks) {
        $name = $bm.Name
        # wdActiveEndAdjustedPageNumber = 1 (so trang dinh dang chuan cua tung section)
        $pNum = [string]$bm.Range.Information(1)
        if (-not [string]::IsNullOrWhiteSpace($pNum)) {
            $pages[$name] = $pNum
        }
    }

    Write-Host "-> Da trich xuat so trang chinh xac cua $($pages.Count) bookmarks."

    # Luu hoac cap nhat vao file bookmark_pages.json
    $jsonContent = $pages | ConvertTo-Json -Depth 5
    Set-Content -Path $jsonPath -Value $jsonContent -Encoding UTF8
    Write-Host "-> Da dong bo anh xa so trang vao: $jsonPath"

    # Kiem tra mot so bookmark trong tam
    $sampleBm = @("bm_mucluc", "bm_modau", "bm_c1", "bm_c2", "bm_c3", "bm_c4", "bm_c4_1_2b", "bm_c5", "bm_ketluan", "bm_tailieu", "bm_phuluc")
    Write-Host "-> Kiem tra trang dinh vi cua cac chuong chinh:"
    foreach ($name in $sampleBm) {
        if ($pages.ContainsKey($name)) {
            $pNum = $pages[$name]
            Write-Host "   [OK] Bookmark '$name' -> Trang $pNum"
        } else {
            Write-Warning "   [THIEU] Khong tim thay bookmark: $name"
        }
    }

    $doc.Save()
    $doc.Close($false)
    Write-Host "-> [THANH CONG] Dong bo so trang Word COM hoan tat!"
} catch {
    Write-Error "Loi trong qua trinh xu ly Word COM: $_"
    exit 1
} finally {
    $word.Quit()
}
