<#
.SYNOPSIS
  One-shot prep: sync lpbitcoin ModelDoc assets repo -> DXRP greenfield lane.

.DESCRIPTION
  - Does NOT mirror from Desktop (repo is ahead for terminal/racks).
  - Copies only lpbitcoin package under Assets/addons/lifepunch/lpbitcoin.
  - Run after vmdl/vmat edits, before ModelDoc compile in editor.

.EXAMPLE
  powershell -File lifepunch\scripts\Prepare-LpBitcoinModelDoc.ps1
  powershell -File lifepunch\scripts\Prepare-LpBitcoinModelDoc.ps1 -RecompileViaBridge
#>
[CmdletBinding()]
param(
    [switch] $RecompileViaBridge
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$repoAddons = (Resolve-Path (Join-Path $Here '..\addons')).Path
$src = Join-Path $repoAddons 'Assets\addons\lifepunch\lpbitcoin'
if (-not (Test-Path -LiteralPath $src)) { throw "Missing staging package: $src" }

$configPath = Join-Path $Here 'dxrp-editor.local.json'
if (-not (Test-Path -LiteralPath $configPath)) {
    Write-Host 'No dxrp-editor.local.json — repo files only. Copy config from .example to sync to DXRP.' -ForegroundColor Yellow
    Write-Host "Canonical staging: $src" -ForegroundColor Cyan
    exit 0
}

$cfg = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
$dxrpGame = Split-Path -Parent ([string]$cfg.projectPath)
$dest = Join-Path $dxrpGame 'Assets\addons\lifepunch\lpbitcoin'

Write-Host 'LpBitcoin ModelDoc prep — repo -> DXRP' -ForegroundColor Cyan
Write-Host "  From: $src" -ForegroundColor DarkGray
Write-Host "  To:   $dest" -ForegroundColor DarkGray

New-Item -ItemType Directory -Force -Path (Split-Path $dest -Parent) | Out-Null
& robocopy $src $dest /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
if ($LASTEXITCODE -ge 8) { throw "robocopy failed with exit $LASTEXITCODE" }
Write-Host '  synced lpbitcoin assets' -ForegroundColor Green

$vmdls = @(
    'bitcoinhub\assets\models\cpu-gamer.vmdl',
    'hashdterminal\assets\models\hashd-terminal.vmdl',
    'gpurack\assets\models\gpu-rack.vmdl',
    'advancedgpurack\assets\models\gpu-rack-stacked.vmdl'
)
Write-Host 'ModelDoc targets (open in editor):' -ForegroundColor Cyan
foreach ($rel in $vmdls) {
    Write-Host "  addons/lifepunch/lpbitcoin/$($rel -replace '\\','/')" -ForegroundColor White
}

if ($RecompileViaBridge) {
    Write-Host 'Bridge recompile: start s&box + Claude Bridge, then re-run with MCP or compile manually in ModelDoc.' -ForegroundColor Yellow
}

Write-Host 'Next: Set-DxrpLifepunchModelDocLane.ps1 if full lane reset needed.' -ForegroundColor DarkGray
