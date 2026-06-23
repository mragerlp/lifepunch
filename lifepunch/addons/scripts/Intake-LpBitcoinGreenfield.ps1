<#
.SYNOPSIS
  Intake owner lpbitcoin art (hub + terminal + rack) into repo staging.

.DESCRIPTION
  Canonical owner drop (Jun 2026):
    %USERPROFILE%\OneDrive\Desktop\addon test\addons\lifepunch\lpbitcoin\

  Repo ships FBX + textures (.blend copies to source/blend/ for local ModelDoc; gitignored).

.EXAMPLE
  powershell -File lifepunch\addons\scripts\Intake-LpBitcoinGreenfield.ps1
  powershell -File lifepunch\addons\scripts\Intake-LpBitcoinGreenfield.ps1 -SyncDxrp
  powershell -File lifepunch\addons\scripts\Intake-LpBitcoinGreenfield.ps1 -Entity bitcoinhub
#>
[CmdletBinding()]
param(
    [string] $SourceRoot = '',
    [ValidateSet('all', 'bitcoinhub', 'hashdterminal', 'gpurack')]
    [string] $Entity = 'all',
    [switch] $SyncDxrp,
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'LifePunch-AddonDropPaths.ps1')

if (-not $SourceRoot) {
    $SourceRoot = Get-LifePunchLpBitcoinArtDrop
}

$AddonsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$LpBitcoinRoot = Join-Path $AddonsRoot 'Assets\addons\lifepunch\lpbitcoin'

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        if ($WhatIf) { Write-Host "[WhatIf] mkdir $Path" }
        else { New-Item -ItemType Directory -Force -Path $Path | Out-Null }
    }
}

function Copy-First([string[]]$Candidates, [string]$Destination, [string]$Label) {
    $src = $Candidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
    if (-not $src) { return $false }
    if ($WhatIf) {
        Write-Host "[WhatIf] $Label <- $src" -ForegroundColor Yellow
        return $true
    }
    Ensure-Dir (Split-Path -Parent $Destination)
    Copy-Item -LiteralPath $src -Destination $Destination -Force
    Write-Host "  $Label" -ForegroundColor Green
    return $true
}

function Sync-Textures([string]$From, [string]$To, [switch]$Flatten) {
    if (-not (Test-Path -LiteralPath $From)) { return }
    if ($WhatIf) {
        Write-Host "[WhatIf] textures -> $To" -ForegroundColor Yellow
        return
    }
    Ensure-Dir $To
    & robocopy $From $To /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "Texture robocopy failed ($LASTEXITCODE) $From -> $To" }
    if ($Flatten) {
        Get-ChildItem -LiteralPath $From -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
            Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $To $_.Name) -Force
        }
    }
    Write-Host "  textures -> $To" -ForegroundColor Green
}

function Remove-Stale([string[]]$Paths) {
    foreach ($p in $Paths) {
        if (-not (Test-Path -LiteralPath $p)) { continue }
        if ($WhatIf) {
            Write-Host "[WhatIf] remove stale $p" -ForegroundColor DarkYellow
            continue
        }
        Remove-Item -LiteralPath $p -Force -Recurse -ErrorAction SilentlyContinue
        Write-Host "  removed stale $(Split-Path $p -Leaf)" -ForegroundColor DarkGray
    }
}

if (-not (Test-Path -LiteralPath $SourceRoot)) {
    throw @"
Missing lpbitcoin art drop: $SourceRoot

Owner canonical path:
  %USERPROFILE%\OneDrive\Desktop\addon test\addons\lifepunch\lpbitcoin\
"@
}

Write-Host 'LpBitcoin greenfield intake' -ForegroundColor Cyan
Write-Host "  From: $SourceRoot" -ForegroundColor DarkGray
Write-Host "  To:   $LpBitcoinRoot" -ForegroundColor DarkGray

$runHub = $Entity -eq 'all' -or $Entity -eq 'bitcoinhub'
$runTerminal = $Entity -eq 'all' -or $Entity -eq 'hashdterminal'
$runRack = $Entity -eq 'all' -or $Entity -eq 'gpurack'

if ($runHub) {
    Write-Host '--- bitcoinhub ---' -ForegroundColor Cyan
    $drop = Join-Path $SourceRoot 'bitcoinhub\assets'
    $dest = Join-Path $LpBitcoinRoot 'bitcoinhub\assets'
    Ensure-Dir (Join-Path $dest 'source\fbx')
    Ensure-Dir (Join-Path $dest 'source\blend')

    Copy-First @(
        (Join-Path $drop 'source\bitcoinhub.blend')
        (Join-Path $drop 'source\bitcoinminer.blend')
    ) (Join-Path $dest 'source\blend\bitcoinhub.blend') 'blend -> source/blend/bitcoinhub.blend' | Out-Null

    $fbxOk = Copy-First @(
        (Join-Path $drop 'source\bitcoinhub.fbx')
        (Join-Path $drop 'source\steam-machine.fbx')
    ) (Join-Path $dest 'source\fbx\bitcoinhub.fbx') 'fbx -> source/fbx/bitcoinhub.fbx'

    if ($fbxOk -and -not $WhatIf) {
        Copy-Item -LiteralPath (Join-Path $dest 'source\fbx\bitcoinhub.fbx') -Destination (Join-Path $dest 'source\fbx\steam-machine.fbx') -Force
        Write-Host '  fbx alias -> source/fbx/steam-machine.fbx (vmdl path)' -ForegroundColor Green
    }

    Copy-First @(
        (Join-Path $drop 'source\steam-machine-fan.fbx')
    ) (Join-Path $dest 'source\fbx\steam-machine-fan.fbx') 'fan fbx -> source/fbx/steam-machine-fan.fbx' | Out-Null

    Sync-Textures (Join-Path $drop 'textures') (Join-Path $dest 'textures')
}

if ($runTerminal) {
    Write-Host '--- hashdterminal ---' -ForegroundColor Cyan
    $drop = Join-Path $SourceRoot 'hashdterminal\assets'
    $dest = Join-Path $LpBitcoinRoot 'hashdterminal\assets'
    Ensure-Dir (Join-Path $dest 'source\fbx')
    Ensure-Dir (Join-Path $dest 'source\blend')

    Copy-First @(
        (Join-Path $drop 'source\HASHDTerminal.blend')
        (Join-Path $drop 'source\PC.blend')
    ) (Join-Path $dest 'source\blend\hashd-terminal.blend') 'blend -> source/blend/hashd-terminal.blend' | Out-Null

    $fbxOk = Copy-First @(
        (Join-Path $drop 'source\HASHDTerminal.fbx')
        (Join-Path $drop 'source\PC.fbx')
    ) (Join-Path $dest 'source\fbx\hashd-terminal.fbx') 'fbx -> source/fbx/hashd-terminal.fbx'

    Remove-Stale @(
        (Join-Path $dest 'source\PC.blend')
        (Join-Path $dest 'source\PC.fbx')
    )

    if ($fbxOk -and -not $WhatIf) {
        Copy-Item -LiteralPath (Join-Path $dest 'source\fbx\hashd-terminal.fbx') -Destination (Join-Path $dest 'source\fbx\pc.fbx') -Force
        Write-Host '  fbx alias -> source/fbx/pc.fbx (vmdl path)' -ForegroundColor Green
    }

    Sync-Textures (Join-Path $drop 'textures') (Join-Path $dest 'textures')
}

if ($runRack) {
    Write-Host '--- gpurack ---' -ForegroundColor Cyan
    $drop = Join-Path $SourceRoot 'gpurack\assets'
    $dest = Join-Path $LpBitcoinRoot 'gpurack\assets'
    Ensure-Dir (Join-Path $dest 'source\fbx')
    Ensure-Dir (Join-Path $dest 'source\blend')
    Ensure-Dir (Join-Path $dest 'source\obj')

    Copy-First @(
        (Join-Path $drop 'source\GPUFarm.blend')
        (Join-Path $drop 'source\gpu_crypto_farm.blend')
    ) (Join-Path $dest 'source\blend\gpu-farm.blend') 'blend -> source/blend/gpu-farm.blend' | Out-Null

    Copy-First @(
        (Join-Path $drop 'source\GPUFarmAnim.fbx')
        (Join-Path $drop 'source\GPU_Farm_Anim.fbx')
    ) (Join-Path $dest 'source\fbx\gpu-rack-anim.fbx') 'fbx -> source/fbx/gpu-rack-anim.fbx' | Out-Null

    Copy-First @(
        (Join-Path $drop 'source\GPUFarmStackedAnim.fbx')
        (Join-Path $drop 'source\GPU_Farm_Stacked_Anim.fbx')
    ) (Join-Path $dest 'source\fbx\gpu-rack-stacked-anim.fbx') 'fbx -> source/fbx/gpu-rack-stacked-anim.fbx' | Out-Null

    Copy-First @(
        (Join-Path $drop 'source\GPUFarmStatic.obj')
        (Join-Path $drop 'source\GPU_Farm_Static.obj')
    ) (Join-Path $dest 'source\obj\gpu-farm-static.obj') 'obj -> source/obj/gpu-farm-static.obj' | Out-Null

    Sync-Textures (Join-Path $drop 'textures') (Join-Path $dest 'textures') -Flatten

    Remove-Stale @(
        (Join-Path $dest 'source\gpu_crypto_farm.blend')
        (Join-Path $dest 'source\GPU_Farm_Anim.fbx')
        (Join-Path $dest 'source\GPU_Farm_Stacked_Anim.fbx')
        (Join-Path $dest 'source\GPU_Farm_Static.obj')
        (Join-Path $dest 'source\obj\GPU_Farm_Static.obj')
    )
}

if ($SyncDxrp -and -not $WhatIf) {
    $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $prep = Join-Path $repoRoot 'scripts\Prepare-LpBitcoinModelDoc.ps1'
    $entities = @()
    if ($runHub) { $entities += 'bitcoinhub' }
    if ($runTerminal) { $entities += 'hashdterminal' }
    if ($runRack) { $entities += 'gpurack' }
    foreach ($e in $entities) {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $prep -Entity $e
    }
    $sync = Join-Path $repoRoot 'scripts\Sync-LifePunchAddonsToDxrp.ps1'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $sync -Addon bitcoinmining
}

Write-Host 'Intake OK — owner drop is canonical; repo FBX/textures committed, blends gitignored.' -ForegroundColor Green
