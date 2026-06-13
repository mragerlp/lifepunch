<#
.SYNOPSIS
  Red -> Green workflow dispatch (no Cursor on Cornerman required).

.DESCRIPTION
  Drops a JSON workflow record to C:\lifepunch\cornerman\inbox\ on Green, optionally runs a
  whitelisted action over SSH, and optionally logs tier=cornerman to lifepunchnet hub.

.EXAMPLE
  powershell -File Send-CornermanWorkflow.ps1 -Action StartVoiceRelay
  powershell -File Send-CornermanWorkflow.ps1 -Action Inbox -Message "Smoke PTT after pull"
  powershell -File Send-CornermanWorkflow.ps1 -Action DeployPttCapture -IngestToHub
#>
[CmdletBinding()]
param(
    [ValidateSet('Inbox', 'StartVoiceRelay', 'DeployPttCapture', 'MonorepoPull', 'Checkpoint', 'WarmDistill', 'WarmCoder', 'FullPerformance', 'InstallLmWatchdog', 'InstallGreenMcp')]
    [string] $Action = 'Inbox',
    [string] $Message = '',
    [string] $WorkflowId = '',
    [string] $SshTarget = '',
    [switch] $NoExecute,
    [switch] $NoHubIngest,
    [switch] $Quiet
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $Here 'Cornerman-Workflow.ps1')
. (Join-Path $Here 'Voice-Console.ps1')
. (Join-Path $Here 'Cvl-Hub.ps1')

if (-not $SshTarget) { $SshTarget = Get-CornermanSshTarget }
if (-not $WorkflowId) { $WorkflowId = New-CornermanWorkflowId }

function Write-WorkflowInfo([string]$m) {
    if (-not $Quiet) { Write-Host $m }
}

if (-not (Test-CornermanSshReady -SshTarget $SshTarget)) {
    throw "Cornerman SSH not ready ($SshTarget)"
}

$record = @{
    id      = $WorkflowId
    action  = $Action
    message = $Message
    execute = (-not $NoExecute)
}
$inbox = Write-CornermanWorkflowInbox -Record $record -SshTarget $SshTarget
Write-WorkflowInfo "Inbox: $($inbox.id).json on Green"

$execOk = $true
$execDetail = 'inbox-only'

if (-not $NoExecute) {
    switch ($Action) {
        'Inbox' {
            $execDetail = 'recorded — no remote command (use -Action StartVoiceRelay etc.)'
        }
        'StartVoiceRelay' {
            $relay = Join-Path $script:CornermanRagRoot 'Start-CornermanVoiceRelay.ps1'
            $r = Invoke-CornermanSshExec -SshTarget $SshTarget -ScriptBlock @"
if (-not (Test-Path -LiteralPath '$relay')) { throw 'Missing $relay' }
& '$relay'
"@ -ConnectTimeout 25
            $execOk = ($r.ExitCode -eq 0)
            $execDetail = if ($r.Output) { $r.Output } else { "exit=$($r.ExitCode)" }
        }
        'DeployPttCapture' {
            $local = Join-Path $Here 'cornerman-relay\ptt_capture.py'
            if (-not (Test-Path -LiteralPath $local)) { throw "Missing $local" }
            $remote = Join-Path $script:CornermanRagRoot 'ptt_capture.py'
            $bytes = [IO.File]::ReadAllBytes($local)
            Push-CornermanFile -Path $remote -FileBytes $bytes -SshTarget $SshTarget | Out-Null
            $fixLocal = Join-Path $Here 'cornerman-relay\fix_session_log_encoding.py'
            if (Test-Path -LiteralPath $fixLocal) {
                $fixRemote = Join-Path $script:CornermanRagRoot 'fix_session_log_encoding.py'
                Push-CornermanFile -Path $fixRemote -FileBytes ([IO.File]::ReadAllBytes($fixLocal)) -SshTarget $SshTarget | Out-Null
                $r = Invoke-CornermanSshExec -SshTarget $SshTarget -ScriptBlock @"
Push-Location '$script:CornermanRagRoot'
& .\.venv\Scripts\python.exe fix_session_log_encoding.py
Pop-Location
"@
                $execOk = ($r.ExitCode -eq 0)
                $execDetail = $r.Output
            }
            else {
                $execDetail = 'ptt_capture.py deployed'
            }
        }
        'MonorepoPull' {
            $r = Invoke-CornermanSshExec -SshTarget $SshTarget -ScriptBlock @"
if (-not (Test-Path -LiteralPath '$script:CornermanMonorepoRoot\.git')) {
    throw 'No monorepo clone at $script:CornermanMonorepoRoot'
}
Push-Location '$script:CornermanMonorepoRoot'
git pull --rebase 2>&1
Pop-Location
"@ -ConnectTimeout 60
            $execOk = ($r.ExitCode -eq 0)
            $execDetail = $r.Output
        }
        'Checkpoint' {
            $probe = 'C:\lifepunch\cornerman\Get-CvlCornermanProbe.ps1'
            $r = Invoke-CornermanSshExec -SshTarget $SshTarget -ScriptBlock @"
if (-not (Test-Path -LiteralPath '$probe')) { throw 'Missing $probe — run Sync-CornermanRebootScripts.ps1 from Red' }
& powershell -NoProfile -ExecutionPolicy Bypass -File '$probe'
"@ -ConnectTimeout 30
            $execOk = ($r.ExitCode -eq 0)
            $execDetail = ($r.Output -split "`n" | Where-Object { $_.Trim().StartsWith('{') } | Select-Object -Last 1)
        }
        { $_ -in 'WarmDistill', 'WarmCoder' } {
            $warm = if ($Action -eq 'WarmCoder') { 'coder' } else { 'daily' }
            $lms = 'C:\lifepunch\cornerman\Start-CornermanLmStudio.ps1'
            $r = Invoke-CornermanSshExec -SshTarget $SshTarget -ScriptBlock @"
if (-not (Test-Path -LiteralPath '$lms')) { throw 'Missing $lms — run Sync-CornermanRebootScripts.ps1 from Red' }
& powershell -NoProfile -ExecutionPolicy Bypass -File '$lms' -WarmModel $warm
"@ -ConnectTimeout 300
            $execOk = ($r.ExitCode -eq 0)
            $execDetail = if ($r.Output) { $r.Output } else { "warm=$warm exit=$($r.ExitCode)" }
        }
        'InstallLmWatchdog' {
            $watch = 'C:\lifepunch\cornerman\Install-CornermanLmWatchdog.ps1'
            $r = Invoke-CornermanSshExec -SshTarget $SshTarget -ScriptBlock @"
if (-not (Test-Path -LiteralPath '$watch')) { throw 'Missing $watch — run Sync-CornermanRebootScripts.ps1 from Red' }
& powershell -NoProfile -ExecutionPolicy Bypass -File '$watch'
"@ -ConnectTimeout 300
            $execOk = ($r.ExitCode -eq 0)
            $execDetail = if ($r.Output) { $r.Output } else { "exit=$($r.ExitCode)" }
        }
        'InstallGreenMcp' {
            $green = 'C:\lifepunch\cornerman\Install-CornermanGreenMcp.ps1'
            $r = Invoke-CornermanSshExec -SshTarget $SshTarget -ScriptBlock @"
if (-not (Test-Path -LiteralPath '$green')) { throw 'Missing $green — run Sync-CornermanRebootScripts.ps1 from Red' }
& powershell -NoProfile -ExecutionPolicy Bypass -File '$green'
"@ -ConnectTimeout 120
            $execOk = ($r.ExitCode -eq 0)
            $execDetail = if ($r.Output) { $r.Output } else { "exit=$($r.ExitCode)" }
        }
        'FullPerformance' {
            $perf = 'C:\lifepunch\cornerman\Invoke-CornermanFullPerformance.ps1'
            $r = Invoke-CornermanSshExec -SshTarget $SshTarget -ScriptBlock @"
if (-not (Test-Path -LiteralPath '$perf')) { throw 'Missing $perf — run Sync-CornermanRebootScripts.ps1 from Red' }
& powershell -NoProfile -ExecutionPolicy Bypass -File '$perf' -WarmModel all
"@ -ConnectTimeout 300
            $execOk = ($r.ExitCode -eq 0)
            $execDetail = if ($r.Output) { $r.Output } else { "exit=$($r.ExitCode)" }
        }
    }
}

Add-CornermanWorkflowAck -WorkflowId $WorkflowId -Action $Action -Ok $execOk -Detail $execDetail -SshTarget $SshTarget

if (-not $NoHubIngest) {
    $cfgPath = Join-Path $Here 'server-host-watch.local.json'
    if (Test-Path -LiteralPath $cfgPath) {
        try {
            $cfg = Get-CvlHubConfig -ConfigPath $cfgPath
            $summary = "workflow id=$WorkflowId action=$Action ok=$execOk"
            if ($Message) { $summary += " | $Message" }
            Send-CvlHubIngest -Config $cfg -Tier cornerman -Type 'cornerman-workflow' -Text $summary -Extra @{
                workflowId = $WorkflowId
                action     = $Action
                ok         = $execOk
            }
            Write-WorkflowInfo 'Hub: tier=cornerman workflow logged'
        }
        catch {
            Write-WorkflowInfo "Hub ingest skipped: $($_.Exception.Message)"
        }
    }
}

Write-WorkflowInfo ''
if (-not $Quiet) {
    if ($execOk) {
        Write-Host "OK Green workflow $WorkflowId ($Action)" -ForegroundColor Green
    }
    else {
        Write-Host "FAIL Green workflow $WorkflowId ($Action)" -ForegroundColor Yellow
        if ($execDetail) { Write-Host "  $execDetail" -ForegroundColor DarkGray }
    }
}
Write-WorkflowInfo "Read ack: Get-CornermanWorkflowStatus.ps1"

exit $(if ($execOk) { 0 } else { 1 })
