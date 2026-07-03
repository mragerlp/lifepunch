<#
.SYNOPSIS
  Align VENGEANCE Projects folder with LIFEPUNCH_REPO_LAYOUT.md.

.DESCRIPTION
  - Ensures monorepo root is C:\Users\jared\Projects\lifepunch
  - Nests DXRP fork at {MonorepoRoot}\lifepunchdxrp (from legacy C:\Users\jared\Projects\dxrp)
  - Retires duplicate sibling clone lifepunchdxrp when safe (junction -> lifepunch)

.EXAMPLE
  powershell -File lifepunch\scripts\Setup-LifepunchProjectsLayout.ps1
  powershell -File lifepunch\scripts\Setup-LifepunchProjectsLayout.ps1 -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string] $ProjectsRoot = 'C:\Users\jared\Projects',
    [string] $MonorepoName = 'lifepunch',
    [string] $LegacyMonorepoName = 'lifepunchdxrp',
    [string] $LegacyDxrpPath = 'C:\Users\jared\Projects\dxrp',
    [string] $NestedDxrpName = 'lifepunchdxrp'
)

$ErrorActionPreference = 'Stop'

function Test-GitMonorepo {
    param([string] $Path)
    if (-not (Test-Path -LiteralPath $Path)) { return $false }
    Push-Location -LiteralPath $Path
    try {
        $ok = [bool](git rev-parse --is-inside-work-tree 2>$null)
        if (-not $ok) { return $false }
        $url = git remote get-url origin 2>$null
        return ($url -match 'mragerlp/lifepunch')
    }
    finally {
        Pop-Location
    }
}

function Ensure-Junction {
    param(
        [string] $LinkPath,
        [string] $TargetPath
    )
    if (Test-Path -LiteralPath $LinkPath) {
        $item = Get-Item -LiteralPath $LinkPath -Force
        if ($item.LinkType -eq 'Junction' -and ($item.Target -contains $TargetPath)) {
            Write-Host "OK junction exists: $LinkPath -> $TargetPath" -ForegroundColor DarkGray
            return
        }
        if ($item.LinkType) {
            throw "Path exists but is not the expected junction: $LinkPath ($($item.LinkType))"
        }
        throw "Path exists and is not a junction: $LinkPath"
    }
    if ($PSCmdlet.ShouldProcess($LinkPath, "Create junction -> $TargetPath")) {
        New-Item -ItemType Junction -Path $LinkPath -Target $TargetPath | Out-Null
        Write-Host "Created junction: $LinkPath -> $TargetPath" -ForegroundColor Green
    }
}

$monorepoPath = Join-Path $ProjectsRoot $MonorepoName
$legacyMonorepoPath = Join-Path $ProjectsRoot $LegacyMonorepoName
$nestedDxrpPath = Join-Path $monorepoPath $NestedDxrpName

Write-Host 'LifePunch Projects layout setup' -ForegroundColor Cyan
Write-Host "  Target monorepo: $monorepoPath"

# Pick source of truth if lifepunch missing but lifepunchdxrp exists
if (-not (Test-Path -LiteralPath $monorepoPath)) {
    if (Test-GitMonorepo -Path $legacyMonorepoPath) {
        Write-Host "Monorepo folder missing; legacy clone found at $legacyMonorepoPath" -ForegroundColor Yellow
        if ($PSCmdlet.ShouldProcess($monorepoPath, "Create junction to $legacyMonorepoPath")) {
            Ensure-Junction -LinkPath $monorepoPath -TargetPath $legacyMonorepoPath
        }
    }
    else {
        throw "No monorepo at $monorepoPath or $legacyMonorepoPath"
    }
}

if (-not (Test-GitMonorepo -Path $monorepoPath)) {
    throw "Not a mragerlp/lifepunch git root: $monorepoPath"
}

Write-Host "OK monorepo git root: $monorepoPath" -ForegroundColor Green

# Nest legacy dxrp fork
if (Test-Path -LiteralPath $LegacyDxrpPath) {
    if (-not (Test-Path -LiteralPath $nestedDxrpPath)) {
        if ($PSCmdlet.ShouldProcess($nestedDxrpPath, "Move-Item from $LegacyDxrpPath")) {
            Move-Item -LiteralPath $LegacyDxrpPath -Destination $nestedDxrpPath
            Write-Host "Moved DXRP fork -> $nestedDxrpPath" -ForegroundColor Green
        }
    }
    else {
        Write-Host "Nested DXRP path already exists: $nestedDxrpPath (legacy dxrp left in place)" -ForegroundColor Yellow
    }
}
elseif (-not (Test-Path -LiteralPath $nestedDxrpPath)) {
    Write-Host "No legacy dxrp at $LegacyDxrpPath — clone manually into $nestedDxrpPath" -ForegroundColor Yellow
    Write-Host '  git clone https://github.com/mragerlp/dxrp-public.git lifepunchdxrp' -ForegroundColor DarkGray
}

# Optional: junction legacy sibling monorepo name to canonical lifepunch
if ((Test-Path -LiteralPath $legacyMonorepoPath) -and -not (Get-Item -LiteralPath $legacyMonorepoPath -Force).LinkType) {
    $resolvedMonorepo = (Resolve-Path -LiteralPath $monorepoPath).Path
    $resolvedLegacy = (Resolve-Path -LiteralPath $legacyMonorepoPath).Path
    if ($resolvedMonorepo -ne $resolvedLegacy) {
        Write-Host "NOTE: Two monorepo folders exist ($MonorepoName and $LegacyMonorepoName)." -ForegroundColor Yellow
        Write-Host '      Use lifepunch only; archive or remove the duplicate after syncing git.' -ForegroundColor Yellow
    }
}

Write-Host ''
Write-Host 'Next:' -ForegroundColor Cyan
Write-Host "  Cursor -> Open Folder -> $monorepoPath"
Write-Host '  git pull --rebase origin develop'
Write-Host '  Doc: lifepunch/docs/LIFEPUNCH_REPO_LAYOUT.md'
