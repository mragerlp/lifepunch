<#
.SYNOPSIS
  Document + optional batch export CS2 weapon reference assets to reference-intake.

.DESCRIPTION
  CS2 exports are REFERENCE-ONLY — never copied into the monorepo publish tree.
  Requires Source 2 Viewer CLI for automated glTF export; without CLI, writes MANIFEST stubs.

.PARAMETER Ident
  Weapon ident from weapon-production.json (ak47, deagle, mp9, ssg08, xm1014). Default: all queue weapons.

.PARAMETER Cs2Vpk
  Path to pak01_dir.vpk

.PARAMETER CliPath
  Source2Viewer-CLI.exe (optional)

.PARAMETER ExportGltf
  Run CLI export when CliPath is valid (experimental — verify vmdl_c path in VPK first)

.EXAMPLE
  powershell -File Intake-Cs2WeaponReference.ps1 -Ident deagle
  powershell -File Intake-Cs2WeaponReference.ps1 -CliPath 'C:\Tools\Source2Viewer-CLI.exe' -ExportGltf
#>
[CmdletBinding()]
param(
    [string[]] $Ident = @(),
    [string] $Cs2Vpk = 'D:\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\pak01_dir.vpk',
    [string] $CliPath = '',
    [string] $IntakeRoot = 'C:\lifepunch\reference-intake\cs2-weapons',
    [switch] $ExportGltf,
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$AddonsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$Prod = Get-Content (Join-Path $AddonsRoot 'config\weapon-production.json') -Raw | ConvertFrom-Json

if (-not $Ident -or $Ident.Count -eq 0) {
    $Ident = @($Prod.weapons | Where-Object { $_.queueOrder -ge 1 } | Sort-Object queueOrder | ForEach-Object { $_.ident })
}

function Get-Cs2FolderName([string]$Cs2Mesh) {
    if ($Cs2Mesh -match '^weapon_(?:pist|rif|smg|snip|shot)_(.+)$') { return $Matches[1] }
    return $Cs2Mesh
}

function Ensure-Dir([string]$Path) {
    if ($WhatIf) { Write-Host "[WhatIf] mkdir $Path"; return }
    if (-not (Test-Path -LiteralPath $Path)) { New-Item -ItemType Directory -Force -Path $Path | Out-Null }
}

Write-Host 'CS2 weapon reference intake' -ForegroundColor Cyan
Write-Host "  VPK:    $Cs2Vpk" -ForegroundColor DarkGray
Write-Host "  Intake: $IntakeRoot" -ForegroundColor DarkGray

if (-not (Test-Path -LiteralPath $Cs2Vpk)) {
    throw "CS2 VPK not found: $Cs2Vpk - install CS2 or pass -Cs2Vpk"
}

$hasCli = $CliPath -and (Test-Path -LiteralPath $CliPath)
if ($ExportGltf -and -not $hasCli) {
    Write-Host 'WARN: -ExportGltf set but Source2Viewer-CLI not found - writing MANIFEST stubs only.' -ForegroundColor Yellow
    Write-Host '      Install from https://s2v.app/ and pass -CliPath' -ForegroundColor Yellow
}

foreach ($id in $Ident) {
    $w = $Prod.weapons | Where-Object { $_.ident -eq $id } | Select-Object -First 1
    if (-not $w) { throw "Unknown ident in weapon-production.json: $id" }

    $folder = Get-Cs2FolderName $w.cs2Mesh
    $dest = Join-Path $IntakeRoot $id
    $vmDir = Join-Path $dest 'viewmodel'
    $worldDir = Join-Path $dest 'world'
    $sndDir = Join-Path $dest 'sounds'

    Ensure-Dir $vmDir
    Ensure-Dir $worldDir
    Ensure-Dir $sndDir

    $manifest = @"
# CS2 reference manifest - $($w.title) ($id)
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm')
cs2Mesh: $($w.cs2Mesh)
dxrpClass: $($w.dxrpClassWeapon)
s2vBrowse: weapons/models/$folder/

## GUI steps (Source 2 Viewer)
1. Open pak01_dir.vpk
2. weapons/models/$folder/ - open main .vmdl_c (not mag-only)
3. Preview animations in toolbar dropdown
4. Decompile and Export - glTF - $vmDir
5. If separate world/dropped model exists - export to $worldDir
6. Search sounds/ for '$folder' / '$($w.cs2Mesh)' - WAV to $sndDir

## CLI (when installed)
Source2Viewer-CLI -i "<vmdl_c path>" -o "$vmDir\$($w.cs2Mesh).glb" -d `
  --gltf_export_format glb --gltf_export_materials --gltf_export_animations

## Ship rule
REFERENCE-ONLY - author own FBX in lifepunch/addons/Assets/.../w_$id/source/
FP anims: reuse s&box Facepunch v_$($w.dxrpClassWeapon) class kit, not CS2 skeleton.

See addons/docs/CS2_WEAPON_HARVEST.md
"@

    $manifestPath = Join-Path $dest 'MANIFEST.txt'
    if ($WhatIf) {
        Write-Host "[WhatIf] $manifestPath"
    } else {
        Set-Content -LiteralPath $manifestPath -Value $manifest -Encoding UTF8
        Write-Host "  $id MANIFEST OK" -ForegroundColor Green
    }

    if ($ExportGltf -and $hasCli) {
        $guess = Join-Path $Cs2Vpk "weapons\models\$folder\$($w.cs2Mesh).vmdl_c"
        $outGlb = Join-Path $vmDir "$($w.cs2Mesh).glb"
        if ($WhatIf) {
            Write-Host "[WhatIf] CLI export $guess -> $outGlb"
        } elseif (Test-Path -LiteralPath $guess) {
            & $CliPath -i $guess -o $outGlb -d --gltf_export_format glb --gltf_export_materials --gltf_export_animations
            if ($LASTEXITCODE -ne 0) { Write-Host "  WARN: CLI exit $LASTEXITCODE for $id" -ForegroundColor Yellow }
            else { Write-Host "  $id glTF export OK" -ForegroundColor Green }
        } else {
            Write-Host "  $id skip CLI - path not verified: $guess (use S2V GUI to find exact vmdl_c name)" -ForegroundColor DarkYellow
        }
    }
}

Write-Host 'Intake OK - see addons/docs/CS2_WEAPON_HARVEST.md' -ForegroundColor Cyan
