<#
.SYNOPSIS
  Archive enhanced drug dealer / coke assets and promote ship tree into advanceddrugprocessing/.

.PARAMETER SourceRoot
  Owner pack root (default: OneDrive bloat serverstuff folder).

.EXAMPLE
  powershell -File Intake-AdvancedDrugProcessingAssets.ps1
#>
[CmdletBinding()]
param(
    [string] $SourceRoot = 'C:\Users\jared\OneDrive\Desktop\bloat\serverstuff\advanceddrugprocessing',
    [string] $ArchiveRoot = 'C:\lifepunch\reference-intake\advanceddrugprocessing\full-export',
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$AddonsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$AssetRoot = Join-Path $AddonsRoot 'Assets\addons\lifepunch\advanceddrugprocessing'
$ModelsRoot = Join-Path $AssetRoot 'models\lifepunch\advanceddrugprocessing'
$EntitiesRoot = Join-Path $AssetRoot 'entities'

$sboxAssets = Join-Path $SourceRoot 'advanceddrugprocessing\_sbox_assets'
if (-not (Test-Path -LiteralPath $sboxAssets)) {
    throw "Missing built assets: $sboxAssets"
}

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        if ($WhatIf) { Write-Host "[WhatIf] mkdir $Path" }
        else { New-Item -ItemType Directory -Force -Path $Path | Out-Null }
    }
}

function Mirror-Tree([string]$From, [string]$To, [string]$Label) {
    if (-not (Test-Path -LiteralPath $From)) { return }
    if ($WhatIf) {
        Write-Host "[WhatIf] MIR $Label"
        return
    }
    Ensure-Dir $To
    & robocopy $From $To /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy failed ($LASTEXITCODE): $Label" }
    $n = (Get-ChildItem $To -Recurse -File).Count
    Write-Host "  $Label - $n files" -ForegroundColor Green
}

Write-Host 'Advanced Drug Processing intake' -ForegroundColor Cyan
Write-Host "  Source: $SourceRoot" -ForegroundColor DarkGray
Write-Host "  Archive: $ArchiveRoot" -ForegroundColor DarkGray
Write-Host "  Publish: $AssetRoot" -ForegroundColor DarkGray

if (-not $WhatIf) {
    Ensure-Dir $ArchiveRoot
    & robocopy $SourceRoot $ArchiveRoot /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "Archive failed ($LASTEXITCODE)" }
    Write-Host 'Archive OK' -ForegroundColor Green
}

Mirror-Tree (Join-Path $sboxAssets 'models') $ModelsRoot 'models (built vmdl + source)'
Mirror-Tree (Join-Path $sboxAssets 'entities') $EntitiesRoot 'entities (prefabs)'

$rawMap = @{
    'cocaine_bag'   = 'coke-bag'
    'cocaine-brick' = 'coke-brick'
}
foreach ($folder in $rawMap.Keys) {
    $src = Join-Path $SourceRoot $folder
    if (-not (Test-Path -LiteralPath $src)) { continue }
    $dest = Join-Path $ModelsRoot $rawMap[$folder]
    Mirror-Tree $src (Join-Path $dest 'intake-raw') "raw/$folder -> $($rawMap[$folder])/intake-raw"
}

Write-Host 'Intake OK' -ForegroundColor Green
