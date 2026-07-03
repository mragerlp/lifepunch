<#
.SYNOPSIS
  Document + optional batch export CS2 weapon reference assets to reference-intake.

.DESCRIPTION
  CS2 exports are REFERENCE-ONLY — never copied into the monorepo publish tree.
  Reads config/cs2-weapon-catalog.json (full study list) and weapon-production.json (ship queue).
  Requires Source 2 Viewer CLI for automated glTF export; without CLI, writes MANIFEST stubs.

.PARAMETER Ident
  Weapon ident(s). Default: all entries in cs2-weapon-catalog.json.

.PARAMETER Cs2Vpk
  Path to pak01_dir.vpk

.PARAMETER CliPath
  Source2Viewer-CLI.exe (optional)

.PARAMETER ExportGltf
  Run CLI export when CliPath is valid (experimental — verify vmdl_c path in VPK first)

.PARAMETER ManifestOnly
  Write MANIFEST stubs without VPK or CLI (Cornerman-safe)

.EXAMPLE
  powershell -File Intake-Cs2WeaponReference.ps1 -ManifestOnly
  powershell -File Intake-Cs2WeaponReference.ps1 -Ident ak47,deagle -CliPath 'C:\Tools\Source2Viewer-CLI.exe' -ExportGltf
#>
[CmdletBinding()]
param(
    [string[]] $Ident = @(),
    [string] $Cs2Vpk = 'D:\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\pak01_dir.vpk',
    [string] $CliPath = 'C:\Tools\Source2Viewer\Source2Viewer-CLI.exe',
    [string] $IntakeRoot = 'C:\lifepunch\reference-intake\cs2-weapons',
    [switch] $ExportGltf,
    [switch] $ManifestOnly,
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$AddonsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$CatalogPath = Join-Path $AddonsRoot 'config\cs2-weapon-catalog.json'
$ProdPath = Join-Path $AddonsRoot 'config\weapon-production.json'

$Catalog = Get-Content $CatalogPath -Raw | ConvertFrom-Json
$Prod = Get-Content $ProdPath -Raw | ConvertFrom-Json

if (-not $Ident -or $Ident.Count -eq 0) {
    $Ident = @($Catalog.entries | Sort-Object priority | ForEach-Object { $_.ident })
}

function Get-Cs2FolderName([string]$Cs2Mesh, [string]$S2vFolder) {
    if ($S2vFolder) { return $S2vFolder }
    if ($Cs2Mesh -match '^weapon_(?:pist|rif|smg|snip|shot)_(.+)$') { return $Matches[1] }
    return $Cs2Mesh
}

function Get-WeaponEntry([string]$Id) {
    $cat = $Catalog.entries | Where-Object { $_.ident -eq $Id } | Select-Object -First 1
    if (-not $cat) { return $null }

    $prod = $Prod.weapons | Where-Object { $_.ident -eq $Id } | Select-Object -First 1
    $study = $Prod.cs2StudyQueue | Where-Object { $_.ident -eq $Id } | Select-Object -First 1

    $title = if ($prod) { $prod.title } elseif ($study) { $study.title } else { $Id }
    $dxrp = if ($prod) { $prod.dxrpClassWeapon } elseif ($study) { $study.dxrpClassWeapon } else { $cat.dxrpClassWeapon }

    [pscustomobject]@{
        ident            = $cat.ident
        title            = $title
        cs2Mesh          = $cat.cs2Mesh
        s2vFolder        = $cat.s2vFolder
        dxrpClassWeapon  = $dxrp
        weaponClass      = $cat.weaponClass
        worldMeshHint    = $cat.worldMeshHint
        soundHints       = @($cat.soundHints)
        program          = $cat.program
        priority         = $cat.priority
        shipQueue        = [bool]$prod
        studyOnly        = [bool](-not $prod -and $study)
    }
}

function Ensure-Dir([string]$Path) {
    if ($WhatIf) { Write-Host "[WhatIf] mkdir $Path"; return }
    if (-not (Test-Path -LiteralPath $Path)) { New-Item -ItemType Directory -Force -Path $Path | Out-Null }
}

Write-Host 'CS2 weapon reference intake' -ForegroundColor Cyan
Write-Host "  VPK:     $Cs2Vpk" -ForegroundColor DarkGray
Write-Host "  Intake:  $IntakeRoot" -ForegroundColor DarkGray
Write-Host "  Catalog: $($Catalog.entries.Count) entries" -ForegroundColor DarkGray

if (-not $ManifestOnly -and -not (Test-Path -LiteralPath $Cs2Vpk)) {
    throw "CS2 VPK not found: $Cs2Vpk - install CS2, pass -Cs2Vpk, or use -ManifestOnly on Cornerman"
}

if ($ManifestOnly) {
    Write-Host '  Mode: ManifestOnly (no VPK / CLI required)' -ForegroundColor DarkYellow
}

$hasCli = $CliPath -and (Test-Path -LiteralPath $CliPath)
if ($ExportGltf -and -not $hasCli) {
    Write-Host 'WARN: -ExportGltf set but Source2Viewer-CLI not found - writing MANIFEST stubs only.' -ForegroundColor Yellow
    Write-Host '      Install from https://s2v.app/ and pass -CliPath' -ForegroundColor Yellow
}

foreach ($id in $Ident) {
    $w = Get-WeaponEntry $id
    if (-not $w) { throw "Unknown ident in cs2-weapon-catalog.json: $id" }

    $folder = Get-Cs2FolderName $w.cs2Mesh $w.s2vFolder
    $dest = Join-Path $IntakeRoot $id
    $vmDir = Join-Path $dest 'viewmodel'
    $worldDir = Join-Path $dest 'world'
    $sndDir = Join-Path $dest 'sounds'
    $attachDir = Join-Path $dest 'attachments'

    Ensure-Dir $vmDir
    Ensure-Dir $worldDir
    Ensure-Dir $sndDir
    Ensure-Dir $attachDir

    $soundSearch = ($w.soundHints + $folder + $w.cs2Mesh) | Select-Object -Unique
    $soundLines = ($soundSearch | ForEach-Object { "  - $_" }) -join "`n"
    $lane = if ($w.shipQueue) {
        'ship-queue'
    } elseif ($w.studyOnly -or $w.program -eq 'extended-study') {
        'extended-study'
    } else {
        'catalog-only'
    }
    $worldHint = if ($w.worldMeshHint) { $w.worldMeshHint } else { 'Export dropped/world vmdl_c separately from viewmodel ag2' }
    $stamp = Get-Date -Format 'yyyy-MM-dd HH:mm'
    $dxrp = $w.dxrpClassWeapon
    $cliOut = Join-Path $vmDir "$($w.cs2Mesh).glb"

    $manifest = @(
        "# CS2 reference manifest - $($w.title) ($id)"
        "Generated: $stamp"
        "lane: $lane"
        "program: $($w.program)"
        "cs2Mesh: $($w.cs2Mesh)"
        "dxrpClass: $dxrp"
        "weaponClass: $($w.weaponClass)"
        "s2vBrowse: weapons/models/$folder/"
        ''
        '## World model (fixes 3P hold + drop physics)'
        $worldHint
        "1. In S2V, list ALL .vmdl_c in weapons/models/$folder/"
        '2. Open each - find the DROPPED / WORLD mesh (not arms viewmodel, not mag-only)'
        "3. Export glTF/GLB to: $worldDir"
        "4. Blender: author LifePunch w_$id.fbx from WORLD proportions"
        '5. ModelDoc w_' + $id + '.vmdl MUST include Physics / convex collision hull (AK fell through floor without this)'
        "6. Clone class w_$dxrp.prefab - swap Model child only"
        ''
        '## Viewmodel (FP study - do not bonemerge static mesh onto M4 bones)'
        "1. Export main viewmodel / ag2 glTF to: $vmDir"
        '2. Study reload timing + moving parts only'
        "3. Ship FP via class vm_$dxrp until own rig (VIEWMODEL_RIG_PIPELINE.md)"
        ''
        '## Sounds (REFERENCE ONLY - ship LifePunch WAV like ak47/sounds/)'
        'Search VPK sounds/ and soundevents/ for:'
        $soundLines
        "Export reference WAV to: $sndDir"
        'Record event names below after export:'
        '  fire:'
        '  reload:'
        '  deploy:'
        '  distant:'
        ''
        '## GUI steps (Source 2 Viewer)'
        '1. Open pak01_dir.vpk'
        "2. weapons/models/$folder/ - open each .vmdl_c; note animation dropdown names here:"
        '   animations_seen:'
        "3. Decompile and Export glTF - viewmodel -> $vmDir"
        "4. Repeat for world/dropped variant -> $worldDir"
        "5. Mag / attachments -> $attachDir (optional)"
        ''
        '## CLI (when installed on VENGEANCE)'
        "Source2Viewer-CLI -i <vmdl_c path> -o $cliOut -d --gltf_export_format glb --gltf_export_materials --gltf_export_animations"
        ''
        '## Ship rule'
        "REFERENCE-ONLY - author own FBX in lifepunchaddons/Assets/.../w_$id/source/"
        'Never copy CS2 WAV into publish tree.'
        ''
        'See addons/docs/CS2_WORLD_MODEL_PIPELINE.md'
        'See addons/docs/CS2_SOUND_REFERENCE.md'
        'See addons/docs/CS2_WEAPON_HARVEST.md'
    ) -join "`n"

    $manifestPath = Join-Path $dest 'MANIFEST.txt'
    if ($WhatIf) {
        Write-Host "[WhatIf] $manifestPath"
    } else {
        Set-Content -LiteralPath $manifestPath -Value $manifest -Encoding UTF8
        Write-Host "  $id MANIFEST OK ($lane)" -ForegroundColor Green
    }

    if ($ExportGltf -and $hasCli) {
        $candidates = @(
            Join-Path $Cs2Vpk "weapons\models\$folder\$($w.cs2Mesh).vmdl_c"
            Join-Path $Cs2Vpk "weapons\models\$folder\weapon_$folder.vmdl_c"
        )
        $vmPath = $candidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
        if (-not $vmPath) {
            $list = & $CliPath -i $Cs2Vpk --vpk_list -f "weapons/models/$folder/" 2>$null
            $rel = $list | Where-Object { $_ -match "$([regex]::Escape($w.cs2Mesh))\.vmdl_c" } | ForEach-Object { ($_ -split '\s+')[0] } | Select-Object -First 1
            if ($rel) { $vmPath = $rel }
        }
        $outGlb = Join-Path $vmDir "$($w.cs2Mesh)_reference.glb"
        if ($WhatIf) {
            Write-Host "[WhatIf] CLI export $vmPath -> $outGlb"
        } elseif ($vmPath) {
            if (Test-Path -LiteralPath $outGlb) { Remove-Item -LiteralPath $outGlb -Force -Recurse -ErrorAction SilentlyContinue }
            & $CliPath -i $Cs2Vpk -f $vmPath -o $outGlb -d --gltf_export_format glb --gltf_export_materials --gltf_export_animations
            if ($LASTEXITCODE -ne 0) { Write-Host "  WARN: CLI exit $LASTEXITCODE for $id viewmodel" -ForegroundColor Yellow }
            else {
                $nested = Join-Path $vmDir "$($w.cs2Mesh).glb\weapons\models\$folder\$($w.cs2Mesh).glb"
                if ((Test-Path -LiteralPath $nested) -and -not (Test-Path -LiteralPath $outGlb)) {
                    Copy-Item -LiteralPath $nested -Destination $outGlb -Force
                }
                Write-Host "  $id viewmodel glTF OK -> $outGlb" -ForegroundColor Green
            }
        } else {
            Write-Host "  $id skip CLI viewmodel - use S2V GUI to find exact vmdl_c names in weapons/models/$folder/" -ForegroundColor DarkYellow
        }
    }
}

Write-Host "Intake OK - see CS2_WORLD_MODEL_PIPELINE.md and RED_CS2_WEAPON_BATCH.md" -ForegroundColor Cyan
