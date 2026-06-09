# LifePunch — create GitLab lane projects (optional) and push lane exports from the GitHub monorepo.
# Canonical repo stays: https://github.com/mragerlp/lifepunch
param(
    [string]$GitLabHost = 'https://gitlab.com',
    [string]$GitLabNamespace = 'mragerlp',
    [string]$GitLabToken = $env:GITLAB_TOKEN,
    [switch]$CreateProjects,
    [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$MapPath = Join-Path $RepoRoot 'lifepunch\docs\gitlab-projects.json'

if (-not (Test-Path -LiteralPath $MapPath)) {
    throw "Missing project map: $MapPath"
}

$Map = Get-Content -LiteralPath $MapPath -Raw | ConvertFrom-Json

function Get-GitLabUrl {
    param([string]$Slug)
    return "$GitLabHost/$GitLabNamespace/$Slug.git"
}

function New-GitLabProject {
    param([string]$Slug)

    if (-not $GitLabToken) {
        throw "CreateProjects requires GITLAB_TOKEN (PAT with api + write_repository). Cursor OAuth is read-only."
    }

    $headers = @{ 'PRIVATE-TOKEN' = $GitLabToken }
    $body = @{
        name                     = $Slug
        path                     = $Slug
        visibility               = 'private'
        initialize_with_readme   = $false
    } | ConvertTo-Json

    try {
        $r = Invoke-RestMethod -Uri "$GitLabHost/api/v4/projects" -Method Post -Headers $headers -Body $body -ContentType 'application/json'
        Write-Host "  Created: $($r.web_url)" -ForegroundColor Green
    }
    catch {
        $msg = $_.ErrorDetails.Message
        if ($msg -match 'has already been taken') {
            Write-Host "  Exists: $Slug" -ForegroundColor Yellow
        }
        else {
            throw "Failed to create $Slug : $msg"
        }
    }
}

function Test-GitLabProject {
    param([string]$Slug)
    $Url = Get-GitLabUrl -Slug $Slug
    git ls-remote $Url 2>$null | Out-Null
    return $?
}

function Push-SinglePathSubtree {
    param(
        [string]$Slug,
        [string]$Path,
        [string]$RemoteUrl
    )

    $Normalized = $Path -replace '/', '-'
    $SplitBranch = "split-$Normalized"

    git branch -D $SplitBranch 2>$null
    git subtree split --prefix=$Path -b $SplitBranch

    git remote remove "gitlab-$Slug" 2>$null
    git remote add "gitlab-$Slug" $RemoteUrl
    git push "gitlab-$Slug" "${SplitBranch}:main" --force-with-lease
    Write-Host "  Pushed $Path -> $Slug main" -ForegroundColor Green
}

function Push-MultiPathLane {
    param(
        [string]$Slug,
        [string[]]$Paths,
        [string]$RemoteUrl
    )

    $TempRoot = Join-Path $env:TEMP "lifepunch-export-$Slug"
    if (Test-Path -LiteralPath $TempRoot) {
        Remove-Item -LiteralPath $TempRoot -Recurse -Force
    }
    New-Item -ItemType Directory -Path $TempRoot | Out-Null

    foreach ($Path in $Paths) {
        $Source = Join-Path $RepoRoot $Path
        if (-not (Test-Path -LiteralPath $Source)) {
            throw "Missing monorepo path: $Path"
        }
        $Dest = Join-Path $TempRoot $Path
        New-Item -ItemType Directory -Path (Split-Path -Parent $Dest) -Force | Out-Null
        Copy-Item -LiteralPath $Source -Destination $Dest -Recurse -Force
    }

    $Readme = @"
# $Slug

LifePunch lane export. **Canonical monorepo:** https://github.com/mragerlp/lifepunch

Do not treat this repo as the sole source of truth — partner lane workspace only.
See lifepunch/docs/GITLAB_ORGANIZATION.md in the GitHub monorepo.
"@
    Set-Content -LiteralPath (Join-Path $TempRoot 'README.md') -Value $Readme -Encoding UTF8

    if ($WhatIf) {
        Write-Host "  WHATIF: export $($Paths.Count) paths to $TempRoot and push -> $RemoteUrl" -ForegroundColor Yellow
        return
    }

    Push-Location $TempRoot
    try {
        git init -q
        git add .
        git commit -q -m "Initial lane export from GitHub monorepo"
        git branch -M main
        git remote add origin $RemoteUrl
        git push -u origin main --force
        Write-Host "  Pushed $($Paths.Count) paths -> $Slug main" -ForegroundColor Green
    }
    finally {
        Pop-Location
        Remove-Item -LiteralPath $TempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Push-LaneSubtree {
    param(
        [string]$Slug,
        [string[]]$Paths
    )

    $RemoteUrl = Get-GitLabUrl -Slug $Slug
    Write-Host "`n=== $Slug ===" -ForegroundColor Cyan
    Write-Host "Remote: $RemoteUrl"
    Write-Host "Paths: $($Paths -join ', ')"

    if (-not (Test-GitLabProject -Slug $Slug)) {
        Write-Host "  SKIP — project not found. Run with -CreateProjects and GITLAB_TOKEN, or create empty project '$Slug' on GitLab." -ForegroundColor Yellow
        return $false
    }

    if ($WhatIf) {
        Write-Host "  WHATIF: would push lane to $RemoteUrl" -ForegroundColor Yellow
        return $true
    }

    if ($Slug -eq 'lifepunch-foundation') {
        git remote remove gitlab-foundation 2>$null
        git remote add gitlab-foundation $RemoteUrl
        git push gitlab-foundation main:main
        Write-Host "  Pushed monorepo main -> $Slug (transition anchor)" -ForegroundColor Green
        return $true
    }

    if ($Paths.Count -eq 1) {
        Push-SinglePathSubtree -Slug $Slug -Path $Paths[0] -RemoteUrl $RemoteUrl
        return $true
    }

    Push-MultiPathLane -Slug $Slug -Paths $Paths -RemoteUrl $RemoteUrl
    return $true
}

Write-Host "LifePunch GitLab setup — repo root: $RepoRoot" -ForegroundColor Cyan
Write-Host "Canonical GitHub: $($Map.canonicalGithubMonorepo)"
Write-Host "Map status: $($Map.migrationStatus)"

Push-Location $RepoRoot
try {
    if ($CreateProjects) {
        Write-Host "`nCreating GitLab projects..." -ForegroundColor Cyan
        foreach ($Project in $Map.projects) {
            New-GitLabProject -Slug $Project.slug
        }
    }

    $pushed = 0
    foreach ($Project in $Map.projects) {
        if (Push-LaneSubtree -Slug $Project.slug -Paths $Project.monorepoPaths) {
            $pushed++
        }
    }

    if ($pushed -eq $Map.projects.Count -and -not $WhatIf) {
        $Map.migrationStatus = 'lanes-synced'
        $Map | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $MapPath -Encoding UTF8
        Write-Host "`nUpdated migrationStatus -> lanes-synced" -ForegroundColor Green
    }

    Write-Host "`nDone. GitHub remains origin: $($Map.canonicalGithubClone)" -ForegroundColor Cyan
    Write-Host "Agent prompts: lifepunch/docs/AGENT_PROMPT.md"
}
finally {
    Pop-Location
}
