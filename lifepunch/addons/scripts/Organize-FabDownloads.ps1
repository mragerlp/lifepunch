<#
.SYNOPSIS
  Move Fab library zips from Downloads into OneDrive intake drop folders.

.DESCRIPTION
  Matches zip filenames (and optional inner folder names after extract) to entity drop paths.
  Run after downloading from fab.com/library in Chrome/Edge (not Cursor Glass browser).

.EXAMPLE
  powershell -File lifepunch/addons/scripts/Organize-FabDownloads.ps1
  powershell -File lifepunch/addons/scripts/Organize-FabDownloads.ps1 -DownloadsPath "$env:USERPROFILE\Downloads" -WhatIf
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string] $DownloadsPath = (Join-Path $env:USERPROFILE 'Downloads'),
    [switch] $Extract
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'LifePunch-AddonDropPaths.ps1')

$root = Get-LifePunchAddonsDropRoot
if (-not $root) {
    throw 'No OneDrive LIFEPUNCH*\addons root found. Run Initialize-FabDropFolders.ps1 first.'
}

# Fab library title substring (case-insensitive) -> relative path under addons\
$map = [ordered]@{
    'CPU GAMER'                          = 'lifepunchbitcoin\bitcoinminer'
    'Computer all-in-one'                = 'lifepunchbitcoin\bitcointerminal'
    'Crypto Farm'                        = 'lifepunchbitcoin\gpurack'
    'Mining Rig'                         = 'lifepunchbitcoin\gpurack'
    'Retro Display Terminal'             = 'lifepunchhacker\hacker\hackerterminal'
    'Retro Computer 80s'                 = 'lifepunchhacker\hacker\advancedhackerterminal'
    'Sci Fi Server rack'                 = 'lifepunchhacker\hacker\serverrack'
    'Sci Fi Server Rack'                 = 'lifepunchhacker\hacker\advancedserverrack'
    'RETRO CRT MILITARY'                 = 'lifepunchhacker\fbi\policeterminal'
    'Servers (DataCenter)'               = 'lifepunchhacker\fbi\governmentserverrack'
    'Vault Safe'                         = 'lifepunchblackmarketdealer\blackmarkethub'
    'Payment Terminal'                   = 'lifepunchblackmarketdealer\blackmarketterminal'
    'Locker 19'                          = 'lifepunchblackmarketdealer\blackmarketlocker'
    'Sci-fi Computer console'            = 'lifepunchbanker\bankterminal'
    'Modern ATM'                         = 'lifepunchbanker\bankeratm'
    'Retro computer'                     = 'lifepunchbanker\bankerhub'
    'USB Flash Drive'                    = 'lifepunchuniversal\usbflashdrive'
    'Assault Rifle'                      = 'lifepunchuniversal\suppressedar15'
    'AR 15'                              = 'lifepunchuniversal\suppressedar15'
}

if (-not (Test-Path -LiteralPath $DownloadsPath)) {
    throw "Downloads path not found: $DownloadsPath"
}

$zips = Get-ChildItem -LiteralPath $DownloadsPath -Filter '*.zip' -File -ErrorAction SilentlyContinue
if ($zips.Count -eq 0) {
    Write-Host "No .zip files in $DownloadsPath" -ForegroundColor Yellow
    Write-Host 'Download from https://www.fab.com/library in Chrome/Edge, then re-run.' -ForegroundColor DarkGray
    exit 0
}

Write-Host "Drop root: $root" -ForegroundColor Cyan
Write-Host "Scanning $($zips.Count) zip(s) in $DownloadsPath`n" -ForegroundColor Cyan

foreach ($zip in $zips) {
    $matched = $null
    foreach ($key in $map.Keys) {
        if ($zip.Name -like "*$key*") {
            $matched = $map[$key]
            break
        }
    }

    if (-not $matched) {
        Write-Host "  SKIP (no match): $($zip.Name)" -ForegroundColor DarkYellow
        continue
    }

    $destDir = Join-Path $root $matched
    $sourceDir = Join-Path $destDir 'source'
    New-Item -ItemType Directory -Force -Path $sourceDir | Out-Null
    $destZip = Join-Path $sourceDir $zip.Name

    if ($PSCmdlet.ShouldProcess($zip.FullName, "Copy to $destZip")) {
        Copy-Item -LiteralPath $zip.FullName -Destination $destZip -Force
        Write-Host "  OK $($zip.Name) -> $matched\source\" -ForegroundColor Green

        if ($Extract) {
            $extractTo = Join-Path $sourceDir ([IO.Path]::GetFileNameWithoutExtension($zip.Name))
            if ($PSCmdlet.ShouldProcess($destZip, "Extract to $extractTo")) {
                New-Item -ItemType Directory -Force -Path $extractTo | Out-Null
                Expand-Archive -LiteralPath $destZip -DestinationPath $extractTo -Force
                Write-Host "       extracted -> $extractTo" -ForegroundColor DarkGray
            }
        }
    }
}

Write-Host ''
Write-Host 'Next: run intake scripts per entity or manual ModelDoc compile (Phase 1 collision).' -ForegroundColor DarkGray
