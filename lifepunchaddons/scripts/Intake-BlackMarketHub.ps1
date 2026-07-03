<#
.SYNOPSIS
  Intake Fab "Vault Safe + Gold & Silver" into blackmarketdealer hub model tree.

.PARAMETER SourceRoot
  Default: OneDrive\Desktop\LIFEPUNCH™\addons\blackmarkethub

.EXAMPLE
  powershell -File Intake-BlackMarketHub.ps1
#>
[CmdletBinding()]
param(
    [string] $SourceRoot = '',
    [string] $ArchiveRoot = 'C:\lifepunch\reference-intake\blackmarketdealer\black-market-hub',
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'LifePunch-AddonDropPaths.ps1')

if (-not $SourceRoot) {
    $SourceRoot = Get-LifePunchEntityDrop -Key 'blackmarket.hub' -LegacyNames @('blackmarkethub')
}
$AddonsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$BmAssets = Join-Path $AddonsRoot 'Assets\addons\lifepunch\blackmarketdealer'
$ModelRoot = Join-Path $BmAssets 'models\lifepunch\blackmarketdealer\black-market-hub'
$EntityRoot = Join-Path $BmAssets 'entities\blackmarkethub'
$IntakeRaw = Join-Path $BmAssets 'intake-raw\black-market-hub'

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        if ($WhatIf) { Write-Host "[WhatIf] mkdir $Path" }
        else { New-Item -ItemType Directory -Force -Path $Path | Out-Null }
    }
}

function Resolve-FabMesh([string]$Root) {
    $names = @('Safe_Vault_FBX.fbx', 'safe_vault_fbx.fbx', 'Safe_Vault_TRIO.fbx')
    foreach ($name in $names) {
        $hits = Get-ChildItem -LiteralPath $Root -Recurse -File -Filter $name -ErrorAction SilentlyContinue
        if ($hits) { return ($hits | Sort-Object Length -Descending | Select-Object -First 1).FullName }
    }
    return $null
}

function Resolve-TextureSet([string]$Root, [string]$SetName, [string[]]$Tiers) {
    foreach ($tier in $Tiers) {
        $dir = Get-ChildItem -LiteralPath $Root -Recurse -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -eq $tier -and $_.Parent.Name -eq $SetName } |
            Select-Object -First 1
        if ($dir) { return $dir.FullName }
    }
    return $null
}

if (-not (Test-Path -LiteralPath $SourceRoot)) {
    throw "Missing source root: $SourceRoot"
}

$SourceFbx = Resolve-FabMesh -Root $SourceRoot
if (-not $SourceFbx) {
    throw "Missing Safe_Vault_FBX.fbx under $SourceRoot"
}

$SafeTex = Resolve-TextureSet -Root $SourceRoot -SetName 'Safe_Vault' -Tiers @('2K', '4K', '1K')
$BullionTex = Resolve-TextureSet -Root $SourceRoot -SetName 'Gold_Bullion' -Tiers @('2K', '4K', '1K')

Write-Host 'Black Market hub intake (Fab Vault Safe)' -ForegroundColor Cyan
Write-Host "  Mesh:    $SourceFbx" -ForegroundColor DarkGray
Write-Host "  Safe:    $SafeTex" -ForegroundColor DarkGray
Write-Host "  Bullion: $BullionTex" -ForegroundColor DarkGray

$destFbx = Join-Path $ModelRoot 'source\black-market-hub.fbx'
$destSafe = Join-Path $ModelRoot 'source\textures\safe-vault'
$destBullion = Join-Path $ModelRoot 'source\textures\bullion'
$destEntityTex = Join-Path $EntityRoot 'textures'

if ($WhatIf) {
    Write-Host "[WhatIf] -> $destFbx"
    exit 0
}

Ensure-Dir $ArchiveRoot
& robocopy $SourceRoot $ArchiveRoot /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
if ($LASTEXITCODE -ge 8) { throw "Archive robocopy failed ($LASTEXITCODE)" }

Ensure-Dir (Join-Path $EntityRoot 'source')
Ensure-Dir (Join-Path $ModelRoot 'source')
Ensure-Dir $IntakeRaw
Copy-Item -LiteralPath $SourceFbx -Destination (Join-Path $IntakeRaw 'black-market-hub.fbx') -Force
Copy-Item -LiteralPath $SourceFbx -Destination (Join-Path $EntityRoot 'source\black-market-hub.fbx') -Force
Copy-Item -LiteralPath $SourceFbx -Destination $destFbx -Force

if ($SafeTex) {
    Ensure-Dir $destSafe
    & robocopy $SafeTex $destSafe /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    Ensure-Dir $destEntityTex
    & robocopy $SafeTex (Join-Path $destEntityTex 'safe-vault') /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
}
if ($BullionTex) {
    Ensure-Dir $destBullion
    & robocopy $BullionTex $destBullion /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    Ensure-Dir $destEntityTex
    & robocopy $BullionTex (Join-Path $destEntityTex 'bullion') /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
}

Write-Host '  black-market-hub.fbx + textures OK' -ForegroundColor Green
Write-Host 'Intake OK — ModelDoc black-market-hub.vmdl (Safe_Vault + Bullion slots). Addon ident TBD in addons.json.' -ForegroundColor Green
