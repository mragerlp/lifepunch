<#
.SYNOPSIS
  Pull ModelDoc / editor compiled outputs from DXRP back into the monorepo.

.DESCRIPTION
  Repo -> DXRP sync uses robocopy /MIR, which DELETES compiled *_c on DXRP when they
  are missing from the repo. Run this after ModelDoc sessions (or before Start-SboxDxrpEditor)
  so bitcoin-terminal, stacked rack, prefabs, and textures stay in git.

.PARAMETER Addon
  Addon ident under Assets/addons/lifepunch (default: bitcoinmining).

.EXAMPLE
  powershell -File Pull-DxrpCompiledAssetsToRepo.ps1
  powershell -File Pull-DxrpCompiledAssetsToRepo.ps1 -Addon bitcoinmining
#>
[CmdletBinding()]
param(
    [string] $Addon = 'bitcoinmining',
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
$repoAddons = (Resolve-Path (Join-Path $Here '..\addons')).Path
$from = Join-Path $dxrpGame "Assets\addons\lifepunch\$Addon"
$to = Join-Path $repoAddons "Assets\addons\lifepunch\$Addon"

if (-not (Test-Path -LiteralPath $from)) {
    throw "DXRP addon assets missing: $from (compile in ModelDoc first)"
}

New-Item -ItemType Directory -Force -Path $to | Out-Null

function Copy-CompiledTree([string]$Relative) {
    $src = Join-Path $from $Relative
    $dst = Join-Path $to $Relative
    if (-not (Test-Path -LiteralPath $src)) { return }
    New-Item -ItemType Directory -Force -Path $dst | Out-Null
    & robocopy $src $dst /E /NFL /NDL /NJH /NJS /nc /ns /np `
        *.vmdl_c *.vmat_c *.vtex_c *.prefab_c | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy failed ($LASTEXITCODE): $Relative" }
}

Write-Host "Pull DXRP compiled -> repo ($Addon)" -ForegroundColor Cyan
Write-Host "  From: $from" -ForegroundColor DarkGray
Write-Host "  To:   $to" -ForegroundColor DarkGray

# Whole addon tree — only compiled + generated texture outputs.
& robocopy $from $to /E /NFL /NDL /NJH /NJS /nc /ns /np `
    *.vmdl_c *.vmat_c *.vtex_c *.prefab_c | Out-Null
if ($LASTEXITCODE -ge 8) { throw "robocopy failed ($LASTEXITCODE)" }

# Textures folder (PBR maps referenced by vmats after ModelDoc compile).
$texFrom = Join-Path $from 'models\lifepunch\bitcoinmining\gpu-rack\textures'
$texTo = Join-Path $to 'models\lifepunch\bitcoinmining\gpu-rack\textures'
if (Test-Path -LiteralPath $texFrom) {
    New-Item -ItemType Directory -Force -Path $texTo | Out-Null
    & robocopy $texFrom $texTo /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy textures failed ($LASTEXITCODE)" }
    Write-Host '  textures/ synced' -ForegroundColor Green
}

$pulled = @(Get-ChildItem -LiteralPath $to -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Extension -match '_c$' })
Write-Host "  $($pulled.Count) compiled files in repo tree" -ForegroundColor Green
Write-Host ''
Write-Host 'Next: git add the new *_c / textures, then normal repo -> DXRP sync is safe.' -ForegroundColor DarkGray
