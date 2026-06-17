<#
.SYNOPSIS
  Migrate _modeldoc/{lpPackage}/{slot}/game/ to {lpPackage}/{slot}/assets|code layout.

.EXAMPLE
  powershell -File lifepunch\addons\scripts\Migrate-ModeldocToPackageStaging.ps1
#>
[CmdletBinding()]
param(
    [string] $AssetsRoot = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$AddonsRoot = Split-Path $Here -Parent
if (-not $AssetsRoot) {
    $AssetsRoot = Join-Path $AddonsRoot 'Assets\addons\lifepunch'
}
$configPath = Join-Path $AddonsRoot 'config\package-staging.json'
$config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json

$legacyMap = @{}
$config.legacyDesktopFolderMap.PSObject.Properties | ForEach-Object { $legacyMap[$_.Name] = $_.Value }

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
    }
}

function Move-Tree {
    param([string]$From, [string]$To)
    if (-not (Test-Path -LiteralPath $From)) { return }
    Ensure-Dir (Split-Path $To -Parent)
    if (Test-Path -LiteralPath $To) { Remove-Item -LiteralPath $To -Recurse -Force }
    Move-Item -LiteralPath $From -Destination $To -Force
}

function Copy-Tree {
    param([string]$From, [string]$To)
    if (-not (Test-Path -LiteralPath $From)) { return }
    Ensure-Dir $To
    & robocopy $From $To /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy failed: $From" }
}

function New-EntitySkeleton {
    param([string]$EntityPath)
    foreach ($sub in @('assets\source\fbx', 'assets\source\blend', 'assets\source\obj', 'assets\textures', 'assets\models', 'assets\entities', 'assets\sounds', 'assets\ui', 'code\components', 'code\ui', 'code\docs', 'audit', 'docs')) {
        Ensure-Dir (Join-Path $EntityPath $sub)
    }
}

function Rewrite-ManifestPaths {
    param([string]$ManifestPath)
    if (-not (Test-Path -LiteralPath $ManifestPath)) { return }
    $raw = Get-Content -LiteralPath $ManifestPath -Raw
    $raw = $raw -replace 'game/source/', 'assets/source/'
    $raw = $raw -replace 'game/textures/', 'assets/textures/'
    Set-Content -LiteralPath $ManifestPath -Value $raw -Encoding UTF8
}

function Write-EntityCodeManifest {
    param(
        [string]$EntityPath,
        [string]$PackageFolder,
        [string]$EntitySlot
    )
    $codeManifestPath = Join-Path $EntityPath 'code\manifest.json'
    $legacyIdent = [string]$config.packages.$PackageFolder.repoIdent
    $files = @()
    $shared = @()
    if ($config.bitcoinCodeMap) {
        if ($config.bitcoinCodeMap.$EntitySlot) { $files = @($config.bitcoinCodeMap.$EntitySlot) }
        if ($config.bitcoinCodeMap.shared) { $shared = @($config.bitcoinCodeMap.shared) }
    }
    $data = @{
        entitySlot = $EntitySlot
        packageFolder = $PackageFolder
        legacyRepoIdent = $legacyIdent
        legacyCodeRoot = "Code/Addons/lifepunch/$legacyIdent"
        entityFiles = $files
        sharedPackageFiles = $shared
        note = 'Physical code move happens on promotion. DXRP lane does not compile entity code from staging.'
    }
    ($data | ConvertTo-Json -Depth 4) | Set-Content -LiteralPath $codeManifestPath -Encoding UTF8
}

Write-Host 'Migrate _modeldoc -> publish-aligned lp* staging' -ForegroundColor Cyan

$modelDocRoot = Join-Path $AssetsRoot '_modeldoc'
$devRoot = Join-Path $AssetsRoot '_dev'
Ensure-Dir $devRoot
Ensure-Dir (Join-Path $devRoot 'scenes')

# scenes
$sceneSrc = Join-Path $modelDocRoot 'scenes\lifepunch-modeldoc.scene'
$sceneDst = Join-Path $devRoot 'scenes\lifepunch-modeldoc.scene'
if (Test-Path -LiteralPath $sceneSrc) {
    Copy-Item -LiteralPath $sceneSrc -Destination $sceneDst -Force
}

if (-not (Test-Path -LiteralPath $modelDocRoot)) {
    Write-Host 'No _modeldoc folder - nothing to migrate.' -ForegroundColor Yellow
    return
}

Get-ChildItem -LiteralPath $modelDocRoot -Directory | Where-Object { $_.Name -notin @('scenes', 'universal') } | ForEach-Object {
    $oldPkg = $_.Name
    $newPkg = if ($legacyMap.ContainsKey($oldPkg)) { $legacyMap[$oldPkg] } else { $oldPkg }
    $destPkg = Join-Path $AssetsRoot $newPkg
    Ensure-Dir $destPkg

    # package-level audit artifacts
    foreach ($leaf in @('issues.md', 'duplicate_report.md')) {
        $from = Join-Path $_.FullName $leaf
        if (Test-Path -LiteralPath $from) {
            $to = Join-Path $destPkg $leaf
            Copy-Item -LiteralPath $from -Destination $to -Force
        }
    }
    $pkgAudit = Join-Path $_.FullName 'audit'
    if (Test-Path -LiteralPath $pkgAudit) {
        Copy-Tree $pkgAudit (Join-Path $destPkg 'audit')
    }

    Get-ChildItem -LiteralPath $_.FullName -Directory | Where-Object { $_.Name -ne 'audit' } | ForEach-Object {
        $slot = $_.Name
        $srcSlot = $_.FullName
        $destSlot = Join-Path $destPkg $slot
        Write-Host "  $oldPkg/$slot -> $newPkg/$slot" -ForegroundColor Green
        New-EntitySkeleton $destSlot

        $game = Join-Path $srcSlot 'game'
        if (Test-Path -LiteralPath $game) {
            Move-Tree (Join-Path $game 'source') (Join-Path $destSlot 'assets\source')
            Move-Tree (Join-Path $game 'textures') (Join-Path $destSlot 'assets\textures')
            if (Test-Path -LiteralPath $game) {
                if (@(Get-ChildItem $game -Recurse -Force).Count -eq 0) { Remove-Item $game -Recurse -Force }
            }
        }

        # vmdl + model docs at slot root -> assets/models
        Get-ChildItem -LiteralPath $srcSlot -File -ErrorAction SilentlyContinue | ForEach-Object {
            if ($_.Extension -in '.vmdl', '.md', '.json') {
                $to = Join-Path (Join-Path $destSlot 'assets\models') $_.Name
                Move-Item -LiteralPath $_.FullName -Destination $to -Force
            }
        }

        $slotAudit = Join-Path $srcSlot 'audit'
        if (Test-Path -LiteralPath $slotAudit) {
            Copy-Tree $slotAudit (Join-Path $destSlot 'audit')
        }
        $slotDocs = Join-Path $srcSlot 'docs'
        if (Test-Path -LiteralPath $slotDocs) {
            Copy-Tree $slotDocs (Join-Path $destSlot 'docs')
        }

        Rewrite-ManifestPaths (Join-Path $destSlot 'audit\manifest.json')
        Write-EntityCodeManifest -EntityPath $destSlot -PackageFolder $newPkg -EntitySlot $slot

        # fix vmdl mesh paths inside models/
        Get-ChildItem (Join-Path $destSlot 'assets\models') -Filter '*.vmdl' -File -ErrorAction SilentlyContinue | ForEach-Object {
            $vraw = Get-Content $_.FullName -Raw
            $vraw = $vraw -replace 'addons/lifepunch/_modeldoc/', 'addons/lifepunch/'
            $vraw = $vraw -replace "/$oldPkg/", "/$newPkg/"
            $vraw = $vraw -replace 'game/source/', 'assets/source/'
            Set-Content -LiteralPath $_.FullName -Value $vraw -Encoding UTF8
        }
    }
}

# README redirect at _modeldoc
$redirect = @"
# DEPRECATED — moved to publish-aligned staging

Model intake now lives under:

``Assets/addons/lifepunch/lpbitcoin/bitcoinhub/`` (etc.)

See ``addons/docs/PACKAGE_STAGING_LAYOUT.md`` and ``config/package-staging.json``.
"@
Set-Content -LiteralPath (Join-Path $modelDocRoot 'README.md') -Value $redirect -Encoding UTF8

Write-Host 'Migration complete.' -ForegroundColor Cyan
Write-Host 'Next: rename Desktop lpbitcoinmining -> lpbitcoin (optional); run Normalize + Sync + lane script.' -ForegroundColor DarkGray
