# LifePunch session-start auto-sync (Windows / PowerShell).
# Failsafe so every clone (esp. partner lanes) opens on the latest data without anyone
# remembering to pull. Clean-only: never touches a dirty tree, never blocks the session.
# Pairs with .cursor/hooks/session-sync.sh (unix). Both are FAIL-OPEN by design.

$ErrorActionPreference = 'SilentlyContinue'
$env:GIT_TERMINAL_PROMPT = '0'   # never hang on a credential prompt

function Emit([string]$ctx) {
    if ($ctx) { (@{ additional_context = $ctx } | ConvertTo-Json -Compress) } else { '{}' }
    exit 0
}

# Drain stdin (hook input JSON); we don't need its contents.
try { $null = [Console]::In.ReadToEnd() } catch {}

$top = (& git rev-parse --show-toplevel 2>$null)
if (-not $top) { Emit $null }
Set-Location -LiteralPath $top

$gitDir = Join-Path $top '.git'
if ((Test-Path (Join-Path $gitDir 'rebase-merge')) -or
    (Test-Path (Join-Path $gitDir 'rebase-apply')) -or
    (Test-Path (Join-Path $gitDir 'MERGE_HEAD'))) {
    Emit "LifePunch auto-sync skipped: a rebase/merge is in progress. Finish it, then 'git pull --rebase'."
}

& git fetch --quiet 2>$null | Out-Null

$up = (& git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>$null)
if (-not $up) { Emit $null }   # no upstream tracking branch

$behind = (& git rev-list --count 'HEAD..@{u}' 2>$null)
if (-not $behind -or $behind -eq '0') { Emit $null }   # already current

$dirty = (& git status --porcelain 2>$null)
if ([string]::IsNullOrWhiteSpace($dirty)) {
    & git pull --rebase --quiet 2>$null | Out-Null
    $head = (& git rev-parse --short HEAD 2>$null)
    Emit "LifePunch auto-sync: pulled $behind new commit(s); now at $head. You are on the latest."
}
else {
    Emit "LifePunch auto-sync WARNING: you are $behind commit(s) behind origin AND have uncommitted changes. NOT auto-pulled (protecting your work). Commit or stash, then 'git pull --rebase' before continuing."
}
