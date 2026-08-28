[CmdletBinding()]
param(
    [ValidateSet('fast', 'full', 'extended')]
    [string]$Mode = 'fast',
    [string]$MirrorName = "c2das-preflight-$env:USERNAME"
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if ($MirrorName -notmatch '^[A-Za-z0-9._-]+$') { throw "Invalid WSL mirror name: $MirrorName" }
$mirror = "/root/$MirrorName"
if ($mirror -notlike '/root/c2das-preflight-*') { throw "Refusing unsafe mirror: $mirror" }

$untracked = @(git -C $repo ls-files --others --exclude-standard)
if ($untracked.Count -ne 0) { throw "Refusing preflight with untracked artifacts:`n$($untracked -join "`n")" }

$drive = [System.IO.Path]::GetPathRoot($repo).TrimEnd('\', ':').ToLowerInvariant()
if ($drive.Length -ne 1) { throw "Unable to map Windows source drive to WSL: $repo" }
$sourceWsl = "/mnt/$drive/$($repo.Substring(3).Replace('\', '/'))"
if (-not $sourceWsl.StartsWith('/mnt/')) { throw 'Unable to resolve Windows source path in WSL.' }
$sourceHash = (& wsl.exe -u root -- env "C2DAS_TREE_ROOT=$sourceWsl" bash "$sourceWsl/scripts/c2das_tree_hash.sh").Trim()
if ($LASTEXITCODE -ne 0 -or -not $sourceHash) { throw 'Unable to hash Windows source tree in WSL.' }

& wsl.exe -u root -- env "C2DAS_SYNC_SOURCE=$sourceWsl" "C2DAS_SYNC_MIRROR=$mirror" bash "$sourceWsl/scripts/c2das_sync_mirror.sh"
if ($LASTEXITCODE -ne 0) { throw 'WSL mirror synchronization failed.' }

$mirrorHash = (& wsl.exe -u root -- env "C2DAS_TREE_ROOT=$mirror" bash "$mirror/scripts/c2das_tree_hash.sh").Trim()
if ($LASTEXITCODE -ne 0 -or $mirrorHash -ne $sourceHash) { throw "Stale mirror after sync: source=$sourceHash mirror=$mirrorHash" }

& wsl.exe -u root -- env "C2DAS_SOURCE_HASH=$sourceHash" "C2DAS_MIRROR_NAME=$MirrorName" 'C2DAS_UNTRACKED_CLEAN=1' 'DASROOT=/root/daScript' bash "$mirror/scripts/c2das_preflight.sh" "--$Mode"
if ($LASTEXITCODE -ne 0) { throw "c2das WSL preflight failed ($LASTEXITCODE)." }
