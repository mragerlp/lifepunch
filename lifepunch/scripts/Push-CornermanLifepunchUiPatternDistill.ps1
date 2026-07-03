# Push the LIFEPUNCH Addon Menu + Upgrade-Path pattern DISTILL brief to Cornerman (Red -> Green).
# Green Deep prep (Opus/Grok packet prep). Distill/spec ONLY — Green holds code.
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')

$brief = 'lifepunchaddons\docs\briefs\CORNERMAN_LIFEPUNCH_UI_UPGRADE_PATTERN_DISTILL.md'
$src = Join-Path $RepoRoot $brief
if ( -not ( Test-Path -LiteralPath $src ) ) { throw "Missing $src" }

# Green reads source files from its own monorepo clone (C:\Projects\lifepunch); we only push the
# brief + a short pointer + the directive. Green must `git pull --rebase` first (brief Step 0).
Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\CORNERMAN_LIFEPUNCH_UI_UPGRADE_PATTERN_DISTILL.md' -Text ( Get-Content -LiteralPath $src -Raw )
Write-Host 'OK inbox\CORNERMAN_LIFEPUNCH_UI_UPGRADE_PATTERN_DISTILL.md' -ForegroundColor Green

$pointer = @'
GREEN DEEP — distill/spec prep, hold code.
1) cd C:\Projects\lifepunch ; git fetch ; git pull --rebase   (must include f5fca7d)
2) WarmDistill, then read CORNERMAN_LIFEPUNCH_UI_UPGRADE_PATTERN_DISTILL.md in this inbox.
3) Read the repo source files it lists (LpHashdPanel.razor/.scss, LpBitcoinDevSpawn.cs, the docs).
4) Produce the 5 outbox Markdown specs. NO C#/Razor/SCSS. Outputs feed Opus + Grok on VENGEANCE.
Eyes covered: repo only — no editor/playtest claims.
'@
Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\to-cornerman-lifepunch-ui-pattern-distill.txt' -Text $pointer
Write-Host 'OK inbox\to-cornerman-lifepunch-ui-pattern-distill.txt' -ForegroundColor Green

$directive = @{
    id         = 'cornerman-lifepunch-ui-upgrade-pattern-distill-2026-06-27'
    priority   = 'P0-prep'
    lane       = 'cornerman'
    route      = 'GREEN DEEP REQUIRED'
    title      = 'LIFEPUNCH addon menu + upgrade-path pattern — distill prep (hold code)'
    summary    = 'Extract the reusable menu shell + nav + component kit + upgrade-path model from the lpbitcoin Hub UI so Opus can architect shared components and other addons (Terminal UI, Money Printer Technician) ship as color/content deltas. Distill/spec only — no code.'
    primaryDoc = 'CORNERMAN_LIFEPUNCH_UI_UPGRADE_PATTERN_DISTILL.md'
    warmModel  = 'distill'
    holdCode   = $true
    tasks      = @(
        @{ order = 1; id = 'menu-pattern'; output = 'LIFEPUNCH_ADDON_MENU_PATTERN.md' },
        @{ order = 2; id = 'upgrade-path-pattern'; output = 'LIFEPUNCH_UPGRADE_PATH_PATTERN.md' },
        @{ order = 3; id = 'component-kit'; output = 'LIFEPUNCH_UI_COMPONENT_KIT.md' },
        @{ order = 4; id = 'reuse-map'; output = 'LIFEPUNCH_ADDON_UI_REUSE_MAP.md' },
        @{ order = 5; id = 'opus-grok-packet'; output = 'LIFEPUNCH_UI_OPUS_GROK_PACKET.md' }
    )
} | ConvertTo-Json -Depth 5

Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\cornerman-inbox-directive.json' -Text $directive
Write-Host 'OK inbox\cornerman-inbox-directive.json' -ForegroundColor Green
Write-Host 'Done — Green: WarmDistill, pull clone, then read to-cornerman-lifepunch-ui-pattern-distill.txt' -ForegroundColor Cyan
