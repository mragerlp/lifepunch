<#
.SYNOPSIS
  Quarantine every LifePunch DXRP mount except lifepunchbitcoin (bitcoinmining) + _dev playtest helpers.

.DESCRIPTION
  DXRP editor install only — monorepo source unchanged.
  - Moves other Assets/Code lifepunch addon folders → lifepunch._quarantine/
  - Syncs repo bitcoinmining + _dev
  - Rewrites rp.sbproj Resources to addons/lifepunch/bitcoinmining/** only

.EXAMPLE
  powershell -File lifepunch\scripts\Set-DxrpLifepunchBitcoinOnly.ps1
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

$repoIdent = 'bitcoinmining'
$keepCodeFolders = @($repoIdent, '_dev')

$repoAddons = (Resolve-Path (Join-Path $Here '..\addons')).Path
$repoCodeSrc = Join-Path $repoAddons "Code\Addons\lifepunch\$repoIdent"
$repoDevSrc = Join-Path $repoAddons 'Code\Addons\lifepunch\_dev'

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

Write-Host 'DXRP Bitcoin-only lane — quarantine + bitcoinmining sync' -ForegroundColor Cyan
Write-Host "  Game: $dxrpGame" -ForegroundColor DarkGray

Write-Host 'Quarantine Assets/addons/lifepunch/*' -ForegroundColor Cyan
if (Test-Path -LiteralPath $dxrpAssetsRoot) {
    Get-ChildItem -LiteralPath $dxrpAssetsRoot -Directory | ForEach-Object {
        if ($_.Name -eq $repoIdent) { return }
        Move-AddonFolder -From $_.FullName -ToRoot $quarantineAssets -Name $_.Name
    }
}

Write-Host 'Quarantine Code/Addons/lifepunch/*' -ForegroundColor Cyan
if (Test-Path -LiteralPath $dxrpCodeRoot) {
    Get-ChildItem -LiteralPath $dxrpCodeRoot -Directory | ForEach-Object {
        if ($keepCodeFolders -contains $_.Name) { return }
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
    $quarantinePatterns = @('*.cs', '*.razor', '*.razor.scss')
    $quarantineRenamed = 0
    foreach ($pattern in $quarantinePatterns) {
        $files = Get-ChildItem -LiteralPath $quarantineCode -Recurse -File -Filter $pattern -ErrorAction SilentlyContinue
        foreach ($file in $files) {
            $off = "$($file.FullName).quarantine"
            if (-not (Test-Path -LiteralPath $off)) {
                Rename-Item -LiteralPath $file.FullName -NewName ($file.Name + '.quarantine') -Force
                $quarantineRenamed++
            }
        }
    }
    if ($quarantineRenamed -gt 0) {
        Write-Host "  quarantine: $quarantineRenamed source files renamed to *.quarantine (not compiled)" -ForegroundColor Yellow
    }
}

Write-Host "Sync repo $repoIdent" -ForegroundColor Cyan
$dxrpFolderAssets = Join-Path $dxrpAssetsRoot $repoIdent
$dxrpFolderCode = Join-Path $dxrpCodeRoot $repoIdent
New-Item -ItemType Directory -Force -Path $dxrpFolderCode | Out-Null

$assetsSrc = Join-Path $repoAddons "Assets\addons\lifepunch\$repoIdent"
if (Test-Path -LiteralPath $assetsSrc) {
    & robocopy $assetsSrc $dxrpFolderAssets /MIR /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy assets failed" }
    Write-Host '  Assets/bitcoinmining mirrored' -ForegroundColor Green
}

if (-not (Test-Path -LiteralPath $repoCodeSrc)) {
    throw "Missing repo code: $repoCodeSrc"
}
& robocopy $repoCodeSrc $dxrpFolderCode /MIR /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
if ($LASTEXITCODE -ge 8) { throw "robocopy code failed" }
$codeCount = (Get-ChildItem -LiteralPath $dxrpFolderCode -Recurse -File).Count
Write-Host "  Code/bitcoinmining - $codeCount files" -ForegroundColor Green

if (Test-Path -LiteralPath $repoDevSrc) {
    $dxrpDev = Join-Path $dxrpCodeRoot '_dev'
    New-Item -ItemType Directory -Force -Path $dxrpDev | Out-Null
    & robocopy $repoDevSrc $dxrpDev /MIR /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy _dev failed" }
    Write-Host '  Code/_dev mirrored (lp_map_flatgrass)' -ForegroundColor Green
}

$content = Get-Content -LiteralPath $sbprojPath -Raw
$marker = '"Resources": "'
$start = $content.IndexOf($marker)
if ($start -lt 0) { throw 'rp.sbproj Resources field not found' }
$valueStart = $start + $marker.Length
$valueEnd = $content.IndexOf( [char]34, $valueStart )
$resourcesBlock = $content.Substring($valueStart, $valueEnd - $valueStart)
$lines = $resourcesBlock -split '\\n' | Where-Object { $_ -and ($_ -notmatch 'addons/lifepunch/') }
$lines += ('addons/lifepunch/' + $repoIdent + '/**')
$newResources = ($lines | Select-Object -Unique) -join '\n'
$content = $content.Substring(0, $valueStart) + $newResources + $content.Substring($valueEnd)
[System.IO.File]::WriteAllText($sbprojPath, $content)
Write-Host ('rp.sbproj Resources -> addons/lifepunch/' + $repoIdent + '/** only') -ForegroundColor Green

Write-Host ''
Write-Host 'Bitcoin-only DXRP lane ready. Restart s&box editor (Resources changed).' -ForegroundColor Cyan
Write-Host 'Play: lp_map_flatgrass -> lp_bitcoin_spawn_kit -> USE hub / racks' -ForegroundColor DarkGray
