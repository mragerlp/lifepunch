# Red dispatches LPBitcoin UI polish overnight distill to Green (runs without Cursor).
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
. (Join-Path $Here 'Cornerman-Workflow.ps1')

if (-not (Test-CornermanSshReady)) { throw 'Cornerman SSH not ready — leave Green powered on.' }

# Ensure inbox + LM warm
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Here 'Send-CornermanWorkflow.ps1') `
    -Action WarmDistill -NoHubIngest -Quiet

$runnerLocal = Join-Path $Here 'cornerman\Run-LpBitcoinUiPolishOvernight.ps1'
if (-not (Test-Path -LiteralPath $runnerLocal)) { throw "Missing $runnerLocal" }

$runnerRemote = 'C:\lifepunch\cornerman\Run-LpBitcoinUiPolishOvernight.ps1'
$logRemote = 'C:\lifepunch\cornerman\outbox\overnight-log.txt'
$bytes = [IO.File]::ReadAllBytes($runnerLocal)
Push-CornermanFile -Path $runnerRemote -FileBytes $bytes | Out-Null
Write-Host "Pushed $runnerRemote ($($bytes.Length) bytes)" -ForegroundColor Green

$wfId = New-CornermanWorkflowId
$start = @"
New-Item -ItemType Directory -Force -Path 'C:\lifepunch\cornerman\outbox' | Out-Null
`$log = '$logRemote'
`$args = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', '$runnerRemote')
`$p = Start-Process -FilePath 'powershell.exe' -ArgumentList `$args -PassThru -WindowStyle Hidden -RedirectStandardOutput '$logRemote' -RedirectStandardError '$logRemote'
Write-Output ('overnight_pid=' + `$p.Id)
"@

$r = Invoke-CornermanSshExec -ScriptBlock $start -ConnectTimeout 30
$ok = ($r.ExitCode -eq 0) -and ($r.Output -match 'overnight_pid=')
Add-CornermanWorkflowAck -WorkflowId $wfId -Action 'Inbox' -Ok $ok -Detail $r.Output

$note = @"
LPBITCOIN OVERNIGHT DISTILL STARTED $(Get-Date -Format o)
PID output: $($r.Output)
Watch: C:\lifepunch\cornerman\outbox\OVERNIGHT_STATUS.json
Log: $logRemote
Deliverables: C:\lifepunch\cornerman\outbox\LPBITCOIN_*.md
When done: to-vengeance-lpbitcoin-overnight-done.txt
VENGEANCE can shut down — Green runs headless LM on :1234.
"@
Push-CornermanText -Path 'C:\lifepunch\cornerman\outbox\to-vengeance-lpbitcoin-overnight-start.txt' -Text $note

if (-not $ok) {
    Write-Host "FAIL start overnight: $($r.Output)" -ForegroundColor Red
    exit 1
}

Write-Host 'OK Green overnight distill started' -ForegroundColor Green
Write-Host $r.Output -ForegroundColor DarkGray
Write-Host 'Monitor: powershell -File lifepunch\scripts\Get-CornermanOvernightStatus.ps1' -ForegroundColor Cyan
