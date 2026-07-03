# Push Inventory / Visible Pocket project package to Cornerman inbox (primary Green lane).
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')

$files = @(
    @{ rel = 'lifepunchaddons\docs\briefs\CORNERMAN_INVENTORY_PROJECT_TASK.md'; inbox = 'CORNERMAN_INVENTORY_PROJECT_TASK.md' },
    @{ rel = 'lifepunchaddons\docs\briefs\CORNERMAN_VISIBLE_POCKET_START.md'; inbox = 'CORNERMAN_VISIBLE_POCKET_START.md' },
    @{ rel = 'lifepunchaddons\docs\briefs\CORNERMAN_WORK_QUEUE.md'; inbox = 'CORNERMAN_WORK_QUEUE.md' },
    @{ rel = 'lifepunch\docs\CORNERMAN_MODEL_ROUTING.md'; inbox = 'CORNERMAN_MODEL_ROUTING.md' },
    @{ rel = 'lifepunch\docs\CORNERMAN_OFF_CURSOR_HANDOFF.md'; inbox = 'CORNERMAN_OFF_CURSOR_HANDOFF.md' },
    @{ rel = 'lifepunchaddons\docs\VISIBLE_POCKET_SPEC.md'; inbox = 'VISIBLE_POCKET_SPEC.md' },
    @{ rel = 'lifepunchaddons\docs\reference\DXRP_POCKET_DISCOVERY.md'; inbox = 'DXRP_POCKET_DISCOVERY.md' },
    @{ rel = 'lifepunchaddons\docs\reference\LLAD_MODULAR_INVENTORY_STUDY.md'; inbox = 'LLAD_MODULAR_INVENTORY_STUDY.md' },
    @{ rel = 'lifepunchaddons\docs\RED_VENGEANCE_VISIBLE_POCKET_BUILD.md'; inbox = 'RED_VENGEANCE_VISIBLE_POCKET_BUILD.md' },
    @{ rel = 'lifepunchaddons\Code\Addons\lifepunch\visiblepocket\docs\VISIBLE_POCKET_PLAYTEST.md'; inbox = 'VISIBLE_POCKET_PLAYTEST.md' },
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\to-cornerman-visible-pocket.txt'; inbox = 'to-cornerman-visible-pocket.txt' },
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\VISIBLE_POCKET_DXRP_SUMMARY.txt'; inbox = 'VISIBLE_POCKET_DXRP_SUMMARY.txt' }
)

foreach ($f in $files) {
    $src = Join-Path $RepoRoot $f.rel
    if (-not (Test-Path -LiteralPath $src)) { throw "Missing $src" }
    Push-CornermanText -Path "C:\lifepunch\cornerman\inbox\$($f.inbox)" -Text (Get-Content -LiteralPath $src -Raw)
    Write-Host "OK inbox\$($f.inbox)" -ForegroundColor Green
}

$directivePath = Join-Path $Here 'cornerman-inbox-directive.json'
$directive = Get-Content -LiteralPath $directivePath -Raw | ConvertFrom-Json
Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\GREEN-WORKFLOW-DIRECTIVE.json' -Text (Get-Content -LiteralPath $directivePath -Raw)
Write-Host 'OK inbox\GREEN-WORKFLOW-DIRECTIVE.json' -ForegroundColor Green

$invDirective = @{
    id           = 'inventory-project-2026-06'
    priority     = 'P0'
    lane         = 'cornerman'
    title        = 'Inventory project — Visible Pocket (distill default)'
    summary      = 'Primary Green lane. distill for docs/llad UI notes; WarmCoder only for assigned HUD scss draft. No llad ship.'
    primaryDoc   = 'CORNERMAN_INVENTORY_PROJECT_TASK.md'
    modelDefault = 'distill'
    modelCoder   = 'WarmCoder only when brief task 6 assigned'
    doNot        = @('llad ship', 'visiblepocket C# commits', 's&box on Green')
} | ConvertTo-Json -Depth 4

Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\INVENTORY_PROJECT_DIRECTIVE.json' -Text $invDirective
Write-Host 'OK inbox\INVENTORY_PROJECT_DIRECTIVE.json' -ForegroundColor Green
