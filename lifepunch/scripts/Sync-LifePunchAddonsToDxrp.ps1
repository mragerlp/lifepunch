# =====================================================================
# RISK: MODIFIES WORKTREE (robocopy /MIR into the nested lifepunchdxrp/ tree; removes stale target folders)
# GO:   no GO needed (routine editor-testing sync)
# NODE: Red only  |  BRANCH: develop
# PRE:  clean tree on the right branch; grounded per START_HERE_AGENTS.md
# WHAT: Mirror LifePunch addon source from lifepunchaddons/ into the nested lifepunchdxrp/ game tree.
# =====================================================================
<#
.SYNOPSIS
  Mirror LifePunch addon source from the monorepo into the local DXRP game project.

.DESCRIPTION
  Repo is source of truth (lifepunchaddons). DXRP editor reads:
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
    # Default set MUST match the launch lane (Start-SboxDxrpEditor syncs adminmenu too) —
    # a narrower default purges lifepunchulx mid-session and strands its static callbacks
    # (NoMatchStatic spam, restart-class). Aligned 2026-07-09 after it bit twice.
    [string[]] $Addon = @('lpbitcoin', 'adminmenu'),
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
$repoAddons = (Resolve-Path (Join-Path $Here '..\..\lifepunchaddons')).Path
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

function Resolve-DxrpPackageFolder([string]$Ident) {
    if ($Ident -eq 'adminmenu') { return 'lifepunchulx' }
    if ($Ident -in @('lpbitcoin', 'lifepunchbitcoin', 'bitcoinmining')) { return 'lpbitcoin' }
    return $Ident
}

# lifepunchulx editor sync: six ship files only — shared UI helpers live at Code/Addons/lifepunch/
# (same block as bitcoinmining). prepare-publish.ps1 bundles deps into lifepunchulx/ for portal ship only.
$script:AdminMenuSharedShipFiles = @(
    'LifePunchUiScale.cs',
    'LifePunchUiScrollPolicy.cs',
    'LifePunchScrollRegionPanel.cs',
    'LifePunchScrollLayout.cs',
    'LifePunchSourceMark.cs',
    'LifePunchUiFooter.razor',
    'LifePunchUiFooter.razor.scss'
)

function Sync-LifepunchUlxToDxrp {
    $repoIdent = 'adminmenu'
    $dxrpFolder = 'lifepunchulx'
    $repoUlxCode = Join-Path $repoCodeRoot $repoIdent
    $dxrpUlxAssets = Join-Path $dxrpAssetsRoot $dxrpFolder
    $dxrpUlxCode = Join-Path $dxrpCodeRoot $dxrpFolder
    $ulxAssetsSrc = Join-Path $repoAssetsRoot $repoIdent

    Write-Host "Addon: lifepunchulx (repo $repoIdent)" -ForegroundColor Cyan

    if (Test-Path -LiteralPath $ulxAssetsSrc) {
        Invoke-Mirror -From $ulxAssetsSrc -To $dxrpUlxAssets -Label "Assets/$dxrpFolder"
    }
    else {
        Write-Host "  Assets/$dxrpFolder - code-only (no repo assets)" -ForegroundColor DarkGray
        Remove-StaleDxrpPath -Path $dxrpUlxAssets -Label "Assets/$dxrpFolder (empty stub)"
    }

    if (-not (Test-Path -LiteralPath $repoUlxCode)) {
        throw "Missing repo code: $repoUlxCode"
    }

    $shipFiles = @(
        'StaffMenu.razor',
        'StaffMenu.razor.scss',
        'StaffMenuHost.cs',
        'StaffMenuActions.cs',
        'StaffMenuBridgeService.cs'
    )

    if ($WhatIf) {
        Write-Host "  [WhatIf] Code/$dxrpFolder ship files (shared UI from lifepunch/ parent)" -ForegroundColor DarkGray
        return
    }

    Remove-StaleDxrpPath -Path (Join-Path $dxrpCodeRoot $repoIdent) -Label "Code/$repoIdent (use lifepunchulx folder)"
    Remove-StaleDxrpPath -Path (Join-Path $dxrpAssetsRoot $repoIdent) -Label "Assets/$repoIdent (use lifepunchulx folder)"

    if (Test-Path -LiteralPath $dxrpUlxCode) {
        Remove-Item -LiteralPath $dxrpUlxCode -Recurse -Force
    }
    New-Item -ItemType Directory -Force -Path $dxrpUlxCode | Out-Null

    foreach ($name in $shipFiles) {
        $src = Join-Path $repoUlxCode $name
        if (-not (Test-Path -LiteralPath $src)) { throw "Missing ship file: $src" }
        Copy-Item -LiteralPath $src -Destination (Join-Path $dxrpUlxCode $name) -Force
    }

    # Purge stale publish-bundle copies — editor compiles shared helpers once from Code/Addons/lifepunch/.
    foreach ($name in $script:AdminMenuSharedShipFiles) {
        $stale = Join-Path $dxrpUlxCode $name
        if (Test-Path -LiteralPath $stale) {
            Remove-Item -LiteralPath $stale -Force
            Write-Host "  Code/${dxrpFolder}: removed bundled $name (use lifepunch/ parent)" -ForegroundColor Yellow
        }
    }

    $codeCount = (Get-ChildItem -LiteralPath $dxrpUlxCode -Recurse -File).Count
    Write-Host "  Code/${dxrpFolder} - $codeCount files (ship only; shared UI at lifepunch/ root)" -ForegroundColor Green
}

function Remove-LegacyAddonTestArtifacts {
    param([string]$LpBitcoinRoot)
    if (-not (Test-Path -LiteralPath $LpBitcoinRoot)) { return }
    Get-ChildItem -LiteralPath $LpBitcoinRoot -Recurse -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -eq 'textures4k' -or $_.FullName -match '[\\/]Textures[\\/]textures4k$' } |
        ForEach-Object {
            Remove-StaleDxrpPath -Path $_.FullName -Label "legacy OneDrive textures4k ($($_.FullName))"
        }
}

function Repair-HashdTerminalFbx {
    param([string]$FbxPath)
    if (-not (Test-Path -LiteralPath $FbxPath)) { return }
    $repair = Join-Path $repoAddons 'scripts\Repair-LpHashdTerminalFbxEmbeddedPaths.ps1'
    if (-not (Test-Path -LiteralPath $repair)) {
        Write-Host '  skip hashdterminal.fbx repair (script missing)' -ForegroundColor Yellow
        return
    }
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $repair -FbxPath $FbxPath
    if ($LASTEXITCODE -ne 0) { throw 'Repair-LpHashdTerminalFbxEmbeddedPaths.ps1 failed' }
}

function Remove-StaleHashdTerminalCompile {
    param([string]$HashdRoot)
    if (-not (Test-Path -LiteralPath $HashdRoot)) { return }
    $models = Join-Path $HashdRoot 'assets\models'
    # Legacy slot names only — do NOT delete hashdterminal.vmdl_c (repo ships compiled _c; MIR already syncs it).
    foreach ($name in @('hashd-terminal.vmdl_c', 'hashd-terminal.vmdl')) {
        $path = Join-Path $models $name
        if (Test-Path -LiteralPath $path) {
            Remove-StaleDxrpPath -Path $path -Label "stale legacy compile/source: $name"
        }
    }
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
Write-Host '  Canonical editor path: D:\Steam\steamapps\common\sbox\dxrp\game (repo MIR).' -ForegroundColor DarkGray
Write-Host '  OneDrive addon test is opt-in only: Start-SboxDxrpEditor.ps1 -OwnerEditorLane' -ForegroundColor DarkGray
Write-Host "  Repo:  $repoAddons" -ForegroundColor DarkGray
Write-Host "  DXRP:  $dxrpGame" -ForegroundColor DarkGray

if (-not $WhatIf) {
    Write-Host 'Purge DXRP-only clutter (not in repo sync set)' -ForegroundColor Cyan
    Remove-StaleDxrpPath -Path (Join-Path $dxrpGame 'Code\Addons\lifepunch._quarantine') -Label 'Code/Addons/lifepunch._quarantine'
    Remove-StaleDxrpPath -Path (Join-Path $dxrpGame 'Assets\addons\lifepunch._quarantine') -Label 'Assets/addons/lifepunch._quarantine'
    Remove-StaleDxrpPath -Path (Join-Path $dxrpGame 'addons\lifepunch\lpbitcoin') -Label 'addons/lifepunch/lpbitcoin (empty greenfield stub)'
    # lifepunchulx is the DXRP folder for repo adminmenu (package slug). Purge only when not syncing adminmenu.
    $syncIdents = @(Get-AddonIdents)
    if ($syncIdents -notcontains 'adminmenu') {
        Remove-StaleDxrpPath -Path (Join-Path $dxrpCodeRoot 'lifepunchulx') -Label 'Code/lifepunchulx (adminmenu not in sync set)'
        Remove-StaleDxrpPath -Path (Join-Path $dxrpAssetsRoot 'lifepunchulx') -Label 'Assets/lifepunchulx (adminmenu not in sync set)'
    }
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
        $staffMenuDevReady = $syncedIdents -contains 'adminmenu'
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

        $staffMenuDevFiles = @('StaffMenuTestBots.cs', 'StaffMenuTestBotsAutoSpawn.cs')
        $devRoot = Join-Path $dxrpCodeRoot '_dev'
        if (Test-Path -LiteralPath $devRoot) {
            if (-not $staffMenuDevReady) {
                foreach ($devFile in $staffMenuDevFiles) {
                    $active = Join-Path $devRoot $devFile
                    if (-not (Test-Path -LiteralPath $active)) { continue }
                    $quarantine = "$active.quarantine"
                    if (Test-Path -LiteralPath $quarantine) {
                        Remove-Item -LiteralPath $quarantine -Force
                    }
                    Rename-Item -LiteralPath $active -NewName ($devFile + '.quarantine') -Force
                    Write-Host "  Code/_dev: $devFile quarantined (adminmenu not in sync set; needs StaffMenuHost)" -ForegroundColor Yellow
                }
            }
            else {
                foreach ($devFile in $staffMenuDevFiles) {
                    $quarantine = Join-Path $devRoot ($devFile + '.quarantine')
                    $restore = Join-Path $devRoot $devFile
                    if ((Test-Path -LiteralPath $quarantine) -and -not (Test-Path -LiteralPath $restore)) {
                        Rename-Item -LiteralPath $quarantine -NewName $devFile -Force
                        Write-Host "  Code/_dev: restored $devFile (adminmenu lane)" -ForegroundColor Green
                    }
                }
            }
        }

        $bitcoinDevReady = @($syncedIdents | Where-Object { $_ -in @('bitcoinmining', 'lpbitcoin', 'lifepunchbitcoin') }).Count -gt 0
        if (Test-Path -LiteralPath $devRoot) {
            $bitcoinDevPatterns = @('LpBitcoin*.cs', 'LpBitcoin*.razor', 'LpBitcoin*.scss')
            if (-not $bitcoinDevReady) {
                foreach ($pattern in $bitcoinDevPatterns) {
                    Get-ChildItem -LiteralPath $devRoot -File -Filter $pattern -ErrorAction SilentlyContinue |
                        Where-Object { $_.Name -notlike '*.quarantine' } |
                        ForEach-Object {
                            $active = $_.FullName
                            $quarantine = "$active.quarantine"
                            if (Test-Path -LiteralPath $quarantine) {
                                Remove-Item -LiteralPath $quarantine -Force
                            }
                            Rename-Item -LiteralPath $active -NewName ($_.Name + '.quarantine') -Force
                            Write-Host "  Code/_dev: $($_.Name) quarantined (bitcoinmining not in sync set)" -ForegroundColor Yellow
                        }
                }
            }
            else {
                Get-ChildItem -LiteralPath $devRoot -File -ErrorAction SilentlyContinue |
                    Where-Object { $_.Name -like 'LpBitcoin*' -and $_.Name -like '*.quarantine' } |
                    ForEach-Object {
                        $restore = Join-Path $devRoot ($_.Name -replace '\.quarantine$', '')
                        if (-not (Test-Path -LiteralPath $restore)) {
                            Rename-Item -LiteralPath $_.FullName -NewName ($_.Name -replace '\.quarantine$', '') -Force
                            Write-Host "  Code/_dev: restored $($_.Name -replace '\.quarantine$','')" -ForegroundColor Green
                        }
                    }
            }
        }
    }
}

foreach ($ident in Get-AddonIdents) {
    if ($ident -eq 'adminmenu') {
        Sync-LifepunchUlxToDxrp
        continue
    }
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
            Remove-LegacyAddonTestArtifacts -LpBitcoinRoot $assetsDest
            Remove-StaleDxrpPath -Path (Join-Path $assetsDest 'advancedgpurack') -Label 'Assets/lpbitcoin/advancedgpurack (retired slot)'
            $hashdFbxRepo = Join-Path $assetsSrc 'hashdterminal\assets\source\fbx\hashdterminal.fbx'
            Repair-HashdTerminalFbx -FbxPath $hashdFbxRepo
        }
    }
    else {
        Write-Host "  Assets/$assetIdent - skip (missing repo folder)" -ForegroundColor DarkGray
    }
    $codeSrc = Join-Path $repoCodeRoot $codeIdent
    if (Test-Path -LiteralPath $codeSrc) {
        $codeDest = Join-Path $dxrpCodeRoot $codeIdent
        Invoke-Mirror `
            -From $codeSrc `
            -To   $codeDest `
            -Label "Code/$codeIdent"
        if ($ident -eq 'adminmenu' -and -not $WhatIf) {
            foreach ($devOnly in @('StaffMenuTestBots.cs', 'StaffMenuTestBotsAutoSpawn.cs')) {
                $stale = Join-Path $codeDest $devOnly
                if (Test-Path -LiteralPath $stale) {
                    Remove-Item -LiteralPath $stale -Force
                    Write-Host "  Code/adminmenu: removed $devOnly (editor-only - lives in Code/_dev)" -ForegroundColor Yellow
                }
            }
        }
    }
    else {
        Write-Host "  Code/$codeIdent - skip (no repo folder)" -ForegroundColor DarkGray
    }
}

# Publish staging packages (lp*) — only when bitcoin lane is in the sync set.
$syncedIdents = @(Get-AddonIdents)
$bitcoinLaneSync = @($syncedIdents | Where-Object { $_ -in @('bitcoinmining', 'lpbitcoin', 'lifepunchbitcoin') }).Count -gt 0
$lpStagingRoot = Join-Path $repoAssetsRoot 'lpbitcoin'
if ($bitcoinLaneSync -and (Test-Path -LiteralPath $lpStagingRoot)) {
    Write-Host 'Staging: lpbitcoin' -ForegroundColor Cyan
    $lpDest = Join-Path $dxrpAssetsRoot 'lpbitcoin'
    Invoke-Mirror `
        -From $lpStagingRoot `
        -To   $lpDest `
        -Label 'Assets/lpbitcoin'
    Remove-LpArchiveCompileArtifacts -LpBitcoinRoot $lpDest
    Remove-LegacyAddonTestArtifacts -LpBitcoinRoot $lpDest
    Remove-StaleDxrpPath -Path (Join-Path $lpDest 'advancedgpurack') -Label 'Assets/lpbitcoin/advancedgpurack (retired slot)'
    $btcRedeemEntities = Join-Path $lpDest 'bitcoinhub\assets\entities'
    if (Test-Path -LiteralPath $btcRedeemEntities) {
        Get-ChildItem -LiteralPath $btcRedeemEntities -File -Force -Filter 'btccashredeem*' -ErrorAction SilentlyContinue |
            ForEach-Object {
                Remove-StaleDxrpPath -Path $_.FullName -Label "parked btccashredeem ($($_.Name))"
            }
    }
    $hashdFbxDxrp = Join-Path $lpDest 'hashdterminal\assets\source\fbx\hashdterminal.fbx'
    Repair-HashdTerminalFbx -FbxPath $hashdFbxDxrp
    Remove-StaleHashdTerminalCompile -HashdRoot (Join-Path $lpDest 'hashdterminal')
}

$lpCodeRoot = Join-Path $repoCodeRoot 'lpbitcoin'
if ($bitcoinLaneSync -and (Test-Path -LiteralPath $lpCodeRoot)) {
    Write-Host 'Staging code map: lpbitcoin' -ForegroundColor Cyan
    Invoke-Mirror `
        -From $lpCodeRoot `
        -To   (Join-Path $dxrpCodeRoot 'lpbitcoin') `
        -Label 'Code/lpbitcoin (README maps — sources in bitcoinmining/)'
}

$ensureResources = Join-Path $Here 'Ensure-DxrpLifepunchResources.ps1'
if (Test-Path -LiteralPath $ensureResources) {
    $ensureArgs = @{
        Ident      = (Get-AddonIdents)
        ConfigPath = $ConfigPath
    }
    if ($bitcoinLaneSync) {
        $ensureArgs['IncludeStaging'] = $true
    }
    & $ensureResources @ensureArgs
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
Write-Host '  Recompile in ModelDoc: bitcoinhub.vmdl, gpurack.vmdl, advancedgpurack.vmdl, hashdterminal.vmdl, then entity prefabs.' -ForegroundColor DarkGray
