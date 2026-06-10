<#
.SYNOPSIS
  Universal CVL command — one action splits into Red/Green/Blue probes and logs to lifepunchnet hub.

.DESCRIPTION
  Rainbow / tri-stack tier. Probes VENGEANCE + Cornerman SSH + lifepunchnet HTTP, posts tier-tagged
  NDJSON to session hub :9102 for Odysseus + security audit trail. Mr. Rager asks once; hub remembers.

.EXAMPLE
  powershell -File Invoke-CvlUniversal.ps1
  powershell -File Invoke-CvlUniversal.ps1 -Action Checkpoint -IngestToHub
#>
[CmdletBinding()]
param(
    [ValidateSet('Checkpoint', 'LogOnly')]
    [string] $Action = 'Checkpoint',
    [switch] $IngestToHub,
    [switch] $SkipSecurityGate,
    [switch] $SkipProbe,
    [string] $Note = ''
)

$ErrorActionPreference = 'Continue'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $Here 'Voice-Console.ps1')
. (Join-Path $Here 'Cvl-Hub.ps1')
$script:VoiceConsoleAccent = 'Cyan'

# Default: always ingest when hub config exists (real data for Odysseus).
if (-not $PSBoundParameters.ContainsKey('IngestToHub')) {
    $cfgPath = Join-Path $Here 'server-host-watch.local.json'
    $IngestToHub = (Test-Path -LiteralPath $cfgPath)
}

$checkpointScript = Join-Path $Here 'Get-CvlUniversalCheckpoint.ps1'
if (-not (Test-Path -LiteralPath $checkpointScript)) { throw "Missing $checkpointScript" }

Write-VoiceHeader `
    -Title 'CVL UNIVERSAL  (Rainbow / tri-stack)' `
    -Subtitle 'Red VENGEANCE + Green Cornerman + Blue lifepunchnet -> hub :9102'
Write-VoiceMeta -Label 'Action' -Value $Action
Write-VoiceMeta -Label 'Hub ingest' -Value $(if ($IngestToHub) { 'ON' } else { 'OFF' })
Write-Host ''

if ($IngestToHub -and -not $SkipSecurityGate) {
    $secScript = Join-Path $Here 'Test-CvlSecurity.ps1'
    if (Test-Path -LiteralPath $secScript) {
        Write-Host 'Security gate (required before hub ingest)...' -ForegroundColor Cyan
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $secScript
        if ($LASTEXITCODE -ne 0) {
            Write-Host ''
            Write-Host 'STOP: security gate failed — hub ingest blocked.' -ForegroundColor Red
            Write-Host '  lifepunchnet: Secure-LifepunchnetCvlPorts.ps1 -RemoteAddress <home IP>' -ForegroundColor Yellow
            exit 1
        }
        Write-Host ''
    }
}

$json = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $checkpointScript -JsonOnly
$probe = $json | ConvertFrom-Json
$exitCode = if ($probe.cvlReady) { 0 } else { 1 }

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $checkpointScript | Out-Host

if ($IngestToHub) {
    try {
        $cfg = Get-CvlHubConfig
        $summary = "CVL READY=$($probe.cvlReady) | $($probe.recommend)"
        if ($Note) { $summary += " | note: $Note" }

        Send-CvlHubObject -Config $cfg -Payload @{
            tier      = 'universal'
            source    = 'cvl'
            type      = 'cvl-checkpoint'
            text      = $summary
            cvlReady  = [bool]$probe.cvlReady
            recommend = [string]$probe.recommend
            blockers  = @($probe.blockers)
        }

        if ($probe.vengeance) {
            $v = $probe.vengeance
            Send-CvlHubIngest -Config $cfg -Tier vengeance -Type 'cvl-git' -Text "head=$($v.gitHead) ahead=$($v.ahead) behind=$($v.behind) dirty=$($v.dirty)" -Extra @{
                gitHead = $v.gitHead; ahead = $v.ahead; behind = $v.behind; dirty = $v.dirty
            }
        }

        if ($probe.cornerman) {
            $c = $probe.cornerman
            Send-CvlHubIngest -Config $cfg -Tier cornerman -Type 'cvl-relay' -Text "relay=$($c.relayRunning) cmd=$($c.relayCmd) git=$($c.gitHead)" -Extra @{
                relayRunning = $c.relayRunning; gitHead = $c.gitHead
            }
        }

        if ($probe.lifepunchnet) {
            $l = $probe.lifepunchnet
            Send-CvlHubIngest -Config $cfg -Tier lifepunchnet -Type 'cvl-services' -Text "whisper=$($l.whisperOk) hub=$($l.sessionHubOk) lines=$($l.hubLines)" -Extra @{
                whisperOk = $l.whisperOk; sessionHubOk = $l.sessionHubOk; hubLines = $l.hubLines
            }
        }

        if ($Note) {
            Send-CvlHubIngest -Config $cfg -Tier universal -Type 'cvl-note' -Text $Note -Source 'mr-rager'
        }

        Write-Host ''
        Write-Host '  Hub ingest OK - tier-tagged lines on lifepunchnet :9102' -ForegroundColor Green
        Write-Host '  Odysseus reads: voice-session.ndjson or GET /tail?lines=50' -ForegroundColor DarkGray
    }
    catch {
        Write-Host ''
        Write-Host "  Hub ingest FAILED: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Host ''
exit $exitCode
