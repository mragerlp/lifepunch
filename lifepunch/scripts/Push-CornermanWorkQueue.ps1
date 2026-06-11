# Push full Cornerman work queue + active briefs to Green inbox.
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')

$briefs = @(
    @{ rel = 'lifepunch\addons\docs\briefs\CORNERMAN_WORK_QUEUE.md'; inbox = 'CORNERMAN_WORK_QUEUE.md' },
    @{ rel = 'lifepunch\addons\docs\briefs\CORNERMAN_AK47_CS2_STUDY_TASK.md'; inbox = 'CORNERMAN_AK47_CS2_STUDY_TASK.md' },
    @{ rel = 'lifepunch\addons\docs\briefs\AK47_CS2_STUDY_BRIEF.md'; inbox = 'AK47_CS2_STUDY_BRIEF.md' },
    @{ rel = 'lifepunch\addons\docs\reference\CS2_AK47_STUDY.md'; inbox = 'CS2_AK47_STUDY_SCAFFOLD.md' },
    @{ rel = 'lifepunch\addons\docs\reference\M4A1_CLASS_ANIM_MAP.md'; inbox = 'M4A1_CLASS_ANIM_MAP_SCAFFOLD.md' },
    @{ rel = 'lifepunch\addons\docs\CS2_WEAPON_HARVEST.md'; inbox = 'CS2_WEAPON_HARVEST.md' },
    @{ rel = 'lifepunch\addons\docs\briefs\CORNERMAN_COKE_DRUG_INTAKE_TASK.md'; inbox = 'CORNERMAN_COKE_DRUG_INTAKE_TASK.md' },
    @{ rel = 'lifepunch\addons\docs\briefs\CORNERMAN_DEAGLE_DISTILL_TASK.md'; inbox = 'CORNERMAN_DEAGLE_DISTILL_TASK.md' },
    @{ rel = 'lifepunch\addons\docs\briefs\CORNERMAN_BITCOINMINING_DUAL_RACK_TASK.md'; inbox = 'CORNERMAN_BITCOINMINING_DUAL_RACK_TASK.md' },
    @{ rel = 'lifepunch\addons\docs\briefs\BITCOINMINING_DUAL_RACK_BRIEF.md'; inbox = 'BITCOINMINING_DUAL_RACK_BRIEF.md' },
    @{ rel = 'lifepunch\addons\docs\reference\BITCOINMINING_DUAL_RACK_SPEC.md'; inbox = 'BITCOINMINING_DUAL_RACK_SPEC_SCAFFOLD.md' },
    @{ rel = 'lifepunch\addons\docs\briefs\CORNERMAN_BITCOINMINING_PHASE2_MENU_TASK.md'; inbox = 'CORNERMAN_BITCOINMINING_PHASE2_MENU_TASK.md' },
    @{ rel = 'lifepunch\addons\docs\briefs\BITCOINMINING_VMAT_AUDIT.md'; inbox = 'BITCOINMINING_VMAT_AUDIT.md' },
    @{ rel = 'lifepunch\addons\docs\briefs\DEAGLE_WEAPON_BRIEF.md'; inbox = 'DEAGLE_WEAPON_BRIEF.md' },
    @{ rel = 'lifepunch\addons\docs\COKE_DRUG_RESKIN_SPEC.md'; inbox = 'COKE_DRUG_RESKIN_SPEC.md' },
    @{ rel = 'lifepunch\addons\docs\BITCOINMINING_UX_SPEC.md'; inbox = 'BITCOINMINING_UX_SPEC.md' },
    @{ rel = 'lifepunch\addons\docs\reference\WEED_ENGINE_ENTITY_INDEX.md'; inbox = 'WEED_ENGINE_ENTITY_INDEX.md' },
    @{ rel = 'lifepunch\addons\Assets\addons\lifepunch\advanceddrugprocessing\ASSET_INVENTORY.md'; inbox = 'COKE_ASSET_INVENTORY.md' },
    @{ rel = 'lifepunch\addons\Assets\addons\lifepunch\advanceddrugprocessing\COKE_LINE_MAP.md'; inbox = 'COKE_LINE_MAP.md' },
    @{ rel = 'lifepunch\addons\Assets\addons\lifepunch\bitcoinmining\ASSET_INVENTORY.md'; inbox = 'BITCOINMINING_ASSET_INVENTORY.md' },
    @{ rel = 'lifepunch\addons\docs\briefs\CORNERMAN_HACKER_JOB_TERMINAL_TASK.md'; inbox = 'CORNERMAN_HACKER_JOB_TERMINAL_TASK.md' },
    @{ rel = 'lifepunch\addons\docs\briefs\HACKER_JOB_TERMINAL_BRIEF.md'; inbox = 'HACKER_JOB_TERMINAL_BRIEF.md' },
    @{ rel = 'lifepunch\addons\docs\HACKER_JOB_SPEC.md'; inbox = 'HACKER_JOB_SPEC.md' },
    @{ rel = 'lifepunch\addons\docs\reference\HACKER_TERMINAL_FLOW.md'; inbox = 'HACKER_TERMINAL_FLOW_SCAFFOLD.md' },
    @{ rel = 'lifepunch\addons\docs\reference\TERMINAL_PUZZLE_CATALOG.md'; inbox = 'TERMINAL_PUZZLE_CATALOG_SCAFFOLD.md' },
    @{ rel = 'lifepunch\addons\docs\reference\GOVERNMENT_DATABASE_TERMINAL_SPEC.md'; inbox = 'GOVERNMENT_DATABASE_TERMINAL_SPEC_SCAFFOLD.md' },
    @{ rel = 'lifepunch\addons\docs\briefs\TERMINAL_PLATFORM_TOKENS.scss'; inbox = 'TERMINAL_PLATFORM_TOKENS.scss' }
)

foreach ($b in $briefs) {
    $src = Join-Path $RepoRoot $b.rel
    if (-not (Test-Path -LiteralPath $src)) { throw "Missing $src" }
    $dest = "C:\lifepunch\cornerman\inbox\$($b.inbox)"
    Push-CornermanText -Path $dest -Text (Get-Content -LiteralPath $src -Raw)
    Write-Host "OK inbox\$($b.inbox)" -ForegroundColor Green
}

$directive = @{
    id         = 'cornerman-work-queue-2026-06-11-hacker-terminal'
    priority   = 'high'
    lane       = 'cornerman'
    title      = 'Active work queue — Hacker Job terminal depth (after AK47 guns)'
    summary    = 'Pull main. #1 NEW: Hacker Job terminal — cornerman.exe flow, puzzle catalog, platform tokens, gov DB scaffold. BitcoinMiningAddon terminal is the shell reference.'
    primaryDoc = 'CORNERMAN_WORK_QUEUE.md'
    tasks      = @(
        @{ order = 0; id = 'ak47-cs2-study'; doc = 'CORNERMAN_AK47_CS2_STUDY_TASK.md' },
        @{ order = 1; id = 'hacker-terminal'; doc = 'CORNERMAN_HACKER_JOB_TERMINAL_TASK.md' },
        @{ order = 2; id = 'coke-intake'; doc = 'CORNERMAN_COKE_DRUG_INTAKE_TASK.md' },
        @{ order = 3; id = 'deagle-distill'; doc = 'CORNERMAN_DEAGLE_DISTILL_TASK.md' },
        @{ order = 4; id = 'bitcoinmining-dual-rack'; doc = 'CORNERMAN_BITCOINMINING_DUAL_RACK_TASK.md' },
        @{ order = 5; id = 'bitcoinmining-phase2'; doc = 'CORNERMAN_BITCOINMINING_PHASE2_MENU_TASK.md' },
        @{ order = 6; id = 'deagle-rag'; doc = 'DEAGLE_WEAPON_BRIEF.md' }
    )
} | ConvertTo-Json -Depth 5

Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\CORNERMAN_WORK_QUEUE.json' -Text $directive
Write-Host 'OK inbox\CORNERMAN_WORK_QUEUE.json' -ForegroundColor Green

# Mirror weapon briefs to outbox for RAG seed
$deagle = Join-Path $RepoRoot 'lifepunch\addons\docs\briefs\DEAGLE_WEAPON_BRIEF.md'
Push-CornermanText -Path 'C:\lifepunch\cornerman\outbox\DEAGLE_WEAPON_BRIEF.md' -Text (Get-Content -LiteralPath $deagle -Raw)
Write-Host 'OK outbox\DEAGLE_WEAPON_BRIEF.md' -ForegroundColor Green

$akBrief = Join-Path $RepoRoot 'lifepunch\addons\docs\briefs\AK47_CS2_STUDY_BRIEF.md'
Push-CornermanText -Path 'C:\lifepunch\cornerman\outbox\AK47_CS2_STUDY_BRIEF.md' -Text (Get-Content -LiteralPath $akBrief -Raw)
Write-Host 'OK outbox\AK47_CS2_STUDY_BRIEF.md' -ForegroundColor Green

$dualRack = Join-Path $RepoRoot 'lifepunch\addons\docs\briefs\BITCOINMINING_DUAL_RACK_BRIEF.md'
Push-CornermanText -Path 'C:\lifepunch\cornerman\outbox\BITCOINMINING_DUAL_RACK_BRIEF.md' -Text (Get-Content -LiteralPath $dualRack -Raw)
Write-Host 'OK outbox\BITCOINMINING_DUAL_RACK_BRIEF.md' -ForegroundColor Green

$hackerBrief = Join-Path $RepoRoot 'lifepunch\addons\docs\briefs\HACKER_JOB_TERMINAL_BRIEF.md'
Push-CornermanText -Path 'C:\lifepunch\cornerman\outbox\HACKER_JOB_TERMINAL_BRIEF.md' -Text (Get-Content -LiteralPath $hackerBrief -Raw)
Write-Host 'OK outbox\HACKER_JOB_TERMINAL_BRIEF.md' -ForegroundColor Green
