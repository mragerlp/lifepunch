<#
.SYNOPSIS
  Export Cornerman session work to idle folder for VENGEANCE review (no git push).

.DESCRIPTION
  Run on Green at session end (e.g. 3:50 PM EST). Copies git-changed files from monorepo clone,
  outbox artifacts, validator log, optional format-patch, and writes MANIFEST.json.

.EXAMPLE
  powershell -File Export-CornermanIdle.ps1 -SessionLabel menu-ui-2026-06-13
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $SessionLabel,
    [string] $Summary = '',
    [string] $RepoRoot = 'C:\Projects\lifepunch',
    [string] $IdleRoot = 'C:\lifepunch\cornerman\idle\sessions',
    [string] $OutboxRoot = 'C:\lifepunch\cornerman\outbox'
)

$ErrorActionPreference = 'Stop'
$stamp = Get-Date -Format 'yyyy-MM-ddTHHmm'
$safeLabel = ($SessionLabel -replace '[^\w\-]', '-').Trim('-')
$sessionDir = Join-Path $IdleRoot "${stamp}-${safeLabel}"

if (Test-Path -LiteralPath $sessionDir) {
    throw "Session folder already exists: $sessionDir"
}

$repo = Join-Path $sessionDir 'repo'
$logs = Join-Path $sessionDir 'logs'
$outbox = Join-Path $sessionDir 'outbox'
$patches = Join-Path $sessionDir 'patches'

foreach ($d in @($sessionDir, $repo, $logs, $outbox, $patches)) {
    New-Item -ItemType Directory -Force -Path $d | Out-Null
}

# --- git snapshot ---
$gitHead = 'unknown'
$gitBehind = $null
$changedFiles = @()

if (Test-Path -LiteralPath (Join-Path $RepoRoot '.git')) {
    Push-Location $RepoRoot
    try {
        git fetch origin 2>&1 | Out-File -FilePath (Join-Path $logs 'git-fetch.txt') -Encoding utf8
        $gitHead = (git rev-parse HEAD 2>$null)
        if ($LASTEXITCODE -eq 0) {
            git rev-parse origin/main 2>$null | Out-File (Join-Path $logs 'origin-main-sha.txt')
            $count = git rev-list --count origin/main..HEAD 2>$null
            if ($count -match '^\d+$' -and [int]$count -gt 0) {
                New-Item -ItemType Directory -Force -Path $patches | Out-Null
                git format-patch origin/main..HEAD -o $patches 2>&1 | Out-File (Join-Path $logs 'format-patch.txt')
            }
        }
        git status -sb 2>&1 | Out-File (Join-Path $logs 'git-status.txt') -Encoding utf8
        git diff 2>&1 | Out-File (Join-Path $logs 'git-diff-unstaged.patch') -Encoding utf8
        git diff --cached 2>&1 | Out-File (Join-Path $logs 'git-diff-staged.patch') -Encoding utf8

        $names = git diff --name-only HEAD 2>$null
        $staged = git diff --cached --name-only 2>$null
        $untracked = git ls-files --others --exclude-standard 2>$null
        $changedFiles = @($names + $staged + $untracked | Where-Object { $_ } | Sort-Object -Unique)
    }
    finally {
        Pop-Location
    }
}

foreach ($rel in $changedFiles) {
    if ($rel -notmatch '^lifepunch/') { continue }
    $src = Join-Path $RepoRoot $rel
    if (-not (Test-Path -LiteralPath $src)) { continue }
    $dest = Join-Path $repo $rel
    $parent = Split-Path -Parent $dest
    if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    Copy-Item -LiteralPath $src -Destination $dest -Force
}

# --- outbox mirror (this session's new files) ---
if (Test-Path -LiteralPath $OutboxRoot) {
    $cutoff = (Get-Date).AddHours(-8)
    Get-ChildItem -LiteralPath $OutboxRoot -File -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -ge $cutoff } |
        ForEach-Object {
            Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $outbox $_.Name) -Force
        }
}

# --- validator ---
$validatorPath = Join-Path $RepoRoot 'lifepunch\addons\scripts\Validate-SboxRazorScss.ps1'
if (Test-Path -LiteralPath $validatorPath) {
    & powershell -NoProfile -File $validatorPath 2>&1 |
        Out-File (Join-Path $logs 'validate-sbox-razor-scss.txt') -Encoding utf8
    $validatorExit = $LASTEXITCODE
}
else {
    $validatorExit = -1
    'Validator script not found' | Out-File (Join-Path $logs 'validate-sbox-razor-scss.txt')
}

# --- summary template ---
$summaryPath = Join-Path $sessionDir 'SESSION_SUMMARY.md'
@(
    "# Session $safeLabel"
    ""
    "Exported: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') EST (local)"
    "Repo: $RepoRoot @ $gitHead"
    ""
    "## Summary"
    $(if ($Summary) { $Summary } else { '_Cornerman: fill pass/fail per task before shutdown._' })
    ""
    "## Validator"
    "Exit code: $validatorExit (0 = no forbidden SCSS patterns)"
    ""
    "## Changed files (lifepunch/)"
    $(if ($changedFiles.Count -eq 0) { '- (none)' } else { ($changedFiles | ForEach-Object { "- $_" }) })
    ""
    "## Red merge checklist"
    "- [ ] Review logs/validate-sbox-razor-scss.txt"
    "- [ ] Review repo/ diffs"
    "- [ ] Playtest on VENGEANCE if UI touched"
    "- [ ] Merge to main only after sign-off"
) | Set-Content -LiteralPath $summaryPath -Encoding utf8

$manifest = @{
    sessionLabel = $safeLabel
    exportedAt   = (Get-Date).ToUniversalTime().ToString('o')
    repoRoot     = $RepoRoot
    gitHead      = $gitHead
    changedFiles = $changedFiles
    validatorExitCode = $validatorExit
    summary      = $Summary
} | ConvertTo-Json -Depth 5

Set-Content -LiteralPath (Join-Path $sessionDir 'MANIFEST.json') -Value $manifest -Encoding utf8

$ready = @(
    "IDLE SESSION READY"
    "Folder: $sessionDir"
    "Label: $safeLabel"
    "Files: $($changedFiles.Count)"
    "Validator: $validatorExit"
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
) -join "`n"

Set-Content -LiteralPath (Join-Path $OutboxRoot 'IDLE_READY.txt') -Value $ready -Encoding utf8

Write-Host "OK idle export: $sessionDir" -ForegroundColor Green
Write-Host $ready
