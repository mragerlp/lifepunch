<#
.SYNOPSIS
  Re-export CPU GAMER hub FBX with one material slot (fixes ModelDoc import stall).

.EXAMPLE
  powershell -File lifepunchaddons\scripts\Export-CpuGamerHubFbx.ps1
  powershell -File lifepunchaddons\scripts\Export-CpuGamerHubFbx.ps1 -BlendPath "C:\Users\jared\OneDrive\Desktop\bitcoinhubpc.blend"
  powershell -File lifepunchaddons\scripts\Export-CpuGamerHubFbx.ps1 -SyncDxrp
#>
[CmdletBinding()]
param(
    [string] $BlenderExe = "${env:ProgramFiles}\Blender Foundation\Blender 5.1\blender.exe",
    [string] $BlendPath = '',
    [double] $DecimateRatio = 0.04,
    [switch] $SyncDxrp,
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$AddonsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$HubRoot = Join-Path $AddonsRoot 'Assets\addons\lifepunch\lpbitcoin\bitcoinhub\assets'
$Blend = if ($BlendPath) { (Resolve-Path -LiteralPath $BlendPath).Path } else { Join-Path $HubRoot 'source\blend\cpu_gamer.blend' }
$OutFbx = Join-Path $HubRoot 'source\fbx\cpu_gamer.fbx'
$OutTex = Join-Path $HubRoot 'textures\cpu-gamer_BaseColor.png'
New-Item -ItemType Directory -Force -Path (Split-Path $OutTex -Parent) | Out-Null
$Py = Join-Path $PSScriptRoot 'Export-CpuGamerHubFbx.py'

if (-not (Test-Path -LiteralPath $Blend)) {
    throw "Missing blend: $Blend"
}

if (-not (Test-Path -LiteralPath $BlenderExe)) {
    $found = Get-ChildItem "${env:ProgramFiles}\Blender Foundation" -Recurse -Filter blender.exe -ErrorAction SilentlyContinue |
        Select-Object -First 1 -ExpandProperty FullName
    if ($found) { $BlenderExe = $found }
    else { throw "Blender not found. Install Blender or pass -BlenderExe." }
}

if ($WhatIf) {
    Write-Host "[WhatIf] $BlenderExe --background $Blend -> $OutFbx"
    exit 0
}

Write-Host 'Export CPU GAMER hub FBX (single material)' -ForegroundColor Cyan
Write-Host "  Blend: $Blend"
Write-Host "  Out:   $OutFbx"

& $BlenderExe --background $Blend --python $Py -- $Blend $OutFbx $DecimateRatio $OutTex
if ($LASTEXITCODE -ne 0) { throw "Blender export failed ($LASTEXITCODE)" }
if (-not (Test-Path -LiteralPath $OutFbx)) { throw "FBX not written: $OutFbx" }

$sizeMb = [math]::Round((Get-Item -LiteralPath $OutFbx).Length / 1MB, 2)
Write-Host "Export OK ($sizeMb MB)" -ForegroundColor Green

if ($SyncDxrp) {
    $prep = Join-Path (Split-Path $PSScriptRoot -Parent) '..\scripts\Prepare-LpBitcoinModelDoc.ps1'
    $prep = (Resolve-Path $prep).Path
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $prep -Entity bitcoinhub
}
