# Talk to VENGEANCE - voice relay (AT2020 on Cornerman -> VENGEANCE Cursor).
param(
    [switch] $Lemonade,
    [switch] $SelfTest,
    [switch] $NoGuided,
    [switch] $Loop,
    [switch] $PushToTalk
)

$ErrorActionPreference = 'Stop'
$env:CORNERMAN_REMOTE_WHISPER_URL = 'http://205.209.104.22:9000/v1/audio/transcriptions'
$env:CORNERMAN_REMOTE_WHISPER_MODEL = 'small.en'

$env:CORNERMAN_PREFER_RDP_MIC = '0'

$py = Join-Path $PSScriptRoot '.venv\Scripts\python.exe'
if (-not (Test-Path $py)) {
    throw "Python venv not found at $py"
}

Set-Location $PSScriptRoot

$pyArgs = @('relay.py')
if ($env:CORNERMAN_REMOTE_WHISPER_URL) {
    $pyArgs += '--remote-whisper', $env:CORNERMAN_REMOTE_WHISPER_URL
}
if ($Lemonade)   { $pyArgs += '--lemonade' }
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
