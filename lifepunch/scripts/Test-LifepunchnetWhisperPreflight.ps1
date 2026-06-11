# Cornerman-side preflight — lifepunchnet Whisper :9000 reachable before PTT (cyan leg).
# Dot-sourced from cornerman-rag\relay.ps1 on Green. No hub token on Green.

function Test-LifepunchnetWhisperPreflight {
    $url = if ($env:CORNERMAN_REMOTE_WHISPER_URL) {
        $env:CORNERMAN_REMOTE_WHISPER_URL.Trim()
    } else {
        'http://205.209.104.22:9000/v1/audio/transcriptions'
    }
    try {
        $uri = [Uri]$url
    }
    catch {
        return $false
    }
    $hostAddr = $uri.Host
    $port = if ($uri.Port -gt 0) { $uri.Port } else {
        if ($uri.Scheme -eq 'https') { 443 } else { 80 }
    }
    $tcp = Test-NetConnection -ComputerName $hostAddr -Port $port -WarningAction SilentlyContinue
    return [bool]$tcp.TcpTestSucceeded
}

function Write-LifepunchnetWhisperPreflightFailure {
    param([string]$WhisperUrl)
    Write-Host ''
    Write-Host 'lifepunchnet Whisper preflight FAILED (G->B cyan leg)' -ForegroundColor Red
    Write-Host "  Target: $WhisperUrl" -ForegroundColor Yellow
    Write-Host '  Fix: Blue :9000 up + firewall scoped to home IP' -ForegroundColor Yellow
    Write-Host '  Red: Test-VoiceCommsReady.ps1 on VENGEANCE' -ForegroundColor DarkGray
    Write-Host '  Emergency only: relay.ps1 -PushToTalk -SkipPreflight' -ForegroundColor DarkGray
    Write-Host ''
}
