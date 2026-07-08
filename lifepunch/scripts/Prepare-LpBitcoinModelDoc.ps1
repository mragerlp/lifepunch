<#
.SYNOPSIS
  One-shot prep: sync lpbitcoin ModelDoc assets owner drop -> DXRP.

.DESCRIPTION
  Source: %USERPROFILE%\OneDrive\Desktop\addon test\addons\lifepunch\lpbitcoin
  (NOT repo staging — repo is for git/publish only).

.EXAMPLE
  powershell -File lifepunch\scripts\Prepare-LpBitcoinModelDoc.ps1
  powershell -File lifepunch\scripts\Prepare-LpBitcoinModelDoc.ps1 -Entity bitcoinhub
#>
[CmdletBinding()]
param(
    [switch] $RecompileViaBridge,
    [string] $Entity = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $Here 'Dxrp-LifepunchPaths.ps1')
$pathsScript = Join-Path (Resolve-Path (Join-Path $Here '..\..\lifepunchaddons')).Path 'scripts\LifePunch-AddonDropPaths.ps1'
. $pathsScript

$src = Get-LifePunchLpBitcoinArtDrop
if (-not (Test-Path -LiteralPath $src)) {
    throw "Missing owner lpbitcoin drop: $src"
}

$configPath = Join-Path $Here 'dxrp-editor.local.json'
if (-not (Test-Path -LiteralPath $configPath)) {
    Write-Host 'No dxrp-editor.local.json — repo files only. Copy config from .example to sync to DXRP.' -ForegroundColor Yellow
    Write-Host "Canonical staging: $src" -ForegroundColor Cyan
    exit 0
}

$cfg = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
$dxrpGame = Get-DxrpGameRootFromConfig -ConfigPath $configPath
$dest = Join-Path (Get-DxrpLifepunchAddonsDiskRoot -DxrpGameRoot $dxrpGame) 'lpbitcoin'

Write-Host 'LpBitcoin ModelDoc prep — owner drop -> DXRP' -ForegroundColor Cyan
Write-Host "  From: $src" -ForegroundColor DarkGray
Write-Host "  To:   $dest" -ForegroundColor DarkGray

New-Item -ItemType Directory -Force -Path (Split-Path $dest -Parent) | Out-Null
if ($Entity) {
    $entitySrc = Join-Path $src $Entity
    if (-not (Test-Path -LiteralPath $entitySrc)) { throw "Missing entity folder: $entitySrc" }
    $entityDest = Join-Path $dest $Entity
    $pkgMeta = @('README.md', 'duplicate_report.md', 'audit')
    foreach ($meta in $pkgMeta) {
        $mSrc = Join-Path $src $meta
        if (Test-Path -LiteralPath $mSrc) {
            $mDst = Join-Path $dest $meta
            if ((Get-Item -LiteralPath $mSrc).PSIsContainer) {
                & robocopy $mSrc $mDst /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
            }
            else {
                New-Item -ItemType Directory -Force -Path (Split-Path $mDst -Parent) | Out-Null
                Copy-Item -LiteralPath $mSrc -Destination $mDst -Force
            }
        }
    }
    & robocopy $entitySrc $entityDest /E /XD '_archive' /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    Write-Host "  synced lpbitcoin/$Entity only (Phase A hub lane)" -ForegroundColor Green
}
else {
    & robocopy $src $dest /E /XD '_archive' /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    Write-Host '  synced full lpbitcoin package' -ForegroundColor Green
}
if ($LASTEXITCODE -ge 8) { throw "robocopy failed with exit $LASTEXITCODE" }

Write-Host '  rp.sbproj: run Enable-LpBitcoinHubRuntimeMount.ps1 after hub _c compiles (Assets/addons path).' -ForegroundColor DarkYellow

$vmdlRels = if ($Entity) {
    @("$Entity/assets/models/bitcoin-hub.vmdl", "$Entity/assets/models/hashd-terminal.vmdl", "$Entity/assets/models/gpu-rack.vmdl", "$Entity/assets/models/gpu-rack-stacked.vmdl") |
        Where-Object { Test-Path -LiteralPath (Join-Path $dest ($_ -replace '/','\')) }
}
else {
    @(
        'bitcoinhub/assets/models/bitcoin-hub.vmdl',
        'hashdterminal/assets/models/hashd-terminal.vmdl',
        'gpurack/assets/models/gpu-rack.vmdl',
        'advancedgpurack/assets/models/gpu-rack-stacked.vmdl'
    ) | Where-Object { Test-Path -LiteralPath (Join-Path $dest ($_ -replace '/','\')) }
}
Write-Host 'ModelDoc targets (open in editor or ModelDoc Studio):' -ForegroundColor Cyan
foreach ($rel in $vmdlRels) {
    Write-Host "  addons/lifepunch/lpbitcoin/$rel" -ForegroundColor White
}

if ($RecompileViaBridge) {
    Write-Host 'Bridge recompile: start s&box + Claude Bridge, then re-run with MCP or compile manually in ModelDoc.' -ForegroundColor Yellow
}

Write-Host 'Next: Set-DxrpLifepunchModelDocLane.ps1 if full lane reset needed.' -ForegroundColor DarkGray
