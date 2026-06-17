<#
.SYNOPSIS
  lifepunchnet Gate 0 — Steam fix + start Dev server. One script, clear pass/fail.

.EXAMPLE
  cd C:\lifepunch\lifepunch-rdp-server\lifepunch\server\dxrp-host\scripts
  powershell -ExecutionPolicy Bypass -File .\Run-LifepunchnetGate0.ps1
#>
[CmdletBinding()]
param(
    [string] $InstallRoot = 'C:\S&BOX DXRP Server',
    [string] $GitRoot = 'C:\lifepunch\lifepunch-rdp-server'
)

$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot

function Write-Step($m) { Write-Host "==> $m" -ForegroundColor Cyan }

Write-Host ''
Write-Host '========== LIFEPUNCH GATE 0 (Steam + Dev start) ==========' -ForegroundColor Green
Write-Host "User: $env:USERDOMAIN\$env:USERNAME" -ForegroundColor White
Write-Host "Install: $InstallRoot" -ForegroundColor White
Write-Host '=========================================================' -ForegroundColor Green
Write-Host ''

if (-not (Test-Path -LiteralPath $InstallRoot)) {
    Write-Host 'GATE0_FAIL missing_install_root' -ForegroundColor Red
    exit 1
}

if (Test-Path -LiteralPath (Join-Path $GitRoot '.git')) {
    Write-Step 'git pull'
    Push-Location $GitRoot
    $dirty = git status --porcelain 2>$null
    if ($dirty) {
        Write-Host '  Stashing local changes before pull...' -ForegroundColor Yellow
        git stash push -m "gate0-auto-$(Get-Date -Format 'yyyyMMdd-HHmmss')" 2>&1 | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }
    }
    git pull --rebase 2>&1 | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }
    Pop-Location
}

$steamCmdHint = Join-Path $InstallRoot 'steamcmd.exe'
if (-not (Test-Path -LiteralPath $steamCmdHint)) { $steamCmdHint = '' }

$steamFix = Join-Path $Here 'Fix-LifepunchnetSteamClient.ps1'
if (-not (Test-Path -LiteralPath $steamFix)) {
    Write-Host 'GATE0_FAIL missing_Fix-LifepunchnetSteamClient.ps1 — git pull lifepunch-rdp-server' -ForegroundColor Red
    exit 1
}

Write-Step 'Steam DLLs + HKCU (this user)'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $steamFix -SteamCmdExe $steamCmdHint -InstallRoots @($InstallRoot)
if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
    Write-Host "GATE0_FAIL steam_fix exit=$LASTEXITCODE" -ForegroundColor Red
    exit 1
}

$preflight = Join-Path $Here 'Test-LifepunchnetDevServerReady.ps1'
if (Test-Path -LiteralPath $preflight) {
    Write-Step 'Preflight'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $preflight -InstallRoot $InstallRoot
    if ($LASTEXITCODE -ne 0) {
        Write-Host 'GATE0_FAIL preflight — see FAIL lines above' -ForegroundColor Red
        exit 1
    }
}

Write-Step 'Stop stale processes'
Get-Process -Name 'sbox-server', 'dotnet' -ErrorAction SilentlyContinue |
    Where-Object { $_.Path -and $_.Path.StartsWith($InstallRoot, [StringComparison]::OrdinalIgnoreCase) } |
    Stop-Process -Force -ErrorAction SilentlyContinue

$startBat = Join-Path $InstallRoot 'server2_start.bat'
if (-not (Test-Path -LiteralPath $startBat)) {
    $deploy = Join-Path $Here 'Deploy-DxrpHostLaunchers.ps1'
    if (Test-Path -LiteralPath $deploy) {
        Write-Step 'Deploy launchers (first-time)'
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $deploy -OfficialRoot $InstallRoot
    }
}
if (-not (Test-Path -LiteralPath $startBat)) {
    Write-Host 'GATE0_FAIL missing_server2_start.bat' -ForegroundColor Red
    exit 1
}

Write-Step 'Start server2_start.bat (new window)'
Start-Process -FilePath 'cmd.exe' -ArgumentList @('/k', 'server2_start.bat') -WorkingDirectory $InstallRoot

Write-Host ''
Write-Host 'GATE0_STARTED — watch the NEW console window:' -ForegroundColor Green
Write-Host '  1) Connected to Steam (NOT "not connected to Steam")' -ForegroundColor White
Write-Host '  2) dxrp-server reaches [7/7]' -ForegroundColor White
Write-Host '  3) Portal DEVELOPMENT SERVER Last Pulsed updates' -ForegroundColor White
Write-Host ''
Write-Host 'Do NOT debug ULX or publish addons until all three pass.' -ForegroundColor Yellow
Write-Host 'GATE0_SCRIPT_OK' -ForegroundColor Green
exit 0
