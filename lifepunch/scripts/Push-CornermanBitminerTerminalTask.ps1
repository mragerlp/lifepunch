# Push Bitcoin Miner Phase-1 terminal task + specs to Cornerman inbox.
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')

$files = @(
    'lifepunch\addons\docs\briefs\CORNERMAN_BITMINER_TERMINAL_TASK.md',
    'lifepunch\addons\docs\BITMINER_UX_SPEC.md',
    'lifepunch\addons\docs\briefs\BITMINER_ENTITY_BRIEF.md',
    'lifepunch\addons\Code\Addons\lifepunch\bitcoinmining\docs\RUNTIME_PATTERN.md',
    'lifepunch\addons\Code\Addons\lifepunch\bitcoinmining\Bitminer.cs'
)

foreach ($rel in $files) {
    $src = Join-Path $RepoRoot $rel
    if (-not (Test-Path -LiteralPath $src)) { throw "Missing $src" }
    $name = Split-Path $src -Leaf
    Push-CornermanText -Path "C:\lifepunch\cornerman\inbox\$name" -Text (Get-Content -LiteralPath $src -Raw)
    Write-Host "OK inbox\$name" -ForegroundColor Green
}

$directive = @{
    id          = 'bitcoinminer-terminal-phase1'
    issued      = (Get-Date -Format 'yyyy-MM-dd')
    priority    = 'high'
    lane        = 'cornerman'
    modelHint   = 'qwen2.5-coder-32b-instruct or lane default'
    title       = 'Bitcoin Miner — Cornerman CLI terminal (Phase 1)'
    summary     = 'Port Evo bitminer entity+terminal; rebrand to LIFEPUNCH hashd; open via hashd/mine commands; menu command stubs Phase 2.'
    primaryDoc  = 'CORNERMAN_BITMINER_TERMINAL_TASK.md'
    reference   = @(
        'reference/evo-bitminer/Code/Addons/lifepunch/bitcoinmining/'
        'lifepunch/addons/Code/Addons/lifepunch/adminmenu/StaffMenuHost.cs'
    )
    validation  = @(
        'lifepunch/addons/scripts/validate-layout.ps1'
    )
    commitScope = 'feat(bitcoinmining): Cornerman CLI terminal + hashd command gate (Phase 1)'
    opusReview  = $true
} | ConvertTo-Json -Depth 5

Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\BITMINER_TERMINAL_PHASE1.json' -Text $directive
Write-Host 'OK inbox\BITMINER_TERMINAL_PHASE1.json' -ForegroundColor Green
