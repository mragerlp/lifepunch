# LifePunch - create GitLab lane projects and push lane exports from the GitHub monorepo.
# Canonical repo stays: https://github.com/mragerlp/lifepunch
# Lane repos are partner workspaces (no shared history); canonical history lives on GitHub.
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

function Get-PushUrl {
    param([string]$Slug)
    if ($GitLabToken) {
        $hostPart = $GitLabHost -replace '^https://', ''
        return "https://oauth2:$GitLabToken@$hostPart/$GitLabNamespace/$Slug.git"
    }
    return Get-GitLabUrl -Slug $Slug
}

function New-GitLabProject {
    param([string]$Slug)

    if (-not $GitLabToken) {
        throw "CreateProjects requires GITLAB_TOKEN (PAT with api + write_repository). Cursor OAuth is read-only."
    }

    $headers = @{ 'PRIVATE-TOKEN' = $GitLabToken }
    $body = @{
        name                   = $Slug
        path                   = $Slug
        visibility             = 'private'
        initialize_with_readme = $false
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

function Push-LaneExport {
    param(
        [string]$Slug,
        [string[]]$Paths,
        [string[]]$GroundingPaths = @()
    )

    # Self-grounding: union the lane's own paths with the grounding bundle (rules + docs), deduped.
    # Foundation already lists these, so the dedup makes the injection a no-op there.
    $AllPaths = @($Paths) + @($GroundingPaths) | Where-Object { $_ } | Select-Object -Unique

    Write-Host "`n=== $Slug ===" -ForegroundColor Cyan
    Write-Host "Paths: $($Paths -join ', ')"
    $injected = @($GroundingPaths | Where-Object { $Paths -notcontains $_ })
    if ($injected.Count -gt 0) {
        Write-Host "Grounding injected: $($injected -join ', ')" -ForegroundColor DarkCyan
    }

    if ($WhatIf) {
        Write-Host "  WHATIF: export $($AllPaths.Count) path(s) and push to $Slug" -ForegroundColor Yellow
        return $true
    }

    $PushUrl = Get-PushUrl -Slug $Slug
    $TempRoot = Join-Path $env:TEMP "lifepunch-export-$Slug"
    if (Test-Path -LiteralPath $TempRoot) {
        Remove-Item -LiteralPath $TempRoot -Recurse -Force
    }

    # If the lane already has content, UPDATE it in place (clone -> resync -> fast-forward push),
    # which respects protected main / never-force-push. If it's empty, fall back to a fresh init.
    # git writes "Cloning into..." to stderr; relax Stop here and gate on $LASTEXITCODE instead.
    $prevEAP0 = $ErrorActionPreference
    $prevPrompt0 = $env:GIT_TERMINAL_PROMPT
    $ErrorActionPreference = 'Continue'
    $env:GIT_TERMINAL_PROMPT = '0'
    git -c credential.helper= -c core.askpass= clone --depth 1 $PushUrl $TempRoot 2>&1 | Out-Null
    $cloneOk = ($LASTEXITCODE -eq 0) -and (Test-Path -LiteralPath (Join-Path $TempRoot '.git'))
    $env:GIT_TERMINAL_PROMPT = $prevPrompt0
    $ErrorActionPreference = $prevEAP0

    if ($cloneOk) {
        $LaneMode = 'update'
        # Clear tracked working tree (keep .git) so removals propagate as a clean delta.
        Get-ChildItem -LiteralPath $TempRoot -Force | Where-Object { $_.Name -ne '.git' } | Remove-Item -Recurse -Force
    }
    else {
        $LaneMode = 'fresh'
        if (Test-Path -LiteralPath $TempRoot) { Remove-Item -LiteralPath $TempRoot -Recurse -Force }
        New-Item -ItemType Directory -Path $TempRoot | Out-Null
    }
    Write-Host "  mode: $LaneMode" -ForegroundColor DarkGray

    foreach ($Path in $AllPaths) {
        $Source = Join-Path $RepoRoot $Path
        if (-not (Test-Path -LiteralPath $Source)) {
            Write-Host "  WARN: missing path skipped: $Path" -ForegroundColor Yellow
            continue
        }
        $Dest = Join-Path $TempRoot $Path
        $DestParent = Split-Path -Parent $Dest
        if ($DestParent) {
            New-Item -ItemType Directory -Path $DestParent -Force | Out-Null
        }
        Copy-Item -LiteralPath $Source -Destination $Dest -Recurse -Force
    }

    $Readme = "# $Slug`n`nLifePunch lane export. Canonical monorepo: https://github.com/mragerlp/lifepunch`n`nThis repo is a partner lane workspace, NOT the sole source of truth.`n`n## Grounding (read first)`n`nThis lane bundles a SYNCED MIRROR of the project grounding so it is self-contained:`n- ` + '`.cursor/rules`' + ` (auto-applies in Cursor at this lane root)`n- ` + '`lifepunch/docs/`' + ` (AGENT_ONBOARDING, WORKSPACE_STRUCTURE, GITLAB_ORGANIZATION, etc.)`n`nThe grounding is a READ-ONLY mirror of the GitHub monorepo. Do NOT edit ` + '`.cursor/rules`' + ` or`n` + '`lifepunch/docs/`' + ` here - change them in the monorepo; they are regenerated on each export.`nSee lifepunch/docs/GITLAB_ORGANIZATION.md.`n"
    Set-Content -LiteralPath (Join-Path $TempRoot 'README.md') -Value $Readme -Encoding UTF8

    Push-Location $TempRoot
    try {
        # git writes progress to stderr; relax Stop here and gate on $LASTEXITCODE instead.
        $prevEAP = $ErrorActionPreference
        $prevPrompt = $env:GIT_TERMINAL_PROMPT
        $ErrorActionPreference = 'Continue'
        # Token is embedded in $PushUrl; disable credential helper + prompts so GCM never pops a GUI and hangs.
        $env:GIT_TERMINAL_PROMPT = '0'
        $gitNoCred = @('-c', 'credential.helper=', '-c', 'core.askpass=')

        if ($LaneMode -eq 'fresh') {
            git init -q 2>&1 | Out-Null
            git symbolic-ref HEAD refs/heads/main 2>&1 | Out-Null
        }
        git add -A 2>&1 | Out-Null
        # commit is a no-op if nothing changed (update mode, lane already current); we gate on push exit.
        $commitMsg = "Lane export from GitHub monorepo (canonical: mragerlp/lifepunch)"
        git -c user.name='LifePunch Setup' -c user.email='mragerlp@gmail.com' commit -q -m $commitMsg 2>&1 | Out-Null
        # No --force: protected main rejects it (matches our never-force-push rule). Fresh push to an
        # empty repo and a fast-forward update of an existing lane both succeed.
        $pushOut = git @gitNoCred push $PushUrl HEAD:main 2>&1
        $pushExit = $LASTEXITCODE
        $ErrorActionPreference = $prevEAP
        $env:GIT_TERMINAL_PROMPT = $prevPrompt

        if ($pushExit -ne 0) {
            Write-Host "  PUSH FAILED for $Slug (exit $pushExit)" -ForegroundColor Red
            $pushOut | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
            return $false
        }
        Write-Host "  Pushed $($AllPaths.Count) path(s) -> $Slug main" -ForegroundColor Green
        return $true
    }
    finally {
        Pop-Location
        Remove-Item -LiteralPath $TempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "LifePunch GitLab setup - repo root: $RepoRoot" -ForegroundColor Cyan
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

    $Grounding = @()
    if ($Map.PSObject.Properties.Name -contains 'groundingBundle' -and $Map.groundingBundle) {
        $Grounding = @($Map.groundingBundle)
    }
    else {
        $Grounding = @('.cursor/rules', 'lifepunch/docs')
    }
    Write-Host "Grounding bundle (injected into every lane): $($Grounding -join ', ')" -ForegroundColor DarkCyan

    $pushed = 0
    foreach ($Project in $Map.projects) {
        if (Push-LaneExport -Slug $Project.slug -Paths $Project.monorepoPaths -GroundingPaths $Grounding) {
            $pushed++
        }
    }

    if ($pushed -eq $Map.projects.Count -and -not $WhatIf) {
        $Map.migrationStatus = 'lanes-synced'
        $Map | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $MapPath -Encoding UTF8
        Write-Host "`nUpdated migrationStatus -> lanes-synced ($pushed/$($Map.projects.Count) lanes)" -ForegroundColor Green
    }
    else {
        Write-Host "`nPushed $pushed/$($Map.projects.Count) lanes." -ForegroundColor Yellow
    }

    Write-Host "`nDone. GitHub remains origin: $($Map.canonicalGithubClone)" -ForegroundColor Cyan
    Write-Host "Agent prompts: lifepunch/docs/AGENT_PROMPT.md"
}
finally {
    Pop-Location
}
