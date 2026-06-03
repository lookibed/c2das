$root = "X:\c2dascript"
$daslang = "X:\..\daScript\bin\Release\daslang.exe"

$dasFiles = Get-ChildItem -Path "$root\tests\unit" -Recurse -Filter "*.das" | Sort-Object

Write-Host "====================================="
Write-Host "  Bulk daslang compilation check"
Write-Host "  $($dasFiles.Count) .das files"
Write-Host "====================================="

$pass = 0; $fail = 0
$failures = @()

foreach ($f in $dasFiles) {
    $rel = $f.FullName.Substring($root.Length + 1)
    $errFile = [System.IO.Path]::GetTempFileName()
    
    $p = Start-Process -FilePath $daslang -ArgumentList "`"$($f.FullName)`"" -NoNewWindow -Wait -PassThru -RedirectStandardError $errFile
    
    if ($p.ExitCode -eq 0) {
        Write-Host "  [PASS] $rel"
        $pass++
    } else {
        $errMsg = Get-Content -Path $errFile -Raw
        if (-not $errMsg) { $errMsg = "(no stderr)" }
        Write-Host "  [FAIL] $rel exit=$($p.ExitCode)"
        $firstLine = ($errMsg -split "`n")[0].Trim()
        if ($firstLine) { Write-Host "         $firstLine" }
        $fail++
        $failures += @{file=$rel; code=$p.ExitCode; msg=$errMsg}
    }
    Remove-Item -Path $errFile -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "====================================="
if ($fail -eq 0) {
    Write-Host "  ALL $pass/$($dasFiles.Count) COMPILED"
} else {
    Write-Host "  $pass/$($dasFiles.Count) compiled, $fail failed"
    Write-Host ""
    Write-Host "--- Failed files (full stderr) ---"
    foreach ($fr in $failures) {
        Write-Host "=== $($fr.file) (exit=$($fr.code)) ==="
        Write-Host $fr.msg
    }
}
Write-Host "====================================="
