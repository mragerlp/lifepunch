<#
.SYNOPSIS
  Export Steam Machine hub blend -> steam-machine.fbx for ModelDoc (hull only — no fan mesh in body FBX).

.PARAMETER SourceRoot
  Folder containing source\*.blend (default: Downloads\steam-machine-controller, then Downloads\bitcoinminer).

.EXAMPLE
  powershell -File Export-BitcoinMinerSteamMachineFbx.ps1
  powershell -File Export-BitcoinMinerSteamMachineFbx.ps1 -SourceRoot "$env:USERPROFILE\Downloads\steam-machine-controller"
#>
[CmdletBinding()]
param(
    [string] $SourceRoot = "",
    [string] $BlenderExe = "${env:ProgramFiles}\Blender Foundation\Blender 5.1\blender.exe",
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$AddonsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$OutFbx = Join-Path $AddonsRoot 'Assets\addons\lifepunch\lpbitcoin\bitcoinhub\assets\source\fbx\steam-machine.fbx'
$Py = Join-Path $PSScriptRoot 'Export-BitcoinMinerSteamMachineFbx.py'

if (-not $SourceRoot) {
    $candidates = @(
        (Join-Path $env:USERPROFILE 'Downloads\steam-machine-controller'),
        (Join-Path $env:USERPROFILE 'Downloads\bitcoinminer')
    )
    $SourceRoot = $candidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
    if (-not $SourceRoot) {
        throw "No SourceRoot found. Pass -SourceRoot or install blend under Downloads\steam-machine-controller"
    }
}

$sourceDir = Join-Path $SourceRoot 'source'
$blendCandidates = @(
    (Join-Path $sourceDir 'steam_machine(b3_6).blend'),
    (Join-Path $sourceDir 'bitcoinminer.blend')
)
$Blend = $blendCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $Blend) {
    throw "Missing blend under $sourceDir (expected steam_machine(b3_6).blend or bitcoinminer.blend)"
}

if (-not (Test-Path -LiteralPath $BlenderExe)) {
    $found = Get-ChildItem "${env:ProgramFiles}\Blender Foundation" -Recurse -Filter blender.exe -ErrorAction SilentlyContinue |
        Select-Object -First 1 -ExpandProperty FullName
    if ($found) { $BlenderExe = $found }
    else { throw "Blender not found. Install BlenderFoundation.Blender or pass -BlenderExe." }
}

if ($WhatIf) {
    Write-Host "[WhatIf] $BlenderExe --background $Blend -> $OutFbx"
    exit 0
}

$outDir = Split-Path -Parent $OutFbx
if (-not (Test-Path -LiteralPath $outDir)) {
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
}

Write-Host 'Export Steam Machine FBX' -ForegroundColor Cyan
Write-Host "  Blend: $Blend"
Write-Host "  Out:   $OutFbx"

& $BlenderExe --background $Blend --python $Py -- $Blend $OutFbx
if ($LASTEXITCODE -ne 0) { throw "Blender export failed ($LASTEXITCODE)" }
if (-not (Test-Path -LiteralPath $OutFbx)) { throw "FBX not written: $OutFbx" }

Write-Host 'Export OK (static hull: base_body, front_panel, back_body — fan is Phase 2 / separate fbx)' -ForegroundColor Green
