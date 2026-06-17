# Red dispatches deterministic ModelDoc sweep to Green (runs without Cursor).
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
. (Join-Path $Here 'Cornerman-Workflow.ps1')

if (-not (Test-CornermanSshReady)) { throw 'Cornerman SSH not ready — leave Green powered on.' }

$sweepLocal = Join-Path $Here 'cornerman\Run-ModelDocGreenfieldSweep.ps1'
if (-not (Test-Path -LiteralPath $sweepLocal)) { throw "Missing $sweepLocal" }

$sweepRemote = 'C:\lifepunch\cornerman\Run-ModelDocGreenfieldSweep.ps1'
$logRemote   = 'C:\lifepunch\cornerman\outbox\sweep-log.txt'
$bytes = [IO.File]::ReadAllBytes($sweepLocal)
Push-CornermanFile -Path $sweepRemote -FileBytes $bytes | Out-Null
Write-Host "Pushed $sweepRemote ($($bytes.Length) bytes)" -ForegroundColor Green

$wfId = New-CornermanWorkflowId
$start = @"
New-Item -ItemType Directory -Force -Path 'C:\lifepunch\cornerman\outbox' | Out-Null
`$log = '$logRemote'
`$cmd = "powershell -NoProfile -ExecutionPolicy Bypass -File '$sweepRemote' *> '$logRemote' 2>&1"
`$p = Start-Process cmd.exe -ArgumentList @('/c', `$cmd) -PassThru -WindowStyle Hidden
Write-Output ('sweep_pid=' + `$p.Id)
"@

$r = Invoke-CornermanSshExec -ScriptBlock $start -ConnectTimeout 30
$ok = ($r.ExitCode -eq 0) -and ($r.Output -match 'sweep_pid=')
Add-CornermanWorkflowAck -WorkflowId $wfId -Action 'Inbox' -Ok $ok -Detail $r.Output

$note = @"
AUTONOMOUS SWEEP STARTED $(Get-Date -Format o)
PID output: $($r.Output)
When done, read: C:\lifepunch\cornerman\outbox\SWEEP_STATUS.json
Deliverables: cornerman-rag\outbox\*_2026-06-17.*
Log: $logRemote
"@
Push-CornermanText -Path 'C:\lifepunch\cornerman\outbox\to-vengeance-greenfield-sweep.txt' -Text $note

if (-not $ok) {
    Write-Host "FAIL start sweep: $($r.Output)" -ForegroundColor Red
    exit 1
}
Write-Host 'OK Green sweep started' -ForegroundColor Green
Write-Host $r.Output -ForegroundColor DarkGray
Write-Host 'When back: ssh cornerman type C:\lifepunch\cornerman\outbox\SWEEP_STATUS.json'
