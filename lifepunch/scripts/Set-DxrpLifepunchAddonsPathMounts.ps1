<#
.SYNOPSIS
  Point rp.sbproj at the canonical DXRP addons path — lp* models-only + _dev.

.DESCRIPTION
  Canonical assets: dxrp/game/addons/lifepunch/
  - Mirrors repo lp* + _dev to disk (no quarantine moves)
  - rp.sbproj Resources: _dev/** + each lp*/<entity>/assets/models/**
  - Does NOT mount full package trees (source FBX stays off Resources scan)

.EXAMPLE
  powershell -File lifepunch\scripts\Set-DxrpLifepunchAddonsPathMounts.ps1
#>
[CmdletBinding()]
param(
    [string] $ConfigPath = '',
    [string[]] $ExcludePackages = @('lpbitcoin'),
    [switch] $SkipDxrpAssetSync
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $ConfigPath) { $ConfigPath = Join-Path $Here 'dxrp-editor.local.json' }
if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw "Missing $ConfigPath"
}

$cfg = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
$sbprojPath = [string]$cfg.projectPath
$dxrpGame = Split-Path -Parent $sbprojPath
$dxrpAssetsRoot = Join-Path $dxrpGame 'addons\lifepunch'

$repoAddons = (Resolve-Path (Join-Path $Here '..\..\lifepunchaddons')).Path
$repoAssetsRoot = Join-Path $repoAddons 'Assets\addons\lifepunch'
$stagingPath = Join-Path $repoAddons 'config\package-staging.json'
$staging = Get-Content -LiteralPath $stagingPath -Raw | ConvertFrom-Json
$stagingPackages = @($staging.packages.PSObject.Properties.Name)
$devFolder = '_dev'

Write-Host 'Canonical addons path:' -ForegroundColor Cyan
Write-Host "  $dxrpAssetsRoot" -ForegroundColor DarkGray

if ($SkipDxrpAssetSync) {
    Write-Host 'SkipDxrpAssetSync: NOT copying lifepunch assets onto DXRP disk (use modeldoc-studio for meshes).' -ForegroundColor Yellow
}
else {
Write-Host 'Sync repo -> DXRP (lp* + _dev, no quarantine)' -ForegroundColor Cyan
Write-Host '  WARN: staging meshes on DXRP disk can stall boot even without rp.sbproj mounts.' -ForegroundColor DarkYellow
Write-Host '  Prefer Reset-DxrpVanillaBoot.ps1 for gamemode work; modeldoc-studio for hub compile.' -ForegroundColor DarkYellow
New-Item -ItemType Directory -Force -Path $dxrpAssetsRoot | Out-Null
foreach ($pkg in $stagingPackages) {
    $src = Join-Path $repoAssetsRoot $pkg
    if (-not (Test-Path -LiteralPath $src)) { continue }
    $dst = Join-Path $dxrpAssetsRoot $pkg
    & robocopy $src $dst /MIR /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy failed: $pkg" }
    Write-Host "  synced $pkg" -ForegroundColor Green
}
$devSrc = Join-Path $repoAssetsRoot $devFolder
if (Test-Path -LiteralPath $devSrc) {
    & robocopy $devSrc (Join-Path $dxrpAssetsRoot $devFolder) /MIR /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw 'robocopy _dev failed' }
    Write-Host '  synced _dev' -ForegroundColor Green
}
}

$keepLines = @(
    'ui/*'
    'gameplay/entities/jobs/mayor/gun_license/gun_license.png'
)
$lines = [System.Collections.Generic.List[string]]::new()
foreach ($k in $keepLines) { $lines.Add($k) }
# _dev/lifepunch-modeldoc.scene is optional preview only — skip mount on DXRP (gamemode context breaks it).
# ModelDoc: open .vmdl directly. Scale proof later: flatgrass or ModelDoc Studio.
foreach ($pkg in $stagingPackages) {
    if ($ExcludePackages -contains $pkg) {
        Write-Host "  skip mount: $pkg (excluded - heavy FBX stalls DXRP boot compile)" -ForegroundColor DarkYellow
        continue
    }
    $entities = $staging.packages.$pkg.entities
    if (-not $entities) { continue }
    foreach ($ent in $entities.PSObject.Properties.Name) {
        $lines.Add("addons/lifepunch/$pkg/$ent/assets/models/**")
    }
}

$content = Get-Content -LiteralPath $sbprojPath -Raw
$marker = '"Resources": "'
$start = $content.IndexOf($marker)
if ($start -lt 0) { throw 'rp.sbproj Resources field not found' }
$valueStart = $start + $marker.Length
$valueEnd = $content.IndexOf('"', $valueStart)
$newResources = ($lines | Select-Object -Unique) -join '\n'
$content = $content.Substring(0, $valueStart) + $newResources + $content.Substring($valueEnd)
[System.IO.File]::WriteAllText($sbprojPath, $content)

Write-Host ''
Write-Host 'rp.sbproj Resources -> DXRP ui + addons/lifepunch (lp* models-only)' -ForegroundColor Green
Write-Host '  lpbitcoin hub: compile in ModelDoc Studio - not mounted on DXRP boot (cpu_gamer FBX stall).' -ForegroundColor DarkGray
Write-Host '  Restart sbox editor if it was open.' -ForegroundColor Yellow
