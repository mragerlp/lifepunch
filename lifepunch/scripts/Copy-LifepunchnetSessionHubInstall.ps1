# VENGEANCE helper - copy standalone session hub installer to clipboard for lifepunchnet RDP paste.

$src = Join-Path $PSScriptRoot '..\server\scripts\Install-LifepunchnetSessionHub-Standalone.ps1'
$src = (Resolve-Path -LiteralPath $src).Path
Get-Content -LiteralPath $src -Raw | Set-Clipboard
Write-Host 'Copied standalone installer to clipboard.' -ForegroundColor Green
Write-Host ''
Write-Host 'On lifepunchnet (elevated PowerShell):' -ForegroundColor Cyan
Write-Host '  1. notepad C:\lifepunch\install-session-hub.ps1'
Write-Host '  2. Ctrl+V, save, close'
Write-Host '  3. powershell -ExecutionPolicy Bypass -File C:\lifepunch\install-session-hub.ps1'
Write-Host ''
Write-Host "Or try git pull first:" -ForegroundColor DarkGray
Write-Host '  cd C:\lifepunch\lifepunch-rdp-server\lifepunch\server\scripts'
Write-Host '  powershell -ExecutionPolicy Bypass -File .\Install-LifepunchnetSessionHub.ps1 -RemoteAddress 71.250.46.224'
