# Red reads Green overnight LPBitcoin distill progress.
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
. (Join-Path $Here 'Cornerman-Workflow.ps1')

if (-not (Test-CornermanSshReady)) { throw 'Cornerman SSH not ready' }

$r = Invoke-CornermanSshExec -ScriptBlock @'
$statusPath = 'C:\lifepunch\cornerman\outbox\OVERNIGHT_STATUS.json'
$logPath = 'C:\lifepunch\cornerman\outbox\overnight-log.txt'
if (Test-Path -LiteralPath $statusPath) {
  Write-Output '=== STATUS ==='
  Get-Content -LiteralPath $statusPath -Raw
} else { Write-Output 'STATUS: (not started)' }
Write-Output '=== LPBITCOIN OUTBOX ==='
Get-ChildItem 'C:\lifepunch\cornerman\outbox' -Filter 'LPBITCOIN*' -ErrorAction SilentlyContinue |
  ForEach-Object { Write-Output ($_.Name + ' ' + $_.Length + 'b ' + $_.LastWriteTime.ToString('o')) }
if (-not (Get-ChildItem 'C:\lifepunch\cornerman\outbox' -Filter 'LPBITCOIN*' -EA SilentlyContinue)) {
  Write-Output '(none yet)'
}
if (Test-Path -LiteralPath $logPath) {
  Write-Output '=== LOG TAIL ==='
  Get-Content -LiteralPath $logPath -Tail 8
}
'@ -ConnectTimeout 25

Write-Host $r.Output
