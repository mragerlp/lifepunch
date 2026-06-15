<#
.SYNOPSIS
  Intake criminal hacker server rack (Fab DataCenter) into hackerjob.

.EXAMPLE
  powershell -File Intake-HackerServerRack.ps1
#>
[CmdletBinding()]
param(
    [string] $SourceRoot = '',
    [string] $GlassSourceRoot = '',
    [string] $ArchiveRoot = 'C:\lifepunch\reference-intake\hackerjob\server-rack-fab',
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'LifePunch-AddonDropPaths.ps1')
. (Join-Path $PSScriptRoot 'Import-FabServerRack.ps1')

if (-not $SourceRoot) {
    $SourceRoot = Get-LifePunchEntityDrop -Key 'hacker.server-rack' -LegacyNames @('serverrack')
}
if (-not $GlassSourceRoot) {
    $GlassSourceRoot = Resolve-LifePunchServerRackGlassRoot -ServerRackRoot $SourceRoot
}

$AddonsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$HackerAssets = Join-Path $AddonsRoot 'Assets\addons\lifepunch\hackerjob'
$ModelRoot = Join-Path $HackerAssets 'models\lifepunch\hackerjob\server-rack'
$DestSource = Join-Path $ModelRoot 'source'
$IntakeRaw = Join-Path $HackerAssets 'intake-raw\server-rack'

Write-Host 'Hacker server rack intake (criminal lane)' -ForegroundColor Cyan
Write-Host "  Drop: $SourceRoot" -ForegroundColor DarkGray

if (-not $WhatIf) {
    if (-not (Test-Path -LiteralPath $ArchiveRoot)) { New-Item -ItemType Directory -Force -Path $ArchiveRoot | Out-Null }
    & robocopy $SourceRoot $ArchiveRoot /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "Archive robocopy failed ($LASTEXITCODE)" }
}

$result = Import-FabServerRackAssets `
    -SourceRoot $SourceRoot `
    -GlassSourceRoot $GlassSourceRoot `
    -DestFbxPath (Join-Path $DestSource 'server-rack.fbx') `
    -DestTrimDir (Join-Path $DestSource 'textures\trim') `
    -DestGlassDir (Join-Path $DestSource 'textures\glass') `
    -MeshFilter 'Servers.fbx' `
    -WhatIf:$WhatIf

Write-Host "  Mesh:  $($result.Mesh)" -ForegroundColor DarkGray
Write-Host "  Trim:  $($result.Trim)" -ForegroundColor DarkGray
Write-Host "  Glass: $($result.Glass)" -ForegroundColor DarkGray

if (-not $WhatIf) {
    if (-not (Test-Path -LiteralPath $IntakeRaw)) { New-Item -ItemType Directory -Force -Path $IntakeRaw | Out-Null }
    Copy-Item -LiteralPath (Join-Path $DestSource 'server-rack.fbx') -Destination (Join-Path $IntakeRaw 'server-rack.fbx') -Force
}

Write-Host 'Intake OK — hackerjob server-rack.vmdl' -ForegroundColor Green
