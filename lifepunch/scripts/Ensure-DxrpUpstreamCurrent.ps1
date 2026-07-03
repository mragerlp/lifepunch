# =====================================================================
# RISK: SYNC/PUSH + DANGEROUS IF UNGROUNDED (touches the official DXRP upstream fork dxrp-public)
# GO:   BLOODWAVE GO REQUIRED for -Sync / -UpdatePin / -SyncSteam
# NODE: Red only  |  BRANCH: dxrp-public develop (from upstream/develop) - NOT the monorepo
# PRE:  grounded per START_HERE_AGENTS.md; official-DXRP lane only (see DXRP_CONTRIBUTOR_LANE.md)
# WHAT: Verify/sync the dxrp-public fork develop against dxura/dxrp upstream; update the pin.
# =====================================================================
<#
.SYNOPSIS
  Verify (and optionally sync) mragerlp/dxrp-public develop with dxura/dxrp upstream.

.DESCRIPTION
  Law: before LifePunch addon/editor work, DXRP upstream must be current.
  Compares lifepunch/config/dxrp-upstream-pin.json to the fork checkout and upstream develop.

.PARAMETER Sync
  Fast-forward the fork checkout from upstream develop (via sync-dxrp-fork.ps1).

.PARAMETER SyncSteam
  Align the shallow Steam DXRP checkout to upstream develop (preserves LifePunch overlay files).

.PARAMETER UpdatePin
  Rewrite dxrp-upstream-pin.json in the monorepo after a successful sync.

.PARAMETER FailIfBehind
  Exit 1 when upstream develop is ahead of the pin or fork (blocks scripted preflight).

.EXAMPLE
  powershell -File lifepunch\scripts\Ensure-DxrpUpstreamCurrent.ps1
  powershell -File lifepunch\scripts\Ensure-DxrpUpstreamCurrent.ps1 -Sync -UpdatePin -SyncSteam
#>
[CmdletBinding()]
param(
    [string] $DxrpForkPath = '',
    [string] $SteamDxrpPath = 'D:\Steam\steamapps\common\sbox\dxrp',
    [string] $PinPath = '',
    [switch] $Sync,
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

if (-not (Test-Path -LiteralPath $DxrpForkPath)) {
    throw "DXRP fork checkout missing: $DxrpForkPath (clone mragerlp/dxrp-public develop)"
}

$pin = Read-Pin
Invoke-ForkGit @('fetch', 'upstream', 'develop')
Invoke-ForkGit @('fetch', 'origin', 'develop')

$upstreamSha = (& git -C $DxrpForkPath rev-parse 'upstream/develop').Trim()
$upstreamShort = (& git -C $DxrpForkPath rev-parse --short $upstreamSha).Trim()
$upstreamSubject = (& git -C $DxrpForkPath log -1 --format='%s' $upstreamSha).Trim()
$forkSha = ''
if (Test-Path (Join-Path $DxrpForkPath '.git')) {
    Invoke-ForkGit @('switch', 'develop') | Out-Null
    $forkSha = (& git -C $DxrpForkPath rev-parse 'HEAD').Trim()
}

$pinSha = [string]$pin.pinned.sha
$pinBehind = 0
if ($pinSha) {
    $pinBehind = [int](& git -C $DxrpForkPath rev-list --count "$pinSha..$upstreamSha")
}

$forkBehind = 0
if ($forkSha) {
    $forkBehind = [int](& git -C $DxrpForkPath rev-list --count "$forkSha..$upstreamSha")
}

Write-Host '=== DXRP upstream gate ===' -ForegroundColor Cyan
Write-Host "  Pin:      $(if ($pinSha) { $pin.pinned.shortSha + ' - ' + $pin.pinned.subject } else { '(none)' })"
Write-Host "  Fork:     $(if ($forkSha) { (& git -C $DxrpForkPath rev-parse --short $forkSha) + ' - ' + (& git -C $DxrpForkPath log -1 --format='%s' $forkSha) } else { '(unknown)' })"
Write-Host "  Upstream: $upstreamShort - $upstreamSubject"
Write-Host "  Behind pin:  $pinBehind commit(s)"
Write-Host "  Behind fork: $forkBehind commit(s)"

$behind = [Math]::Max($pinBehind, $forkBehind)
if ($behind -gt 0 -and $Sync) {
    Write-Host ''
    Write-Host 'Syncing fork from upstream develop...' -ForegroundColor Yellow
    $syncScript = Join-Path $Here 'sync-dxrp-fork.ps1'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $syncScript
    $forkSha = (& git -C $DxrpForkPath rev-parse 'HEAD').Trim()
    $upstreamSha = $forkSha
    $upstreamShort = (& git -C $DxrpForkPath rev-parse --short $upstreamSha).Trim()
    $upstreamSubject = (& git -C $DxrpForkPath log -1 --format='%s' $upstreamSha).Trim()
    $pinBehind = 0
    $forkBehind = 0
    $behind = 0
    Write-Host "Fork now at $upstreamShort" -ForegroundColor Green
}

if ($behind -gt 0) {
    $msg = "DXRP develop is $behind commit(s) behind upstream. Run: powershell -File lifepunch\scripts\Ensure-DxrpUpstreamCurrent.ps1 -Sync -UpdatePin [-SyncSteam]"
    if ($FailIfBehind) {
        Write-Host $msg -ForegroundColor Red
        exit 1
    }
    Write-Host "WARN $msg" -ForegroundColor Yellow
}
else {
    Write-Host 'OK - fork matches upstream develop.' -ForegroundColor Green
}

if ($SyncSteam -and $behind -eq 0) {
    $steamScript = Join-Path $Here 'Sync-DxrpSteamCheckout.ps1'
    if (Test-Path -LiteralPath $steamScript) {
        Write-Host ''
        Write-Host 'Syncing Steam DXRP checkout...' -ForegroundColor Yellow
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $steamScript -TargetSha $upstreamSha -SteamDxrpPath $SteamDxrpPath
    }
}

if ($UpdatePin -and $behind -eq 0) {
    $payload = [ordered]@{
        schemaVersion = 1
        fork          = [ordered]@{
            remote = 'https://github.com/mragerlp/dxrp-public.git'
            branch = 'develop'
        }
        upstream      = [ordered]@{
            remote = 'https://github.com/dxura/dxrp.git'
            branch = 'develop'
        }
        pinned        = [ordered]@{
            sha       = $upstreamSha
            shortSha  = $upstreamShort
            subject   = $upstreamSubject
            syncedAt  = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        }
        localPaths    = [ordered]@{
            forkCheckout  = ($DxrpForkPath -replace '\\', '/')
            steamCheckout = ($SteamDxrpPath -replace '\\', '/')
        }
        gateScript    = 'lifepunch/scripts/Ensure-DxrpUpstreamCurrent.ps1'
        notes         = 'Run Ensure-DxrpUpstreamCurrent.ps1 -Sync before addon/editor work. Monorepo records the verified develop tip here after each upstream sync.'
    }
    ($payload | ConvertTo-Json -Depth 6) + "`n" | Set-Content -LiteralPath $PinPath -Encoding utf8 -NoNewline
    Write-Host "Updated pin: $PinPath ($upstreamShort)" -ForegroundColor Green
}

if ($FailIfBehind -and $behind -gt 0) { exit 1 }
exit 0
