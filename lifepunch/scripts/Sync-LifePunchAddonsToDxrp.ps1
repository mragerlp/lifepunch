<#
.SYNOPSIS
  Mirror LifePunch addon source from the monorepo into the local DXRP game project.

.DESCRIPTION
  Repo is source of truth (lifepunch/addons). DXRP editor reads:
    <dxrp-game>/Assets/addons/lifepunch/<ident>/
    <dxrp-game>/Code/Addons/lifepunch/<ident>/

  Uses robocopy /MIR so stale folders (e.g. legacy gpu-rack paths after rename) are removed.

.PARAMETER Addon
  One or more addon idents (e.g. bitcoinmining). Default: bitcoinmining.

.PARAMETER All
  Sync every lifepunch ident that exists under Assets/addons/lifepunch in the repo.

.EXAMPLE
  powershell -File Sync-LifePunchAddonsToDxrp.ps1
  powershell -File Sync-LifePunchAddonsToDxrp.ps1 -Addon ak47,bitcoinmining
  powershell -File Sync-LifePunchAddonsToDxrp.ps1 -All
#>
[CmdletBinding()]
param(
    [string[]] $Addon = @('bitcoinmining'),
    [switch] $All,
    [string] $ConfigPath = '',
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
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

function Get-AddonIdents {
    if ($All) {
        return @(Get-ChildItem -LiteralPath $repoAssetsRoot -Directory | ForEach-Object { $_.Name })
    }
    return $Addon
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

Write-Host 'Sync LifePunch addons -> DXRP game' -ForegroundColor Cyan
Write-Host "  Repo:  $repoAddons" -ForegroundColor DarkGray
Write-Host "  DXRP:  $dxrpGame" -ForegroundColor DarkGray

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
    $assetsSrc = Join-Path $repoAssetsRoot $ident
    if (Test-Path -LiteralPath $assetsSrc) {
        Invoke-Mirror `
            -From $assetsSrc `
            -To   (Join-Path $dxrpAssetsRoot $ident) `
            -Label "Assets/$ident"
    }
    else {
        Write-Host "  Assets/$ident - skip (code-only addon)" -ForegroundColor DarkGray
    }
    $codeSrc = Join-Path $repoCodeRoot $ident
    if (Test-Path -LiteralPath $codeSrc) {
        Invoke-Mirror `
            -From $codeSrc `
            -To   (Join-Path $dxrpCodeRoot $ident) `
            -Label "Code/$ident"
    }
    else {
        Write-Host "  Code/$ident - skip (no repo folder)" -ForegroundColor DarkGray
    }
}

$ensureResources = Join-Path $Here 'Ensure-DxrpLifepunchResources.ps1'
if (Test-Path -LiteralPath $ensureResources) {
    & $ensureResources -Ident (Get-AddonIdents) -ConfigPath $ConfigPath
}

Write-Host 'Sync OK' -ForegroundColor Green
