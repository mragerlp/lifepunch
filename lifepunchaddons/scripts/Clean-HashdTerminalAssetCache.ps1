# Purge stale hashd-terminal compile artifacts (run with s&box STOPPED).
# Drops orphaned *_png_*.generated.vtex* and stale vmat/vmdl _c that reference old PNG bakes.
param(
    [string]$DxrpGame = 'D:\Steam\steamapps\common\sbox\dxrp\game',
    [switch]$IncludeRepo
)

$ErrorActionPreference = 'Stop'

function Clear-HashdCache {
    param([string]$Root)
    if (-not (Test-Path -LiteralPath $Root)) { return 0 }
    $removed = 0
    foreach ($pattern in @('*.generated.vtex', '*.generated.vtex_c', '*_c', '*.vtex_c', '*.png')) {
        Get-ChildItem -LiteralPath $Root -Recurse -Filter $pattern -File -ErrorAction SilentlyContinue |
            ForEach-Object {
                Remove-Item -LiteralPath $_.FullName -Force
                $removed++
            }
    }
    return $removed
}

$dxrpRoot = Join-Path $DxrpGame 'Assets\addons\lifepunch\lpbitcoin\hashdterminal'
$dxrpRemoved = Clear-HashdCache -Root $dxrpRoot
Write-Host "DXRP: removed $dxrpRemoved cache/_c files" -ForegroundColor Green

if ($IncludeRepo) {
    $repoRoot = Join-Path (Split-Path $PSScriptRoot -Parent) 'Assets\addons\lifepunch\lpbitcoin\hashdterminal'
    if (Test-Path -LiteralPath $repoRoot) {
        $repoRemoved = Clear-HashdCache -Root (Resolve-Path -LiteralPath $repoRoot).Path
        Write-Host "Repo: removed $repoRemoved cache/_c files" -ForegroundColor Green
    }
}

Write-Host 'Next: recompile vmats + vmdl in ModelDoc or bridge, then copy fresh _c to repo.' -ForegroundColor Cyan
