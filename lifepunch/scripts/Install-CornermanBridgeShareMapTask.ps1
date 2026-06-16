<#
.SYNOPSIS
  Install Cornerman logon task to map VENGEANCE SboxBridgeIpc in the interactive session.

.DESCRIPTION
  OpenSSH batch sessions cannot persist cmdkey/net use for the desktop Cursor session.
  This task runs Ensure-CornermanBridgeShare.ps1 at logon and on demand from VENGEANCE.

.EXAMPLE
  powershell -File lifepunch\scripts\Install-CornermanBridgeShareMapTask.ps1
#>
[CmdletBinding()]
param(
    [string] $SshTarget = '',
    [switch] $RunNow
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $Here 'Cornerman-Workflow.ps1')

if (-not $SshTarget) { $SshTarget = Get-CornermanSshTarget }
if (-not (Test-CornermanSshReady -SshTarget $SshTarget)) {
    throw "Cornerman SSH not ready ($SshTarget)"
}

$onBoxEnsure = 'C:\lifepunch\cornerman\Ensure-CornermanBridgeShare.ps1'
$onBoxInstall = 'C:\lifepunch\cornerman\Install-CornermanBridgeShareMapTask.ps1'

$installBody = @'
[CmdletBinding()]
param([switch]$RunNow)
$ErrorActionPreference = 'Stop'
$taskName = 'LifePunch BridgeShare'
$ensure = 'C:\lifepunch\cornerman\Ensure-CornermanBridgeShare.ps1'
if (-not (Test-Path -LiteralPath $ensure)) { throw "Missing $ensure" }
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ensure`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
Write-Output "OK task $taskName"
if ($RunNow) {
  Start-ScheduledTask -TaskName $taskName
  Start-Sleep -Seconds 4
  & $ensure
}
'@

Push-CornermanText -Path $onBoxInstall -Text $installBody -SshTarget $SshTarget | Out-Null
Push-CornermanFile -Path $onBoxEnsure -FileBytes ([IO.File]::ReadAllBytes((Join-Path $Here 'Ensure-CornermanBridgeShare.ps1'))) -SshTarget $SshTarget | Out-Null

$runFlag = if ($RunNow) { '-RunNow' } else { '' }
$r = Invoke-CornermanSshExec -SshTarget $SshTarget -ScriptBlock @"
& powershell -NoProfile -ExecutionPolicy Bypass -File '$onBoxInstall' $runFlag
"@ -ConnectTimeout 60

Write-Host $r.Output -ForegroundColor $(if ($r.ExitCode -eq 0) { 'Green' } else { 'Red' })
if ($r.ExitCode -ne 0) { throw "Task install failed (exit $($r.ExitCode))" }

if ($RunNow) {
    Start-Sleep -Seconds 2
    $ok = Test-CornermanBridgeShareReachable -SshTarget $SshTarget
    Write-Host "Cornerman SMB reachable: $ok" -ForegroundColor $(if ($ok) { 'Green' } else { 'Yellow' })
}
