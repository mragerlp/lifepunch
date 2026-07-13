# GATE: ancestry-guard + dry-run proof for the repaired DXRP instruments.
# Builds a DISPOSABLE git fixture that reproduces the exact 2026-07-13 defect shape:
#   fork tip F (fork-only) is NOT an ancestor of upstream tip U, while local develop sits on an
#   upstream ancestor - so `pull --ff-only upstream develop` is a CLEAN FF that orphans F.
# Never touches the live fork.

$ErrorActionPreference = 'Stop'
$scratch = Join-Path ([System.IO.Path]::GetTempPath()) 'dxrp-ancestry-gate'
if (-not (Test-Path $scratch)) { New-Item -ItemType Directory -Path $scratch | Out-Null }
$fix     = Join-Path $scratch 'fixture-dxrp'
$scripts = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

if (Test-Path $fix) { Remove-Item $fix -Recurse -Force }
New-Item -ItemType Directory -Path $fix | Out-Null

function G { param([string[]]$a) & git -C $fix @a 2>&1 | Out-Null; if ($LASTEXITCODE -ne 0) { throw "git $($a -join ' ') failed" } }

G @('init','-q','-b','develop')
G @('config','user.name','fixture'); G @('config','user.email','f@x')
Set-Content (Join-Path $fix 'a.txt') 'base' -NoNewline; G @('add','-A'); G @('commit','-q','-m','base')
$BASE = (& git -C $fix rev-parse HEAD).Trim()

# upstream lineage: BASE -> P -> U
Set-Content (Join-Path $fix 'a.txt') 'up1' -NoNewline; G @('add','-A'); G @('commit','-q','-m','upstream 1')
$P = (& git -C $fix rev-parse HEAD).Trim()
Set-Content (Join-Path $fix 'a.txt') 'up2' -NoNewline; G @('add','-A'); G @('commit','-q','-m','upstream 2')
$U = (& git -C $fix rev-parse HEAD).Trim()

# fork lineage off BASE: F  (NOT an ancestor of U) - this is b9d6068's shape
G @('checkout','-q','-b','forkline',$BASE)
Set-Content (Join-Path $fix 'b.txt') 'fork work' -NoNewline; G @('add','-A'); G @('commit','-q','-m','fork-only work')
$F = (& git -C $fix rev-parse HEAD).Trim()

# local develop sits on P - an upstream ANCESTOR (0ee91dd's shape) => FF to U is clean
G @('checkout','-q','develop'); G @('reset','-q','--hard',$P)

# remote-tracking refs WITHOUT network; remote URLs match what the scripts assert
& git -C $fix update-ref refs/remotes/upstream/develop $U 2>&1 | Out-Null
& git -C $fix update-ref refs/remotes/origin/develop  $F 2>&1 | Out-Null
G @('remote','add','origin','https://github.com/mragerlp/dxrp-public.git')
G @('remote','add','upstream','https://github.com/dxura/dxrp.git')

# fixture pin (schema v2), floor = F
$pin = Join-Path $scratch 'fixture-pin.json'
$payload = [ordered]@{
  schemaVersion = 2
  ancestryGuard = [ordered]@{ requiredAncestorSha = $F; rule = 'test floor' }
  fork = [ordered]@{ remote='https://github.com/mragerlp/dxrp-public.git'; branch='develop' }
  upstream = [ordered]@{ remote='https://github.com/dxura/dxrp.git'; branch='develop' }
  pinned = [ordered]@{ sha=$P; shortSha=$P.Substring(0,7); subject='fixture'; syncedAt='2026-07-13T00:00:00Z' }
  lastSyncedFrom = [ordered]@{ forkCheckout='x'; steamCheckout='y' }
  gateScript='x'; notes='fixture'
}
($payload | ConvertTo-Json -Depth 6) + "`n" | Set-Content -LiteralPath $pin -Encoding utf8 -NoNewline

Write-Host "FIXTURE  BASE=$($BASE.Substring(0,7))  P=$($P.Substring(0,7))  U=$($U.Substring(0,7))  F=$($F.Substring(0,7))"
& git -C $fix merge-base --is-ancestor $F $U
Write-Host ("  F is ancestor of U : {0}   <- FALSE reproduces the defect" -f ($LASTEXITCODE -eq 0))
& git -C $fix merge-base --is-ancestor $P $U
Write-Host ("  develop(P) ancestor of U : {0}   <- TRUE means FF-to-U is CLEAN (the trap)" -f ($LASTEXITCODE -eq 0))

function Snapshot { (& git -C $fix show-ref) -join '|' }
$before = Snapshot
$devBefore = (& git -C $fix rev-parse refs/heads/develop).Trim()

# PS 5.1 trap: with EAP=Stop, a child exe writing to stderr becomes a terminating
# NativeCommandError. The scripts under test are SUPPOSED to write errors here - that is the
# behaviour being asserted - so the harness must not treat their stderr as its own failure.
$ErrorActionPreference = 'Continue'

Write-Host "`n===== TEST 1: guard must REFUSE the orphaning FF (floor = F) =====" -ForegroundColor Cyan
$t1 = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $scripts 'sync-dxrp-fork.ps1') `
        -DxrpPath $fix -PinPath $pin -WhatIf 2>&1 | Out-String
$t1refused = $t1 -match 'ANCESTRY GUARD FAILED'
Write-Host ("  ANCESTRY GUARD FAILED raised : {0}" -f $t1refused)
$devAfter1 = (& git -C $fix rev-parse refs/heads/develop).Trim()
Write-Host ("  develop UNMOVED              : {0}" -f ($devAfter1 -eq $devBefore))
Write-Host ("  all refs UNCHANGED           : {0}" -f ((Snapshot) -eq $before))

Write-Host "`n===== TEST 2: NON-VACUITY - same fixture, valid floor (BASE) must PASS =====" -ForegroundColor Cyan
$t2 = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $scripts 'sync-dxrp-fork.ps1') `
        -DxrpPath $fix -PinPath $pin -RequiredAncestorSha $BASE -WhatIf 2>&1 | Out-String
$t2passed = $t2 -match 'ANCESTRY GUARD PASS'
Write-Host ("  ANCESTRY GUARD PASS raised   : {0}   <- proves the guard DISCRIMINATES, not always-throws" -f $t2passed)
Write-Host ("  DRY RUN COMPLETE reported    : {0}" -f ($t2 -match 'DRY RUN COMPLETE'))

Write-Host "`n===== TEST 3: -WhatIf must mutate NOTHING =====" -ForegroundColor Cyan
$devAfter2 = (& git -C $fix rev-parse refs/heads/develop).Trim()
Write-Host ("  develop still at P           : {0}" -f ($devAfter2 -eq $devBefore))
Write-Host ("  all refs byte-identical      : {0}" -f ((Snapshot) -eq $before))
Write-Host ("  worktree clean               : {0}" -f (-not (& git -C $fix status --porcelain)))

Write-Host "`n===== TEST 4: Ensure- mode split (-Sync alone must say DID NOT RE-PIN) =====" -ForegroundColor Cyan
$pinHashBefore = (Get-FileHash $pin -Algorithm SHA256).Hash
$t4 = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $scripts 'Ensure-DxrpUpstreamCurrent.ps1') `
        -DxrpForkPath $fix -PinPath $pin -RequiredAncestorSha $BASE -Sync -WhatIf 2>&1 | Out-String
Write-Host ("  'SYNC ONLY' mode announced   : {0}" -f ($t4 -match 'MODE: SYNC ONLY'))
Write-Host ("  'DID NOT RE-PIN' said aloud  : {0}" -f ($t4 -match 'DID NOT RE-PIN'))
Write-Host ("  pin file SHA256 UNCHANGED    : {0}" -f ((Get-FileHash $pin -Algorithm SHA256).Hash -eq $pinHashBefore))

Write-Host "`n===== TEST 5: Ensure- check mode must NOT switch branches (old :80 bug) =====" -ForegroundColor Cyan
& git -C $fix checkout -q forkline
$branchBefore = (& git -C $fix rev-parse --abbrev-ref HEAD).Trim()
$t5 = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $scripts 'Ensure-DxrpUpstreamCurrent.ps1') `
        -DxrpForkPath $fix -PinPath $pin -RequiredAncestorSha $BASE -WhatIf 2>&1 | Out-String
$branchAfter = (& git -C $fix rev-parse --abbrev-ref HEAD).Trim()
Write-Host ("  branch before/after check    : {0} -> {1}" -f $branchBefore, $branchAfter)
Write-Host ("  check mode did NOT switch    : {0}   <- old script switched to develop here" -f ($branchAfter -eq $branchBefore))
& git -C $fix checkout -q develop

Write-Host "`n===== RESULT =====" -ForegroundColor Yellow
$pass = $t1refused -and ($devAfter1 -eq $devBefore) -and $t2passed -and ((Snapshot) -eq $before) `
        -and ($t4 -match 'DID NOT RE-PIN') -and ((Get-FileHash $pin -Algorithm SHA256).Hash -eq $pinHashBefore) `
        -and ($branchAfter -eq $branchBefore)
Write-Host ("GATE: {0}" -f $(if ($pass) { 'PASS' } else { 'FAIL' })) -ForegroundColor $(if ($pass) { 'Green' } else { 'Red' })
