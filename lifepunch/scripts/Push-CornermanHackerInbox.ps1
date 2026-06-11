# Push Hacker Job terminal briefs + resume failed queue tail to Green inbox.
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')

$briefs = @(
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

$queue = Join-Path $RepoRoot 'lifepunch\addons\docs\briefs\CORNERMAN_WORK_QUEUE.md'
Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\CORNERMAN_WORK_QUEUE.md' -Text (Get-Content -LiteralPath $queue -Raw)
Write-Host 'OK inbox\CORNERMAN_WORK_QUEUE.md' -ForegroundColor Green

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

$hackerBrief = Join-Path $RepoRoot 'lifepunch\addons\docs\briefs\HACKER_JOB_TERMINAL_BRIEF.md'
Push-CornermanText -Path 'C:\lifepunch\cornerman\outbox\HACKER_JOB_TERMINAL_BRIEF.md' -Text (Get-Content -LiteralPath $hackerBrief -Raw)
Write-Host 'OK outbox\HACKER_JOB_TERMINAL_BRIEF.md' -ForegroundColor Green
