# Cornerman — start Talk to Vengeance PTT relay in a dedicated console (run on Cornerman).
# Deployed to C:\Projects\cornerman-rag\ via Apply-CornermanPushToTalk.ps1

$ErrorActionPreference = 'Stop'
$ragRoot = 'C:\Projects\cornerman-rag'
$relay = Join-Path $ragRoot 'relay.ps1'

if (-not (Test-Path -LiteralPath $relay)) {
    throw "Missing $relay - run Apply-CornermanPushToTalk.ps1 from VENGEANCE"
}

# One relay only — duplicate python relay.py processes steal F7/F8 and hang PTT.
$relays = @(Get-CimInstance Win32_Process -Filter "Name = 'python.exe'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -match 'relay\.py' })
foreach ($p in $relays) {
    Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue
}
if ($relays.Count -gt 0) {
    Write-Host "Stopped $($relays.Count) stale relay process(es)." -ForegroundColor Yellow
    Start-Sleep -Seconds 1
}

$ps = Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe'
$cmd = "Set-Location -LiteralPath '$ragRoot'; & '$relay' -PushToTalk"
Start-Process -FilePath $ps -ArgumentList @(
    '-NoExit', '-ExecutionPolicy', 'Bypass', '-NoProfile',
    '-Command', $cmd
) -WindowStyle Normal | Out-Null

Write-Host 'Started Talk to Vengeance (PTT). Tap F7 -> Ready -> hold F8.' -ForegroundColor Green
