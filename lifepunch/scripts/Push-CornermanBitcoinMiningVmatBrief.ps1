# Push BitcoinMiningAddon vmat + owner guide to Cornerman inbox.
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')
foreach ($rel in @(
        'lifepunchaddons\docs\briefs\CORNERMAN_BITCOINMINING_VMAT_TASK.md',
        'lifepunchaddons\Assets\addons\lifepunch\bitcoinmining\models\lifepunch\bitcoinmining\gpu-rack\BITCOINMINING_VMAT_OWNER_GUIDE.md',
        'lifepunchaddons\Assets\addons\lifepunch\bitcoinmining\models\lifepunch\bitcoinmining\gpu-rack\material-map.json'
    )) {
    $src = Join-Path $RepoRoot $rel
    if (-not (Test-Path -LiteralPath $src)) { throw "Missing $src" }
    $name = Split-Path $src -Leaf
    Push-CornermanText -Path "C:\lifepunch\cornerman\inbox\$name" -Text (Get-Content -LiteralPath $src -Raw)
    Write-Host "OK inbox\$name" -ForegroundColor Green
}
