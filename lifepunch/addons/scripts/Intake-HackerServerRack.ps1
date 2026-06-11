<#
.SYNOPSIS
  Intake owner server rack DAE + PBR textures into lifepunch hackerjob.

.PARAMETER SourceRoot
  Default: Downloads\serverrack

.EXAMPLE
  powershell -File Intake-HackerServerRack.ps1
#>
[CmdletBinding()]
param(
    [string] $SourceRoot = "$env:USERPROFILE\Downloads\serverrack",
    [string] $ArchiveRoot = 'C:\lifepunch\reference-intake\hackerjob\server-rack',
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$AddonsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$HackerAssets = Join-Path $AddonsRoot 'Assets\addons\lifepunch\hackerjob'
$IntakeRaw = Join-Path $HackerAssets 'intake-raw\server-rack'

$SourceDae = Join-Path $SourceRoot 'source\_extracted\model\model.dae'
$SourceTexDir = Join-Path $SourceRoot 'source\_extracted\model\textures'
if (-not (Test-Path -LiteralPath $SourceDae)) {
    $zip = Join-Path $SourceRoot 'source\model.zip'
    if (Test-Path -LiteralPath $zip) {
        $extract = Join-Path $SourceRoot 'source\_extracted'
        if (-not $WhatIf) {
            Expand-Archive -LiteralPath $zip -DestinationPath $extract -Force
        }
    }
}

$DestDae = Join-Path $HackerAssets 'models\lifepunch\hackerjob\server-rack\source\server-rack.dae'
$DestTex = Join-Path $HackerAssets 'models\lifepunch\hackerjob\server-rack\source\textures'

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        if ($WhatIf) { Write-Host "[WhatIf] mkdir $Path" }
        else { New-Item -ItemType Directory -Force -Path $Path | Out-Null }
    }
}

if (-not (Test-Path -LiteralPath $SourceDae)) {
    throw "Missing DAE: $SourceDae - extract model.zip first."
}

Write-Host 'Hacker server rack intake' -ForegroundColor Cyan
Write-Host "  Source DAE: $SourceDae" -ForegroundColor DarkGray

if (-not $WhatIf) {
    Ensure-Dir $ArchiveRoot
    Copy-Item -LiteralPath $SourceDae -Destination (Join-Path $ArchiveRoot 'server-rack.dae') -Force
    if (Test-Path -LiteralPath $SourceTexDir) {
        Ensure-Dir (Join-Path $ArchiveRoot 'textures')
        Copy-Item -LiteralPath (Join-Path $SourceTexDir '*') -Destination (Join-Path $ArchiveRoot 'textures') -Recurse -Force
    }
    Ensure-Dir $IntakeRaw
    Copy-Item -LiteralPath $SourceDae -Destination (Join-Path $IntakeRaw 'server-rack.dae') -Force
    Write-Host 'Archive OK' -ForegroundColor Green
}

Ensure-Dir (Split-Path -Parent $DestDae)
Ensure-Dir $DestTex

if ($WhatIf) {
    Write-Host "[WhatIf] DAE -> $DestDae" -ForegroundColor DarkGray
    Write-Host "[WhatIf] textures -> $DestTex" -ForegroundColor DarkGray
}
else {
    Copy-Item -LiteralPath $SourceDae -Destination $DestDae -Force
    if (Test-Path -LiteralPath $SourceTexDir) {
        Copy-Item -LiteralPath (Join-Path $SourceTexDir '*') -Destination $DestTex -Recurse -Force
    }
    Write-Host '  server-rack OK' -ForegroundColor Green
}

Write-Host 'Intake OK - open server-rack.vmdl in ModelDoc, map materials, compile.' -ForegroundColor Green
