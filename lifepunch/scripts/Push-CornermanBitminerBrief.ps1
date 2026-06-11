# Push bitminer specs to Cornerman inbox for Tier-3 distill.
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')
foreach ($rel in @(
        'lifepunch\addons\docs\BITMINER_UX_SPEC.md',
        'lifepunch\addons\docs\briefs\BITMINER_ENTITY_BRIEF.md'
    )) {
    $src = Join-Path $RepoRoot $rel
    if (-not (Test-Path -LiteralPath $src)) { throw "Missing $src" }
    $name = Split-Path $src -Leaf
    Push-CornermanText -Path "C:\lifepunch\cornerman\inbox\$name" -Text (Get-Content -LiteralPath $src -Raw)
    Write-Host "OK inbox\$name" -ForegroundColor Green
}
