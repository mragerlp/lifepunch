<#
.SYNOPSIS
  lifepunchnet: fix lifepunch.ulx dedicated-server compile (missing shared UI types).

.DESCRIPTION
  dxrp-server downloads addon code under dxrp/game/Code/Addons/lifepunch/<folder>/.
  Published r6/r7 often ship only adminmenu/*.cs — missing LifePunchUiScale, LifePunchUiFooter, etc.

  This script copies the 5 shared helpers from the git clone into every ULX code folder
  on disk, patches StaffMenu.razor.scss import, then you restart server2_start.bat.

.PARAMETER DxrpRoot
  Folder containing dxrp-server.cs (default: C:\S&BOX DXRP Server).

.PARAMETER RepoRoot
  lifepunch-rdp-server clone (default: C:\lifepunch\lifepunch-rdp-server).

.EXAMPLE
  cd C:\lifepunch\lifepunch-rdp-server\lifepunch\server\dxrp-host\scripts
  powershell -ExecutionPolicy Bypass -File .\Patch-LifepunchnetUlxCompile.ps1
#>
[CmdletBinding()]
param(
    [string] $DxrpRoot = 'C:\S&BOX DXRP Server',
    [string] $RepoRoot = 'C:\lifepunch\lifepunch-rdp-server'
)

$ErrorActionPreference = 'Stop'

$SharedFiles = @(
    'LifePunchUiScale.cs',
    'LifePunchUiScrollPolicy.cs',
    'LifePunchSourceMark.cs',
    'LifePunchUiFooter.razor',
    'LifePunchUiFooter.razor.scss'
)

$SharedSource = Join-Path $RepoRoot 'lifepunch\addons\Code\Addons\lifepunch'
$GameCodeRoot = Join-Path $DxrpRoot 'dxrp\game\Code\Addons\lifepunch'

if (-not (Test-Path -LiteralPath $GameCodeRoot)) {
    throw "DXRP game code root missing: $GameCodeRoot`nStart server2_start.bat once so dxrp-server clones dxrp, then re-run."
}

foreach ($name in $SharedFiles) {
    $src = Join-Path $SharedSource $name
    if (-not (Test-Path -LiteralPath $src)) {
        throw "Missing shared source in repo: $src`nRun: git pull --rebase in $RepoRoot"
    }
}

# Portal/s&box folder names seen on lifepunchnet (legacy + current slug).
$UlxFolderNames = @('dxrpadminmenu', 'lifepunchulx', 'adminmenu')
$targets = @()

foreach ($folder in $UlxFolderNames) {
    $path = Join-Path $GameCodeRoot $folder
    if (Test-Path -LiteralPath $path) {
        $targets += $path
    }
}

if ($targets.Count -eq 0) {
    Write-Host "No ULX folder under $GameCodeRoot" -ForegroundColor Yellow
    Write-Host 'Known names: dxrpadminmenu, lifepunchulx, adminmenu' -ForegroundColor Yellow
    Write-Host 'Listing what exists:' -ForegroundColor Yellow
    Get-ChildItem -LiteralPath $GameCodeRoot -Directory | ForEach-Object { Write-Host "  $($_.Name)" }
    throw 'Cannot patch — mount lifepunch.ulx on Dev server and run server2_start.bat through [6/7] first.'
}

Write-Host 'Patching ULX compile bundle on lifepunchnet...' -ForegroundColor Cyan

foreach ($target in $targets) {
    Write-Host "  -> $target" -ForegroundColor Green
    foreach ($name in $SharedFiles) {
        Copy-Item -LiteralPath (Join-Path $SharedSource $name) -Destination (Join-Path $target $name) -Force
    }

    $scss = Join-Path $target 'StaffMenu.razor.scss'
    if (Test-Path -LiteralPath $scss) {
        $text = [System.IO.File]::ReadAllText($scss)
        $patched = $text -replace '@import "\.\./LifePunchUiFooter\.razor\.scss";', '@import "./LifePunchUiFooter.razor.scss";'
        if ($patched -ne $text) {
            [System.IO.File]::WriteAllText($scss, $patched)
            Write-Host '     StaffMenu.razor.scss import -> ./LifePunchUiFooter' -ForegroundColor DarkGray
        }
    }

    $count = (Get-ChildItem -LiteralPath $target -File).Count
    Write-Host "     $count code files in folder (expect 11+ for compile-ready ULX)" -ForegroundColor DarkGray
}

Write-Host ''
Write-Host 'Done. Restart Development:' -ForegroundColor Green
Write-Host '  cd /d "C:\S&BOX DXRP Server"' -ForegroundColor White
Write-Host '  server2_start.bat' -ForegroundColor White
Write-Host ''
Write-Host 'NOTE: dxrp-server re-downloads from portal every start — patch is TEMP unless portal has r8 (11 files).' -ForegroundColor Yellow
Write-Host 'Permanent fix: Publish-LifepunchUlxRevision.ps1 on Vengeance -> portal r8 -> download > 85 KB.' -ForegroundColor Cyan
