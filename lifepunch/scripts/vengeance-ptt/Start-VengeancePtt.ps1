<#
.SYNOPSIS
  VENGEANCE desk PTT — AT2020 USB+ in, Virtuoso out, lifepunchnet Whisper STT.

.DESCRIPTION
  No Cornerman relay. No RDP. F7 arm, F8 hold-to-talk, transcript to clipboard.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File lifepunch\scripts\vengeance-ptt\Start-VengeancePtt.ps1
#>
[CmdletBinding()]
param(
    [switch] $SkipPreflight,
    [switch] $ListDevices,
    [switch] $Install
)

$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoScripts = Split-Path $Here -Parent
$VenvPy = Join-Path $Here '.venv\Scripts\python.exe'

if ($Install) {
    & (Join-Path $Here 'Install-VengeancePtt.ps1')
}

if (-not (Test-Path -LiteralPath $VenvPy)) {
    Write-Host 'venv missing — running Install-VengeancePtt.ps1' -ForegroundColor Yellow
    & (Join-Path $Here 'Install-VengeancePtt.ps1')
}

$env:VENGEANCE_WHISPER_URL = if ($env:VENGEANCE_WHISPER_URL) {
    $env:VENGEANCE_WHISPER_URL.Trim()
} else {
    'http://205.209.104.22:9000/v1/audio/transcriptions'
}
$env:VENGEANCE_WHISPER_MODEL = if ($env:VENGEANCE_WHISPER_MODEL) { $env:VENGEANCE_WHISPER_MODEL } else { 'small.en' }
$env:VENGEANCE_PTT_INPUT_MATCH = if ($env:VENGEANCE_PTT_INPUT_MATCH) { $env:VENGEANCE_PTT_INPUT_MATCH } else { 'AT2020' }
$env:VENGEANCE_PTT_OUTPUT_MATCH = if ($env:VENGEANCE_PTT_OUTPUT_MATCH) { $env:VENGEANCE_PTT_OUTPUT_MATCH } else { 'VIRTUOSO' }

if ($ListDevices) {
    & $VenvPy (Join-Path $Here 'vengeance_ptt.py') --list-devices
    exit $LASTEXITCODE
}

if (-not $SkipPreflight) {
    $preflight = Join-Path $RepoScripts 'Test-LifepunchnetWhisperPreflight.ps1'
    if (Test-Path -LiteralPath $preflight) {
        . $preflight
        $env:CORNERMAN_REMOTE_WHISPER_URL = $env:VENGEANCE_WHISPER_URL
        if (-not (Test-LifepunchnetWhisperPreflight)) {
            Write-LifepunchnetWhisperPreflightFailure -WhisperUrl $env:VENGEANCE_WHISPER_URL
            exit 2
        }
    }
}

Set-Location $Here
& $VenvPy (Join-Path $Here 'vengeance_ptt.py')
exit $LASTEXITCODE
