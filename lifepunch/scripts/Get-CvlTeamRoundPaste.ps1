<#
.SYNOPSIS
  Red's arm - one paste for Green + Blue from live checkpoint gaps.

.DESCRIPTION
  Runs Get-CvlUniversalCheckpoint -JsonOnly, builds ONE message both lanes receive.
  No dual replies - Mr. Rager says "both lanes done" then Invoke-CvlUniversal -IngestToHub.

.EXAMPLE
  powershell -File Get-CvlTeamRoundPaste.ps1
  powershell -File Get-CvlTeamRoundPaste.ps1 -PingNote cvl-tune-20260610
#>
[CmdletBinding()]
param(
    [string] $PingNote = '',
    [switch] $CopyToClipboard
)

$ErrorActionPreference = 'Continue'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$checkpoint = Join-Path $Here 'Get-CvlUniversalCheckpoint.ps1'
if (-not (Test-Path -LiteralPath $checkpoint)) { throw "Missing $checkpoint" }

$raw = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $checkpoint -JsonOnly
$probe = $raw | ConvertFrom-Json

if (-not $PingNote) {
    $PingNote = 'cvl-round-' + (Get-Date -Format 'yyyyMMdd-HHmm')
}

$greenTasks = [System.Collections.Generic.List[string]]::new()
$blueTasks = [System.Collections.Generic.List[string]]::new()
$optional = [System.Collections.Generic.List[string]]::new()

# --- Green lane work from gaps ---
if ($probe.cornerman) {
    $c = $probe.cornerman
    if ($c.gitHead -notmatch '^\w{7}\s') {
        $greenTasks.Add('cd C:\Projects\lifepunch && git pull --rebase (align monorepo with Red)')
    }
    if (-not $c.relayCmd -or -not $c.relayStarter) {
        $greenTasks.Add('RESTORE voice stack: Talk to Vengeance.cmd + Start-CornermanVoiceRelay.ps1 under cornerman-rag')
    }
    else {
        $optional.Add('GREEN optional: smoke-test Yellow - run Start-CornermanVoiceRelay.ps1, confirm window opens, close (idle without voice is OK)')
    }
    $greenTasks.Add('Confirm: no hub/status token files on Green; no hub tumble wiring')
}
else {
    $greenTasks.Add('BLOCKED: Cornerman SSH unreachable from VENGEANCE - fix LAN/SSH first')
}

# --- Blue lane work from gaps ---
if ($probe.lifepunchnet) {
    $l = $probe.lifepunchnet
    if ($l.gitHead -eq 'unknown' -or $l.gitHead -match 'no-clone|no-git') {
        $blueTasks.Add('cd C:\lifepunch\lifepunch-rdp-server && git pull --rebase')
        $blueTasks.Add('Run once: .\lifepunch\server\scripts\ServerHost-Watchdog.ps1')
        $blueTasks.Add('Restart task: LifePunch-ServerHost-Watchdog (picks up git + session fixes)')
    }
    if ($l.odysseusHint -eq 'not-installed' -or $l.odysseusHint -eq 'unknown') {
        $optional.Add('BLUE optional (owner yes): Install-Odysseus-Lifepunchnet.ps1 - hub memory reader for single final answers')
    }
    if ($l.alerts -and $l.alerts.Count -gt 0) {
        $blueTasks.Add("Review watchdog alerts: $($l.alerts -join '; ') - after pull, administrator RDP noise should clear")
    }
    $blueTasks.Add('Confirm Secure-LifepunchnetCvlPorts.ps1 still scoped to home IP (71.250.46.224)')
    $blueTasks.Add('Acknowledge HTTP-not-TLS WARN: mitigated by firewall scope + Bearer (TLS = future hardening)')
}
else {
    $blueTasks.Add('BLOCKED: lifepunchnet :9101/:9102 unreachable from VENGEANCE')
}

if ($probe.blockers -and $probe.blockers.Count -gt 0) {
    $blueTasks.Add("Red blockers to clear: $($probe.blockers -join '; ')")
}

$greenBlock = if ($greenTasks.Count -gt 0) {
    ($greenTasks | ForEach-Object { "  - $_" }) -join "`n"
} else {
    '  - (none required - stay SSH-reachable and token-clean)'
}

$blueBlock = if ($blueTasks.Count -gt 0) {
    ($blueTasks | ForEach-Object { "  - $_" }) -join "`n"
} else {
    '  - (none required - services + scope confirmed)'
}

$optBlock = if ($optional.Count -gt 0) {
    "`nOPTIONAL (help Red / Odysseus path):`n" + (($optional | ForEach-Object { "  - $_" }) -join "`n")
} else { '' }

$rgb = $probe.rgb
$rgbLine = if ($rgb) {
    "R=$($rgb.redLit) G=$($rgb.greenLit) B=$($rgb.blueLit) state=$($rgb.state)"
} else { 'rgb=unknown' }

$paste = @"
================================================================
LIFEPUNCH CVL - TEAM ROUND (G + B) | ONE PASTE | RED'S ARM
PING: $PingNote
Red snapshot: $rgbLine | cvlReady=$($probe.cvlReady)
================================================================

YOU BOTH SEE THE FULL ROUND. Do your section only. No routine replies to VENGEANCE.
Exception only: BLOCKED <lane>: <reason>

When BOTH lanes are done, Mr. Rager tells VENGEANCE: "both lanes done"
Red runs ONE ping (the single answer):
  .\lifepunch\scripts\Invoke-CvlUniversal.ps1 -IngestToHub -Note "$PingNote"

--- GREEN (Cornerman) ---
$greenBlock

--- BLUE (lifepunchnet) ---
$blueBlock
$optBlock

COMMUNICATION LAW (unchanged):
  Hub = Blue append-only memory. Green feeds via Red. No tumble.
  Odysseus (when installed on Blue) reads tier-tagged hub - not attacker-facing colors.

Canonical: lifepunch/docs/CVL_RGB_DOCTRINE.md
================================================================
"@

Write-Output $paste

if ($CopyToClipboard) {
    try {
        Set-Clipboard -Value $paste
        Write-Host ''
        Write-Host 'Copied to clipboard.' -ForegroundColor Green
    }
    catch {
        Write-Host ''
        Write-Host 'Could not copy to clipboard.' -ForegroundColor Yellow
    }
}

Write-Host ''
Write-Host "Ping id: $PingNote" -ForegroundColor Cyan
Write-Host 'Send this SAME paste to Cornerman and lifepunchnet. One ping after both done.' -ForegroundColor DarkGray
