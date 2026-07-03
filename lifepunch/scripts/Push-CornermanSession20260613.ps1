# Push full 2026-06-13 Cornerman session to Green inbox.
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')

$files = @(
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\CORNERMAN_SESSION_2026-06-13.md'; inbox = 'CORNERMAN_SESSION_2026-06-13.md' },
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\CORNERMAN_MENU_UI_FIX_2026-06-13.md'; inbox = 'CORNERMAN_MENU_UI_FIX_2026-06-13.md' },
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\to-cornerman-menu-ui-fix.txt'; inbox = 'to-cornerman-menu-ui-fix.txt' },
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\to-cornerman-session-2026-06-13.txt'; inbox = 'to-cornerman-session-2026-06-13.txt' },
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\to-cornerman-idle-folder-2026-06-13.txt'; inbox = 'to-cornerman-idle-folder-2026-06-13.txt' },
    @{ rel = 'lifepunchaddons\docs\SBOX_RAZOR_SCSS_RULES.md'; inbox = 'SBOX_RAZOR_SCSS_RULES.md' },
    @{ rel = 'lifepunchaddons\docs\briefs\CORNERMAN_WORK_QUEUE.md'; inbox = 'CORNERMAN_WORK_QUEUE.md' },
    @{ rel = 'lifepunch\docs\CORNERMAN_IDLE_FOLDER.md'; inbox = 'CORNERMAN_IDLE_FOLDER.md' },
    @{ rel = 'lifepunch\scripts\Export-CornermanIdle.ps1'; inbox = 'Export-CornermanIdle.ps1' }
)

foreach ($f in $files) {
    $src = Join-Path $RepoRoot $f.rel
    if (-not (Test-Path -LiteralPath $src)) { throw "Missing $src" }
    Push-CornermanText -Path "C:\lifepunch\cornerman\inbox\$($f.inbox)" -Text (Get-Content -LiteralPath $src -Raw)
    Write-Host "OK inbox\$($f.inbox)" -ForegroundColor Green
}

$directive = @{
    id           = 'cornerman-session-2026-06-13'
    priority     = 'P0'
    lane         = 'cornerman'
    title        = 'Session 2026-06-13 — menus + addon lanes'
    summary      = 'SHUTDOWN 4:00 PM EST. IDLE EXPORT 3:50 PM EST (no push). P0 menus. P1 addon code. P2 distill.'
    primaryDoc   = 'CORNERMAN_SESSION_2026-06-13.md'
    shutdownEst  = '2026-06-13T16:00:00-04:00'
    idleExportEst = '2026-06-13T15:50:00-04:00'
} | ConvertTo-Json -Depth 4

Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\CORNERMAN_SESSION_DIRECTIVE.json' -Text $directive
Write-Host 'OK inbox\CORNERMAN_SESSION_DIRECTIVE.json' -ForegroundColor Green
