# Runs ON Cornerman (Green). LM Studio distill overnight — no Cursor required.
# Input:  C:\lifepunch\cornerman\inbox\CORNERMAN_LPBITCOIN_UI_POLISH_OVERNIGHT_TASK.md
#         C:\Projects\lifepunch (monorepo clone)
# Output: C:\lifepunch\cornerman\outbox\LPBITCOIN_*.md (+ BITCOINMINING_*)
#         C:\lifepunch\cornerman\outbox\OVERNIGHT_STATUS.json
param(
    [string] $LmBase = 'http://127.0.0.1:1234/v1',
    [string] $DistillModel = 'qwen/qwen3.6-35b-a3b',
    [string] $CoderModel = 'qwen2.5-coder-32b-instruct'
)

$ErrorActionPreference = 'Stop'
$Inbox = 'C:\lifepunch\cornerman\inbox'
$Outbox = 'C:\lifepunch\cornerman\outbox'
$Repo = 'C:\Projects\lifepunch'
$Log = Join-Path $Outbox 'overnight-log.txt'
$StatusPath = Join-Path $Outbox 'OVERNIGHT_STATUS.json'

New-Item -ItemType Directory -Force -Path $Outbox | Out-Null

function Write-Log([string]$m) {
    $line = "[$(Get-Date -Format o)] $m"
    Add-Content -LiteralPath $Log -Value $line -Encoding UTF8
    Write-Host $line
}

function Read-ContextFile([string]$RelPath, [int]$MaxChars = 12000) {
    $full = Join-Path $Repo $RelPath
    if (-not (Test-Path -LiteralPath $full)) { return "(missing: $RelPath)" }
    $text = Get-Content -LiteralPath $full -Raw -Encoding UTF8
    if ($text.Length -gt $MaxChars) {
        return $text.Substring(0, $MaxChars) + "`n`n...(truncated)..."
    }
    return $text
}

function Save-Status([hashtable]$Status) {
    ($Status | ConvertTo-Json -Depth 6) | Set-Content -LiteralPath $StatusPath -Encoding UTF8
}

function Invoke-LmChat {
    param(
        [string]$System,
        [string]$User,
        [string]$Model,
        [int]$MaxTokens = 8192
    )
    $body = @{
        model       = $Model
        messages    = @(
            @{ role = 'system'; content = $System }
            @{ role = 'user'; content = $User }
        )
        max_tokens  = $MaxTokens
        temperature = 0.25
    }
    $json = $body | ConvertTo-Json -Depth 6
    $resp = Invoke-RestMethod -Uri "$LmBase/chat/completions" -Method Post -Body $json -ContentType 'application/json; charset=utf-8'
    return [string]$resp.choices[0].message.content
}

function Test-LmReady {
    try {
        $r = Invoke-RestMethod -Uri "$LmBase/models" -UseBasicParsing -TimeoutSec 8
        return ($null -ne $r)
    }
    catch { return $false }
}

$blocks = @(
    @{
        Id    = 'A'
        File  = 'LPBITCOIN_TERMINAL_SCROLL_ACCEPTANCE.md'
        Model = $DistillModel
        Task  = 'Write a step-by-step playtest acceptance script for LPBitcoin CRT terminal scroll. Cover: sync DXRP, stop/play, help command fills log, wheel up stays up, stick-to-bottom only when near bottom, UI scale change. Include failure modes and done-when criteria for owner sign-off. Red landed native overflow-y scroll and removed log line count from BuildHash in LpBitcoinTerminalPanel.razor.'
    }
    @{
        Id    = 'B'
        File  = 'LPBITCOIN_HUB_PANEL_ALIGNMENT_AUDIT.md'
        Model = $DistillModel
        Task  = 'Audit hub panel alignment for Active miners and GPU racks empty states. Document the nested rounded callout corner-ear bug, flat SCSS fix applied, remaining gaps. List selectors in LpHashdPanel.razor.scss and LifePunchUiShell.scss. Screenshot checklist for owner.'
    }
    @{
        Id    = 'C'
        File  = 'LPBITCOIN_HUB_TERMINAL_PARITY_MATRIX.md'
        Model = $DistillModel
        Task  = 'Build hub action to CRT command parity matrix: link terminal, link racks, wallet, deposit, mining start/stop, help, racks, select. Use LpBitcoinTerminalCommands.cs and LpHashdPanel.razor. Passive rack loop: mine -> deposit at CRT -> hub wallet.'
    }
    @{
        Id    = 'D'
        File  = 'LPBITCOIN_UI_SHELL_UNIFORM_PLAN.md'
        Model = $DistillModel
        Task  = 'Plan one uniform UI chrome stack for hub + terminal: LpUiMenuLayout.scss, LifePunchUiShell.scss, header/footer/sidebar tokens, font law (hub Poppins vs CRT mono). Minimal diff path for Red.'
    }
    @{
        Id    = 'E'
        File  = 'LPBITCOIN_HASHD_HOST_EXTRACTION_DRAFT.md'
        Model = $CoderModel
        Task  = 'Draft LpHashdPanelHost extraction plan mirroring StaffMenuHost pattern. File split map from LpHashdPanel.razor (~1700 lines). C# skeleton outline only — no ship. Reference TECH_DEBT UI-03.'
    }
    @{
        Id    = 'F'
        File  = 'LPBITCOIN_RAZOR_SCSS_VALIDATION_REPORT.md'
        Model = $DistillModel
        Task  = 'Audit LpHashdPanel.razor.scss and LpBitcoinTerminalPanel.razor.scss against SBOX_RAZOR_SCSS_RULES.md (class root, flex only, no display:none, flat rules for s&box). List violations + fixes.'
    }
    @{
        Id    = 'G'
        File  = 'LPBITCOIN_JULY_PUBLISH_CHECKLIST.md'
        Model = $DistillModel
        Task  = 'July ship checklist for lifepunch.bitcoin addon: flatgrass proof, H10 sign-off, portal _c assets, prepare-publish.ps1, player loop without help. Phase A hub then terminal then racks.'
    }
    @{
        Id    = 'H'
        File  = 'BITCOINMINING_JOB_ROLEPLAY_ONE_PAGER.md'
        Model = $DistillModel
        Task  = 'One-page Bitcoin Miner job roleplay: hub PIN admin, rig0 CRT commands, passive GPU racks, deposit flow. Market fantasy for DXRP.'
    }
    @{
        Id    = 'I'
        File  = 'BITCOINMINING_SOUND_SHORTLIST.md'
        Model = $DistillModel
        Task  = 'Sound shortlist for bitcoin lane: keyboard typing, hub power, rack fan states. Map to LpBitcoinUiSounds.cs hooks and assets paths under bitcoinmining/sounds.'
    }
)

$status = @{
    id       = 'cornerman-lpbitcoin-ui-polish-overnight-2026-06-20'
    started  = (Get-Date).ToUniversalTime().ToString('o')
    finished = $null
    blocks   = @()
}

Write-Log 'OVERNIGHT START'
if (-not (Test-LmReady)) {
    Write-Log 'FAIL LM not ready on :1234'
    $status.error = 'lm_not_ready'
    Save-Status $status
    exit 1
}

$briefPath = Join-Path $Inbox 'CORNERMAN_LPBITCOIN_UI_POLISH_OVERNIGHT_TASK.md'
$brief = if (Test-Path -LiteralPath $briefPath) { Get-Content -LiteralPath $briefPath -Raw } else { '(brief missing)' }

$contextBundle = @(
    "=== ACTIVE_WORKSTREAM ==="
    (Read-ContextFile 'lifepunch\addons\docs\ACTIVE_WORKSTREAM.md' 6000)
    "=== TERMINAL PANEL RAZOR (excerpt) ==="
    (Read-ContextFile 'lifepunch\addons\Code\Addons\lifepunch\bitcoinmining\LpBitcoinTerminalPanel.razor' 8000)
    "=== HASHD PANEL SCSS (excerpt) ==="
    (Read-ContextFile 'lifepunch\addons\Code\Addons\lifepunch\bitcoinmining\LpHashdPanel.razor.scss' 10000)
    "=== SCSS RULES ==="
    (Read-ContextFile 'lifepunch\addons\docs\SBOX_RAZOR_SCSS_RULES.md' 6000)
) -join "`n`n"

$systemPrompt = @"
You are Cornerman Tier-3 distill for LIFEPUNCH LPBitcoin addon (lifepunchbitcoin lane only).
Eyes covered: no playtest claims. Output markdown for Red (VENGEANCE) to implement.
Law: ACTIVE_WORKSTREAM gate, TERMINAL_BRAND_MATRIX, no hacker/weapons scope.
Be concrete: file paths, selectors, acceptance steps, tables where useful.
"@

foreach ($block in $blocks) {
    $entry = @{
        id     = $block.Id
        file   = $block.File
        status = 'running'
        started = (Get-Date).ToUniversalTime().ToString('o')
    }
    $status.current = $block.Id
    $status.blocks += $entry
    Save-Status $status

    Write-Log "BLOCK $($block.Id) $($block.File)"
    $userPrompt = @"
OVERNIGHT BRIEF:
$brief

REPO CONTEXT (excerpts):
$contextBundle

TASK:
$($block.Task)

Deliver complete markdown document body only (no code fences wrapping the whole doc).
"@

    try {
        $content = Invoke-LmChat -System $systemPrompt -User $userPrompt -Model $block.Model
        $outPath = Join-Path $Outbox $block.File
        Set-Content -LiteralPath $outPath -Value $content.Trim() -Encoding UTF8
        $entry.status = 'done'
        $entry.finished = (Get-Date).ToUniversalTime().ToString('o')
        Write-Log "OK $($block.File) ($($content.Length) chars)"
    }
    catch {
        $entry.status = 'failed'
        $entry.error = $_.Exception.Message
        Write-Log "FAIL $($block.File): $($_.Exception.Message)"
    }
    Save-Status $status
}

$status.current = $null
$status.finished = (Get-Date).ToUniversalTime().ToString('o')
$doneCount = @($status.blocks | Where-Object { $_.status -eq 'done' }).Count
$status.summary = "done=$doneCount/$($blocks.Count)"
Save-Status $status

$ping = "OK cornerman lpbitcoin-ui-polish-overnight @$doneCount files"
Set-Content -LiteralPath (Join-Path $Outbox 'to-vengeance-lpbitcoin-overnight-done.txt') -Value $ping -Encoding UTF8
Write-Log $ping
Write-Log 'OVERNIGHT END'
