<#
.SYNOPSIS
  Mirror normalized Desktop lifepunchaddons trees into repo lp* staging.

.EXAMPLE
  powershell -File lifepunch\addons\scripts\Sync-LifepunchDesktopToStaging.ps1
#>
[CmdletBinding()]
param(
    [string] $DesktopRoot = "$env:USERPROFILE\OneDrive\Desktop\lifepunchaddons",
    [string] $RepoAssetsRoot = ''
)

$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$AddonsRoot = Split-Path $Here -Parent
if (-not $RepoAssetsRoot) {
    $RepoAssetsRoot = (Resolve-Path (Join-Path $AddonsRoot 'Assets\addons\lifepunch')).Path
}

$configPath = Join-Path $AddonsRoot 'config\package-staging.json'
$config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
$legacyMap = @{}
$config.legacyDesktopFolderMap.PSObject.Properties | ForEach-Object { $legacyMap[$_.Name] = $_.Value }

if (-not (Test-Path -LiteralPath $DesktopRoot)) {
    throw "Missing desktop drop: $DesktopRoot"
}

Write-Host 'Sync Desktop -> repo lp* staging' -ForegroundColor Cyan
Write-Host "  From: $DesktopRoot" -ForegroundColor DarkGray
Write-Host "  To:   $RepoAssetsRoot" -ForegroundColor DarkGray

$packages = Get-ChildItem -LiteralPath $DesktopRoot -Directory -Force |
    Where-Object { $_.Name -notin @('audit') }

foreach ($pkg in $packages) {
    $repoPkgName = if ($legacyMap.ContainsKey($pkg.Name)) { $legacyMap[$pkg.Name] } else { $pkg.Name }
    Get-ChildItem -LiteralPath $pkg.FullName -Directory -Force -ErrorAction SilentlyContinue | ForEach-Object {
        $assets = Join-Path $_.FullName 'assets'
        $legacyGame = Join-Path $_.FullName 'game'
        if (-not (Test-Path -LiteralPath $assets) -and -not (Test-Path -LiteralPath $legacyGame)) { return }

        $rel = Join-Path $repoPkgName $_.Name
        $dest = Join-Path $RepoAssetsRoot $rel
        New-Item -ItemType Directory -Force -Path $dest | Out-Null

        if (Test-Path -LiteralPath $assets) {
            & robocopy $assets (Join-Path $dest 'assets') /MIR /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
        }
        elseif (Test-Path -LiteralPath $legacyGame) {
            & robocopy (Join-Path $legacyGame 'source') (Join-Path $dest 'assets\source') /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
            if (Test-Path (Join-Path $legacyGame 'textures')) {
                & robocopy (Join-Path $legacyGame 'textures') (Join-Path $dest 'assets\textures') /MIR /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
            }
        }

        foreach ($extra in @('audit', 'docs', 'code')) {
            $srcExtra = Join-Path $_.FullName $extra
            if (Test-Path -LiteralPath $srcExtra) {
                & robocopy $srcExtra (Join-Path $dest $extra) /MIR /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
            }
        }

        if ($LASTEXITCODE -ge 8) { throw "robocopy failed for $rel" }
        Write-Host "  OK $rel" -ForegroundColor Green
    }
}

Write-Host 'Done.' -ForegroundColor Cyan
