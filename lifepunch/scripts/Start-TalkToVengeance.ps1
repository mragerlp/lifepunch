# VENGEANCE — remote-start Cornerman Talk to Vengeance PTT relay over SSH.

$ErrorActionPreference = 'Stop'
$CornermanSsh = if ($env:CORNERMAN_SSH) { $env:CORNERMAN_SSH } else { 'cornerman' }
$CornermanRelayScript = 'C:\Projects\cornerman-rag\Start-CornermanVoiceRelay.ps1'

Write-Host ''
Write-Host 'Talk to Vengeance — starting Cornerman PTT relay (SSH)...' -ForegroundColor Cyan
& ssh.exe -o BatchMode=yes $CornermanSsh "powershell -NoProfile -ExecutionPolicy Bypass -File `"$CornermanRelayScript`""
if ($LASTEXITCODE -ne 0) {
    Write-Host ''
    Write-Host 'Failed. Check SSH to cornerman or RDP in and run Talk to Vengeance.cmd on Cornerman.' -ForegroundColor Red
    exit 1
}
Write-Host ''
Write-Host 'Relay window should be open on Cornerman. F7 arm -> Ready -> hold F8 -> Ctrl+V on VENGEANCE.' -ForegroundColor Green
