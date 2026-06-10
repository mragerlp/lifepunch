# Preflight before Cornerman voice work — run on VENGEANCE.

param(
    [string] $SshTarget = $(if ($env:CORNERMAN_SSH) { $env:CORNERMAN_SSH } else { 'cornerman' }),
    [string] $ConfigPath = $(Join-Path $PSScriptRoot 'server-host-watch.local.json')
)

$ErrorActionPreference = 'Continue'
. (Join-Path $PSScriptRoot 'Voice-Console.ps1')
$ok = $true

function Report([string]$Label, [bool]$Pass, [string]$Detail = '') {
    $color = if ($Pass) { 'Green' } else { 'Red' }
    $mark = if ($Pass) { 'OK' } else { 'FAIL' }
    Write-Host ("  [{0}] {1}" -f $mark, $Label) -ForegroundColor $color
    if ($Detail) { Write-Host "        $Detail" -ForegroundColor DarkGray }
    if (-not $Pass) { $script:ok = $false }
}

Write-VoiceHeader -Title 'VOICE COMMS PREFLIGHT  (VENGEANCE)' -Subtitle 'Run before LifePunch Voice Comms'

if (-not (Test-Path -LiteralPath $ConfigPath)) {
    Report 'server-host-watch.local.json' $false 'Copy .example and add lifepunchnet token'
}
else {
    $cfg = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
    Report 'server-host-watch.local.json' $true $cfg.host
}

$ssh = ssh -o BatchMode=yes -o ConnectTimeout=8 $SshTarget "echo ok" 2>$null
Report 'Cornerman SSH' ($LASTEXITCODE -eq 0 -and $ssh -eq 'ok') $SshTarget

if ($cfg) {
    $h = @{ Authorization = "Bearer $($cfg.token)" }
    try {
        $status = Invoke-RestMethod -Uri "http://$($cfg.host):9101/status" -Headers $h -TimeoutSec 12
        $w = if ($status.whisper.running) { 'running' } else { 'down' }
        Report 'lifepunchnet Whisper :9000' $status.whisper.running $w
    }
    catch {
        Report 'lifepunchnet Whisper :9000' $false $_.Exception.Message
    }
    try {
        $hub = Invoke-RestMethod -Uri "http://$($cfg.host):9102/status" -Headers $h -TimeoutSec 12
        Report 'lifepunchnet session hub :9102' $true "$($hub.lines) lines in hub"
    }
    catch {
        Report 'lifepunchnet session hub :9102' $false $_.Exception.Message
    }
}

Write-Host ''
if ($ok) {
    Write-Host 'Ready for voice work. Start: LifePunch Voice Comms shortcut or start-voice-comms.ps1' -ForegroundColor Green
}
else {
    Write-Host 'Fix FAIL items before Cornerman voice session.' -ForegroundColor Yellow
}
Write-Host ''
exit $(if ($ok) { 0 } else { 1 })
