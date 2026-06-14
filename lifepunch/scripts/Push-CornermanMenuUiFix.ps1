# Push menu UI fix handoff to Green Cornerman inbox.
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')

$files = @(
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\CORNERMAN_MENU_UI_FIX_2026-06-13.md'; inbox = 'CORNERMAN_MENU_UI_FIX_2026-06-13.md' },
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\to-cornerman-menu-ui-fix.txt'; inbox = 'to-cornerman-menu-ui-fix.txt' },
    @{ rel = 'lifepunch\addons\docs\SBOX_RAZOR_SCSS_RULES.md'; inbox = 'SBOX_RAZOR_SCSS_RULES.md' }
)

foreach ($f in $files) {
    $src = Join-Path $RepoRoot $f.rel
    if (-not (Test-Path -LiteralPath $src)) { throw "Missing $src" }
    Push-CornermanText -Path "C:\lifepunch\cornerman\inbox\$($f.inbox)" -Text (Get-Content -LiteralPath $src -Raw)
    Write-Host "OK inbox\$($f.inbox)" -ForegroundColor Green
}

$directive = @{
    id         = 'cornerman-menu-ui-fix-2026-06-13'
    priority   = 'P0'
    lane       = 'cornerman'
    title      = 'Menu UI — SCSS compile + GATEKEEPER PIN + power row + settings cog'
    summary    = 'Empty GATEKEEPER = forbidden SCSS kills stylesheet. Run Validate-SboxRazorScss.ps1. Owner away ~5h. Red commits; Green drafts/audits if no Cursor.'
    primaryDoc = 'CORNERMAN_MENU_UI_FIX_2026-06-13.md'
    hours      = 5
} | ConvertTo-Json -Depth 4

Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\CORNERMAN_MENU_UI_DIRECTIVE.json' -Text $directive
Write-Host 'OK inbox\CORNERMAN_MENU_UI_DIRECTIVE.json' -ForegroundColor Green
