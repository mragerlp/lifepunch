# =====================================================================
# RISK: READ-ONLY TEST (temp git fixtures + scratch BaseDir)  |  clone-freshness slice
# NODE: Red (VENGEANCE) -- runs anywhere the repo is checked out
# WHAT: Gate for the expectedClones freshness precondition. Reproduce-then-fix:
#       a packet naming a commit the node does NOT have must refuse with the right
#       named message and never reach the model; the corrected packet must run.
#       Unit cases exercise Test-CdwExpectedClones directly; the E2E cases drive the
#       real worker (Invoke-CornermanWorkerOnce) against scratch dirs, no live model.
#       Also pins the untracked-debris interaction: a clone-swap that leaves a
#       'lifepunchdxrp_stale' folder trips the dirty gate, because the .gitignore
#       pattern '/lifepunchdxrp/' is anchored to that exact name.
# USAGE:
#   powershell -NoProfile -ExecutionPolicy Bypass -File Test-CdwExpectedClones.ps1
# =====================================================================
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
. (Join-Path $here 'CornermanDropWorker.Lib.ps1')

$script:pass = 0; $script:fail = 0
function Assert($cond, $name) {
    if ($cond) { $script:pass++; Write-Output "  PASS  $name" }
    else { $script:fail++; Write-Output "  FAIL  $name" }
}
# Native stderr under EAP=Stop is a terminating NativeCommandError in PS 5.1 (git prints
# CRLF warnings on commit). Fixture git calls run with EAP=Continue and discard stderr.
function Git-Q {
    param([string[]] $CliArgs)
    $prev = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    try { (& git @CliArgs 2>$null) | Out-Null } finally { $ErrorActionPreference = $prev }
}
function Git-Out {
    param([string[]] $CliArgs)
    $prev = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    try { return ([string]((& git @CliArgs 2>$null) -join '')).Trim() } finally { $ErrorActionPreference = $prev }
}
function New-Commit {
    param([string] $Repo, [string] $File, [string] $Text, [string] $Msg)
    Set-Content -LiteralPath (Join-Path $Repo $File) -Value $Text -Encoding utf8
    Git-Q @('-C', $Repo, 'add', '-A')
    Git-Q @('-C', $Repo, '-c', 'user.email=t@t', '-c', 'user.name=t', 'commit', '-m', $Msg)
    return (Git-Out @('-C', $Repo, 'rev-parse', 'HEAD'))
}

$tmp = Join-Path $env:TEMP ('cdw-clones-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
$clone = Join-Path $tmp 'clone'
$nested = Join-Path $clone 'lifepunchdxrp'
New-Item -ItemType Directory -Force -Path $clone | Out-Null

# ---- fixture: the "monorepo" clone (origin slug must satisfy Test-CdwCloneIdentity)
Git-Q @('init', $clone)
Git-Q @('-C', $clone, 'config', 'core.autocrlf', 'false')
Git-Q @('-C', $clone, 'symbolic-ref', 'HEAD', 'refs/heads/main')
Git-Q @('-C', $clone, 'remote', 'add', 'origin', 'https://github.com/mragerlp/lifepunch.git')
Set-Content -LiteralPath (Join-Path $clone '.gitignore') -Value "/lifepunchdxrp/`n" -Encoding utf8
$shaA = New-Commit $clone 'game.txt' 'alpha' 'A'
$shaB = New-Commit $clone 'game.txt' 'bravo' 'B'   # A is an ancestor of B

# ---- fixture: the NESTED clone (a separate repo living inside the ignored path)
New-Item -ItemType Directory -Force -Path $nested | Out-Null
Git-Q @('init', $nested)
Git-Q @('-C', $nested, 'config', 'core.autocrlf', 'false')
Git-Q @('-C', $nested, 'symbolic-ref', 'HEAD', 'refs/heads/develop')
$shaN = New-Commit $nested 'vanilla.cs' '// vanilla' 'N'
$absent = 'deadbeefdeadbeefdeadbeefdeadbeefdeadbeef'

$profile = [pscustomobject]@{ cloneWindows = $clone; focus = 'LifePunch' }
function New-Pk($expected) {
    $p = @{ inputs = @{ readFiles = @('game.txt'); maxBytes = 400000 } }
    if ($null -ne $expected) { $p.expectedClones = $expected }
    return ($p | ConvertTo-Json -Depth 8 | ConvertFrom-Json)
}
function Errs($r) { return (@($r.Errors) -join ' | ') }

Write-Output '== Case 1: no expectedClones => not an error, but Declared=false (freshness unverified) =='
$r = Test-CdwExpectedClones -Packet (New-Pk $null) -Profile $profile
Assert ($r.Ok) 'C1 back-compat: packet without expectedClones passes'
Assert (-not $r.Declared) 'C1 Declared=false so the caller can warn'

Write-Output '== Case 2 (ROOT CAUSE): snapshot-not-a-clone gets its own distinct message =='
Rename-Item -LiteralPath (Join-Path $nested '.git') -NewName 'git_disabled'   # a frozen hand-copy
$r = Test-CdwExpectedClones -Packet (New-Pk @{ '.' = $shaB; 'lifepunchdxrp' = $shaN }) -Profile $profile
Assert (-not $r.Ok) 'C2 refuses a git-less snapshot'
Assert ((Errs $r) -match 'snapshot-not-a-clone') 'C2 distinct error string: snapshot-not-a-clone'
Assert ((Errs $r) -match 'lifepunchdxrp') 'C2 names the offending clone'
Assert ((Errs $r) -notmatch 'declared-commit-absent') 'C2 does NOT mask (a) behind a (b) failure'
Rename-Item -LiteralPath (Join-Path $nested 'git_disabled') -NewName '.git'

Write-Output '== Case 3: missing clone path =='
$r = Test-CdwExpectedClones -Packet (New-Pk @{ 'nope' = $shaN }) -Profile $profile
Assert (-not $r.Ok) 'C3 refuses a missing clone path'
Assert ((Errs $r) -match 'clone-path-missing') 'C3 distinct error string: clone-path-missing'

Write-Output '== Case 4: declared commit absent from a real clone (todays Green failure) =='
$r = Test-CdwExpectedClones -Packet (New-Pk @{ '.' = $absent }) -Profile $profile
Assert (-not $r.Ok) 'C4 refuses when the clone lacks the declared commit'
Assert ((Errs $r) -match 'declared-commit-absent') 'C4 distinct error string'
Assert ((Errs $r) -match [regex]::Escape($absent)) 'C4 names the EXPECTED commit'
Assert ((Errs $r) -match $shaB.Substring(0, 12)) 'C4 names the ACTUAL HEAD'
Assert ((Errs $r) -match "on 'main'") 'C4 names the actual branch'

Write-Output '== Case 5: HEAD does not CONTAIN a commit the clone has =='
Git-Q @('-C', $clone, 'checkout', '-q', $shaA)          # detach at A; B exists but is not reachable
$r = Test-CdwExpectedClones -Packet (New-Pk @{ '.' = $shaB }) -Profile $profile
Assert (-not $r.Ok) 'C5 refuses when HEAD does not contain the declared commit'
Assert ((Errs $r) -match 'head-does-not-contain-commit') 'C5 distinct error string'
Git-Q @('-C', $clone, 'checkout', '-q', 'main')

Write-Output '== Case 6: HEAD equals, and HEAD contains (ancestor), both pass =='
$r = Test-CdwExpectedClones -Packet (New-Pk @{ '.' = $shaB; 'lifepunchdxrp' = $shaN }) -Profile $profile
Assert ($r.Ok -and $r.Declared -and $r.Checked -eq 2) 'C6 HEAD equals declared: pass, 2 clones checked'
$r = Test-CdwExpectedClones -Packet (New-Pk @{ '.' = $shaA }) -Profile $profile
Assert ($r.Ok) 'C6 HEAD contains declared (ancestor): pass'
$r = Test-CdwExpectedClones -Packet (New-Pk @{ '.' = $shaB.Substring(0, 7) }) -Profile $profile
Assert ($r.Ok) 'C6 abbreviated sha accepted'

Write-Output '== Case 7 (SAFETY): path traversal / absolute keys refused, never resolved =='
$r = Test-CdwExpectedClones -Packet (New-Pk @{ '../evil' = $shaB }) -Profile $profile
Assert ((-not $r.Ok) -and (Errs $r) -match 'repo-relative') 'C7 refuses .. traversal'
$r = Test-CdwExpectedClones -Packet (New-Pk @{ 'C:\evil' = $shaB }) -Profile $profile
Assert ((-not $r.Ok) -and (Errs $r) -match 'repo-relative') 'C7 refuses absolute key'

Write-Output '== Case 8 (SCHEMA): expectedClones shape is validated, not trusted =='
function New-FullPk($ec) {
    $p = @{
        schemaVersion = 2; id = 'task-20260710-050501-x'; type = 'distill'; createdBy = 'red'
        createdTs = '2026-07-10T05:05:01Z'; repoProfile = 'lifepunch-private'; repoPath = 'C:\r'
        baseRemote = 'origin'; baseBranch = 'main'; focus = 'LifePunch'; routeTag = 'AUTO OK'
        inputs = @{ readFiles = @('game.txt'); maxBytes = 4 }; instruction = 'read the code and report'
        allowedOutputTypes = @('distill'); forbiddenScope = @(); requiresMaintainerApproval = $false
        mode = 'report'; deliverable = @{ outboxName = 'OUT'; format = 'markdown' }
    }
    if ($null -ne $ec) { $p.expectedClones = $ec }
    return ($p | ConvertTo-Json -Depth 8 | ConvertFrom-Json)
}
Assert ((Test-CdwPacketSchema -Packet (New-FullPk @{ '.' = $shaB })).Ok) 'C8 valid expectedClones accepted'
Assert (-not (Test-CdwPacketSchema -Packet (New-FullPk @{ '.' = 'nothex' })).Ok) 'C8 non-sha value rejected'
Assert (-not (Test-CdwPacketSchema -Packet (New-FullPk @{ '../x' = $shaB })).Ok) 'C8 traversal key rejected'
Assert ((Test-CdwPacketSchema -Packet (New-FullPk $null)).Ok) 'C8 absent expectedClones still valid (back-compat)'

Write-Output '== Case 9 (INTERACTION): untracked debris from a clone-swap trips the dirty gate =='
Assert ((Test-CdwCloneDirty -ClonePath $clone).Ok) 'C9 clean with the nested clone present (gitignored)'
New-Item -ItemType Directory -Force -Path (Join-Path $clone 'lifepunchdxrp_stale') | Out-Null
Set-Content -LiteralPath (Join-Path $clone 'lifepunchdxrp_stale\old.cs') -Value '// stale' -Encoding utf8
$d = Test-CdwCloneDirty -ClonePath $clone
Assert (-not $d.Ok) 'C9 a _stale sibling is UNTRACKED, not ignored => dirty (the gitignore pattern is anchored)'
Assert ($d.Error -match 'lifepunchdxrp_stale') 'C9 dirty error names the debris'
Remove-Item -LiteralPath (Join-Path $clone 'lifepunchdxrp_stale') -Recurse -Force

# =====================================================================
# E2E: reproduce-then-fix through the REAL worker. No model call anywhere.
# =====================================================================
$base = Join-Path $tmp 'cdw'
$paths = Get-CdwDefaultPaths -BaseDir $base
Initialize-CdwFolders -Paths $paths
New-Item -ItemType Directory -Force -Path (Join-Path $base 'config') | Out-Null
@{
    schemaVersion = 1
    profiles      = @{ 'lifepunch-private' = @{
            cloneWindows    = $clone
            expectedRemotes = @{ origin = 'mragerlp/lifepunch' }
            branchLaw       = @{ baseRemote = 'origin'; allowedBaseBranches = @('main', 'develop'); defaultBaseBranch = 'main' }
            focus           = 'LifePunch'; ipPosture = 'private-ok'; noIpScan = $false
        }
    }
} | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $paths.Registry -Encoding utf8

$pkDir = Join-Path $tmp 'packets'
function Invoke-Once {
    param([hashtable] $Expected)
    Get-ChildItem -LiteralPath $paths.Inbox -Filter '*.json' -EA SilentlyContinue | Remove-Item -Force
    # artifacts land in outbox\<taskId>\{report,error,meta} -- clear subdirs too, or a prior
    # run's error.md leaks into the next run's verdict.
    Remove-Item -Path (Join-Path $paths.Outbox '*') -Recurse -Force -EA SilentlyContinue
    Remove-Item -LiteralPath $pkDir -Recurse -Force -EA SilentlyContinue

    # -File would stringify every arg, so a [hashtable] param cannot cross it. Use -Command.
    $lit = '@{' + (($Expected.Keys | ForEach-Object { "'$_'='$($Expected[$_])'" }) -join ';') + '}'
    $author = Join-Path $here 'New-CornermanTaskPacket.ps1'
    $cmd = "& '$author' -RepoProfile lifepunch-private -RouteTag 'AUTO OK' -Slug freshness-gate " +
           "-Instruction 'read the cited file and report what it contains' -ReadFiles game.txt " +
           "-OutputDir '$pkDir' -Force -ExpectedClones $lit"
    $out = & powershell -NoProfile -ExecutionPolicy Bypass -Command $cmd 2>&1
    if ($LASTEXITCODE -ne 0) { throw "packet authoring failed: $($out | Out-String)" }
    Copy-Item -Path (Join-Path $pkDir '*.json') -Destination $paths.Inbox -Force

    $runOut = & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $here 'Invoke-CornermanWorkerOnce.ps1') `
        -BaseDir $base -RegistryPath $paths.Registry 2>&1
    # The verdict is whatever the worker actually emitted: console + every outbox artifact,
    # recursing into outbox\<taskId>\ where report.md / error.md / meta.json live.
    $arts = Get-ChildItem -LiteralPath $paths.Outbox -Recurse -File -EA SilentlyContinue |
        ForEach-Object { "--- $($_.Name)`n" + (Get-Content -LiteralPath $_.FullName -Raw) }
    return (($runOut | Out-String) + "`n" + ($arts -join "`n"))
}

Write-Output '== Case 10 (E2E REPRODUCE): packet names a commit this node does not have =='
$o = Invoke-Once @{ '.' = $absent }
Assert ($o -match 'clone freshness') 'C10 refused by the freshness gate'
Assert ($o -match 'declared-commit-absent') 'C10 the named message reached the operator'
Assert ($o -match [regex]::Escape($absent)) 'C10 names the expected commit'
Assert ($o -match 'pre-model-validation') 'C10 failed at pre-model-validation (before any model call)'

Write-Output '== Case 11 (E2E FIX): the corrected packet runs =='
$o = Invoke-Once @{ '.' = $shaB }
Assert ($o -notmatch 'clone freshness') 'C11 freshness gate passes on the corrected packet'
Assert ($o -notmatch 'declared-commit-absent') 'C11 no stale-commit refusal'
Assert ($o -match 'game\.txt|report|bravo') 'C11 the corrected packet reached the read/report stage'

Remove-Item -LiteralPath $tmp -Recurse -Force -EA SilentlyContinue
Write-Output ''
Write-Output "RESULT: pass=$script:pass fail=$script:fail"
if ($script:fail -gt 0) { exit 1 }
exit 0
