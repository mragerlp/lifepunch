<#
.SYNOPSIS
  Intake owner advanced server rack mesh into lifepunch hackerjob.

.PARAMETER SourceRoot
  Folder containing advanced server rack OBJ (+ MTL). Default: Desktop\advancedserverrack

.EXAMPLE
  powershell -File Intake-AdvancedServerRack.ps1 -SourceRoot "$env:USERPROFILE\OneDrive\Desktop\advancedserverrack"
#>
[CmdletBinding()]
param(
    [string] $SourceRoot = "$env:USERPROFILE\OneDrive\Desktop\advancedserverrack",
    [string] $ArchiveRoot = 'C:\lifepunch\reference-intake\hackerjob\advanced-server-rack',
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$AddonsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$HackerAssets = Join-Path $AddonsRoot 'Assets\addons\lifepunch\hackerjob'
$DestRoot = Join-Path $HackerAssets 'models\lifepunch\hackerjob\advanced-server-rack\source'
$IntakeRaw = Join-Path $HackerAssets 'intake-raw\advanced-server-rack'

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        if ($WhatIf) { Write-Host "[WhatIf] mkdir $Path" }
        else { New-Item -ItemType Directory -Force -Path $Path | Out-Null }
    }
}

if (-not (Test-Path -LiteralPath $SourceRoot)) {
    throw "Missing source root: $SourceRoot"
}

$mesh = Get-ChildItem -LiteralPath $SourceRoot -Recurse -File -Include *.obj,*.fbx,*.dae -ErrorAction SilentlyContinue |
    Sort-Object Length -Descending |
    Select-Object -First 1
if (-not $mesh) {
    throw "No OBJ/FBX/DAE under $SourceRoot"
}

$mtl = Get-ChildItem -LiteralPath $SourceRoot -Recurse -File -Filter *.mtl -ErrorAction SilentlyContinue | Select-Object -First 1
$texDir = @(
    (Join-Path $SourceRoot 'textures')
    (Join-Path $SourceRoot 'source\textures')
) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1

Write-Host 'Advanced server rack intake' -ForegroundColor Cyan
Write-Host "  Mesh: $($mesh.FullName)" -ForegroundColor DarkGray

if ($WhatIf) {
    Write-Host "[WhatIf] -> $DestRoot"
    return
}

Ensure-Dir $ArchiveRoot
Copy-Item -LiteralPath $SourceRoot -Destination (Join-Path $ArchiveRoot 'source-tree') -Recurse -Force
Ensure-Dir $IntakeRaw
Copy-Item -LiteralPath $SourceRoot -Destination (Join-Path $IntakeRaw 'latest') -Recurse -Force

Ensure-Dir $DestRoot
$destMesh = Join-Path $DestRoot ("advanced-server-rack{0}" -f $mesh.Extension)
Copy-Item -LiteralPath $mesh.FullName -Destination $destMesh -Force
if ($mtl) {
    Copy-Item -LiteralPath $mtl.FullName -Destination (Join-Path $DestRoot $mtl.Name) -Force
}
if ($texDir) {
    $destTex = Join-Path $DestRoot 'textures'
    Ensure-Dir $destTex
    Copy-Item -LiteralPath (Join-Path $texDir '*') -Destination $destTex -Recurse -Force
}

Write-Host '  advanced-server-rack source OK' -ForegroundColor Green
Write-Host 'Next: ModelDoc advanced-server-rack.vmdl, map MTL slots, compile _c.' -ForegroundColor Yellow
