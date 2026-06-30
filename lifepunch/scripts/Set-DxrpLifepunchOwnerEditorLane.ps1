<#
.SYNOPSIS
  DXRP editor lane: owner OneDrive drop + lifepunchulx + bitcoinmining code (no repo art MIR).

.DESCRIPTION
  Assets source of truth:
    %USERPROFILE%\OneDrive\Desktop\addon test\addons\lifepunch\

  Also syncs from monorepo (code only):
    - lifepunchulx (adminmenu ship files + shared UI helpers)
    - bitcoinmining gameplay/UI C#
    - Code/_dev + lifepunch shared root

  Does NOT robocopy repo Assets/addons/lifepunch/lpbitcoin or legacy bitcoinmining meshes.

.PARAMETER ConfigPath
  dxrp-editor.local.json path.

.PARAMETER OwnerDropRoot
  Override owner drop (default: addon test\addons\lifepunch).

.PARAMETER SkipCode
  Assets + lifepunchulx only - skip bitcoinmining / _dev code sync.

.EXAMPLE
  powershell -File lifepunch\scripts\Set-DxrpLifepunchOwnerEditorLane.ps1
#>
[CmdletBinding()]
param(
    [string] $ConfigPath = '',
    [string] $OwnerDropRoot = '',
    [switch] $SkipCode,
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$pathsScript = Join-Path (Split-Path $Here -Parent) 'addons\scripts\LifePunch-AddonDropPaths.ps1'
. $pathsScript

if (-not $ConfigPath) { $ConfigPath = Join-Path $Here 'dxrp-editor.local.json' }
if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw "Missing $ConfigPath - copy dxrp-editor.local.json.example first."
}

if (-not $OwnerDropRoot) {
    $OwnerDropRoot = Get-LifePunchOwnerEditorDropRoot
}
if (-not (Test-Path -LiteralPath $OwnerDropRoot)) {
    throw @"
Missing owner editor drop: $OwnerDropRoot

Create or restore:
  %USERPROFILE%\OneDrive\Desktop\addon test\addons\lifepunch\
"@
}

$cfg = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
$sbprojPath = [string]$cfg.projectPath
$dxrpGame = Split-Path -Parent $sbprojPath

$ulxRepoIdent = 'adminmenu'
$ulxDxrpFolder = 'lifepunchulx'
$codeIdent = 'bitcoinmining'

$repoAddons = (Resolve-Path (Join-Path $Here '..\addons')).Path
$repoAssetsRoot = Join-Path $repoAddons 'Assets\addons\lifepunch'
$repoCodeRoot = Join-Path $repoAddons 'Code\Addons\lifepunch'
$repoUlxCode = Join-Path $repoCodeRoot $ulxRepoIdent
$repoBitcoinCode = Join-Path $repoCodeRoot $codeIdent
$repoDevCode = Join-Path $repoCodeRoot '_dev'

$dxrpAssetsRoot = Join-Path $dxrpGame 'Assets\addons\lifepunch'
$dxrpCodeRoot = Join-Path $dxrpGame 'Code\Addons\lifepunch'

function Remove-DxrpTree {
    param([string] $Path, [string] $Label)
    if (-not (Test-Path -LiteralPath $Path)) { return }
    if ($WhatIf) {
        Write-Host "  [WhatIf] purge $Label" -ForegroundColor DarkGray
        return
    }
    Remove-Item -LiteralPath $Path -Recurse -Force
    Write-Host "  purged: $Label" -ForegroundColor Yellow
}

function Invoke-OwnerMirror {
    param(
        [string] $From,
        [string] $To,
        [string] $Label
    )
    if ($WhatIf) {
        Write-Host "  [WhatIf] $Label" -ForegroundColor DarkGray
        Write-Host "           $From -> $To" -ForegroundColor DarkGray
        return
    }
    New-Item -ItemType Directory -Force -Path $To | Out-Null
    & robocopy $From $To /MIR /XD '_archive' /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy failed ($LASTEXITCODE): $Label" }
    $count = (Get-ChildItem -LiteralPath $To -Recurse -File -ErrorAction SilentlyContinue).Count
    Write-Host "  $Label - $count files" -ForegroundColor Green
}

function Sync-LifepunchUlx {
    $dxrpUlxAssets = Join-Path $dxrpAssetsRoot $ulxDxrpFolder
    $dxrpUlxCode = Join-Path $dxrpCodeRoot $ulxDxrpFolder
    $ulxAssetsSrc = Join-Path $repoAssetsRoot $ulxRepoIdent

    if (Test-Path -LiteralPath $ulxAssetsSrc) {
        if ($WhatIf) {
            Write-Host '  [WhatIf] Assets/lifepunchulx <- adminmenu' -ForegroundColor DarkGray
        }
        else {
            New-Item -ItemType Directory -Force -Path $dxrpUlxAssets | Out-Null
            & robocopy $ulxAssetsSrc $dxrpUlxAssets /MIR /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
            if ($LASTEXITCODE -ge 8) { throw 'robocopy ulx assets failed' }
            Write-Host '  Assets/lifepunchulx (adminmenu)' -ForegroundColor Green
        }
    }

    if (-not (Test-Path -LiteralPath $repoUlxCode)) {
        throw "Missing repo code: $repoUlxCode"
    }

    $shipFiles = @(
        'StaffMenu.razor',
        'StaffMenu.razor.scss',
        'StaffMenuHost.cs',
        'StaffMenuActions.cs',
        'StaffMenuBridgeService.cs'
    )

    if ($WhatIf) {
        Write-Host '  [WhatIf] Code/lifepunchulx ship files only (shared deps at Code/lifepunch root)' -ForegroundColor DarkGray
        return
    }

    if (Test-Path -LiteralPath $dxrpUlxCode) {
        Remove-Item -LiteralPath $dxrpUlxCode -Recurse -Force
    }
    New-Item -ItemType Directory -Force -Path $dxrpUlxCode | Out-Null

    foreach ($name in $shipFiles) {
        $src = Join-Path $repoUlxCode $name
        if (-not (Test-Path -LiteralPath $src)) { throw "Missing ship file: $src" }
        Copy-Item -LiteralPath $src -Destination (Join-Path $dxrpUlxCode $name) -Force
    }

    foreach ($name in @('StaffMenuTestBots.cs', 'StaffMenuTestBotsAutoSpawn.cs')) {
        $path = Join-Path $dxrpUlxCode $name
        if (-not (Test-Path -LiteralPath $path)) { continue }
        Rename-Item -LiteralPath $path -NewName ($name + '.quarantine') -Force
    }

    Write-Host '  Code/lifepunchulx (adminmenu ship files; shared UI at lifepunch root)' -ForegroundColor Green
}

function Sync-RepoLpBitcoinShipAssets {
    <#
      Owner drop holds source art (blend/fbx/png). Repo holds ModelDoc ship output
      (vmdl, vmats, prefab, _c). Overlay ship layers without clobbering owner source/.
    #>
    $repoLpBitcoin = Join-Path $repoAssetsRoot 'lpbitcoin'
    if (-not (Test-Path -LiteralPath $repoLpBitcoin)) {
        Write-Host '  skip repo ship overlay - no repo lpbitcoin assets' -ForegroundColor DarkGray
        return
    }

        $shipSubdirs = @('models', 'entities', 'sounds', 'source')
    $overlayCount = 0

    Get-ChildItem -LiteralPath $repoLpBitcoin -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $entity = $_.Name
        $assetsRoot = Join-Path $_.FullName 'assets'
        if (-not (Test-Path -LiteralPath $assetsRoot)) { return }

        foreach ($sub in $shipSubdirs) {
            $src = Join-Path $assetsRoot $sub
            if (-not (Test-Path -LiteralPath $src)) { continue }
            $dst = Join-Path $dxrpAssetsRoot "lpbitcoin\$entity\assets\$sub"
            if ($WhatIf) {
                Write-Host "  [WhatIf] ship overlay $entity/assets/$sub" -ForegroundColor DarkGray
                continue
            }
            New-Item -ItemType Directory -Force -Path $dst | Out-Null
            & robocopy $src $dst /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
            if ($LASTEXITCODE -ge 8) { throw "robocopy ship overlay failed: $entity/$sub" }
            $overlayCount += (Get-ChildItem -LiteralPath $dst -Recurse -File -ErrorAction SilentlyContinue).Count
        }

        $texSrc = Join-Path $assetsRoot 'textures'
        $texDst = Join-Path $dxrpAssetsRoot "lpbitcoin\$entity\assets\textures"
        if ((Test-Path -LiteralPath $texSrc) -and -not $WhatIf) {
            New-Item -ItemType Directory -Force -Path $texDst | Out-Null
            Get-ChildItem -LiteralPath $texSrc -File -ErrorAction SilentlyContinue |
                Where-Object {
                    $_.Extension -eq '.png' -or
                    $_.Extension -eq '.vtex_c' -or
                    $_.Name -like '*_c'
                } |
                ForEach-Object {
                    Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $texDst $_.Name) -Force
                    $overlayCount++
                }
        }
    }

    if (-not $WhatIf) {
        Write-Host "  repo ship overlay (models/entities/sounds + vtex_c) - $overlayCount files under lpbitcoin" -ForegroundColor Green
    }
}

function Sync-LpBitcoinEntityCode {
    $repoLpBitcoinCode = Join-Path $repoCodeRoot 'lpbitcoin'
    if (-not (Test-Path -LiteralPath $repoLpBitcoinCode)) { return }

    $dest = Join-Path $dxrpCodeRoot 'lpbitcoin'
    if ($WhatIf) {
        Write-Host '  [WhatIf] Code/lpbitcoin (entity code slots)' -ForegroundColor DarkGray
        return
    }

    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    & robocopy $repoLpBitcoinCode $dest /MIR /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw 'robocopy lpbitcoin code failed' }
    $count = (Get-ChildItem -LiteralPath $dest -Recurse -File -Include '*.cs','*.razor','*.scss' -ErrorAction SilentlyContinue).Count
    Write-Host "  Code/lpbitcoin (entity slots, $count source files)" -ForegroundColor Green
}

function Sync-BitcoinCode {
    if (-not (Test-Path -LiteralPath $repoBitcoinCode)) {
        throw "Missing repo code: $repoBitcoinCode"
    }
    $dest = Join-Path $dxrpCodeRoot $codeIdent
    if ($WhatIf) {
        Write-Host '  [WhatIf] Code/bitcoinmining' -ForegroundColor DarkGray
    }
    else {
        New-Item -ItemType Directory -Force -Path $dest | Out-Null
        & robocopy $repoBitcoinCode $dest /MIR /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
        if ($LASTEXITCODE -ge 8) { throw 'robocopy bitcoinmining code failed' }
        Write-Host '  Code/bitcoinmining (UI + gameplay, repo code only)' -ForegroundColor Green
    }

    $sharedCodeFiles = @(Get-ChildItem -LiteralPath $repoCodeRoot -File -ErrorAction SilentlyContinue)
    if ($sharedCodeFiles.Count -gt 0) {
        if (-not $WhatIf) {
            New-Item -ItemType Directory -Force -Path $dxrpCodeRoot | Out-Null
            foreach ($file in $sharedCodeFiles) {
                Copy-Item -LiteralPath $file.FullName -Destination (Join-Path $dxrpCodeRoot $file.Name) -Force
            }
            Write-Host "  Code/lifepunch shared root - $($sharedCodeFiles.Count) files" -ForegroundColor Green
        }
    }

    if (Test-Path -LiteralPath $repoDevCode) {
        $dxrpDev = Join-Path $dxrpCodeRoot '_dev'
        if ($WhatIf) {
            Write-Host '  [WhatIf] Code/_dev' -ForegroundColor DarkGray
        }
        else {
            New-Item -ItemType Directory -Force -Path $dxrpDev | Out-Null
            & robocopy $repoDevCode $dxrpDev /MIR /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
            if ($LASTEXITCODE -ge 8) { throw 'robocopy _dev failed' }
            $weaponDevGive = Join-Path $dxrpDev 'WeaponDevGive.cs'
            if (Test-Path -LiteralPath $weaponDevGive) {
                Rename-Item -LiteralPath $weaponDevGive -NewName 'WeaponDevGive.cs.quarantine' -Force
            }
            Write-Host '  Code/_dev (flatgrass + bitcoin dev ConCmds)' -ForegroundColor Green
        }
    }
}

function Update-RpSbprojResources {
    param([string[]] $OwnerPackages)

    if ($WhatIf) {
        Write-Host '  [WhatIf] rp.sbproj Resources update' -ForegroundColor DarkGray
        return
    }

    $content = Get-Content -LiteralPath $sbprojPath -Raw
    $match = [regex]::Match($content, '"Resources"\s*:\s*"((?:[^"\\]|\\.)*)"')
    if (-not $match.Success) { throw 'rp.sbproj Resources field not found' }

    $existing = ($match.Groups[1].Value -replace '\\n', [Environment]::NewLine) -split '\r?\n' |
        ForEach-Object { $_.Trim().TrimEnd('\') } |
        Where-Object { $_ }

    $mounts = [System.Collections.Generic.List[string]]::new()
    $seen = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)

    function Add-Mount([string]$Line) {
        if ([string]::IsNullOrWhiteSpace($Line)) { return }
        $Line = $Line.Trim().TrimEnd('\')
        if ($seen.Add($Line)) { $mounts.Add($Line) | Out-Null }
    }

    foreach ($line in @('ui/*', 'gameplay/entities/jobs/mayor/gun_license/gun_license.png')) {
        Add-Mount $line
    }
    foreach ($line in $existing) {
        if ($line -notmatch '^addons/lifepunch/') {
            Add-Mount $line
        }
    }

    Add-Mount "addons/lifepunch/$ulxDxrpFolder/**"
    foreach ($pkg in $OwnerPackages) {
        Add-Mount "addons/lifepunch/$pkg/**"
    }

    $resourcesForFile = ($mounts | Select-Object -Unique) -join '\n'
    $content = [regex]::Replace(
        $content,
        '"Resources"\s*:\s*"(?:[^"\\]|\\.)*"',
        '"Resources": "' + ($resourcesForFile -replace '\\', '\\') + '"'
    )
    [System.IO.File]::WriteAllText($sbprojPath, $content)
    Write-Host 'rp.sbproj Resources -> owner drop + lifepunchulx:' -ForegroundColor Green
    $mounts | Select-Object -Unique | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }
}

Write-Host 'DXRP owner editor lane (addon test + lifepunchulx)' -ForegroundColor Cyan
Write-Host "  Owner drop: $OwnerDropRoot" -ForegroundColor DarkGray
Write-Host "  DXRP game:  $dxrpGame" -ForegroundColor DarkGray

Write-Host 'Purge legacy repo-art paths from DXRP' -ForegroundColor Cyan
Remove-DxrpTree -Path (Join-Path $dxrpGame 'Assets\addons\lifepunch._quarantine') -Label 'Assets/lifepunch._quarantine'
Remove-DxrpTree -Path (Join-Path $dxrpGame 'Code\Addons\lifepunch._quarantine') -Label 'Code/lifepunch._quarantine'
Remove-DxrpTree -Path (Join-Path $dxrpAssetsRoot 'bitcoinmining') -Label 'Assets/bitcoinmining (legacy repo art)'
Remove-DxrpTree -Path (Join-Path $dxrpCodeRoot 'lifepunchulx') -Label 'Code/lifepunchulx (re-sync below)'
Remove-DxrpTree -Path (Join-Path $dxrpCodeRoot 'adminmenu') -Label 'Code/adminmenu (use lifepunchulx folder)'

$ownerPackages = @(
    Get-ChildItem -LiteralPath $OwnerDropRoot -Directory -ErrorAction SilentlyContinue |
        ForEach-Object { $_.Name }
)

Write-Host 'Mirror owner drop -> DXRP Assets/addons/lifepunch/*' -ForegroundColor Cyan
foreach ($pkg in $ownerPackages) {
    $src = Join-Path $OwnerDropRoot $pkg
    $dst = Join-Path $dxrpAssetsRoot $pkg
    Invoke-OwnerMirror -From $src -To $dst -Label "Assets/$pkg (owner drop)"
}

Write-Host 'Overlay repo lpbitcoin ship assets (vmdl/prefab/_c - not owner source/)' -ForegroundColor Cyan
Sync-RepoLpBitcoinShipAssets

# Remove DXRP asset folders not in owner drop (except lifepunchulx added next)
if (Test-Path -LiteralPath $dxrpAssetsRoot) {
    $keepAssets = @($ownerPackages) + @($ulxDxrpFolder)
    Get-ChildItem -LiteralPath $dxrpAssetsRoot -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        if ($keepAssets -contains $_.Name) { return }
        Remove-DxrpTree -Path $_.FullName -Label "Assets/$($_.Name) (not in owner drop)"
    }
}

Write-Host 'Sync lifepunchulx from repo' -ForegroundColor Cyan
Sync-LifepunchUlx

if (-not $SkipCode) {
    Write-Host 'Sync bitcoin code from repo (lpbitcoin slots + bitcoinmining package)' -ForegroundColor Cyan
    Sync-LpBitcoinEntityCode
    Sync-BitcoinCode

    if (-not $WhatIf) {
        $keepCode = @($ulxDxrpFolder, $codeIdent, 'lpbitcoin', '_dev')
        Get-ChildItem -LiteralPath $dxrpCodeRoot -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            if ($keepCode -contains $_.Name) { return }
            Remove-DxrpTree -Path $_.FullName -Label "Code/$($_.Name) (not in owner lane)"
        }
    }
}

Update-RpSbprojResources -OwnerPackages $ownerPackages

Write-Host ''
Write-Host 'Owner editor lane ready. Restart sbox editor if it was open.' -ForegroundColor Cyan
Write-Host '  Art: OneDrive drop (source) + repo ship overlay (vmdl/prefab/_c)' -ForegroundColor DarkGray
Write-Host '  ULX: lifepunchulx from repo adminmenu' -ForegroundColor DarkGray
Write-Host '  Code: lpbitcoin/{entity}/code + bitcoinmining (terminal/rack/economy) + _dev from repo' -ForegroundColor DarkGray
