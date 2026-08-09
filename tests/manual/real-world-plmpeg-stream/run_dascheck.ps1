param(
    [string]$File = "src\all.das",
    [string]$DaslangPath = ""
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = (Resolve-Path (Join-Path $ScriptDir "..\..\..")).ProviderPath
$WorkspaceRoot = Split-Path -Parent $RepoRoot

if ([string]::IsNullOrWhiteSpace($DaslangPath)) {
    $DaslangPath = Join-Path $WorkspaceRoot "daScript\bin\Release\daslang.exe"
}

if (-not (Test-Path -LiteralPath $DaslangPath)) {
    throw "daslang.exe not found: $DaslangPath"
}

$Target = (Resolve-Path (Join-Path $ScriptDir $File)).ProviderPath
$OutputPath = Join-Path $ScriptDir "src\daslang_output.txt"
$RawPath = Join-Path $ScriptDir "src\daslang_raw.txt"

Write-Host "daslang: $DaslangPath"
Write-Host "target:  $Target"

$output = & $DaslangPath $Target 2>&1
$exitCode = $LASTEXITCODE

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($RawPath, ($output -join [Environment]::NewLine), $utf8NoBom)

if ($exitCode -eq 0) {
    [System.IO.File]::WriteAllText($OutputPath, "", $utf8NoBom)
    Write-Host "dascheck passed"
    exit 0
}

[System.IO.File]::WriteAllText($OutputPath, ($output -join [Environment]::NewLine), $utf8NoBom)
$output | Select-Object -First 80 | ForEach-Object { Write-Host $_ }
exit $exitCode
