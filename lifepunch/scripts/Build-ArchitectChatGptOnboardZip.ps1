<#
.SYNOPSIS
  Build ChatGPT LIFEPUNCH Architect onboarding zip on the user Desktop.

.DESCRIPTION
  Packages paste files + reconciled canon docs for ChatGPT Project knowledge upload.
  Does not include KNOWLEDGE content, templates, scratch, or repo rules (.cursor).

.EXAMPLE
  powershell -File lifepunch\scripts\Build-ArchitectChatGptOnboardZip.ps1
#>
[CmdletBinding()]
param(
    [string] $OutputPath = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$RepoRoot = Split-Path -Parent (Split-Path -Parent $Here)
$Lifepunch = Join-Path $RepoRoot 'lifepunch'
$Docs = Join-Path $Lifepunch 'docs'
$AddonsDocs = Join-Path $Lifepunch 'addons\docs'
$Handoff = Join-Path $Docs 'handoff'

$stamp = Get-Date -Format 'yyyy-MM-dd'
$bundleName = "LIFEPUNCH-Architect-ChatGPT-Onboard-$stamp"
$desktop = [Environment]::GetFolderPath('Desktop')
if (-not $desktop) { $desktop = Join-Path $env:USERPROFILE 'Desktop' }
if ($OutputPath) {
    $zipPath = $OutputPath
}
else {
    $zipPath = Join-Path $desktop "$bundleName.zip"
}

$stage = Join-Path $env:TEMP $bundleName
if (Test-Path -LiteralPath $stage) { Remove-Item -LiteralPath $stage -Recurse -Force }
New-Item -ItemType Directory -Force -Path $stage | Out-Null

function Stage-File([string]$Src, [string]$DestRel) {
    if (-not (Test-Path -LiteralPath $Src)) {
        Write-Warning "Skip missing: $Src"
        return
    }
    $dest = Join-Path $stage $DestRel
    $dir = Split-Path -Parent $dest
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    Copy-Item -LiteralPath $Src -Destination $dest -Force
}

$pasteFiles = @(
    'ARCHITECT_ONBOARDING_PASTE.txt'
    'ARCHITECT_PROJECT_INSTRUCTIONS.txt'
    'CHATGPT_FULL_ONBOARDING_PASTE.txt'
    'CHATGPT_STEP1_PASTE.txt'
    'CHATGPT_PROJECT_LIFEPUNCH_INSTRUCTIONS.txt'
    'CHATGPT_CONCEPT_BRIEF_TEMPLATE.txt'
    'BLANK_CURSOR_BRIEF.txt'
    'WORKFLOW_IDEATION_FIRST.md'
)
foreach ($f in $pasteFiles) {
    Stage-File (Join-Path $Handoff $f) "paste\$f"
}

Stage-File (Join-Path $Handoff 'ARCHITECT_HANDOFF_README.md') 'START_HERE.md'

$canon = @(
    @{ Src = Join-Path $Docs 'LIFEPUNCH_GAMEPLAY_LAWS.md'; Dest = 'canon\gameplay\LIFEPUNCH_GAMEPLAY_LAWS.md' }
    @{ Src = Join-Path $Docs 'LIFEPUNCH_FEEL.md'; Dest = 'canon\gameplay\LIFEPUNCH_FEEL.md' }
    @{ Src = Join-Path $Docs 'TERMINOLOGY.md'; Dest = 'canon\gameplay\TERMINOLOGY.md' }
    @{ Src = Join-Path $Docs 'OWNERSHIP_MATRIX.md'; Dest = 'canon\gameplay\OWNERSHIP_MATRIX.md' }
    @{ Src = Join-Path $Docs 'ARCHITECT.md'; Dest = 'canon\architect\ARCHITECT.md' }
    @{ Src = Join-Path $Docs 'CHATGPT_FOOD_PIPELINE.md'; Dest = 'canon\architect\CHATGPT_FOOD_PIPELINE.md' }
    @{ Src = Join-Path $Docs 'DESIGN_DECISION_LOG.md'; Dest = 'canon\architect\DESIGN_DECISION_LOG.md' }
    @{ Src = Join-Path $Docs 'PATTERN_LIBRARY.md'; Dest = 'canon\architect\PATTERN_LIBRARY.md' }
    @{ Src = Join-Path $Docs 'OPUS_USAGE_LAW.md'; Dest = 'canon\cvl\OPUS_USAGE_LAW.md' }
    @{ Src = Join-Path $Docs 'MACHINE_CAST.md'; Dest = 'canon\cvl\MACHINE_CAST.md' }
    @{ Src = Join-Path $Docs 'BLOODWAVE_ALIAS.md'; Dest = 'canon\cvl\BLOODWAVE_ALIAS.md' }
    @{ Src = Join-Path $Docs 'AGENT_ONBOARDING.md'; Dest = 'canon\integrator\AGENT_ONBOARDING.md' }
    @{ Src = Join-Path $Docs 'AGENT_SYNC_BROADCAST.txt'; Dest = 'canon\integrator\AGENT_SYNC_BROADCAST.txt' }
    @{ Src = Join-Path $AddonsDocs 'ACTIVE_WORKSTREAM.md'; Dest = 'canon\bitcoin\ACTIVE_WORKSTREAM.md' }
    @{ Src = Join-Path $AddonsDocs 'BITCOIN_SHIP_ROADMAP.md'; Dest = 'canon\bitcoin\BITCOIN_SHIP_ROADMAP.md' }
    @{ Src = Join-Path $AddonsDocs 'CYBER_REFERENCE_LAWS.md'; Dest = 'canon\bitcoin\CYBER_REFERENCE_LAWS.md' }
    @{ Src = Join-Path $AddonsDocs 'BITCOIN_PLAYER_DESIGN.md'; Dest = 'canon\bitcoin\BITCOIN_PLAYER_DESIGN.md' }
    @{ Src = Join-Path $AddonsDocs 'BITCOIN_CONTROLLER_PATTERN.md'; Dest = 'canon\bitcoin\BITCOIN_CONTROLLER_PATTERN.md' }
    @{ Src = Join-Path $AddonsDocs 'BITCOIN_DATA_FLOW.md'; Dest = 'canon\bitcoin\BITCOIN_DATA_FLOW.md' }
    @{ Src = Join-Path $AddonsDocs 'BITCOIN_UPGRADE_TAXONOMY.md'; Dest = 'canon\bitcoin\BITCOIN_UPGRADE_TAXONOMY.md' }
    @{ Src = Join-Path $AddonsDocs 'LIFEPUNCH_HUB_PATTERN.md'; Dest = 'canon\bitcoin\LIFEPUNCH_HUB_PATTERN.md' }
    @{ Src = Join-Path $AddonsDocs 'LIFEPUNCH_CYBER_SYSTEM_PATTERN.md'; Dest = 'canon\bitcoin\LIFEPUNCH_CYBER_SYSTEM_PATTERN.md' }
    @{ Src = Join-Path $Handoff 'cornerman-inbox\BITCOINMINING_UPGRADE_ARCH_PREP_2026-06-25.md'; Dest = 'canon\bitcoin\BITCOINMINING_UPGRADE_ARCH_PREP_2026-06-25.md' }
)
foreach ($c in $canon) { Stage-File $c.Src $c.Dest }

Stage-File (Join-Path $Docs 'DECISIONS\README.md') 'canon\decisions\README.md'
Get-ChildItem -LiteralPath (Join-Path $Docs 'DECISIONS') -Filter 'DECISION-*.md' | ForEach-Object {
    Stage-File $_.FullName ("canon\decisions\" + $_.Name)
}

$uploadReadme = @"
# LIFEPUNCH Architect — ChatGPT Project upload ($stamp)

Built from repo @ $(git -C $RepoRoot rev-parse --short HEAD 2>$null).

## New chat setup (performance)

1. **Custom instructions:** paste ``paste/ARCHITECT_ONBOARDING_PASTE.txt`` (or short ``paste/ARCHITECT_PROJECT_INSTRUCTIONS.txt``).
2. **Project knowledge:** upload everything under ``canon/`` + ``paste/WORKFLOW_IDEATION_FIRST.md``.
3. **Start ideation:** new chat → paste ``paste/CHATGPT_STEP1_PASTE.txt``.

## Read order (Architect)

1. ``canon/gameplay/LIFEPUNCH_GAMEPLAY_LAWS.md`` (G0–G9)
2. ``canon/gameplay/LIFEPUNCH_FEEL.md`` + ``TERMINOLOGY.md``
3. ``canon/decisions/README.md`` — cite DECISION-####
4. Active lane: ``canon/bitcoin/*``

## Not in this zip (Integrator / repo only)

- ``.cursor/rules`` — Cursor Integrator reads from git clone
- ``KNOWLEDGE/**`` — seed deferred; Distiller on Green
- ``RFC-0005`` — Draft; hub upgrade HOLD until owner GO
- Gameplay code, compiled assets

## Reconciliation (2026-06-25)

- No LIFEPUNCH NPC dependency (G9, DECISION-0003)
- Hub vs LpHashdPanel vs HASHD Terminal split documented
- Lean boot — do not require full doc stack every chat

— LIFEPUNCH / Peak Performance Products LLC
"@
Set-Content -LiteralPath (Join-Path $stage 'UPLOAD_README.md') -Value $uploadReadme -Encoding UTF8

if (Test-Path -LiteralPath $zipPath) { Remove-Item -LiteralPath $zipPath -Force }
Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $zipPath -Force
Remove-Item -LiteralPath $stage -Recurse -Force

Write-Host "OK $zipPath" -ForegroundColor Green
Write-Host "Upload canon/ + paste/ to ChatGPT LIFEPUNCH Project knowledge." -ForegroundColor Cyan
