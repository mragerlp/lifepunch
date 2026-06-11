<#
.SYNOPSIS
  Intake owner Bitcoin Miner SFX into sounds/bitcoinminer/.

  Expected names (any of .wav / .mp3 / .ogg) — **owner-recorded or licensed originals only**:
    hub-startup, hub-fan-loop, hub-fan-down, metal-hit, smoke, explode
    server-hum, keyboard, glitch, error

  Do NOT copy audio from any third-party bitminer addon pack.

.PARAMETER SourceRoot
  Default: Downloads\bitcoinminer-sounds

.EXAMPLE
  powershell -File Intake-BitcoinMinerSounds.ps1
#>
[CmdletBinding()]
param(
    [string] $SourceRoot = "$env:USERPROFILE\Downloads\bitcoinminer-sounds",
    [string] $ArchiveRoot = 'C:\lifepunch\reference-intake\bitcoinmining\sounds',
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$AddonsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$DestRoot = Join-Path $AddonsRoot 'Assets\addons\lifepunch\bitcoinmining\sounds\bitcoinminer'

$Expected = @(
    'hub-startup',
    'hub-fan-loop',
    'hub-fan-down',
    'metal-hit',
    'smoke',
    'explode',
    'server-hum',
    'keyboard',
    'glitch',
    'error'
)

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        if ($WhatIf) { Write-Host "[WhatIf] mkdir $Path" }
        else { New-Item -ItemType Directory -Force -Path $Path | Out-Null }
    }
}

if (-not (Test-Path -LiteralPath $SourceRoot)) {
    throw "Missing $SourceRoot — drop owner sound pack first."
}

$audio = Get-ChildItem -LiteralPath $SourceRoot -Recurse -Include *.wav, *.mp3, *.ogg -ErrorAction SilentlyContinue
if (-not $audio) {
    throw "No audio files under $SourceRoot"
}

Write-Host 'Bitcoin Miner sounds intake' -ForegroundColor Cyan

if (-not $WhatIf) {
    Ensure-Dir $ArchiveRoot
    Copy-Item -LiteralPath (Join-Path $SourceRoot '*') -Destination $ArchiveRoot -Recurse -Force
}

Ensure-Dir $DestRoot

$copied = 0
foreach ( $file in $audio ) {
    $base = $file.BaseName.ToLowerInvariant() -replace '[_\s]+', '-'
    $destName = "$base$($file.Extension.ToLowerInvariant())"
    $destPath = Join-Path $DestRoot $destName

    if ($WhatIf) {
        Write-Host "[WhatIf] $($file.FullName) -> $destPath"
    }
    else {
        Copy-Item -LiteralPath $file.FullName -Destination $destPath -Force
        $copied++
        Write-Host "  OK $destName" -ForegroundColor Green
    }
}

$missing = @()
foreach ( $name in $Expected ) {
    $hit = Get-ChildItem -LiteralPath $DestRoot -Filter "$name.*" -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $hit) { $missing += $name }
}

Write-Host "Copied $copied file(s) -> $DestRoot" -ForegroundColor Green
if ($missing.Count -gt 0) {
    Write-Host "Still missing (optional until wired): $($missing -join ', ')" -ForegroundColor Yellow
}

Write-Host 'Next: compile .vsnd in s&box editor; wire .sound resources + BitminerHubEntity SFX hooks.' -ForegroundColor DarkGray
