<#
.SYNOPSIS
  Refresh machine uniforms from canonical Hacker Job outfit folders on OneDrive.

.DESCRIPTION
  Each node in the LifePunch web has an outfit — the art that makes the ops console feel like them.
  OneDrive is the artist's source; this script copies into the monorepo pack and rebuilds
  desktop wallpapers from the shared wallpapers uniform folder.

  Canonical paths (VENGEANCE desk):
    Enhanced Hacker Terminal\vengeance
    Hacker Terminal\cornerman
    Government Terminal\lifepunchnet
    Desktop\wallpapers  (desktop HUD — same layout, per-machine color)

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\Sync-OutfitsFromOneDrive.ps1
#>
[CmdletBinding()]
param(
    [string] $HackerJobRoot = (Join-Path $env:USERPROFILE 'OneDrive\Desktop\Hacker Job'),
    [string] $WallpapersRoot = (Join-Path $env:USERPROFILE 'OneDrive\Desktop\wallpapers')
)

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$outfitsRoot = Join-Path $here 'outfits'
$wallDir = Join-Path $here 'wallpapers'

function Write-Step($m) { Write-Host "==> $m" -ForegroundColor Cyan }

$outfitMap = @{
    vengeance    = @{
        src  = Join-Path $HackerJobRoot 'Enhanced Hacker Terminal\vengeance'
        dest = Join-Path $outfitsRoot 'vengeance'
    }
    cornerman    = @{
        src  = Join-Path $HackerJobRoot 'Hacker Terminal\cornerman'
        dest = Join-Path $outfitsRoot 'cornerman'
    }
    lifepunchnet = @{
        src  = Join-Path $HackerJobRoot 'Government Terminal\lifepunchnet'
        dest = Join-Path $outfitsRoot 'lifepunchnet'
    }
}

$wallMap = @{
    vengeance    = @{ from = 'vengeancewallpaper.png'; to = 'lifepunch-ops-wallpaper-vengeance.png' }
    cornerman    = @{ from = 'cornermanwallpaper.png'; to = 'lifepunch-ops-wallpaper-cornerman.png' }
    lifepunchnet = @{ from = 'lifepunchnetwallpaper.png'; to = 'lifepunch-ops-wallpaper-lifepunchnet.png' }
}

if (-not (Test-Path -LiteralPath $HackerJobRoot)) {
    throw "Hacker Job folder not found: $HackerJobRoot"
}
if (-not (Test-Path -LiteralPath $WallpapersRoot)) {
    throw "Wallpapers uniform folder not found: $WallpapersRoot"
}

New-Item -ItemType Directory -Force -Path $outfitsRoot, $wallDir | Out-Null

foreach ($machine in $outfitMap.Keys) {
    $entry = $outfitMap[$machine]
    if (-not (Test-Path -LiteralPath $entry.src)) {
        throw "Missing outfit source for ${machine}: $($entry.src)"
    }
    Write-Step "Outfit -> $machine from $($entry.src)"
    New-Item -ItemType Directory -Force -Path $entry.dest | Out-Null
    Copy-Item -LiteralPath (Join-Path $entry.src '*') -Destination $entry.dest -Recurse -Force
}

Write-Step "Wallpapers uniform from $WallpapersRoot"
foreach ($machine in $wallMap.Keys) {
    $entry = $wallMap[$machine]
    $wpFrom = Join-Path $WallpapersRoot $entry.from
    $wpTo = Join-Path $wallDir $entry.to
    if (-not (Test-Path -LiteralPath $wpFrom)) {
        throw "Missing wallpaper for ${machine}: $wpFrom"
    }
    Copy-Item -LiteralPath $wpFrom -Destination $wpTo -Force
    Write-Host "    $($entry.from) -> $($entry.to)" -ForegroundColor DarkGray
}

Write-Host ''
Write-Host 'Outfits + wallpapers synced. Re-run Apply-LifePunchOpsConsole.ps1 on each machine to dress the desk.' -ForegroundColor Cyan
