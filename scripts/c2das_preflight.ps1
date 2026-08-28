[CmdletBinding()]
param(
    [ValidateSet('fast', 'full', 'extended')]
    [string]$Mode = 'fast'
)

$ErrorActionPreference = 'Stop'
& wsl.exe -u root -- bash -lc "cd /root/c2das && DASROOT=/root/daScript bash scripts/c2das_preflight.sh --$Mode"
if ($LASTEXITCODE -ne 0) { throw "canonical WSL c2das preflight failed ($LASTEXITCODE)." }
