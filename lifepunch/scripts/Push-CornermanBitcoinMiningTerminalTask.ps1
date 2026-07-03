# Push Bitcoin Miner Phase-1 terminal task + specs to Cornerman inbox.
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')

$files = @(
    'lifepunchaddons\docs\briefs\CORNERMAN_BITCOINMINING_TERMINAL_TASK.md',
    'lifepunchaddons\docs\BITCOINMINING_UX_SPEC.md',
    'lifepunchaddons\docs\briefs\BITCOINMINING_ENTITY_BRIEF.md',
    'lifepunchaddons\Code\Addons\lifepunch\bitcoinmining\docs\RUNTIME_PATTERN.md',
    'lifepunchaddons\Code\Addons\lifepunch\bitcoinmining\BitcoinMiningAddon.cs'
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
    summary     = 'LIFEPUNCH hashd terminal; open via hashd/mine commands; menu command stubs Phase 2. IP: BITCOINMINING_IP_DOCTRINE.md'
    primaryDoc  = 'CORNERMAN_BITCOINMINING_TERMINAL_TASK.md'
    reference   = @(
        'lifepunchaddons/docs/BITCOINMINING_IP_DOCTRINE.md'
        'lifepunchaddons/Code/Addons/lifepunch/adminmenu/StaffMenuHost.cs'
    )
    validation  = @(
        'lifepunchaddons/scripts/validate-layout.ps1'
    )
    commitScope = 'feat(bitcoinmining): Cornerman CLI terminal + hashd command gate (Phase 1)'
    opusReview  = $true
} | ConvertTo-Json -Depth 5

Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\BITCOINMINING_TERMINAL_PHASE1.json' -Text $directive
Write-Host 'OK inbox\BITCOINMINING_TERMINAL_PHASE1.json' -ForegroundColor Green
