<#
.SYNOPSIS
  Initialize UPLOAD READY ADDONS tree: canonical lp* names, entity skeleton, ModelDoc files from repo.

.EXAMPLE
  powershell -File lifepunchaddons\scripts\Initialize-UploadReadyAddons.ps1
  powershell -File lifepunchaddons\scripts\Initialize-UploadReadyAddons.ps1 -TargetRoot "C:\Users\jared\OneDrive\Desktop\UPLOAD READY ADDONS"
#>
[CmdletBinding()]
param(
    [string] $TargetRoot = "$env:USERPROFILE\OneDrive\Desktop\UPLOAD READY ADDONS",
    [switch] $IncludeCode
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$AddonsRoot = Split-Path $Here -Parent
$repoStaging = Join-Path $AddonsRoot 'Assets\addons\lifepunch'
$configPath = Join-Path $AddonsRoot 'config\package-staging.json'
$config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
$placeScript = Join-Path $Here 'Place-LifepunchModelDocAssets.ps1'

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
    }
}

function Ensure-EntitySkeleton([string]$EntityPath) {
    foreach ($sub in @(
        'assets\source\fbx', 'assets\source\blend', 'assets\source\obj',
        'assets\textures', 'assets\models', 'assets\entities', 'assets\sounds', 'assets\ui',
        'code\components', 'code\ui', 'code\docs', 'audit', 'docs'
    )) {
        Ensure-Dir (Join-Path $EntityPath $sub)
    }
}

function Move-LegacyPackageName {
    param([string]$Root, [string]$OldName, [string]$NewName)
    $oldPath = Join-Path $Root $OldName
    $newPath = Join-Path $Root $NewName
    if (-not (Test-Path -LiteralPath $oldPath)) { return }
    if (Test-Path -LiteralPath $newPath) {
        Write-Host "  merge $OldName -> $NewName (target exists)" -ForegroundColor DarkYellow
        Get-ChildItem $oldPath -Directory | ForEach-Object {
            $dest = Join-Path $newPath $_.Name
            if (-not (Test-Path $dest)) {
                Move-Item $_.FullName $dest -Force
            }
        }
        if (@(Get-ChildItem $oldPath -Force).Count -eq 0) {
            Remove-Item $oldPath -Force -ErrorAction SilentlyContinue
        }
        return
    }
    Rename-Item -LiteralPath $oldPath -NewName $NewName -Force
    Write-Host "  renamed $OldName -> $NewName" -ForegroundColor Green
}

if (-not (Test-Path -LiteralPath $TargetRoot)) {
    throw "Missing target root: $TargetRoot"
}

$PackageRoot = Join-Path $TargetRoot 'addons\lifepunch'
Ensure-Dir $PackageRoot

Write-Host "Initialize UPLOAD READY ADDONS" -ForegroundColor Cyan
Write-Host "  Target: $TargetRoot" -ForegroundColor DarkGray
Write-Host "  Packages: $PackageRoot" -ForegroundColor DarkGray
Write-Host "  Source: $repoStaging" -ForegroundColor DarkGray

# Canonical package folder names (migrate legacy flat layout under PackageRoot)
Move-LegacyPackageName -Root $PackageRoot -OldName 'lpbitcoinmining' -NewName 'lpbitcoin'
Move-LegacyPackageName -Root $PackageRoot -OldName 'lppolicehacker' -NewName 'lppolice'
# If owner had lp* at TargetRoot root (legacy flat layout), merge into addons/lifepunch
Get-ChildItem -LiteralPath $TargetRoot -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -like 'lp*' } |
    ForEach-Object {
        $dest = Join-Path $PackageRoot $_.Name
        if (-not (Test-Path -LiteralPath $dest)) {
            Move-Item -LiteralPath $_.FullName -Destination $dest -Force
            Write-Host "  moved $($_.Name) -> addons\lifepunch\$($_.Name)" -ForegroundColor Green
            return
        }
        Get-ChildItem -LiteralPath $_.FullName -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            $entityDest = Join-Path $dest $_.Name
            if (-not (Test-Path -LiteralPath $entityDest)) {
                Move-Item -LiteralPath $_.FullName -Destination $entityDest -Force
            }
        }
        if (@(Get-ChildItem -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue).Count -eq 0) {
            Remove-Item -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue
        }
    }

@(
    'Package staging for LIFEPUNCH upload-ready zips.',
    'Layout: addons/lifepunch/{lpPackage}/{entitySlot}/assets|code|audit',
    'Law: addons/docs/PACKAGE_STAGING_LAYOUT.md',
    'Populate from repo: Initialize-UploadReadyAddons.ps1',
    '',
    'Canonical packages: lpbitcoin lphacker lppolice lpgovernment lpblackmarket lpbanker lpflashdrive lpweapons lpchemist lpdrugdrops'
) | Set-Content -LiteralPath (Join-Path $TargetRoot 'README.txt') -Encoding UTF8

foreach ($pkgProp in $config.packages.PSObject.Properties) {
    $pkg = $pkgProp.Name
    $pkgPath = Join-Path $PackageRoot $pkg
    Ensure-Dir $pkgPath

    foreach ($entProp in $pkgProp.Value.entities.PSObject.Properties) {
        $entity = $entProp.Name
        $entityPath = Join-Path $pkgPath $entity
        Ensure-Dir $entityPath
        Ensure-EntitySkeleton $entityPath
    }

    if (-not (Test-Path -LiteralPath (Join-Path $repoStaging $pkg))) {
        Write-Host "  WARN no repo source for $pkg" -ForegroundColor Yellow
        continue
    }

    $placeArgs = @{
        Package    = $pkg
        TargetRoot = $PackageRoot
    }
    if ($IncludeCode) { $placeArgs['IncludeCode'] = $true }
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $placeScript @placeArgs
}

# Placeholder lanes on Desktop (flash drive splits)
foreach ($placeholder in @('lpflashdrive\bitcoinusb', 'lpflashdrive\hackerusb')) {
    $p = Join-Path $PackageRoot ($placeholder -replace '\\', '\')
    if (-not (Test-Path -LiteralPath $p)) { continue }
    Ensure-EntitySkeleton $p
    @"
# $(Split-Path $placeholder -Leaf)

Gameplay placeholder — canonical mesh/textures live in usbflashdrive/.
Do not delete usbflashdrive color variants.
"@ | Set-Content -LiteralPath (Join-Path $p 'docs\README.md') -Encoding UTF8
}

Write-Host ''
Write-Host 'Done. Canonical folders: lpbitcoin (not lpbitcoinmining), lppolice (not lppolicehacker).' -ForegroundColor Cyan
Write-Host 'ModelDoc Studio: Start-SboxModelDocStudio.ps1 -TargetRoot can point here after copy.' -ForegroundColor DarkGray
