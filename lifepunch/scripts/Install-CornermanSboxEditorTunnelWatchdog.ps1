<#
.SYNOPSIS
  Keep Cornerman -> VENGEANCE sbox-editor MCP tunnel alive (localhost:9090).

.DESCRIPTION
  Registers LifePunch-Cornerman-SboxEditor-Tunnel — logon + every 5 minutes in jared's
  interactive session. SSH one-shots die when the session ends; this does not.

.EXAMPLE
  powershell -File C:\lifepunch\cornerman\Install-CornermanSboxEditorTunnelWatchdog.ps1
  Send-CornermanWorkflow.ps1 -Action InstallGreenMcp
#>
[CmdletBinding()]
param(
    [string] $OnBoxDir = 'C:\lifepunch\cornerman',
    [string] $TaskUser = 'jared',
    [int] $IntervalMinutes = 5
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
$tunnelOnBox = Join-Path $OnBoxDir 'Start-CornermanSboxEditorTunnel.ps1'
$tunnelSrc = Join-Path $here 'Start-CornermanSboxEditorTunnel.ps1'
if (-not (Test-Path -LiteralPath $tunnelOnBox)) {
    if (-not (Test-Path -LiteralPath $tunnelSrc)) {
        throw "Missing $tunnelOnBox (sync from Red first)"
    }
    Copy-Item -LiteralPath $tunnelSrc -Destination $tunnelOnBox -Force
}
elseif ($tunnelSrc -ne $tunnelOnBox -and (Test-Path -LiteralPath $tunnelSrc)) {
    Copy-Item -LiteralPath $tunnelSrc -Destination $tunnelOnBox -Force
}

$psArgs = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$tunnelOnBox`" -Background"
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $psArgs
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 1) `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 3)

$logonTrigger = New-ScheduledTaskTrigger -AtLogon -User $TaskUser
$repeatTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) `
    -RepetitionInterval (New-TimeSpan -Minutes $IntervalMinutes) `
    -RepetitionDuration (New-TimeSpan -Days 3650)

$principal = New-ScheduledTaskPrincipal -UserId $TaskUser -LogonType Interactive -RunLevel Limited

Write-Step "Scheduled task LifePunch-Cornerman-SboxEditor-Tunnel (every ${IntervalMinutes}m + logon)"
Register-ScheduledTask -TaskName 'LifePunch-Cornerman-SboxEditor-Tunnel' `
    -Action $action -Trigger @($logonTrigger, $repeatTrigger) -Settings $settings `
    -Principal $principal -Force | Out-Null

Write-Step 'Start tunnel now'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $tunnelOnBox -Background

Write-Host ''
Write-Host 'Editor MCP tunnel watchdog installed. Green sbox-editor -> http://127.0.0.1:9090/sbox-mcp' -ForegroundColor Cyan
Write-Host 'Requires: VENGEANCE editor open + chomnr on :9090 + SSH key Cornerman -> VENGEANCE.' -ForegroundColor DarkGray
