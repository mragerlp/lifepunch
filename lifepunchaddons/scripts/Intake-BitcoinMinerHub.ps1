<#
.SYNOPSIS
  Intake owner Bitcoin Miner hub (Steam Machine) into entities/bitcoinminer + models tree.

.PARAMETER SourceRoot
  Default: Downloads\bitcoinminer

.EXAMPLE
  powershell -File Intake-BitcoinMinerHub.ps1
  powershell -File Intake-BitcoinMinerHub.ps1 -ExportFbx
#>
[CmdletBinding()]
param(
    [string] $SourceRoot = "$env:USERPROFILE\Downloads\bitcoinminer",
    [string] $ArchiveRoot = 'C:\lifepunch\reference-intake\bitcoinmining\bitcoin-miner-hub',
    [switch] $ExportFbx,
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'LifePunch-AddonDropPaths.ps1')
if (-not $SourceRoot -or $SourceRoot -like '*\Downloads\bitcoinminer') {
    $SourceRoot = Get-LifePunchEntityDrop -Key 'bitcoin.bitcoin-miner' -LegacyNames @('bitcoinminer')
}
$AddonsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$BtcAssets = Join-Path $AddonsRoot 'Assets\addons\lifepunch\bitcoinmining'
$EntityRoot = Join-Path $BtcAssets 'entities\bitcoinminer'
$ModelRoot = Join-Path $BtcAssets 'models\lifepunch\bitcoinmining\bitcoin-miner'

$SourceBlend = Join-Path $SourceRoot 'source\bitcoinminer.blend'
$DestFbx = Join-Path $ModelRoot 'source\steam-machine.fbx'
$sourceTex = Join-Path $SourceRoot 'textures'

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        if ($WhatIf) { Write-Host "[WhatIf] mkdir $Path" }
        else { New-Item -ItemType Directory -Force -Path $Path | Out-Null }
    }
}

if (-not (Test-Path -LiteralPath $SourceBlend)) {
    throw "Missing Steam Machine blend: $SourceBlend"
}

Write-Host 'Bitcoin Miner hub intake (Steam Machine)' -ForegroundColor Cyan

if ($ExportFbx -and -not $WhatIf) {
    $exportScript = Join-Path $PSScriptRoot 'Export-BitcoinMinerSteamMachineFbx.ps1'
    & $exportScript -SourceRoot $SourceRoot
}

if (-not (Test-Path -LiteralPath $DestFbx)) {
    throw "Missing steam-machine.fbx at $DestFbx. Run with -ExportFbx or: Export-BitcoinMinerSteamMachineFbx.ps1"
}

$destBlendEntity = Join-Path $EntityRoot 'source\bitcoinminer.blend'
$destBlendModel = Join-Path $ModelRoot 'source\bitcoinminer.blend'
$destTexEntity = Join-Path $EntityRoot 'textures'
$destTexModel = Join-Path $ModelRoot 'source\textures'

if (-not $WhatIf) {
    Ensure-Dir $ArchiveRoot
    Copy-Item -LiteralPath $SourceBlend -Destination (Join-Path $ArchiveRoot 'bitcoinminer.blend') -Force
    if (Test-Path -LiteralPath $sourceTex) {
        Ensure-Dir (Join-Path $ArchiveRoot 'textures')
        Copy-Item -LiteralPath (Join-Path $sourceTex '*') -Destination (Join-Path $ArchiveRoot 'textures') -Recurse -Force
    }
}

Ensure-Dir (Join-Path $EntityRoot 'source')
Ensure-Dir (Join-Path $ModelRoot 'source')
Ensure-Dir $destTexModel

if ($WhatIf) {
    Write-Host "[WhatIf] blend + fbx + textures -> entity + model source"
}
else {
    Copy-Item -LiteralPath $SourceBlend -Destination $destBlendEntity -Force
    Copy-Item -LiteralPath $SourceBlend -Destination $destBlendModel -Force
    if (Test-Path -LiteralPath $sourceTex) {
        & robocopy $sourceTex $destTexEntity /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
        if ($LASTEXITCODE -ge 8) { throw "Texture robocopy to entity failed ($LASTEXITCODE)" }
        & robocopy $sourceTex $destTexModel /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
        if ($LASTEXITCODE -ge 8) { throw "Texture robocopy to model failed ($LASTEXITCODE)" }
    }
    Write-Host '  Steam Machine blend + FBX + textures OK' -ForegroundColor Green
}

Write-Host 'Intake OK — ModelDoc bitcoin-miner.vmdl: remap sm_* slots, Add Simple Animations (fanAction, front_panelAction).' -ForegroundColor Green
