<#
.SYNOPSIS
  Intake owner government datacenter + terminal assets.

.PARAMETER SourceRoot
  Default: Downloads\governmentdatacenter

.EXAMPLE
  powershell -File Intake-GovernmentDatacenter.ps1
#>
[CmdletBinding()]
param(
    [string] $SourceRoot = "$env:USERPROFILE\Downloads\governmentdatacenter",
    [string] $ArchiveRoot = 'C:\lifepunch\reference-intake\governmentdatacenter',
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$AddonsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$GovAssets = Join-Path $AddonsRoot 'Assets\addons\lifepunch\governmentdatacenter'

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        if ($WhatIf) { New-Item -ItemType Directory -Force -Path $Path | Out-Null }
        elseif (-not $WhatIf) { New-Item -ItemType Directory -Force -Path $Path | Out-Null }
    }
}

if (-not (Test-Path -LiteralPath $SourceRoot)) {
    throw "Missing $SourceRoot - drop government datacenter pack first."
}

$sourceMesh = Get-ChildItem -LiteralPath $SourceRoot -Recurse -Include *.fbx,*.dae,*.obj -ErrorAction SilentlyContinue | Select-Object -First 5
if (-not $sourceMesh) {
    throw "No FBX/DAE/OBJ found under $SourceRoot"
}

Write-Host 'Government datacenter intake' -ForegroundColor Cyan
Write-Host "  Source root: $SourceRoot" -ForegroundColor DarkGray

$intakeRaw = Join-Path $GovAssets 'intake-raw'
Ensure-Dir $intakeRaw
Ensure-Dir (Join-Path $GovAssets 'entities\governmentdatacenter')
Ensure-Dir (Join-Path $GovAssets 'entities\governmentterminal')
Ensure-Dir (Join-Path $GovAssets 'models\lifepunch\governmentdatacenter')

if ($WhatIf) {
    Write-Host "[WhatIf] Copy tree to intake-raw + archive"
    return
}

if (-not (Test-Path -LiteralPath $ArchiveRoot)) { New-Item -ItemType Directory -Force -Path $ArchiveRoot | Out-Null }
Copy-Item -LiteralPath $SourceRoot -Destination (Join-Path $ArchiveRoot 'source-tree') -Recurse -Force
Copy-Item -LiteralPath $SourceRoot -Destination (Join-Path $intakeRaw 'latest') -Recurse -Force

Write-Host '  Archive + intake-raw OK' -ForegroundColor Green
Write-Host 'Next: classify meshes (datacenter landmark vs terminal vs tax miner) in ASSET_INVENTORY.md' -ForegroundColor Yellow
Write-Host 'Intake OK - owner + Red sort files into entity/model folders.' -ForegroundColor Green
