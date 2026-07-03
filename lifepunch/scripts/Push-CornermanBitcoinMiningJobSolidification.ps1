# Push Bitcoin Miner job solidification brief to Cornerman inbox (Red -> Green).
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')

$files = @(
    @{ rel = 'lifepunchaddons\docs\briefs\CORNERMAN_BITCOINMINING_JOB_SOLIDIFICATION_TASK.md'; inbox = 'CORNERMAN_BITCOINMINING_JOB_SOLIDIFICATION_TASK.md' },
    @{ rel = 'lifepunchaddons\docs\BITCOINMINING_HUB_ARCH.md'; inbox = 'BITCOINMINING_HUB_ARCH.md' },
    @{ rel = 'lifepunchaddons\docs\LIFEPUNCH_CYBER_ECOSYSTEM.md'; inbox = 'LIFEPUNCH_CYBER_ECOSYSTEM.md' },
    @{ rel = 'lifepunchaddons\Code\Addons\lifepunch\bitcoinmining\docs\BITCOINMINING_TERMINAL_DOCTRINE.md'; inbox = 'BITCOINMINING_TERMINAL_DOCTRINE.md' },
    @{ rel = 'lifepunchaddons\docs\PHYSICAL_TERMINAL_DOCTRINE.md'; inbox = 'PHYSICAL_TERMINAL_DOCTRINE.md' },
    @{ rel = 'lifepunchaddons\docs\reference\BITCOINMINING_PORTAL_LISTING.md'; inbox = 'BITCOINMINING_PORTAL_LISTING.md' },
    @{ rel = 'lifepunchaddons\Code\Addons\lifepunch\bitcoinmining\docs\BITCOINMINING_PLAYTEST.md'; inbox = 'BITCOINMINING_PLAYTEST.md' },
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\to-cornerman-bitcoinmining-job-solidification.txt'; inbox = 'to-cornerman-bitcoinmining-job-solidification.txt' }
)

foreach ($f in $files) {
    $src = Join-Path $RepoRoot $f.rel
    if (-not (Test-Path -LiteralPath $src)) { throw "Missing $src" }
    $dest = "C:\lifepunch\cornerman\inbox\$($f.inbox)"
    Push-CornermanText -Path $dest -Text (Get-Content -LiteralPath $src -Raw)
    Write-Host "OK inbox\$($f.inbox)" -ForegroundColor Green
}

$directive = @{
    id         = 'cornerman-bitcoinmining-job-solidification-2026-06-12'
    priority   = 'P1c'
    lane       = 'cornerman'
    title      = 'Bitcoin Miner job solidification — distill + Market draft'
    summary    = 'Owner locked miner as RP class: hub PIN gate + 3 placeables. Distill one-pager, purchase model, stale doc fixlist, Market listings, scale checklist, UI naming audit.'
    primaryDoc = 'CORNERMAN_BITCOINMINING_JOB_SOLIDIFICATION_TASK.md'
    warmModel  = 'distill'
    tasks      = @(
        @{ order = 1; id = 'roleplay-one-pager'; output = 'BITCOINMINING_JOB_ROLEPLAY_ONE_PAGER.md' },
        @{ order = 2; id = 'purchase-model'; output = 'BITCOINMINING_PURCHASE_MODEL.md' },
        @{ order = 3; id = 'stale-docs'; output = 'STALE_BITCOINMINING_DOC_FIXLIST.md' },
        @{ order = 4; id = 'market-listings'; output = 'BITCOINMINING_MARKET_LISTINGS_DRAFT.md' },
        @{ order = 5; id = 'scale-checklist'; output = 'BITCOINMINING_SCALE_CHECKLIST.md' },
        @{ order = 6; id = 'ui-naming'; output = 'BITCOINMINING_UI_NAMING_AUDIT.md' }
    )
} | ConvertTo-Json -Depth 5

Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\cornerman-inbox-directive.json' -Text $directive
Write-Host 'OK inbox\cornerman-inbox-directive.json' -ForegroundColor Green
Write-Host 'Done — Green: read to-cornerman-bitcoinmining-job-solidification.txt' -ForegroundColor Cyan
