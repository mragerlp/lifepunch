<#
.SYNOPSIS
  lifepunchnet turn-on-and-forget boot wiring (:9000 Whisper, :9101 watchdog, :9102 session hub).

.DESCRIPTION
  Run ELEVATED on lifepunchnet (Administrator). Idempotent — safe to re-run.

  - Docker: com.docker.service Automatic (+ manual Docker Desktop "Start when you sign in")
  - LifePunch-Whisper-Deploy: AtLogon -> C:\lifepunch\whisper\deploy-whisper.ps1
  - LifePunch-ServerHost-* + LifePunch-SessionHub: existing installers
  - Starts tasks now + smoke-tests ports

.PARAMETER RemoteAddress
  VENGEANCE home public IP for session hub + status firewall (e.g. 71.250.46.224).

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\Install-LifePunchNetBoot.ps1 -RemoteAddress 71.250.46.224
#>
[CmdletBinding()]
param(
    [string] $RemoteAddress = '',
    [int] $WhisperPort = 9000,
    [int] $StatusPort = 9101,
    [int] $SessionPort = 9102,
    [string] $WhisperDeployDir = 'C:\lifepunch\whisper',
    [string] $StatusDir = 'C:\lifepunch\status'
)

$ErrorActionPreference = 'Stop'

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
          ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if (-not $isAdmin) { throw 'Run elevated on lifepunchnet (Administrator).' }

$here = $PSScriptRoot
$repoWhisper = Join-Path (Split-Path -Parent $here) 'whisper\deploy-whisper.ps1'
$watchdogInstall = Join-Path $here 'Install-ServerHostWatchdog.ps1'
$hubInstall = Join-Path $here 'Install-LifepunchnetSessionHub.ps1'
$statusFirewall = Join-Path $here 'Open-LifepunchnetStatusFirewall.ps1'
$sessionFirewall = Join-Path $here 'Open-LifepunchnetSessionFirewall.ps1'
$whisperFirewall = Join-Path $here 'Open-LifepunchnetWhisperFirewall.ps1'
$secureCvl = Join-Path $here 'Secure-LifepunchnetCvlPorts.ps1'

function Write-Step($m) { Write-Host "==> $m" -ForegroundColor Cyan }
function Write-Note($m) { Write-Host "    $m" -ForegroundColor DarkGray }

function Test-PortListening([int]$Port) {
    return (Test-NetConnection -ComputerName 127.0.0.1 -Port $Port -WarningAction SilentlyContinue).TcpTestSucceeded
}

function Add-SmokeResult {
    param([string]$Label, [bool]$Pass, [string]$Detail = '')
    $script:Smoke += [pscustomobject]@{ Label = $Label; Pass = $Pass; Detail = $Detail }
}

$script:Smoke = [System.Collections.Generic.List[object]]::new()

Write-Step 'LifePunch net boot installer (lifepunchnet)'

# --- Docker service (daemon; Desktop still needs sign-in session) ---
Write-Step 'Docker service'
$dockerSvc = Get-Service -Name 'com.docker.service' -ErrorAction SilentlyContinue
if ($dockerSvc) {
    if ($dockerSvc.StartType -ne 'Automatic') {
        Set-Service -Name 'com.docker.service' -StartupType Automatic
        Write-Note 'com.docker.service -> Automatic'
    }
    else { Write-Note 'com.docker.service already Automatic' }
}
else {
    Write-Note 'com.docker.service not found — install Docker Desktop first'
}
Write-Host ''
Write-Host '  MANUAL (once per Administrator profile on lifepunchnet):' -ForegroundColor Yellow
Write-Host '    Docker Desktop -> Settings -> General -> Start Docker Desktop when you sign in' -ForegroundColor Yellow
Write-Host ''

# --- Whisper deploy script on-box path ---
Write-Step 'Whisper deploy script'
New-Item -ItemType Directory -Force -Path $WhisperDeployDir | Out-Null
$whisperOnBox = Join-Path $WhisperDeployDir 'deploy-whisper.ps1'
if (-not (Test-Path -LiteralPath $repoWhisper)) {
    throw "Missing repo script: $repoWhisper"
}
Copy-Item -LiteralPath $repoWhisper -Destination $whisperOnBox -Force
Write-Note "Copied -> $whisperOnBox"

$whisperAction = New-ScheduledTaskAction -Execute 'powershell.exe' `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$whisperOnBox`""
$logonTrigger = New-ScheduledTaskTrigger -AtLogon
$whisperSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
    -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 1)
Register-ScheduledTask -TaskName 'LifePunch-Whisper-Deploy' -Action $whisperAction -Trigger $logonTrigger `
    -Settings $whisperSettings -RunLevel Highest -Force | Out-Null
Write-Note 'Task: LifePunch-Whisper-Deploy (AtLogon)'

Write-Step 'Whisper deploy now'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $whisperOnBox
$whisperExit = $LASTEXITCODE
Write-Note "deploy-whisper exit: $whisperExit"

# --- Watchdog + status :9101 ---
Write-Step 'Watchdog + status server :9101'
if (-not (Test-Path -LiteralPath $watchdogInstall)) { throw "Missing $watchdogInstall" }
& $watchdogInstall -StatusPort $StatusPort
if ($RemoteAddress) {
    & $statusFirewall -RemoteAddress $RemoteAddress -Port $StatusPort
}

# --- Session hub :9102 ---
Write-Step 'Session hub :9102'
if (-not (Test-Path -LiteralPath $hubInstall)) { throw "Missing $hubInstall" }
if ($RemoteAddress) {
    & $hubInstall -Port $SessionPort -RemoteAddress $RemoteAddress
}
else {
    & $hubInstall -Port $SessionPort
    Write-Note 'Pass -RemoteAddress for scoped Public firewall on :9102'
}

if ($RemoteAddress -and (Test-Path -LiteralPath $sessionFirewall)) {
    & $sessionFirewall -RemoteAddress $RemoteAddress -Port $SessionPort
}

if ($RemoteAddress -and (Test-Path -LiteralPath $secureCvl)) {
    Write-Step 'CVL signal hardening (firewall scope)'
    & $secureCvl -RemoteAddress $RemoteAddress -WhisperPort $WhisperPort -StatusPort $StatusPort -SessionPort $SessionPort
}
elseif ($RemoteAddress -and (Test-Path -LiteralPath $whisperFirewall)) {
    & $whisperFirewall -RemoteAddress $RemoteAddress -Port $WhisperPort
}
else {
    Write-Host ''
    Write-Host '  SECURITY: pass -RemoteAddress <VENGEANCE-home-public-IP> before hub ingest' -ForegroundColor Yellow
    Write-Host '            Without it :9000 may be world-reachable via Docker bind.' -ForegroundColor Yellow
}

# --- Ensure startup tasks running ---
Write-Step 'Start scheduled tasks'
foreach ($task in @(
        'LifePunch-ServerHost-StatusServer',
        'LifePunch-ServerHost-Watchdog',
        'LifePunch-SessionHub'
    )) {
    Start-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue
    $info = Get-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue
    if ($info) { Write-Note "$task -> $($info.State)" }
}

Start-Sleep -Seconds 5

# --- Smoke tests ---
Write-Step 'Smoke tests'
Add-SmokeResult -Label "Whisper TCP :$WhisperPort" -Pass (Test-PortListening $WhisperPort) `
    -Detail $(if (Test-PortListening $WhisperPort) { 'listening' } else { 'closed' })

try {
    $health = Invoke-RestMethod -Uri "http://127.0.0.1:${WhisperPort}/health" -TimeoutSec 15
    $model = if ($health.model) { [string]$health.model } else { ($health | ConvertTo-Json -Compress) }
    Add-SmokeResult -Label 'Whisper /health' -Pass ($model -match 'small\.en') -Detail $model
}
catch {
    Add-SmokeResult -Label 'Whisper /health' -Pass $false -Detail $_.Exception.Message
}

$tokenFile = Join-Path $StatusDir 'status-token.txt'
if (Test-Path -LiteralPath $tokenFile) {
    $token = (Get-Content -LiteralPath $tokenFile -Raw).Trim()
    $h = @{ Authorization = "Bearer $token" }
    try {
        $st = Invoke-RestMethod -Uri "http://127.0.0.1:${StatusPort}/status" -Headers $h -TimeoutSec 15
        $w = if ($st.whisper.running) { 'whisper running' } else { 'whisper down in status payload' }
        Add-SmokeResult -Label "Watchdog :$StatusPort" -Pass $true -Detail $w
    }
    catch {
        Add-SmokeResult -Label "Watchdog :$StatusPort" -Pass $false -Detail $_.Exception.Message
    }
    try {
        $hub = Invoke-RestMethod -Uri "http://127.0.0.1:${SessionPort}/status" -Headers $h -TimeoutSec 15
        Add-SmokeResult -Label "Session hub :$SessionPort" -Pass $true -Detail "$($hub.lines) lines"
    }
    catch {
        Add-SmokeResult -Label "Session hub :$SessionPort" -Pass $false -Detail $_.Exception.Message
    }
}
else {
    Add-SmokeResult -Label 'status-token.txt' -Pass $false -Detail "missing $tokenFile"
}

Write-Host ''
foreach ($s in $script:Smoke) {
    $color = if ($s.Pass) { 'Green' } else { 'Red' }
    $mark = if ($s.Pass) { 'OK' } else { 'FAIL' }
    Write-Host ("  [{0}] {1}" -f $mark, $s.Label) -ForegroundColor $color
    if ($s.Detail) { Write-Host "        $($s.Detail)" -ForegroundColor DarkGray }
}

$allOk = ($script:Smoke | Where-Object { -not $_.Pass }).Count -eq 0
Write-Host ''
if ($allOk) {
    Write-Host 'lifepunchnet boot OK — :9000 / :9101 / :9102 ready for VENGEANCE Start Day.' -ForegroundColor Green
}
else {
    Write-Host 'Some smoke checks failed — fix above, then re-run this installer.' -ForegroundColor Yellow
}
Write-Host ''
Write-Host 'VENGEANCE: copy status-token.txt -> server-host-watch.local.json, then LifePunch — Start Day.' -ForegroundColor Cyan
exit $(if ($allOk) { 0 } else { 1 })
