# Push full Cornerman work queue + active briefs to Green inbox.
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')

$briefs = @(
    @{ rel = 'lifepunch\addons\docs\briefs\CORNERMAN_WORK_QUEUE.md'; inbox = 'CORNERMAN_WORK_QUEUE.md' },
    @{ rel = 'lifepunch\addons\docs\briefs\CORNERMAN_COKE_DRUG_INTAKE_TASK.md'; inbox = 'CORNERMAN_COKE_DRUG_INTAKE_TASK.md' },
    @{ rel = 'lifepunch\addons\docs\briefs\CORNERMAN_DEAGLE_DISTILL_TASK.md'; inbox = 'CORNERMAN_DEAGLE_DISTILL_TASK.md' },
    @{ rel = 'lifepunch\addons\docs\briefs\CORNERMAN_BITMINER_PHASE2_MENU_TASK.md'; inbox = 'CORNERMAN_BITMINER_PHASE2_MENU_TASK.md' },
    @{ rel = 'lifepunch\addons\docs\briefs\BITMINER_VMAT_AUDIT.md'; inbox = 'BITMINER_VMAT_AUDIT.md' },
    @{ rel = 'lifepunch\addons\docs\briefs\DEAGLE_WEAPON_BRIEF.md'; inbox = 'DEAGLE_WEAPON_BRIEF.md' },
    @{ rel = 'lifepunch\addons\docs\COKE_DRUG_RESKIN_SPEC.md'; inbox = 'COKE_DRUG_RESKIN_SPEC.md' },
    @{ rel = 'lifepunch\addons\docs\BITMINER_UX_SPEC.md'; inbox = 'BITMINER_UX_SPEC.md' },
    @{ rel = 'lifepunch\addons\docs\reference\WEED_ENGINE_ENTITY_INDEX.md'; inbox = 'WEED_ENGINE_ENTITY_INDEX.md' },
    @{ rel = 'lifepunch\addons\Assets\addons\lifepunch\advanceddrugprocessing\ASSET_INVENTORY.md'; inbox = 'COKE_ASSET_INVENTORY.md' },
    @{ rel = 'lifepunch\addons\Assets\addons\lifepunch\advanceddrugprocessing\COKE_LINE_MAP.md'; inbox = 'COKE_LINE_MAP.md' },
    @{ rel = 'lifepunch\addons\Assets\addons\lifepunch\bitcoinmining\ASSET_INVENTORY.md'; inbox = 'BITMINER_ASSET_INVENTORY.md' }
)

foreach ($b in $briefs) {
    $src = Join-Path $RepoRoot $b.rel
    if (-not (Test-Path -LiteralPath $src)) { throw "Missing $src" }
    $dest = "C:\lifepunch\cornerman\inbox\$($b.inbox)"
    Push-CornermanText -Path $dest -Text (Get-Content -LiteralPath $src -Raw)
    Write-Host "OK inbox\$($b.inbox)" -ForegroundColor Green
}

$directive = @{
    id         = 'cornerman-work-queue-2026-06-11'
    priority   = 'high'
    lane       = 'cornerman'
    title      = 'Active work queue — coke, deagle, bitminer Phase 2'
    summary    = 'Pull main, then tasks 1-4 in CORNERMAN_WORK_QUEUE.md. Local commits only; Red publishes.'
    primaryDoc = 'CORNERMAN_WORK_QUEUE.md'
    tasks      = @(
        @{ order = 1; id = 'coke-intake'; doc = 'CORNERMAN_COKE_DRUG_INTAKE_TASK.md' },
        @{ order = 2; id = 'deagle-distill'; doc = 'CORNERMAN_DEAGLE_DISTILL_TASK.md' },
        @{ order = 3; id = 'bitminer-phase2'; doc = 'CORNERMAN_BITMINER_PHASE2_MENU_TASK.md' },
        @{ order = 4; id = 'deagle-rag'; doc = 'DEAGLE_WEAPON_BRIEF.md' }
    )
} | ConvertTo-Json -Depth 5

Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\CORNERMAN_WORK_QUEUE.json' -Text $directive
Write-Host 'OK inbox\CORNERMAN_WORK_QUEUE.json' -ForegroundColor Green

# Mirror deagle brief to outbox for RAG seed
$deagle = Join-Path $RepoRoot 'lifepunch\addons\docs\briefs\DEAGLE_WEAPON_BRIEF.md'
Push-CornermanText -Path 'C:\lifepunch\cornerman\outbox\DEAGLE_WEAPON_BRIEF.md' -Text (Get-Content -LiteralPath $deagle -Raw)
Write-Host 'OK outbox\DEAGLE_WEAPON_BRIEF.md' -ForegroundColor Green
