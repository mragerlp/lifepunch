# Talk to VENGEANCE - voice relay (AT2020 on Cornerman -> VENGEANCE Cursor).
param(
    [switch] $SelfTest,
    [switch] $NoGuided,
    [switch] $Loop,
    [switch] $PushToTalk,
    [switch] $SkipPreflight
)

$ErrorActionPreference = 'Stop'

$WhisperUrl = if ($env:CORNERMAN_REMOTE_WHISPER_URL) {
    $env:CORNERMAN_REMOTE_WHISPER_URL.Trim()
} else {
    'http://205.209.104.22:9000/v1/audio/transcriptions'
}
$env:CORNERMAN_REMOTE_WHISPER_URL   = $WhisperUrl
$env:CORNERMAN_REMOTE_WHISPER_MODEL = if ($env:CORNERMAN_REMOTE_WHISPER_MODEL) { $env:CORNERMAN_REMOTE_WHISPER_MODEL } else { 'small.en' }
$env:CORNERMAN_PREFER_RDP_MIC = '0'

if ($PushToTalk -and -not $SkipPreflight -and -not $SelfTest) {
    $preflight = 'C:\Projects\lifepunch\lifepunch\scripts\Test-LifepunchnetWhisperPreflight.ps1'
    if (-not (Test-Path -LiteralPath $preflight)) {
        throw "Missing lifepunchnet preflight script: $preflight"
    }
    . $preflight
    if (-not (Test-LifepunchnetWhisperPreflight)) {
        Write-LifepunchnetWhisperPreflightFailure -WhisperUrl $WhisperUrl
        exit 2
    }
}

$py = Join-Path $PSScriptRoot '.venv\Scripts\python.exe'
if (-not (Test-Path $py)) {
    throw "Python venv not found at $py"
}

Set-Location $PSScriptRoot

$pyArgs = @('relay.py')
if ($env:CORNERMAN_REMOTE_WHISPER_URL) {
    $pyArgs += '--remote-whisper', $env:CORNERMAN_REMOTE_WHISPER_URL
}
if ($SelfTest)   { $pyArgs += '--selftest' }
if ($NoGuided)   { $pyArgs += '--no-guided' }
if ($PushToTalk) { $pyArgs += '--ptt' }
if ($Loop)       { $pyArgs += '--loop' }

& $py @pyArgs
$code = $LASTEXITCODE

if (-not $Loop -and -not $PushToTalk) {
    $out = Join-Path $PSScriptRoot 'outbox\to-vengeance.txt'
    if ($code -eq 0 -and (Test-Path $out)) {
        $text = (Get-Content $out -Raw -Encoding UTF8).Trim()
        if ($text.Length -gt 0) {
            Set-Clipboard -Value $text
            Write-Host ''
            Write-Host '--- Clipboard ---' -ForegroundColor Green
            Write-Host 'Copied to VENGEANCE clipboard.' -ForegroundColor Green
            Write-Host 'On VENGEANCE: Ctrl+V into Cursor (edit if needed).' -ForegroundColor DarkGray
            if (-not $NoGuided -and -not $SelfTest) {
                & $py -c "import tts; tts.speak('Copied to clipboard. Paste into Cursor on Vengeance.')"
            }
        }
    }
}

exit $code
