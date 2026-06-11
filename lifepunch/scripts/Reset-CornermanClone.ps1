# Green box - abort stuck rebase/merge and hard-align clone to origin/main.
# Red owns git; Cornerman should NOT pull --rebase after local commits. Run from inbox or repo.
param(
    [string] $RepoRoot = 'C:\Projects\lifepunch',
    [string] $Branch = 'main'
)

$ErrorActionPreference = 'Stop'

$gitDir = Join-Path $RepoRoot '.git'
if (-not (Test-Path -LiteralPath $gitDir)) {
    throw "Not a git repo: $RepoRoot"
}

Push-Location $RepoRoot
try {
    $rebaseMerge = Join-Path $gitDir 'rebase-merge'
    $rebaseApply = Join-Path $gitDir 'rebase-apply'
    $mergeHead = Join-Path $gitDir 'MERGE_HEAD'

    if ((Test-Path -LiteralPath $rebaseMerge) -or (Test-Path -LiteralPath $rebaseApply)) {
        Write-Host 'Aborting in-progress rebase...' -ForegroundColor Yellow
        git rebase --abort
        if ($LASTEXITCODE -ne 0) {
            throw 'git rebase --abort failed'
        }
    }

    if (Test-Path -LiteralPath $mergeHead) {
        Write-Host 'Aborting in-progress merge...' -ForegroundColor Yellow
        git merge --abort
        if ($LASTEXITCODE -ne 0) {
            throw 'git merge --abort failed'
        }
    }

    Write-Host 'Fetching origin...' -ForegroundColor Cyan
    git fetch origin
    if ($LASTEXITCODE -ne 0) {
        throw 'git fetch failed'
    }

    $target = "origin/$Branch"
    Write-Host "git reset --hard $target" -ForegroundColor Cyan
    git reset --hard $target
    if ($LASTEXITCODE -ne 0) {
        throw 'git reset --hard failed'
    }

    $head = (git rev-parse --short HEAD).Trim()
    $subject = (git log -1 --format='%s').Trim()
    Write-Host "OK Cornerman at $head - $subject" -ForegroundColor Green
    git status -sb
}
finally {
    Pop-Location
}
