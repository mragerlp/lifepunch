<#
.SYNOPSIS
  Register a logon + 10-minute LM Studio watchdog on Cornerman (all 3 Tier-3 models).

.DESCRIPTION
  Keeps :1234 up with qwen distill, qwen coder, and nomic embed. Idempotent with
  Start-CornermanLmStudio.ps1 -WarmModel all. Run elevated ON Green once, or from
  Red via Send-CornermanWorkflow -Action InstallLmWatchdog.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File Install-CornermanLmWatchdog.ps1
#>
[CmdletBinding()]
param(
    [string] $OnBoxDir = 'C:\lifepunch\cornerman',
    [string] $TaskUser = 'jared',
    [int] $IntervalMinutes = 10
)

$ErrorActionPreference = 'Stop'

function Write-Step($m) { Write-Host ('==> ' + $m) -ForegroundColor Green }

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
          ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if (-not $isAdmin) {
    throw 'Run in ELEVATED PowerShell (Run as administrator) on Cornerman.'
}

$here = $PSScriptRoot
New-Item -ItemType Directory -Force -Path $OnBoxDir | Out-Null
$lmsOnBox = Join-Path $OnBoxDir 'Start-CornermanLmStudio.ps1'
$lmsSrc = Join-Path $here 'Start-CornermanLmStudio.ps1'
if (-not (Test-Path -LiteralPath $lmsOnBox)) {
    if (-not (Test-Path -LiteralPath $lmsSrc)) {
        throw "Missing $lmsOnBox (sync Start-CornermanLmStudio.ps1 from Red first)"
    }
    Write-Step 'Publish Start-CornermanLmStudio.ps1'
    Copy-Item -LiteralPath $lmsSrc -Destination $lmsOnBox -Force
}
elseif ($lmsSrc -ne $lmsOnBox -and (Test-Path -LiteralPath $lmsSrc)) {
    Write-Step 'Update Start-CornermanLmStudio.ps1'
    Copy-Item -LiteralPath $lmsSrc -Destination $lmsOnBox -Force
}

$psArgs = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$lmsOnBox`" -WarmModel all -Quiet"
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $psArgs
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 1) `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 15)

$logonTrigger = New-ScheduledTaskTrigger -AtLogon -User $TaskUser
# Task Scheduler rejects TimeSpan::MaxValue — use ~10 years.
$repeatTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(2) `
    -RepetitionInterval (New-TimeSpan -Minutes $IntervalMinutes) `
    -RepetitionDuration (New-TimeSpan -Days 3650)

$principal = New-ScheduledTaskPrincipal -UserId $TaskUser -LogonType Interactive -RunLevel Limited

Write-Step ('Scheduled task LifePunch-Cornerman-LM-Watchdog (every ' + $IntervalMinutes + 'm + logon)')
Register-ScheduledTask -TaskName 'LifePunch-Cornerman-LM-Watchdog' `
    -Action $action -Trigger @($logonTrigger, $repeatTrigger) -Settings $settings `
    -Principal $principal -Force | Out-Null

Write-Step 'Warm all Tier-3 models now'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $lmsOnBox -WarmModel all

Write-Host ''
Write-Host 'LM watchdog installed. Green should keep 3 models on :1234 after reboot/logon.' -ForegroundColor Cyan
