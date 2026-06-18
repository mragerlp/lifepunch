<#
.SYNOPSIS
  LEGACY playtest lane — old bitcoinmining ship tree (Steam Machine meshes). NOT Model Foundation.

.DESCRIPTION
  BLOCKED by default while ACTIVE_WORKSTREAM is Model Foundation on lpbitcoin staging.

  This mounts legacy bitcoinmining/models/ (quarantined for mesh work) and enables
  lp_bitcoin_spawn_* commands that spawn Steam Machine prefabs — NOT the paid Fab meshes.

  Use instead:
    Prepare-LpBitcoinModelDoc.ps1
    Set-DxrpLifepunchModelDocLane.ps1

  Only run with -AllowLegacyPlaytest when owner explicitly wants legacy ship-tree play polish
  AFTER Model Foundation sign-off + vmdl promotion — not for new mesh work.

.EXAMPLE
  powershell -File lifepunch\scripts\Set-DxrpLifepunchBitcoinOnly.ps1 -AllowLegacyPlaytest
#>
[CmdletBinding()]
param(
    [string] $ConfigPath = '',
    [switch] $AllowLegacyPlaytest
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }

if (-not $AllowLegacyPlaytest) {
    Write-Host 'BLOCKED: Set-DxrpLifepunchBitcoinOnly mounts legacy bitcoinmining meshes (Steam Machine).' -ForegroundColor Red
    Write-Host 'Active lane: lpbitcoin Model Foundation — see ACTIVE_WORKSTREAM.md + LPBITCOIN_TODAY_CHECKLIST.md' -ForegroundColor Yellow
    Write-Host '  Prepare-LpBitcoinModelDoc.ps1' -ForegroundColor Cyan
    Write-Host '  Set-DxrpLifepunchModelDocLane.ps1' -ForegroundColor Cyan
    Write-Host 'Re-run with -AllowLegacyPlaytest only if owner explicitly wants legacy play polish.' -ForegroundColor DarkGray
    exit 1
}

if (-not $ConfigPath) { $ConfigPath = Join-Path $Here 'dxrp-editor.local.json' }
if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw "Missing $ConfigPath - copy dxrp-editor.local.json.example first."
}

$cfg = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
$sbprojPath = [string]$cfg.projectPath
$dxrpGame = Split-Path -Parent $sbprojPath

$repoIdent = 'bitcoinmining'
$keepCodeFolders = @($repoIdent, '_dev')

$repoAddons = (Resolve-Path (Join-Path $Here '..\addons')).Path
$repoCodeRoot = Join-Path $repoAddons 'Code\Addons\lifepunch'
$repoCodeSrc = Join-Path $repoCodeRoot $repoIdent
$repoDevSrc = Join-Path $repoCodeRoot '_dev'

$dxrpAssetsRoot = Join-Path $dxrpGame 'Assets\addons\lifepunch'
$dxrpCodeRoot = Join-Path $dxrpGame 'Code\Addons\lifepunch'
$quarantineAssets = Join-Path $dxrpGame 'Assets\addons\lifepunch._quarantine'
$quarantineCode = Join-Path $dxrpGame 'Code\Addons\lifepunch._quarantine'

function Remove-DxrpTree {
    param([string] $Path, [string] $Label)
    if (-not (Test-Path -LiteralPath $Path)) { return }
    Remove-Item -LiteralPath $Path -Recurse -Force
    Write-Host "  purged: $Label" -ForegroundColor Yellow
}

function Purge-NonKeepFolders {
    param(
        [string] $Root,
        [string[]] $Keep,
        [string] $Label
    )
    if (-not (Test-Path -LiteralPath $Root)) { return }
    Get-ChildItem -LiteralPath $Root -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        if ($Keep -contains $_.Name) { return }
        Remove-DxrpTree -Path $_.FullName -Label "$Label/$($_.Name)"
    }
    Get-ChildItem -LiteralPath $Root -File -ErrorAction SilentlyContinue | ForEach-Object {
        Remove-DxrpTree -Path $_.FullName -Label "$Label/$($_.Name)"
    }
}

Write-Host 'DXRP Bitcoin-only lane — purge stale addons + bitcoinmining sync' -ForegroundColor Cyan
Write-Host "  Game: $dxrpGame" -ForegroundColor DarkGray

Write-Host 'Purge stale lifepunch._quarantine trees' -ForegroundColor Cyan
Remove-DxrpTree -Path $quarantineAssets -Label 'Assets/addons/lifepunch._quarantine'
Remove-DxrpTree -Path $quarantineCode -Label 'Code/Addons/lifepunch._quarantine'

Write-Host 'Purge Assets/addons/lifepunch/* (keep bitcoinmining only)' -ForegroundColor Cyan
Purge-NonKeepFolders -Root $dxrpAssetsRoot -Keep @($repoIdent) -Label 'Assets/addons/lifepunch'

Write-Host 'Purge Code/Addons/lifepunch/* (keep bitcoinmining + _dev)' -ForegroundColor Cyan
Purge-NonKeepFolders -Root $dxrpCodeRoot -Keep $keepCodeFolders -Label 'Code/Addons/lifepunch'

Write-Host "Sync repo $repoIdent" -ForegroundColor Cyan
$dxrpFolderAssets = Join-Path $dxrpAssetsRoot $repoIdent
$dxrpFolderCode = Join-Path $dxrpCodeRoot $repoIdent
New-Item -ItemType Directory -Force -Path $dxrpFolderCode | Out-Null

$assetsSrc = Join-Path $repoAddons "Assets\addons\lifepunch\$repoIdent"
if (Test-Path -LiteralPath $assetsSrc) {
    & robocopy $assetsSrc $dxrpFolderAssets /MIR /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy assets failed" }
    Write-Host '  Assets/bitcoinmining mirrored' -ForegroundColor Green
}

if (-not (Test-Path -LiteralPath $repoCodeSrc)) {
    throw "Missing repo code: $repoCodeSrc"
}
& robocopy $repoCodeSrc $dxrpFolderCode /MIR /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
if ($LASTEXITCODE -ge 8) { throw "robocopy code failed" }
$codeCount = (Get-ChildItem -LiteralPath $dxrpFolderCode -Recurse -File).Count
Write-Host "  Code/bitcoinmining - $codeCount files" -ForegroundColor Green

$sharedCodeFiles = @(Get-ChildItem -LiteralPath $repoCodeRoot -File -ErrorAction SilentlyContinue)
if ($sharedCodeFiles.Count -gt 0) {
    New-Item -ItemType Directory -Force -Path $dxrpCodeRoot | Out-Null
    foreach ($file in $sharedCodeFiles) {
        Copy-Item -LiteralPath $file.FullName -Destination (Join-Path $dxrpCodeRoot $file.Name) -Force
    }
    Write-Host "  Code/lifepunch shared root - $($sharedCodeFiles.Count) files" -ForegroundColor Green
}

if (Test-Path -LiteralPath $repoDevSrc) {
    $dxrpDev = Join-Path $dxrpCodeRoot '_dev'
    New-Item -ItemType Directory -Force -Path $dxrpDev | Out-Null
    & robocopy $repoDevSrc $dxrpDev /MIR /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy _dev failed" }
    $weaponDevGive = Join-Path $dxrpDev 'WeaponDevGive.cs'
    if (Test-Path -LiteralPath $weaponDevGive) {
        Rename-Item -LiteralPath $weaponDevGive -NewName 'WeaponDevGive.cs.quarantine' -Force
        Write-Host '  Code/_dev: WeaponDevGive.cs quarantined (bitcoin-only lane)' -ForegroundColor Yellow
    }
    Write-Host '  Code/_dev mirrored (lp_map_flatgrass)' -ForegroundColor Green
}

$content = Get-Content -LiteralPath $sbprojPath -Raw
$marker = '"Resources": "'
$start = $content.IndexOf($marker)
if ($start -lt 0) { throw 'rp.sbproj Resources field not found' }
$valueStart = $start + $marker.Length
$valueEnd = $content.IndexOf( [char]34, $valueStart )
$resourcesBlock = $content.Substring($valueStart, $valueEnd - $valueStart)
$lines = $resourcesBlock -split '\\n' | Where-Object { $_ -and ($_ -notmatch 'addons/lifepunch/') }
$lines += ('addons/lifepunch/' + $repoIdent + '/**')
$newResources = ($lines | Select-Object -Unique) -join '\n'
$content = $content.Substring(0, $valueStart) + $newResources + $content.Substring($valueEnd)
[System.IO.File]::WriteAllText($sbprojPath, $content)
Write-Host ('rp.sbproj Resources -> addons/lifepunch/' + $repoIdent + '/** only') -ForegroundColor Green

$assetsRoot = Join-Path $dxrpGame 'Assets'
foreach ($name in @('lpdevtest.scene', 'LPDEVTEST.scene', 'lpdevtest.scene_c', 'lpdevtest.scene_d', 'LPDEVTEST.scene.bak')) {
    $p = Join-Path $assetsRoot $name
    if (Test-Path -LiteralPath $p) {
        Remove-Item -LiteralPath $p -Force
        Write-Host "  Removed stale lpdevtest artifact: $name" -ForegroundColor Yellow
    }
}

Write-Host ''
Write-Host 'Bitcoin-only DXRP lane ready. Restart s&box editor (Resources + asset tree changed).' -ForegroundColor Cyan
Write-Host 'Quarantined addons live in the monorepo only — not copied into DXRP.' -ForegroundColor DarkGray
Write-Host 'Play: lp_map_flatgrass -> lp_bitcoin_spawn_kit -> USE hub / racks' -ForegroundColor DarkGray
