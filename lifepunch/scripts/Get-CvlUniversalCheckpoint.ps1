<#
.SYNOPSIS
  One command on VENGEANCE: auto-probe CVL (Cornerman SSH + lifepunchnet HTTP) and print universal go/no-go.

.DESCRIPTION
  Replaces manual copy-paste between three Cursor chats for "are we on the same page?"
  VENGEANCE slot = local git. Cornerman slot = SSH probe. lifepunchnet slot = :9101/:9102 API.
  Cursor on VENGEANCE synthesizes Odysseus/opinion layers from this output — facts are automatic.

.EXAMPLE
  cd lifepunch\scripts
  powershell -ExecutionPolicy Bypass -File .\Get-CvlUniversalCheckpoint.ps1
#>
[CmdletBinding()]
param(
    [string] $CornermanSsh = $(if ($env:CORNERMAN_SSH) { $env:CORNERMAN_SSH } else { 'cornerman' }),
    [string] $ConfigPath = '',
    [string] $RepoRoot = '',
    [switch] $JsonOnly
)

$ErrorActionPreference = 'Continue'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $ConfigPath) { $ConfigPath = Join-Path $Here 'server-host-watch.local.json' }
if (-not $RepoRoot) { $RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path }
. (Join-Path $Here 'Voice-Console.ps1')
. (Join-Path $Here 'Cvl-Rgb.ps1')
$script:VoiceConsoleAccent = 'Cyan'

$script:Slots = [ordered]@{}
$script:Blockers = [System.Collections.Generic.List[string]]::new()
$script:Ready = $true

function Add-Blocker([string]$Msg) {
    $script:Blockers.Add($Msg)
    $script:Ready = $false
}

function Get-VengeanceSlot {
    Push-Location $RepoRoot
    try {
        $head = (git log -1 --format='%h %s' 2>$null)
        $branch = (git branch --show-current 2>$null)
        $status = git status -sb 2>$null | Out-String
        $ahead = 0
        $behind = 0
        git fetch origin 2>$null | Out-Null
        $counts = git rev-list --left-right --count "origin/$branch...HEAD" 2>$null
        if ($counts -match '^(\d+)\s+(\d+)$') {
            $behind = [int]$Matches[1]
            $ahead = [int]$Matches[2]
        }
        $dirty = $status -match '^\s*M |^\s*\?\?|^\s*A '
        return [pscustomobject]@{
            node      = 'vengeance'
            gitHead   = $head.Trim()
            branch    = $branch
            ahead     = $ahead
            behind    = $behind
            dirty     = $dirty
            statusSb  = ($status.Trim() -split "`n" | Select-Object -First 6) -join '; '
        }
    }
    finally { Pop-Location }
}

function Get-CornermanSlot {
    $probeFile = Join-Path $Here 'Get-CvlCornermanProbe.ps1'
    if (-not (Test-Path -LiteralPath $probeFile)) {
        Add-Blocker 'Missing Get-CvlCornermanProbe.ps1'
        return $null
    }
    $enc = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes((Get-Content -LiteralPath $probeFile -Raw)))
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    $raw = & ssh -o BatchMode=yes -o ConnectTimeout=12 $CornermanSsh `
        "powershell -NoProfile -NonInteractive -EncodedCommand $enc" 2>$null
    $code = $LASTEXITCODE
    $ErrorActionPreference = $prev
    if ($code -ne 0 -or [string]::IsNullOrWhiteSpace($raw)) {
        Add-Blocker "Cornerman SSH probe failed ($CornermanSsh)"
        return $null
    }
    $line = ($raw -split "`r?`n" | Where-Object { $_.Trim().StartsWith('{') } | Select-Object -Last 1)
    if (-not $line) {
        Add-Blocker 'Cornerman probe returned no JSON'
        return $null
    }
    try { return $line | ConvertFrom-Json }
    catch {
        Add-Blocker 'Cornerman probe JSON parse failed'
        return $null
    }
}

function Get-LifepunchnetSlot($cfg) {
    $hostAddr = [string]$cfg.host
    $token = [string]$cfg.token
    $h = @{ Authorization = "Bearer $token" }
    $port9101 = if ($cfg.statusPort) { [int]$cfg.statusPort } else { 9101 }
    $port9102 = if ($cfg.sessionPort) { [int]$cfg.sessionPort } else { 9102 }

    $slot = [ordered]@{
        node           = 'lifepunchnet'
        host           = $hostAddr
        whisperOk      = $false
        watchdogOk     = $false
        sessionHubOk   = $false
        hubLines       = 0
        gitHead        = 'unknown'
        odysseusHint   = 'unknown'
        alerts         = @()
    }

    try {
        $status = Invoke-RestMethod -Uri "http://${hostAddr}:${port9101}/status" -Headers $h -TimeoutSec 15
        $slot.watchdogOk = $true
        $slot.whisperOk = [bool]$status.whisper.running
        if ($status.alerts) {
            $slot.alerts = @($status.alerts | Where-Object {
                $_ -notmatch '^UNEXPECTED_SESSION:\s*>?administrator\b'
            })
        }
        if ($status.PSObject.Properties.Name -contains 'git') {
            if ($status.git.head) {
                $sub = if ($status.git.subject) { " $($status.git.subject)" } else { '' }
                $slot.gitHead = "$($status.git.head) $($status.git.branch)$sub".Trim()
            }
            elseif ($status.git.detail) { $slot.gitHead = $status.git.detail }
            else { $slot.gitHead = 'no-git-in-status' }
        }
        if ($status.PSObject.Properties.Name -contains 'odysseus') {
            $o = $status.odysseus
            if ($o.running -or $o.httpOk) { $slot.odysseusHint = 'running' }
            elseif ($o.installed) { $slot.odysseusHint = 'installed-not-running' }
            else { $slot.odysseusHint = 'not-installed' }
        }
        if (-not $slot.whisperOk) { Add-Blocker 'lifepunchnet Whisper :9000 down' }
    }
    catch {
        Add-Blocker "lifepunchnet :9101 unreachable ($($_.Exception.Message))"
    }

    try {
        $hub = Invoke-RestMethod -Uri "http://${hostAddr}:${port9102}/status" -Headers $h -TimeoutSec 15
        $slot.sessionHubOk = $true
        $slot.hubLines = [int]$hub.lines
    }
    catch {
        Add-Blocker "lifepunchnet :9102 unreachable ($($_.Exception.Message))"
    }

    return [pscustomobject]$slot
}

function Get-OdysseusUniversalVerdict($v, $c, $l) {
    $lines = @(
        'Odysseus lives on lifepunchnet only - Cornerman feeds hub via PTT + session-sync.'
        'VENGEANCE integrates GitHub; reads hub/Odysseus output for long-context prep, not hosting.'
        'Tier-3 experimental: pinned commit, AUTH on, no secrets, no write-git creds.'
    )
    if ($l -and $l.odysseusHint -eq 'running') {
        $lines += 'Odysseus running on lifepunchnet :7000 - hub reader path live.'
    }
    elseif ($l -and $l.odysseusHint -eq 'installed-not-running') {
        $lines += 'Odysseus installed on lifepunchnet but not responding on :7000 - start launch-windows.ps1.'
    }
    elseif ($l) {
        $lines += 'Odysseus not on lifepunchnet yet - run Install-Odysseus-Lifepunchnet.ps1 (CVL missing link).'
    }
    if ($c -and -not $c.relayRunning) {
        if ($c.relayCmd -and $c.relayStarter) {
            $lines += 'Yellow idle (OK) - open Talk to Vengeance or Start Day when voice is needed.'
        }
        else {
            $lines += 'Yellow broken - missing Talk to Vengeance.cmd or Start-CornermanVoiceRelay.ps1 on Cornerman.'
        }
    }
    return $lines
}

function Get-Recommendation($v, $ready) {
    if (-not $ready) { return 'FIX FIRST - resolve BLOCKERS before commit/push or move-on.' }
    if ($v.dirty -or $v.ahead -gt 0) {
        return "COMMIT/PUSH CANDIDATE - VENGEANCE $($v.ahead) commit(s) ahead of origin; confirm scope with Mr. Rager."
    }
    if ($v.behind -gt 0) {
        return "PULL FIRST - VENGEANCE behind origin by $($v.behind) commit(s)."
    }
    return 'MOVE ON - CVL factual checks green; no pending local commits.'
}

# --- collect ---
$cfg = $null
if (-not (Test-Path -LiteralPath $ConfigPath)) {
    Add-Blocker 'Missing server-host-watch.local.json'
}
else {
    $cfg = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
}

$v = Get-VengeanceSlot
$c = Get-CornermanSlot
$l = if ($cfg) { Get-LifepunchnetSlot $cfg } else { $null }

if ($c) {
    if (-not $c.relayCmd) { Add-Blocker 'Cornerman missing Talk to Vengeance.cmd' }
    if (-not $c.relayStarter) { Add-Blocker 'Cornerman missing Start-CornermanVoiceRelay.ps1' }
}

$rgb = Get-CvlRgbDiagnostics -Vengeance $v -Cornerman $c -Lifepunchnet $l -CvlReady $script:Ready

$result = [ordered]@{
    ts           = (Get-Date).ToUniversalTime().ToString('o')
    cvlReady     = $script:Ready
    blockers     = @($script:Blockers)
    vengeance    = $v
    cornerman    = $c
    lifepunchnet = $l
    rgb          = $rgb
    odysseus     = @(Get-OdysseusUniversalVerdict $v $c $l)
    recommend    = Get-Recommendation $v $script:Ready
}

if ($JsonOnly) {
    $result | ConvertTo-Json -Depth 6
    exit $(if ($script:Ready) { 0 } else { 1 })
}

Write-VoiceHeader -Title 'CVL UNIVERSAL CHECKPOINT' -Subtitle 'auto 1/3 + 2/3 + 3/3 - no RDP paste required'
Write-Host ''

Write-Host '  [1/3] VENGEANCE' -ForegroundColor Cyan
Write-Host "        git: $($v.gitHead)" -ForegroundColor Gray
Write-Host "        branch: $($v.branch)  ahead: $($v.ahead)  behind: $($v.behind)  dirty: $($v.dirty)" -ForegroundColor Gray
Write-Host ''

Write-Host '  [2/3] CORNERMAN (SSH auto)' -ForegroundColor Cyan
if ($c) {
    Write-Host "        git: $($c.gitHead)" -ForegroundColor Gray
    Write-Host "        relay: cmd=$($c.relayCmd) starter=$($c.relayStarter) running=$($c.relayRunning)" -ForegroundColor Gray
    if ($c.sttPathLast) { Write-Host "        stt: $($c.sttPathLast)" -ForegroundColor DarkGray }
}
else { Write-Host '        probe failed' -ForegroundColor Red }
Write-Host ''

Write-Host '  [3/3] LIFEPUNCHNET (HTTP auto)' -ForegroundColor Cyan
if ($l) {
    Write-Host "        :9000 whisper=$($l.whisperOk)  :9101=$($l.watchdogOk)  :9102=$($l.sessionHubOk) hubLines=$($l.hubLines)" -ForegroundColor Gray
    Write-Host "        git (API): $($l.gitHead)  odysseus: $($l.odysseusHint)" -ForegroundColor Gray
    if ($l.alerts.Count -gt 0) {
        Write-Host "        alerts: $($l.alerts -join '; ')" -ForegroundColor Yellow
    }
}
else { Write-Host '        probe skipped or failed' -ForegroundColor Red }
Write-Host ''

Write-VoiceDivider
Write-Host '  ODYSSEUS (universal - synthesized on VENGEANCE)' -ForegroundColor DarkMagenta
foreach ($line in $result.odysseus) { Write-Host "    $line" -ForegroundColor Gray }
Write-Host ''

if ($script:Blockers.Count -gt 0) {
    Write-Host '  BLOCKERS' -ForegroundColor Red
    foreach ($b in $script:Blockers) { Write-Host "    - $b" -ForegroundColor Red }
    Write-Host ''
}

Write-CvlRgbReport -Rgb $rgb
Write-Host ''

$readyColor = if ($script:Ready) { 'Green' } else { 'Yellow' }
$readyText = if ($script:Ready) { 'YES - Mr. Rager may move on or commit when scope is confirmed' } else { 'NO - fix blockers first' }
Write-Host "  CVL READY: $readyText" -ForegroundColor $readyColor
Write-Host "  $($result.recommend)" -ForegroundColor $(if ($script:Ready) { 'Green' } else { 'Yellow' })
Write-VoiceDivider
Write-Host ''
Write-Host '  Re-run anytime: Get-CvlUniversalCheckpoint.ps1' -ForegroundColor DarkGray
Write-Host '  Json: add -JsonOnly for agents/automation' -ForegroundColor DarkGray
Write-Host ''

exit $(if ($script:Ready) { 0 } else { 1 })
