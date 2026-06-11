# Push DEAGLE_WEAPON_BRIEF.md to Cornerman inbox + outbox for Tier-3 RAG.
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')
$src = Join-Path $RepoRoot 'lifepunch\addons\docs\briefs\DEAGLE_WEAPON_BRIEF.md'
if (-not (Test-Path -LiteralPath $src)) { throw "Missing $src" }
$text = Get-Content -LiteralPath $src -Raw
foreach ($dest in @(
        'C:\lifepunch\cornerman\inbox\DEAGLE_WEAPON_BRIEF.md',
        'C:\lifepunch\cornerman\outbox\DEAGLE_WEAPON_BRIEF.md'
    )) {
    Push-CornermanText -Path $dest -Text $text
    Write-Host "OK $dest" -ForegroundColor Green
}
