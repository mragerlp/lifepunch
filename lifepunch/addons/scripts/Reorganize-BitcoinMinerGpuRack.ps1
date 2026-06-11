<#
.SYNOPSIS
  Build publish tree for Bitcoin Miner entity + gpu-rack world model.

.DESCRIPTION
  Product: Bitcoin Miner (entity prefab, sounds, code)
  World mesh: gpu-rack (single assembled rack vmdl — no underscores)

  Archives raw Blender export to reference-intake; ship tree follows AK47 w_ak47 pattern.

.EXAMPLE
  powershell -File Reorganize-BitcoinMinerGpuRack.ps1
  powershell -File Reorganize-BitcoinMinerGpuRack.ps1 -SourceRoot "C:\path\to\export"
#>
[CmdletBinding()]
param(
    [string] $SourceRoot = '',
    [string] $ArchiveRoot = 'C:\lifepunch\reference-intake\bitcoinmining\gpu-rack-export',
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$AddonsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$BitcoinRoot = Join-Path $AddonsRoot 'Assets\addons\lifepunch\bitcoinmining'
$GpuRackRoot = Join-Path $BitcoinRoot 'models\lifepunch\bitcoinmining\gpu-rack'

$legacyCandidates = @(
    (Join-Path $BitcoinRoot 'models\lifepunch\bitcoinmining\bitminer')
    (Join-Path $BitcoinRoot 'models\lifepunch\bitcoinmining\gpu_farm\source')
    (Join-Path $BitcoinRoot 'models\lifepunch\bitcoinmining\gpu_farm')
)

function Resolve-SourceRoot {
    if ($SourceRoot) { return (Resolve-Path -LiteralPath $SourceRoot).Path }
    foreach ($c in $legacyCandidates) {
        if (Test-Path -LiteralPath $c) {
            $meshes = @('GPU_Farm_Static.obj', 'gpu-rack-static.obj')
            foreach ($m in $meshes) {
                $p = Join-Path $c $m
                if (Test-Path -LiteralPath $p) { return $c }
                $p2 = Join-Path (Join-Path $c 'source') $m
                if (Test-Path -LiteralPath $p2) { return (Join-Path $c 'source') }
            }
            if ((Get-ChildItem -LiteralPath $c -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq 'textures' })) {
                return $c
            }
        }
    }
    throw 'No source. Pass -SourceRoot or restore bitminer/ / gpu_farm/source/.'
}

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        if ($WhatIf) { Write-Host "[WhatIf] mkdir $Path" }
        else { New-Item -ItemType Directory -Force -Path $Path | Out-Null }
    }
}

function Copy-File([string]$From, [string]$To) {
    Ensure-Dir (Split-Path -Parent $To)
    if ($WhatIf) { Write-Host "[WhatIf] $($From.Split('\')[-1]) -> $($To.Split('\')[-1])" }
    else { Copy-Item -LiteralPath $From -Destination $To -Force }
}

$rawSource = Resolve-SourceRoot
Write-Host 'Bitcoin Miner / gpu-rack reorganize' -ForegroundColor Cyan
Write-Host "  Raw source: $rawSource" -ForegroundColor DarkGray
Write-Host "  Archive:    $ArchiveRoot" -ForegroundColor DarkGray
Write-Host "  Publish:    $GpuRackRoot" -ForegroundColor DarkGray

if (-not $WhatIf) {
    Ensure-Dir $ArchiveRoot
    & robocopy $rawSource $ArchiveRoot /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "Archive robocopy failed ($LASTEXITCODE)" }
    Write-Host 'Archive OK' -ForegroundColor Green
}

$meshMap = @{
    'GPU_Farm_Static.obj'       = 'gpu-rack-static.obj'
    'gpu-rack-static.obj'       = 'gpu-rack-static.obj'
    'GPU_Farm_Anim.fbx'         = 'gpu-rack-anim.fbx'
    'gpu-rack-anim.fbx'         = 'gpu-rack-anim.fbx'
    'GPU_Farm_Stacked_Anim.fbx' = 'gpu-rack-stacked-anim.fbx'
    'gpu-rack-stacked-anim.fbx' = 'gpu-rack-stacked-anim.fbx'
}

$rawTextureFolders = @{
    'GPU_GraphicsCard' = 'textures\gpu'
    'GPU_Rack'         = 'textures\rack'
    'Motherboard'      = 'textures\motherboard'
    'Power_Supply'     = 'textures\psu'
    'Wires'            = 'textures\cord'
}
$flatTextureFolders = @{
    'gpu'         = 'textures\gpu'
    'rack'        = 'textures\rack'
    'motherboard' = 'textures\motherboard'
    'psu'         = 'textures\psu'
    'wires'       = 'textures\cord'
    'cord'        = 'textures\cord'
}

Ensure-Dir (Join-Path $GpuRackRoot 'source')
Ensure-Dir (Join-Path $GpuRackRoot 'materials')

$sourceDir = $rawSource
if (Test-Path -LiteralPath (Join-Path $rawSource 'source')) {
    $nested = Join-Path $rawSource 'source'
    if (Get-ChildItem -LiteralPath $nested -File -ErrorAction SilentlyContinue) { $sourceDir = $nested }
}

foreach ($pair in $meshMap.GetEnumerator() | Sort-Object Key -Unique) {
    $src = Join-Path $sourceDir $pair.Key
    if (-not (Test-Path -LiteralPath $src)) { continue }
    $dest = Join-Path $GpuRackRoot "source\$($pair.Value)"
    Copy-File $src $dest
}

foreach ($required in @('gpu-rack-static.obj')) {
    $p = Join-Path $GpuRackRoot "source\$required"
    if (-not (Test-Path -LiteralPath $p) -and -not $WhatIf) {
        throw "Missing required mesh after copy: $required"
    }
}

foreach ($map in @($rawTextureFolders, $flatTextureFolders)) {
    foreach ($folder in $map.Keys) {
        $srcDir = Join-Path $sourceDir $folder
        if (-not (Test-Path -LiteralPath $srcDir)) { continue }
        $destDir = Join-Path $GpuRackRoot $map[$folder]
        Ensure-Dir $destDir
        Get-ChildItem -LiteralPath $srcDir -File | ForEach-Object {
            Copy-File $_.FullName (Join-Path $destDir $_.Name)
        }
    }
}

# Entity + sound folders (Bitcoin Miner — not the mesh slug)
$entityDir = Join-Path $BitcoinRoot 'entities\bitcoin-miner'
$soundDir = Join-Path $BitcoinRoot 'sounds\bitcoin-miner'
if (-not $WhatIf) {
    Ensure-Dir $entityDir
    Ensure-Dir $soundDir
    $oldEntity = Join-Path $BitcoinRoot 'entities\bitminer'
    if (Test-Path -LiteralPath $oldEntity) {
        Get-ChildItem -LiteralPath $oldEntity -Force | ForEach-Object {
            Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $entityDir $_.Name) -Force -Recurse
        }
        Remove-Item -LiteralPath $oldEntity -Recurse -Force
    }
    $oldSound = Join-Path $BitcoinRoot 'sounds\bitminer'
    if (Test-Path -LiteralPath $oldSound) {
        Get-ChildItem -LiteralPath $oldSound -Force | ForEach-Object {
            Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $soundDir $_.Name) -Force -Recurse
        }
        Remove-Item -LiteralPath $oldSound -Recurse -Force
    }
    $oldMat = Join-Path $BitcoinRoot 'materials\bitminer'
    if (Test-Path -LiteralPath $oldMat) { Remove-Item -LiteralPath $oldMat -Recurse -Force }
}

$remove = @(
    (Join-Path $BitcoinRoot 'models\lifepunch\bitcoinmining\bitminer')
    (Join-Path $BitcoinRoot 'models\lifepunch\bitcoinmining\gpu_farm')
)
foreach ($path in $remove) {
    if (-not (Test-Path -LiteralPath $path)) { continue }
    if ($WhatIf) { Write-Host "[WhatIf] remove $path" }
    else {
        Remove-Item -LiteralPath $path -Recurse -Force
        Write-Host "Removed $(Split-Path $path -Leaf)/" -ForegroundColor DarkGray
    }
}

Write-Host 'Publish tree OK: gpu-rack/ + entities/bitcoin-miner/' -ForegroundColor Green
if (-not $WhatIf) {
    $count = (Get-ChildItem $GpuRackRoot -Recurse -File).Count
    Write-Host "  $count files in gpu-rack/" -ForegroundColor DarkGray
}
