# Moves superseded Ophion / duplicate hub assets into _archive/ (repo only — run Sync after).
# Safe to re-run: skips paths that are already archived.

param(
    [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'
$repoRoot = Join-Path $PSScriptRoot '..'
$hubModel = Join-Path $repoRoot 'Assets/addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/bitcoin-miner'
$hubEntityTex = Join-Path $repoRoot 'Assets/addons/lifepunch/bitcoinmining/entities/bitcoinminer/textures'

function Move-ToArchive {
    param(
        [string]$Source,
        [string]$ArchiveRoot,
        [string]$RelativeDest
    )
    if (-not (Test-Path -LiteralPath $Source)) { return }
    $dest = Join-Path $ArchiveRoot $RelativeDest
    $destDir = Split-Path -Parent $dest
    if (-not (Test-Path -LiteralPath $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    if ($WhatIf) {
        Write-Host "[WhatIf] $Source -> $dest"
        return
    }
    if (Test-Path -LiteralPath $dest) {
        Remove-Item -LiteralPath $dest -Recurse -Force
    }
    Move-Item -LiteralPath $Source -Destination $dest -Force
    Write-Host "Archived: $RelativeDest"
}

$modelArchive = Join-Path $hubModel '_archive'
$entityArchive = Join-Path $hubEntityTex '_archive'

# --- Model folder: Ophion mesh, duplicate source textures, legacy vmats, dev orphan ---
Move-ToArchive -Source (Join-Path $hubModel 'source/Ophion.fbx') -ArchiveRoot $modelArchive -RelativeDest 'ophion-era/Ophion.fbx'
Move-ToArchive -Source (Join-Path $hubModel 'source/textures') -ArchiveRoot $modelArchive -RelativeDest 'source-textures-mirror'
Move-ToArchive -Source (Join-Path $hubModel 'bitcoin-miner-mcp-test.vmdl_c') -ArchiveRoot $modelArchive -RelativeDest 'dev/bitcoin-miner-mcp-test.vmdl_c'

$legacyVmats = @(
    'bitcoin-miner-acrylic.vmat', 'bitcoin-miner-acrylic.vmat_c',
    'bitcoin-miner-chassis.vmat', 'bitcoin-miner-chassis.vmat_c',
    'bitcoin-miner-gpu.vmat', 'bitcoin-miner-gpu.vmat_c',
    'bitcoin-miner-led.vmat', 'bitcoin-miner-led.vmat_c',
    'bitcoin-miner-metal009.vmat', 'bitcoin-miner-metal009.vmat_c',
    'bitcoin-miner-motherboard.vmat', 'bitcoin-miner-motherboard.vmat_c',
    'bitcoin-miner-plate.vmat', 'bitcoin-miner-plate.vmat_c',
    'bitcoin-miner-psu.vmat', 'bitcoin-miner-psu.vmat_c',
    'bitcoin-miner-wire.vmat', 'bitcoin-miner-wire.vmat_c'
)
foreach ($name in $legacyVmats) {
    Move-ToArchive -Source (Join-Path $hubModel "materials/$name") -ArchiveRoot $modelArchive -RelativeDest "materials-ophion/$name"
}

# --- Entity textures: keep only sm_* PNG set used by active vmats ---
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

if (Test-Path -LiteralPath $hubEntityTex) {
    $keepSet = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($k in $keepTextures) { [void]$keepSet.Add($k) }

    Get-ChildItem -LiteralPath $hubEntityTex -File | ForEach-Object {
        if ($_.Name -eq 'README.md') { return }
        if ($keepSet.Contains($_.Name)) { return }
        $rel = "ophion-era/$($_.Name)"
        Move-ToArchive -Source $_.FullName -ArchiveRoot $entityArchive -RelativeDest $rel
    }
}

Write-Host ''
Write-Host 'Done. Active hub files:' -ForegroundColor Green
Write-Host "  Model: $hubModel/bitcoin-miner.vmdl"
Write-Host "  Fan:   $hubModel/bitcoin-miner-fan.vmdl"
Write-Host "  Prefab: entities/bitcoinminer/bitcoin-miner.prefab"
Write-Host "  Textures (ship): entities/bitcoinminer/textures/ (18 sm_* PNG only)"
Write-Host ''
Write-Host 'Re-sync DXRP: lifepunch\scripts\Sync-LifePunchAddonsToDxrp.ps1 -Addon bitcoinmining' -ForegroundColor Cyan
