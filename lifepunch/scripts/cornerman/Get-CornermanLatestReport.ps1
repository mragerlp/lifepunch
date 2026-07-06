# =====================================================================
# RISK: READ-ONLY (never writes, deletes, moves, or archives)  |  Slice 3
# NODE: Green (Cornerman) -- testable anywhere with -BaseDir scratch dirs
# WHAT: Operator helper. Shows the latest drop-worker run (or a specific
#       -TaskId): ack line, meta.json summary (status / dryRun /
#       failureStage / model), artifact paths, and optionally the first
#       lines of the report/error body with -ShowContent.
# NOT:  No mutation of any kind. No HTTP. No git.
# LAW:  lifepunch/docs/CORNERMAN_HEADLESS_DROP_WORKER.md (runbook)
# USAGE:
#   powershell -NoProfile -File Get-CornermanLatestReport.ps1
#   powershell -NoProfile -File Get-CornermanLatestReport.ps1 -TaskId task-20260706-051500-slice2-live-smoke
#   powershell -NoProfile -File Get-CornermanLatestReport.ps1 -ShowContent -ContentLines 60
# =====================================================================

[CmdletBinding()]
param(
    [string] $BaseDir = 'C:\lifepunch\cornerman',

    # Specific task id. Default: the id on the newest ack line.
    [string] $TaskId = '',

    # Print the first -ContentLines lines of report/error body.
    [switch] $ShowContent,
    [ValidateRange(1, 2000)]
    [int] $ContentLines = 40
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ackLog = Join-Path $BaseDir 'outbox\workflow-ack.ndjson'

function Test-Prop {
    param($Obj, [string] $Name)
    return ($null -ne $Obj) -and ($Obj.PSObject.Properties.Name -contains $Name) -and ($null -ne $Obj.$Name)
}

# ------------------------------------------------------ resolve task id
$ackLine = $null
if (-not $TaskId) {
    if (-not (Test-Path -LiteralPath $ackLog)) {
        Write-Output "No runs recorded yet (no ack log at $ackLog)."
        exit 0
    }
    $ackLines = @(Get-Content -LiteralPath $ackLog | Where-Object { $_ -match '\S' })
    if ($ackLines.Count -eq 0) {
        Write-Output "No runs recorded yet (ack log is empty: $ackLog)."
        exit 0
    }
    $ackLine = $ackLines[-1]
    try { $TaskId = ([string](($ackLine | ConvertFrom-Json).id)) } catch { $TaskId = '' }
    if (-not $TaskId) {
        Write-Output "Latest ack line is unparseable: $ackLine"
        exit 1
    }
}
elseif (Test-Path -LiteralPath $ackLog) {
    # newest ack for this specific task, if any
    $ackLine = @(Get-Content -LiteralPath $ackLog | Where-Object { $_ -like ('*"' + $TaskId + '"*') }) |
        Select-Object -Last 1
}

Write-Output "== task: $TaskId =="
if ($ackLine) { Write-Output "ack      : $ackLine" }
else { Write-Output 'ack      : (no ack line found for this task)' }

# ---------------------------------------------------------- meta summary
$taskDir = Join-Path $BaseDir ("outbox\{0}" -f $TaskId)
$metaFile = Join-Path $taskDir 'meta.json'
if (Test-Path -LiteralPath $metaFile) {
    try {
        $meta = Get-Content -LiteralPath $metaFile -Raw | ConvertFrom-Json
        $status = if (Test-Prop $meta 'status') { [string]$meta.status } else { '?' }
        $dryRun = if (Test-Prop $meta 'dryRun') { [bool]$meta.dryRun } else { $null }
        Write-Output ("status   : {0} (dryRun={1})" -f $status, $dryRun)
        if ((Test-Prop $meta 'failureStage') -and [string]$meta.failureStage) {
            Write-Output ("failure  : stage={0}" -f $meta.failureStage)
        }
        if (Test-Prop $meta 'failures') {
            foreach ($f in @($meta.failures)) { Write-Output ("  - {0}" -f $f) }
        }
        if (Test-Prop $meta 'model') {
            $m = $meta.model
            $mid = if (Test-Prop $m 'modelId') { [string]$m.modelId } else { '?' }
            $dur = if (Test-Prop $m 'durationSeconds') { [string]$m.durationSeconds } else { '?' }
            $oc = if (Test-Prop $m 'outputChars') { [string]$m.outputChars } else { '?' }
            Write-Output ("model    : {0} ({1}s, {2} output chars)" -f $mid, $dur, $oc)
        }
    }
    catch {
        Write-Output "meta     : unreadable ($($_.Exception.Message))"
    }
    Write-Output "meta     : $metaFile"
}
else {
    Write-Output "meta     : (no outbox folder/meta for this task: $taskDir)"
}

# ------------------------------------------------------- artifact paths
$body = $null
foreach ($name in @('report.md', 'report.json', 'report.txt', 'error.md')) {
    $p = Join-Path $taskDir $name
    if (Test-Path -LiteralPath $p) {
        Write-Output ("artifact : {0}" -f $p)
        if (-not $body) { $body = $p }
    }
}

$historyDir = Join-Path $BaseDir 'history'
$hist = Get-ChildItem -LiteralPath $historyDir -Filter ($TaskId + '.*.json') -File -ErrorAction SilentlyContinue |
    Select-Object -First 1
if ($hist) { Write-Output ("history  : {0}" -f $hist.FullName) }

# --------------------------------------------------------- body preview
if ($ShowContent) {
    if ($body) {
        Write-Output ''
        Write-Output ("-- first {0} lines of {1} --" -f $ContentLines, [IO.Path]::GetFileName($body))
        Get-Content -LiteralPath $body -TotalCount $ContentLines | ForEach-Object { Write-Output $_ }
    }
    else {
        Write-Output '(no report/error body found to show)'
    }
}
exit 0
