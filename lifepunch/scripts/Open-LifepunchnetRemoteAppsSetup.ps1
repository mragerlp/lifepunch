<#
.SYNOPSIS
  VENGEANCE helper: refresh lifepunchnet RDP (local audio), copy install one-liner, open RDP.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File Open-LifepunchnetRemoteAppsSetup.ps1
#>
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot

Write-Host 'Refreshing lifepunchnet RDP shortcut (play remote audio on this PC)...' -ForegroundColor Cyan
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Here 'Install-LifePunchRemoteShortcuts.ps1') -DesktopOnly | Out-Host

$oneLiner = @'
cd C:\lifepunch\lifepunch-rdp-server\lifepunch\server\scripts
git pull --rebase
powershell -ExecutionPolicy Bypass -File .\Install-LifepunchnetRemoteApps.ps1
'@

Set-Clipboard -Value $oneLiner
Write-Host 'Copied install one-liner to clipboard (paste in elevated PS on lifepunchnet).' -ForegroundColor Green

$desktop = [Environment]::GetFolderPath('Desktop')
$lnk = Join-Path $desktop 'lifepunchnet (RDP).lnk'
if (Test-Path -LiteralPath $lnk) {
    Start-Process -FilePath $lnk
    Write-Host 'Opened lifepunchnet (RDP).' -ForegroundColor Green
}
else {
    Write-Host 'No lifepunchnet (RDP).lnk on Desktop — set remote-hosts.local.json host and re-run Install-LifePunchRemoteShortcuts.ps1' -ForegroundColor Yellow
}

Write-Host ''
Write-Host 'After Discord installs on Blue: quit Discord on VENGEANCE (tray -> Exit).' -ForegroundColor Cyan
