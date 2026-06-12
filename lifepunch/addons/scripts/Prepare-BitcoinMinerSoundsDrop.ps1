<#
.SYNOPSIS
  Build P0 bitcoinminer sound drop in Downloads from Cornerman shortlist CC0 picks.

  Sources (verify licenses in SOURCES.md beside the WAVs):
    hub-*     BigSoundBank #0125 Computer ventilation (CC0)
    server-hum richwise RoomTone06 Freesound #474830 (CC0 preview trim)
    keyboard  grcekh Freesound #546046 (CC0 preview trim) — swap for RECORD when ready
    glitch    Erokia Freesound #663473 (CC0 preview trim)
    error     Kenney interface-sounds error_003.ogg (CC0) — itch ObsydianX preferred when manually fetched

.EXAMPLE
  powershell -File Prepare-BitcoinMinerSoundsDrop.ps1
#>
[CmdletBinding()]
param(
    [string] $DestRoot = "$env:USERPROFILE\Downloads\bitcoinminer-sounds"
)

$ErrorActionPreference = 'Stop'
$Work = Join-Path $env:TEMP 'bitcoinminer-sounds-build'
$Ff = 'ffmpeg.exe'
if (-not (Get-Command $Ff -ErrorAction SilentlyContinue)) {
    $wingetFf = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Recurse -Filter ffmpeg.exe -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($wingetFf) { $Ff = $wingetFf.FullName }
    else { throw 'ffmpeg not found on PATH' }
}

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { New-Item -ItemType Directory -Force -Path $Path | Out-Null }
}

function Invoke-Download([string]$Url, [string]$OutPath) {
    curl.exe -sL $Url -o $OutPath
    if (-not (Test-Path -LiteralPath $OutPath) -or (Get-Item -LiteralPath $OutPath).Length -lt 1024) {
        throw "Download failed or too small: $Url"
    }
}

function Invoke-Ff([string[]]$FfArgs) {
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & $Ff @FfArgs *> $null
    $code = $LASTEXITCODE
    $ErrorActionPreference = $prev
    if ($code -ne 0) { throw "ffmpeg failed ($code): $($FfArgs -join ' ')" }
}

Ensure-Dir $Work
Ensure-Dir $DestRoot

Write-Host 'Downloading CC0 sources...' -ForegroundColor Cyan

$bsbOgg = Join-Path $Work 'bsb-0125.ogg'
if (-not (Test-Path $bsbOgg)) {
    Invoke-Download 'https://bigsoundbank.com/UPLOAD/ogg/0125.ogg' $bsbOgg
}

$kenneyZip = Join-Path $Work 'kenney_interface-sounds.zip'
$kenneyDir = Join-Path $Work 'kenney'
if (-not (Test-Path (Join-Path $kenneyDir 'Audio\error_003.ogg'))) {
    Invoke-Download 'https://kenney.nl/media/pages/assets/interface-sounds/fa43c1dd4d-1677589452/kenney_interface-sounds.zip' $kenneyZip
    Expand-Archive -Path $kenneyZip -DestinationPath $kenneyDir -Force
}

$kbMp3 = Join-Path $Work 'grcekh-546046.mp3'
if (-not (Test-Path $kbMp3)) {
    Invoke-Download 'https://cdn.freesound.org/previews/546/546046_12206738-lq.mp3' $kbMp3
}

$humMp3 = Join-Path $Work 'roomtone06-474830.mp3'
if (-not (Test-Path $humMp3)) {
    Invoke-Download 'https://cdn.freesound.org/previews/474/474830_1481531-lq.mp3' $humMp3
}

$glitchMp3 = Join-Path $Work 'erokia-663473.mp3'
if (-not (Test-Path $glitchMp3)) {
    Invoke-Download 'https://cdn.freesound.org/previews/663/663473_9497060-lq.mp3' $glitchMp3
}

Write-Host 'Rendering slot WAVs...' -ForegroundColor Cyan

$fanWav = Join-Path $Work 'fan-src.wav'
Invoke-Ff @('-y', '-i', $bsbOgg, '-ac', '1', '-ar', '44100', '-sample_fmt', 's16', $fanWav)

Invoke-Ff @('-y', '-i', $fanWav, '-t', '1.2', '-af', 'afade=t=in:st=0:d=0.05,afade=t=out:st=0.9:d=0.3,volume=2.5', (Join-Path $DestRoot 'hub-startup.wav'))
Invoke-Ff @('-y', '-i', $fanWav, '-t', '10', '-af', 'volume=1.2', (Join-Path $DestRoot 'hub-fan-loop.wav'))
Invoke-Ff @('-y', '-i', $fanWav, '-ss', '7', '-t', '2.5', '-af', 'afade=t=out:st=1.5:d=1,volume=1.5', (Join-Path $DestRoot 'hub-fan-down.wav'))

Invoke-Ff @('-y', '-i', $humMp3, '-ss', '5', '-t', '12', '-ac', '1', '-ar', '44100', '-af', 'lowpass=f=3500,volume=1.8', (Join-Path $DestRoot 'server-hum.wav'))

Invoke-Ff @('-y', '-i', $kbMp3, '-ss', '12', '-t', '0.09', '-ac', '1', '-ar', '44100', '-af', 'highpass=f=200,volume=4', (Join-Path $DestRoot 'keyboard.wav'))

Invoke-Ff @('-y', '-i', $glitchMp3, '-t', '0.45', '-ac', '1', '-ar', '44100', '-af', 'volume=2', (Join-Path $DestRoot 'glitch.wav'))

$errorSrc = Join-Path $kenneyDir 'Audio\error_003.ogg'
Invoke-Ff @('-y', '-i', $errorSrc, '-ac', '1', '-ar', '44100', '-af', 'volume=1.5', (Join-Path $DestRoot 'error.wav'))

$manifest = @'
# bitcoinminer-sounds — CC0 intake manifest (2026-06-12)

| Slot | File | Source | License |
|------|------|--------|---------|
| hub-startup | hub-startup.wav | BigSoundBank #0125 trim 0–1.2s | CC0 |
| hub-fan-loop | hub-fan-loop.wav | BigSoundBank #0125 full loop | CC0 |
| hub-fan-down | hub-fan-down.wav | BigSoundBank #0125 tail fade | CC0 |
| server-hum | server-hum.wav | Freesound richwise RoomTone06 #474830 preview 12s | CC0 |
| keyboard | keyboard.wav | Freesound grcekh #546046 preview click trim | CC0 — **replace with RECORD Cherry MX when ready** |
| glitch | glitch.wav | Freesound Erokia #663473 preview 0.45s | CC0 |
| error | error.wav | Kenney interface-sounds error_003.ogg | CC0 — **ObsydianX itch Error Tones preferred when manually downloaded** |

Freesound previews are LQ (128kbps MP3 source). Re-run after owner drops full-quality WAVs.

Next: `Intake-BitcoinMinerSounds.ps1`
'@

Set-Content -LiteralPath (Join-Path $DestRoot 'SOURCES.md') -Value $manifest -Encoding UTF8

Write-Host "Drop ready: $DestRoot" -ForegroundColor Green
Get-ChildItem -LiteralPath $DestRoot -Filter '*.wav' | ForEach-Object { Write-Host "  $($_.Name) ($([math]::Round($_.Length/1KB,1)) KB)" }
