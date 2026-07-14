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

# PATCH 1 (2026-07-13) - NEVER pipe native git through `2>&1` under $ErrorActionPreference='Stop'.
# git writes normal fetch progress to STDERR; PowerShell 5.1 wraps redirected native stderr in a
# NativeCommandError, which under EAP=Stop is TERMINATING. That killed this script mid-fetch on
# every run that had real work to do (a no-op fetch is silent, so it "passed" for months).
# Here stderr is DATA and the EXIT CODE is the verdict. Same discipline as Invoke-CdwGit in
# lifepunch/scripts/cornerman/CornermanDropWorker.Lib.ps1.
function Invoke-SteamGit {
    param([string[]] $GitArgs, [switch] $AllowFail)
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $out  = @(& git @GitArgs 2>&1 | ForEach-Object { "$_" })
        $code = $LASTEXITCODE
    }
    finally { $ErrorActionPreference = $prev }
    foreach ($line in $out) { Write-Host "    git| $line" -ForegroundColor DarkGray }
    if ($code -ne 0 -and -not $AllowFail) {
        throw "git $($GitArgs -join ' ') failed with exit $code"
    }
    return [pscustomobject]@{ Output = $out; ExitCode = $code }
}

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
Invoke-SteamGit @('-C', $SteamDxrpPath, 'fetch', 'origin', 'develop:refs/remotes/origin/develop') | Out-Null

# PATCH 2 (2026-07-13) - resolve STRICTLY. A bare `git rev-parse <40-hex>` ECHOES the string back
# and exits 0 even when the object is absent, which would feed a phantom SHA straight into
# `reset --hard`. `--verify <sha>^{commit}` fails loudly instead.
$resolved = (Invoke-SteamGit @('-C', $SteamDxrpPath, 'rev-parse', '--verify', "$TargetSha^{commit}")).Output[0].Trim()

$dirtyOverlay = @()
foreach ($rel in $overlayPaths) {
    $full = Join-Path $SteamDxrpPath $rel
    if (-not (Test-Path -LiteralPath $full)) { continue }
    $status = (Invoke-SteamGit @('-C', $SteamDxrpPath, 'status', '--porcelain', '--', $rel) -AllowFail).Output
    if ($status) { $dirtyOverlay += $rel }
}

$stashName = 'lifepunch-steam-overlay-sync'
if ($dirtyOverlay.Count -gt 0) {
    Write-Host "Stashing $($dirtyOverlay.Count) LifePunch overlay file(s)..." -ForegroundColor DarkGray
    Invoke-SteamGit (@('-C', $SteamDxrpPath, 'stash', 'push', '-m', $stashName, '--') + $dirtyOverlay) | Out-Null
}

Invoke-SteamGit @('-C', $SteamDxrpPath, 'reset', '--hard', $resolved) | Out-Null

# PATCH 3 (2026-07-13) - THE MISSING SENSOR. This script used to print "Steam HEAD: <x>" and declare
# alignment without ever comparing it to the target. Read HEAD back and REFUSE to claim success.
$head = (Invoke-SteamGit @('-C', $SteamDxrpPath, 'rev-parse', 'HEAD')).Output[0].Trim()
if ($head -ne $resolved) {
    throw "STEAM ALIGNMENT FAILED: HEAD is $head, expected $resolved. The Steam checkout is NOT aligned."
}
Write-Host "Steam HEAD: $head  (VERIFIED == target)" -ForegroundColor Green

if ($dirtyOverlay.Count -gt 0) {
    $pop = Invoke-SteamGit @('-C', $SteamDxrpPath, 'stash', 'pop') -AllowFail
    if ($pop.ExitCode -ne 0) {
        if ($pop.Output -match 'drunk\.shader_c') {
            Write-Host 'Resolving drunk.shader_c with upstream develop copy.' -ForegroundColor Yellow
            Invoke-SteamGit @('-C', $SteamDxrpPath, 'checkout', 'HEAD', '--', 'game/Assets/shaders/drunk.shader_c') | Out-Null
            Invoke-SteamGit @('-C', $SteamDxrpPath, 'stash', 'drop') | Out-Null
        }
        else {
            Write-Host 'WARN stash pop had conflicts - resolve manually in Steam DXRP tree.' -ForegroundColor Yellow
        }
    }
}

# Re-apply the dxrp-overlays/ mechanism's files. The stash list above is hand-maintained and does
# NOT know about lifepunch/dxrp-overlays/ (green\0008); this script is the authoritative restore for
# anything that lives there, and it derives its file list dynamically.
& (Join-Path $Here 'Sync-DxrpEditorOverlays.ps1')

Write-Host 'Steam DXRP aligned + editor overlays re-applied. Run Sync-LifePunchAddonsToDxrp.ps1 next.' -ForegroundColor Green
