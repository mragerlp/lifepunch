# Push coke / enhanced drug intake task to Cornerman inbox.
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')

$files = @(
    'lifepunchaddons\docs\briefs\CORNERMAN_COKE_DRUG_INTAKE_TASK.md',
    'lifepunchaddons\docs\COKE_DRUG_RESKIN_SPEC.md',
    'lifepunchaddons\Assets\addons\lifepunch\advanceddrugprocessing\ASSET_INVENTORY.md',
    'lifepunchaddons\Assets\addons\lifepunch\advanceddrugprocessing\COKE_LINE_MAP.md'
)

foreach ($rel in $files) {
    $src = Join-Path $RepoRoot $rel
    if (-not (Test-Path -LiteralPath $src)) { throw "Missing $src" }
    $name = Split-Path $src -Leaf
    Push-CornermanText -Path "C:\lifepunch\cornerman\inbox\$name" -Text (Get-Content -LiteralPath $src -Raw)
    Write-Host "OK inbox\$name" -ForegroundColor Green
}

$directive = @{
    id         = 'coke-drug-intake'
    priority   = 'medium'
    lane       = 'cornerman'
    title      = 'Coke / enhanced drug — asset intake'
    summary    = 'Unzip raw drug meshes, material-map stubs, distill COKE_LINE_MAP. No editor, no push.'
    primaryDoc = 'CORNERMAN_COKE_DRUG_INTAKE_TASK.md'
} | ConvertTo-Json -Compress

Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\COKE_DRUG_INTAKE.json' -Text $directive
Write-Host 'OK inbox\COKE_DRUG_INTAKE.json' -ForegroundColor Green
