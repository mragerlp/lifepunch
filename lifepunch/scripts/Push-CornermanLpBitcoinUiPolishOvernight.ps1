# Push LPBitcoin UI polish overnight brief to Cornerman inbox (Red -> Green).
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')

$files = @(
    @{ rel = 'lifepunchaddons\docs\briefs\CORNERMAN_LPBITCOIN_UI_POLISH_OVERNIGHT_TASK.md'; inbox = 'CORNERMAN_LPBITCOIN_UI_POLISH_OVERNIGHT_TASK.md' },
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\to-cornerman-lpbitcoin-ui-polish-overnight.txt'; inbox = 'to-cornerman-lpbitcoin-ui-polish-overnight.txt' },
    @{ rel = 'lifepunchaddons\docs\ACTIVE_WORKSTREAM.md'; inbox = 'ACTIVE_WORKSTREAM.md' },
    @{ rel = 'lifepunchaddons\docs\TERMINAL_BRAND_MATRIX.md'; inbox = 'TERMINAL_BRAND_MATRIX.md' },
    @{ rel = 'lifepunchaddons\docs\SBOX_RAZOR_SCSS_RULES.md'; inbox = 'SBOX_RAZOR_SCSS_RULES.md' },
    @{ rel = 'lifepunchaddons\docs\TECH_DEBT.md'; inbox = 'TECH_DEBT.md' },
    @{ rel = 'lifepunchaddons\Code\Addons\lifepunch\bitcoinmining\LpUiMenuLayout.scss'; inbox = 'LpUiMenuLayout.scss' },
    @{ rel = 'lifepunchaddons\Code\Addons\lifepunch\LifePunchUiShell.scss'; inbox = 'LifePunchUiShell.scss' }
)

foreach ($f in $files) {
    $src = Join-Path $RepoRoot $f.rel
    if (-not (Test-Path -LiteralPath $src)) { throw "Missing $src" }
    Push-CornermanText -Path "C:\lifepunch\cornerman\inbox\$($f.inbox)" -Text (Get-Content -LiteralPath $src -Raw)
    Write-Host "OK inbox\$($f.inbox)" -ForegroundColor Green
}

$directive = @{
    id         = 'cornerman-lpbitcoin-ui-polish-overnight-2026-06-20'
    priority   = 'P0'
    lane       = 'lifepunchbitcoin'
    title      = 'LPBitcoin UI polish overnight (~12h) — July ship prep'
    summary    = 'Terminal scroll + hub panel ears fixed on Red; distill acceptance scripts, parity matrix, uniform plan, host extraction draft, July checklist. Owner back 11:59 PM EST.'
    primaryDoc = 'CORNERMAN_LPBITCOIN_UI_POLISH_OVERNIGHT_TASK.md'
    warmModel  = 'distill'
    hours      = 12
    ownerBack  = '2026-06-20T23:59:00-04:00'
    tasks      = @(
        @{ order = 1; id = 'terminal-scroll-acceptance'; output = 'LPBITCOIN_TERMINAL_SCROLL_ACCEPTANCE.md' },
        @{ order = 2; id = 'hub-panel-alignment'; output = 'LPBITCOIN_HUB_PANEL_ALIGNMENT_AUDIT.md' },
        @{ order = 3; id = 'hub-terminal-parity'; output = 'LPBITCOIN_HUB_TERMINAL_PARITY_MATRIX.md' },
        @{ order = 4; id = 'ui-shell-uniform'; output = 'LPBITCOIN_UI_SHELL_UNIFORM_PLAN.md' },
        @{ order = 5; id = 'hashd-host-extraction'; output = 'LPBITCOIN_HASHD_HOST_EXTRACTION_DRAFT.md'; model = 'coder' },
        @{ order = 6; id = 'razor-scss-validation'; output = 'LPBITCOIN_RAZOR_SCSS_VALIDATION_REPORT.md' },
        @{ order = 7; id = 'july-publish-checklist'; output = 'LPBITCOIN_JULY_PUBLISH_CHECKLIST.md' },
        @{ order = 8; id = 'job-one-pager'; output = 'BITCOINMINING_JOB_ROLEPLAY_ONE_PAGER.md' },
        @{ order = 9; id = 'sound-shortlist'; output = 'BITCOINMINING_SOUND_SHORTLIST.md' }
    )
} | ConvertTo-Json -Depth 5

Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\cornerman-inbox-directive.json' -Text $directive
Write-Host 'OK inbox\cornerman-inbox-directive.json' -ForegroundColor Green
Write-Host 'Done — Green: read to-cornerman-lpbitcoin-ui-polish-overnight.txt' -ForegroundColor Cyan
