# Refresh all LifePunch desktop shortcuts with tier icons (universal / vengeance / cornerman / lifepunchnet).

$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot

Write-Host ''
Write-Host 'LifePunch shortcut icons - refresh all installers' -ForegroundColor Cyan
Write-Host ''

& (Join-Path $Here 'Build-LifePunchShortcutIcons.ps1')

& (Join-Path $Here 'Install-LifePunchDayShortcut.ps1')
& (Join-Path $Here 'Install-LifePunchCvlShortcut.ps1')
& (Join-Path $Here 'Install-LifePunchVoiceShortcuts.ps1')
& (Join-Path $Here 'Install-LifePunchRemoteShortcuts.ps1')
& (Join-Path $Here 'Install-LifePunchTalkToVengeanceShortcut.ps1')

Write-Host ''
Write-Host 'Shortcut pairing (icon color = destination):' -ForegroundColor Cyan
Write-Host '  tri-stack  LifePunch — Start Day' -ForegroundColor DarkGray
Write-Host '  tri-stack  LifePunch - CVL Same Page (hub log)' -ForegroundColor DarkGray
Write-Host '  tri-stack  LifePunch Voice Preflight' -ForegroundColor DarkGray
Write-Host '  red        LifePunch Voice Comms' -ForegroundColor DarkGray
Write-Host '  green      Cornerman (RDP)' -ForegroundColor DarkGray
Write-Host '  green      Cornerman — Talk to Vengeance (on VENGEANCE — signals Green)' -ForegroundColor DarkGray
Write-Host '  red        Talk to Vengeance (on Cornerman only — voice to Red)' -ForegroundColor DarkGray
Write-Host '  blue       lifepunchnet (RDP)' -ForegroundColor DarkGray
Write-Host ''
Write-Host 'Icons: lifepunch/branding/shortcut-icons/SHORTCUT_ICONS.md' -ForegroundColor Cyan

# Bust Explorer icon cache (generic document icon = stale cache or bad ICO).
Write-Host 'Refreshing desktop icon cache...' -ForegroundColor DarkGray
$prev = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
$ie4u = Join-Path ${env:WinDir} 'System32\ie4uinit.exe'
if (Test-Path -LiteralPath $ie4u) { Start-Process $ie4u -ArgumentList '-show' -WindowStyle Hidden }
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Milliseconds 1200
Start-Process explorer.exe
$ErrorActionPreference = $prev
Write-Host 'Icons published under Documents\LifePunch-Icons - check desktop now.' -ForegroundColor Green
