# Push Bitcoin mining sound-sourcing brief to Cornerman inbox (Red -> Green).
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')

$files = @(
    @{ rel = 'lifepunch\addons\docs\briefs\CORNERMAN_BITCOINMINING_SOUNDS_TASK.md'; inbox = 'CORNERMAN_BITCOINMINING_SOUNDS_TASK.md' },
    @{ rel = 'lifepunch\addons\Assets\addons\lifepunch\bitcoinmining\sounds\bitcoinminer\README.md'; inbox = 'BITCOINMINER_SOUNDS_README.md' },
    @{ rel = 'lifepunch\addons\Code\Addons\lifepunch\bitcoinmining\BitcoinMiningAddon.cs'; inbox = 'BitcoinMiningAddon.cs' },
    @{ rel = 'lifepunch\addons\scripts\Intake-BitcoinMinerSounds.ps1'; inbox = 'Intake-BitcoinMinerSounds.ps1' },
    @{ rel = 'lifepunch\addons\Code\Addons\lifepunch\bitcoinmining\docs\BITCOINMINING_PLAYTEST.md'; inbox = 'BITCOINMINING_PLAYTEST.md' },
    @{ rel = 'lifepunch\addons\docs\briefs\BITCOINMINING_PROTECTION_CHECKLIST.md'; inbox = 'BITCOINMINING_PROTECTION_CHECKLIST.md' },
    @{ rel = 'lifepunch\addons\docs\briefs\CORNERMAN_WORK_QUEUE.md'; inbox = 'CORNERMAN_WORK_QUEUE.md' },
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\to-cornerman-bitcoinmining-sounds.txt'; inbox = 'to-cornerman-bitcoinmining-sounds.txt' }
)

foreach ($f in $files) {
    $src = Join-Path $RepoRoot $f.rel
    if (-not (Test-Path -LiteralPath $src)) { throw "Missing $src" }
    $dest = "C:\lifepunch\cornerman\inbox\$($f.inbox)"
    Push-CornermanText -Path $dest -Text (Get-Content -LiteralPath $src -Raw)
    Write-Host "OK inbox\$($f.inbox)" -ForegroundColor Green
}

$directive = @{
    id         = 'cornerman-bitcoinmining-sounds-2026-06-12'
    priority   = 'P1d'
    lane       = 'cornerman'
    title      = 'Bitcoin mining — sound slot research + shortlist'
    summary    = 'Seven wired SFX slots empty. Distill per-slot spec, legal shortlist (CC0/paid/record), intake checklist for Red. Owner priority: loud click typing for keyboard slot. No WAV commits.'
    primaryDoc = 'CORNERMAN_BITCOINMINING_SOUNDS_TASK.md'
    warmModel  = 'distill'
    tasks      = @(
        @{ order = 1; id = 'slot-spec'; output = 'BITCOINMINING_SOUND_SLOT_SPEC.md' },
        @{ order = 2; id = 'shortlist'; output = 'BITCOINMINING_SOUND_SHORTLIST.md' },
        @{ order = 3; id = 'intake-checklist'; output = 'BITCOINMINING_SOUND_INTAKE_CHECKLIST.md' }
    )
} | ConvertTo-Json -Depth 5

Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\BITCOINMINING_SOUNDS_DIRECTIVE.json' -Text $directive
Write-Host 'OK inbox\BITCOINMINING_SOUNDS_DIRECTIVE.json' -ForegroundColor Green
Write-Host ''
Write-Host 'Next (on Green):' -ForegroundColor Cyan
Write-Host '  Send-CornermanWorkflow.ps1 -Action MonorepoPull' -ForegroundColor Cyan
Write-Host '  Send-CornermanWorkflow.ps1 -Action WarmDistill -Message "Bitcoin mining sounds P1d"' -ForegroundColor Cyan
