# =====================================================================
# RISK: SYNC/PUSH + DANGEROUS IF UNGROUNDED (ff-merges upstream; pushes dxrp-public with -PushOrigin)
# GO:   BLOODWAVE GO REQUIRED for -PushOrigin
# NODE: Red only  |  BRANCH: dxrp-public develop (official upstream lane) - NOT the monorepo
# PRE:  grounded per START_HERE_AGENTS.md; official-DXRP lane only (see DXRP_CONTRIBUTOR_LANE.md)
# WHAT: Fast-forward dxrp-public develop from dxura/dxrp upstream ONLY when the result keeps the
#       recorded ancestry floor reachable; optionally push origin.
# GUARD: a fast-forward that would orphan ancestryGuard.requiredAncestorSha is REFUSED before any
#        branch mutation. See STOPGO_DXRP_REPIN_2026-07-11 (ruled MERGE, not rebase) and
#        docs/handoff/STOPGO_DXRP_REPIN_INSTRUMENT_DEFECTS_2026-07-13.md.
# DRY RUN: -WhatIf performs reads only. It does not fetch, switch, merge, push, or write.
# =====================================================================
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$DxrpPath = (Join-Path $PSScriptRoot '..\..\..\dxrp-public'),
    [string]$PinPath = (Join-Path $PSScriptRoot '..\config\dxrp-upstream-pin.json'),
    [string]$RequiredAncestorSha = '',
    [switch]$PushOrigin
)

$ErrorActionPreference = 'Stop'

$ResolvedDxrpPath = (Resolve-Path -LiteralPath $DxrpPath).Path

function Invoke-Git {
    param([string[]]$Arguments)

    & git -C $ResolvedDxrpPath @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments -join ' ') failed with exit code $LASTEXITCODE"
    }
}

function Get-GitText {
    param([string[]]$Arguments)

    $output = & git -C $ResolvedDxrpPath @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments -join ' ') failed with exit code $LASTEXITCODE"
    }
    return (($output -join "`n").Trim())
}

function Test-GitAncestor {
    param(
        [string]$Ancestor,
        [string]$Descendant
    )

    & git -C $ResolvedDxrpPath merge-base --is-ancestor $Ancestor $Descendant
    if ($LASTEXITCODE -eq 0) { return $true }
    if ($LASTEXITCODE -eq 1) { return $false }
    throw "Unable to test ancestry: $Ancestor -> $Descendant (exit $LASTEXITCODE)"
}

# --- Ancestry floor: explicit parameter, else schema v2 pin, else legacy fallback (loudly) ------
if (-not $RequiredAncestorSha) {
    if (-not (Test-Path -LiteralPath $PinPath)) {
        throw "Ancestry guard unavailable: pin file missing at $PinPath. Pass -RequiredAncestorSha explicitly."
    }

    $pin = Get-Content -LiteralPath $PinPath -Raw | ConvertFrom-Json
    $RequiredAncestorSha = [string]$pin.ancestryGuard.requiredAncestorSha
    if (-not $RequiredAncestorSha) {
        $RequiredAncestorSha = [string]$pin.pinned.sha
        Write-Warning "LEGACY PIN SCHEMA: ancestryGuard.requiredAncestorSha missing; falling back to pinned.sha=$RequiredAncestorSha"
    }
}

if ($RequiredAncestorSha -notmatch '^[0-9a-fA-F]{40}$') {
    throw "Ancestry guard invalid: expected full 40-hex SHA, got '$RequiredAncestorSha'"
}

$Status = (& git -C $ResolvedDxrpPath status --porcelain)
if ($LASTEXITCODE -ne 0) {
    throw "Unable to read git status in $ResolvedDxrpPath"
}

if ($Status) {
    throw "DXRP fork checkout has uncommitted changes. Commit or stash them before syncing."
}

$Origin = (& git -C $ResolvedDxrpPath remote get-url origin).Trim()
$Upstream = (& git -C $ResolvedDxrpPath remote get-url upstream).Trim()

if ($Origin -ne 'https://github.com/mragerlp/dxrp-public.git') {
    throw "Unexpected origin remote: $Origin"
}

if ($Upstream -ne 'https://github.com/dxura/dxrp.git') {
    throw "Unexpected upstream remote: $Upstream"
}

$fetched = $false
if ($PSCmdlet.ShouldProcess($ResolvedDxrpPath, 'Fetch upstream/develop')) {
    Invoke-Git @('fetch', 'upstream', 'develop')
    $fetched = $true
}
else {
    Write-Warning 'DRY RUN: upstream refs were NOT refreshed; the ancestry plan below uses the existing upstream/develop ref.'
}

# --- THE GUARD -------------------------------------------------------------------------------
# Evaluated against the PROSPECTIVE RESULT, not against whether git calls the operation a
# fast-forward. The defect this exists to stop IS a clean fast-forward: when local develop sits on
# a pure upstream ancestor, `pull --ff-only upstream develop` succeeds and silently drops the fork
# lineage. "Is it a FF?" is the wrong question; "does the result still contain the floor?" is the
# right one.
$targetSha = Get-GitText @('rev-parse', 'upstream/develop')
if (-not (Test-GitAncestor $RequiredAncestorSha $targetSha)) {
    throw "ANCESTRY GUARD FAILED: proposed result $targetSha does not contain required ancestor $RequiredAncestorSha. No switch, merge, push, or pin write is allowed. If upstream has genuinely diverged, the ruled path is an AUTHORED MERGE (STOPGO_DXRP_REPIN_2026-07-11), not a fast-forward."
}

Write-Host "ANCESTRY GUARD PASS: $RequiredAncestorSha is reachable from proposed result $targetSha" -ForegroundColor Green

if ($PSCmdlet.ShouldProcess($ResolvedDxrpPath, 'Switch to develop')) {
    Invoke-Git @('switch', 'develop')
}

# Merge the exact object the guard approved - not a second implicit network fetch inside `pull`.
if ($PSCmdlet.ShouldProcess("develop -> $targetSha", 'Fast-forward from upstream/develop')) {
    Invoke-Git @('merge', '--ff-only', $targetSha)
}

if ($PushOrigin) {
    $resultSha = Get-GitText @('rev-parse', 'refs/heads/develop')
    if (-not (Test-GitAncestor $RequiredAncestorSha $resultSha)) {
        throw "ANCESTRY GUARD FAILED BEFORE PUSH: develop $resultSha lost required ancestor $RequiredAncestorSha"
    }

    if ($PSCmdlet.ShouldProcess("origin/develop <- $resultSha", 'Push guarded develop')) {
        Invoke-Git @('push', 'origin', 'develop')
    }
}

if (-not $fetched) {
    Write-Host 'DRY RUN COMPLETE: no fetch, switch, merge, or push executed.' -ForegroundColor Yellow
}

Invoke-Git @('status', '--short', '--branch')
