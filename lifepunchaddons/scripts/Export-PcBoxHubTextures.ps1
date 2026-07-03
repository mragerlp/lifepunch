<#
.SYNOPSIS
  Sync pc_box hub from PLACEHOLDER + bake missing basecolor + optional DXRP sync.

.EXAMPLE
  powershell -File lifepunchaddons\scripts\Export-PcBoxHubTextures.ps1
  powershell -File lifepunchaddons\scripts\Export-PcBoxHubTextures.ps1 -SyncDxrp
#>
[CmdletBinding()]
param(
    [switch] $SyncDxrp,
    [string] $PlaceholderRoot = "$env:USERPROFILE\OneDrive\Desktop\UPLOAD READY ADDONS PLACEHOLDER\addons\lifepunch\lpbitcoin\bitcoinhub\assets"
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$AddonsRoot = Split-Path $Here -Parent
$HubAssets = Join-Path $AddonsRoot 'Assets\addons\lifepunch\lpbitcoin\bitcoinhub\assets'
$py = Join-Path $Here 'Export-PcBoxHubTextures.py'

$blender = Join-Path ${env:ProgramFiles} 'Blender Foundation\Blender 5.1\blender.exe'
if (-not (Test-Path -LiteralPath $blender)) {
    $blender = Get-ChildItem (Join-Path ${env:ProgramFiles} 'Blender Foundation') -Filter blender.exe -Recurse -ErrorAction SilentlyContinue |
        Select-Object -First 1 -ExpandProperty FullName
}
if (-not $blender) { throw 'Blender not found — install Blender 5.x' }

foreach ($d in @('source\fbx', 'textures', 'models\materials')) {
    New-Item -ItemType Directory -Force -Path (Join-Path $HubAssets $d) | Out-Null
}

$srcFbx = Join-Path $PlaceholderRoot 'pc_box.fbx'
$srcPngs = Join-Path $PlaceholderRoot 'pngs'
if (-not (Test-Path -LiteralPath $srcFbx)) { throw "Missing $srcFbx" }
if (-not (Test-Path -LiteralPath $srcPngs)) { $srcPngs = $PlaceholderRoot }

Copy-Item -LiteralPath $srcFbx -Destination (Join-Path $HubAssets 'source\fbx\pc_box.fbx') -Force
Copy-Item -LiteralPath (Join-Path $srcPngs 'PC_Box_nm.png') -Destination (Join-Path $HubAssets 'textures\pc_box_normal.png') -Force
Copy-Item -LiteralPath (Join-Path $srcPngs 'PC_Box_ao.png') -Destination (Join-Path $HubAssets 'textures\pc_box_ao.png') -Force
Copy-Item -LiteralPath (Join-Path $srcPngs 'PC_Box_id.png') -Destination (Join-Path $HubAssets 'textures\pc_box_id.png') -Force -ErrorAction SilentlyContinue
Copy-Item -LiteralPath (Join-Path $srcPngs 'PC_Box_curv.png') -Destination (Join-Path $HubAssets 'textures\pc_box_curv.png') -Force -ErrorAction SilentlyContinue

$outBase = Join-Path $HubAssets 'textures\pc_box_basecolor.png'
$ao = Join-Path $HubAssets 'textures\pc_box_ao.png'
$curv = Join-Path $HubAssets 'textures\pc_box_curv.png'
$fbx = Join-Path $HubAssets 'source\fbx\pc_box.fbx'

$args = @('--background', '--python', $py, '--', $fbx, $ao, $outBase)
if (Test-Path -LiteralPath $curv) { $args += $curv }
& $blender @args
if ($LASTEXITCODE -ne 0) { throw "Blender bake failed ($LASTEXITCODE)" }
if (-not (Test-Path -LiteralPath $outBase)) { throw "Bake did not write $outBase" }

Write-Host "Baked basecolor -> $outBase" -ForegroundColor Green

if ($SyncDxrp) {
    $prep = Join-Path (Split-Path $AddonsRoot -Parent) 'scripts\Prepare-LpBitcoinModelDoc.ps1'
    if (-not (Test-Path -LiteralPath $prep)) {
        $prep = Join-Path (Split-Path (Split-Path $AddonsRoot -Parent) -Parent) 'scripts\Prepare-LpBitcoinModelDoc.ps1'
    }
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $prep -Entity bitcoinhub
}
