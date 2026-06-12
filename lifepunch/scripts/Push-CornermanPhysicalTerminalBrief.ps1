# Push physical-terminal alignment brief to Cornerman inbox (Red -> Green).
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')

$files = @(
    @{ rel = 'lifepunch\addons\docs\briefs\CORNERMAN_PHYSICAL_TERMINAL_ALIGNMENT_TASK.md'; inbox = 'CORNERMAN_PHYSICAL_TERMINAL_ALIGNMENT_TASK.md' },
    @{ rel = 'lifepunch\addons\docs\PHYSICAL_TERMINAL_DOCTRINE.md'; inbox = 'PHYSICAL_TERMINAL_DOCTRINE.md' },
    @{ rel = 'lifepunch\addons\Code\Addons\lifepunch\bitcoinmining\docs\BITCOINMINING_TERMINAL_DOCTRINE.md'; inbox = 'BITCOINMINING_TERMINAL_DOCTRINE.md' },
    @{ rel = 'lifepunch\addons\Code\Addons\lifepunch\hackerjob\docs\TERMINAL_SESSION_DOCTRINE.md'; inbox = 'TERMINAL_SESSION_DOCTRINE.md' },
    @{ rel = 'lifepunch\addons\docs\TERMINAL_BRAND_MATRIX.md'; inbox = 'TERMINAL_BRAND_MATRIX.md' },
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\to-cornerman-physical-terminal.txt'; inbox = 'to-cornerman-physical-terminal.txt' },
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\to-vengeance-physical-terminal-red.txt'; inbox = 'to-vengeance-physical-terminal-red.txt' }
)

foreach ($f in $files) {
    $src = Join-Path $RepoRoot $f.rel
    if (-not (Test-Path -LiteralPath $src)) { throw "Missing $src" }
    $dest = "C:\lifepunch\cornerman\inbox\$($f.inbox)"
    Push-CornermanText -Path $dest -Text (Get-Content -LiteralPath $src -Raw)
    Write-Host "OK inbox\$($f.inbox)" -ForegroundColor Green
}

$directive = @{
    id         = 'cornerman-physical-terminal-2026-06-12'
    priority   = 'P0'
    lane       = 'cornerman'
    title      = 'Physical terminal alignment — distill + gap audit'
    summary    = 'Owner locked: USE entity only, no dev console gameplay. Audit bitcoin+hacker vs PHYSICAL_TERMINAL_DOCTRINE. Outbox gap audit + hacker rack parity + doc fixlist.'
    primaryDoc = 'CORNERMAN_PHYSICAL_TERMINAL_ALIGNMENT_TASK.md'
    warmModel  = 'distill'
    tasks      = @(
        @{ order = 1; id = 'gap-audit'; output = 'PHYSICAL_TERMINAL_GAP_AUDIT.md' },
        @{ order = 2; id = 'hacker-parity'; output = 'HACKER_SERVER_RACK_TERMINAL_PARITY.md' },
        @{ order = 3; id = 'doc-fixlist'; output = 'STALE_TERMINAL_DOC_FIXLIST.md' },
        @{ order = 4; id = 'ui-notes'; output = 'HACKER_UI_PARITY_NOTES.md' }
    )
} | ConvertTo-Json -Depth 5

Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\cornerman-inbox-directive.json' -Text $directive
Write-Host 'OK inbox\cornerman-inbox-directive.json' -ForegroundColor Green
Write-Host 'Done — Green: read to-cornerman-physical-terminal.txt' -ForegroundColor Cyan
