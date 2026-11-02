# scripts/sync_word_toc.ps1
# Dong bo so trang va cap nhat truong PAGEREF trong Microsoft Word qua COM Interop

$docxPath = "D:\glpi-helpdesk\tai-lieu\BAO-CAO-THUC-TAP-FINAL.docx"
if (-not (Test-Path $docxPath)) {
    Write-Error "Khong tim thay file: $docxPath"
    exit 1
}

Write-Host "================================================================================"
Write-Host " DONG BO MUC LUC TUONG TAC VA CAP NHAT TRUONG SO TRANG (WORD COM INTEROP)"
Write-Host "================================================================================"

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0

try {
    Write-Host "-> Dang mo tai lieu trong Microsoft Word..."
    $doc = $word.Documents.Open($docxPath)

    Write-Host "-> Dang cap nhat toan bo truong dong (PAGEREF, TOC, PAGE)..."
    $doc.Fields.Update()

    $totalPages = $doc.ComputeStatistics(2)       # wdStatisticPages = 2
    $totalWords = $doc.ComputeStatistics(0)       # wdStatisticWords = 0
    $totalChars = $doc.ComputeStatistics(5)       # wdStatisticCharactersWithSpaces = 5
    $bmCount = $doc.Bookmarks.Count
    $hlCount = $doc.Hyperlinks.Count

    Write-Host "-> Thong ke tai lieu sau khi cap nhat:"
    Write-Host "   - Tong so trang in:      $totalPages trang"
    Write-Host "   - Tong so tu (Words):    $totalWords tu"
    Write-Host "   - Tong so ky tu:         $totalChars ky tu"
    Write-Host "   - Tong so Bookmark:      $bmCount bookmark"
    Write-Host "   - Tong so Hyperlink:     $hlCount lien ket tuong tac"

    # Kiem tra mot so bookmark trong tam
    $sampleBm = @("bm_mucluc", "bm_modau", "bm_c1", "bm_c2", "bm_c3", "bm_c4", "bm_c5", "bm_ketluan", "bm_tailieu", "bm_phuluc")
    Write-Host "-> Kiem tra trang dinh vi cua cac chuong chinh:"
    foreach ($name in $sampleBm) {
        if ($doc.Bookmarks.Exists($name)) {
            $bm = $doc.Bookmarks.Item($name)
            $pNum = $bm.Range.Information(3)  # wdActiveEndPageNumber
            Write-Host "   [OK] Bookmark '$name' -> Trang $pNum"
        } else {
            Write-Warning "   [THIEU] Khong tim thay bookmark: $name"
        }
    }

    Write-Host "-> Dang luu tai lieu da dong bo..."
    $doc.Save()
    $doc.Close($false)
    Write-Host "-> [THANH CONG] Tai lieu Word da san sang voi Muc luc tuong tac 100%!"
} catch {
    Write-Error "Loi trong qua trinh xu ly Word COM: $_"
    exit 1
} finally {
    $word.Quit()
}
