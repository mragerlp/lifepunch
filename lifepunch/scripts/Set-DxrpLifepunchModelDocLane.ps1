<#
.SYNOPSIS
  DXRP editor lane: lifepunchulx + ModelDoc staging only (no job entity code).

.DESCRIPTION
  Fresh foundation pass — same idea as ULX-only, plus publish-aligned lp* staging packages.

  Mounts:
    - lifepunchulx (adminmenu) — unchanged publish-ready addon
    - lpbitcoin, lphacker, lppolice, lpgovernment, lpblackmarket, lpbanker, lpflashdrive, lpweapons
    - _dev/scenes — ModelDoc review scene

  Does NOT mount: bitcoinmining, hackerjob, _dev spawn helpers, or any quarantined ident.

.PARAMETER ConfigPath
  dxrp-editor.local.json path.

.EXAMPLE
  powershell -File lifepunch\scripts\Set-DxrpLifepunchModelDocLane.ps1
#>
[CmdletBinding()]
param(
    [string] $ConfigPath = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $ConfigPath) { $ConfigPath = Join-Path $Here 'dxrp-editor.local.json' }
if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw "Missing $ConfigPath - copy dxrp-editor.local.json.example and set projectPath first."
}

$cfg = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
$sbprojPath = [string]$cfg.projectPath
$dxrpGame = Split-Path -Parent $sbprojPath

$ulxRepoIdent = 'adminmenu'
$ulxDxrpFolder = 'lifepunchulx'
$devFolder = '_dev'
$stagingPackagePrefix = 'lp'
$configPath = Join-Path (Split-Path $Here -Parent) 'addons\config\package-staging.json'
$config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
$stagingPackages = @($config.packages.PSObject.Properties.Name)
$keepAssetFolders = @($ulxDxrpFolder, $devFolder) + $stagingPackages

$repoAddons = (Resolve-Path (Join-Path $Here '..\addons')).Path
$repoUlxCode = Join-Path $repoAddons "Code\Addons\lifepunch\$ulxRepoIdent"
$repoAssetsRoot = Join-Path $repoAddons 'Assets\addons\lifepunch'

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

function Remove-DxrpTree {
    param([string] $Path, [string] $Label)
    if (-not (Test-Path -LiteralPath $Path)) { return }
    Remove-Item -LiteralPath $Path -Recurse -Force
    Write-Host "  purged: $Label" -ForegroundColor Yellow
}

Write-Host 'DXRP ModelDoc greenfield lane - ULX + lp* staging packages' -ForegroundColor Cyan
Write-Host "  Game: $dxrpGame" -ForegroundColor DarkGray

# Purge stale quarantine debris if present
Remove-DxrpTree -Path $quarantineAssets -Label 'Assets/addons/lifepunch._quarantine (stale)'
Remove-DxrpTree -Path $quarantineCode -Label 'Code/Addons/lifepunch._quarantine (stale)'

Write-Host 'Quarantine Assets/addons/lifepunch/* (keep ulx + lp* + _dev)' -ForegroundColor Cyan
if (Test-Path -LiteralPath $dxrpAssetsRoot) {
    Get-ChildItem -LiteralPath $dxrpAssetsRoot -Directory | ForEach-Object {
        if ($keepAssetFolders -contains $_.Name) { return }
        Move-AddonFolder -From $_.FullName -ToRoot $quarantineAssets -Name $_.Name
    }
}

Write-Host 'Quarantine Code/Addons/lifepunch/* (keep lifepunchulx only)' -ForegroundColor Cyan
if (Test-Path -LiteralPath $dxrpCodeRoot) {
    Get-ChildItem -LiteralPath $dxrpCodeRoot -Directory | ForEach-Object {
        if ($_.Name -eq $ulxDxrpFolder) { return }
        Move-AddonFolder -From $_.FullName -ToRoot $quarantineCode -Name $_.Name
    }
    Get-ChildItem -LiteralPath $dxrpCodeRoot -File | ForEach-Object {
        $qFiles = Join-Path $quarantineCode '_root'
        New-Item -ItemType Directory -Force -Path $qFiles | Out-Null
        Move-Item -LiteralPath $_.FullName -Destination (Join-Path $qFiles $_.Name) -Force
        Write-Host "  quarantine file: $($_.Name)" -ForegroundColor Yellow
    }
}

if (Test-Path -LiteralPath $quarantineCode) {
    $quarantineSources = Get-ChildItem -LiteralPath $quarantineCode -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension -in '.cs', '.razor', '.scss' -and $_.Name -notlike '*.quarantine' }
    foreach ($src in $quarantineSources) {
        $off = "$($src.FullName).quarantine"
        if (-not (Test-Path -LiteralPath $off)) {
            Rename-Item -LiteralPath $src.FullName -NewName ($src.Name + '.quarantine') -Force
        }
    }
    if ($quarantineSources.Count -gt 0) {
        Write-Host "  quarantine: $($quarantineSources.Count) source files -> *.quarantine (not compiled)" -ForegroundColor Yellow
    }
}

Write-Host "Sync repo $ulxRepoIdent -> DXRP $ulxDxrpFolder" -ForegroundColor Cyan
$dxrpUlxAssets = Join-Path $dxrpAssetsRoot $ulxDxrpFolder
$dxrpUlxCode = Join-Path $dxrpCodeRoot $ulxDxrpFolder
New-Item -ItemType Directory -Force -Path $dxrpUlxCode | Out-Null

$ulxAssetsSrc = Join-Path $repoAddons "Assets\addons\lifepunch\$ulxRepoIdent"
if (Test-Path -LiteralPath $ulxAssetsSrc) {
    & robocopy $ulxAssetsSrc $dxrpUlxAssets /MIR /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw 'robocopy ulx assets failed' }
    Write-Host '  Assets/lifepunchulx mirrored' -ForegroundColor Green
}
else {
    if (Test-Path -LiteralPath $dxrpUlxAssets) {
        Remove-Item -LiteralPath $dxrpUlxAssets -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Host '  Assets/lifepunchulx - code-only' -ForegroundColor DarkGray
}

if (-not (Test-Path -LiteralPath $repoUlxCode)) {
    throw "Missing repo code: $repoUlxCode"
}
& robocopy $repoUlxCode $dxrpUlxCode /MIR /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
if ($LASTEXITCODE -ge 8) { throw 'robocopy ulx code failed' }
Write-Host '  Code/lifepunchulx mirrored' -ForegroundColor Green

Write-Host 'Quarantine StaffMenuTestBots* (DXRP API drift — not needed for ModelDoc)' -ForegroundColor Cyan
$testBotFiles = @(
    'StaffMenuTestBots.cs',
    'StaffMenuTestBotsAutoSpawn.cs'
)
foreach ($name in $testBotFiles) {
    $path = Join-Path $dxrpUlxCode $name
    if (-not (Test-Path -LiteralPath $path)) { continue }
    $off = "$path.quarantine"
    if (Test-Path -LiteralPath $off) {
        Remove-Item -LiteralPath $path -Force
        continue
    }
    Rename-Item -LiteralPath $path -NewName ($name + '.quarantine') -Force
    Write-Host "  quarantine: $name" -ForegroundColor Yellow
}

$repoCodeRoot = Join-Path $repoAddons 'Code\Addons\lifepunch'
$sharedRootFiles = @(Get-ChildItem -LiteralPath $repoCodeRoot -File -ErrorAction SilentlyContinue)
if ($sharedRootFiles.Count -gt 0) {
    New-Item -ItemType Directory -Force -Path $dxrpCodeRoot | Out-Null
    foreach ($file in $sharedRootFiles) {
        Copy-Item -LiteralPath $file.FullName -Destination (Join-Path $dxrpCodeRoot $file.Name) -Force
    }
    Write-Host "  Code/lifepunch shared root - $($sharedRootFiles.Count) files (ULX deps)" -ForegroundColor Green
}

Write-Host 'Sync repo lp* staging + _dev -> DXRP (assets only)' -ForegroundColor Cyan
foreach ($pkg in $stagingPackages) {
    $src = Join-Path $repoAssetsRoot $pkg
    if (-not (Test-Path -LiteralPath $src)) { continue }
    $dst = Join-Path $dxrpAssetsRoot $pkg

    # Phase A: lpbitcoin on disk = bitcoinhub only (no terminal/racks/_archive compile noise).
    if ($pkg -eq 'lpbitcoin') {
        $hubSrc = Join-Path $src 'bitcoinhub'
        if (-not (Test-Path -LiteralPath $hubSrc)) { continue }
        $hubDst = Join-Path $dst 'bitcoinhub'
        & robocopy $hubSrc $hubDst /E /XD '_archive' /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
        if ($LASTEXITCODE -ge 8) { throw 'robocopy lpbitcoin/bitcoinhub failed' }
        if (Test-Path -LiteralPath $dst) {
            Get-ChildItem -LiteralPath $dst -Directory | ForEach-Object {
                if ($_.Name -ne 'bitcoinhub') {
                    Remove-DxrpTree -Path $_.FullName -Label "lpbitcoin/$($_.Name) (Phase A hub-only)"
                }
            }
        }
        $archiveOnDisk = Join-Path $hubDst '_archive'
        Remove-DxrpTree -Path $archiveOnDisk -Label 'lpbitcoin/bitcoinhub/_archive'
        Write-Host '  Assets/lpbitcoin/bitcoinhub mirrored (hub-only; _archive excluded)' -ForegroundColor Green
        continue
    }

    & robocopy $src $dst /MIR /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy staging package failed: $pkg" }
    Write-Host "  Assets/$pkg mirrored" -ForegroundColor Green
}
$devSrc = Join-Path $repoAssetsRoot $devFolder
if (Test-Path -LiteralPath $devSrc) {
    $devDst = Join-Path $dxrpAssetsRoot $devFolder
    & robocopy $devSrc $devDst /MIR /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw 'robocopy _dev failed' }
    Write-Host '  Assets/_dev mirrored' -ForegroundColor Green
}

$content = Get-Content -LiteralPath $sbprojPath -Raw
$marker = '"Resources": "'
$start = $content.IndexOf($marker)
if ($start -lt 0) { throw 'rp.sbproj Resources field not found' }
$valueStart = $start + $marker.Length
$valueEnd = $content.IndexOf('"', $valueStart)
$resourcesBlock = $content.Substring($valueStart, $valueEnd - $valueStart)
$lines = $resourcesBlock -split '\\n' | Where-Object { $_ -and ($_ -notmatch 'addons/lifepunch/') }
$lines += "addons/lifepunch/$ulxDxrpFolder/**"
$lines += "addons/lifepunch/$devFolder/**"
# Phase A (Model Foundation): hub model/textures/source only — skip _archive sketchfab + entities until code remount.
$lines += 'addons/lifepunch/lpbitcoin/bitcoinhub/assets/models/**'
$lines += 'addons/lifepunch/lpbitcoin/bitcoinhub/assets/textures/**'
$lines += 'addons/lifepunch/lpbitcoin/bitcoinhub/assets/source/**'
$lines += 'addons/lifepunch/lpbitcoin/bitcoinhub/assets/entities/**'
$newResources = ($lines | Select-Object -Unique) -join '\n'
$content = $content.Substring(0, $valueStart) + $newResources + $content.Substring($valueEnd)
[System.IO.File]::WriteAllText($sbprojPath, $content)
Write-Host 'rp.sbproj Resources -> lifepunchulx + _dev + lpbitcoin/bitcoinhub/assets (no _archive)' -ForegroundColor Green
Write-Host '  lp* assets synced to disk; mount terminal/racks in sbproj when Phase B/C starts.' -ForegroundColor DarkGray

Write-Host ''
Write-Host 'ModelDoc greenfield lane ready. Restart s&box editor.' -ForegroundColor Cyan
Write-Host 'Law: MODEL_FOUNDATION_PASS.md - no play test until model sign-off.' -ForegroundColor DarkGray
Write-Host 'Quarantine: Assets/Code lifepunch._quarantine (recent DXRP mounts, not deleted from repo).' -ForegroundColor DarkGray
