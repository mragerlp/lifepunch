<#
.SYNOPSIS
  Refresh Desktop\lifepunchaddons\publish\<packageSlug> from monorepo prepare-publish staging.

.DESCRIPTION
  Bloodwave local organization — NOT a second source of truth.
  Runs prepare-publish.ps1, copies upload tree to the desktop, renames repo ident folder
  to packageSlug (portal/DXRP mount law), and writes portal-fields.json + UPLOAD_README.md.

.PARAMETER Addon
  Monorepo ident (e.g. adminmenu). Default: all entries in portfolio publishReadyAddons.

.PARAMETER DesktopRoot
  Root of the desktop workspace. Default: %USERPROFILE%\Desktop\lifepunch

.EXAMPLE
  powershell -File lifepunch\scripts\Sync-DesktopPublishFolder.ps1 -Addon adminmenu
#>
[CmdletBinding()]
param(
    [string] $Addon = '',
    [string] $DesktopRoot = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$RepoRoot = (Resolve-Path (Join-Path $Here '..')).Path
$AddonsRoot = (Resolve-Path (Join-Path $Here '..\..\lifepunchaddons')).Path
$PrepareScript = Join-Path $AddonsRoot 'scripts\prepare-publish.ps1'
$ManifestPath = Join-Path $AddonsRoot 'config\addons.json'
$PortfolioPath = Join-Path $AddonsRoot 'config\portfolio.json'

if (-not $DesktopRoot) {
    # Use the shell Desktop (OneDrive-redir on VENGEANCE), not %USERPROFILE%\Desktop when they differ.
    $DesktopRoot = Join-Path ([Environment]::GetFolderPath('Desktop')) 'lifepunch'
}

$Manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
$Portfolio = Get-Content -LiteralPath $PortfolioPath -Raw | ConvertFrom-Json

$Targets = if ($Addon) {
    @($Addon)
} else {
    @($Portfolio.publishReadyAddons)
}

function Get-PackageSlug {
    param([string] $Ident)
    $entry = @($Manifest.addons) | Where-Object { $_.ident -eq $Ident } | Select-Object -First 1
    if ($entry.packageSlug) { return [string]$entry.packageSlug }
    return $Ident
}

function Copy-UploadTree {
    param(
        [string] $SourceUpload,
        [string] $DestUpload,
        [string] $RepoIdent,
        [string] $PackageSlug
    )

    if (Test-Path -LiteralPath $DestUpload) {
        Remove-Item -LiteralPath $DestUpload -Recurse -Force
    }

    if (-not (Test-Path -LiteralPath $SourceUpload)) {
        throw "Missing staging upload root: $SourceUpload (run prepare-publish first)"
    }

    # Robocopy mirror, then rename ident -> packageSlug in DXRP paths
    & robocopy $SourceUpload $DestUpload /MIR /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy to desktop failed ($LASTEXITCODE)" }

    $renamePairs = @(
        @{ From = "Code\Addons\lifepunch\$RepoIdent"; To = "Code\Addons\lifepunch\$PackageSlug" },
        @{ From = "Assets\addons\lifepunch\$RepoIdent"; To = "Assets\addons\lifepunch\$PackageSlug" }
    )

    foreach ($pair in $renamePairs) {
        $from = Join-Path $DestUpload $pair.From
        $to = Join-Path $DestUpload $pair.To
        if ((Test-Path -LiteralPath $from) -and ($RepoIdent -ne $PackageSlug)) {
            New-Item -ItemType Directory -Force -Path (Split-Path -Parent $to) | Out-Null
            Move-Item -LiteralPath $from -Destination $to -Force
        }
    }
}

foreach ($ident in $Targets) {
    $pkg = @($Manifest.addons) | Where-Object { $_.ident -eq $ident } | Select-Object -First 1
    if ($null -eq $pkg) { throw "Unknown addon ident '$ident' in addons.json" }

    $slug = Get-PackageSlug -Ident $ident
    Write-Host "Prepare publish: $ident -> desktop publish/$slug" -ForegroundColor Cyan

    & $PrepareScript -Addon $ident

    $sourceUpload = Join-Path $AddonsRoot '.dxrp-publish\upload'
    $publishRoot = Join-Path $DesktopRoot "addons\publish\$slug"
    $destUpload = Join-Path $publishRoot 'upload'
    New-Item -ItemType Directory -Force -Path $publishRoot | Out-Null

    Copy-UploadTree -SourceUpload $sourceUpload -DestUpload $destUpload -RepoIdent $ident -PackageSlug $slug

    $gitSha = ''
    $gitDate = ''
    try {
        Push-Location $RepoRoot
        $gitSha = (git rev-parse --short HEAD 2>$null)
        $gitDate = (git log -1 --format='%ci' 2>$null)
        Pop-Location
    } catch {
        Pop-Location -ErrorAction SilentlyContinue
    }

    $portalFields = [ordered]@{
        schemaVersion = 1
        generatedAt = (Get-Date).ToString('o')
        gitCommit = $gitSha
        gitCommitDate = $gitDate
        packageSlug = $slug
        repoIdent = $ident
        portal = [ordered]@{
            title = $pkg.title
            description = $pkg.description
            dxrpAddonId = $pkg.dxrpAddonId
            dxrpAddonIdentifier = $pkg.dxrpAddonIdentifier
            sboxIdentifier = $pkg.sboxIdentifier
            kind = $pkg.kind
            marketingVersion = '2.0.0'
        }
        inGame = [ordered]@{
            consoleCommand = 'lifepunchulx'
            chatCommand = '/lifepunchulx'
            settingsPermission = 'lifepunchulx.settings.edit'
            bindExample = 'bind f4 lifepunchulx'
        }
        upload = [ordered]@{
            codeRoot = "upload\Code\Addons\lifepunch\$slug"
            assetsRoot = if ($pkg.hasAssets) { "upload\Assets\addons\lifepunch\$slug" } else { $null }
            codeOnly = -not [bool]$pkg.hasAssets
            contentRows = @($pkg.contents).Count
        }
        sourceOfTruth = $RepoRoot
    }

    $portalFields | ConvertTo-Json -Depth 6 |
        Set-Content -LiteralPath (Join-Path $publishRoot 'portal-fields.json') -Encoding UTF8

    Copy-Item -LiteralPath (Join-Path $AddonsRoot ".dxrp-publish\package-$ident.json") `
        -Destination (Join-Path $publishRoot 'package-export.json') -Force

    @"
syncedFrom=$gitSha
syncedAt=$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
repoIdent=$ident
packageSlug=$slug
"@ | Set-Content -LiteralPath (Join-Path $publishRoot 'SYNC_FROM.txt') -Encoding UTF8

    $codeCount = (Get-ChildItem -LiteralPath $destUpload -Recurse -File -ErrorAction SilentlyContinue).Count
    Write-Host "  Desktop: $publishRoot ($codeCount files under upload/)" -ForegroundColor Green

    $assetsLine = if ($pkg.hasAssets) {
        "``upload\Assets\addons\lifepunch\$slug\``"
    } else {
        '**None** - code-only package. Skip Assets upload or leave empty.'
    }

    $uploadReadme = @"
# $slug - DXRP portal upload (local desktop copy)

**Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm')  
**Monorepo commit:** $gitSha  
**Source of truth:** ``$RepoRoot`` (not this folder)

## What to upload

| Portal field | Value |
|--------------|-------|
| Package title | $($pkg.title) |
| Identifier | $($pkg.dxrpAddonIdentifier) |
| Existing package ID | $($pkg.dxrpAddonId) |
| s&box ident | $($pkg.sboxIdentifier) |
| Kind | $($pkg.kind) |

### Code root (required)

Point the portal **Code** upload at:

``upload\Code\Addons\lifepunch\$slug\``

### Assets root

$assetsLine

## In-game

- Console: ``lifepunchulx``
- Chat: ``/lifepunchulx``
- Bind example: ``bind f4 lifepunchulx``
- Owner settings permission: ``lifepunchulx.settings.edit`` (grant in DXRP portal ranks)

## Portal checklist

1. Publish new **revision** from this ``upload/`` tree (never ``upload-assets`` / ``upload-code`` flat folders).
2. Confirm compiled ``_c`` if you added assets later (ULX v1 is code-only).
3. Pin revision on LifePunch gamemode (development server first).
4. Grant ``lifepunchulx.settings.edit`` to Owner (or ranks that may edit website URL).
5. Smoke test: join dev server, run ``/lifepunchulx``, confirm menu opens and clicks work.

## Refresh this folder

```powershell
powershell -File lifepunch\scripts\Sync-DesktopPublishFolder.ps1 -Addon $ident
```

See ``portal-fields.json`` and ``package-export.json`` for machine-readable field values.
"@
    Set-Content -LiteralPath (Join-Path $publishRoot 'UPLOAD_README.md') -Value $uploadReadme -Encoding UTF8

    $ownershipNotice = @"
LIFEPUNCH(tm) PROPRIETARY NOTICE
============================

Package: $($pkg.title) ($slug)
Publisher: lifepunch.co (PEAK PERFORMANCE PRODUCTS LLC)
s&box ident: $($pkg.sboxIdentifier)
DXRP addon ident: $($pkg.dxrpAddonIdentifier)

$($pkg.ownership)

Every source file in this upload tree carries the matching proprietary header.
Server operators may use this addon on their DXRP server under portal terms;
redistribution, resale, sublicensing, or reuse of source or compiled output
by third parties is not permitted.

Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm') - Monorepo: $gitSha
"@
    $utf8Bom = New-Object System.Text.UTF8Encoding $true
    [IO.File]::WriteAllText((Join-Path $publishRoot 'INTELLECTUAL_PROPERTY.txt'), $ownershipNotice, $utf8Bom)
}

Write-Host ''
Write-Host "Desktop publish folders refreshed under $DesktopRoot\addons\publish" -ForegroundColor Cyan
