<#
.SYNOPSIS
  One-shot lifepunchulx portal staging with hard verify gate (11 files).

.EXAMPLE
  cd lifepunch\addons\scripts
  powershell -ExecutionPolicy Bypass -File .\Publish-LifepunchUlxRevision.ps1 -OpenFolder
#>
[CmdletBinding()]
param(
    [switch] $OpenFolder,
    [switch] $SyncDesktop
)

$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot

& (Join-Path $Here 'prepare-publish.ps1') -Addon adminmenu

$Root = (Resolve-Path (Join-Path $Here '..')).Path
$verifyPath = Join-Path $Root '.dxrp-publish\ulx-publish-verify.json'
if (-not (Test-Path -LiteralPath $verifyPath)) {
    throw 'Missing ulx-publish-verify.json — prepare-publish gate did not run.'
}

$verify = Get-Content -LiteralPath $verifyPath -Raw | ConvertFrom-Json
$codeDir = Join-Path $Root ".dxrp-publish\upload\Code\Addons\lifepunch\$($verify.packageSlug)"

Write-Host ''
Write-Host '========== LIFEPUNCH ULX — PORTAL r8 UPLOAD ==========' -ForegroundColor Cyan
Write-Host "Files:  $($verify.fileCount)  (must be 11)" -ForegroundColor Green
Write-Host "Bytes:  $($verify.totalBytes)  (broken r6/r7 ~ 47 KB; good r8 ~ 90 KB+)" -ForegroundColor Green
Write-Host ''
Write-Host 'Portal Code upload — select ALL files inside:' -ForegroundColor Yellow
Write-Host "  $codeDir" -ForegroundColor White
Write-Host ''
Write-Host 'Do NOT upload adminmenu/ or only StaffMenu*.cs (6-file broken revision).' -ForegroundColor Red
Write-Host 'After publish: pin r8 on Dev gamemode, restart server2_start.bat.' -ForegroundColor Cyan
Write-Host 'Download line should show code > 85 KB, not ~47 KB.' -ForegroundColor Cyan
Write-Host '====================================================' -ForegroundColor Cyan

if ($SyncDesktop) {
    $sync = Join-Path (Split-Path (Split-Path $Here -Parent) -Parent) 'scripts\Sync-DesktopPublishFolder.ps1'
    if (Test-Path -LiteralPath $sync) {
        & $sync -Addon adminmenu
    }
}

if ($OpenFolder) {
    Invoke-Item $codeDir
}
