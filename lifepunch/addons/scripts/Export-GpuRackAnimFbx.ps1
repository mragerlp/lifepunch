<#
.SYNOPSIS
  Rig gpu-rack anim FBX with armature + fan spin actions for ModelDoc animated_model.

.DESCRIPTION
  Re-exports source/gpu-rack-anim.fbx and gpu-rack-stacked-anim.fbx with bones so
  power_on / GPU_Farm_Final / Mining_Rig_Stacked compile in s&box.

.EXAMPLE
  powershell -File lifepunch\addons\scripts\Export-GpuRackAnimFbx.ps1
#>
[CmdletBinding()]
param(
    [string] $BlenderExe = "${env:ProgramFiles}\Blender Foundation\Blender 5.1\blender.exe",
    [string] $GpuRackSource = "",
    [switch] $UpdateVmdl,
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$AddonsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$ModelSource = Join-Path $AddonsRoot 'Assets\addons\lifepunch\bitcoinmining\models\lifepunch\bitcoinmining\gpu-rack\source'
$Py = Join-Path $PSScriptRoot 'Export-GpuRackAnimFbx.py'

$SingleIn = if ($GpuRackSource) { $GpuRackSource } else { Join-Path $ModelSource 'gpu-rack-anim.fbx' }
$StackedIn = Join-Path $ModelSource 'gpu-rack-stacked-anim.fbx'
$SingleOut = Join-Path $ModelSource 'gpu-rack-anim-rigged.fbx'
$StackedOut = Join-Path $ModelSource 'gpu-rack-stacked-anim-rigged.fbx'

if (-not (Test-Path -LiteralPath $SingleIn)) {
    throw "Missing single-rack FBX: $SingleIn"
}

if (-not (Test-Path -LiteralPath $BlenderExe)) {
    $found = Get-ChildItem "${env:ProgramFiles}\Blender Foundation" -Recurse -Filter blender.exe -ErrorAction SilentlyContinue |
        Select-Object -First 1 -ExpandProperty FullName
    if ($found) { $BlenderExe = $found }
    else { throw "Blender not found. Install BlenderFoundation.Blender or pass -BlenderExe." }
}

function Invoke-RigExport([string] $In, [string] $Out, [switch] $Stacked) {
    $stackedArg = if ($Stacked) { 'stacked' } else { '' }
    Write-Host "Rig export: $In -> $Out $(if ($Stacked) { '(stacked)' })" -ForegroundColor Cyan
    if ($WhatIf) {
        Write-Host "[WhatIf] $BlenderExe --background --python $Py -- $In $Out $stackedArg"
        return
    }
    & $BlenderExe --background --python $Py -- $In $Out $stackedArg
    if ($LASTEXITCODE -ne 0) { throw "Blender export failed ($LASTEXITCODE) for $In" }
    if (-not (Test-Path -LiteralPath $Out)) { throw "FBX not written: $Out" }
    Write-Host "  OK: $Out" -ForegroundColor Green
}

Invoke-RigExport -In $SingleIn -Out $SingleOut
if (Test-Path -LiteralPath $StackedIn) {
    Invoke-RigExport -In $StackedIn -Out $StackedOut -Stacked
}

Write-Host ''
Write-Host 'Next: run with -UpdateVmdl to point gpurack.vmdl / advancedgpurack.vmdl at *-rigged.fbx, then compile in ModelDoc + Pull-DxrpCompiledAssetsToRepo -Addon lpbitcoin.' -ForegroundColor Yellow

if (-not $WhatIf -and $UpdateVmdl) {
    $modelDir = Join-Path $AddonsRoot 'Assets\addons\lifepunch\lpbitcoin\gpurack\assets\models'
    $vmdlSingle = Join-Path $modelDir 'gpurack.vmdl'
    $vmdlStacked = Join-Path $modelDir 'advancedgpurack.vmdl'
    foreach ($pair in @(
            @{ Vmdl = $vmdlSingle; From = 'gpu-rack-anim.fbx'; To = 'gpu-rack-anim-rigged.fbx' },
            @{ Vmdl = $vmdlStacked; From = 'gpu-rack-stacked-anim.fbx'; To = 'gpu-rack-stacked-anim-rigged.fbx' }
        )) {
        if (-not (Test-Path -LiteralPath $pair.Vmdl)) { continue }
        $text = Get-Content -LiteralPath $pair.Vmdl -Raw
        $updated = $text.Replace($pair.From, $pair.To)
        if ($updated -ne $text) {
            Set-Content -LiteralPath $pair.Vmdl -Value $updated -NoNewline
            Write-Host "Updated vmdl paths: $($pair.Vmdl)" -ForegroundColor Green
        }
    }
}
