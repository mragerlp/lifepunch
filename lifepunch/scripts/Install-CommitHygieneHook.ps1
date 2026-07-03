<#
.SYNOPSIS
  Install the LifePunch commit-msg guard into one or more git clones.

.DESCRIPTION
  Writes a fail-closed `commit-msg` hook that BLOCKS any commit whose message contains an
  AI/agent attribution trailer (Cursor, Claude, Copilot, ChatGPT, OpenAI, Anthropic, or
  Generated-with/Assisted-by lines). This is the mechanical backstop behind the
  `lifepunch-commit-hygiene` rule.

  The hook lives in `.git/hooks/commit-msg` (NOT tracked by git), so it must be installed per
  clone. This script is the canonical source of the hook body. Re-run after a fresh clone.

  Primary trigger: keep the Cursor co-author trailer out of the public DXRP fork
  (mragerlp/dxrp-public -> dxura/dxrp). See lifepunch/docs/DXRP_CONTRIBUTOR_LANE.md.

.PARAMETER RepoPath
  One or more repo roots to install into. Defaults to the DXRP fork + the LifePunch monorepo.

.EXAMPLE
  powershell -File lifepunch\scripts\Install-CommitHygieneHook.ps1
#>
[CmdletBinding()]
param(
    [string[]] $RepoPath = @(
        'C:\Users\jared\Projects\dxrp',
        'C:\Users\jared\Projects\lifepunchdxrp'
    )
)

$ErrorActionPreference = 'Stop'

# Canonical hook body (POSIX sh; LF only). grep -E with [[:space:]] is git-bash safe.
$hookBody = @'
#!/bin/sh
# LifePunch commit-msg guard — block AI/agent attribution trailers in commit messages.
# Source of truth: lifepunch/scripts/Install-CommitHygieneHook.ps1 (do not hand-edit here).
# Law: .cursor/rules/lifepunch-commit-hygiene.mdc. FAIL-CLOSED on match.
msg_file="$1"
[ -f "$msg_file" ] || exit 0

if grep -Eiq 'co-authored-by:[[:space:]]*(cursor|claude|copilot|chatgpt|openai|anthropic)|cursoragent@cursor\.com|noreply@anthropic\.com|generated (with|by) (cursor|claude|chatgpt|copilot)|(assisted|generated|ai)-(authored-)?by:.*(cursor|claude|copilot|chatgpt|ai)' "$msg_file"; then
  echo ""                                                                             1>&2
  echo "BLOCKED by LifePunch commit-msg guard: AI/agent attribution found."           1>&2
  echo "Remove Co-authored-by / Generated-with lines (Cursor, Claude, Copilot, ...)." 1>&2
  echo "Author is Bloodwave / mragerlp only. See lifepunch-commit-hygiene rule."      1>&2
  echo "Root cause: Cursor Settings > Agent > Attribution (Commit + PR) must be OFF." 1>&2
  echo ""                                                                             1>&2
  exit 1
fi
exit 0
'@

# Normalize to LF, no BOM.
$hookBody = $hookBody -replace "`r`n", "`n"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$installed = 0
foreach ($repo in $RepoPath) {
    if (-not (Test-Path -LiteralPath $repo)) {
        Write-Warning "skip (missing): $repo"
        continue
    }
    $gitDir = Join-Path $repo '.git'
    if (-not (Test-Path -LiteralPath $gitDir)) {
        Write-Warning "skip (not a git repo): $repo"
        continue
    }
    $hooksDir = Join-Path $gitDir 'hooks'
    if (-not (Test-Path -LiteralPath $hooksDir)) {
        New-Item -ItemType Directory -Path $hooksDir | Out-Null
    }
    $hookPath = Join-Path $hooksDir 'commit-msg'
    [System.IO.File]::WriteAllText($hookPath, $hookBody, $utf8NoBom)

    # Best-effort exec bit (git-for-windows ships bash). Harmless if unavailable.
    $bash = Get-Command bash -ErrorAction SilentlyContinue
    if ($bash) {
        & $bash.Source -lc "chmod +x '$($hookPath -replace '\\','/')'" 2>$null
    }

    Write-Host "installed commit-msg guard -> $hookPath"
    $installed++
}

Write-Host "done: $installed hook(s) installed."
