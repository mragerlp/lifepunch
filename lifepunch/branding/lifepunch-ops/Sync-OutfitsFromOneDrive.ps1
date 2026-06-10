<#
.SYNOPSIS
  Refresh machine uniforms from canonical Hacker Job outfit folders on OneDrive.

.DESCRIPTION
  Each working piece has an outfit — the art that makes the ops console feel like them.
  OneDrive is the artist's source; this script copies into the monorepo pack and rebuilds
  desktop wallpapers under wallpapers/.

  Canonical paths (VENGEANCE desk):
    Enhanced Hacker Terminal\vengeance
    Hacker Terminal\cornerman
    Government Terminal\lifepunchnet

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\Sync-OutfitsFromOneDrive.ps1
#>
[CmdletBinding()]
param(
    [string] $HackerJobRoot = (Join-Path $env:USERPROFILE 'OneDrive\Desktop\Hacker Job')
)

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$outfitsRoot = Join-Path $here 'outfits'
$wallDir = Join-Path $here 'wallpapers'

function Write-Step($m) { Write-Host "==> $m" -ForegroundColor Cyan }

$map = @{
    vengeance    = @{
        src  = Join-Path $HackerJobRoot 'Enhanced Hacker Terminal\vengeance'
        dest = Join-Path $outfitsRoot 'vengeance'
        wp   = @{ from = 'vengeanceterminal.png'; to = 'lifepunch-ops-wallpaper-vengeance.png' }
    }
    cornerman    = @{
        src  = Join-Path $HackerJobRoot 'Hacker Terminal\cornerman'
        dest = Join-Path $outfitsRoot 'cornerman'
        wp   = @{ from = 'cornermanbanner.png'; to = 'lifepunch-ops-wallpaper-cornerman.png' }
    }
    lifepunchnet = @{
        src  = Join-Path $HackerJobRoot 'Government Terminal\lifepunchnet'
        dest = Join-Path $outfitsRoot 'lifepunchnet'
        wp   = @{ from = 'lifepunchnetbanner.png'; to = 'lifepunch-ops-wallpaper-lifepunchnet.png' }
    }
}

if (-not (Test-Path -LiteralPath $HackerJobRoot)) {
    throw "Hacker Job folder not found: $HackerJobRoot"
}

New-Item -ItemType Directory -Force -Path $outfitsRoot, $wallDir | Out-Null

foreach ($machine in $map.Keys) {
    $entry = $map[$machine]
    if (-not (Test-Path -LiteralPath $entry.src)) {
        throw "Missing outfit source for ${machine}: $($entry.src)"
    }
    Write-Step "Outfit -> $machine from $($entry.src)"
    New-Item -ItemType Directory -Force -Path $entry.dest | Out-Null
    Copy-Item -LiteralPath (Join-Path $entry.src '*') -Destination $entry.dest -Recurse -Force

    $wpFrom = Join-Path $entry.dest $entry.wp.from
    $wpTo = Join-Path $wallDir $entry.wp.to
    if (-not (Test-Path -LiteralPath $wpFrom)) {
        Write-Host "    wallpaper source missing: $($entry.wp.from)" -ForegroundColor Yellow
        continue
    }
    Copy-Item -LiteralPath $wpFrom -Destination $wpTo -Force
    Write-Host "    wallpaper: $($entry.wp.to)" -ForegroundColor DarkGray
}

Write-Host ''
Write-Host 'Outfits synced. Re-run Apply-LifePunchOpsConsole.ps1 on each machine to dress the desk.' -ForegroundColor Cyan
