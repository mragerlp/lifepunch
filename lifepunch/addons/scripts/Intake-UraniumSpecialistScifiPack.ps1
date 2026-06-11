<#
.SYNOPSIS
  Intake Pack_SciFi_B_001 into lifepunch uraniumspecialist addon tree (raw FBX/OBJ per prop).

.PARAMETER ZipPath
  Owner download (default: Downloads Pack_SciFi_B_001_V1.0.zip).

.EXAMPLE
  powershell -File Intake-UraniumSpecialistScifiPack.ps1
#>
[CmdletBinding()]
param(
    [string] $ZipPath = "$env:USERPROFILE\Downloads\Pack_SciFi_B_001_V1.0.zip",
    [string] $ArchiveRoot = 'C:\lifepunch\reference-intake\uraniumspecialist\pack-scifi-b-001',
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$AddonsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$Ident = 'uraniumspecialist'
$AssetRoot = Join-Path $AddonsRoot "Assets\addons\lifepunch\$Ident"
$ModelsRoot = Join-Path $AssetRoot "models\lifepunch\$Ident"
$IntakeRoot = Join-Path $AssetRoot 'intake-raw\pack-scifi-b-001'

$PropMap = [ordered]@{
    'SM_Reactor'         = @{ slug = 'uranium-reactor'; role = 'Primary reactor - job centerpiece' }
    'SM_Energy_Cell'     = @{ slug = 'uranium-energy-cell'; role = 'Fuel cell / enriched material crate' }
    'SM_Cell'            = @{ slug = 'uranium-cell'; role = 'Small cell prop' }
    'SM_Control_Pannel'  = @{ slug = 'uranium-control-panel'; role = 'Control station / job terminal anchor' }
    'SM_Power_Cabinet'   = @{ slug = 'uranium-power-cabinet'; role = 'Power cabinet' }
    'SM_Power_Junction'  = @{ slug = 'uranium-power-junction'; role = 'Junction box' }
    'SM_Fuse_Box'        = @{ slug = 'uranium-fuse-box'; role = 'Fuse box' }
    'SM_Batterie'        = @{ slug = 'uranium-battery'; role = 'Battery storage' }
    'SM_Capacitor'       = @{ slug = 'uranium-capacitor'; role = 'Capacitor bank' }
    'SM_Card'            = @{ slug = 'uranium-circuit-card'; role = 'Circuit card' }
    'SM_Switch'          = @{ slug = 'uranium-switch'; role = 'Switch / breaker' }
    'SM_Ventilateur'     = @{ slug = 'uranium-cooling-fan'; role = 'Cooling fan' }
}

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        if ($WhatIf) { Write-Host "[WhatIf] mkdir $Path" }
        else { New-Item -ItemType Directory -Force -Path $Path | Out-Null }
    }
}

function Write-Utf8NoBom([string]$Path, [string]$Content) {
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Content, $utf8)
}

function Copy-IfExists([string]$From, [string]$To) {
    if (-not (Test-Path -LiteralPath $From)) { return $false }
    if ($WhatIf) {
        Write-Host "[WhatIf] copy $From -> $To"
        return $true
    }
    Ensure-Dir (Split-Path -Parent $To)
    Copy-Item -LiteralPath $From -Destination $To -Force
    return $true
}

if (-not (Test-Path -LiteralPath $ZipPath)) {
    throw "Missing zip: $ZipPath"
}

Write-Host 'Uranium Specialist - SciFi Pack B intake' -ForegroundColor Cyan
Write-Host "  Zip: $ZipPath" -ForegroundColor DarkGray
Write-Host "  Publish: $AssetRoot" -ForegroundColor DarkGray

$extractTemp = Join-Path $env:TEMP "lp-uranium-scifi-b-$([guid]::NewGuid().ToString('N'))"
if (-not $WhatIf) {
    Ensure-Dir $extractTemp
    Expand-Archive -LiteralPath $ZipPath -DestinationPath $extractTemp -Force
}

$packInner = Get-ChildItem -LiteralPath $extractTemp -Directory | Select-Object -First 1
if (-not $packInner) { throw 'Zip extracted empty' }
$exportFbx = Join-Path $packInner.FullName '02_EXPORT\FBX'
$exportObj = Join-Path $packInner.FullName '02_EXPORT\OBJ'

if (-not $WhatIf) {
    Ensure-Dir $ArchiveRoot
    & robocopy $packInner.FullName $ArchiveRoot /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "Archive robocopy failed ($LASTEXITCODE)" }
    Write-Host "Archive OK: $ArchiveRoot" -ForegroundColor Green

    Ensure-Dir $IntakeRoot
    & robocopy $packInner.FullName $IntakeRoot /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "Intake mirror failed ($LASTEXITCODE)" }
}

foreach ($entry in $PropMap.GetEnumerator()) {
    $srcName = $entry.Key
    $slug = $entry.Value.slug
    $role = $entry.Value.role
    $destDir = Join-Path $ModelsRoot $slug
    $sourceDir = Join-Path $destDir 'source'

    if (-not $WhatIf) { Ensure-Dir $sourceDir }

    $fbx = Join-Path $exportFbx "$srcName.fbx"
    $obj = Join-Path $exportObj "$srcName.obj"
    $mtl = Join-Path $exportObj "$srcName.mtl"

    $copied = 0
    if (Copy-IfExists $fbx (Join-Path $sourceDir "$slug.fbx")) { $copied++ }
    if (Copy-IfExists $obj (Join-Path $sourceDir "$slug.obj")) { $copied++ }
    if (Copy-IfExists $mtl (Join-Path $sourceDir "$slug.mtl")) { $copied++ }

    if ($copied -eq 0 -and -not $WhatIf) {
        Write-Warning "No files for $srcName"
        continue
    }

    $modelBuild = @"
# $slug

**Pack:** LowPoly SciFi Pack B 001 | **Source FBX:** ``source/$slug.fbx``  
**Role:** $role  
**Target vmdl:** ``$slug.vmdl`` (ModelDoc TODO)

## ModelDoc

1. Import ``source/$slug.fbx`` (prefer FBX over OBJ for s&box).
2. Material slots are **procedural** (no texture PNGs) - see ``../MATERIAL_SLOTS.md``.
3. Create vmats under ``materials/`` or per-slot ``complex.shader`` baselines.
4. Compile ``$slug.vmdl`` then pull ``_c`` via ``Pull-DxrpCompiledAssetsToRepo.ps1``.
5. Wire prefab under ``entities/$slug/`` when gameplay is scoped.

## Scale

Tune ``import_scale`` in ModelDoc against a DXRP citizen (~64-72 units tall). Reactor is the scale reference for the job line.
"@
    if (-not $WhatIf) {
        Write-Utf8NoBom (Join-Path $destDir 'MODEL_BUILD.md') $modelBuild
        $map = @{
            schemaVersion = 1
            model         = @{
                slug         = $slug
                displayName  = ($slug -replace '-', ' ')
                activeSource = "source/$slug.fbx"
                targetModel  = "$slug.vmdl"
                packSource   = $srcName
                status       = 'ModelDoc TODO'
            }
            materials     = @(
                'M_Cyan', 'M_Gris_Metal', 'M_Noir_Bleute', 'M_Noir_Profond', 'M_Orange'
            )
            status        = @{
                sourceSeeded             = $true
                modelResourceCreated     = $false
                materialResourcesCreated = $false
            }
        }
        Write-Utf8NoBom (Join-Path $destDir 'material-map.json') ($map | ConvertTo-Json -Depth 5)
    }

    Write-Host "  $slug ($copied files)" -ForegroundColor Green
}

if (-not $WhatIf) {
    Remove-Item -LiteralPath $extractTemp -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host 'Intake OK' -ForegroundColor Green
