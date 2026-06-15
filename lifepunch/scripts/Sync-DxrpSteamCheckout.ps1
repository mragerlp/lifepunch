<#
.SYNOPSIS
  Align the shallow Steam DXRP install to a specific upstream develop commit.

.DESCRIPTION
  Steam's dxura/dxrp checkout is often a depth-1 shallow clone on main. This script
  fetches develop and hard-resets to the target SHA, then restores known LifePunch
  overlay paths from git stash when present.

  Does NOT commit in the Steam tree — runtime overlay only.

.PARAMETER TargetSha
  Full or short upstream develop SHA. Defaults to fork HEAD.

.EXAMPLE
  powershell -File lifepunch\scripts\Sync-DxrpSteamCheckout.ps1
  powershell -File lifepunch\scripts\Sync-DxrpSteamCheckout.ps1 -TargetSha 7fcbf03
#>
[CmdletBinding()]
param(
    [string] $TargetSha = '',
    [string] $SteamDxrpPath = 'D:\Steam\steamapps\common\sbox\dxrp',
    [string] $DxrpForkPath = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }

if (-not $DxrpForkPath) {
    $repoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
    $DxrpForkPath = Join-Path (Split-Path $repoRoot -Parent) 'dxrp-public'
}

if (-not $TargetSha) {
    if (-not (Test-Path -LiteralPath $DxrpForkPath)) {
        throw 'TargetSha required when fork checkout is missing.'
    }
    $TargetSha = (& git -C $DxrpForkPath rev-parse 'develop').Trim()
}

if (-not (Test-Path -LiteralPath $SteamDxrpPath)) {
    throw "Steam DXRP path not found: $SteamDxrpPath"
}

$overlayPaths = @(
    'game/Assets/scenes/game.scene',
    'game/Assets/scenes/game.scene_c',
    'game/Assets/scenes/game.scene_d',
    'game/Code/Chat/Chat.Handler.cs',
    'game/Code/Entity/Entities/ItemEntity.cs',
    'game/Code/System/AdminSystem.cs',
    'game/Code/System/Player/PocketSystem.cs',
    'game/Code/System/Player/RankSystem.cs',
    'game/Code/System/Recovery/SnapshotSystem.cs',
    'game/Code/rp.csproj',
    'game/Editor/rp.editor.csproj',
    'game/rp.sbproj',
    'game/rp.slnx'
)

Write-Host "Steam DXRP -> $TargetSha" -ForegroundColor Cyan
& git -C $SteamDxrpPath fetch origin "develop:refs/remotes/origin/develop" 2>&1 | Out-Host
$resolved = (& git -C $SteamDxrpPath rev-parse $TargetSha).Trim()

$dirtyOverlay = @()
foreach ($rel in $overlayPaths) {
    $full = Join-Path $SteamDxrpPath $rel
    if (-not (Test-Path -LiteralPath $full)) { continue }
    $status = (& git -C $SteamDxrpPath status --porcelain -- $rel 2>$null)
    if ($status) { $dirtyOverlay += $rel }
}

$stashName = 'lifepunch-steam-overlay-sync'
if ($dirtyOverlay.Count -gt 0) {
    Write-Host "Stashing $($dirtyOverlay.Count) LifePunch overlay file(s)..." -ForegroundColor DarkGray
    & git -C $SteamDxrpPath stash push -m $stashName -- @dirtyOverlay 2>&1 | Out-Host
}

& git -C $SteamDxrpPath reset --hard $resolved 2>&1 | Out-Host
$head = (& git -C $SteamDxrpPath rev-parse --short HEAD).Trim()
Write-Host "Steam HEAD: $head" -ForegroundColor Green

if ($dirtyOverlay.Count -gt 0) {
    $pop = & git -C $SteamDxrpPath stash pop 2>&1
    $pop | Out-Host
    if ($LASTEXITCODE -ne 0) {
        if ($pop -match 'drunk\.shader_c') {
            Write-Host 'Resolving drunk.shader_c with upstream develop copy.' -ForegroundColor Yellow
            & git -C $SteamDxrpPath checkout HEAD -- 'game/Assets/shaders/drunk.shader_c' 2>&1 | Out-Host
            & git -C $SteamDxrpPath stash drop 2>&1 | Out-Null
        }
        else {
            Write-Host 'WARN stash pop had conflicts - resolve manually in Steam DXRP tree.' -ForegroundColor Yellow
        }
    }
}

Write-Host 'Steam DXRP aligned. Run Sync-LifePunchAddonsToDxrp.ps1 next.' -ForegroundColor Green
