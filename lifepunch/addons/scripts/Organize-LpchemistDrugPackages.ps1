<#
.SYNOPSIS
  Normalize Desktop lpchemist + lpdrugdrops into canonical entity staging layout.

.DESCRIPTION
  Law: {lpPackage}/{entitySlot}/assets|code|audit
  assets/source/fbx|blend|obj, assets/textures, assets/models, ...

  lpchemist  = lab equipment, precursors, grow inputs, druglab bench
  lpdrugdrops = product props (bags/bricks/raw) + map drop entities (train/truck)

  Copies/moves loose files into canonical paths. Does not delete zips or extracted trees.

.EXAMPLE
  powershell -File lifepunch\addons\scripts\Organize-LpchemistDrugPackages.ps1
  powershell -File lifepunch\addons\scripts\Organize-LpchemistDrugPackages.ps1 -Root "C:\Users\jared\OneDrive\Desktop\UPLOAD READY ADDONS"
#>
[CmdletBinding()]
param(
    [string] $Root = "$env:USERPROFILE\OneDrive\Desktop\lifepunchaddons"
)

$ErrorActionPreference = 'Stop'

$lpchemistSlots = @(
    'druglab', 'drugtable', 'laboven', 'chemicalprocessor', 'chemicaljar',
    'iodinebarrel', 'sulfurbarrel', 'redphosphorusbarrel', 'cocaseed', 'cocaleaf'
)

$lpdrugdropsSlots = @(
    'methbag', 'methbrick', 'rawmeth', 'cocainebag', 'cocainebrick', 'traindrop', 'truckdrop'
)

$moveToDrugdrops = @('methbag', 'methbrick', 'rawmeth', 'cocainebag', 'cocainebrick')

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
    }
}

function Ensure-EntitySkeleton([string]$EntityPath) {
    foreach ($sub in @(
        'assets\source\fbx', 'assets\source\blend', 'assets\source\obj',
        'assets\textures', 'assets\models', 'assets\entities', 'assets\sounds', 'assets\ui',
        'code\components', 'code\ui', 'code\docs', 'audit', 'docs'
    )) {
        Ensure-Dir (Join-Path $EntityPath $sub)
    }
}

function Move-IfExists {
    param([string]$From, [string]$To)
    if (-not (Test-Path -LiteralPath $From)) { return $false }
    Ensure-Dir (Split-Path $To -Parent)
    if (Test-Path -LiteralPath $To) {
        $base = [System.IO.Path]::GetFileNameWithoutExtension($To)
        $ext = [System.IO.Path]::GetExtension($To)
        $dir = Split-Path $To -Parent
        $n = 1
        while (Test-Path -LiteralPath $To) {
            $To = Join-Path $dir "$base`_$n$ext"
            $n++
        }
    }
    Move-Item -LiteralPath $From -Destination $To -Force
    return $true
}

function Copy-IfExists {
    param([string]$From, [string]$To)
    if (-not (Test-Path -LiteralPath $From)) { return $false }
    Ensure-Dir (Split-Path $To -Parent)
    Copy-Item -LiteralPath $From -Destination $To -Force
    return $true
}

function Copy-TreeFiles {
    param([string]$FromDir, [string]$ToDir, [string[]]$Include = @('*.png', '*.jpg', '*.jpeg', '*.tga', '*.fbx', '*.obj', '*.dae', '*.blend'))
    if (-not (Test-Path -LiteralPath $FromDir)) { return 0 }
    Ensure-Dir $ToDir
    $n = 0
    foreach ($pat in $Include) {
        Get-ChildItem -LiteralPath $FromDir -Recurse -File -Filter $pat -ErrorAction SilentlyContinue | ForEach-Object {
            $dest = Join-Path $ToDir $_.Name
            if (-not (Test-Path -LiteralPath $dest)) {
                Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
                $n++
            }
        }
    }
    return $n
}

function Write-SlotManifest {
    param([string]$SlotPath, [hashtable]$Data)
    Ensure-Dir (Join-Path $SlotPath 'audit')
    ($Data | ConvertTo-Json -Depth 6) | Set-Content -LiteralPath (Join-Path $SlotPath 'audit\manifest.json') -Encoding UTF8
}

function Normalize-BarrelSlot {
    param([string]$SlotPath, [string]$SlotName, [string]$Role, [string]$ColorNote)
    $fbx = Join-Path $SlotPath 'assets\source\fbx\fuel_barrels.fbx'
    $tex = Join-Path $SlotPath 'assets\textures'
    $candidates = @(
        (Join-Path $SlotPath 'fuel_barrels.FBX'),
        (Join-Path $SlotPath 'assets\fuel_barrels.FBX'),
        (Join-Path $SlotPath 'assets\fuel_barrels.fbx')
    )
    foreach ($c in $candidates) { if (Move-IfExists $c $fbx) { break } }
    $matDir = Join-Path $SlotPath 'assets\materials'
    Copy-TreeFiles $matDir $tex | Out-Null
    Write-SlotManifest $SlotPath @{
        slot = $SlotName; role = $Role; primary_mesh = 'assets/source/fbx/fuel_barrels.fbx'
        notes = @($ColorNote; 'Shared barrel mesh — tint via vmat')
        issues = @()
    }
}

if (-not (Test-Path -LiteralPath $Root)) { throw "Missing root: $Root" }

Write-Host "Organize lpchemist + lpdrugdrops" -ForegroundColor Cyan
Write-Host "  Root: $Root" -ForegroundColor DarkGray

# Move product slots from lpchemist -> lpdrugdrops if still under wrong package
foreach ($slot in $moveToDrugdrops) {
    $from = Join-Path $Root "lpchemist\$slot"
    $toPkg = Join-Path $Root 'lpdrugdrops'
    $to = Join-Path $toPkg $slot
    if (-not (Test-Path -LiteralPath $from)) { continue }
    Ensure-Dir $toPkg
    if (Test-Path -LiteralPath $to) {
        Write-Host "  merge lpchemist/$slot -> lpdrugdrops/$slot" -ForegroundColor DarkYellow
        Get-ChildItem -LiteralPath $from -Recurse -Force | ForEach-Object {
            $rel = $_.FullName.Substring($from.Length).TrimStart('\')
            $dest = Join-Path $to $rel
            if ($_.PSIsContainer) { Ensure-Dir $dest; return }
            Ensure-Dir (Split-Path $dest -Parent)
            if (-not (Test-Path -LiteralPath $dest)) {
                Move-Item -LiteralPath $_.FullName -Destination $dest -Force
            }
        }
        if (@(Get-ChildItem -LiteralPath $from -Force -ErrorAction SilentlyContinue).Count -eq 0) {
            Remove-Item -LiteralPath $from -Force -ErrorAction SilentlyContinue
        }
    }
    else {
        Move-Item -LiteralPath $from -Destination $to -Force
        Write-Host "  moved lpchemist/$slot -> lpdrugdrops/$slot" -ForegroundColor Green
    }
}

foreach ($slot in $lpchemistSlots + $lpdrugdropsSlots) {
    $pkg = if ($lpchemistSlots -contains $slot) { 'lpchemist' } else { 'lpdrugdrops' }
    $slotPath = Join-Path $Root "$pkg\$slot"
    Ensure-Dir $slotPath
    Ensure-EntitySkeleton $slotPath
}

# --- lpchemist slots ---
$druglab = Join-Path $Root 'lpchemist\druglab'
Move-IfExists (Join-Path $druglab 'assets\methlab.FBX') (Join-Path $druglab 'assets\source\fbx\meth-lab-bench.fbx') | Out-Null
Move-IfExists (Join-Path $druglab 'assets\methlab.fbx') (Join-Path $druglab 'assets\source\fbx\meth-lab-bench.fbx') | Out-Null
Copy-TreeFiles (Join-Path $druglab 'assets') (Join-Path $druglab 'assets\textures') -Include @('*.png', '*.jpg', '*.jpeg', '*.tga') | Out-Null
Write-SlotManifest $druglab @{
    slot = 'druglab'; role = 'Meth lab bench (Fab Props FOR Labs hero merge)'; priority = 'P2'
    primary_mesh = 'assets/source/fbx/meth-lab-bench.fbx'
    fab_listing = 'https://www.fab.com/listings/87ceafb0-5a88-4d8c-b960-ae301f53036a'
    issues = @('Export Chemistry/Texture maps from UE if not yet in assets/textures/')
}

$drugtable = Join-Path $Root 'lpchemist\drugtable'
Move-IfExists (Join-Path $drugtable 'source\drugtable.blend') (Join-Path $drugtable 'assets\source\blend\drugtable.blend') | Out-Null
Copy-TreeFiles (Join-Path $drugtable 'textures') (Join-Path $drugtable 'assets\textures') | Out-Null
Write-SlotManifest $drugtable @{
    slot = 'drugtable'; role = 'Alternate drug table (blend source)'; primary_mesh = 'assets/source/blend/drugtable.blend'
    issues = @('Export FBX from blend before ModelDoc if blend import unavailable')
}

$chemJar = Join-Path $Root 'lpchemist\chemicaljar'
Move-IfExists (Join-Path $chemJar 'assets\y1.fbx') (Join-Path $chemJar 'assets\source\fbx\chemical-jar.fbx') | Out-Null
Move-IfExists (Join-Path $chemJar 'assets\y1.blend') (Join-Path $chemJar 'assets\source\blend\chemical-jar.blend') | Out-Null
Write-SlotManifest $chemJar @{ slot = 'chemicaljar'; role = 'Chemical jar prop'; primary_mesh = 'assets/source/fbx/chemical-jar.fbx'; issues = @() }

$chemProc = Join-Path $Root 'lpchemist\chemicalprocessor'
Get-ChildItem (Join-Path $chemProc 'assets') -Filter '*.fbx' -File -ErrorAction SilentlyContinue | ForEach-Object {
    Move-IfExists $_.FullName (Join-Path $chemProc 'assets\source\fbx\chemical-processor.fbx') | Out-Null
}
Write-SlotManifest $chemProc @{ slot = 'chemicalprocessor'; role = 'Chemical processor'; primary_mesh = 'assets/source/fbx/chemical-processor.fbx'; issues = @() }

$labOven = Join-Path $Root 'lpchemist\laboven'
Get-ChildItem (Join-Path $labOven 'assets\source') -Filter '*.glb' -File -ErrorAction SilentlyContinue | ForEach-Object {
    Move-IfExists $_.FullName (Join-Path $labOven 'assets\source\obj\lab-oven.glb') | Out-Null
}
Write-SlotManifest $labOven @{
    slot = 'laboven'; role = 'Laboratory drying oven'; primary_mesh = 'assets/source/obj/lab-oven.glb'
    issues = @('GLB reference — export FBX for ModelDoc if needed')
}

Normalize-BarrelSlot (Join-Path $Root 'lpchemist\iodinebarrel') 'iodinebarrel' 'Iodine precursor barrel (blue)' 'Blue barrel maps in assets/textures/'
Normalize-BarrelSlot (Join-Path $Root 'lpchemist\sulfurbarrel') 'sulfurbarrel' 'Sulfur precursor barrel (green)' 'Green barrel maps in assets/textures/'
Normalize-BarrelSlot (Join-Path $Root 'lpchemist\redphosphorusbarrel') 'redphosphorusbarrel' 'Red phosphorus barrel (red)' 'Red/default barrel maps in assets/textures/'

$cocaSeed = Join-Path $Root 'lpchemist\cocaseed'
Move-IfExists (Join-Path $cocaSeed 'assets\source\seed.fbx') (Join-Path $cocaSeed 'assets\source\fbx\coca-seed.fbx') | Out-Null
Write-SlotManifest $cocaSeed @{ slot = 'cocaseed'; role = 'Coca seed prop'; primary_mesh = 'assets/source/fbx/coca-seed.fbx'; issues = @() }

$cocaLeaf = Join-Path $Root 'lpchemist\cocaleaf'
if (Test-Path (Join-Path $cocaLeaf 'assets\source\leaf.zip')) {
    Copy-IfExists (Join-Path $cocaLeaf 'assets\source\leaf.zip') (Join-Path $cocaLeaf 'assets\source\obj\leaf.zip') | Out-Null
}
Write-SlotManifest $cocaLeaf @{
    slot = 'cocaleaf'; role = 'Coca leaf prop'; primary_mesh = 'assets/source/obj/leaf.zip (extract for mesh)'
    issues = @('Extract leaf.zip when ready — keep zip as source archive')
}

# --- lpdrugdrops slots ---
$methBag = Join-Path $Root 'lpdrugdrops\methbag'
Move-IfExists (Join-Path $methBag 'assets\source\output.fbx') (Join-Path $methBag 'assets\source\fbx\meth-bag.fbx') | Out-Null
Copy-TreeFiles (Join-Path $methBag 'assets\source') (Join-Path $methBag 'assets\textures') -Include @('*.jpg', '*.jpeg', '*.png') | Out-Null
Write-SlotManifest $methBag @{ slot = 'methbag'; role = 'Meth bag product'; primary_mesh = 'assets/source/fbx/meth-bag.fbx'; issues = @() }

$methBrick = Join-Path $Root 'lpdrugdrops\methbrick'
Move-IfExists (Join-Path $methBrick 'assets\source\Drug_Brick_Simple.obj') (Join-Path $methBrick 'assets\source\obj\meth-brick.obj') | Out-Null
Write-SlotManifest $methBrick @{ slot = 'methbrick'; role = 'Meth brick product'; primary_mesh = 'assets/source/obj/meth-brick.obj'; issues = @() }

$rawMeth = Join-Path $Root 'lpdrugdrops\rawmeth'
Move-IfExists (Join-Path $rawMeth 'assets\source\model\model.dae') (Join-Path $rawMeth 'assets\source\obj\raw-meth.dae') | Out-Null
Copy-TreeFiles (Join-Path $rawMeth 'assets\source\model\textures') (Join-Path $rawMeth 'assets\textures') | Out-Null
Write-SlotManifest $rawMeth @{ slot = 'rawmeth'; role = 'Raw meth product'; primary_mesh = 'assets/source/obj/raw-meth.dae'; issues = @() }

$cocaBag = Join-Path $Root 'lpdrugdrops\cocainebag'
Move-IfExists (Join-Path $cocaBag 'assets\source\DrugBaggieLP.fbx') (Join-Path $cocaBag 'assets\source\fbx\cocaine-bag.fbx') | Out-Null
Write-SlotManifest $cocaBag @{ slot = 'cocainebag'; role = 'Cocaine bag product'; primary_mesh = 'assets/source/fbx/cocaine-bag.fbx'; issues = @() }

$cocaBrick = Join-Path $Root 'lpdrugdrops\cocainebrick'
Move-IfExists (Join-Path $cocaBrick 'assets\source\Coke Brick.fbx') (Join-Path $cocaBrick 'assets\source\fbx\coke-brick.fbx') | Out-Null
Copy-TreeFiles (Join-Path $cocaBrick 'assets\source\cokebrick') (Join-Path $cocaBrick 'assets\textures') | Out-Null
Write-SlotManifest $cocaBrick @{ slot = 'cocainebrick'; role = 'Cocaine brick product'; primary_mesh = 'assets/source/fbx/coke-brick.fbx'; issues = @() }

$trainDrop = Join-Path $Root 'lpdrugdrops\traindrop'
Get-ChildItem (Join-Path $trainDrop 'assets\source') -Filter '*.blend' -File -ErrorAction SilentlyContinue | ForEach-Object {
    Move-IfExists $_.FullName (Join-Path $trainDrop 'assets\source\blend\train-drop.blend') | Out-Null
}
Write-SlotManifest $trainDrop @{
    slot = 'traindrop'; role = 'Train drug drop map entity'; primary_mesh = 'assets/source/blend/train-drop.blend'
    issues = @('Map entity — export FBX when drop prefab is wired')
}

$truckDrop = Join-Path $Root 'lpdrugdrops\truckdrop'
Move-IfExists (Join-Path $truckDrop 'assets\source\Truck.blend') (Join-Path $truckDrop 'assets\source\blend\truck-drop.blend') | Out-Null
Write-SlotManifest $truckDrop @{
    slot = 'truckdrop'; role = 'Truck drug drop map entity'; primary_mesh = 'assets/source/blend/truck-drop.blend'
    issues = @('Map entity — export FBX when drop prefab is wired')
}

# Package README stubs
@(
    'lpchemist = Drug Chemist job — lab bench, precursors, grow inputs, processing props.',
    'Slots: druglab drugtable laboven chemicalprocessor chemicaljar iodinebarrel sulfurbarrel redphosphorusbarrel cocaseed cocaleaf',
    'Law: addons/docs/PACKAGE_STAGING_LAYOUT.md'
) | Set-Content -LiteralPath (Join-Path $Root 'lpchemist\README.txt') -Encoding UTF8

@(
    'lpdrugdrops = Drug product props + map drop entities.',
    'Slots: methbag methbrick rawmeth cocainebag cocainebrick traindrop truckdrop',
    'Law: addons/docs/PACKAGE_STAGING_LAYOUT.md'
) | Set-Content -LiteralPath (Join-Path $Root 'lpdrugdrops\README.txt') -Encoding UTF8

Write-Host 'Done.' -ForegroundColor Cyan
