<#
.SYNOPSIS
  Export owner Steam Machine hub (bitcoinminer.blend) to steam-machine.fbx for ModelDoc.

.PARAMETER SourceRoot
  Default: Downloads\bitcoinminer

.EXAMPLE
  powershell -File Export-BitcoinMinerSteamMachineFbx.ps1
#>
[CmdletBinding()]
param(
    [string] $SourceRoot = "$env:USERPROFILE\Downloads\bitcoinminer",
    [string] $BlenderExe = "${env:ProgramFiles}\Blender Foundation\Blender 5.1\blender.exe",
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$AddonsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$ModelSource = Join-Path $AddonsRoot 'Assets\addons\lifepunch\bitcoinmining\models\lifepunch\bitcoinmining\bitcoin-miner\source'
$Blend = Join-Path $SourceRoot 'source\bitcoinminer.blend'
$OutFbx = Join-Path $ModelSource 'steam-machine.fbx'
$Py = Join-Path $PSScriptRoot 'Export-BitcoinMinerSteamMachineFbx.py'

if (-not (Test-Path -LiteralPath $Blend)) {
    throw "Missing blend: $Blend"
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

if (-not (Test-Path -LiteralPath $ModelSource)) {
    New-Item -ItemType Directory -Force -Path $ModelSource | Out-Null
}

Write-Host 'Export Steam Machine FBX' -ForegroundColor Cyan
Write-Host "  Blend: $Blend"
Write-Host "  Out:   $OutFbx"

& $BlenderExe --background $Blend --python $Py -- $Blend $OutFbx
if ($LASTEXITCODE -ne 0) { throw "Blender export failed ($LASTEXITCODE)" }
if (-not (Test-Path -LiteralPath $OutFbx)) { throw "FBX not written: $OutFbx" }

Write-Host 'Export OK' -ForegroundColor Green
