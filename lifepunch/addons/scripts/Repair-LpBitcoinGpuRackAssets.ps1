<#
.SYNOPSIS
  Clean GPU rack art from owner drop: flat textures, FBX aliases, invalidate stale _c.

.DESCRIPTION
  Owner drop (canonical):
    C:\Users\jared\OneDrive\Desktop\addon test\addons\lifepunch\lpbitcoin\gpurack

  Fixes:
  - Pull owner drop textures (incl. textures/GraphicsCard/) then flatten to paths vmats expect
  - Nested texture folders (GPURack/, GraphicsCard/, …) flattened to flat GPU_*.png at textures/
  - Removes legacy dupes, FBX/OBJ in textures/, stale generated.vtex_c
  - Ensures source/fbx/gpu-rack-stacked-anim.fbx alias for ModelDoc

.EXAMPLE
  powershell -File lifepunch\addons\scripts\Repair-LpBitcoinGpuRackAssets.ps1
  powershell -File lifepunch\addons\scripts\Repair-LpBitcoinGpuRackAssets.ps1 -SyncDxrp
#>
[CmdletBinding()]
param(
    [switch] $SyncDxrp,
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'LifePunch-AddonDropPaths.ps1')

$repoRack = Join-Path (Resolve-Path (Join-Path $PSScriptRoot '..')).Path 'Assets\addons\lifepunch\lpbitcoin\gpurack\assets'

$keepTextures = @(
    'Rack_AO.png', 'Rack_BaseColor.png', 'Rack_Metallic.png', 'Rack_Normal_GL.png', 'Rack_Roughness.png',
    'GPU_AO.png', 'GPU_BaseColor.png', 'GPU_Metallic.png', 'GPU_Normal_GL.png', 'GPU_Roughness.png', 'GPU_Emission.png',
    'MotherB_AO.png', 'Motherboard_BaseColor.png', 'Motherboard_Metallic.png', 'Motherboard_Normal_GL.png', 'Motherboard_Roughness.png',
    'PSU_AO.png', 'PSU_BaseColor.png', 'PSU_Metallic.png', 'PSU_Normal_GL.png', 'PSU_Roughness.png',
    'Wires_AO.png', 'Wires_Cord_BaseColor.png', 'Wires_Cord_Metallic.png', 'Wires_Cord_Roughness.png'
)

function Ensure-Dir([string]$Path) {
    if ($WhatIf) { return }
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
    }
}

function Flatten-GpuRackTextures([string]$TexDir) {
    if (-not (Test-Path -LiteralPath $TexDir)) { return }

    Get-ChildItem -LiteralPath $TexDir -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
        $leaf = $_.Name
        if ($keepTextures -notcontains $leaf) { return }
        $dest = Join-Path $TexDir $leaf
        if ($_.FullName -eq $dest) { return }
        if ($WhatIf) {
            Write-Host "  [WhatIf] flatten $leaf" -ForegroundColor DarkYellow
            return
        }
        Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
    }
}

function Sync-OwnerGpuRackTextures([string]$AssetsRoot) {
    $ownerTex = Join-Path (Get-LifePunchLpBitcoinArtDrop) 'gpurack\assets\textures'
    if (-not (Test-Path -LiteralPath $ownerTex)) {
        Write-Host '  owner textures drop missing — skip pull' -ForegroundColor DarkYellow
        return
    }

    $destTex = Join-Path $AssetsRoot 'textures'
    Ensure-Dir $destTex

    if ($WhatIf) {
        Write-Host "  [WhatIf] pull owner textures -> $destTex" -ForegroundColor DarkYellow
        return
    }

    & robocopy $ownerTex $destTex /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "Owner texture robocopy failed ($LASTEXITCODE) $ownerTex" }
    Write-Host '  pulled owner textures (GraphicsCard/, GPURack/, …)' -ForegroundColor Green
}

function Repair-RackRoot([string]$AssetsRoot, [string]$Label, [switch]$PullOwnerTextures) {
    if (-not (Test-Path -LiteralPath $AssetsRoot)) {
        Write-Host "Skip $Label - not found" -ForegroundColor DarkGray
        return
    }

    Write-Host "--- $Label ---" -ForegroundColor Cyan

    if ($PullOwnerTextures) {
        Sync-OwnerGpuRackTextures $AssetsRoot
    }

    $texDir = Join-Path $AssetsRoot 'textures'
    if (Test-Path -LiteralPath $texDir) {
        Flatten-GpuRackTextures $texDir

        $removed = 0
        Get-ChildItem -LiteralPath $texDir -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
            $rel = $_.FullName.Substring($texDir.Length).TrimStart('\')
            $drop = $false
            if ($rel -match '\\') { $drop = $true }
            elseif ($_.Extension -in @('.jpeg', '.jpg', '.fbx', '.obj', '.blend')) { $drop = $true }
            elseif ($_.Name -like '*generated.vtex*') { $drop = $true }
            elseif ($_.Name -like '*.generated.vtex') { $drop = $true }
            elseif ($_.Name -like '*.vtex_c') { $drop = $true }
            elseif ($_.Name -like '*_png_*.generated.vtex*') { $drop = $true }
            elseif ($keepTextures -notcontains $_.Name) { $drop = $true }

            if (-not $drop) { return }

            if ($WhatIf) {
                Write-Host "  [WhatIf] remove $rel" -ForegroundColor DarkYellow
                return
            }
            Remove-Item -LiteralPath $_.FullName -Force
            $removed++
        }

        Get-ChildItem -LiteralPath $texDir -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            if ($WhatIf) {
                Write-Host "  [WhatIf] rmdir $($_.Name)" -ForegroundColor DarkGray
                return
            }
            Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
        }

        Write-Host "  textures cleaned ($removed stale files removed; flat sm-style layout)" -ForegroundColor Green
    }

    $fbxDir = Join-Path $AssetsRoot 'source\fbx'
    $objDir = Join-Path $AssetsRoot 'source\obj'
    Ensure-Dir $fbxDir
    Ensure-Dir $objDir

    $stackedShip = Join-Path $fbxDir 'gpu-rack-stacked-anim.fbx'
    $stackedCandidates = @(
        (Join-Path $fbxDir 'GPUFarmStackedAnim.fbx')
        (Join-Path $fbxDir 'GPU_Farm_Stacked_Anim.fbx')
        (Join-Path $AssetsRoot 'source\GPUFarmStackedAnim.fbx')
        (Join-Path $AssetsRoot 'source\GPU_Farm_Stacked_Anim.fbx')
        (Join-Path (Get-LifePunchLpBitcoinArtDrop) 'gpurack\assets\source\GPUFarmStackedAnim.fbx')
        (Join-Path (Get-LifePunchLpBitcoinArtDrop) 'gpurack\assets\source\GPU_Farm_Stacked_Anim.fbx')
    ) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1

    if ($stackedCandidates -and -not $WhatIf) {
        Copy-Item -LiteralPath $stackedCandidates -Destination $stackedShip -Force
        Write-Host "  fbx -> source/fbx/gpu-rack-stacked-anim.fbx (from $(Split-Path $stackedCandidates -Leaf))" -ForegroundColor Green
    }

    $animShip = Join-Path $fbxDir 'gpu-rack-anim.fbx'
    $animCandidates = @(
        (Join-Path $fbxDir 'GPUFarmAnim.fbx')
        (Join-Path $fbxDir 'GPU_Farm_Anim.fbx')
        (Join-Path $AssetsRoot 'source\GPUFarmAnim.fbx')
        (Join-Path $AssetsRoot 'source\GPU_Farm_Anim.fbx')
        (Join-Path (Get-LifePunchLpBitcoinArtDrop) 'gpurack\assets\source\GPUFarmAnim.fbx')
        (Join-Path (Get-LifePunchLpBitcoinArtDrop) 'gpurack\assets\source\GPU_Farm_Anim.fbx')
    ) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1

    if ($animCandidates -and -not $WhatIf) {
        Copy-Item -LiteralPath $animCandidates -Destination $animShip -Force
        Write-Host "  fbx -> source/fbx/gpu-rack-anim.fbx (from $(Split-Path $animCandidates -Leaf))" -ForegroundColor Green
    }

    $objShip = Join-Path $objDir 'gpu-farm-static.obj'
    $objCandidates = @(
        (Join-Path $objDir 'GPUFarmStatic.obj')
        (Join-Path $objDir 'GPU_Farm_Static.obj')
        (Join-Path $AssetsRoot 'source\GPUFarmStatic.obj')
        (Join-Path $AssetsRoot 'source\GPU_Farm_Static.obj')
        (Join-Path (Get-LifePunchLpBitcoinArtDrop) 'gpurack\assets\source\GPUFarmStatic.obj')
        (Join-Path (Get-LifePunchLpBitcoinArtDrop) 'gpurack\assets\source\GPU_Farm_Static.obj')
    ) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1

    if ($objCandidates -and -not $WhatIf) {
        Copy-Item -LiteralPath $objCandidates -Destination $objShip -Force
        Write-Host "  obj -> source/obj/gpu-farm-static.obj (from $(Split-Path $objCandidates -Leaf))" -ForegroundColor Green
    }

    foreach ($pat in @('*.vmdl_c', '*.vmat_c', '*.prefab_c', '*.vtex_c', '*.generated.vtex')) {
        Get-ChildItem -LiteralPath $AssetsRoot -Recurse -Filter $pat -File -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -notmatch '\\_archive\\' } |
            ForEach-Object {
                if ($WhatIf) {
                    Write-Host "  [WhatIf] remove $($_.Name)" -ForegroundColor DarkGray
                    return
                }
                Remove-Item -LiteralPath $_.FullName -Force
                Write-Host "  invalidated $($_.Name)" -ForegroundColor Yellow
            }
    }
}

Write-Host 'Repair lpbitcoin GPU rack assets' -ForegroundColor Cyan
Write-Host "  Owner drop: $(Get-LifePunchLpBitcoinArtDrop)\gpurack" -ForegroundColor DarkGray

Repair-RackRoot $repoRack 'repo' -PullOwnerTextures

if ($SyncDxrp -and -not $WhatIf) {
    $cfg = Join-Path (Resolve-Path (Join-Path $PSScriptRoot '..\..\scripts')).Path 'dxrp-editor.local.json'
    if (Test-Path -LiteralPath $cfg) {
        $dxrp = (Get-Content $cfg -Raw | ConvertFrom-Json).projectPath
        $dxrpRack = Join-Path (Split-Path $dxrp -Parent) 'Assets\addons\lifepunch\lpbitcoin\gpurack\assets'
        Repair-RackRoot $dxrpRack 'DXRP' -PullOwnerTextures:$false

        $overlays = @(
            @{ Src = Join-Path $repoRack 'models'; Dst = Join-Path $dxrpRack 'models' }
            @{ Src = Join-Path $repoRack 'entities'; Dst = Join-Path $dxrpRack 'entities' }
            @{ Src = Join-Path $repoRack 'textures'; Dst = Join-Path $dxrpRack 'textures' }
            @{ Src = Join-Path $repoRack 'source\fbx'; Dst = Join-Path $dxrpRack 'source\fbx' }
            @{ Src = Join-Path $repoRack 'source\obj'; Dst = Join-Path $dxrpRack 'source\obj' }
        )
        foreach ($o in $overlays) {
            if (-not (Test-Path -LiteralPath $o.Src)) { continue }
            New-Item -ItemType Directory -Force -Path $o.Dst | Out-Null
            & robocopy $o.Src $o.Dst /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
            if ($LASTEXITCODE -ge 8) { throw "robocopy failed: $($o.Src)" }
            Write-Host "  overlay -> DXRP $(Split-Path $o.Src -Leaf)" -ForegroundColor Green
        }

        $repoAdvanced = Join-Path (Split-Path $repoRack -Parent) 'advancedgpurack\assets\entities'
        $dxrpAdvanced = Join-Path (Split-Path $dxrpRack -Parent) 'advancedgpurack\assets\entities'
        if (Test-Path -LiteralPath $repoAdvanced) {
            New-Item -ItemType Directory -Force -Path $dxrpAdvanced | Out-Null
            & robocopy $repoAdvanced $dxrpAdvanced /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
            if ($LASTEXITCODE -ge 8) { throw "robocopy failed: advancedgpurack entities" }
            Write-Host '  overlay -> DXRP advancedgpurack/entities' -ForegroundColor Green
        }
    }
}

Write-Host 'Done. Recompile in ModelDoc: gpu-rack-*.vmat → gpu-rack.vmdl → gpu-rack-stacked.vmdl → both prefabs (gpurack + advancedgpurack).' -ForegroundColor Green
