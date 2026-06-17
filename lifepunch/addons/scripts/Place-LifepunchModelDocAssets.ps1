<#
.SYNOPSIS
  Copy ModelDoc-necessary files into entity staging folders (empty or partial).

.DESCRIPTION
  Source of truth: repo lp* staging under Assets/addons/lifepunch/.
  Copies only what ModelDoc needs:
    assets/source/
    assets/textures/
    assets/models/   (vmdl, vmat, material maps, MODEL_BUILD.md)
    audit/manifest.json

  Skips code/, entities/, sounds/, ui/ unless -IncludeCode.

.PARAMETER Package
  e.g. lpbitcoin

.PARAMETER Entity
  e.g. bitcoinhub. Omit to sync all entities in the package.

.PARAMETER TargetRoot
  Root that contains package folders (default: repo Assets/addons/lifepunch).

.PARAMETER Studio
  Also mirror into lifepunch/modeldoc-studio/game/Assets/addons/lifepunch/

.EXAMPLE
  powershell -File lifepunch\addons\scripts\Place-LifepunchModelDocAssets.ps1 -Package lpbitcoin -Entity bitcoinhub
  powershell -File lifepunch\addons\scripts\Place-LifepunchModelDocAssets.ps1 -Package lpbitcoin -Studio
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $Package,
    [string] $Entity = '',
    [string] $TargetRoot = '',
    [switch] $Studio,
    [switch] $IncludeCode
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$AddonsRoot = Split-Path $Here -Parent
$repoStaging = Join-Path $AddonsRoot 'Assets\addons\lifepunch'
if (-not $TargetRoot) { $TargetRoot = $repoStaging }
$studioRoot = Join-Path (Split-Path $AddonsRoot -Parent) 'modeldoc-studio\game\Assets\addons\lifepunch'

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
    }
}

function Copy-ModelDocTree {
    param(
        [string]$FromEntity,
        [string]$ToEntity
    )
    if (-not (Test-Path -LiteralPath $FromEntity)) {
        Write-Host "  SKIP missing source $FromEntity" -ForegroundColor DarkYellow
        return
    }
    Ensure-Dir $ToEntity
    foreach ($sub in @('assets\source', 'assets\textures', 'assets\models', 'audit')) {
        $src = Join-Path $FromEntity $sub
        if (Test-Path -LiteralPath $src) {
            $dst = Join-Path $ToEntity $sub
            Ensure-Dir $dst
            & robocopy $src $dst /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
            if ($LASTEXITCODE -ge 8) { throw "robocopy failed: $src" }
        }
    }
    if ($IncludeCode) {
        $codeSrc = Join-Path $FromEntity 'code'
        if (Test-Path -LiteralPath $codeSrc) {
            & robocopy $codeSrc (Join-Path $ToEntity 'code') /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
        }
    }
    Write-Host "  OK -> $ToEntity" -ForegroundColor Green
}

$srcPkg = Join-Path $repoStaging $Package
if (-not (Test-Path -LiteralPath $srcPkg)) { throw "Missing repo package: $srcPkg" }

Write-Host "Place ModelDoc assets: $Package" -ForegroundColor Cyan
Write-Host "  Source: $srcPkg" -ForegroundColor DarkGray
Write-Host "  Target: $TargetRoot" -ForegroundColor DarkGray

$entities = if ($Entity) { @($Entity) } else {
    @(Get-ChildItem $srcPkg -Directory | Where-Object { $_.Name -ne 'audit' } | Select-Object -ExpandProperty Name)
}

foreach ($ent in $entities) {
    $from = Join-Path $srcPkg $ent
    $to = Join-Path (Join-Path $TargetRoot $Package) $ent
    Copy-ModelDocTree -FromEntity $from -ToEntity $to
    if ($Studio) {
        $studioTo = Join-Path (Join-Path $studioRoot $Package) $ent
        Copy-ModelDocTree -FromEntity $from -ToEntity $studioTo
    }
}

if ($Studio) {
    Write-Host "Studio tree: $studioRoot\$Package" -ForegroundColor DarkGray
}

Write-Host 'Done.' -ForegroundColor Cyan
