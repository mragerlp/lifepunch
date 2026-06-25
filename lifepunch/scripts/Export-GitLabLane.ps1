# One-shot lane export using Windows Git Credential Manager (no GITLAB_TOKEN env required).
# WARNING: Replaces each monorepoPath entirely from GitHub — GitLab-only files in those trees are
# wiped. lifepunch-rdp-server: lifepunch/server/ clobber risk until Blue scripts land in monorepo
# or export excludes Blue-only paths. See lifepunch/docs/GITLAB_ORGANIZATION.md.
param(
    [Parameter(Mandatory)]
    [string] $Slug,
    [string] $CommitSuffix = ''
)

$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$MapPath = Join-Path $RepoRoot 'lifepunch\docs\gitlab-projects.json'
$Map = Get-Content -LiteralPath $MapPath -Raw | ConvertFrom-Json
$Project = @($Map.projects | Where-Object { $_.slug -eq $Slug })[0]
if (-not $Project) { throw "Unknown slug: $Slug" }

if ($Slug -eq 'lifepunch-rdp-server') {
    Write-Host 'WARN: export replaces lifepunch/server/ from GitHub — GitLab-only server scripts are wiped unless ported to monorepo or paths excluded (GITLAB_ORGANIZATION.md).' -ForegroundColor Yellow
}

$Grounding = @()
if ($Map.PSObject.Properties.Name -contains 'groundingBundle' -and $Map.groundingBundle) {
    $Grounding = @($Map.groundingBundle)
}
else {
    $Grounding = @('.cursor/rules', 'lifepunch/docs')
}

$AllPaths = @($Project.monorepoPaths) + @($Grounding) | Where-Object { $_ } | Select-Object -Unique
$PushUrl = "https://gitlab.com/mragerlp/$Slug.git"
$TempRoot = Join-Path $env:TEMP "lifepunch-export-$Slug"

Write-Host "Export $Slug from $RepoRoot" -ForegroundColor Cyan
if (Test-Path -LiteralPath $TempRoot) { Remove-Item -LiteralPath $TempRoot -Recurse -Force }

$prevPrompt = $env:GIT_TERMINAL_PROMPT
$env:GIT_TERMINAL_PROMPT = '0'
git clone --depth 1 $PushUrl $TempRoot
if ($LASTEXITCODE -ne 0) { throw "git clone failed ($LASTEXITCODE)" }
$env:GIT_TERMINAL_PROMPT = $prevPrompt

Get-ChildItem -LiteralPath $TempRoot -Force | Where-Object { $_.Name -ne '.git' } | Remove-Item -Recurse -Force
foreach ($Path in $AllPaths) {
    $Source = Join-Path $RepoRoot $Path
    if (-not (Test-Path -LiteralPath $Source)) {
        Write-Host "  WARN skip missing: $Path" -ForegroundColor Yellow
        continue
    }
    $Dest = Join-Path $TempRoot $Path
    $DestParent = Split-Path -Parent $Dest
    if ($DestParent) { New-Item -ItemType Directory -Path $DestParent -Force | Out-Null }
    Copy-Item -LiteralPath $Source -Destination $Dest -Recurse -Force
}

Push-Location $TempRoot
try {
    git add -A
    $monoSha = (git -C $RepoRoot rev-parse --short HEAD).Trim()
    $msg = "Lane export from GitHub monorepo (canonical: mragerlp/lifepunch) @$monoSha"
    if ($CommitSuffix) { $msg += " $CommitSuffix" }
    git -c user.name='LifePunch Setup' -c user.email='mragerlp@gmail.com' commit -m $msg
    if ($LASTEXITCODE -ne 0) {
        Write-Host 'No changes to commit (lane already current).' -ForegroundColor Yellow
        Pop-Location
        exit 0
    }
    git push origin HEAD:main
    if ($LASTEXITCODE -ne 0) { throw "git push failed ($LASTEXITCODE)" }
    $sha = (git rev-parse HEAD).Trim()
    Write-Host "EXPORT_OK $Slug sha=$sha mono=$monoSha" -ForegroundColor Green
}
finally {
    Pop-Location
    Remove-Item -LiteralPath $TempRoot -Recurse -Force -ErrorAction SilentlyContinue
}
