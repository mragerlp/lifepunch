<#
.SYNOPSIS
  Pull Sbox UI Designer work from DXRP back into the monorepo.

.DESCRIPTION
  Repo -> DXRP sync (Sync-LifePunchAddonsToDxrp.ps1) uses robocopy /MIR and will
  DELETE designer edits that only exist in DXRP. Run this after UI Designer sessions
  before syncing repo -> DXRP or before asking an agent to port layout into Razor.

  Pulls:
    - Assets/.../ui/sui/*.sui
    - Assets/.../ui/hashd/* (png, jpg, svg, webp)
    - Optional scratch compile output (Code/_sui_scratch/hashd_hub_ui) for port reference

.PARAMETER Addon
  Addon ident (default: bitcoinmining).

.PARAMETER IncludeScratch
  Also mirror Code/_sui_scratch/hashd_hub_ui into repo Code/_sui_scratch/hashd_hub_ui.

.EXAMPLE
  powershell -File Pull-DxrpUiDesignerToRepo.ps1
  powershell -File Pull-DxrpUiDesignerToRepo.ps1 -IncludeScratch
#>
[CmdletBinding()]
param(
    [string] $Addon = 'bitcoinmining',
    [switch] $IncludeScratch,
    [string] $ConfigPath = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $ConfigPath) { $ConfigPath = Join-Path $Here 'dxrp-editor.local.json' }
if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw "Missing $ConfigPath - copy dxrp-editor.local.json.example first."
}

$cfg = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
$project = [string]$cfg.projectPath
if (-not (Test-Path -LiteralPath $project)) { throw "DXRP project not found: $project" }

$dxrpGame = Split-Path -Parent $project
$repoAddons = (Resolve-Path (Join-Path $Here '..\..\lifepunchaddons')).Path
$dxrpAddon = Join-Path $dxrpGame "Assets\addons\lifepunch\$Addon"
$repoAddon = Join-Path $repoAddons "Assets\addons\lifepunch\$Addon"

if (-not (Test-Path -LiteralPath $dxrpAddon)) {
    Write-Host "Pull DXRP UI Designer -> repo ($Addon)" -ForegroundColor Cyan
    Write-Host '  skip: no DXRP assets folder' -ForegroundColor DarkGray
    exit 0
}

function Copy-Tree([string]$Relative, [string[]]$Include = @('*')) {
    $src = Join-Path $dxrpAddon $Relative
    $dst = Join-Path $repoAddon $Relative
    if (-not (Test-Path -LiteralPath $src)) { return 0 }
    New-Item -ItemType Directory -Force -Path $dst | Out-Null
    $countBefore = @(Get-ChildItem -LiteralPath $dst -Recurse -File -ErrorAction SilentlyContinue).Count
    foreach ($pattern in $Include) {
        & robocopy $src $dst /E /NFL /NDL /NJH /NJS /nc /ns /np $pattern | Out-Null
        if ($LASTEXITCODE -ge 8) { throw "robocopy failed ($LASTEXITCODE): $Relative ($pattern)" }
    }
    $countAfter = @(Get-ChildItem -LiteralPath $dst -Recurse -File -ErrorAction SilentlyContinue).Count
    return [Math]::Max(0, $countAfter - $countBefore)
}

Write-Host "Pull DXRP UI Designer -> repo ($Addon)" -ForegroundColor Cyan
Write-Host "  From: $dxrpAddon" -ForegroundColor DarkGray
Write-Host "  To:   $repoAddon" -ForegroundColor DarkGray

$sui = Copy-Tree 'ui\sui' @('*.sui')
$hashd = Copy-Tree 'ui\hashd' @('*.png', '*.jpg', '*.jpeg', '*.svg', '*.webp')
Write-Host "  ui/sui:   $sui file(s) updated/added" -ForegroundColor Green
Write-Host "  ui/hashd: $hashd file(s) updated/added" -ForegroundColor Green

if ($IncludeScratch) {
    $scratchFrom = Join-Path $dxrpGame 'Code\_sui_scratch\hashd_hub_ui'
    $scratchTo = Join-Path $repoAddons 'Code\_sui_scratch\hashd_hub_ui'
    if (Test-Path -LiteralPath $scratchFrom) {
        New-Item -ItemType Directory -Force -Path $scratchTo | Out-Null
        & robocopy $scratchFrom $scratchTo /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
        if ($LASTEXITCODE -ge 8) { throw "robocopy scratch failed ($LASTEXITCODE)" }
        $n = @(Get-ChildItem -LiteralPath $scratchTo -Recurse -File).Count
        Write-Host "  scratch:  $n file(s) in Code/_sui_scratch/hashd_hub_ui" -ForegroundColor Green
    }
    else {
        Write-Host '  scratch:  skip (compile hashd-hub-ui.sui in editor first)' -ForegroundColor DarkGray
    }
}

Write-Host ''
Write-Host 'Next: agent ports layout deltas into LpHashdPanel.razor + .razor.scss (@code stays in repo).' -ForegroundColor DarkGray
Write-Host 'Do NOT run Sync-LifePunchAddonsToDxrp until you are ready to push repo -> DXRP again.' -ForegroundColor DarkYellow
