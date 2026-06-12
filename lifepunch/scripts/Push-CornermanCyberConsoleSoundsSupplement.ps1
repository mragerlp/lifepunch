# Push P1d supplement asks — GPU fan lifecycle, universal keyboard, hackerjob sounds.
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')

$files = @(
    @{ rel = 'lifepunch\addons\docs\briefs\CORNERMAN_CYBER_CONSOLE_SOUNDS_SUPPLEMENT.md'; inbox = 'CORNERMAN_CYBER_CONSOLE_SOUNDS_SUPPLEMENT.md' },
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\OWNER_ASK_GPU_FAN_LIFECYCLE.txt'; inbox = 'OWNER_ASK_GPU_FAN_LIFECYCLE.txt' },
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\OWNER_ASK_UNIVERSAL_CONSOLE_KEYBOARD.txt'; inbox = 'OWNER_ASK_UNIVERSAL_CONSOLE_KEYBOARD.txt' },
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\OWNER_ASK_HACKERJOB_SOUNDS.txt'; inbox = 'OWNER_ASK_HACKERJOB_SOUNDS.txt' },
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\OWNER_ASK_LOUD_CLICK_TYPING.txt'; inbox = 'OWNER_ASK_LOUD_CLICK_TYPING.txt' },
    @{ rel = 'lifepunch\addons\Code\Addons\lifepunch\hackerjob\HackerJob.cs'; inbox = 'HackerJob.cs' },
    @{ rel = 'lifepunch\addons\docs\HACKER_JOB_SPEC.md'; inbox = 'HACKER_JOB_SPEC.md' },
    @{ rel = 'lifepunch\addons\Code\Addons\lifepunch\bitcoinmining\GpuRackEntity.cs'; inbox = 'GpuRackEntity_sounds_ref.cs' }
)

foreach ($f in $files) {
    $src = Join-Path $RepoRoot $f.rel
    if (-not (Test-Path -LiteralPath $src)) { throw "Missing $src" }
    Push-CornermanText -Path "C:\lifepunch\cornerman\inbox\$($f.inbox)" -Text (Get-Content -LiteralPath $src -Raw)
    Write-Host "OK inbox\$($f.inbox)" -ForegroundColor Green
}

$note = @"
P1d SUPPLEMENT (2026-06-12) — read while working sounds task:

1. OWNER_ASK_UNIVERSAL_CONSOLE_KEYBOARD.txt — ONE loud click for ALL consoles (bitcoin + hacker + future)
2. OWNER_ASK_GPU_FAN_LIFECYCLE.txt — ON ramp / passive loop / OFF ramp (8s volume ramp in code)
3. OWNER_ASK_HACKERJOB_SOUNDS.txt — hacker terminal + rack SFX matrix (boot, granted, denied, fans, scan)

Primary doc: CORNERMAN_CYBER_CONSOLE_SOUNDS_SUPPLEMENT.md
"@

Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\to-cornerman-cyber-sounds-supplement.txt' -Text $note
Write-Host 'OK inbox\to-cornerman-cyber-sounds-supplement.txt' -ForegroundColor Green
Write-Host 'Done — Cornerman: merge into P1d outbox shortlists' -ForegroundColor Cyan
