# lifepunchnet watchdog - collects health + security signals for the VENGEANCE watcher.
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
$baselineAllowed = @('jared', 'administrator')
if (-not $AllowedUsers) {
    $AllowedUsers = $baselineAllowed
}
else {
    $AllowedUsers = @($baselineAllowed + $AllowedUsers | Select-Object -Unique)
}

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

function Get-LaneGitHead {
    $candidates = @(
        'C:\lifepunch\lifepunch-rdp-server',
        'C:\Projects\lifepunch',
        'C:\lifepunch\lifepunchaddons'
    )
    foreach ($root in $candidates) {
        if (-not (Test-Path -LiteralPath (Join-Path $root '.git'))) { continue }
        Push-Location $root
        try {
            $head = (git log -1 --format='%h' 2>$null)
            $branch = (git branch --show-current 2>$null)
            $subject = (git log -1 --format='%s' 2>$null)
            if ($head) {
                return @{
                    head    = $head.Trim()
                    branch  = if ($branch) { $branch.Trim() } else { '' }
                    subject = if ($subject) { $subject.Trim() } else { '' }
                    root    = $root
                    detail  = 'ok'
                }
            }
        }
        catch { }
        finally { Pop-Location }
    }
    return @{ head = ''; branch = ''; subject = ''; root = ''; detail = 'no-clone' }
}

function Get-OdysseusProbe {
    $installDir = 'C:\lifepunch\odysseus'
    $installed = Test-Path -LiteralPath (Join-Path $installDir '.git')
    $httpOk = $false
    $port = 7000
    $statusFile = Join-Path $StatusDir 'odysseus.json'
    if (Test-Path -LiteralPath $statusFile) {
        try {
            $st = Get-Content -LiteralPath $statusFile -Raw | ConvertFrom-Json
            if ($st.port) { $port = [int]$st.port }
            if ($st.installDir) { $installed = Test-Path -LiteralPath (Join-Path $st.installDir '.git') }
        }
        catch { }
    }
    try {
        $r = Invoke-WebRequest -Uri "http://127.0.0.1:$port" -TimeoutSec 4 -UseBasicParsing -ErrorAction Stop
        $httpOk = ($r.StatusCode -ge 200 -and $r.StatusCode -lt 500)
    }
    catch { }
    $ollama = $false
    try {
        $r = Invoke-RestMethod -Uri 'http://127.0.0.1:11434/api/tags' -TimeoutSec 3 -ErrorAction Stop
        $ollama = $null -ne $r
    }
    catch { }
    return @{
        installed = $installed
        running   = $httpOk
        httpOk    = $httpOk
        ollama    = $ollama
        port      = $port
        installDir = $installDir
    }
}

function Normalize-SessionUser([string]$Raw) {
    if ([string]::IsNullOrWhiteSpace($Raw)) { return '' }
    $s = ($Raw -replace '^>+', '').Trim()
    if ($s -match '\\') { $s = ($s -split '\\')[-1] }
    return $s.ToLowerInvariant()
}

function Test-AllowedUser([string]$User, [string[]]$Allowed) {
    $u = Normalize-SessionUser $User
    if (-not $u -or $u -eq 'username') { return $true }
    $norm = @($Allowed | ForEach-Object { Normalize-SessionUser $_ })
    return $norm -contains $u
}

function New-Alerts($Sessions, $AuthEvents, $Allowed) {
    $alerts = @()
    foreach ($s in $Sessions) {
        $u = $s.user
        if ($u -and -not (Test-AllowedUser $u $Allowed)) {
            $alerts += "UNEXPECTED_SESSION: $u ($($s.state))"
        }
    }
    foreach ($e in $AuthEvents) {
        if ($e.id -eq 4625) {
            $alerts += "FAILED_LOGON: $($e.user) from $($e.ip)"
        }
        if ($e.id -eq 4624 -and $e.logonType -eq '10' -and -not (Test-AllowedUser $e.user $Allowed)) {
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
    git         = Get-LaneGitHead
    odysseus    = Get-OdysseusProbe
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

# Append tier-tagged snapshot to session hub only on material change (avoid noise / disk fill).
$hubDir = 'C:\lifepunch\session-hub'
$hubLog = Join-Path $hubDir 'voice-session.ndjson'
$hubSigFile = Join-Path $StatusDir 'hub-watchdog-sig.txt'
try {
    $gitSig = if ($payload.git.head) { $payload.git.head } else { 'none' }
    $sig = "w=$($payload.whisper.running);g=$gitSig;a=$($payload.alerts -join '|')"
    $prevSig = ''
    if (Test-Path -LiteralPath $hubSigFile) {
        $prevSig = (Get-Content -LiteralPath $hubSigFile -Raw).Trim()
    }
    if ($sig -ne $prevSig) {
        New-Item -ItemType Directory -Force -Path $hubDir | Out-Null
        $hubLine = @{
            ts      = $payload.ts
            tier    = 'lifepunchnet'
            source  = 'lifepunchnet'
            type    = 'cvl-watchdog'
            text    = "whisper=$($payload.whisper.running) alerts=$($payload.alerts.Count) uptime=$($payload.boot.uptimeSeconds)s"
            whisper = $payload.whisper.running
            git     = $payload.git
            odysseus = $payload.odysseus
            alerts  = @($payload.alerts)
        } | ConvertTo-Json -Compress -Depth 6
        Add-Content -LiteralPath $hubLog -Value $hubLine -Encoding UTF8
        Set-Content -LiteralPath $hubSigFile -Value $sig -Encoding ASCII -NoNewline
    }
}
catch { }

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
