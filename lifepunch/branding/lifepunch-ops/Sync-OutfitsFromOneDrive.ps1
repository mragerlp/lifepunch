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
    Desktop\uniforms\PNGs  (gray Explorer icons — folder + .txt, all nodes)

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\Sync-OutfitsFromOneDrive.ps1
#>
[CmdletBinding()]
param(
    [string] $HackerJobRoot = (Join-Path $env:USERPROFILE 'OneDrive\Desktop\Hacker Job'),
    [string] $WallpapersRoot = (Join-Path $env:USERPROFILE 'OneDrive\Desktop\wallpapers'),
    [string] $UniformsRoot = (Join-Path $env:USERPROFILE 'OneDrive\Desktop\uniforms\PNGs')
)

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$outfitsRoot = Join-Path $here 'outfits'
$wallDir = Join-Path $here 'wallpapers'
$iconDir = Join-Path $here 'icons'

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

New-Item -ItemType Directory -Force -Path $outfitsRoot, $wallDir, $iconDir | Out-Null

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

$explorerIconMap = @{
    'grayfoldericon.png'              = 'lifepunch-folder.png'
    'graynotes.png'                   = 'lifepunch-txt.png'
    'powershell-prompt-thumbnail.png' = 'powershell-prompt-thumbnail.png'
}
if (Test-Path -LiteralPath $UniformsRoot) {
    Write-Step "Explorer icons (uniform) from $UniformsRoot"
    foreach ($entry in $explorerIconMap.GetEnumerator()) {
        $from = Join-Path $UniformsRoot $entry.Key
        $to = Join-Path $iconDir $entry.Value
        if (-not (Test-Path -LiteralPath $from)) {
            throw "Missing Explorer icon source: $from (see OneDrive Desktop\uniforms\UNIFORM_STANDARDS.md)"
        }
        Copy-Item -LiteralPath $from -Destination $to -Force
        Write-Host "    $($entry.Key) -> $($entry.Value)" -ForegroundColor DarkGray
    }
}
else {
    Write-Host "    Skip Explorer icons — uniforms folder not found: $UniformsRoot" -ForegroundColor Yellow
}

if (Test-Path -LiteralPath (Join-Path $iconDir 'powershell-prompt-thumbnail.png')) {
    Write-Step 'PowerShell prompt thumbnail -> outfit *console.png'
    $thumb = Join-Path $iconDir 'powershell-prompt-thumbnail.png'
    foreach ($entry in @{
        vengeance    = 'vengeanceconsole.png'
        cornerman    = 'cornermanconsole.png'
        lifepunchnet = 'lifepunchnetconsole.png'
    }.GetEnumerator()) {
        $destDir = Join-Path $outfitsRoot $entry.Key
        if (Test-Path -LiteralPath $destDir) {
            Copy-Item -LiteralPath $thumb -Destination (Join-Path $destDir $entry.Value) -Force
            Write-Host "    -> outfits/$($entry.Key)/$($entry.Value)" -ForegroundColor DarkGray
        }
    }
}

Write-Host ''
Write-Host 'Outfits + wallpapers + Explorer icons synced. Re-run Apply-LifePunchOpsConsole.ps1 on each machine to dress the desk.' -ForegroundColor Cyan
