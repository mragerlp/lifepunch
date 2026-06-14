<#
.SYNOPSIS
  Render configs and start Grafana + Prometheus + Blackbox on lifepunchnet.

.DESCRIPTION
  Run on lifepunchnet after Install-ServerHostWatchdog.ps1 (needs status-token.txt).
  Idempotent — safe to re-run after token rotation or git pull.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File C:\lifepunch\observability\deploy-observability.ps1
#>
[CmdletBinding()]
param(
    [string] $ObsRoot = 'C:\lifepunch\observability',
    [string] $StatusTokenFile = 'C:\lifepunch\status\status-token.txt',
    [string] $GrafanaPasswordFile = 'C:\lifepunch\observability\secrets\grafana-admin.txt',
    [int] $DockerWaitSeconds = 180
)

$ErrorActionPreference = 'Stop'

function Write-Log([string]$Message) {
    $line = '{0}  {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    Write-Host $line
}

function Test-DockerReady {
    docker info 2>$null | Out-Null
    return ($LASTEXITCODE -eq 0)
}

function Get-OrCreateGrafanaPassword([string]$Path) {
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    if (Test-Path -LiteralPath $Path) {
        return (Get-Content -LiteralPath $Path -Raw).Trim()
    }
    $bytes = New-Object byte[] 24
    [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
    $pw = [Convert]::ToBase64String($bytes) -replace '[^a-zA-Z0-9]', 'x'
    Set-Content -LiteralPath $Path -Value $pw -Encoding UTF8 -NoNewline
    Write-Log "Grafana admin password written -> $Path (user: admin)"
    return $pw
}

if (-not (Test-Path -LiteralPath $StatusTokenFile)) {
    throw "Missing $StatusTokenFile - run Install-ServerHostWatchdog.ps1 first."
}
$statusToken = (Get-Content -LiteralPath $StatusTokenFile -Raw).Trim()
if (-not $statusToken) { throw 'status-token.txt is empty' }

$composeFile = Join-Path $ObsRoot 'docker-compose.yml'
if (-not (Test-Path -LiteralPath $composeFile)) {
    throw "Missing $composeFile - run Install-LifepunchnetObservability.ps1 first."
}

$renderedDir = Join-Path $ObsRoot 'rendered'
New-Item -ItemType Directory -Force -Path $renderedDir | Out-Null

$promTpl = Join-Path $ObsRoot 'prometheus\prometheus.yml.template'
$bbTpl = Join-Path $ObsRoot 'blackbox\blackbox.yml.template'
if (-not (Test-Path -LiteralPath $promTpl)) { throw "Missing $promTpl" }
if (-not (Test-Path -LiteralPath $bbTpl)) { throw "Missing $bbTpl" }

Copy-Item -LiteralPath $promTpl -Destination (Join-Path $renderedDir 'prometheus.yml') -Force
$bbOut = Join-Path $renderedDir 'blackbox.yml'
(Get-Content -LiteralPath $bbTpl -Raw).Replace('__STATUS_TOKEN__', $statusToken) |
    Set-Content -LiteralPath $bbOut -Encoding UTF8 -NoNewline

$grafanaPw = Get-OrCreateGrafanaPassword -Path $GrafanaPasswordFile
$env:GRAFANA_ADMIN_PASSWORD = $grafanaPw

Write-Log 'Waiting for Docker...'
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw 'docker CLI not found on lifepunchnet'
}
$deadline = (Get-Date).AddSeconds($DockerWaitSeconds)
while (-not (Test-DockerReady)) {
    if ((Get-Date) -gt $deadline) { throw "Docker not ready after ${DockerWaitSeconds}s" }
    Start-Sleep -Seconds 5
}

Push-Location $ObsRoot
try {
    $prevEa = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    Write-Log 'docker compose pull'
    docker compose pull 2>&1 | ForEach-Object { Write-Log ([string]$_) }
    $pullExit = $LASTEXITCODE
    Write-Log 'docker compose up -d'
    docker compose up -d 2>&1 | ForEach-Object { Write-Log ([string]$_) }
    $upExit = $LASTEXITCODE
    $ErrorActionPreference = $prevEa
    if ($pullExit -ne 0 -or $upExit -ne 0) {
        throw "docker compose failed (pull=$pullExit up=$upExit)"
    }
}
finally {
    Pop-Location
}

Start-Sleep -Seconds 8

$smoke = @()
try {
    $r = Invoke-WebRequest -Uri 'http://127.0.0.1:3000/login' -UseBasicParsing -TimeoutSec 15
    $smoke += [pscustomobject]@{ Label = 'Grafana :3000'; Pass = ($r.StatusCode -eq 200) }
}
catch {
    $smoke += [pscustomobject]@{ Label = 'Grafana :3000'; Pass = $false; Detail = $_.Exception.Message }
}

try {
    $targets = Invoke-RestMethod -Uri 'http://127.0.0.1:9091/api/v1/targets' -TimeoutSec 15
    $up = @($targets.data.activeTargets | Where-Object { $_.health -eq 'up' }).Count
    $total = @($targets.data.activeTargets).Count
    $smoke += [pscustomobject]@{ Label = 'Prometheus targets'; Pass = ($up -ge 3); Detail = "$up/$total up" }
}
catch {
    $smoke += [pscustomobject]@{ Label = 'Prometheus targets'; Pass = $false; Detail = $_.Exception.Message }
}

Write-Host ''
foreach ($s in $smoke) {
    $color = if ($s.Pass) { 'Green' } else { 'Red' }
    $mark = if ($s.Pass) { 'OK' } else { 'FAIL' }
    Write-Host ("  [{0}] {1}" -f $mark, $s.Label) -ForegroundColor $color
    if ($s.Detail) { Write-Host "        $($s.Detail)" -ForegroundColor DarkGray }
}

Write-Host ''
Write-Host 'Grafana: http://<lifepunchnet-ip>:3000  user=admin  password in secrets\grafana-admin.txt' -ForegroundColor Cyan
Write-Host 'Dashboard: LifePunch folder -> LifePunch CVL - Phase 1' -ForegroundColor Cyan

$fail = @($smoke | Where-Object { -not $_.Pass }).Count
exit $(if ($fail -eq 0) { 0 } else { 1 })
