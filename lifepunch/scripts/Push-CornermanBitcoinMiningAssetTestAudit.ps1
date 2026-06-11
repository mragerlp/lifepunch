# Push Bitcoin mining asset test-audit task to Green inbox.
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')

$files = @(
    @{ rel = 'lifepunch\addons\docs\briefs\CORNERMAN_BITCOINMINING_ASSET_TEST_AUDIT_TASK.md'; inbox = 'CORNERMAN_BITCOINMINING_ASSET_TEST_AUDIT_TASK.md' },
    @{ rel = 'lifepunch\addons\Assets\addons\lifepunch\bitcoinmining\ASSET_INVENTORY.md'; inbox = 'BITCOINMINING_ASSET_INVENTORY.md' },
    @{ rel = 'lifepunch\addons\Code\Addons\lifepunch\bitcoinmining\docs\BITCOINMINING_PLAYTEST.md'; inbox = 'BITCOINMINING_PLAYTEST.md' },
    @{ rel = 'lifepunch\addons\docs\BITCOINMINING_HUB_ARCH.md'; inbox = 'BITCOINMINING_HUB_ARCH.md' },
    @{ rel = 'lifepunch\addons\docs\BITCOINMINING_ENCRYPTION_SPEC.md'; inbox = 'BITCOINMINING_ENCRYPTION_SPEC.md' },
    @{ rel = 'lifepunch\addons\docs\TECH_DEBT.md'; inbox = 'TECH_DEBT.md' },
    @{ rel = 'lifepunch\addons\docs\briefs\BITCOINMINING_PROTECTION_CHECKLIST.md'; inbox = 'BITCOINMINING_PROTECTION_CHECKLIST.md' },
    @{ rel = 'lifepunch\addons\docs\ASSET_INTAKE_CYBER_ECOSYSTEM.md'; inbox = 'ASSET_INTAKE_CYBER_ECOSYSTEM.md' },
    @{ rel = 'lifepunch\addons\docs\briefs\CORNERMAN_WORK_QUEUE.md'; inbox = 'CORNERMAN_WORK_QUEUE.md' },
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\to-cornerman-bitcoinmining-asset-test.txt'; inbox = 'to-cornerman-bitcoinmining-asset-test.txt' }
)

foreach ($f in $files) {
    $src = Join-Path $RepoRoot $f.rel
    if (-not (Test-Path -LiteralPath $src)) { throw "Missing $src" }
    $dest = "C:\lifepunch\cornerman\inbox\$($f.inbox)"
    Push-CornermanText -Path $dest -Text (Get-Content -LiteralPath $src -Raw)
    Write-Host "OK inbox\$($f.inbox)" -ForegroundColor Green
}

$directive = @{
    id         = 'cornerman-bitcoinmining-asset-test-2026-06-11'
    priority   = 'P1b'
    lane       = 'cornerman'
    title      = 'Bitcoin mining — asset test-readiness audit'
    summary    = 'Owner: can we test bitcoinmining now? Walk assets vs BITCOINMINING_PLAYTEST.md. Deliver outbox/BITCOINMINING_TEST_READINESS.md with GO/PARTIAL/BLOCKED.'
    primaryDoc = 'CORNERMAN_BITCOINMINING_ASSET_TEST_AUDIT_TASK.md'
    warmModel  = 'distill'
    tasks      = @(
        @{ order = 1; id = 'file-inventory'; output = 'BITCOINMINING_ASSET_FILE_TREE.txt' },
        @{ order = 2; id = 'test-readiness'; output = 'BITCOINMINING_TEST_READINESS.md' }
    )
} | ConvertTo-Json -Depth 5

Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\BITCOINMINING_ASSET_TEST_DIRECTIVE.json' -Text $directive
Write-Host 'OK inbox\BITCOINMINING_ASSET_TEST_DIRECTIVE.json' -ForegroundColor Green
Write-Host ''
Write-Host 'Next: Send-CornermanWorkflow.ps1 -Action MonorepoPull' -ForegroundColor Cyan
Write-Host '      Send-CornermanWorkflow.ps1 -Action WarmDistill -Message "BitcoinMiningAddon asset test audit P1b"' -ForegroundColor Cyan
