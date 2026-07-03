<#
.SYNOPSIS
  Full Phase A hub rebuild: decimated FBX + fresh cpu-gamer.vmdl (no physics) + DXRP sync.

.EXAMPLE
  powershell -File lifepunchaddons\scripts\Rebuild-CpuGamerHubModel.ps1
  powershell -File lifepunchaddons\scripts\Rebuild-CpuGamerHubModel.ps1 -DecimateRatio 0.05
#>
[CmdletBinding()]
param(
    [double] $DecimateRatio = 0.015,
    [switch] $SkipBlender,
    [switch] $SkipMatrixRainFix,
    [switch] $RelaunchEditor
)

$ErrorActionPreference = 'Stop'
$AddonsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$HubModels = Join-Path $AddonsRoot 'Assets\addons\lifepunch\lpbitcoin\bitcoinhub\assets\models'
$VmdlPath = Join-Path $HubModels 'cpu-gamer.vmdl'
$VmdlC = "$VmdlPath`_c"

$vmdlContent = @'
<!-- kv3 encoding:text:version{e21c7f3c-8a33-41c5-9977-a76d3a32aa0d} format:modeldoc30:version{8c2d7a91-9c42-4bf0-883a-5a3b1762d4f1} -->
{
	rootNode = 
	{
		_class = "RootNode"
		children = 
		[
			{
				_class = "MaterialGroupList"
				children = 
				[
					{
						_class = "DefaultMaterialGroup"
						remaps = 
						[
						]
						use_global_default = true
						global_default_material = "addons/lifepunch/lpbitcoin/bitcoinhub/assets/models/materials/cpu-gamer-vertex.vmat"
					},
				]
			},
			{
				_class = "RenderMeshList"
				children = 
				[
					{
						_class = "RenderMeshFile"
						name = "LOD0"
						filename = "addons/lifepunch/lpbitcoin/bitcoinhub/assets/source/fbx/cpu_gamer.fbx"
						import_translation = [ 0.0, 0.0, 0.0 ]
						import_rotation = [ 0.0, 0.0, 0.0 ]
						import_scale = 1.0
						align_origin_x_type = "Center"
						align_origin_y_type = "Center"
						align_origin_z_type = "Bottom"
					},
				]
			},
		]
		model_archetype = ""
		primary_associated_entity = "prop_dynamic"
		anim_graph_name = ""
		base_model_name = ""
	}
}
'@

Write-Host '== Rebuild CPU GAMER hub (Phase A)' -ForegroundColor Cyan

if (-not $SkipBlender) {
    $export = Join-Path $PSScriptRoot 'Export-CpuGamerHubFbx.ps1'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $export -DecimateRatio $DecimateRatio
}

if (Test-Path -LiteralPath $VmdlC) {
    Remove-Item -LiteralPath $VmdlC -Force
    Write-Host '  removed stale cpu-gamer.vmdl_c' -ForegroundColor DarkYellow
}

[System.IO.File]::WriteAllText($VmdlPath, $vmdlContent.TrimEnd() + "`n")
Write-Host '  wrote fresh cpu-gamer.vmdl (no physics block — collision is Phase 1 after mesh sign-off)' -ForegroundColor Green

$prep = Join-Path (Split-Path $PSScriptRoot -Parent) '..\scripts\Prepare-LpBitcoinModelDoc.ps1'
$prep = (Resolve-Path $prep).Path
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $prep -Entity bitcoinhub

if (-not $SkipMatrixRainFix) {
    $dxrpLibs = 'D:\Steam\steamapps\common\sbox\dxrp\game\Libraries'
    $rain = Join-Path $dxrpLibs 'quack.matrix_rain'
    $disabled = Join-Path $dxrpLibs '_disabled'
    $rainOff = Join-Path $disabled 'quack.matrix_rain'
    if ((Test-Path -LiteralPath $rain) -and -not (Test-Path -LiteralPath $rainOff)) {
        New-Item -ItemType Directory -Force -Path $disabled | Out-Null
        Move-Item -LiteralPath $rain -Destination $rainOff -Force
        Write-Host '  disabled quack.matrix_rain (broken textures stall DXRP boot compile)' -ForegroundColor Yellow
    }
}

Write-Host ''
Write-Host 'Next in editor:' -ForegroundColor Cyan
Write-Host '  1. Asset browser -> addons/lifepunch/lpbitcoin/bitcoinhub/assets/models/cpu-gamer.vmdl'
Write-Host '  2. Open in ModelDoc -> Compile'
Write-Host '  3. Confirm cpu-gamer.vmdl_c appears'
Write-Host ''
Write-Host 'Not a bad model — Fab source was 1M+ verts + 97 materials. Decimated + recreated vmdl fixes compile.' -ForegroundColor DarkGray

if ($RelaunchEditor) {
    Stop-Process -Name 'sbox-dev' -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    $start = Join-Path (Split-Path $prep -Parent) 'Start-SboxDxrpEditor.ps1'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $start -NoSync -SkipPreflight -SkipConnectivityWatch
}
