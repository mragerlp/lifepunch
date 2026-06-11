<#
.SYNOPSIS
  Scaffold a LifePunch weapon addon from the AK kit pattern (mass-production lane).

.PARAMETER Ident
  Addon ident (e.g. deagle, mp9).

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File New-LifePunchWeapon.ps1 -Ident deagle
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $Ident,
    [switch] $Force
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$Root = (Resolve-Path (Join-Path $Here '..')).Path
$ProdPath = Join-Path $Root 'config\weapon-production.json'
$ManifestPath = Join-Path $Root 'config\addons.json'

if (-not (Test-Path -LiteralPath $ProdPath)) { throw "Missing $ProdPath" }

$prod = Get-Content -LiteralPath $ProdPath -Raw | ConvertFrom-Json
$spec = @($prod.weapons) | Where-Object { $_.ident -eq $Ident } | Select-Object -First 1
if (-not $spec) { throw "Ident '$Ident' not in weapon-production.json" }
if ($Ident -eq 'ak47') { throw 'AK-47 is the golden kit - edit it directly, do not scaffold over it.' }

$title = [string]$spec.title
$label = [string]$spec.displayLabel
$class = [string]$spec.weaponClass
$classRef = [string]$spec.dxrpClassWeapon
$cs2 = [string]$spec.cs2Mesh
$sboxId = [string]$spec.sboxIdentifier
$pascal = (Get-Culture).TextInfo.ToTitleCase($Ident) -replace '-',''
$ns = "LifePunch.DXRP.Addons.$pascal"

$assetsRoot = Join-Path $Root "Assets\addons\lifepunch\$Ident"
$codeRoot = Join-Path $Root "Code\Addons\lifepunch\$Ident"
if ((Test-Path -LiteralPath $assetsRoot) -or (Test-Path -LiteralPath $codeRoot)) {
    if (-not $Force) { throw "Scaffold exists for '$Ident'. Pass -Force to refresh docs/code stubs only." }
}

function New-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
    }
}

function Write-IfMissing([string]$Path, [string]$Content) {
    if (Test-Path -LiteralPath $Path) { return $false }
    $parent = Split-Path -Parent $Path
    if ($parent) { New-Dir $parent }
    Set-Content -LiteralPath $Path -Value $Content -Encoding UTF8
    return $true
}

$utf8 = [System.Text.UTF8Encoding]::new( $false )
$headerTemplatePath = Join-Path $Here 'templates\proprietary-header.cs.template'
if (-not (Test-Path -LiteralPath $headerTemplatePath)) { throw "Missing $headerTemplatePath" }
$headerTemplate = [System.IO.File]::ReadAllText( $headerTemplatePath, $utf8 )
$header = $headerTemplate.
    Replace( '{{TITLE}}', $title ).
    Replace( '{{SBOX_ID}}', $sboxId ).
    Replace( '{{IDENT}}', $Ident )

function Write-Utf8File( [string]$Path, [string]$Content ) {
    [System.IO.File]::WriteAllText( $Path, $Content, $utf8 )
}

# --- Assets tree ---
$dirs = @(
    "$assetsRoot\equipment\w_$Ident",
    "$assetsRoot\equipment\vm_$Ident",
    "$assetsRoot\models\lifepunch\$Ident\w_$Ident\source",
    "$assetsRoot\models\lifepunch\$Ident\w_$Ident\textures",
    "$assetsRoot\models\lifepunch\$Ident\w_$Ident\materials",
    "$assetsRoot\models\lifepunch\$Ident\v_$Ident\source",
    "$assetsRoot\sounds\source",
    "$assetsRoot\ui"
)
foreach ($d in $dirs) { New-Dir $d }

$wPath = "addons/lifepunch/$Ident/equipment/w_$Ident/w_$Ident.prefab"
$vmPath = "addons/lifepunch/$Ident/equipment/vm_$Ident/vm_$Ident.prefab"
$vmdlPath = "addons/lifepunch/$Ident/models/lifepunch/$Ident/w_$Ident/w_$Ident.vmdl"
$classW = "gameplay/equipment/weapons/$classRef/w_$classRef.prefab"
$classVm = "gameplay/equipment/weapons/$classRef/vm_$classRef.prefab"

$assetsReadme = @"
# $title Assets

Mass-production scaffold — clone of AK kit pattern. Class: **$class** (DXRP reference: **$classRef**).

## CS2 reference (study only — do not ship)

Source 2 Viewer: ``weapons/models/$($cs2 -replace 'weapon_(pist|rif|smg|snip|shot)_','')/`` → ``$cs2``

Export glTF to: ``$($prod.referenceIntakeRoot)/$Ident/`` (reference-only).

## Target mounted paths

``````text
$wPath
$vmPath
$vmdlPath
``````

## Next editor steps

1. Import own FBX → ``models/lifepunch/$Ident/w_$Ident/source/``
2. Build ``w_$Ident.vmdl`` + materials (see MODEL_BUILD.md)
3. Clone ``$classW`` / ``$classVm`` prefab wiring in editor → save as w_/vm_ prefabs here
4. Tune 3rd-person grip vs class reference
5. Ship VM as **clean class placeholder** until FP rig bind (``$classVm``)

See ``Code/Addons/lifepunch/$Ident/docs/WEAPON_BUILD.md``.
"@

Write-IfMissing (Join-Path $assetsRoot 'README.md') $assetsReadme | Out-Null
foreach ($d in $dirs) {
    $gk = Join-Path $d '.gitkeep'
    if (-not (Test-Path -LiteralPath $gk)) { Set-Content -LiteralPath $gk -Value '' }
}

$modelBuild = @"
# $title — World Model Build

## CS2 reference mesh

``$cs2`` in ``pak01_dir.vpk`` → ``weapons/models/``

## Active source (LifePunch-owned)

``````text
source/w_$Ident.fbx
``````

## Outputs

``````text
w_$Ident.vmdl
materials/${Ident}_body.vmat
``````

## Status

- [ ] CS2 glTF exported to reference intake (not in repo)
- [ ] Own FBX authored/imported
- [ ] ModelDoc compile green
- [ ] 3rd-person grip tuned vs ``$classW``
"@

Write-IfMissing (Join-Path $assetsRoot "models\lifepunch\$Ident\w_$Ident\MODEL_BUILD.md") $modelBuild | Out-Null

$materialMap = @{
    schemaVersion = 1
    ident = $Ident
    materials = @(
        @{
            slot = 'body'
            vmat = "materials/${Ident}_body.vmat"
            textures = @{
                baseColor = "textures/${Ident}_BaseColor.png"
                normal = "textures/${Ident}_Normal.png"
                roughness = "textures/${Ident}_Roughness.png"
                metalness = "textures/${Ident}_Metalness.png"
            }
        }
    )
} | ConvertTo-Json -Depth 6

Write-IfMissing (Join-Path $assetsRoot "models\lifepunch\$Ident\w_$Ident\material-map.json") $materialMap | Out-Null

# --- Code tree ---
New-Dir $codeRoot
New-Dir (Join-Path $codeRoot 'docs')

$weaponCs = @"
${header}namespace $ns;

public static class $pascal
{
	public const string Package = "$sboxId";
	public const string Ident = "$Ident";
	public const string DisplayName = "$label";
	public const string Grouping = "Secondary";
	public const string WeaponClass = "$class";
	public const string DxrpClassReference = "$classRef";

	public const string WorldPrefabPath = "$wPath";
	public const string ViewModelPrefabPath = "$vmPath";
	public const string WorldModelPath = "$vmdlPath";
	public const string ClassWorldPrefabPlaceholder = "$classW";
	public const string ClassViewModelPlaceholder = "$classVm";

	public static ${pascal}WeaponStats Stats { get; } = new()
	{
		Damage = 0,
		RoundsPerMinute = 0,
		MagazineSize = 0,
		ReserveAmmo = 0,
		ReloadSeconds = 0f,
		RangeMeters = 0,
		SpreadDegrees = 0f,
		RecoilPitch = 0f,
		RecoilYaw = 0f,
		Automatic = false
	};
}

public sealed class ${pascal}WeaponStats
{
	public int Damage { get; init; }
	public int RoundsPerMinute { get; init; }
	public int MagazineSize { get; init; }
	public int ReserveAmmo { get; init; }
	public float ReloadSeconds { get; init; }
	public int RangeMeters { get; init; }
	public float SpreadDegrees { get; init; }
	public float RecoilPitch { get; init; }
	public float RecoilYaw { get; init; }
	public bool Automatic { get; init; }

	public float SecondsBetweenShots => RoundsPerMinute > 0 ? 60f / RoundsPerMinute : 0f;
}
"@

$weaponComponent = @"
${header}using Sandbox;

namespace $ns;

/// <summary>Runtime weapon state stub — tune stats in $pascal.cs, wire prefab Functions in editor.</summary>
public sealed class ${pascal}Weapon : Component
{
	public int ClipContents { get; private set; }
	public int ReserveAmmo { get; private set; }
	public bool IsReloading { get; private set; }

	protected override void OnAwake()
	{
		base.OnAwake();
		ResetAmmo();
	}

	public void ResetAmmo()
	{
		ClipContents = $pascal.Stats.MagazineSize;
		ReserveAmmo = $pascal.Stats.ReserveAmmo;
		IsReloading = false;
	}
}
"@

Write-Utf8File (Join-Path $codeRoot "$pascal.cs") $weaponCs
Write-Utf8File (Join-Path $codeRoot "${pascal}Weapon.cs") $weaponComponent

$sourceIntake = @"
# $title — Source Intake

## CS2 reference (reference-only)

| Item | Value |
|------|-------|
| VPK path | ``weapons/models/`` |
| Mesh | ``$cs2`` |
| Intake folder | ``$($prod.referenceIntakeRoot)/$Ident/`` |

Classify all CS2 exports: **reference-only** — never ship in LifePunch addons.

## DXRP class kit

| Field | Value |
|-------|-------|
| Class | $class |
| Reference weapon | $classRef |
| World placeholder | ``$classW`` |
| Viewmodel placeholder | ``$classVm`` |

## LifePunch paths

See ``$pascal.cs`` constants and ``Assets/addons/lifepunch/$Ident/README.md``.
"@

$weaponBuild = @"
# $title — Build Checklist

Copy AK golden-kit workflow. Class = **$class** / **$classRef**.

- [ ] CS2 glTF → Blender study → own ``w_$Ident.fbx``
- [ ] ``w_$Ident.vmdl`` + materials
- [ ] ``w_$Ident.prefab`` cloned from ``$classW`` (Equipment + Functions)
- [ ] ``vm_$Ident.prefab`` OR placeholder ``$classVm`` for FP
- [ ] Sounds under ``sounds/`` (own or licensed)
- [ ] Tune ``$pascal.Stats`` from class reference
- [ ] ``addons.json`` content row + portal Equipment + Gun Dealer shipment (Qty 5)
- [ ] ``prepare-publish.ps1 -Addon $Ident``

## Portal

Create DXRP addon package on portal → set ``dxrpAddonId`` in ``addons.json``.
"@

Write-IfMissing (Join-Path $codeRoot 'docs\SOURCE_INTAKE.md') $sourceIntake | Out-Null
Set-Content -LiteralPath (Join-Path $codeRoot 'docs\WEAPON_BUILD.md') -Value $weaponBuild -Encoding UTF8

# --- Manifest merge (text splice; preserves addons.json formatting) ---
$manifestRaw = [System.IO.File]::ReadAllText( $ManifestPath, $utf8 )
$identPattern = '"ident"\s*:\s*"' + [regex]::Escape( $Ident ) + '"'
if ($manifestRaw -match $identPattern) {
    Write-Host "Manifest entry exists for ${Ident} - left unchanged." -ForegroundColor Yellow
} else {
    $entryBlock = @"
,
    {
      "ident": "$Ident",
      "title": "$title",
      "kind": "weapon",
      "hasAssets": true,
      "hasCode": true,
      "dxrpAddonId": "",
      "sboxIdentifier": "$sboxId",
      "status": "foundation-scaffold",
      "weaponClass": "$class",
      "dxrpClassReference": "$classRef",
      "cs2ReferenceMesh": "$cs2",
      "notes": "Mass-production scaffold. Portal package TBD. Clone $classRef kit; CS2 $cs2 reference-only.",
      "contents": []
    }
"@
    if ($manifestRaw -notmatch '(\r?\n  \]\r?\n\}\s*)$') { throw 'addons.json end pattern not found' }
    $manifestRaw = [regex]::Replace( $manifestRaw, '(\r?\n  \]\r?\n\}\s*)$', "$entryBlock`$1", 1 )
    [System.IO.File]::WriteAllText( $ManifestPath, $manifestRaw, $utf8 )
    Write-Host "Added addons.json entry: ${Ident} [foundation-scaffold]" -ForegroundColor Green
}

# --- Reference intake folder ---
$intake = Join-Path $prod.referenceIntakeRoot $Ident
New-Dir $intake
Write-IfMissing (Join-Path $intake 'README.txt') "CS2 reference exports for $title ($cs2). reference-only - not for repo commit.`n" | Out-Null

Write-Host ''
Write-Host "Scaffold OK: ${Ident} ($title) - class $class / $classRef" -ForegroundColor Cyan
Write-Host "  Assets: $assetsRoot"
Write-Host "  Code:   $codeRoot"
Write-Host "  Intake: $intake"
