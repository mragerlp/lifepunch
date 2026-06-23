<#
.SYNOPSIS
  Fresh GPU rack art: wipe derived repo + DXRP art, re-intake from owner drop, repair, sync.

.DESCRIPTION
  Owner drop (canonical raw Fab — do not flatten here):
    %USERPROFILE%\OneDrive\Desktop\addon test\addons\lifepunch\lpbitcoin\gpurack

  Keeps ship scaffolding in repo:
    assets/models/*   (gpu-rack.vmdl, vmats, material-map.json, MODEL_BUILD.md)
    assets/entities/gpu-rack.prefab

  Wipes and rebuilds from owner drop:
    assets/textures/   (flat 25 PNGs for vmats)
    assets/source/fbx/ assets/source/obj/

.EXAMPLE
  powershell -File lifepunch\addons\scripts\Reset-LpBitcoinGpuRackFromOwnerDrop.ps1
  powershell -File lifepunch\addons\scripts\Reset-LpBitcoinGpuRackFromOwnerDrop.ps1 -SyncDxrp -Recompile
#>
[CmdletBinding()]
param(
    [switch] $SyncDxrp,
    [switch] $Recompile,
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'LifePunch-AddonDropPaths.ps1')

$ownerDrop = Join-Path (Get-LifePunchLpBitcoinArtDrop) 'gpurack'
if (-not (Test-Path -LiteralPath $ownerDrop)) {
    throw "Owner drop missing: $ownerDrop"
}

$repoRackAssets = Join-Path (Resolve-Path (Join-Path $PSScriptRoot '..')).Path 'Assets\addons\lifepunch\lpbitcoin\gpurack\assets'

function Clear-DirContents([string]$Path, [string]$Label) {
    if (-not (Test-Path -LiteralPath $Path)) { return }
    Write-Host "  wipe $Label" -ForegroundColor Yellow
    if ($WhatIf) {
        Get-ChildItem -LiteralPath $Path -Force -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Host "    [WhatIf] remove $($_.Name)" -ForegroundColor DarkGray
        }
        return
    }
    Get-ChildItem -LiteralPath $Path -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host 'Reset lpbitcoin GPU rack from owner drop' -ForegroundColor Cyan
Write-Host "  Owner: $ownerDrop" -ForegroundColor DarkGray
Write-Host "  Repo:  $repoRackAssets" -ForegroundColor DarkGray

Write-Host '--- wipe repo derived art ---' -ForegroundColor Cyan
Clear-DirContents (Join-Path $repoRackAssets 'textures') 'textures'
Clear-DirContents (Join-Path $repoRackAssets 'source\fbx') 'source/fbx'
Clear-DirContents (Join-Path $repoRackAssets 'source\obj') 'source/obj'

if (-not $WhatIf) {
    Write-Host '--- intake owner -> repo ---' -ForegroundColor Cyan
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'Intake-LpBitcoinGreenfield.ps1') -Entity gpurack
    Write-Host '--- repair repo ---' -ForegroundColor Cyan
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'Repair-LpBitcoinGpuRackAssets.ps1')
}

if ($SyncDxrp -and -not $WhatIf) {
    $cfg = Join-Path (Resolve-Path (Join-Path $PSScriptRoot '..\..\scripts')).Path 'dxrp-editor.local.json'
    if (-not (Test-Path -LiteralPath $cfg)) { throw "Missing $cfg" }
    $dxrp = (Get-Content $cfg -Raw | ConvertFrom-Json).projectPath
    $dxrpRackAssets = Join-Path (Split-Path $dxrp -Parent) 'Assets\addons\lifepunch\lpbitcoin\gpurack\assets'

    Write-Host '--- wipe DXRP derived art ---' -ForegroundColor Cyan
    Clear-DirContents (Join-Path $dxrpRackAssets 'textures') 'DXRP textures'
    Clear-DirContents (Join-Path $dxrpRackAssets 'source\fbx') 'DXRP source/fbx'
    Clear-DirContents (Join-Path $dxrpRackAssets 'source\obj') 'DXRP source/obj'

    Get-ChildItem -LiteralPath $dxrpRackAssets -Recurse -Include '*.vmdl_c','*.vmat_c','*.prefab_c','*.vtex_c','*.generated.vtex' -File -ErrorAction SilentlyContinue |
        ForEach-Object { Remove-Item -LiteralPath $_.FullName -Force }

    Write-Host '--- repair + overlay repo -> DXRP ---' -ForegroundColor Cyan
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'Repair-LpBitcoinGpuRackAssets.ps1') -SyncDxrp
}

Write-Host @'

Fresh layout (repo + DXRP after sync):
  owner drop     = raw Fab (nested textures, GPU_Farm_*.fbx) — edit here only
  repo textures  = 25 flat PNGs + vmats + gpu-rack.vmdl + prefab
  ship mesh      = source/fbx/gpu-rack-anim.fbx  (single rack)
  stacked        = parked — source/fbx/gpu-rack-stacked-anim.fbx (BITCOINMINING-07)

Next: Stop play -> recompile vmats -> gpu-rack.vmdl -> prefab -> Play -> lp_spawn_gpu_rack
'@ -ForegroundColor Green
