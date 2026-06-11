# Push off-Cursor handoff + updated work queue to Green inbox (no Cursor required on box).
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')

$files = @(
    @{ rel = 'lifepunch\addons\docs\briefs\CORNERMAN_INVENTORY_PROJECT_TASK.md'; inbox = 'CORNERMAN_INVENTORY_PROJECT_TASK.md' },
    @{ rel = 'lifepunch\docs\CORNERMAN_OFF_CURSOR_HANDOFF.md'; inbox = 'CORNERMAN_OFF_CURSOR_HANDOFF.md' },
    @{ rel = 'lifepunch\docs\CORNERMAN_MODEL_ROUTING.md'; inbox = 'CORNERMAN_MODEL_ROUTING.md' },
    @{ rel = 'lifepunch\addons\docs\briefs\CORNERMAN_WORK_QUEUE.md'; inbox = 'CORNERMAN_WORK_QUEUE.md' },
    @{ rel = 'lifepunch\addons\docs\BITMINER_FINISH_RUNBOOK.md'; inbox = 'BITMINER_FINISH_RUNBOOK.md' },
    @{ rel = 'lifepunch\addons\docs\reference\BITMINER_PORTAL_LISTING.md'; inbox = 'BITMINER_PORTAL_LISTING.md' }
)

foreach ($f in $files) {
    $src = Join-Path $RepoRoot $f.rel
    if (-not (Test-Path -LiteralPath $src)) { throw "Missing $src" }
    Push-CornermanText -Path "C:\lifepunch\cornerman\inbox\$($f.inbox)" -Text (Get-Content -LiteralPath $src -Raw)
    Write-Host "OK inbox\$($f.inbox)" -ForegroundColor Green
}

$directive = @{
    id       = 'cornerman-off-cursor-2026-06-11'
    priority = 'info'
    lane     = 'cornerman'
    title    = 'Green off-Cursor — Red owns git; read inbox only'
    summary  = 'P0 = Inventory project (Visible Pocket). distill default. No Cursor on Green. git reset --hard origin/main on clone.'
    primaryDoc = 'CORNERMAN_OFF_CURSOR_HANDOFF.md'
    redHead  = 'afdabd4+'
} | ConvertTo-Json -Depth 4

Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\CORNERMAN_OFF_CURSOR_DIRECTIVE.json' -Text $directive
Write-Host 'OK inbox\CORNERMAN_OFF_CURSOR_DIRECTIVE.json' -ForegroundColor Green
