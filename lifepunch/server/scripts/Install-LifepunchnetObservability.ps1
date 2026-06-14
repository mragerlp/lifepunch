<#
.SYNOPSIS
  Install LifePunch CVL Phase 1 observability on lifepunchnet (Grafana + Prometheus probes).

.DESCRIPTION
  Copies stack to C:\lifepunch\observability, registers AtLogon deploy task, scopes :3000 firewall.
  Requires: Docker Desktop, status-token.txt from watchdog install.

.PARAMETER RemoteAddress
  VENGEANCE home public IP for Grafana firewall scope (e.g. 71.250.46.224).

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\Install-LifepunchnetObservability.ps1 -RemoteAddress 71.250.46.224
#>
[CmdletBinding()]
param(
    [string] $RemoteAddress = '',
    [string] $ObsRoot = 'C:\lifepunch\observability',
    [string] $RepoObsPath = ''
)

$ErrorActionPreference = 'Stop'

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
          ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if (-not $isAdmin) { throw 'Run elevated on lifepunchnet (Administrator).' }

$here = $PSScriptRoot
if (-not $RepoObsPath) {
    $RepoObsPath = Join-Path (Split-Path -Parent $here) 'observability'
}
if (-not (Test-Path -LiteralPath $RepoObsPath)) {
    throw "Missing repo observability folder: $RepoObsPath"
}

function Write-Step($m) { Write-Host "==> $m" -ForegroundColor Cyan }

Write-Step 'Copy observability stack'
if (Test-Path -LiteralPath $ObsRoot) {
    Remove-Item -LiteralPath $ObsRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $ObsRoot | Out-Null
# PS 5.1: -LiteralPath never expands '*' — copy children explicitly
Get-ChildItem -Path $RepoObsPath -Force | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination $ObsRoot -Recurse -Force
}
if (Test-Path -LiteralPath (Join-Path $ObsRoot 'rendered')) {
    Remove-Item -LiteralPath (Join-Path $ObsRoot 'rendered') -Recurse -Force -ErrorAction SilentlyContinue
}

$deploy = Join-Path $ObsRoot 'deploy-observability.ps1'
if (-not (Test-Path -LiteralPath $deploy)) { throw "Missing $deploy after copy" }

Write-Step 'Scheduled task LifePunch-Observability-Deploy (AtLogon)'
$action = New-ScheduledTaskAction -Execute 'powershell.exe' `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$deploy`""
$trigger = New-ScheduledTaskTrigger -AtLogon
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
    -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 1)
Register-ScheduledTask -TaskName 'LifePunch-Observability-Deploy' -Action $action -Trigger $trigger `
    -Settings $settings -RunLevel Highest -Force | Out-Null

if ($RemoteAddress) {
    Write-Step "Firewall Grafana :3000 for $RemoteAddress"
    $fw = Join-Path $here 'Open-LifepunchnetGrafanaFirewall.ps1'
    & $fw -RemoteAddress $RemoteAddress
}
else {
    Write-Host '  Pass -RemoteAddress to scope Grafana :3000 to VENGEANCE home IP' -ForegroundColor Yellow
}

Write-Step 'Deploy now'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $deploy
exit $LASTEXITCODE
