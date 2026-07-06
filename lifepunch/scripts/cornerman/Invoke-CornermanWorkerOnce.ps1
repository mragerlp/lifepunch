# =====================================================================
# RISK: RUNS THE DROP WORKER EXACTLY ONCE (no loop, no scheduler)  |  Slice 3
# NODE: Green (Cornerman) -- testable anywhere with -BaseDir scratch dirs
# WHAT: Operator helper. Invokes Invoke-CornermanDropWorker.ps1 for ONE
#       run, then prints exactly where the artifacts landed (report /
#       error / meta.json / ack line / history file). Model calls stay
#       behind the explicit -EnableModelCall switch, passed through
#       verbatim -- this wrapper never enables it on its own.
# NOT:  No loop. No retry. No scheduler install. No background daemon.
#       No git mutation. Exits after one worker invocation.
# LAW:  lifepunch/docs/CORNERMAN_HEADLESS_DROP_WORKER.md (runbook)
# USAGE:
#   powershell -NoProfile -File Invoke-CornermanWorkerOnce.ps1
#   powershell -NoProfile -File Invoke-CornermanWorkerOnce.ps1 -EnableModelCall
#   powershell -NoProfile -File Invoke-CornermanWorkerOnce.ps1 -BaseDir C:\tmp\cdw -RegistryPath C:\tmp\cdw\repo-profiles.json
# =====================================================================

[CmdletBinding()]
param(
    [string] $BaseDir = 'C:\lifepunch\cornerman',
    [string] $RegistryPath = '',
    [string] $ModelConfigPath = '',
    [string] $PacketFile = '',
    [int] $StaleLockMinutes = 30,

    # Passed through to the worker verbatim. Without it the worker never
    # performs HTTP and model-opted packets fail closed.
    [switch] $EnableModelCall
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$workerScript = Join-Path $PSScriptRoot 'Invoke-CornermanDropWorker.ps1'
if (-not (Test-Path -LiteralPath $workerScript)) {
    Write-Output "ERROR: worker script not found next to this helper: $workerScript"
    exit 1
}

$ackLog = Join-Path $BaseDir 'outbox\workflow-ack.ndjson'
$ackCountBefore = 0
if (Test-Path -LiteralPath $ackLog) {
    $ackCountBefore = @(Get-Content -LiteralPath $ackLog -ErrorAction SilentlyContinue).Count
}

# ------------------------------------------------ one worker invocation
$workerArgs = @(
    '-NoProfile', '-File', $workerScript,
    '-BaseDir', $BaseDir,
    '-StaleLockMinutes', $StaleLockMinutes
)
if ($RegistryPath)    { $workerArgs += @('-RegistryPath', $RegistryPath) }
if ($ModelConfigPath) { $workerArgs += @('-ModelConfigPath', $ModelConfigPath) }
if ($PacketFile)      { $workerArgs += @('-PacketFile', $PacketFile) }
if ($EnableModelCall) { $workerArgs += '-EnableModelCall' }

Write-Output ("-- one worker run (modelCallEnabled={0}) --" -f [bool]$EnableModelCall.IsPresent)
& powershell @workerArgs 2>&1 | ForEach-Object { Write-Output $_ }
$workerExit = $LASTEXITCODE
Write-Output "-- worker exit code: $workerExit --"

# ------------------------------------------------ locate what landed
if (-not (Test-Path -LiteralPath $ackLog)) {
    Write-Output 'No ack log exists -- the run produced no artifact (IDLE / SKIP / startup failure). Nothing landed.'
    exit $workerExit
}
$ackLines = @(Get-Content -LiteralPath $ackLog)
if ($ackLines.Count -le $ackCountBefore) {
    Write-Output 'No new ack line -- the run processed no packet (IDLE / SKIP / startup failure). Nothing landed.'
    exit $workerExit
}

$ack = $ackLines[-1]
try { $ackObj = $ack | ConvertFrom-Json } catch { $ackObj = $null }
Write-Output ''
Write-Output '== artifacts from this run =='
Write-Output "ack line : $ack"

if ($ackObj -and $ackObj.id) {
    $taskId = [string]$ackObj.id
    $taskDir = Join-Path $BaseDir ("outbox\{0}" -f $taskId)
    foreach ($name in @('report.md', 'report.json', 'report.txt', 'error.md', 'meta.json')) {
        $p = Join-Path $taskDir $name
        if (Test-Path -LiteralPath $p) { Write-Output ("{0,-9}: {1}" -f ($name -replace '\..*$', ''), $p) }
    }
    $historyDir = Join-Path $BaseDir 'history'
    $hist = Get-ChildItem -LiteralPath $historyDir -Filter ($taskId + '.*.json') -File -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($hist) { Write-Output ("history  : {0}" -f $hist.FullName) }
}

$lockFile = Join-Path $BaseDir 'lock\worker.lock'
if (Test-Path -LiteralPath $lockFile) {
    Write-Output "WARNING  : lock file still present (unexpected): $lockFile"
}
else {
    Write-Output 'lock     : released'
}
Write-Output ''
Write-Output 'Inspect details with Get-CornermanLatestReport.ps1. This helper never loops or schedules; run it again manually for the next packet.'
exit $workerExit
