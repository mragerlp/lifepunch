# Push Visible Pocket start brief + discovery to Cornerman inbox.
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')

$files = @(
    @{ rel = 'lifepunch\addons\docs\briefs\CORNERMAN_VISIBLE_POCKET_START.md'; inbox = 'CORNERMAN_VISIBLE_POCKET_START.md' },
    @{ rel = 'lifepunch\addons\docs\VISIBLE_POCKET_SPEC.md'; inbox = 'VISIBLE_POCKET_SPEC.md' },
    @{ rel = 'lifepunch\addons\docs\reference\DXRP_POCKET_DISCOVERY.md'; inbox = 'DXRP_POCKET_DISCOVERY.md' },
    @{ rel = 'lifepunch\addons\Code\Addons\lifepunch\visiblepocket\docs\VISIBLE_POCKET_PLAYTEST.md'; inbox = 'VISIBLE_POCKET_PLAYTEST.md' },
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\to-cornerman-visible-pocket.txt'; inbox = 'to-cornerman-visible-pocket.txt' },
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\VISIBLE_POCKET_DXRP_SUMMARY.txt'; inbox = 'VISIBLE_POCKET_DXRP_SUMMARY.txt' }
)

foreach ($f in $files) {
    $src = Join-Path $RepoRoot $f.rel
    if (-not (Test-Path -LiteralPath $src)) { throw "Missing $src" }
    Push-CornermanText -Path "C:\lifepunch\cornerman\inbox\$($f.inbox)" -Text (Get-Content -LiteralPath $src -Raw)
    Write-Host "OK inbox\$($f.inbox)" -ForegroundColor Green
}

$directive = @{
    id         = 'visible-pocket-start-2026-06'
    priority   = 'high'
    lane       = 'cornerman'
    title      = 'Visible Pocket — docs lane (VENGEANCE tests code)'
    summary    = 'Distill DXRP_POCKET_DISCOVERY; optional llad UI notes; no C# commits.'
    primaryDoc = 'CORNERMAN_VISIBLE_POCKET_START.md'
    vengeanceHead = 'a5e4461+'
} | ConvertTo-Json -Depth 4

Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\VISIBLE_POCKET_DIRECTIVE.json' -Text $directive
Write-Host 'OK inbox\VISIBLE_POCKET_DIRECTIVE.json' -ForegroundColor Green
