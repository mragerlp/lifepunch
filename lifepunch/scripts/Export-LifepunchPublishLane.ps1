# =====================================================================
# RISK: SYNC/PUSH  |  GO: BLOODWAVE GO REQUIRED
# NODE: Red only  |  BRANCH: main (publish-ready export set only)
# PRE:  clean tree on the right branch; grounded per START_HERE_AGENTS.md
# WHAT: Export publishReadyAddons from the monorepo to the LIFEPUNCH publish lane repo.
# =====================================================================
<#
.SYNOPSIS
  Export active portfolio addons from core monorepo to LIFEPUNCH publish lane repo.

.DESCRIPTION
  Reads lifepunchaddons/config/portfolio.json publishReadyAddons (fallback: activeAddons).
  Copies ship-ready Assets + Code (same filters as prepare-publish.ps1).
  Writes slim addons.json + SYNC_FROM.md.

.EXAMPLE
  powershell -File lifepunch\scripts\Export-LifepunchPublishLane.ps1 -Init -Target C:\Users\jared\Projects\lifepunchdxrp-published
  powershell -File lifepunch\scripts\Export-LifepunchPublishLane.ps1 -Target C:\Users\jared\Projects\lifepunchdxrp-published
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $Target,
    [switch] $Init
)

$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$AddonsRoot = Join-Path $RepoRoot 'lifepunchaddons'
$PortfolioPath = Join-Path $AddonsRoot 'config\portfolio.json'
$ManifestPath = Join-Path $AddonsRoot 'config\addons.json'
$ScaffoldRoot = Join-Path $RepoRoot 'lifepunch\publish-lane\scaffold'

if (-not (Test-Path -LiteralPath $PortfolioPath)) { throw "Missing $PortfolioPath" }
if (-not (Test-Path -LiteralPath $ManifestPath)) { throw "Missing $ManifestPath" }

$portfolio = Get-Content -LiteralPath $PortfolioPath -Raw | ConvertFrom-Json
$manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
if ($portfolio.publishReadyAddons -and @($portfolio.publishReadyAddons).Count -gt 0) {
    $active = @($portfolio.publishReadyAddons)
} else {
    $active = @($portfolio.activeAddons)
}

if ($Init) {
    if (-not (Test-Path -LiteralPath $Target)) {
        New-Item -ItemType Directory -Force -Path $Target | Out-Null
    }
    if (Test-Path -LiteralPath $ScaffoldRoot) {
        Copy-Item -LiteralPath (Join-Path $ScaffoldRoot '*') -Destination $Target -Recurse -Force
    }
}

function Copy-PublishTree {
    param([string]$Source, [string]$Destination)
    if (-not (Test-Path -LiteralPath $Source -PathType Container)) { return }
    $sourceRoot = (Resolve-Path -LiteralPath $Source).Path
    Get-ChildItem -LiteralPath $sourceRoot -Recurse -File -Force |
        Where-Object {
            $rel = $_.FullName.Substring($sourceRoot.Length).TrimStart('\', '/')
            $parts = $rel -split '[\\/]'
            $_.Name -notin @('.gitkeep', 'desktop.ini', 'Thumbs.db', 'material-map.json') `
                -and $_.Extension -ne '.md' `
                -and $parts -notcontains 'docs' `
                -and $parts -notcontains '_dev' `
                -and $_.Name -notmatch '(TestBots|DevGive|DevSpawn)'
        } |
        ForEach-Object {
            $rel = $_.FullName.Substring($sourceRoot.Length).TrimStart('\', '/')
            $target = Join-Path $Destination $rel
            $parent = Split-Path -Parent $target
            if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
            Copy-Item -LiteralPath $_.FullName -Destination $target -Force
        }
}

# Remove stale addon trees from prior exports (publish lane is a snapshot, not incremental).
foreach ($root in @(
        (Join-Path $Target 'Assets\addons\lifepunch'),
        (Join-Path $Target 'Code\Addons\lifepunch')
    )) {
    if (Test-Path -LiteralPath $root) {
        Remove-Item -LiteralPath $root -Recurse -Force
    }
}

$exportAddons = @()
foreach ($ident in $active) {
    $pkg = $manifest.addons | Where-Object { $_.ident -eq $ident } | Select-Object -First 1
    if (-not $pkg) {
        Write-Warning "Skip $ident - not in addons.json"
        continue
    }
    $exportAddons += $pkg
    $assetSrc = Join-Path $AddonsRoot "Assets\addons\lifepunch\$ident"
    $codeSrc = Join-Path $AddonsRoot "Code\Addons\lifepunch\$ident"
    $assetDst = Join-Path $Target "Assets\addons\lifepunch\$ident"
    $codeDst = Join-Path $Target "Code\Addons\lifepunch\$ident"
    Write-Host "Export $ident ..." -ForegroundColor Cyan
    Copy-PublishTree -Source $assetSrc -Destination $assetDst
    Copy-PublishTree -Source $codeSrc -Destination $codeDst
}

$outManifest = @{
    schemaVersion = 1
    org           = $manifest.org
    brand         = $manifest.brand
    ownership     = 'PROPRIETARY - (c) 2026 lifepunch.co. Server use only; no redistribution.'
    contentReferenceRoot = 'addons/lifepunch'
    portfolioPhase = $portfolio.phase
    syncedFromMonorepo = 'github.com/mragerlp/lifepunch'
    addons        = $exportAddons
}
$outJson = ($outManifest | ConvertTo-Json -Depth 12)
$configDir = Join-Path $Target 'config'
if (-not (Test-Path -LiteralPath $configDir)) { New-Item -ItemType Directory -Force -Path $configDir | Out-Null }
$utf8 = New-Object System.Text.UTF8Encoding $false
[IO.File]::WriteAllText((Join-Path $configDir 'addons.json'), $outJson, $utf8)

$monoSha = 'unknown'
Push-Location $RepoRoot
try { $monoSha = (git rev-parse --short HEAD 2>$null) } catch { }
Pop-Location
$syncText = @(
    "# Sync from core monorepo",
    "",
    "exported: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
    "monorepo: https://github.com/mragerlp/lifepunch",
    "commit: $monoSha",
    "active: $($active -join ', ')",
    "phase: $($portfolio.phase)",
    ""
)
[IO.File]::WriteAllText((Join-Path $Target 'SYNC_FROM.md'), ($syncText -join [Environment]::NewLine), $utf8)

Write-Host "OK publish lane -> $Target ($($exportAddons.Count) addon(s))" -ForegroundColor Green
