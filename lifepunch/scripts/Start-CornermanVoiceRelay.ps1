# Cornerman — start Talk to Vengeance PTT relay in a dedicated console (run on Cornerman).
# Deployed to C:\Projects\cornerman-rag\ via Apply-CornermanPushToTalk.ps1

$ErrorActionPreference = 'Stop'
$ragRoot = 'C:\Projects\cornerman-rag'
$relay = Join-Path $ragRoot 'relay.ps1'

if (-not (Test-Path -LiteralPath $relay)) {
    throw "Missing $relay — run Apply-CornermanPushToTalk.ps1 from VENGEANCE"
}

$existing = Get-CimInstance Win32_Process -Filter "Name = 'python.exe'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -match 'relay\.py' -and $_.CommandLine -match '--ptt' }
if ($existing) {
    Write-Host 'Talk to Vengeance PTT relay already running (python relay.py --ptt).' -ForegroundColor Yellow
    exit 0
}

$ps = Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe'
$cmd = "Set-Location -LiteralPath '$ragRoot'; & '$relay' -PushToTalk"
Start-Process -FilePath $ps -ArgumentList @(
    '-NoExit', '-ExecutionPolicy', 'Bypass', '-NoProfile',
    '-Command', $cmd
) -WindowStyle Normal | Out-Null

Write-Host 'Started Talk to Vengeance (PTT). Tap F7 -> Ready -> hold F8.' -ForegroundColor Green
