<#
.SYNOPSIS
  Intake FBI / government server rack (Fab DataCenter) into governmentdatacenter.

.EXAMPLE
  powershell -File Intake-GovernmentServerRack.ps1
#>
[CmdletBinding()]
param(
    [string] $SourceRoot = '',
    [string] $GlassSourceRoot = '',
    [string] $ArchiveRoot = 'C:\lifepunch\reference-intake\governmentdatacenter\government-server-rack',
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'LifePunch-AddonDropPaths.ps1')
. (Join-Path $PSScriptRoot 'Import-FabServerRack.ps1')

if (-not $SourceRoot) {
    $SourceRoot = Get-LifePunchEntityDrop -Key 'fbi.government-server-rack'
}
if (-not $GlassSourceRoot) {
    $GlassSourceRoot = Resolve-LifePunchServerRackGlassRoot -ServerRackRoot $SourceRoot
}

$AddonsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$GovAssets = Join-Path $AddonsRoot 'Assets\addons\lifepunch\governmentdatacenter'
$ModelRoot = Join-Path $GovAssets 'models\lifepunch\governmentdatacenter\government-server-rack'
$DestSource = Join-Path $ModelRoot 'source'
$IntakeRaw = Join-Path $GovAssets 'intake-raw\government-server-rack'

Write-Host 'Government server rack intake (FBI lane)' -ForegroundColor Cyan
Write-Host "  Drop: $SourceRoot" -ForegroundColor DarkGray

if (-not $WhatIf) {
    if (-not (Test-Path -LiteralPath $ArchiveRoot)) { New-Item -ItemType Directory -Force -Path $ArchiveRoot | Out-Null }
    & robocopy $SourceRoot $ArchiveRoot /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "Archive robocopy failed ($LASTEXITCODE)" }
}

$result = Import-FabServerRackAssets `
    -SourceRoot $SourceRoot `
    -GlassSourceRoot $GlassSourceRoot `
    -DestFbxPath (Join-Path $DestSource 'government-server-rack.fbx') `
    -DestTrimDir (Join-Path $DestSource 'textures\trim') `
    -DestGlassDir (Join-Path $DestSource 'textures\glass') `
    -MeshFilter 'Servers.fbx' `
    -WhatIf:$WhatIf

Write-Host "  Mesh:  $($result.Mesh)" -ForegroundColor DarkGray
Write-Host "  Trim:  $($result.Trim)" -ForegroundColor DarkGray
Write-Host "  Glass: $($result.Glass)" -ForegroundColor DarkGray

if (-not $WhatIf) {
    if (-not (Test-Path -LiteralPath $IntakeRaw)) { New-Item -ItemType Directory -Force -Path $IntakeRaw | Out-Null }
    Copy-Item -LiteralPath (Join-Path $DestSource 'government-server-rack.fbx') -Destination (Join-Path $IntakeRaw 'government-server-rack.fbx') -Force
    if (-not (Test-Path -LiteralPath (Join-Path $GovAssets 'entities\government-server-rack'))) {
        New-Item -ItemType Directory -Force -Path (Join-Path $GovAssets 'entities\government-server-rack') | Out-Null
    }
}

Write-Host 'Intake OK — governmentdatacenter government-server-rack.vmdl' -ForegroundColor Green
