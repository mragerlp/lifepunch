<#
.SYNOPSIS
  Clean Steam Machine hub art: sm_* textures only, correct FBX path, static body vmdl.

.DESCRIPTION
  Fixes the common owner-lane breakage:
  - vmats point at sm_* BaseColor.png but drop still has .jpeg + Ophion sc_* textures
  - vmdl imports source/fbx/steam-machine.fbx but drop ships source/bitcoinhub.fbx flat
  - stale *_generated.vtex_c from old bakes

  Does NOT add a separate fan vmdl — fan stays static in bitcoinhub.vmdl when present in FBX.

.EXAMPLE
  powershell -File lifepunch\addons\scripts\Repair-BitcoinHubSteamMachineAssets.ps1
  powershell -File lifepunch\addons\scripts\Repair-BitcoinHubSteamMachineAssets.ps1 -SyncDxrp
#>
[CmdletBinding()]
param(
    [switch] $SyncDxrp,
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$repoHub = Join-Path (Resolve-Path (Join-Path $PSScriptRoot '..')).Path 'Assets\addons\lifepunch\lpbitcoin\bitcoinhub\assets'

$keepTextures = @(
    'sm_body_mat_BaseColor.png',
    'sm_body_mat_Normal.png',
    'sm_body_mat_Metallic-sm_body_mat_Roughness@channels=G.png',
    'sm_body_mat_Metallic-sm_body_mat_Roughness@channels=B.png',
    'sm_details_one_mat_BaseColor.png',
    'sm_details_one_mat_Normal.png',
    'sm_details_one_mat_Metallic-sm_details_one_mat_Roughness@cha.png',
    'sm_details_two_mat_BaseColor.png',
    'sm_details_two_mat_Normal.png',
    'sm_details_two_mat_Metallic-sm_details_two_mat_Roughness@cha.png',
    'sm_panel_mat_BaseColor.png',
    'sm_panel_mat_Normal.png',
    'sm_panel_mat_Metallic-sm_panel_mat_Roughness@channels=G.png',
    'sm_panel_mat_Metallic-sm_panel_mat_Roughness@channels=B.png',
    'sm_fence_led_mat_BaseColor-sm_fence_led_mat_Alpha.png',
    'sm_fence_led_mat_Normal.png',
    'sm_fence_led_mat_Metallic-sm_fence_led_mat_Roughness@channel.png',
    'sm_fence_led_mat_Emissive.png'
)

function Ensure-Dir([string]$Path) {
    if ($WhatIf) { return }
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
    }
}

function Repair-HubRoot([string]$AssetsRoot, [string]$Label) {
    if (-not (Test-Path -LiteralPath $AssetsRoot)) {
        Write-Host "Skip $Label - not found" -ForegroundColor DarkGray
        return
    }

    Write-Host "--- $Label ---" -ForegroundColor Cyan

    $texDir = Join-Path $AssetsRoot 'textures'
    if (Test-Path -LiteralPath $texDir) {
        $removed = 0
        Get-ChildItem -LiteralPath $texDir -File -ErrorAction SilentlyContinue | ForEach-Object {
            $name = $_.Name
            $drop = $false
            if ($name -like 'sc_*') { $drop = $true }
            elseif ($name -like '*.jpeg') { $drop = $true }
            elseif ($name -like '*.jpg') { $drop = $true }
            elseif ($name -like '*generated.vtex*') { $drop = $true }
            elseif ($name -like '*.vtex_c') { $drop = $true }
            elseif ($keepTextures -notcontains $name -and $name -ne 'sm_logo.png') { $drop = $true }

            if (-not $drop) { return }

            if ($WhatIf) {
                Write-Host "  [WhatIf] remove texture $name" -ForegroundColor DarkYellow
                return
            }
            Remove-Item -LiteralPath $_.FullName -Force
            $removed++
        }
        Write-Host "  textures cleaned ($removed stale files removed)" -ForegroundColor Green

        foreach ($need in $keepTextures) {
            $path = Join-Path $texDir $need
            if (Test-Path -LiteralPath $path) { continue }
            $jpegAlt = $need -replace '\.png$', '.jpeg'
            $jpegPath = Join-Path $texDir $jpegAlt
            if (-not (Test-Path -LiteralPath $jpegPath)) { continue }
            if ($WhatIf) {
                Write-Host "  [WhatIf] promote $jpegAlt -> $need" -ForegroundColor DarkYellow
                continue
            }
            Copy-Item -LiteralPath $jpegPath -Destination $path -Force
            Write-Host "  promoted $jpegAlt -> $need" -ForegroundColor Yellow
        }
    }

    $fbxDir = Join-Path $AssetsRoot 'source\fbx'
    Ensure-Dir $fbxDir
    $shipFbx = Join-Path $fbxDir 'steam-machine.fbx'
    $candidates = @(
        (Join-Path $fbxDir 'bitcoinhub.fbx')
        (Join-Path $AssetsRoot 'source\bitcoinhub.fbx')
        (Join-Path $AssetsRoot 'source\steam-machine.fbx')
    ) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1

    if ($candidates -and -not $WhatIf) {
        Copy-Item -LiteralPath $candidates -Destination $shipFbx -Force
        Write-Host "  fbx -> source/fbx/steam-machine.fbx (from $(Split-Path $candidates -Leaf))" -ForegroundColor Green
    }
    elseif ($WhatIf -and $candidates) {
        Write-Host "  [WhatIf] fbx alias -> steam-machine.fbx" -ForegroundColor DarkYellow
    }
    elseif (-not (Test-Path -LiteralPath $shipFbx)) {
        Write-Host "  WARN: no FBX found under $AssetsRoot\source" -ForegroundColor Red
    }

    $fanVmdl = Join-Path $AssetsRoot 'models\bitcoinhub-fan.vmdl'
    if (Test-Path -LiteralPath $fanVmdl) {
        $archive = Join-Path (Split-Path $AssetsRoot -Parent) '_archive\phase2-fan-spin'
        Ensure-Dir $archive
        foreach ($pat in @('bitcoinhub-fan.vmdl', 'bitcoinhub-fan.vmdl_c')) {
            $src = Join-Path $AssetsRoot "models\$pat"
            if (-not (Test-Path -LiteralPath $src)) { continue }
            if ($WhatIf) {
                Write-Host "  [WhatIf] archive $pat" -ForegroundColor DarkYellow
                continue
            }
            Move-Item -LiteralPath $src -Destination (Join-Path $archive $pat) -Force
            Write-Host "  archived $pat (static hull only)" -ForegroundColor DarkGray
        }
    }

    foreach ($pat in @('*.vmdl_c', '*.vmat_c', '*.prefab_c', '*.vtex_c')) {
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

Write-Host 'Repair Bitcoin hub Steam Machine assets' -ForegroundColor Cyan
Repair-HubRoot $repoHub 'repo'

if ($SyncDxrp -and -not $WhatIf) {
    $cfg = Join-Path (Resolve-Path (Join-Path $PSScriptRoot '..\..\scripts')).Path 'dxrp-editor.local.json'
    if (Test-Path -LiteralPath $cfg) {
        $dxrp = (Get-Content $cfg -Raw | ConvertFrom-Json).projectPath
        $dxrpHub = Join-Path (Split-Path $dxrp -Parent) 'Assets\addons\lifepunch\lpbitcoin\bitcoinhub\assets'
        Repair-HubRoot $dxrpHub 'DXRP'

        $overlays = @(
            @{ Src = Join-Path $repoHub 'models'; Dst = Join-Path $dxrpHub 'models' }
            @{ Src = Join-Path $repoHub 'entities'; Dst = Join-Path $dxrpHub 'entities' }
            @{ Src = Join-Path $repoHub 'textures'; Dst = Join-Path $dxrpHub 'textures' }
            @{ Src = Join-Path $repoHub 'source\fbx'; Dst = Join-Path $dxrpHub 'source\fbx' }
        )
        foreach ($o in $overlays) {
            if (-not (Test-Path -LiteralPath $o.Src)) { continue }
            New-Item -ItemType Directory -Force -Path $o.Dst | Out-Null
            & robocopy $o.Src $o.Dst /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
            if ($LASTEXITCODE -ge 8) { throw "robocopy failed: $($o.Src)" }
            Write-Host "  overlay $($o.Src) -> DXRP" -ForegroundColor Green
        }
    }
}

Write-Host 'Done. Recompile in ModelDoc: vmats first, then bitcoinhub.vmdl.' -ForegroundColor Green
