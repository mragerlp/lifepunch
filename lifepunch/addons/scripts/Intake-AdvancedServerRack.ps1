<#
.SYNOPSIS
  Intake advanced hacker server rack (Fab DataCenter rows) into hackerjob.

.DESCRIPTION
  Same Fab pack as basic rack (OneDrive lifepunchhacker\hacker\serverrack):
    Servers\Model\Servers.fbx        -> server-rack (Intake-HackerServerRack.ps1)
    Servers\Model\Servers_Rows.fbx   -> advanced-server-rack (this script)
    Servers\Texture\2K\*             -> trim (shared)
    Glass_Cover_Material\2K\*        -> glass (shared)

.EXAMPLE
  powershell -File Intake-AdvancedServerRack.ps1
#>
[CmdletBinding()]
param(
    [string] $SourceRoot = '',
    [string] $GlassSourceRoot = '',
    [string] $ArchiveRoot = 'C:\lifepunch\reference-intake\hackerjob\advanced-server-rack-fab',
    [switch] $SkipBasicRackIntake,
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
$BasicModelRoot = Join-Path $HackerAssets 'models\lifepunch\hackerjob\server-rack'
$ModelRoot = Join-Path $HackerAssets 'models\lifepunch\hackerjob\advanced-server-rack'
$DestSource = Join-Path $ModelRoot 'source'
$IntakeRaw = Join-Path $HackerAssets 'intake-raw\advanced-server-rack'

Write-Host 'Advanced server rack intake (vengeance-tier rows)' -ForegroundColor Cyan
Write-Host "  Drop: $SourceRoot" -ForegroundColor DarkGray

if (-not $SkipBasicRackIntake) {
    Write-Host '  Running basic server-rack intake first (shared trim/glass)...' -ForegroundColor DarkGray
    $basicScript = Join-Path $PSScriptRoot 'Intake-HackerServerRack.ps1'
    if ($WhatIf) {
        Write-Host '[WhatIf] Intake-HackerServerRack.ps1' -ForegroundColor DarkGray
    }
    else {
        & $basicScript -SourceRoot $SourceRoot -GlassSourceRoot $GlassSourceRoot
    }
}

if (-not $WhatIf) {
    if (-not (Test-Path -LiteralPath $ArchiveRoot)) { New-Item -ItemType Directory -Force -Path $ArchiveRoot | Out-Null }
    & robocopy $SourceRoot $ArchiveRoot /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "Archive robocopy failed ($LASTEXITCODE)" }
}

$result = Import-FabServerRackAssets `
    -SourceRoot $SourceRoot `
    -GlassSourceRoot $GlassSourceRoot `
    -DestFbxPath (Join-Path $DestSource 'advanced-server-rack.fbx') `
    -DestTrimDir (Join-Path $DestSource 'textures\trim') `
    -DestGlassDir (Join-Path $DestSource 'textures\glass') `
    -MeshFilter 'Servers_Rows.fbx' `
    -WhatIf:$WhatIf

Write-Host "  Mesh:  $($result.Mesh)" -ForegroundColor DarkGray
Write-Host "  Trim:  $($result.Trim)" -ForegroundColor DarkGray
Write-Host "  Glass: $($result.Glass)" -ForegroundColor DarkGray

if (-not $WhatIf) {
    if (-not (Test-Path -LiteralPath $IntakeRaw)) { New-Item -ItemType Directory -Force -Path $IntakeRaw | Out-Null }
    Copy-Item -LiteralPath (Join-Path $DestSource 'advanced-server-rack.fbx') -Destination (Join-Path $IntakeRaw 'advanced-server-rack.fbx') -Force

    # Keep advanced tree in sync with basic rack trim/glass when basic intake ran.
    $basicTrim = Join-Path $BasicModelRoot 'source\textures\trim'
    $basicGlass = Join-Path $BasicModelRoot 'source\textures\glass'
    if (Test-Path -LiteralPath $basicTrim) {
        & robocopy $basicTrim (Join-Path $DestSource 'textures\trim') /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    }
    if (Test-Path -LiteralPath $basicGlass) {
        & robocopy $basicGlass (Join-Path $DestSource 'textures\glass') /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    }
}

Write-Host 'Intake OK — hackerjob advanced-server-rack.vmdl (reuses server-rack trim/glass vmats)' -ForegroundColor Green
