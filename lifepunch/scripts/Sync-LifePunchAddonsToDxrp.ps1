<#
.SYNOPSIS
  Mirror LifePunch addon source from the monorepo into the local DXRP game project.

.DESCRIPTION
  Repo is source of truth (lifepunch/addons). DXRP editor reads:
    <dxrp-game>/Assets/addons/lifepunch/<ident>/
    <dxrp-game>/Code/Addons/lifepunch/<ident>/

  Uses robocopy /MIR so stale folders (e.g. legacy gpu-rack paths after rename) are removed.

.PARAMETER Addon
  One or more addon idents (e.g. lpbitcoin). Default: lpbitcoin.
  Aliases: lpbitcoin / lifepunchbitcoin → assets under lpbitcoin/, code under bitcoinmining/ (legacy repo folder).

.PARAMETER All
  Sync every lifepunch ident that exists under Assets/addons/lifepunch in the repo.

.EXAMPLE
  powershell -File Sync-LifePunchAddonsToDxrp.ps1
  powershell -File Sync-LifePunchAddonsToDxrp.ps1 -Addon ak47,lpbitcoin
  powershell -File Sync-LifePunchAddonsToDxrp.ps1 -All
#>
[CmdletBinding()]
param(
    [string[]] $Addon = @('lpbitcoin'),
    [switch] $All,
    [string] $ConfigPath = '',
    [switch] $WhatIf,
    [switch] $AllowVanillaSync
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $Here 'Dxrp-VanillaWipe.ps1')
if (-not $ConfigPath) { $ConfigPath = Join-Path $Here 'dxrp-editor.local.json' }
if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw "Missing $ConfigPath - copy dxrp-editor.local.json.example first."
}

$cfg = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
$project = [string]$cfg.projectPath
if (-not (Test-Path -LiteralPath $project)) { throw "DXRP project not found: $project" }

$dxrpGame = Split-Path -Parent $project
$repoAddons = (Resolve-Path (Join-Path $Here '..\addons')).Path
$repoAssetsRoot = Join-Path $repoAddons 'Assets\addons\lifepunch'
$repoCodeRoot = Join-Path $repoAddons 'Code\Addons\lifepunch'
$dxrpAssetsRoot = Join-Path $dxrpGame 'Assets\addons\lifepunch'
$dxrpCodeRoot = Join-Path $dxrpGame 'Code\Addons\lifepunch'

if ((Test-DxrpVanillaWorkbench -DxrpGameRoot $dxrpGame) -and -not $AllowVanillaSync) {
    throw @"
BLOCKED: refusing to sync LifePunch into dxrp-vanilla workbench (would restore lp_* commands).

Use the polluted DXRP editor (dxrp-editor.local.json) for LifePunch sync, or pass -AllowVanillaSync deliberately.
"@
}

function Get-AddonIdents {
    if ($All) {
        return @(Get-ChildItem -LiteralPath $repoAssetsRoot -Directory | ForEach-Object { $_.Name })
    }
    $expanded = [System.Collections.Generic.List[string]]::new()
    foreach ($entry in $Addon) {
        if ([string]::IsNullOrWhiteSpace($entry)) { continue }
        foreach ($part in ($entry -split ',')) {
            $ident = $part.Trim()
            if ($ident) { $expanded.Add($ident) | Out-Null }
        }
    }
    return @($expanded | Select-Object -Unique)
}

function Resolve-LpBitcoinCodeIdent([string]$Ident) {
    if ($Ident -in @('lpbitcoin', 'lifepunchbitcoin')) { return 'bitcoinmining' }
    return $Ident
}

function Resolve-LpBitcoinAssetIdent([string]$Ident) {
    if ($Ident -in @('lpbitcoin', 'lifepunchbitcoin', 'bitcoinmining')) { return 'lpbitcoin' }
    return $Ident
}

function Invoke-Mirror([string]$From, [string]$To, [string]$Label) {
    if (-not (Test-Path -LiteralPath $From)) {
        throw "Missing repo path: $From"
    }
    if ($WhatIf) {
        Write-Host "[WhatIf] MIR $Label" -ForegroundColor DarkGray
        Write-Host "         $From -> $To" -ForegroundColor DarkGray
        return
    }
    New-Item -ItemType Directory -Force -Path $To | Out-Null
    & robocopy $From $To /MIR /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy failed ($LASTEXITCODE): $Label" }
    $count = (Get-ChildItem -LiteralPath $To -Recurse -File -ErrorAction SilentlyContinue).Count
    Write-Host "  $Label - $count files" -ForegroundColor Green
}

function Remove-StaleDxrpPath {
    param([string]$Path, [string]$Label)
    if (-not (Test-Path -LiteralPath $Path)) { return }
    if ($WhatIf) {
        Write-Host "[WhatIf] purge $Label" -ForegroundColor DarkGray
        return
    }
    Remove-Item -LiteralPath $Path -Recurse -Force
    Write-Host "  purged stale: $Label" -ForegroundColor Yellow
}

function Remove-LpArchiveCompileArtifacts {
    param([string]$LpBitcoinRoot)
    if (-not (Test-Path -LiteralPath $LpBitcoinRoot)) { return }
    $patterns = @('*.vmdl', '*.vmdl_c', '*.vmat', '*.vmat_c')
    foreach ($pattern in $patterns) {
        Get-ChildItem -LiteralPath $LpBitcoinRoot -Recurse -File -Filter $pattern -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -match '[\\/]_archive[\\/]' } |
            ForEach-Object {
                if ($WhatIf) {
                    Write-Host "  [WhatIf] purge archive compile artifact: $($_.FullName)" -ForegroundColor DarkGray
                    return
                }
                Remove-Item -LiteralPath $_.FullName -Force
                Write-Host "  purged archive compile artifact: $($_.Name)" -ForegroundColor Yellow
            }
    }
}

Write-Host 'Sync LifePunch addons -> DXRP game' -ForegroundColor Cyan
Write-Host "  Repo:  $repoAddons" -ForegroundColor DarkGray
Write-Host "  DXRP:  $dxrpGame" -ForegroundColor DarkGray

if (-not $WhatIf) {
    Write-Host 'Purge DXRP-only clutter (not in repo sync set)' -ForegroundColor Cyan
    Remove-StaleDxrpPath -Path (Join-Path $dxrpGame 'Code\Addons\lifepunch._quarantine') -Label 'Code/Addons/lifepunch._quarantine'
    Remove-StaleDxrpPath -Path (Join-Path $dxrpGame 'Assets\addons\lifepunch._quarantine') -Label 'Assets/addons/lifepunch._quarantine'
    Remove-StaleDxrpPath -Path (Join-Path $dxrpGame 'addons\lifepunch\lpbitcoin') -Label 'addons/lifepunch/lpbitcoin (empty greenfield stub)'
    # adminmenu sync uses Code/Addons/lifepunch/{adminmenu + shared root}. lifepunchulx is the
    # publish slug copy from Set-DxrpLifepunchUlxOnly — if both exist, shared types compile twice.
    Remove-StaleDxrpPath -Path (Join-Path $dxrpCodeRoot 'lifepunchulx') -Label 'Code/lifepunchulx (stale duplicate — use adminmenu sync)'
    Remove-StaleDxrpPath -Path (Join-Path $dxrpAssetsRoot 'lifepunchulx') -Label 'Assets/lifepunchulx (stale duplicate)'
}

# Shared lifepunch code (LifePunchSourceMark.cs, etc.) — not under a single addon ident.
$sharedCodeFiles = @(Get-ChildItem -LiteralPath $repoCodeRoot -File -ErrorAction SilentlyContinue)
if ($sharedCodeFiles.Count -gt 0) {
    Write-Host 'Shared: lifepunch root code' -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path $dxrpCodeRoot | Out-Null
    foreach ($file in $sharedCodeFiles) {
        $dest = Join-Path $dxrpCodeRoot $file.Name
        if ($WhatIf) {
            Write-Host "  [WhatIf] $($file.Name)" -ForegroundColor DarkGray
            continue
        }
        Copy-Item -LiteralPath $file.FullName -Destination $dest -Force
        Write-Host "  $($file.Name)" -ForegroundColor Green
    }

        if (-not $WhatIf) {
        $repoNames = @($sharedCodeFiles | ForEach-Object { $_.Name })
        Get-ChildItem -LiteralPath $dxrpCodeRoot -File -ErrorAction SilentlyContinue |
            Where-Object { $repoNames -notcontains $_.Name } |
            ForEach-Object {
                Remove-Item -LiteralPath $_.FullName -Force
                Write-Host "  Removed stale shared file: $($_.Name)" -ForegroundColor Yellow
            }
    }
}

$devSrc = Join-Path $repoCodeRoot '_dev'
if (Test-Path -LiteralPath $devSrc) {
    Invoke-Mirror `
        -From $devSrc `
        -To   (Join-Path $dxrpCodeRoot '_dev') `
        -Label 'Code/_dev'
    if (-not $WhatIf) {
        $syncedIdents = @(Get-AddonIdents)
        $weaponDevDeps = @('adminmenu', 'ak47', 'deagle', 'mp9', 'ssg08', 'xm1014')
        $weaponDevReady = @($weaponDevDeps | Where-Object { $syncedIdents -notcontains $_ }).Count -eq 0
        $weaponDevGive = Join-Path $dxrpCodeRoot '_dev\WeaponDevGive.cs'
        $weaponDevQuarantine = "$weaponDevGive.quarantine"
        if (-not $weaponDevReady) {
            if (Test-Path -LiteralPath $weaponDevGive) {
                if (Test-Path -LiteralPath $weaponDevQuarantine) {
                    Remove-Item -LiteralPath $weaponDevQuarantine -Force
                }
                Rename-Item -LiteralPath $weaponDevGive -NewName 'WeaponDevGive.cs.quarantine' -Force
                Write-Host '  Code/_dev: WeaponDevGive.cs quarantined (weapon addons not in sync set)' -ForegroundColor Yellow
            }
        }
        elseif (Test-Path -LiteralPath $weaponDevQuarantine) {
            if (-not (Test-Path -LiteralPath $weaponDevGive)) {
                Rename-Item -LiteralPath $weaponDevQuarantine -NewName 'WeaponDevGive.cs' -Force
                Write-Host '  Code/_dev: WeaponDevGive.cs restored (weapon lane)' -ForegroundColor Green
            }
        }
    }
}

foreach ($ident in Get-AddonIdents) {
    Write-Host "Addon: $ident" -ForegroundColor Cyan
    $codeIdent = Resolve-LpBitcoinCodeIdent $ident
    $assetIdent = Resolve-LpBitcoinAssetIdent $ident
    $assetsSrc = Join-Path $repoAssetsRoot $assetIdent
    $assetsDest = Join-Path $dxrpAssetsRoot $assetIdent
    if ($ident -eq 'bitcoinmining') {
        # Legacy repo ident — purge stale Assets/bitcoinmining; ship tree is lpbitcoin/.
        Remove-StaleDxrpPath -Path (Join-Path $dxrpAssetsRoot 'bitcoinmining') -Label 'Assets/bitcoinmining (legacy — purged)'
        Write-Host '  Assets/bitcoinmining - skip (lpbitcoin is canonical in editor)' -ForegroundColor DarkGray
    }
    elseif (Test-Path -LiteralPath $assetsSrc) {
        Invoke-Mirror `
            -From $assetsSrc `
            -To   $assetsDest `
            -Label "Assets/$assetIdent"
        if ($assetIdent -eq 'lpbitcoin') {
            Remove-LpArchiveCompileArtifacts -LpBitcoinRoot $assetsDest
            Remove-StaleDxrpPath -Path (Join-Path $assetsDest 'advancedgpurack') -Label 'Assets/lpbitcoin/advancedgpurack (retired slot)'
        }
    }
    else {
        Write-Host "  Assets/$assetIdent - skip (missing repo folder)" -ForegroundColor DarkGray
    }
    $codeSrc = Join-Path $repoCodeRoot $codeIdent
    if (Test-Path -LiteralPath $codeSrc) {
        Invoke-Mirror `
            -From $codeSrc `
            -To   (Join-Path $dxrpCodeRoot $codeIdent) `
            -Label "Code/$codeIdent"
    }
    else {
        Write-Host "  Code/$codeIdent - skip (no repo folder)" -ForegroundColor DarkGray
    }
}

# Publish staging packages (lp*) — hub/racks live here; not legacy repo idents.
$lpStagingRoot = Join-Path $repoAssetsRoot 'lpbitcoin'
if (Test-Path -LiteralPath $lpStagingRoot) {
    Write-Host 'Staging: lpbitcoin' -ForegroundColor Cyan
    $lpDest = Join-Path $dxrpAssetsRoot 'lpbitcoin'
    Invoke-Mirror `
        -From $lpStagingRoot `
        -To   $lpDest `
        -Label 'Assets/lpbitcoin'
    Remove-LpArchiveCompileArtifacts -LpBitcoinRoot $lpDest
    Remove-StaleDxrpPath -Path (Join-Path $lpDest 'advancedgpurack') -Label 'Assets/lpbitcoin/advancedgpurack (retired slot)'
}

$lpCodeRoot = Join-Path $repoCodeRoot 'lpbitcoin'
if (Test-Path -LiteralPath $lpCodeRoot) {
    Write-Host 'Staging code map: lpbitcoin' -ForegroundColor Cyan
    Invoke-Mirror `
        -From $lpCodeRoot `
        -To   (Join-Path $dxrpCodeRoot 'lpbitcoin') `
        -Label 'Code/lpbitcoin (README maps — sources in bitcoinmining/)'
}

$ensureResources = Join-Path $Here 'Ensure-DxrpLifepunchResources.ps1'
if (Test-Path -LiteralPath $ensureResources) {
    & $ensureResources -Ident (Get-AddonIdents) -ConfigPath $ConfigPath -IncludeStaging
}

if (-not $WhatIf) {
    $assetsRoot = Join-Path $dxrpGame 'Assets'
    foreach ($name in @('lpdevtest.scene', 'LPDEVTEST.scene', 'lpdevtest.scene_c', 'lpdevtest.scene_d', 'LPDEVTEST.scene.bak')) {
        $p = Join-Path $assetsRoot $name
        if (Test-Path -LiteralPath $p) {
            Remove-Item -LiteralPath $p -Force
            Write-Host "  Removed stale lpdevtest artifact: $name" -ForegroundColor Yellow
        }
    }
}

$tailwandConfigSrc = Join-Path (Split-Path $Here -Parent) 'config\tailwand.config.json'
$tailwandConfigDest = Join-Path $dxrpGame 'tailwand.config.json'
if (Test-Path -LiteralPath $tailwandConfigSrc) {
    if ($WhatIf) {
        Write-Host "[WhatIf] tailwand.config.json -> $tailwandConfigDest" -ForegroundColor DarkGray
    }
    else {
        Copy-Item -LiteralPath $tailwandConfigSrc -Destination $tailwandConfigDest -Force
        Write-Host '  tailwand.config.json -> DXRP game root' -ForegroundColor Green
    }
}

Write-Host 'Sync OK' -ForegroundColor Green
Write-Host '  Editor assets: Assets/addons/lifepunch/lpbitcoin/{bitcoinhub,hashdterminal,gpurack} only.' -ForegroundColor Yellow
Write-Host '  Recompile in ModelDoc: bitcoinhub.vmdl, gpu-rack-stacked.vmdl, hashd-terminal.vmdl, then entity prefabs.' -ForegroundColor DarkGray
