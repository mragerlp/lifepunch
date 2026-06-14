<#
.SYNOPSIS
  Verify lifepunchnet Grafana Phase 1 reachable from VENGEANCE.

.EXAMPLE
  powershell -File lifepunch\scripts\Test-LifepunchnetObservability.ps1
#>
[CmdletBinding()]
param(
    [string] $ConfigPath = '',
    [int] $GrafanaPort = 0,
    [int] $TimeoutSec = 15
)

$ErrorActionPreference = 'Continue'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $ConfigPath) {
    $ConfigPath = Join-Path $Here 'server-host-watch.local.json'
}
$ok = $true

function Report([string]$Label, [bool]$Pass, [string]$Detail = '') {
    $color = if ($Pass) { 'Green' } else { 'Red' }
    $mark = if ($Pass) { 'OK' } else { 'FAIL' }
    Write-Host ("  [{0}] {1}" -f $mark, $Label) -ForegroundColor $color
    if ($Detail) { Write-Host "        $Detail" -ForegroundColor DarkGray }
    if (-not $Pass) { $script:ok = $false }
}

Write-Host ''
Write-Host '=== lifepunchnet observability (Phase 1) ===' -ForegroundColor Cyan

$hostAddr = '205.209.104.22'
$port = 3000

if (Test-Path -LiteralPath $ConfigPath) {
    $cfg = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
    if ($cfg.host) { $hostAddr = [string]$cfg.host }
    if ($cfg.grafanaPort) { $port = [int]$cfg.grafanaPort }
}
if ($GrafanaPort -gt 0) { $port = $GrafanaPort }

$loginUrl = "http://${hostAddr}:${port}/login"
Report 'Config host' $true "$hostAddr : grafana :$port"

try {
    $r = Invoke-WebRequest -Uri $loginUrl -UseBasicParsing -TimeoutSec $TimeoutSec
    Report 'Grafana /login' ($r.StatusCode -eq 200) "HTTP $($r.StatusCode)"
}
catch {
    Report 'Grafana /login' $false $_.Exception.Message
}

if ($cfg -and $cfg.token) {
    $h = @{ Authorization = "Bearer $($cfg.token)" }
    foreach ($pair in @(
            @{ Port = 9101; Name = 'watchdog' }
            @{ Port = 9102; Name = 'session_hub' }
        )) {
        try {
            $st = Invoke-RestMethod -Uri "http://${hostAddr}:$($pair.Port)/status" -Headers $h -TimeoutSec $TimeoutSec
            Report ("CVL :$($pair.Port) " + $pair.Name) $true 'reachable'
        }
        catch {
            Report ("CVL :$($pair.Port) " + $pair.Name) $false $_.Exception.Message
        }
    }
    try {
        $wh = Invoke-RestMethod -Uri "http://${hostAddr}:9000/health" -TimeoutSec $TimeoutSec
        $model = if ($wh.model) { $wh.model } else { 'ok' }
        Report 'Whisper :9000 /health' $true $model
    }
    catch {
        Report 'Whisper :9000 /health' $false $_.Exception.Message
    }
}
else {
    Report 'server-host-watch.local.json' $false 'Optional — copy .example for full CVL probe set'
}

Write-Host ''
if ($ok) {
    Write-Host "Grafana UI: $loginUrl (password on lifepunchnet secrets\grafana-admin.txt)" -ForegroundColor Green
}
else {
    Write-Host 'Fix: RDP lifepunchnet -> Install-LifepunchnetObservability.ps1 -RemoteAddress <home-ip>' -ForegroundColor Yellow
}
Write-Host ''
exit $(if ($ok) { 0 } else { 1 })
