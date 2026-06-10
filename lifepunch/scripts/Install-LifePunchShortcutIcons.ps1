# Refresh all LifePunch desktop shortcuts with tier icons (universal / vengeance / cornerman / lifepunchnet).

$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot

Write-Host ''
Write-Host 'LifePunch shortcut icons — refresh all installers' -ForegroundColor Cyan
Write-Host ''

& (Join-Path $Here 'Install-LifePunchDayShortcut.ps1')
& (Join-Path $Here 'Install-LifePunchVoiceShortcuts.ps1')
& (Join-Path $Here 'Install-LifePunchRemoteShortcuts.ps1')
& (Join-Path $Here 'Install-LifePunchTalkToVengeanceShortcut.ps1')

Write-Host ''
Write-Host 'Shortcut pairing (icon color = destination):' -ForegroundColor Cyan
Write-Host '  tri-stack  LifePunch — Start Day' -ForegroundColor DarkGray
Write-Host '  tri-stack  LifePunch Voice Preflight' -ForegroundColor DarkGray
Write-Host '  red        LifePunch Voice Comms' -ForegroundColor DarkGray
Write-Host '  green      Cornerman (RDP)' -ForegroundColor DarkGray
Write-Host '  red        Talk to Vengeance (voice to VENGEANCE)' -ForegroundColor DarkGray
Write-Host '  blue       lifepunchnet (RDP)' -ForegroundColor DarkGray
Write-Host ''
Write-Host 'Icons: lifepunch/branding/shortcut-icons/SHORTCUT_ICONS.md' -ForegroundColor Cyan
