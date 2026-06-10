# VENGEANCE "bot" — watches lifepunchnet health + security (sessions, failed logons, down).
# Leave this window open. Pair with Install-ServerHostWatchdog.ps1 on the server box.

param(
    [int] $IntervalSeconds = 30,
    [string] $ConfigPath = $(Join-Path $PSScriptRoot 'server-host-watch.local.json')
)

$ErrorActionPreference = 'Stop'

function Read-WatchConfig {
    if (-not (Test-Path -LiteralPath $ConfigPath)) {
        throw @"
Missing $ConfigPath
Copy server-host-watch.local.json.example -> server-host-watch.local.json
Paste the token from lifepunchnet C:\lifepunch\status\status-token.txt
"@
    }
    return Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
}

function Get-StatusPayload([string]$HostAddr, [int]$Port, [string]$Token) {
    $uri = "http://${HostAddr}:${Port}/status"
    $headers = @{ Authorization = "Bearer $Token" }
    return Invoke-RestMethod -Uri $uri -Headers $headers -TimeoutSec 15 -Method Get
}

function Test-RdpPort([string]$HostAddr) {
    return (Test-NetConnection -ComputerName $HostAddr -Port 3389 -WarningAction SilentlyContinue).TcpTestSucceeded
}

function Format-SessionLine($sessions) {
    if (-not $sessions -or $sessions.Count -eq 0) { return '  (no interactive sessions)' }
    $lines = @()
    foreach ($s in $sessions) {
        $lines += "  $($s.user)  [$($s.state)]  idle=$($s.idle)"
    }
    return ($lines -join "`n")
}

$cfg = Read-WatchConfig
$hostAddr = [string]$cfg.host
$port = if ($cfg.statusPort) { [int]$cfg.statusPort } else { 9101 }
$token = [string]$cfg.token
$allowed = @($cfg.allowedUsers)

$lastState = $null
$lastAlerts = @()

Write-Host ''
Write-Host ('=' * 64) -ForegroundColor Cyan
Write-Host '  LIFEPUNCHNET WATCH  (lifepunch security + uptime bot)' -ForegroundColor Cyan
Write-Host ('=' * 64) -ForegroundColor Cyan
Write-Host "  Target   $hostAddr" -ForegroundColor DarkGray
Write-Host "  Poll     every ${IntervalSeconds}s" -ForegroundColor DarkGray
Write-Host '  Stop     Ctrl+C' -ForegroundColor DarkGray
Write-Host ''

while ($true) {
    $ts = Get-Date -Format 'HH:mm:ss'
    $state = 'UNKNOWN'
    $detail = ''

    try {
        $data = Get-StatusPayload -HostAddr $hostAddr -Port $port -Token $token
        $state = 'UP'
        $uptimeH = [math]::Round($data.boot.uptimeSeconds / 3600, 1)
        $alerts = @($data.alerts)

        Write-Host ''
        Write-Host ('-' * 64) -ForegroundColor DarkGray
        Write-Host "  [$ts]  ONLINE  uptime ${uptimeH}h  boot $($data.boot.bootTime)" -ForegroundColor Green
        Write-Host '  SESSIONS:' -ForegroundColor White
        Write-Host (Format-SessionLine $data.sessions)
        $wh = $data.whisper
        if ($wh) {
            $wtxt = if ($wh.running) { "running ($($wh.detail))" } else { "down ($($wh.detail))" }
            Write-Host "  WHISPER:  $wtxt" -ForegroundColor $(if ($wh.running) { 'DarkGray' } else { 'Yellow' })
        }

        if ($alerts.Count -gt 0) {
            foreach ($a in $alerts) {
                if ($lastAlerts -notcontains $a) {
                    Write-Host "  *** ALERT: $a" -ForegroundColor Red
                }
            }
        }
        $lastAlerts = $alerts
    }
    catch {
        $rdp = Test-RdpPort -HostAddr $hostAddr
        if ($rdp) {
            $state = 'DEGRADED'
            Write-Host ''
            Write-Host "  [$ts]  DEGRADED — RDP :3389 open but status API failed" -ForegroundColor Yellow
            Write-Host "         $($_.Exception.Message)" -ForegroundColor DarkGray
        }
        else {
            $state = 'DOWN'
            Write-Host ''
            Write-Host "  [$ts]  *** OFFLINE *** — no RDP, no status API" -ForegroundColor Red
        }
    }

    if ($lastState -and $lastState -ne $state) {
        Write-Host "  >> STATE CHANGE: $lastState -> $state" -ForegroundColor Magenta
    }
    $lastState = $state

    Start-Sleep -Seconds $IntervalSeconds
}
