# VENGEANCE "bot" — watches lifepunchnet health + security (sessions, failed logons, down).
# Leave this window open. Pair with Install-ServerHostWatchdog.ps1 on the server box.

param(
    [int] $IntervalSeconds = 30,
    [string] $ConfigPath = $(Join-Path $PSScriptRoot 'server-host-watch.local.json')
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Voice-Console.ps1')
. (Join-Path $PSScriptRoot 'Cvl-Hub.ps1')
# lifepunchnet watch = Blue channel; body text gray/white (never DarkGray on black)
$script:VoiceConsoleAccent = 'Blue'

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

Write-VoiceHeader `
    -Title 'LIFEPUNCHNET WATCH  (security + uptime)' `
    -Subtitle 'Whisper :9000, sessions, alerts from :9101'
Write-VoiceMeta -Label 'Target' -Value $hostAddr
Write-VoiceMeta -Label 'Poll' -Value "every ${IntervalSeconds}s"
Write-VoiceMeta -Label 'Stop' -Value 'Ctrl+C in this window'
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
        Write-VoiceDivider
        Write-VoiceEvent -Name 'ONLINE' -Detail "uptime ${uptimeH}h  boot $($data.boot.bootTime)" -Color Green
        Write-Host '  SESSIONS:' -ForegroundColor White
        Write-VoiceBody (Format-SessionLine $data.sessions)
        $wh = $data.whisper
        if ($wh) {
            $wtxt = if ($wh.running) { "running ($($wh.detail))" } else { "down ($($wh.detail))" }
            Write-VoiceStatus -Label 'WHISPER' -Value $wtxt -Ok ([bool]$wh.running)
        }

        if ($alerts.Count -gt 0) {
            foreach ($a in $alerts) {
                if ($lastAlerts -notcontains $a) {
                    Write-Host "  *** ALERT: $a" -ForegroundColor Red
                    try {
                        Send-CvlHubIngest -Tier lifepunchnet -Type 'cvl-security' -Text $a -Extra @{ alert = $a; state = $state }
                    }
                    catch { }
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
            Write-VoiceMuted $_.Exception.Message
        }
        else {
            $state = 'DOWN'
            Write-Host ''
            Write-Host "  [$ts]  *** OFFLINE *** — no RDP, no status API" -ForegroundColor Red
        }
    }

    if ($lastState -and $lastState -ne $state) {
        Write-Host "  >> STATE CHANGE: $lastState -> $state" -ForegroundColor Magenta
        try {
            Send-CvlHubIngest -Tier lifepunchnet -Type 'cvl-uptime' -Text "state $lastState -> $state" -Extra @{
                priorState = $lastState; state = $state
            }
        }
        catch { }
    }
    $lastState = $state

    Start-Sleep -Seconds $IntervalSeconds
}
