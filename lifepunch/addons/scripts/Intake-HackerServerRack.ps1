<#
.SYNOPSIS
  Intake owner server rack DAE + PBR textures into lifepunch hackerjob.

.PARAMETER SourceRoot
  Default: first match among Desktop\serverrack, Downloads\serverrack

.EXAMPLE
  powershell -File Intake-HackerServerRack.ps1
  powershell -File Intake-HackerServerRack.ps1 -SourceRoot "$env:USERPROFILE\OneDrive\Desktop\serverrack"
#>
[CmdletBinding()]
param(
    [string] $SourceRoot = '',
    [string] $ArchiveRoot = 'C:\lifepunch\reference-intake\hackerjob\server-rack',
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$AddonsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$HackerAssets = Join-Path $AddonsRoot 'Assets\addons\lifepunch\hackerjob'
$IntakeRaw = Join-Path $HackerAssets 'intake-raw\server-rack'

function Resolve-ServerRackSourceRoot([string]$Explicit) {
    if ($Explicit) { return $Explicit }
    $candidates = @(
        (Join-Path $env:USERPROFILE 'OneDrive\Desktop\serverrack')
        (Join-Path $env:USERPROFILE 'Downloads\serverrack')
        (Join-Path $env:USERPROFILE 'Desktop\serverrack')
    )
    foreach ($c in $candidates) {
        if (-not (Test-Path -LiteralPath $c)) { continue }
        $dae = Resolve-ServerRackDae -Root $c
        $tex = if ($dae) { Resolve-ServerRackTextures -Root $c -DaePath $dae } else { $null }
        if ($dae -and $tex) { return $c }
    }
    foreach ($c in $candidates) {
        if (Test-Path -LiteralPath $c) { return $c }
    }
    return $candidates[1]
}

$SourceRoot = Resolve-ServerRackSourceRoot -Explicit $SourceRoot

function Resolve-ServerRackDae([string]$Root) {
    $candidates = @(
        (Join-Path $Root 'source\_extracted\model\model.dae')
        (Join-Path $Root 'source\model\model.dae')
    )
    foreach ($c in $candidates) {
        if (Test-Path -LiteralPath $c) { return $c }
    }
    $zip = Join-Path $Root 'source\model.zip'
    if (Test-Path -LiteralPath $zip) {
        $extract = Join-Path $Root 'source\_extracted'
        if (-not $WhatIf) {
            Expand-Archive -LiteralPath $zip -DestinationPath $extract -Force
        }
        $after = Join-Path $extract 'model\model.dae'
        if ($WhatIf -or (Test-Path -LiteralPath $after)) { return $after }
    }
    return $null
}

function Resolve-ServerRackTextures([string]$Root, [string]$DaePath) {
    $dirs = @(
        (Join-Path (Split-Path -Parent $DaePath) 'textures')
        (Join-Path $Root 'source\_extracted\model\textures')
        (Join-Path $Root 'source\model\textures')
        (Join-Path $Root 'textures')
    )
    foreach ($d in $dirs) {
        if (Test-Path -LiteralPath $d) { return $d }
    }
    return $null
}

$SourceDae = Resolve-ServerRackDae -Root $SourceRoot
$SourceTexDir = if ($SourceDae) { Resolve-ServerRackTextures -Root $SourceRoot -DaePath $SourceDae } else { $null }

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
        Copy-Item -Path "$SourceTexDir\*" -Destination (Join-Path $ArchiveRoot 'textures') -Force
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
        Copy-Item -Path "$SourceTexDir\*" -Destination $DestTex -Force
        Write-Host "  textures: $((Get-ChildItem -LiteralPath $DestTex -File).Count) files" -ForegroundColor DarkGray
    }
    else {
        Write-Host '  WARN: no textures found - ModelDoc PBR will be empty' -ForegroundColor Yellow
    }
    Write-Host '  server-rack OK' -ForegroundColor Green
}

Write-Host 'Intake OK - open server-rack.vmdl in ModelDoc, map materials, compile.' -ForegroundColor Green
