# VENGEANCE bridge - pull Cornerman voice logs and POST to lifepunchnet session hub.

param(
    [int] $IntervalSeconds = 15,
    [string] $SshTarget = $(if ($env:CORNERMAN_SSH) { $env:CORNERMAN_SSH } else { 'cornerman' }),
    [string] $ConfigPath = $(Join-Path $PSScriptRoot 'server-host-watch.local.json'),
    [string] $StatePath = $(Join-Path $PSScriptRoot '.session-sync-state.json')
)

$ErrorActionPreference = 'Stop'

$SessionLogRemote = 'C:\Projects\cornerman-rag\outbox\session.log'
$TranscriptRemote = 'C:\Projects\cornerman-rag\outbox\to-vengeance.txt'
$SttLogRemote = 'C:\Projects\cornerman-rag\outbox\stt-path.log'
$ConversationRemote = 'C:\Projects\cornerman-rag\outbox\conversation.ndjson'

function Read-Config {
    if (-not (Test-Path -LiteralPath $ConfigPath)) {
        throw "Missing $ConfigPath - copy server-host-watch.local.json.example and add token."
    }
    return Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
}

function Read-State {
    if (-not (Test-Path -LiteralPath $StatePath)) {
        return @{ sessionLines = 0; lastTranscript = '' }
    }
    return Get-Content -LiteralPath $StatePath -Raw | ConvertFrom-Json
}

function Save-State($state) {
    $state | ConvertTo-Json | Set-Content -LiteralPath $StatePath -Encoding UTF8
}

function Get-RemoteText([string]$RemotePath) {
    $psCmd = "if (Test-Path -LiteralPath '$RemotePath') { Get-Content -LiteralPath '$RemotePath' -Raw }"
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $raw = & ssh -o BatchMode=yes -o ConnectTimeout=10 $SshTarget "powershell -NoProfile -Command $psCmd" 2>$null
    $ErrorActionPreference = $prev
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($raw)) { return '' }
    return $raw
}

function Send-Ingest($cfg, [string]$Source, [string]$Type, [string]$Text) {
    if ([string]::IsNullOrWhiteSpace($Text)) { return }
    Send-IngestObject $cfg @{
        ts     = (Get-Date).ToUniversalTime().ToString('o')
        source = $Source
        type   = $Type
        text   = $Text.Trim()
    }
}

function Send-IngestObject($cfg, [hashtable]$Payload) {
    if (-not $Payload -or $Payload.Count -eq 0) { return }
    $hostAddr = [string]$cfg.host
    $port = if ($cfg.sessionPort) { [int]$cfg.sessionPort } else { 9102 }
    $token = [string]$cfg.token
    $uri = "http://${hostAddr}:${port}/ingest"
    $headers = @{ Authorization = "Bearer $token" }
    $body = ($Payload | ConvertTo-Json -Compress -Depth 8)
    Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body -ContentType 'application/json' -TimeoutSec 15 | Out-Null
}

$cfg = Read-Config
$state = Read-State

Write-Host ''
Write-Host 'SESSION SYNC  Cornerman -> lifepunchnet' -ForegroundColor Cyan
Write-Host "  Target   $($cfg.host):$(if ($cfg.sessionPort) { $cfg.sessionPort } else { 9102 })" -ForegroundColor DarkGray
Write-Host "  Poll     every ${IntervalSeconds}s" -ForegroundColor DarkGray
Write-Host '  Stop     Ctrl+C' -ForegroundColor DarkGray
Write-Host ''

while ($true) {
    try {
        $sessionRaw = Get-RemoteText $SessionLogRemote
        if ($sessionRaw) {
            $lines = @($sessionRaw -split "`r?`n" | Where-Object { $_.Trim() -ne '' })
            $start = [int]$state.sessionLines
            if ($start -lt $lines.Count) {
                foreach ($line in $lines[$start..($lines.Count - 1)]) {
                    Send-Ingest $cfg 'cornerman' 'session' $line
                }
                $state.sessionLines = $lines.Count
            }
        }

        $transcript = Get-RemoteText $TranscriptRemote
        if ($transcript -and $transcript.Trim() -ne [string]$state.lastTranscript) {
            Send-Ingest $cfg 'cornerman' 'transcript' $transcript
            $state.lastTranscript = $transcript.Trim()
        }

        $sttRaw = Get-RemoteText $SttLogRemote
        if ($sttRaw) {
            $sttLines = @($sttRaw -split "`r?`n" | Where-Object { $_.Trim() -ne '' })
            if (-not $state.sttLines) { $state | Add-Member -NotePropertyName sttLines -NotePropertyValue 0 -Force }
            $sttStart = [int]$state.sttLines
            if ($sttStart -lt $sttLines.Count) {
                foreach ($line in $sttLines[$sttStart..($sttLines.Count - 1)]) {
                    Send-Ingest $cfg 'cornerman' 'stt-path' $line
                }
                $state.sttLines = $sttLines.Count
            }
        }

        $convRaw = Get-RemoteText $ConversationRemote
        if ($convRaw) {
            $convLines = @($convRaw -split "`r?`n" | Where-Object { $_.Trim() -ne '' })
            if (-not $state.conversationLines) { $state | Add-Member -NotePropertyName conversationLines -NotePropertyValue 0 -Force }
            $convStart = [int]$state.conversationLines
            if ($convStart -lt $convLines.Count) {
                foreach ($line in $convLines[$convStart..($convLines.Count - 1)]) {
                    try {
                        $obj = $line | ConvertFrom-Json
                        $payload = @{
                            source   = 'cornerman'
                            type     = 'conversation'
                            text     = [string]$obj.user_text
                            ts       = [string]$obj.ts
                            channel  = [string]$obj.channel
                            user_text = [string]$obj.user_text
                            ai_text  = if ($obj.ai_text) { [string]$obj.ai_text } else { $null }
                            agent    = [string]$obj.agent
                            intent   = [string]$obj.intent
                            project  = if ($obj.project) { [string]$obj.project } else { $null }
                            stt      = if ($obj.stt) { [string]$obj.stt } else { $null }
                        }
                        Send-IngestObject $cfg $payload
                    }
                    catch {
                        Send-Ingest $cfg 'cornerman' 'conversation' $line
                    }
                }
                $state.conversationLines = $convLines.Count
            }
        }

        Save-State $state
    }
    catch {
        Write-Host ("  [{0}] sync error: {1}" -f (Get-Date -Format 'HH:mm:ss'), $_.Exception.Message) -ForegroundColor Yellow
    }
    Start-Sleep -Seconds $IntervalSeconds
}
