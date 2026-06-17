<#
.SYNOPSIS
  Quarantine every LifePunch DXRP mount except lifepunchulx (adminmenu).

.DESCRIPTION
  DXRP editor install only — monorepo source unchanged.
  - Moves Assets/Code lifepunch addon folders → lifepunch._quarantine/
  - Syncs repo adminmenu → DXRP folder lifepunchulx (package slug law)
  - Rewrites rp.sbproj Resources to addons/lifepunch/lifepunchulx/** only

.PARAMETER ConfigPath
  dxrp-editor.local.json path.

.EXAMPLE
  powershell -File lifepunch\scripts\Set-DxrpLifepunchUlxOnly.ps1
#>
[CmdletBinding()]
param(
    [string] $ConfigPath = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $ConfigPath) { $ConfigPath = Join-Path $Here 'dxrp-editor.local.json' }
if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw "Missing $ConfigPath - copy dxrp-editor.local.json.example first."
}

$cfg = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
$sbprojPath = [string]$cfg.projectPath
$dxrpGame = Split-Path -Parent $sbprojPath

$repoIdent = 'adminmenu'
$dxrpFolder = 'lifepunchulx'

$repoAddons = (Resolve-Path (Join-Path $Here '..\addons')).Path
$repoCodeSrc = Join-Path $repoAddons "Code\Addons\lifepunch\$repoIdent"

$dxrpAssetsRoot = Join-Path $dxrpGame 'Assets\addons\lifepunch'
$dxrpCodeRoot = Join-Path $dxrpGame 'Code\Addons\lifepunch'
$quarantineAssets = Join-Path $dxrpGame 'Assets\addons\lifepunch._quarantine'
$quarantineCode = Join-Path $dxrpGame 'Code\Addons\lifepunch._quarantine'

function Move-AddonFolder {
    param(
        [string] $From,
        [string] $ToRoot,
        [string] $Name
    )
    if (-not (Test-Path -LiteralPath $From)) { return }
    New-Item -ItemType Directory -Force -Path $ToRoot | Out-Null
    $dest = Join-Path $ToRoot $Name
    if (Test-Path -LiteralPath $dest) {
        $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $dest = "${dest}.$stamp"
    }
    Move-Item -LiteralPath $From -Destination $dest -Force
    Write-Host "  quarantine: $Name -> $(Split-Path $dest -Leaf)" -ForegroundColor Yellow
}

Write-Host 'DXRP ULX-only lane — quarantine + lifepunchulx sync' -ForegroundColor Cyan
Write-Host "  Game: $dxrpGame" -ForegroundColor DarkGray

# 1) Quarantine all lifepunch addon folders (assets + code)
Write-Host 'Quarantine Assets/addons/lifepunch/*' -ForegroundColor Cyan
if (Test-Path -LiteralPath $dxrpAssetsRoot) {
    Get-ChildItem -LiteralPath $dxrpAssetsRoot -Directory | ForEach-Object {
        if ($_.Name -eq $dxrpFolder) { return }
        Move-AddonFolder -From $_.FullName -ToRoot $quarantineAssets -Name $_.Name
    }
}

Write-Host 'Quarantine Code/Addons/lifepunch/*' -ForegroundColor Cyan
if (Test-Path -LiteralPath $dxrpCodeRoot) {
    Get-ChildItem -LiteralPath $dxrpCodeRoot -Directory | ForEach-Object {
        if ($_.Name -eq $dxrpFolder) { return }
        Move-AddonFolder -From $_.FullName -ToRoot $quarantineCode -Name $_.Name
    }
    # Shared root + _dev — not lifepunchulx; quarantine so only ulx compiles
    Get-ChildItem -LiteralPath $dxrpCodeRoot -File | ForEach-Object {
        $qFiles = Join-Path $quarantineCode '_root'
        New-Item -ItemType Directory -Force -Path $qFiles | Out-Null
        Move-Item -LiteralPath $_.FullName -Destination (Join-Path $qFiles $_.Name) -Force
        Write-Host "  quarantine file: $($_.Name)" -ForegroundColor Yellow
    }
}

# s&box compiles every .cs under Code/ — quarantined sources must not remain as .cs
if (Test-Path -LiteralPath $quarantineCode) {
    $quarantineCs = Get-ChildItem -LiteralPath $quarantineCode -Recurse -File -Filter '*.cs' -ErrorAction SilentlyContinue
    foreach ($cs in $quarantineCs) {
        $off = "$($cs.FullName).quarantine"
        if (-not (Test-Path -LiteralPath $off)) {
            Rename-Item -LiteralPath $cs.FullName -NewName ($cs.Name + '.quarantine') -Force
        }
    }
    if ($quarantineCs.Count -gt 0) {
        Write-Host "  quarantine: $($quarantineCs.Count) .cs renamed to .cs.quarantine (not compiled)" -ForegroundColor Yellow
    }
}

# 2) Sync adminmenu → lifepunchulx
Write-Host "Sync repo $repoIdent -> DXRP $dxrpFolder" -ForegroundColor Cyan
$dxrpFolderAssets = Join-Path $dxrpAssetsRoot $dxrpFolder
$dxrpFolderCode = Join-Path $dxrpCodeRoot $dxrpFolder
New-Item -ItemType Directory -Force -Path $dxrpFolderCode | Out-Null

if (Test-Path -LiteralPath (Join-Path $repoAddons "Assets\addons\lifepunch\$repoIdent")) {
    & robocopy (Join-Path $repoAddons "Assets\addons\lifepunch\$repoIdent") $dxrpFolderAssets /MIR /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy assets failed" }
    Write-Host '  Assets/lifepunchulx mirrored' -ForegroundColor Green
}
else {
    Write-Host '  Assets/lifepunchulx — code-only (no repo assets)' -ForegroundColor DarkGray
    if (Test-Path -LiteralPath $dxrpFolderAssets) {
        Remove-Item -LiteralPath $dxrpFolderAssets -Recurse -Force -ErrorAction SilentlyContinue
    }
}

if (-not (Test-Path -LiteralPath $repoCodeSrc)) {
    throw "Missing repo code: $repoCodeSrc"
}
& robocopy $repoCodeSrc $dxrpFolderCode /MIR /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
if ($LASTEXITCODE -ge 8) { throw "robocopy code failed" }

$sharedBundle = @(
    'LifePunchUiScale.cs',
    'LifePunchUiScrollPolicy.cs',
    'LifePunchSourceMark.cs',
    'LifePunchUiFooter.razor',
    'LifePunchUiFooter.razor.scss'
)
$sharedRoot = Join-Path $repoAddons 'Code\Addons\lifepunch'
foreach ($name in $sharedBundle) {
    $src = Join-Path $sharedRoot $name
    if (Test-Path -LiteralPath $src) {
        Copy-Item -LiteralPath $src -Destination (Join-Path $dxrpFolderCode $name) -Force
    }
}
$staffScss = Join-Path $dxrpFolderCode 'StaffMenu.razor.scss'
if (Test-Path -LiteralPath $staffScss) {
    $scss = [System.IO.File]::ReadAllText($staffScss)
    $patched = $scss -replace '@import "\.\./LifePunchUiFooter\.razor\.scss";', '@import "./LifePunchUiFooter.razor.scss";'
    if ($patched -ne $scss) { [System.IO.File]::WriteAllText($staffScss, $patched) }
}

$codeCount = (Get-ChildItem -LiteralPath $dxrpFolderCode -Recurse -File).Count
Write-Host "  Code/lifepunchulx — $codeCount files" -ForegroundColor Green

# 3) rp.sbproj — only lifepunchulx resource glob
$content = Get-Content -LiteralPath $sbprojPath -Raw
$marker = '"Resources": "'
$start = $content.IndexOf($marker)
if ($start -lt 0) { throw 'rp.sbproj Resources field not found' }
$valueStart = $start + $marker.Length
$valueEnd = $content.IndexOf('"', $valueStart)
$resourcesBlock = $content.Substring($valueStart, $valueEnd - $valueStart)
$lines = $resourcesBlock -split '\\n' | Where-Object { $_ -and ($_ -notmatch 'addons/lifepunch/') }
$lines += "addons/lifepunch/$dxrpFolder/**"
$newResources = ($lines | Select-Object -Unique) -join '\n'
$content = $content.Substring(0, $valueStart) + $newResources + $content.Substring($valueEnd)
[System.IO.File]::WriteAllText($sbprojPath, $content)
Write-Host "rp.sbproj Resources -> addons/lifepunch/$dxrpFolder/** only" -ForegroundColor Green

Write-Host ''
Write-Host 'ULX-only DXRP lane ready. Restart s&box editor (Resources changed).' -ForegroundColor Cyan
Write-Host 'Quarantine: Assets/addons/lifepunch._quarantine + Code/Addons/lifepunch._quarantine' -ForegroundColor DarkGray
