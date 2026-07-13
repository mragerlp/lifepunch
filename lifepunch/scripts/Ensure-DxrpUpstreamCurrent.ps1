# =====================================================================
# RISK: SYNC/PUSH + DANGEROUS IF UNGROUNDED (touches the official DXRP upstream fork dxrp-public)
# GO:   BLOODWAVE GO REQUIRED for -Sync / -Repin / -UpdatePin / -SyncSteam
# NODE: Red only  |  BRANCH: dxrp-public develop (from upstream/develop) - NOT the monorepo
# PRE:  grounded per START_HERE_AGENTS.md; official-DXRP lane only (see DXRP_CONTRIBUTOR_LANE.md)
# WHAT: Verify/sync the dxrp-public fork develop against dxura/dxrp upstream; update the pin.
# GUARD: every sync/pin result must keep ancestryGuard.requiredAncestorSha reachable.
# DRY RUN: -WhatIf performs reads only. It does not fetch, switch, merge, sync Steam, or write.
# =====================================================================
<#
.SYNOPSIS
  Verify (and optionally sync) mragerlp/dxrp-public develop with dxura/dxrp upstream.

.DESCRIPTION
  Law: before LifePunch addon/editor work, DXRP upstream must be current.
  Compares lifepunch/config/dxrp-upstream-pin.json to the fork checkout and upstream develop.

  ANCESTRY GUARD (pin schema v2). The pin records `ancestryGuard.requiredAncestorSha` - a commit
  that every operational pin must keep reachable. A fast-forward that would orphan it is refused
  BEFORE any branch mutation. This machine-encodes the write-once ruling
  STOPGO_DXRP_REPIN_2026-07-11 (MERGE, not rebase); it does not create new policy.

  CHECK MODE IS READ-ONLY. Running with no switches inspects refs and reports. It does NOT switch
  branches (the pre-2026-07-13 script did, on every editor-launch preflight).

.PARAMETER Sync
  Attempt a GUARDED fast-forward of fork develop. This does NOT update the pin unless -UpdatePin
  is also present; a sync-only run says DID NOT RE-PIN out loud.

.PARAMETER Repin
  Guarded sync + pin in one pass (equivalent to -Sync -UpdatePin). If history has diverged, the
  ancestry guard stops the run: perform the separately ruled AUTHORED MERGE first, then re-run
  with -UpdatePin alone.

.PARAMETER UpdatePin
  Rewrite dxrp-upstream-pin.json to the VERIFIED FORK develop HEAD - never to the upstream parent
  by assumption. May be used ALONE after an authored merge (that is the reconciliation path).

.PARAMETER SyncSteam
  Align the shallow Steam DXRP checkout to fork develop (preserves LifePunch overlay files).

.PARAMETER RequiredAncestorSha
  Full 40-hex SHA that every sync/pin result must retain in ancestry.
  Defaults to ancestryGuard.requiredAncestorSha from the pin.

.PARAMETER FailIfBehind
  Exit 1 when upstream develop is ahead of the pin OR the fork (blocks scripted preflight).
  Callers: Start-SboxDxrpEditor.ps1 (blocks launch), Setup-ModelDocGreenfieldEditor.ps1 (warns).

.EXAMPLE
  powershell -File lifepunch\scripts\Ensure-DxrpUpstreamCurrent.ps1
  powershell -File lifepunch\scripts\Ensure-DxrpUpstreamCurrent.ps1 -Repin -SyncSteam -WhatIf
  powershell -File lifepunch\scripts\Ensure-DxrpUpstreamCurrent.ps1 -UpdatePin
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string] $DxrpForkPath = '',
    [string] $SteamDxrpPath = 'D:\Steam\steamapps\common\sbox\dxrp',
    [string] $PinPath = '',
    [string] $RequiredAncestorSha = '',
    [switch] $Sync,
    [switch] $Repin,
    [switch] $SyncSteam,
    [switch] $UpdatePin,
    [switch] $FailIfBehind
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path

if (-not $PinPath) {
    $PinPath = Join-Path $RepoRoot 'lifepunch\config\dxrp-upstream-pin.json'
}
if (-not $DxrpForkPath) {
    $DxrpForkPath = Join-Path (Split-Path $RepoRoot -Parent) 'dxrp-public'
}

function Read-Pin {
    if (-not (Test-Path -LiteralPath $PinPath)) { return $null }
    return Get-Content -LiteralPath $PinPath -Raw | ConvertFrom-Json
}

function Invoke-ForkGit {
    param([string[]] $Arguments)
    & git -C $DxrpForkPath @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git -C $DxrpForkPath $($Arguments -join ' ') failed ($LASTEXITCODE)"
    }
}

function Get-ForkGitText {
    param([string[]] $Arguments)
    $output = & git -C $DxrpForkPath @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git -C $DxrpForkPath $($Arguments -join ' ') failed ($LASTEXITCODE)"
    }
    return (($output -join "`n").Trim())
}

function Test-ForkAncestor {
    param([string] $Ancestor, [string] $Descendant)
    & git -C $DxrpForkPath merge-base --is-ancestor $Ancestor $Descendant
    if ($LASTEXITCODE -eq 0) { return $true }
    if ($LASTEXITCODE -eq 1) { return $false }
    throw "Unable to test ancestry: $Ancestor -> $Descendant (exit $LASTEXITCODE)"
}

if (-not (Test-Path -LiteralPath $DxrpForkPath)) {
    throw "DXRP fork checkout missing: $DxrpForkPath (clone mragerlp/dxrp-public develop)"
}

# --- MODE SPLIT: sync and re-pin are no longer allowed to silently drift apart -----------------
if ($Repin) {
    $Sync = $true
    $UpdatePin = $true
    Write-Host 'MODE: REPIN (guarded -Sync + -UpdatePin)' -ForegroundColor Cyan
}
elseif ($Sync -and -not $UpdatePin) {
    Write-Warning 'MODE: SYNC ONLY. This run will not rewrite dxrp-upstream-pin.json and DID NOT RE-PIN.'
}
elseif ($UpdatePin -and -not $Sync) {
    Write-Host 'MODE: PIN ONLY. Fork develop must already contain upstream and the required ancestor.' -ForegroundColor Cyan
}

$pin = Read-Pin

# --- Ancestry floor ----------------------------------------------------------------------------
if (-not $RequiredAncestorSha) {
    $RequiredAncestorSha = [string]$pin.ancestryGuard.requiredAncestorSha
    if (-not $RequiredAncestorSha) {
        $RequiredAncestorSha = [string]$pin.pinned.sha
        Write-Warning "LEGACY PIN SCHEMA: ancestryGuard.requiredAncestorSha missing; falling back to pinned.sha=$RequiredAncestorSha"
    }
}
if ($RequiredAncestorSha -notmatch '^[0-9a-fA-F]{40}$') {
    throw "Ancestry guard invalid: expected full 40-hex SHA, got '$RequiredAncestorSha'"
}

$refsFresh = $false
if ($PSCmdlet.ShouldProcess($DxrpForkPath, 'Fetch upstream/develop and origin/develop')) {
    Invoke-ForkGit @('fetch', 'upstream', 'develop')
    Invoke-ForkGit @('fetch', 'origin', 'develop')
    $refsFresh = $true
}
else {
    Write-Warning 'DRY RUN: refs were NOT refreshed; the report below uses existing remote-tracking refs.'
}

$upstreamSha = Get-ForkGitText @('rev-parse', 'upstream/develop')
$upstreamShort = Get-ForkGitText @('rev-parse', '--short', $upstreamSha)
$upstreamSubject = Get-ForkGitText @('log', '-1', '--format=%s', $upstreamSha)

# Read develop by ref. Check mode must NOT switch branches - the old script did, which meant every
# editor-launch preflight silently moved the fork's checked-out branch.
$forkSha = ''
if (Test-Path (Join-Path $DxrpForkPath '.git')) {
    $forkSha = Get-ForkGitText @('rev-parse', 'refs/heads/develop')
}

$pinSha = [string]$pin.pinned.sha
$pinBehind = 0
if ($pinSha) {
    $pinBehind = [int](Get-ForkGitText @('rev-list', '--count', "$pinSha..$upstreamSha"))
}

$forkBehind = 0
if ($forkSha) {
    $forkBehind = [int](Get-ForkGitText @('rev-list', '--count', "$forkSha..$upstreamSha"))
}

Write-Host '=== DXRP upstream gate ===' -ForegroundColor Cyan
Write-Host "  Pin:      $(if ($pinSha) { $pin.pinned.shortSha + ' - ' + $pin.pinned.subject } else { '(none)' })"
Write-Host "  Fork:     $(if ($forkSha) { (Get-ForkGitText @('rev-parse','--short',$forkSha)) + ' - ' + (Get-ForkGitText @('log','-1','--format=%s',$forkSha)) } else { '(unknown)' })"
Write-Host "  Upstream: $upstreamShort - $upstreamSubject"
Write-Host "  Guard:    $RequiredAncestorSha must stay reachable"
Write-Host "  Behind pin:  $pinBehind commit(s)"
Write-Host "  Behind fork: $forkBehind commit(s)"

# TWO DISTINCT NOTIONS OF "BEHIND" - conflating them is what let the pin silently not move.
#   syncBehind = does the FORK need upstream commits?      -> drives sync + pin gating
#   gateBehind = is EITHER the fork or the pin record stale? -> drives -FailIfBehind (preflight)
# The old script used max() for both, which meant a stale pin BLOCKED a valid pin-only
# reconciliation after an authored merge. Splitting them fixes the pin write without weakening
# the editor-launch gate that Start-SboxDxrpEditor.ps1 depends on.
$syncBehind = $forkBehind

if ($syncBehind -gt 0 -and $Sync) {
    $syncScript = Join-Path $Here 'sync-dxrp-fork.ps1'
    if ($PSCmdlet.ShouldProcess($DxrpForkPath, "Guarded sync toward $upstreamSha preserving $RequiredAncestorSha")) {
        Write-Host ''
        Write-Host 'Syncing fork from upstream develop (guarded)...' -ForegroundColor Yellow
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $syncScript `
            -DxrpPath $DxrpForkPath -PinPath $PinPath -RequiredAncestorSha $RequiredAncestorSha
        if ($LASTEXITCODE -ne 0) { throw "sync-dxrp-fork.ps1 failed ($LASTEXITCODE)" }
        $forkSha = Get-ForkGitText @('rev-parse', 'refs/heads/develop')
        $forkBehind = [int](Get-ForkGitText @('rev-list', '--count', "$forkSha..$upstreamSha"))
        $syncBehind = $forkBehind
        Write-Host "Fork now at $(Get-ForkGitText @('rev-parse','--short',$forkSha))" -ForegroundColor Green
    }
}

# --- THE GUARD, asserted on the ACTUAL fork state, whatever path got us here -------------------
if ($forkSha -and -not (Test-ForkAncestor $RequiredAncestorSha $forkSha)) {
    throw "ANCESTRY GUARD FAILED: fork develop $forkSha does not contain required ancestor $RequiredAncestorSha. The pin will not be written."
}

if ($UpdatePin -and $forkSha -and -not (Test-ForkAncestor $upstreamSha $forkSha)) {
    throw "PIN REFUSED: fork develop $forkSha does not contain upstream/develop $upstreamSha. Sync or perform the ruled authored merge first."
}

if ($SyncSteam -and $syncBehind -eq 0) {
    $steamScript = Join-Path $Here 'Sync-DxrpSteamCheckout.ps1'
    if (Test-Path -LiteralPath $steamScript) {
        if ($PSCmdlet.ShouldProcess($SteamDxrpPath, "Sync Steam checkout to fork develop $forkSha")) {
            Write-Host ''
            Write-Host 'Syncing Steam DXRP checkout...' -ForegroundColor Yellow
            & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $steamScript -TargetSha $forkSha -SteamDxrpPath $SteamDxrpPath
            # PATCH 4 (2026-07-13) - ASK THE CHILD HOW IT DIED. The Steam script runs in its own
            # process, so a terminating error inside it CANNOT stop this one. Without this check the
            # child could die mid-fetch while this script sailed on to print "OK" and exit 0 - which
            # is exactly what happened on 2026-07-13 (codex\0015): a false green over an unaligned
            # Steam checkout. An unchecked $LASTEXITCODE is a sensor you declined to read.
            if ($LASTEXITCODE -ne 0) {
                throw "Steam sync FAILED (exit $LASTEXITCODE). The Steam checkout is NOT aligned to $forkSha."
            }
        }
    }
}

if ($UpdatePin -and $syncBehind -eq 0 -and $forkSha) {
    $pinShort = Get-ForkGitText @('rev-parse', '--short', $forkSha)
    $pinSubject = Get-ForkGitText @('log', '-1', '--format=%s', $forkSha)
    $payload = [ordered]@{
        schemaVersion = 2
        ancestryGuard = [ordered]@{
            requiredAncestorSha = $RequiredAncestorSha
            rule                = 'Every operational pin must retain this commit in ancestry. Ruled by STOPGO_DXRP_REPIN_2026-07-11 (MERGE, not rebase): Packet E, Packet G and the P1 verdict cite it by hash.'
        }
        fork          = [ordered]@{
            remote = 'https://github.com/mragerlp/dxrp-public.git'
            branch = 'develop'
        }
        upstream      = [ordered]@{
            remote = 'https://github.com/dxura/dxrp.git'
            branch = 'develop'
        }
        pinned        = [ordered]@{
            sha      = $forkSha
            shortSha = $pinShort
            subject  = $pinSubject
            syncedAt = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        }
        lastSyncedFrom = [ordered]@{
            forkCheckout  = ($DxrpForkPath -replace '\\', '/')
            steamCheckout = ($SteamDxrpPath -replace '\\', '/')
        }
        gateScript    = 'lifepunch/scripts/Ensure-DxrpUpstreamCurrent.ps1'
        notes         = 'Operational pin is the VERIFIED FORK develop HEAD, not the upstream parent. lastSyncedFrom is a descriptive stamp of the machine that last wrote this file - it is never an input path; the gate script derives its own checkout. Use -Repin for a guarded FF sync+pin; after an authored merge use -UpdatePin alone.'
    }
    if ($PSCmdlet.ShouldProcess($PinPath, "Write operational pin $forkSha")) {
        ($payload | ConvertTo-Json -Depth 6) + "`n" | Set-Content -LiteralPath $PinPath -Encoding utf8 -NoNewline
        Write-Host "Updated pin: $PinPath ($pinShort)" -ForegroundColor Green
        $pinSha = $forkSha
        $pinBehind = [int](Get-ForkGitText @('rev-list', '--count', "$pinSha..$upstreamSha"))
    }
}

if ($Sync -and -not $UpdatePin) {
    Write-Warning "SYNC-ONLY COMPLETE: fork develop is $forkSha; the pin file was NOT changed. THIS RUN DID NOT RE-PIN."
}

# Preflight gate: stale fork OR stale pin record both count as "behind" for -FailIfBehind, which
# preserves the contract Start-SboxDxrpEditor.ps1 and Setup-ModelDocGreenfieldEditor.ps1 rely on.
$gateBehind = [Math]::Max($pinBehind, $forkBehind)

if ($gateBehind -gt 0) {
    $msg = "DXRP develop is $gateBehind commit(s) behind upstream (fork $forkBehind, pin record $pinBehind). Run: powershell -File lifepunch\scripts\Ensure-DxrpUpstreamCurrent.ps1 -Repin [-SyncSteam]"
    if ($FailIfBehind) {
        Write-Host $msg -ForegroundColor Red
        exit 1
    }
    Write-Host "WARN $msg" -ForegroundColor Yellow
}
else {
    Write-Host 'OK - fork develop matches upstream and the pin record is current.' -ForegroundColor Green
}

if (-not $refsFresh) {
    Write-Host 'DRY RUN COMPLETE: no refs, branch, pin, or Steam mutation executed.' -ForegroundColor Yellow
}

if ($FailIfBehind -and $gateBehind -gt 0) { exit 1 }
exit 0
