# Prepare lpmonnowsprinterupgrade for DXRP portal upload (Assets + Code).
# Source: Desktop Monnow LifePunch folder (canonical until monorepo staging exists).
#
# Root cause this fixes: Rev 2 shipped models/sounds under lpmonnowsprinterupgrade/ but
# NO prefab, while gamemode PrimaryReference expects:
#   addons/lifepunch/monnow-printer-lp/monnow_printer.prefab
#
# Usage:
#   powershell -File lifepunch\scripts\Prepare-LpMonnowPrinterPublish.ps1
#   powershell -File lifepunch\scripts\Prepare-LpMonnowPrinterPublish.ps1 -OpenFolder

param(
    [string]$MonnowRoot = "$env:USERPROFILE\OneDrive\Desktop\monnowsaddons",
    [switch]$OpenFolder
)

$ErrorActionPreference = 'Stop'

$SourceRoot = Join-Path $MonnowRoot "Monnow's Printer Addon\LifePunch"

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$UploadRoot = Join-Path $RepoRoot 'lifepunch\addons\.dxrp-publish\upload'

$AssetsSource = Join-Path $SourceRoot 'assets\monnow-printer-lp'
$CodeSource = Join-Path $SourceRoot 'code\monnow-printer-lp'

if (-not (Test-Path -LiteralPath $AssetsSource)) {
    throw "Missing assets source: $AssetsSource"
}

if (-not (Test-Path -LiteralPath $CodeSource)) {
    throw "Missing code source: $CodeSource"
}

$PrefabSource = Join-Path $AssetsSource 'monnow_printer.prefab'
if (-not (Test-Path -LiteralPath $PrefabSource)) {
    throw "Missing prefab (required for market spawn): $PrefabSource"
}

$AssetsStage = Join-Path $UploadRoot 'Assets\addons\lifepunch\monnow-printer-lp'
$CodeStage = Join-Path $UploadRoot 'Code\Addons\lifepunch\lpmonnowsprinterupgrade'

if (Test-Path -LiteralPath $UploadRoot) {
    Remove-Item -LiteralPath $UploadRoot -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $AssetsStage | Out-Null
New-Item -ItemType Directory -Force -Path $CodeStage | Out-Null

function Copy-Tree {
    param(
        [string]$From,
        [string]$To
    )

    Get-ChildItem -LiteralPath $From -Recurse -File -Force | ForEach-Object {
        $Relative = $_.FullName.Substring($From.Length).TrimStart('\', '/')
        if ($Relative -match '(?i)(\\|^)(source|_archive|audit|docs|_dev)(\\|$)') {
            return
        }

        if ($_.Extension -in @('.blend', '.fbx', '.tga', '.obj', '.md')) {
            return
        }

        $Target = Join-Path $To $Relative
        $Parent = Split-Path -Parent $Target
        if (-not (Test-Path -LiteralPath $Parent)) {
            New-Item -ItemType Directory -Force -Path $Parent | Out-Null
        }

        Copy-Item -LiteralPath $_.FullName -Destination $Target -Force
    }
}

Copy-Tree -From $AssetsSource -To $AssetsStage
Copy-Tree -From $CodeSource -To $CodeStage

$RequiredAssetPaths = @(
    'monnow_printer.prefab',
    'models\money_printer.vmdl',
    'sounds\generate.sound',
    'sounds\idle.sound'
)

$Missing = @()
foreach ($Rel in $RequiredAssetPaths) {
    $Full = Join-Path $AssetsStage $Rel
    if (-not (Test-Path -LiteralPath $Full)) {
        $Missing += $Rel
    }
}

if ($Missing.Count -gt 0) {
    throw "Staging incomplete - missing: $($Missing -join ', ')"
}

$GeneratedAt = Get-Date -Format 'yyyy-MM-dd HH:mm'
$Readme = @"
lpmonnowsprinterupgrade - DXRP publish staging
==============================================

Generated: $GeneratedAt
Source: $SourceRoot

UPLOAD (portal -> addon -> new revision):
  1. Upload everything under: $UploadRoot\Assets
     (must mount as addons/lifepunch/monnow-printer-lp/...)
  2. Upload everything under: $UploadRoot\Code
     (mounts as Code/Addons/lifepunch/lpmonnowsprinterupgrade/)

Gamemode content PrimaryReference (already configured):
  addons/lifepunch/monnow-printer-lp/monnow_printer.prefab

Before upload - compile in sbox editor (ModelDoc Studio or DXRP project):
  - monnow_printer.prefab (and prefab_c)
  - money_printer.vmdl (and vmdl_c)
  - sounds (and vsnd_c)
  Re-run this script after compile so _c files are included.

After publish:
  - Addon Content: ONE row (Monnowlith Printer) — not three tier rows on the addon
  - Gamemode: ONE content + ONE entity + ONE market row (Monnowlith Printer). L1/L2/L3 = in-game upgrades only.
  - Pin new revision on LIFEPUNCH Dev gamemode
  - Sync Servers (owner approval)
  - Market buy test: printer appears at aim ray; no silent charge-without-spawn

Rev 2 failure mode (fixed by this layout):
  - Published assets were lpmonnowsprinterupgrade/models only (no prefab)
  - GetPrefab() failed - money charged, nothing spawned
"@

$PublishRoot = Join-Path $RepoRoot 'lifepunch\addons\.dxrp-publish'
Set-Content -LiteralPath (Join-Path $PublishRoot 'README-monnow-printer.txt') -Value $Readme -Encoding UTF8

Write-Host 'Prepared lpmonnowsprinterupgrade publish staging.' -ForegroundColor Green
Write-Host "Upload root: $UploadRoot"
Write-Host 'Assets path law: addons/lifepunch/monnow-printer-lp/monnow_printer.prefab' -ForegroundColor Cyan
Write-Host "Prefab staged: $(Join-Path $AssetsStage 'monnow_printer.prefab')" -ForegroundColor Green

if ($OpenFolder) {
    Invoke-Item $UploadRoot
}
