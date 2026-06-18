<#
.SYNOPSIS
  Package the working VENGEANCE s&box dedicated files for lifepunchnet (Blue) Dev server.

.DESCRIPTION
  Copies dxrp-server.cs + sbox-server.* from D:\Steam\steamapps\common\sbox into
  lifepunch/server/blue-dev-package/ for RDP transfer to C:\S&BOX DXRP Server\

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File lifepunch\scripts\Package-BlueDevServerFromVengeance.ps1
#>
[CmdletBinding()]
param(
    [string] $VengeanceSboxRoot = 'D:\Steam\steamapps\common\sbox',
    [string] $OutputDir = ''
)

$ErrorActionPreference = 'Stop'

if (-not $OutputDir) {
    $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $OutputDir = Join-Path $repoRoot 'lifepunch\server\blue-dev-package'
}

if (-not (Test-Path -LiteralPath $VengeanceSboxRoot)) {
    throw "VENGEANCE sbox root not found: $VengeanceSboxRoot"
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$files = @(
    'dxrp-server.cs',
    'sbox-server.dll',
    'sbox-server.exe',
    'sbox-server.runtimeconfig.json'
)

foreach ($name in $files) {
    $src = Join-Path $VengeanceSboxRoot $name
    if (-not (Test-Path -LiteralPath $src)) {
        Write-Warning "Skip missing: $src"
        continue
    }
    Copy-Item -LiteralPath $src -Destination (Join-Path $OutputDir $name) -Force
    Write-Host "  OK $name" -ForegroundColor DarkGray
}

$paste = @'
================================================================================
BLUE RDP — paste after copying this package to C:\S&BOX DXRP Server\
================================================================================
1. Copy ALL files from blue-dev-package into C:\S&BOX DXRP Server\
2. secure\development.local.env must have DXRP_TOKEN_DEVELOPMENT=<portal token>
3. Portal Development server IP = 205.209.104.22  port 27016
4. STOP any Dev server still running on VENGEANCE (Ctrl+C in that PowerShell)

cd /d "C:\S&BOX DXRP Server"
fix_steam.bat
dotnet run dxrp-server.cs --token PASTE_DEV_TOKEN_HERE

PASS: Connected to Steam + [7/7] + portal Last Pulsed on 205.209.104.22
================================================================================
'@

Set-Content -LiteralPath (Join-Path $OutputDir 'BLUE_RDP_PASTE.txt') -Value $paste -Encoding UTF8

Write-Host ''
Write-Host "Package ready: $OutputDir" -ForegroundColor Green
Write-Host 'RDP to lifepunchnet, copy files to C:\S&BOX DXRP Server\, run BLUE_RDP_PASTE.txt' -ForegroundColor Cyan
