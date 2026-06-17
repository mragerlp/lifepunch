<#
.SYNOPSIS
  lifepunchnet — one-shot Dev server recovery (Steam + launchers + ULX patch + restart).

.DESCRIPTION
  Run as your NORMAL RDP user (jared). DO NOT "Run as administrator".
  Fixes the #1 failure mode: auto_update wrote Steam HKCU for Administrator, not you.

.EXAMPLE
  cd C:\lifepunch\lifepunch-rdp-server\lifepunch\server\dxrp-host\scripts
  powershell -ExecutionPolicy Bypass -File .\Fix-LifepunchnetDevServerNow.ps1
#>
[CmdletBinding()]
param(
    [string] $InstallRoot = 'C:\S&BOX DXRP Server',
    [string] $GitRoot = 'C:\lifepunch\lifepunch-rdp-server'
)

$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
          ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if ($isAdmin) {
    Write-Host 'Running elevated — Steam HKCU will apply to Administrator.' -ForegroundColor Yellow
    Write-Host 'Start server2_start.bat in THIS SAME session (also Administrator).' -ForegroundColor Yellow
}

function Write-Step($m) { Write-Host "==> $m" -ForegroundColor Cyan }

Write-Host ''
Write-Host '============================================================' -ForegroundColor Green
Write-Host '  LIFEPUNCH — FIX DEV SERVER NOW' -ForegroundColor Green
Write-Host "  User: $env:USERNAME  (must match server2_start.bat)" -ForegroundColor Green
Write-Host '============================================================' -ForegroundColor Green
Write-Host ''

if (-not (Test-Path -LiteralPath $InstallRoot)) {
    throw "Missing install root: $InstallRoot"
}

if (Test-Path -LiteralPath (Join-Path $GitRoot '.git')) {
    Write-Step 'git pull (lifepunch-rdp-server)'
    Push-Location $GitRoot
    git fetch 2>&1 | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
    git pull --rebase 2>&1 | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
    Pop-Location
}

$deploy = Join-Path $Here 'Deploy-DxrpHostLaunchers.ps1'
if (Test-Path -LiteralPath $deploy) {
    Write-Step 'Deploy launchers + fix scripts to install root'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $deploy -OfficialRoot $InstallRoot -DevelopmentRoot $InstallRoot
}

$steamFix = Join-Path $Here 'Fix-LifepunchnetSteamClient.ps1'
if (-not (Test-Path -LiteralPath $steamFix)) {
    $steamFix = Join-Path $InstallRoot 'Fix-LifepunchnetSteamClient.ps1'
}
if (-not (Test-Path -LiteralPath $steamFix)) {
    throw "Missing Fix-LifepunchnetSteamClient.ps1 — git pull failed or wrong clone path."
}

Write-Step 'Wire Steam DLLs + HKCU registry (THIS user)'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $steamFix -InstallRoots @($InstallRoot)

$patch = Join-Path $Here 'Patch-LifepunchnetUlxCompile.ps1'
if (Test-Path -LiteralPath $patch) {
    $dxrpGame = Join-Path $InstallRoot 'dxrp\game\Code\Addons\lifepunch'
    if (Test-Path -LiteralPath $dxrpGame) {
        Write-Step 'Patch ULX shared UI files on disk (until portal r8 pins)'
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $patch -DxrpRoot $InstallRoot -RepoRoot $GitRoot
    }
    else {
        Write-Host 'Skip ULX patch — dxrp not cloned yet (first start will create it).' -ForegroundColor Yellow
    }
}

Write-Step 'Stop stale server processes'
Get-Process -Name 'sbox-server', 'dotnet' -ErrorAction SilentlyContinue |
    Where-Object { $_.Path -and $_.Path.StartsWith($InstallRoot, [StringComparison]::OrdinalIgnoreCase) } |
    Stop-Process -Force -ErrorAction SilentlyContinue

$restart = Join-Path $InstallRoot 'restart_development.ps1'
if (-not (Test-Path -LiteralPath $restart)) {
    $restart = Join-Path (Join-Path $Here '..\development') 'restart_development.ps1'
}
if (Test-Path -LiteralPath $restart) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $restart -InstallRoot $InstallRoot -NoStart
}

$startBat = Join-Path $InstallRoot 'server2_start.bat'
if (-not (Test-Path -LiteralPath $startBat)) {
    throw "Missing $startBat"
}

Write-Step 'Start Development (server2_start.bat) in new window'
Start-Process -FilePath 'cmd.exe' -ArgumentList @('/c', 'server2_start.bat') -WorkingDirectory $InstallRoot

Write-Host ''
Write-Host 'DONE. In the new console window, wait for:' -ForegroundColor Green
Write-Host '  - Connected to Steam (not "not connected to Steam")' -ForegroundColor White
Write-Host '  - dxrp-server [7/7] and DEVELOPMENT SERVER pulsing in portal' -ForegroundColor White
Write-Host ''
Write-Host 'If Steam still fails: install Steam desktop client on lifepunchnet, rerun this script.' -ForegroundColor Yellow
Write-Host ''
