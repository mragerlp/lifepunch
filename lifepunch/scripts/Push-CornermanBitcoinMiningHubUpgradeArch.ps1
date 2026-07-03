# Push Bitcoin hub/GPU upgrade architecture distill brief to Cornerman inbox (Red -> Green).
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')

$files = @(
    @{ rel = 'lifepunchaddons\docs\briefs\CORNERMAN_BITCOINMINING_HUB_UPGRADE_ARCH_TASK.md'; inbox = 'CORNERMAN_BITCOINMINING_HUB_UPGRADE_ARCH_TASK.md' },
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\to-cornerman-bitcoinmining-hub-upgrade-arch.txt'; inbox = 'to-cornerman-bitcoinmining-hub-upgrade-arch.txt' },
    @{ rel = 'lifepunch\docs\handoff\cornerman-inbox\BITCOINMINING_UPGRADE_ARCH_PREP_2026-06-25.md'; inbox = 'BITCOINMINING_UPGRADE_ARCH_PREP_2026-06-25.md' },
    @{ rel = 'lifepunchaddons\docs\BITCOINMINING_HUB_ARCH.md'; inbox = 'BITCOINMINING_HUB_ARCH.md' },
    @{ rel = 'lifepunchaddons\docs\BITCOINMINING_UX_SPEC.md'; inbox = 'BITCOINMINING_UX_SPEC.md' },
    @{ rel = 'lifepunchaddons\Code\Addons\lifepunch\bitcoinmining\docs\BITCOINMINING_TERMINAL_DOCTRINE.md'; inbox = 'BITCOINMINING_TERMINAL_DOCTRINE.md' },
    @{ rel = 'lifepunchaddons\Code\Addons\lifepunch\bitcoinmining\LpBitcoinEconomy.cs'; inbox = 'LpBitcoinEconomy.cs' },
    @{ rel = 'lifepunchaddons\Code\Addons\lifepunch\bitcoinmining\LpBitcoinRackEntity.cs'; inbox = 'LpBitcoinRackEntity.cs' },
    @{ rel = 'lifepunchaddons\Code\Addons\lifepunch\bitcoinmining\LpBitcoinIdent.cs'; inbox = 'LpBitcoinIdent.cs' }
)

foreach ( $f in $files ) {
    $src = Join-Path $RepoRoot $f.rel
    if ( -not ( Test-Path -LiteralPath $src ) ) { throw "Missing $src" }
    $dest = "C:\lifepunch\cornerman\inbox\$($f.inbox)"
    Push-CornermanText -Path $dest -Text ( Get-Content -LiteralPath $src -Raw )
    Write-Host "OK inbox\$($f.inbox)" -ForegroundColor Green
}

$directive = @{
    id         = 'cornerman-bitcoinmining-hub-upgrade-arch-2026-06-25'
    priority   = 'P0-prep'
    lane       = 'cornerman'
    title      = 'Bitcoin hub vs GPU upgrade architecture — distill prep (hold code)'
    summary    = 'Owner overhauling upgrade split: hub=controller, servers=GPU hashing. Distill 7 outbox docs. Wait for final ChatGPT plan before Red ships.'
    primaryDoc = 'CORNERMAN_BITCOINMINING_HUB_UPGRADE_ARCH_TASK.md'
    warmModel  = 'distill'
    tasks      = @(
        @{ order = 1; id = 'controller-vs-hardware'; output = 'BITCOINMINING_CONTROLLER_VS_HARDWARE.md' },
        @{ order = 2; id = 'upgrade-taxonomy'; output = 'BITCOINMINING_UPGRADE_TAXONOMY.md' },
        @{ order = 3; id = 'economy-migration'; output = 'BITCOINMINING_ECONOMY_MIGRATION_NOTES.md' },
        @{ order = 4; id = 'hub-ui-tab-plan'; output = 'BITCOINMINING_HUB_UI_TAB_PLAN.md' },
        @{ order = 5; id = 'terminal-copy'; output = 'BITCOINMINING_TERMINAL_COPY_PASS.md' },
        @{ order = 6; id = 'doc-drift'; output = 'BITCOINMINING_DOC_DRIFT_FIXLIST.md' },
        @{ order = 7; id = 'chatgpt-merge-shell'; output = 'BITCOINMINING_CHATGPT_PROMPT_MERGE.md' }
    )
} | ConvertTo-Json -Depth 5

Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\cornerman-inbox-directive.json' -Text $directive
Write-Host 'OK inbox\cornerman-inbox-directive.json' -ForegroundColor Green
Write-Host 'Done — Green: read to-cornerman-bitcoinmining-hub-upgrade-arch.txt then WarmDistill' -ForegroundColor Cyan
