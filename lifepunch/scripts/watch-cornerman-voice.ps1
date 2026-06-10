# Watch Cornerman outbox for new voice relay transcripts; auto-copy to VENGEANCE clipboard.
# Run in a dedicated PowerShell window while brainstorming on VENGEANCE.
# Cornerman: F7 arm -> Ready -> F8 talk -> this watcher picks up clipboard + session log.

param(
    [int] $IntervalSeconds = 2,
    [string] $SshTarget = $(if ($env:CORNERMAN_SSH) { $env:CORNERMAN_SSH } else { 'cornerman' })
)

$ErrorActionPreference = 'Continue'
. (Join-Path $PSScriptRoot 'Voice-Console.ps1')
# VENGEANCE inbox uses cyan (Cornerman relay UI stays red).
$script:VoiceConsoleAccent = 'Cyan'
# SSH helpers swallow remote profile noise so the watcher loop keeps running.
$RemotePath = 'C:\Projects\cornerman-rag\outbox\to-vengeance.txt'
$SessionLogPath = 'C:\Projects\cornerman-rag\outbox\session.log'
$PullScript = Join-Path $PSScriptRoot 'pull-cornerman-voice.ps1'
$ArmKey = if ($env:CORNERMAN_ARM_KEY) { $env:CORNERMAN_ARM_KEY.ToUpper() } else { 'F7' }
$PttKey = if ($env:CORNERMAN_PTT_KEY) { $env:CORNERMAN_PTT_KEY.ToUpper() } else { 'F8' }

if (-not (Test-Path -LiteralPath $PullScript)) {
    throw "Missing $PullScript"
}

function Get-RemoteTranscriptHash {
    $raw = Invoke-CornermanSshRead -RemotePath $RemotePath -SshTarget $SshTarget
    if ([string]::IsNullOrWhiteSpace($raw)) { return $null }
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($raw.TrimEnd())
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try { return [BitConverter]::ToString($sha.ComputeHash($bytes)) }
    finally { $sha.Dispose() }
}

function Get-SessionLogTail {
    param([int] $Lines = 8)
    $raw = Invoke-CornermanSshRead -RemotePath $SessionLogPath -SshTarget $SshTarget
    if ([string]::IsNullOrWhiteSpace($raw)) { return @() }
    $all = $raw -split "`r?`n" | Where-Object { $_.Trim() -ne '' }
    if ($all.Count -le $Lines) { return $all }
    return $all[($all.Count - $Lines)..($all.Count - 1)]
}

Write-VoiceHeader `
    -Title 'VENGEANCE VOICE INBOX  (watching Cornerman)' `
    -Subtitle 'Cornerman runs Talk to Vengeance (PTT) — this window only copies new transcripts'
Write-VoiceMeta -Label 'Cornerman' -Value 'Talk to Vengeance must be open + focused (F7/F8 land there)'
Write-VoiceMeta -Label 'Arm' -Value "tap $ArmKey on Cornerman when you want a round"
Write-VoiceMeta -Label 'Talk' -Value "hold $PttKey after Cornerman says Ready"
Write-VoiceMeta -Label 'Paste' -Value 'Ctrl+V in Cursor when clipboard updates'
Write-VoiceMeta -Label 'Stop' -Value 'Ctrl+C in this window'
Write-Host ''

$lastHash = Get-RemoteTranscriptHash
if ($null -ne $lastHash) {
    Write-VoiceMuted 'Baseline captured (notify only on NEW relays after this point).'
    $tail = Get-SessionLogTail
    if ($tail.Count -gt 0) {
        Write-VoiceSessionLog -Lines $tail -Title 'SESSION LOG (Cornerman baseline)'
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
    Write-VoiceDivider
    Write-VoiceEvent -Name 'PASTE NOW' -Detail 'Ctrl+V in Cursor' -Color Green
    Write-VoiceHeard -Text $full
    $tail = Get-SessionLogTail
    Write-VoiceSessionLog -Lines $tail
    Write-Host ''
    Write-VoiceMeta -Label 'Next' -Value "tap $ArmKey on Cornerman for another round"
    Write-VoiceDivider
    Write-Host ''
    $lastHash = $hash
}

