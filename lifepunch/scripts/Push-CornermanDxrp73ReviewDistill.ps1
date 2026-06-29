# Push DXRP #73 party review distill brief to Green inbox (read-only; no LP proprietary code).
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')

$files = @(
    @{ rel = 'lifepunch\docs\handoff\dxrp\CORNERMAN_DXRP_73_REVIEW_DISTILL.md'; inbox = 'CORNERMAN_DXRP_73_REVIEW_DISTILL.md' },
    @{ rel = 'lifepunch\docs\handoff\dxrp\DXRP_73_BRANCH_MANIFEST.txt'; inbox = 'DXRP_73_BRANCH_MANIFEST.txt' },
    @{ rel = 'lifepunch\docs\handoff\LIFEPUNCH_AI_REPORT_TEMPLATE.md'; inbox = 'LIFEPUNCH_AI_REPORT_TEMPLATE.md' }
)

foreach ($f in $files) {
    $src = Join-Path $RepoRoot $f.rel
    if (-not (Test-Path -LiteralPath $src)) { throw "Missing $src" }
    Push-CornermanText -Path "C:\lifepunch\cornerman\inbox\$($f.inbox)" -Text (Get-Content -LiteralPath $src -Raw)
    Write-Host "OK inbox\$($f.inbox)" -ForegroundColor Green
}

$directive = @{
    id         = 'dxrp-73-review-distill-2026-06-28'
    priority   = 'P0'
    lane       = 'dxrp-upstream'
    focus      = 'DXRP'
    title      = 'DXRP #73 Party System — Review Distill + PR Checklist'
    summary    = 'Read-only distill from DXRP_73_BRANCH_MANIFEST.txt. Deliver outbox DXRP_73_* packets. No code, no commit, no PR, no playtest claims.'
    routeTags  = @('GREEN READ-ONLY', 'OPUS REQUIRED for PartySystem/Sync', 'AUTO OK for UI/locale/PR text')
    branchHead = '9e424f2'
    warmModel  = 'distill'
    primaryDoc = 'CORNERMAN_DXRP_73_REVIEW_DISTILL.md'
} | ConvertTo-Json -Depth 5

Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\CORNERMAN_DXRP_73_DIRECTIVE.json' -Text $directive
Write-Host 'OK inbox\CORNERMAN_DXRP_73_DIRECTIVE.json' -ForegroundColor Green
