<#
.SYNOPSIS
  Unfreeze DXRP: vanilla rp.sbproj + LifePunch assets OFF the DXRP game tree.

.DESCRIPTION
  Staging meshes on disk under dxrp/game/addons cause auto-compile stalls even when rp.sbproj
  does not mount them. This script:
    1. Kills frozen sbox-dev
    2. Resets rp.sbproj Resources to DXRP vanilla (no lifepunch mounts)
    3. Moves game/addons/lifepunch -> dxrp/_lifepunch-offline/ (outside game tree)
    4. Renames staging _dev spawn helper so C# does not reference hub vmdl on boot

  Hub / Model Foundation work belongs in modeldoc-studio, NOT the DXRP gamemode project.

.EXAMPLE
  powershell -File lifepunch\scripts\Reset-DxrpVanillaBoot.ps1
  powershell -File lifepunch\scripts\Reset-DxrpVanillaBoot.ps1 -Launch
#>
[CmdletBinding()]
param(
    [switch] $Launch,
    [string] $ConfigPath = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $Here 'Dxrp-LifepunchPaths.ps1')
if (-not $ConfigPath) { $ConfigPath = Join-Path $Here 'dxrp-editor.local.json' }
if (-not (Test-Path -LiteralPath $ConfigPath)) { throw "Missing $ConfigPath" }

$cfg = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
$sbprojPath = [string]$cfg.projectPath
$dxrpGame = Get-DxrpGameRootFromConfig -ConfigPath $ConfigPath
$dxrpRoot = Split-Path -Parent $dxrpGame
$assetsLp = Get-DxrpLifepunchAddonsDiskRoot -DxrpGameRoot $dxrpGame
$offlineRoot = Join-Path $dxrpRoot '_lifepunch-offline'
$offlineAssets = Join-Path $offlineRoot 'addons\lifepunch'
$stagingSpawn = Join-Path $dxrpGame 'Code\Addons\lifepunch\_dev\LpBitcoinStagingDevSpawn.cs'

Stop-Process -Name 'sbox-dev' -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Write-Host 'Stopped sbox-dev.' -ForegroundColor Yellow

$vanillaResources = @(
    'ui/*'
    'gameplay/entities/jobs/mayor/gun_license/gun_license.png'
) -join '\n'

$content = Get-Content -LiteralPath $sbprojPath -Raw
$marker = '"Resources": "'
$start = $content.IndexOf($marker)
if ($start -lt 0) { throw 'rp.sbproj Resources field not found' }
$valueStart = $start + $marker.Length
$valueEnd = $content.IndexOf('"', $valueStart)
$content = $content.Substring(0, $valueStart) + $vanillaResources + $content.Substring($valueEnd)
[System.IO.File]::WriteAllText($sbprojPath, $content)
Write-Host 'rp.sbproj -> vanilla Resources (no lifepunch mounts).' -ForegroundColor Green

if (Test-Path -LiteralPath $assetsLp) {
    New-Item -ItemType Directory -Force -Path (Split-Path $offlineAssets -Parent) | Out-Null
    if (Test-Path -LiteralPath $offlineAssets) {
        $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $archived = Join-Path $offlineRoot "Assets-addons-lifepunch-$stamp"
        Write-Host "Offline folder exists; archiving to $archived" -ForegroundColor DarkYellow
        Move-Item -LiteralPath $offlineAssets -Destination $archived -Force
    }
    Move-Item -LiteralPath $assetsLp -Destination $offlineAssets -Force
    Write-Host "Moved lifepunch assets OFF DXRP tree -> $offlineAssets" -ForegroundColor Green
}
else {
    Write-Host 'No game/addons/lifepunch on DXRP (already offline).' -ForegroundColor DarkGray
}

if (Test-Path -LiteralPath $stagingSpawn) {
    $disabled = "$stagingSpawn.offline"
    if (Test-Path -LiteralPath $disabled) { Remove-Item -LiteralPath $disabled -Force }
    Rename-Item -LiteralPath $stagingSpawn -NewName 'LpBitcoinStagingDevSpawn.cs.offline' -Force
    Write-Host 'Disabled LpBitcoinStagingDevSpawn.cs on DXRP (renamed .offline).' -ForegroundColor Green
}

Write-Host ''
Write-Host 'DXRP is clean for gamemode/editor work. lpbitcoin stays in repo + modeldoc-studio only.' -ForegroundColor Cyan
Write-Host 'Dev playtest: open Assets/scenes/blank.scene -> Host Play (not flatgrass).' -ForegroundColor Cyan
Write-Host "Offline copy: $offlineRoot" -ForegroundColor DarkGray

if ($Launch) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Here 'Start-SboxDxrpEditor.ps1') -NoSync -SkipPreflight
}
