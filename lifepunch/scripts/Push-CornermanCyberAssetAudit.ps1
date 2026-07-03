# Push cyber ecosystem asset audit pack to Green inbox.
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')

$files = @(
    @{ rel = 'lifepunchaddons\docs\briefs\CORNERMAN_CYBER_ASSET_AUDIT_TASK.md'; inbox = 'CORNERMAN_CYBER_ASSET_AUDIT_TASK.md' },
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\CYBER_ASSET_AUDIT_2026-06-11.md'; inbox = 'CYBER_ASSET_AUDIT_2026-06-11.md' },
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\MODELDOC_CHECKLIST_CYBER_2026-06-11.md'; inbox = 'MODELDOC_CHECKLIST_CYBER_2026-06-11.md' },
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\PROTECTION_GREP_CYBER_2026-06-11.md'; inbox = 'PROTECTION_GREP_CYBER_2026-06-11.md' },
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\PUBLISH_STAGING_DRYRUN_2026-06-11.md'; inbox = 'PUBLISH_STAGING_DRYRUN_2026-06-11.md' },
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\to-cornerman-cyber-asset-audit.txt'; inbox = 'to-cornerman-cyber-asset-audit.txt' },
    @{ rel = 'lifepunchaddons\Assets\addons\lifepunch\bitcoinmining\ASSET_INVENTORY.md'; inbox = 'BITCOINMINING_ASSET_INVENTORY.md' },
    @{ rel = 'lifepunchaddons\docs\ASSET_INTAKE_CYBER_ECOSYSTEM.md'; inbox = 'ASSET_INTAKE_CYBER_ECOSYSTEM.md' },
    @{ rel = 'lifepunchaddons\docs\LIFEPUNCH_CYBER_ECOSYSTEM.md'; inbox = 'LIFEPUNCH_CYBER_ECOSYSTEM.md' },
    @{ rel = 'lifepunchaddons\docs\briefs\CORNERMAN_WORK_QUEUE.md'; inbox = 'CORNERMAN_WORK_QUEUE.md' }
)

foreach ($f in $files) {
    $src = Join-Path $RepoRoot $f.rel
    if (-not (Test-Path -LiteralPath $src)) { throw "Missing $src" }
    $dest = "C:\lifepunch\cornerman\inbox\$($f.inbox)"
    Push-CornermanText -Path $dest -Text (Get-Content -LiteralPath $src -Raw)
    Write-Host "OK inbox\$($f.inbox)" -ForegroundColor Green
}

$directive = @{
    id         = 'cornerman-cyber-asset-audit-2026-06-11'
    priority   = 'P0b'
    lane       = 'cornerman'
    title      = 'Cyber ecosystem asset audit (owner on legal)'
    summary    = 'Validate Red pre-draft audits. Extend if repo drifted. Owner gets ModelDoc checklist + publish dry-run.'
    primaryDoc = 'CORNERMAN_CYBER_ASSET_AUDIT_TASK.md'
    warmModel  = 'distill'
    tasks      = @(
        @{ order = 1; id = 'validate-audit'; output = 'CYBER_ASSET_AUDIT_2026-06-11.md' },
        @{ order = 2; id = 'protection-grep'; output = 'PROTECTION_GREP_CYBER_2026-06-11.md' }
    )
} | ConvertTo-Json -Depth 5

Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\CORNERMAN_CYBER_ASSET_AUDIT.json' -Text $directive
Write-Host 'OK inbox\CORNERMAN_CYBER_ASSET_AUDIT.json' -ForegroundColor Green
