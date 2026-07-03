# Push bitcoinmining specs to Cornerman inbox for Tier-3 distill.
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')
foreach ($rel in @(
        'lifepunchaddons\docs\BITCOINMINING_UX_SPEC.md',
        'lifepunchaddons\docs\briefs\BITCOINMINING_ENTITY_BRIEF.md'
    )) {
    $src = Join-Path $RepoRoot $rel
    if (-not (Test-Path -LiteralPath $src)) { throw "Missing $src" }
    $name = Split-Path $src -Leaf
    Push-CornermanText -Path "C:\lifepunch\cornerman\inbox\$name" -Text (Get-Content -LiteralPath $src -Raw)
    Write-Host "OK inbox\$name" -ForegroundColor Green
}
