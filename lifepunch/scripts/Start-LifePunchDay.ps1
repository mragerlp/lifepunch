<#
.SYNOPSIS
  One action: LifePunch day is live — lifepunchnet STT + Cornerman relay + VENGEANCE paste watcher.

.DESCRIPTION
  Gates on lifepunchnet Whisper :9000 (no SSH to lifepunchnet in v1 — hosted services must auto-boot).
  Starts VENGEANCE watchers in background windows and remote-starts Cornerman PTT relay.
#>
[CmdletBinding()]
param(
    [switch] $SkipCornermanRelay,
    [switch] $OpenRdpOnFailure
)

$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
. (Join-Path $Here 'Voice-Console.ps1')

$WatchConfigPath = Join-Path $Here 'server-host-watch.local.json'
$RemoteHostsBase = Join-Path $Here 'remote-hosts.json'
$RemoteHostsLocal = Join-Path $Here 'remote-hosts.local.json'
$CornermanSsh = if ($env:CORNERMAN_SSH) { $env:CORNERMAN_SSH } else { 'cornerman' }
$CornermanRelayScript = 'C:\Projects\cornerman-rag\Start-CornermanVoiceRelay.ps1'

$script:Checks = [System.Collections.Generic.List[object]]::new()
$script:GateFailed = $false

function Add-Check {
    param([string]$Label, [bool]$Pass, [string]$Detail = '')
    $script:Checks.Add([pscustomobject]@{ Label = $Label; Pass = $Pass; Detail = $Detail })
    if (-not $Pass -and $Label -eq 'lifepunchnet Whisper :9000 (gate)') {
        $script:GateFailed = $true
    }
}

function Get-LifepunchnetHost {
    if (Test-Path -LiteralPath $WatchConfigPath) {
        $w = Get-Content -LiteralPath $WatchConfigPath -Raw | ConvertFrom-Json
        if ($w.host) { return [string]$w.host }
    }
    if (Test-Path -LiteralPath $RemoteHostsLocal) {
        $r = Get-Content -LiteralPath $RemoteHostsLocal -Raw | ConvertFrom-Json
        if ($r.lifepunchnet.host) { return [string]$r.lifepunchnet.host }
    }
    if (Test-Path -LiteralPath $RemoteHostsBase) {
        $r = Get-Content -LiteralPath $RemoteHostsBase -Raw | ConvertFrom-Json
        if ($r.lifepunchnet.host) { return [string]$r.lifepunchnet.host }
    }
    if ($env:LIFEPUNCH_LIFEPUNCHNET_HOST) { return $env:LIFEPUNCH_LIFEPUNCHNET_HOST.Trim() }
    return '205.209.104.22'
}

function Start-BackgroundScript {
    param([string]$Title, [string]$ScriptName)
    $path = Join-Path $Here $ScriptName
    if (-not (Test-Path -LiteralPath $path)) { throw "Missing $path" }
    $args = @(
        '-NoExit', '-ExecutionPolicy', 'Bypass', '-NoProfile',
        '-Command', "& { `$Host.UI.RawUI.WindowTitle = '$Title'; & '$path' }"
    )
    Start-Process -FilePath 'powershell.exe' -ArgumentList $args -WindowStyle Normal | Out-Null
    Write-Host "  Started: $Title" -ForegroundColor Green
}

function Open-EyesOnRdp {
    param([switch]$Lifepunchnet, [switch]$Cornerman)
    $desktop = [Environment]::GetFolderPath('Desktop')
    $rdpDir = Join-Path $env:USERPROFILE 'Documents\LifePunch-RDP'
    if ($Lifepunchnet) {
        foreach ($p in @(
                (Join-Path $desktop 'lifepunchnet (RDP).lnk'),
                (Join-Path $rdpDir 'lifepunchnet.rdp')
            )) {
            if (Test-Path -LiteralPath $p) {
                Start-Process -FilePath $p
                Write-Host "  Opened: $p" -ForegroundColor Yellow
                return
            }
        }
    }
    if ($Cornerman) {
        foreach ($p in @(
                (Join-Path $desktop 'Cornerman (RDP).lnk'),
                (Join-Path $rdpDir 'cornerman.rdp')
            )) {
            if (Test-Path -LiteralPath $p) {
                Start-Process -FilePath $p
                Write-Host "  Opened: $p" -ForegroundColor Yellow
                return
            }
        }
    }
    Write-Host '  No RDP shortcut found — run Install-LifePunchRemoteShortcuts.ps1' -ForegroundColor DarkGray
}

Write-VoiceHeader -Title 'LIFEPUNCH — START DAY' -Subtitle 'lifepunchnet STT + Cornerman relay + paste watcher'

$lpHost = Get-LifepunchnetHost
Write-VoiceMeta -Label 'lifepunchnet' -Value $lpHost
Write-VoiceMeta -Label 'Cornerman' -Value $CornermanSsh
Write-Host ''

# --- lifepunchnet gate :9000 ---
Write-Host 'Preflight lifepunchnet...' -ForegroundColor Cyan
$tcp9000 = Test-NetConnection -ComputerName $lpHost -Port 9000 -WarningAction SilentlyContinue
Add-Check -Label 'lifepunchnet Whisper :9000 (gate)' -Pass $tcp9000.TcpTestSucceeded -Detail $(if ($tcp9000.TcpTestSucceeded) { 'TCP open' } else { 'timeout / refused' })

# Optional :9101 status API
$watchCfg = $null
if (Test-Path -LiteralPath $WatchConfigPath) {
    $watchCfg = Get-Content -LiteralPath $WatchConfigPath -Raw | ConvertFrom-Json
    Add-Check -Label 'server-host-watch.local.json' -Pass $true -Detail $watchCfg.host
    $port9101 = if ($watchCfg.statusPort) { [int]$watchCfg.statusPort } else { 9101 }
    try {
        $h = @{ Authorization = "Bearer $($watchCfg.token)" }
        $status = Invoke-RestMethod -Uri "http://${lpHost}:${port9101}/status" -Headers $h -TimeoutSec 12
        $w = if ($status.whisper.running) { 'whisper running' } else { 'whisper down in status' }
        Add-Check -Label 'lifepunchnet watchdog :9101' -Pass $status.whisper.running -Detail $w
    }
    catch {
        Add-Check -Label 'lifepunchnet watchdog :9101' -Pass $false -Detail $_.Exception.Message
    }
    try {
        $port9102 = if ($watchCfg.sessionPort) { [int]$watchCfg.sessionPort } else { 9102 }
        $hub = Invoke-RestMethod -Uri "http://${lpHost}:${port9102}/status" -Headers $h -TimeoutSec 12
        Add-Check -Label 'lifepunchnet session hub :9102' -Pass $true -Detail "$($hub.lines) lines"
    }
    catch {
        Add-Check -Label 'lifepunchnet session hub :9102' -Pass $false -Detail $_.Exception.Message
    }
}
else {
    Add-Check -Label 'server-host-watch.local.json' -Pass $false -Detail 'copy .example + token from lifepunchnet'
}

# Optional Whisper health
if ($tcp9000.TcpTestSucceeded) {
    try {
        $health = Invoke-RestMethod -Uri "http://${lpHost}:9000/health" -TimeoutSec 10
        $model = if ($health.model) { [string]$health.model } elseif ($health.PSObject.Properties.Name -contains 'status') { [string]$health.status } else { ($health | ConvertTo-Json -Compress) }
        $modelOk = $model -match 'small\.en'
        Add-Check -Label 'Whisper /health' -Pass $modelOk -Detail $model
    }
    catch {
        Add-Check -Label 'Whisper /health' -Pass $false -Detail $_.Exception.Message
    }
}

# --- Cornerman ---
Write-Host ''
Write-Host 'Preflight Cornerman...' -ForegroundColor Cyan
$sshOk = $false
try {
    $pong = ssh -o BatchMode=yes -o ConnectTimeout=8 $CornermanSsh 'echo ok' 2>$null
    $sshOk = ($LASTEXITCODE -eq 0 -and $pong -eq 'ok')
}
catch { $sshOk = $false }
Add-Check -Label 'Cornerman SSH' -Pass $sshOk -Detail $CornermanSsh

if ($sshOk) {
    $relayScriptOk = ssh -o BatchMode=yes -o ConnectTimeout=8 $CornermanSsh "if (Test-Path -LiteralPath '$CornermanRelayScript') { 'yes' } else { 'no' }" 2>$null
    Add-Check -Label 'Start-CornermanVoiceRelay.ps1' -Pass ($relayScriptOk -eq 'yes') -Detail $CornermanRelayScript
}

# --- Results table ---
Write-Host ''
Write-VoiceDivider
foreach ($c in $script:Checks) {
    $color = if ($c.Pass) { 'Green' } else { 'Red' }
    $mark = if ($c.Pass) { 'OK' } else { 'FAIL' }
    Write-Host ("  [{0}]  {1}" -f $mark, $c.Label) -ForegroundColor $color
    if ($c.Detail) { Write-Host "         $($c.Detail)" -ForegroundColor DarkGray }
}
Write-VoiceDivider
Write-Host ''

if ($script:GateFailed) {
    Write-Host 'STOP: start lifepunchnet Whisper first (not a Cornerman issue).' -ForegroundColor Red
    Write-Host '  Hosted box must have :9000 listening. VENGEANCE cannot start Docker on lifepunchnet in v1.' -ForegroundColor DarkGray
    if ($OpenRdpOnFailure) { Open-EyesOnRdp -Lifepunchnet }
    exit 1
}

if (-not $sshOk) {
    Write-Host 'STOP: Cornerman SSH failed.' -ForegroundColor Red
    if ($OpenRdpOnFailure) { Open-EyesOnRdp -Cornerman }
    exit 1
}

# --- Start VENGEANCE watchers ---
Write-Host 'Starting VENGEANCE voice stack...' -ForegroundColor Cyan
Start-BackgroundScript -Title 'LifePunch Voice Watch' -ScriptName 'start-vengeance-voice-watch.ps1'
Start-Sleep -Milliseconds 400
Start-BackgroundScript -Title 'LifePunch Session Sync' -ScriptName 'start-session-sync.ps1'
Start-Sleep -Milliseconds 400
Start-BackgroundScript -Title 'LifePunch lifepunchnet Watch' -ScriptName 'start-server-host-watch.ps1'
Write-Host ''

# --- Remote-start Cornerman relay ---
if (-not $SkipCornermanRelay) {
    Write-Host 'Starting Cornerman Talk to Vengeance (PTT)...' -ForegroundColor Cyan
    ssh -o BatchMode=yes $CornermanSsh "powershell -NoProfile -ExecutionPolicy Bypass -File `"$CornermanRelayScript`""
    if ($LASTEXITCODE -ne 0) {
        Write-Host '  Remote relay start failed — open Cornerman and run Talk to Vengeance.cmd' -ForegroundColor Yellow
        if ($OpenRdpOnFailure) { Open-EyesOnRdp -Cornerman }
    }
}

Write-Host ''
Write-Host '============================================================' -ForegroundColor Green
Write-Host '  LIFEPUNCH DAY IS LIVE' -ForegroundColor Green
Write-Host '  F7 arm -> Ready -> F8 talk -> Ctrl+V in Cursor' -ForegroundColor Green
Write-Host '============================================================' -ForegroundColor Green
Write-Host ''
