# Push Hacker Job P0 kickoff to Green inbox + workflow cue.
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')

$files = @(
    @{ rel = 'lifepunch\addons\docs\HACKER_JOB_KICKOFF.md'; inbox = 'HACKER_JOB_KICKOFF.md' },
    @{ rel = 'lifepunch\addons\docs\HACKER_JOB_SPEC.md'; inbox = 'HACKER_JOB_SPEC.md' },
    @{ rel = 'lifepunch\addons\docs\HACKER_OPS_CONSOLE_SPEC.md'; inbox = 'HACKER_OPS_CONSOLE_SPEC.md' },
    @{ rel = 'lifepunch\addons\docs\HACKER_PVP_INFRA.md'; inbox = 'HACKER_PVP_INFRA.md' },
    @{ rel = 'lifepunch\addons\docs\UPGRADE_TIER_STANDARD.md'; inbox = 'UPGRADE_TIER_STANDARD.md' },
    @{ rel = 'lifepunch\addons\docs\RED_HACKER_JOB_BUILD.md'; inbox = 'RED_HACKER_JOB_BUILD.md' },
    @{ rel = 'lifepunch\addons\docs\briefs\CORNERMAN_HACKER_JOB_TERMINAL_TASK.md'; inbox = 'CORNERMAN_HACKER_JOB_TERMINAL_TASK.md' },
    @{ rel = 'lifepunch\addons\docs\briefs\HACKER_JOB_TERMINAL_BRIEF.md'; inbox = 'HACKER_JOB_TERMINAL_BRIEF.md' },
    @{ rel = 'lifepunch\addons\docs\reference\HACKER_TERMINAL_FLOW.md'; inbox = 'HACKER_TERMINAL_FLOW.md' },
    @{ rel = 'lifepunch\addons\docs\reference\TERMINAL_PUZZLE_CATALOG.md'; inbox = 'TERMINAL_PUZZLE_CATALOG.md' },
    @{ rel = 'lifepunch\addons\docs\reference\GOVERNMENT_DATABASE_TERMINAL_SPEC.md'; inbox = 'GOVERNMENT_DATABASE_TERMINAL_SPEC.md' },
    @{ rel = 'lifepunch\addons\docs\briefs\TERMINAL_PLATFORM_TOKENS.scss'; inbox = 'TERMINAL_PLATFORM_TOKENS.scss' },
    @{ rel = 'lifepunch\addons\Code\Addons\lifepunch\hackerjob\docs\HACKER_JOB_PLAYTEST.md'; inbox = 'HACKER_JOB_PLAYTEST.md' },
    @{ rel = 'lifepunch\addons\Code\Addons\lifepunch\hackerjob\docs\HACKER_SERVER_RACK_SPEC.md'; inbox = 'HACKER_SERVER_RACK_SPEC.md' },
    @{ rel = 'lifepunch\addons\docs\briefs\CORNERMAN_WORK_QUEUE.md'; inbox = 'CORNERMAN_WORK_QUEUE.md' },
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\to-cornerman-hacker-job.txt'; inbox = 'to-cornerman-hacker-job.txt' },
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\to-vengeance-hacker-job-start.txt'; inbox = 'to-vengeance-hacker-job-start.txt' },
    @{ rel = 'lifepunch\addons\docs\LIFEPUNCH_CYBER_ECOSYSTEM.md'; inbox = 'LIFEPUNCH_CYBER_ECOSYSTEM.md' },
    @{ rel = 'lifepunch\addons\docs\BITCOINMINING_ENCRYPTION_SPEC.md'; inbox = 'BITCOINMINING_ENCRYPTION_SPEC.md' }
)

foreach ($f in $files) {
    $src = Join-Path $RepoRoot $f.rel
    if (-not (Test-Path -LiteralPath $src)) { throw "Missing $src" }
    $dest = "C:\lifepunch\cornerman\inbox\$($f.inbox)"
    Push-CornermanText -Path $dest -Text (Get-Content -LiteralPath $src -Raw)
    Write-Host "OK inbox\$($f.inbox)" -ForegroundColor Green
}

$directive = @{
    id         = 'cornerman-hacker-job-2026-06-11'
    priority   = 'P0'
    lane       = 'cornerman'
    title      = 'Hacker Job — distill + UI notes (owner start)'
    summary    = 'Owner pivot: Hacker Job active. Read to-cornerman-hacker-job.txt. Distill puzzle catalog, PvP flow, auth pattern. Cyber ecosystem P1 parallel.'
    primaryDoc = 'CORNERMAN_HACKER_JOB_TERMINAL_TASK.md'
    warmModel  = 'distill'
    tasks      = @(
        @{ order = 1; id = 'hacker-flow'; output = 'HACKER_TERMINAL_FLOW_NOTES.md' },
        @{ order = 2; id = 'puzzle-catalog'; output = 'TERMINAL_PUZZLE_CATALOG.md' },
        @{ order = 3; id = 'pvp-flow'; output = 'HACKER_PVP_INFRA_FLOW.md' },
        @{ order = 4; id = 'auth-pattern'; output = 'HASHD_AUTH_PATTERN.md' },
        @{ order = 5; id = 'ui-review'; output = 'HACKER_UI_REVIEW_NOTES.md' }
    )
} | ConvertTo-Json -Depth 5

Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\HACKER_JOB_DIRECTIVE.json' -Text $directive
Write-Host 'OK inbox\HACKER_JOB_DIRECTIVE.json' -ForegroundColor Green
Write-Host ''
Write-Host 'Next: Send-CornermanWorkflow.ps1 -Action WarmDistill -Message "Hacker Job P0"' -ForegroundColor Cyan
