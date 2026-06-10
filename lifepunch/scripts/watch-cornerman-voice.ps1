# Watch Cornerman outbox for new voice relay transcripts; auto-copy to VENGEANCE clipboard.
# Run in a dedicated PowerShell window while brainstorming on VENGEANCE.
# Cornerman: hold F8 (PTT) -> message -> this watcher picks up clipboard + session log.

param(
    [int] $IntervalSeconds = 2,
    [string] $SshTarget = $(if ($env:CORNERMAN_SSH) { $env:CORNERMAN_SSH } else { 'cornerman' })
)

$ErrorActionPreference = 'Stop'
# SSH helpers use Continue so remote cmd noise does not kill the watcher loop.
$RemotePath = 'C:\Projects\cornerman-rag\outbox\to-vengeance.txt'
$SessionLogPath = 'C:\Projects\cornerman-rag\outbox\session.log'
$PullScript = Join-Path $PSScriptRoot 'pull-cornerman-voice.ps1'
$ArmKey = if ($env:CORNERMAN_ARM_KEY) { $env:CORNERMAN_ARM_KEY.ToUpper() } else { 'F7' }
$PttKey = if ($env:CORNERMAN_PTT_KEY) { $env:CORNERMAN_PTT_KEY.ToUpper() } else { 'F8' }

if (-not (Test-Path -LiteralPath $PullScript)) {
    throw "Missing $PullScript"
}

function Get-RemoteTranscriptHash {
    $raw = & ssh -o BatchMode=yes -o ConnectTimeout=10 $SshTarget "type `"$RemotePath`"" 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($raw)) { return $null }
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($raw.TrimEnd())
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try { return [BitConverter]::ToString($sha.ComputeHash($bytes)) }
    finally { $sha.Dispose() }
}

function Get-SessionLogTail {
    param([int] $Lines = 8)
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $psCmd = "if (Test-Path -LiteralPath '$SessionLogPath') { Get-Content -LiteralPath '$SessionLogPath' -Raw }"
    $raw = & ssh -o BatchMode=yes -o ConnectTimeout=10 $SshTarget "powershell -NoProfile -Command $psCmd" 2>$null
    $ErrorActionPreference = $prev
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($raw)) { return @() }
    $all = $raw -split "`r?`n" | Where-Object { $_.Trim() -ne '' }
    if ($all.Count -le $Lines) { return $all }
    return $all[($all.Count - $Lines)..($all.Count - 1)]
}

Write-Host ''
Write-Host ('=' * 60) -ForegroundColor Cyan
Write-Host '  VENGEANCE VOICE INBOX  (watching Cornerman)' -ForegroundColor Cyan
Write-Host ('=' * 60) -ForegroundColor Cyan
Write-Host '  Cornerman : tap ARM, wait for Ready, hold talk key, release' -ForegroundColor DarkGray
Write-Host ('  Arm key   : {0}   Talk key: {1}' -f $ArmKey, $PttKey) -ForegroundColor DarkGray
Write-Host '  You       : when clipboard updates -> Ctrl+V in Cursor' -ForegroundColor DarkGray
Write-Host '  Stop      : Ctrl+C in this window' -ForegroundColor DarkGray
Write-Host ''

$lastHash = Get-RemoteTranscriptHash
if ($null -ne $lastHash) {
    Write-Host 'Baseline captured (notify only on NEW relays after this point).' -ForegroundColor DarkGray
    $tail = Get-SessionLogTail
    if ($tail.Count -gt 0) {
        Write-Host ''
        Write-Host '  CONVERSATION (from Cornerman session.log)' -ForegroundColor DarkMagenta
        foreach ($line in $tail) { Write-Host "    $line" -ForegroundColor DarkGray }
    }
    Write-Host ''
}

while ($true) {
    Start-Sleep -Seconds $IntervalSeconds
    $hash = Get-RemoteTranscriptHash
    if ($null -eq $hash) { continue }
    if ($null -ne $lastHash -and $hash -eq $lastHash) { continue }

    & $PullScript -Notify -Quiet
    $full = (Get-Clipboard).ToString()
    $preview = $full
    if ($preview.Length -gt 80) { $preview = $preview.Substring(0, 80) + '...' }

    Write-Host ''
    Write-Host ('-' * 60) -ForegroundColor DarkGray
    Write-Host ("  [{0}]  PASTE NOW  (Ctrl+V in Cursor)" -f (Get-Date -Format 'HH:mm:ss')) -ForegroundColor Green
    Write-Host '  CLIPBOARD updated - Cornerman voice prompt is your audio cue' -ForegroundColor Green
    Write-Host ("  I HEARD: $preview") -ForegroundColor White

    $tail = Get-SessionLogTail
    if ($tail.Count -gt 0) {
        Write-Host ''
        Write-Host '  SESSION LOG (agents can read this thread)' -ForegroundColor DarkMagenta
        foreach ($line in $tail) { Write-Host "    $line" -ForegroundColor Gray }
    }

    Write-Host ''
    Write-Host ('  Tap {0} on Cornerman when you want another round' -f $ArmKey) -ForegroundColor DarkCyan
    Write-Host ('-' * 60) -ForegroundColor DarkGray
    Write-Host ''
    $lastHash = $hash
}

