[CmdletBinding()]
param(
    [ValidateSet('fast', 'full', 'extended')]
    [string]$Mode = 'fast',
    # The c2das checkout and the daScript checkout as WSL paths.  Defaults come from the
    # C2DAS_WSL_ROOT and DASROOT_WSL environment variables.
    [string]$C2dasRoot = $env:C2DAS_WSL_ROOT,
    [string]$DasRoot = $env:DASROOT_WSL
)

$ErrorActionPreference = 'Stop'
if (-not $C2dasRoot) { throw "set -C2dasRoot or C2DAS_WSL_ROOT to the c2das checkout (WSL path)." }
if (-not $DasRoot) { throw "set -DasRoot or DASROOT_WSL to the daScript checkout (WSL path)." }
& wsl.exe -u root -- bash -lc "cd '$C2dasRoot' && DASROOT='$DasRoot' bash scripts/c2das_preflight.sh --$Mode"
if ($LASTEXITCODE -ne 0) { throw "canonical WSL c2das preflight failed ($LASTEXITCODE)." }
