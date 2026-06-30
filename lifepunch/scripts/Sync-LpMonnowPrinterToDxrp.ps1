# Mirror Desktop Monnow source into the DXRP editor project for compile + playtest.
param(
    [string]$MonnowRoot = "$env:USERPROFILE\OneDrive\Desktop\monnowsaddons",
    [string]$ConfigPath = ''
)

$ErrorActionPreference = 'Stop'
$SourceRoot = Join-Path $MonnowRoot "Monnow's Printer Addon\LifePunch"
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $ConfigPath) {
    $ConfigPath = Join-Path $Here 'dxrp-editor.local.json'
}

if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw "Missing $ConfigPath"
}

$Config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
$DxrpGame = Split-Path -Parent $Config.projectPath

$AssetsSource = Join-Path $SourceRoot 'assets\monnowprinterlp'
$CodeSource = Join-Path $SourceRoot 'code\monnowprinterlp'
$AssetsDest = Join-Path $DxrpGame 'Assets\addons\lifepunch\monnowprinterlp'
$CodeDest = Join-Path $DxrpGame 'Code\Addons\lifepunch\lpmonnowsprinterupgrade'

foreach ($pair in @(
        @{ Label = 'assets'; From = $AssetsSource; To = $AssetsDest },
        @{ Label = 'code'; From = $CodeSource; To = $CodeDest }
    )) {
    if (-not (Test-Path -LiteralPath $pair.From)) {
        throw "Missing $($pair.Label) source: $($pair.From)"
    }

    New-Item -ItemType Directory -Force -Path $pair.To | Out-Null
    & robocopy $pair.From $pair.To /MIR /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) {
        throw "robocopy $($pair.Label) failed ($LASTEXITCODE)"
    }

    $count = (Get-ChildItem -LiteralPath $pair.To -Recurse -File).Count
    Write-Host "Synced $($pair.Label) -> $($pair.To) ($count files)" -ForegroundColor Green
}

Write-Host "DXRP mount paths:" -ForegroundColor Cyan
Write-Host "  addons/lifepunch/monnowprinterlp/monnowprinter.prefab"
Write-Host "  Code/Addons/lifepunch/lpmonnowsprinterupgrade/"
