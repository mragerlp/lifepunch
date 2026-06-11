# Push LIFEPUNCH Cyber Ecosystem briefs to Green inbox + workflow record.
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
. (Join-Path $Here 'Cornerman-Workflow.ps1')

$files = @(
    @{ rel = 'lifepunch\addons\docs\LIFEPUNCH_CYBER_ECOSYSTEM.md'; inbox = 'LIFEPUNCH_CYBER_ECOSYSTEM.md' },
    @{ rel = 'lifepunch\addons\docs\ASSET_INTAKE_CYBER_ECOSYSTEM.md'; inbox = 'ASSET_INTAKE_CYBER_ECOSYSTEM.md' },
    @{ rel = 'lifepunch\addons\docs\briefs\CORNERMAN_CYBER_ECOSYSTEM_TASK.md'; inbox = 'CORNERMAN_CYBER_ECOSYSTEM_TASK.md' },
    @{ rel = 'lifepunch\addons\docs\GOVERNMENT_DATABASE_SPEC.md'; inbox = 'GOVERNMENT_DATABASE_SPEC.md' },
    @{ rel = 'lifepunch\addons\docs\HACKER_OPS_CONSOLE_SPEC.md'; inbox = 'HACKER_OPS_CONSOLE_SPEC.md' },
    @{ rel = 'lifepunch\addons\Code\Addons\lifepunch\hackerjob\docs\HACKER_SERVER_RACK_SPEC.md'; inbox = 'HACKER_SERVER_RACK_SPEC.md' },
    @{ rel = 'lifepunch\addons\docs\BITCOINMINING_HUB_ARCH.md'; inbox = 'BITCOINMINING_HUB_ARCH.md' },
    @{ rel = 'lifepunch\addons\docs\BITCOINMINING_ENCRYPTION_SPEC.md'; inbox = 'BITCOINMINING_ENCRYPTION_SPEC.md' },
    @{ rel = 'lifepunch\addons\docs\HACKER_PVP_INFRA.md'; inbox = 'HACKER_PVP_INFRA.md' },
    @{ rel = 'lifepunch\addons\docs\GOV_DATACENTER_ROLEPLAY.md'; inbox = 'GOV_DATACENTER_ROLEPLAY.md' },
    @{ rel = 'lifepunch\addons\docs\UPGRADE_TIER_STANDARD.md'; inbox = 'UPGRADE_TIER_STANDARD.md' },
    @{ rel = 'lifepunch\docs\handoff\cornerman-outbox\to-cornerman-cyber-ecosystem.txt'; inbox = 'to-cornerman-cyber-ecosystem.txt' }
)

foreach ($f in $files) {
    $src = Join-Path $RepoRoot $f.rel
    if (-not (Test-Path -LiteralPath $src)) { throw "Missing $src" }
    $dest = "C:\lifepunch\cornerman\inbox\$($f.inbox)"
    Push-CornermanText -Path $dest -Text (Get-Content -LiteralPath $src -Raw)
    Write-Host "OK inbox\$($f.inbox)" -ForegroundColor Green
}

$directive = @{
    id       = 'cornerman-cyber-ecosystem-2026-06-11'
    priority = 'P1'
    lane     = 'cornerman'
    title    = 'LIFEPUNCH Cyber Ecosystem — distill pass'
    summary  = 'Owner greenlit unified hacker+bitcoin+gov loop. Read CORNERMAN_CYBER_ECOSYSTEM_TASK.md. Deliver outbox tables + PvP flow + gov roleplay. WarmDistill. No C# on Green.'
    primaryDoc = 'CORNERMAN_CYBER_ECOSYSTEM_TASK.md'
    warmModel  = 'distill'
} | ConvertTo-Json -Depth 4

Push-CornermanText -Path 'C:\lifepunch\cornerman\inbox\CYBER_ECOSYSTEM_DIRECTIVE.json' -Text $directive
Write-Host 'OK inbox\CYBER_ECOSYSTEM_DIRECTIVE.json' -ForegroundColor Green

Write-Host ''
Write-Host 'Next: Send-CornermanWorkflow.ps1 -Action WarmDistill -Message "Cyber ecosystem distill P1"' -ForegroundColor Cyan
