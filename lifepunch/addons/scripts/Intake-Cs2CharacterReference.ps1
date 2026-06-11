<#
.SYNOPSIS
  Document + optional batch export CS2 agent/gear reference assets to reference-intake.

.DESCRIPTION
  CS2 character exports are REFERENCE-ONLY — never copied into the monorepo publish tree.
  Study silhouettes and gear; ship LifePunch-owned meshes on s&box citizen / DXRP clothing.

.PARAMETER Ident
  Role ident from gear-production.json (swat, police, hacker, mayor, cybersecurity). Default: all roles.

.PARAMETER Prop
  Prop ident from gear-production.json props[] (e.g. riot_shield). Optional add-on export.

.PARAMETER Cs2Vpk
  Path to pak01_dir.vpk

.PARAMETER CliPath
  Source2Viewer-CLI.exe (optional)

.PARAMETER ExportGltf
  Run CLI export when CliPath is valid (verify exact .vmdl_c name in S2V GUI first)

.EXAMPLE
  powershell -File Intake-Cs2CharacterReference.ps1 -ManifestOnly
  powershell -File Intake-Cs2CharacterReference.ps1 -Ident swat,police
  powershell -File Intake-Cs2CharacterReference.ps1 -Ident swat -CliPath 'C:\Tools\Source2Viewer-CLI.exe' -ExportGltf
  powershell -File Intake-Cs2CharacterReference.ps1 -Prop riot_shield -ManifestOnly
#>
[CmdletBinding()]
param(
    [string[]] $Ident = @(),
    [string[]] $Prop = @(),
    [string] $Cs2Vpk = 'D:\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\pak01_dir.vpk',
    [string] $CliPath = '',
    [string] $IntakeRoot = 'C:\lifepunch\reference-intake\cs2-characters',
    [switch] $ExportGltf,
    [switch] $ManifestOnly,
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$AddonsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$Gear = Get-Content (Join-Path $AddonsRoot 'config\gear-production.json') -Raw | ConvertFrom-Json

function Ensure-Dir([string]$Path) {
    if ($WhatIf) { Write-Host "[WhatIf] mkdir $Path"; return }
    if (-not (Test-Path -LiteralPath $Path)) { New-Item -ItemType Directory -Force -Path $Path | Out-Null }
}

function Write-RoleManifest($Role, [string]$Dest) {
    $agentDir = Join-Path $Dest 'agent'
    $gearDir = Join-Path $Dest 'gear'
    $notesDir = Join-Path $Dest 'notes'

    Ensure-Dir $agentDir
    Ensure-Dir $gearDir
    Ensure-Dir $notesDir

    $specLine = if ($Role.relatedSpec) {
        "Related: addons/$($Role.relatedSpec)"
    } else {
        'Related: (owner job - TBD)'
    }

    $manifest = @(
        "# CS2 character reference manifest - $($Role.title) ($($Role.ident))"
        "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
        "dxrpJob: $($Role.dxrpJob)"
        "cs2AgentFolder: $($Role.cs2AgentFolder)"
        "cs2PrimaryModel: $($Role.cs2PrimaryModel)"
        "s2vBrowse: $($Role.s2vBrowse)"
        "terminalBrand: $($Role.terminalBrand) ($($Role.accentHex))"
        "shipTarget: $($Role.shipTarget)"
        ''
        $specLine
        ''
        '## GUI steps (Source 2 Viewer)'
        '1. Open pak01_dir.vpk'
        "2. Browse $($Role.s2vBrowse)"
        '3. Open the main agent .vmdl_c (variant names differ - confirm in S2V file tree)'
        '4. Preview idle / walk animations in toolbar dropdown'
        "5. Decompile and Export - glTF/GLB - $agentDir"
        "6. Export helmet / vest / gloves as separate glTF if split models exist - $gearDir"
        "7. Record exact .vmdl_c filenames and animation names in $notesDir\blender-notes.md"
        ''
        '## CLI (after GUI confirms path)'
        "Source2Viewer-CLI -i `"<exact agent.vmdl_c>`" -o `"$agentDir\$($Role.cs2PrimaryModel).glb`" -d --gltf_export_format glb --gltf_export_materials --gltf_export_animations"
        ''
        '## Ship rule'
        'REFERENCE-ONLY - author own FBX; attach to sbox citizen / DXRP clothing. Do NOT ship CS2 meshes.'
        'Animations: citizen rig, not CS2 skeleton.'
        ''
        'See addons/docs/CS2_CHARACTER_HARVEST.md'
    ) -join "`n"

    $manifestPath = Join-Path $Dest 'MANIFEST.txt'
    if ($WhatIf) {
        Write-Host "[WhatIf] $manifestPath"
    } else {
        Set-Content -LiteralPath $manifestPath -Value $manifest -Encoding UTF8
        Write-Host "  $($Role.ident) MANIFEST OK" -ForegroundColor Green
    }

    return $agentDir
}

function Write-PropManifest($PropRow, [string]$Dest) {
    $meshDir = Join-Path $Dest 'mesh'
    Ensure-Dir $meshDir

    $manifest = @(
        "# CS2 prop reference manifest - $($PropRow.title) ($($PropRow.ident))"
        "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
        "cs2Mesh: $($PropRow.cs2Mesh)"
        "s2vBrowse: $($PropRow.s2vBrowse)"
        "forRoles: $($PropRow.forRoles -join ', ')"
        ''
        '## GUI steps'
        '1. Open pak01_dir.vpk'
        "2. $($PropRow.s2vBrowse)"
        "3. Export glTF/GLB to $meshDir"
        ''
        'See addons/docs/CS2_CHARACTER_HARVEST.md'
    ) -join "`n"

    $manifestPath = Join-Path $Dest 'MANIFEST.txt'
    if ($WhatIf) {
        Write-Host "[WhatIf] $manifestPath"
    } else {
        Set-Content -LiteralPath $manifestPath -Value $manifest -Encoding UTF8
        Write-Host "  prop:$($PropRow.ident) MANIFEST OK" -ForegroundColor Green
    }

    return $meshDir
}

function Try-CliExport([string]$GuessPath, [string]$OutGlb, [string]$Label) {
    if (-not (Test-Path -LiteralPath $GuessPath)) {
        Write-Host "  $Label skip CLI - path not verified: $GuessPath (use S2V GUI first)" -ForegroundColor DarkYellow
        return
    }
    if ($WhatIf) {
        Write-Host "[WhatIf] CLI export $GuessPath -> $OutGlb"
        return
    }
    & $CliPath -i $GuessPath -o $OutGlb -d --gltf_export_format glb --gltf_export_materials --gltf_export_animations
    if ($LASTEXITCODE -ne 0) { Write-Host "  WARN: CLI exit $LASTEXITCODE for $Label" -ForegroundColor Yellow }
    else { Write-Host "  $Label glTF export OK" -ForegroundColor Green }
}

Write-Host 'CS2 character / job gear reference intake' -ForegroundColor Cyan
Write-Host "  VPK:    $Cs2Vpk" -ForegroundColor DarkGray
Write-Host "  Intake: $IntakeRoot" -ForegroundColor DarkGray

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

if (-not $Ident -or $Ident.Count -eq 0) {
    if (-not $Prop -or $Prop.Count -eq 0) {
        $Ident = @($Gear.roles | Sort-Object queueOrder | ForEach-Object { $_.ident })
    }
}

foreach ($id in $Ident) {
    $role = $Gear.roles | Where-Object { $_.ident -eq $id } | Select-Object -First 1
    if (-not $role) { throw "Unknown ident in gear-production.json: $id" }

    $dest = Join-Path $IntakeRoot $id
    $agentDir = Write-RoleManifest $role $dest

    if ($ExportGltf -and $hasCli) {
        $folder = $role.cs2AgentFolder
        $model = $role.cs2PrimaryModel
        $guess = Join-Path $Cs2Vpk "characters\models\$folder\$model.vmdl_c"
        $outGlb = Join-Path $agentDir "$model.glb"
        Try-CliExport $guess $outGlb $id
    }
}

foreach ($propId in $Prop) {
    $propRow = $Gear.props | Where-Object { $_.ident -eq $propId } | Select-Object -First 1
    if (-not $propRow) { throw "Unknown prop in gear-production.json: $propId" }

    $dest = Join-Path $IntakeRoot "_props\$propId"
    $meshDir = Write-PropManifest $propRow $dest

    if ($ExportGltf -and $hasCli) {
        $mesh = $propRow.cs2Mesh
        $guess = Join-Path $Cs2Vpk "weapons\models\$mesh\$mesh.vmdl_c"
        $outGlb = Join-Path $meshDir "$mesh.glb"
        Try-CliExport $guess $outGlb "prop:$propId"
    }
}

Write-Host 'Intake OK - see addons/docs/CS2_CHARACTER_HARVEST.md' -ForegroundColor Cyan
