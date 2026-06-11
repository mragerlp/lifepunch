<#
.SYNOPSIS
  Red reads Green workflow inbox + ack log over SSH.

.EXAMPLE
  powershell -File Get-CornermanWorkflowStatus.ps1
  powershell -File Get-CornermanWorkflowStatus.ps1 -Tail 5
#>
[CmdletBinding()]
param(
    [int] $Tail = 8,
    [string] $SshTarget = ''
)

$ErrorActionPreference = 'Continue'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $Here 'Cornerman-Workflow.ps1')
. (Join-Path $Here 'Voice-Console.ps1')
$script:VoiceConsoleAccent = 'Green'

if (-not $SshTarget) { $SshTarget = Get-CornermanSshTarget }

Write-VoiceHeader -Title 'CORNERMAN WORKFLOW STATUS' -Subtitle 'Red reads Green inbox + ack (no Cursor on Green)'
Write-VoiceMeta -Label 'SSH' -Value $SshTarget
Write-Host ''

if (-not (Test-CornermanSshReady -SshTarget $SshTarget)) {
    Write-Host '  FAIL — Cornerman SSH unreachable' -ForegroundColor Red
    exit 1
}

$inboxList = Invoke-CornermanSshExec -SshTarget $SshTarget -ScriptBlock @"
`$inbox = '$script:CornermanInboxRoot'
if (-not (Test-Path -LiteralPath `$inbox)) { Write-Output '(inbox missing)'; exit 0 }
Get-ChildItem -LiteralPath `$inbox -Filter 'wf-*.json' -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTimeUtc -Descending |
    Select-Object -First $Tail |
    ForEach-Object { Write-Output (`$_.Name + ' ' + `$_.LastWriteTimeUtc.ToString('o')) }
"@
Write-Host '=== INBOX (newest) ===' -ForegroundColor Cyan
if ($inboxList.Output) { Write-Host $inboxList.Output } else { Write-Host '(empty)' }

Write-Host '=== ACK (newest) ===' -ForegroundColor Cyan
$ackList = Invoke-CornermanSshExec -SshTarget $SshTarget -ScriptBlock @"
`$inbox = '$script:CornermanInboxRoot'
Get-ChildItem -LiteralPath `$inbox -Filter 'ack-*.json' -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTimeUtc -Descending |
    Select-Object -First $Tail |
    ForEach-Object { Write-Output (`$_.Name + ' ' + `$_.LastWriteTimeUtc.ToString('o')) }
"@
if ($ackList.Output) { Write-Host $ackList.Output } else { Write-Host '(none)' }
Write-Host ''
exit $(if ($r.ExitCode -eq 0) { 0 } else { 1 })
