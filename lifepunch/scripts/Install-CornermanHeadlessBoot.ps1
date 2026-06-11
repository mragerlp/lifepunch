<#
.SYNOPSIS
  Register Cornerman headless maintenance to run on every boot and logon.

.DESCRIPTION
  Copies Invoke-CornermanHeadlessBoot.ps1 to C:\lifepunch\cornerman\ and registers:
    - LifePunch-Cornerman-Headless-Startup  (AtStartup, SYSTEM)
    - LifePunch-Cornerman-Headless-Logon    (AtLogon, highest)
  Idempotent — safe to re-run. Called by Enable-CornermanHeadless.ps1.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\Install-CornermanHeadlessBoot.ps1
#>
[CmdletBinding()]
param(
    [string] $OnBoxDir = 'C:\lifepunch\cornerman'
)

$ErrorActionPreference = 'Stop'

function Write-Step($m) { Write-Host "==> $m" -ForegroundColor Green }
function Write-Note($m) { Write-Host "    $m" -ForegroundColor DarkGray }

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
          ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if (-not $isAdmin) {
    throw 'Run in ELEVATED PowerShell (Run as administrator).'
}

$here = $PSScriptRoot
New-Item -ItemType Directory -Force -Path $OnBoxDir | Out-Null
$bootOnBox = Join-Path $OnBoxDir 'Invoke-CornermanHeadlessBoot.ps1'
$lmsOnBox = Join-Path $OnBoxDir 'Start-CornermanLmStudio.ps1'
$bootSrc = Join-Path $here 'Invoke-CornermanHeadlessBoot.ps1'
$lmsSrc = Join-Path $here 'Start-CornermanLmStudio.ps1'

foreach ($pair in @(
        @{ Label = 'Invoke-CornermanHeadlessBoot.ps1'; Src = $bootSrc; Dest = $bootOnBox }
        @{ Label = 'Start-CornermanLmStudio.ps1'; Src = $lmsSrc; Dest = $lmsOnBox }
    )) {
    if (-not (Test-Path -LiteralPath $pair.Dest)) {
        if (-not (Test-Path -LiteralPath $pair.Src)) {
            throw "Missing $($pair.Dest) (sync $($pair.Label) from Red first)"
        }
        Copy-Item -LiteralPath $pair.Src -Destination $pair.Dest -Force
    }
    elseif ($pair.Src -ne $pair.Dest -and (Test-Path -LiteralPath $pair.Src)) {
        Copy-Item -LiteralPath $pair.Src -Destination $pair.Dest -Force
    }
}

Write-Step 'Headless boot + LM Studio scripts on-box'
Write-Note $bootOnBox
Write-Note $lmsOnBox

$psArgs = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$bootOnBox`""
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $psArgs
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 1) `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 5)

Write-Step 'Scheduled task AtStartup'
$startupTrigger = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -TaskName 'LifePunch-Cornerman-Headless-Startup' `
    -Action $action -Trigger $startupTrigger -Settings $settings `
    -RunLevel Highest -User 'SYSTEM' -Force | Out-Null
Write-Note 'LifePunch-Cornerman-Headless-Startup'

Write-Step 'Scheduled task AtLogon'
$logonTrigger = New-ScheduledTaskTrigger -AtLogon
Register-ScheduledTask -TaskName 'LifePunch-Cornerman-Headless-Logon' `
    -Action $action -Trigger $logonTrigger -Settings $settings `
    -RunLevel Highest -Force | Out-Null
Write-Note 'LifePunch-Cornerman-Headless-Logon (any user, runs after auto-login)'

Write-Step 'Run headless boot maintenance now'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $bootOnBox
Write-Note 'Log: C:\lifepunch\cornerman\headless-boot.log'

Write-Host ''
Write-Host 'Cornerman headless boot tasks installed. Re-applies power + SSH/RDP every reboot.' -ForegroundColor Cyan
