# lifepunchnet watchdog — collects health + security signals for the VENGEANCE watcher.
# Run on the server box (scheduled task). Writes C:\lifepunch\status\watchdog.json

param(
    [string] $StatusDir = 'C:\lifepunch\status',
    [string[]] $AllowedUsers,
    [int] $EventLookbackMinutes = 10
)

$configFile = Join-Path $StatusDir 'watchdog-config.json'
if (-not $AllowedUsers -and (Test-Path -LiteralPath $configFile)) {
    try {
        $cfg = Get-Content -LiteralPath $configFile -Raw | ConvertFrom-Json
        $AllowedUsers = @($cfg.allowedUsers)
    }
    catch { }
}
if (-not $AllowedUsers) { $AllowedUsers = @('jared') }

$ErrorActionPreference = 'Continue'

function Ensure-StatusDir([string]$Dir) {
    if (-not (Test-Path -LiteralPath $Dir)) {
        New-Item -ItemType Directory -Force -Path $Dir | Out-Null
    }
}

function Get-BootInfo {
    $os = Get-CimInstance Win32_OperatingSystem
    $boot = $os.LastBootUpTime
    $uptimeSec = [int]((Get-Date) - $boot).TotalSeconds
    [pscustomobject]@{
        bootTime     = $boot.ToString('o')
        uptimeSeconds = $uptimeSec
        hostname     = $env:COMPUTERNAME
    }
}

function Get-InteractiveSessions {
    $rows = @()
    try {
        $raw = query user 2>$null
        if (-not $raw) { return $rows }
        foreach ($line in $raw | Select-Object -Skip 1) {
            $line = ($line -replace '\s{2,}', '|').Trim('|')
            $p = $line -split '\|'
            if ($p.Count -ge 1 -and $p[0] -notmatch 'USERNAME') {
                $rows += [pscustomobject]@{
                    user      = $p[0].Trim()
                    session   = if ($p.Count -gt 1) { $p[1].Trim() } else { '' }
                    state     = if ($p.Count -gt 3) { $p[3].Trim() } else { '' }
                    idle      = if ($p.Count -gt 4) { $p[4].Trim() } else { '' }
                }
            }
        }
    }
    catch { }
    return $rows
}

function Get-AuthEvents([int]$Minutes) {
    $since = (Get-Date).AddMinutes(-1 * $Minutes)
    $events = @()
    $ids = 4624, 4625, 4778, 4779
    try {
        $filter = @{ LogName = 'Security'; Id = $ids; StartTime = $since }
        Get-WinEvent -FilterHashtable $filter -MaxEvents 40 -ErrorAction Stop | ForEach-Object {
            $xml = [xml]$_.ToXml()
            $d = @{}
            foreach ($n in $xml.Event.EventData.Data) { $d[$n.Name] = $n.'#text' }
            $events += [pscustomobject]@{
                time       = $_.TimeCreated.ToString('o')
                id         = $_.Id
                user       = $d.TargetUserName
                domain     = $d.TargetDomainName
                logonType  = $d.LogonType
                ip         = $d.IpAddress
                status     = $d.Status
                message    = switch ($_.Id) {
                    4624 { 'logon' }
                    4625 { 'logon-failed' }
                    4778 { 'rdp-reconnect' }
                    4779 { 'rdp-disconnect' }
                    default { 'auth' }
                }
            }
        }
    }
    catch {
        # Security log may need elevation; still emit partial status.
    }
    return $events | Select-Object -First 25
}

function Get-WhisperDockerStatus {
    try {
        $out = docker ps --filter name=whisper --format '{{.Names}}|{{.Status}}' 2>$null
        if (-not $out) { return @{ running = $false; detail = 'container not found' } }
        $p = $out.Split('|')
        return @{ running = $true; name = $p[0]; detail = $p[1] }
    }
    catch {
        return @{ running = $false; detail = 'docker unavailable' }
    }
}

function Get-ServiceStates {
    $names = 'TermService', 'sshd', 'com.docker.service'
    $out = @{}
    foreach ($n in $names) {
        $s = Get-Service -Name $n -ErrorAction SilentlyContinue
        if ($s) { $out[$n] = $s.Status.ToString() }
    }
    return $out
}

function New-Alerts($Sessions, $AuthEvents, $Allowed) {
    $alerts = @()
    foreach ($s in $Sessions) {
        $u = $s.user
        if ($u -and $u -ne 'USERNAME' -and $Allowed -notcontains $u) {
            $alerts += "UNEXPECTED_SESSION: $u ($($s.state))"
        }
    }
    foreach ($e in $AuthEvents) {
        if ($e.id -eq 4625) {
            $alerts += "FAILED_LOGON: $($e.user) from $($e.ip)"
        }
        if ($e.id -eq 4624 -and $e.logonType -eq '10' -and $Allowed -notcontains $e.user) {
            $alerts += "RDP_LOGON: $($e.user) from $($e.ip)"
        }
    }
    return $alerts | Select-Object -Unique
}

Ensure-StatusDir $StatusDir
$prevPath = Join-Path $StatusDir 'watchdog.prev.json'
$outPath  = Join-Path $StatusDir 'watchdog.json'
$logPath  = Join-Path $StatusDir 'events.ndjson'

$payload = [ordered]@{
    ts          = (Get-Date).ToUniversalTime().ToString('o')
    boot        = Get-BootInfo
    sessions    = @(Get-InteractiveSessions)
    services    = Get-ServiceStates
    whisper     = Get-WhisperDockerStatus
    authEvents  = @(Get-AuthEvents -Minutes $EventLookbackMinutes)
    alerts      = @(New-Alerts -Sessions (Get-InteractiveSessions) -AuthEvents (Get-AuthEvents -Minutes $EventLookbackMinutes) -Allowed $AllowedUsers)
}

$json = $payload | ConvertTo-Json -Depth 6
Set-Content -LiteralPath $outPath -Value $json -Encoding UTF8

# Append new alerts to ndjson log for forensics
if ($payload.alerts.Count -gt 0) {
    $prevAlerts = @()
    if (Test-Path -LiteralPath $prevPath) {
        try {
            $prev = Get-Content -LiteralPath $prevPath -Raw | ConvertFrom-Json
            $prevAlerts = @($prev.alerts)
        }
        catch { }
    }
    foreach ($a in $payload.alerts) {
        if ($prevAlerts -notcontains $a) {
            $line = @{ ts = $payload.ts; alert = $a } | ConvertTo-Json -Compress
            Add-Content -LiteralPath $logPath -Value $line -Encoding UTF8
        }
    }
}

Copy-Item -LiteralPath $outPath -Destination $prevPath -Force

# Optional outbound alert (set LIFEPUNCH_ALERT_WEBHOOK in server env / secure local file)
$webhook = $env:LIFEPUNCH_ALERT_WEBHOOK
if ($webhook -and $payload.alerts.Count -gt 0) {
    $body = @{
        content = "lifepunchnet alert on $($env:COMPUTERNAME):`n" + ($payload.alerts -join "`n")
    } | ConvertTo-Json
    try {
        Invoke-RestMethod -Uri $webhook -Method Post -Body $body -ContentType 'application/json' -TimeoutSec 15
    }
    catch { }
}
