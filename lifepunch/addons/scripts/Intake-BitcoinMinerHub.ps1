<#
.SYNOPSIS
  Intake owner Bitcoin Miner hub (Ophion.fbx) into entities/bitcoinminer + models tree.

.PARAMETER SourceRoot
  Default: Downloads\bitcoinminer

.EXAMPLE
  powershell -File Intake-BitcoinMinerHub.ps1
#>
[CmdletBinding()]
param(
    [string] $SourceRoot = "$env:USERPROFILE\Downloads\gaming-pc",
    [string] $ArchiveRoot = 'C:\lifepunch\reference-intake\bitcoinmining\bitcoin-miner-hub',
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$AddonsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$BtcAssets = Join-Path $AddonsRoot 'Assets\addons\lifepunch\bitcoinmining'
$EntityRoot = Join-Path $BtcAssets 'entities\bitcoinminer'
$ModelRoot = Join-Path $BtcAssets 'models\lifepunch\bitcoinmining\bitcoin-miner'

$SourceFbx = Join-Path $SourceRoot 'source\Ophion.fbx'
if (-not (Test-Path -LiteralPath $SourceFbx)) {
    $SourceFbx = Join-Path $EntityRoot 'source\Ophion.fbx'
}

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        if ($WhatIf) { Write-Host "[WhatIf] mkdir $Path" }
        else { New-Item -ItemType Directory -Force -Path $Path | Out-Null }
    }
}

if (-not (Test-Path -LiteralPath $SourceFbx)) {
    throw "Missing Ophion.fbx under $SourceRoot\source\ or entities\bitcoinminer\source\"
}

Write-Host 'Bitcoin Miner hub intake (Ophion)' -ForegroundColor Cyan

$destFbx = Join-Path $ModelRoot 'source\Ophion.fbx'
$destTexEntity = Join-Path $EntityRoot 'textures'
$destTexModel = Join-Path $ModelRoot 'source\textures'
$sourceTex = Join-Path $SourceRoot 'textures'
if (-not (Test-Path -LiteralPath $sourceTex)) {
    $sourceTex = Join-Path $EntityRoot 'textures'
}

if (-not $WhatIf) {
    Ensure-Dir $ArchiveRoot
    Copy-Item -LiteralPath $SourceFbx -Destination (Join-Path $ArchiveRoot 'Ophion.fbx') -Force
    if (Test-Path -LiteralPath $sourceTex) {
        Ensure-Dir (Join-Path $ArchiveRoot 'textures')
        Copy-Item -LiteralPath (Join-Path $sourceTex '*') -Destination (Join-Path $ArchiveRoot 'textures') -Recurse -Force
    }
}

Ensure-Dir (Split-Path -Parent $destFbx)
Ensure-Dir $destTexModel

if ($WhatIf) {
    Write-Host "[WhatIf] FBX -> $destFbx"
}
else {
    Copy-Item -LiteralPath $SourceFbx -Destination $destFbx -Force
    if (Test-Path -LiteralPath $sourceTex) {
        Copy-Item -LiteralPath (Join-Path $sourceTex '*') -Destination $destTexEntity -Recurse -Force -ErrorAction SilentlyContinue
        Copy-Item -LiteralPath (Join-Path $sourceTex '*') -Destination $destTexModel -Recurse -Force
    }
    Write-Host '  Ophion FBX + textures OK' -ForegroundColor Green
}

Write-Host 'Intake OK - ModelDoc bitcoin-miner.vmdl, wire power anims, prefab BitcoinMinerHubEntity.' -ForegroundColor Green
