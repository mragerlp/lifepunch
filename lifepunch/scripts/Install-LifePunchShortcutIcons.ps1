# Refresh all LifePunch desktop shortcuts with tier icons (universal / vengeance / cornerman / lifepunchnet).

$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot

Write-Host ''
Write-Host 'LifePunch shortcut icons — refresh all installers' -ForegroundColor Cyan
Write-Host ''

& (Join-Path $Here 'Install-LifePunchDayShortcut.ps1')
& (Join-Path $Here 'Install-LifePunchVoiceShortcuts.ps1')
& (Join-Path $Here 'Install-LifePunchRemoteShortcuts.ps1')

Write-Host ''
Write-Host 'Icon tiers:' -ForegroundColor DarkGray
Write-Host '  universal   = Start Day, preflight (full stack)' -ForegroundColor DarkGray
Write-Host '  vengeance   = Voice Comms (desk)' -ForegroundColor DarkGray
Write-Host '  cornerman   = Cornerman RDP' -ForegroundColor DarkGray
Write-Host '  lifepunchnet = lifepunchnet RDP' -ForegroundColor DarkGray
Write-Host ''
Write-Host 'See lifepunch/branding/shortcut-icons/SHORTCUT_ICONS.md' -ForegroundColor Cyan
