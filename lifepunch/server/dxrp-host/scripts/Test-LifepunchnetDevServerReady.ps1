<#
.SYNOPSIS
  Gate 0 preflight — session user, Steam HKCU, DLLs on disk (lifepunchnet).

.DESCRIPTION
  Run as the SAME user who will start server2_start.bat.
  Exit 0 = safe to start (or Steam wiring looks correct).
  Exit 1 = fix before start — usually fix_dev_server_now.bat.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\Test-LifepunchnetDevServerReady.ps1
#>
[CmdletBinding()]
param(
    [string] $InstallRoot = 'C:\S&BOX DXRP Server'
)

$ErrorActionPreference = 'Continue'
$fail = 0

function Report([string] $Label, [bool] $Pass, [string] $Detail) {
    $color = if ($Pass) { 'Green' } else { 'Red' }
    $mark = if ($Pass) { 'PASS' } else { 'FAIL' }
    Write-Host "[$mark] $Label" -ForegroundColor $color
    if ($Detail) { Write-Host "       $Detail" -ForegroundColor DarkGray }
    if (-not $Pass) { $script:fail++ }
}

Write-Host ''
Write-Host '=== LIFEPUNCH Gate 0 preflight (Dev server) ===' -ForegroundColor Cyan
Write-Host "Current user: $env:USERDOMAIN\$env:USERNAME" -ForegroundColor White
Write-Host ''

# Active RDP / console sessions
$sessions = @()
try {
    $raw = query user 2>$null
    foreach ($line in $raw | Select-Object -Skip 1) {
        $line = ($line -replace '\s{2,}', '|').Trim('|')
        $p = $line -split '\|'
        if ($p.Count -ge 1 -and $p[0] -notmatch 'USERNAME') {
            $sessions += "$($p[0].Trim()) ($($p[3].Trim()))"
        }
    }
}
catch { }

if ($sessions.Count -gt 0) {
    Report 'Interactive sessions' $true ($sessions -join '; ')
    $active = $sessions | Where-Object { $_ -match 'Active' }
    if ($active) {
        $match = $active | Where-Object { $_ -match [regex]::Escape($env:USERNAME) }
        Report 'Current user has Active session' ($null -ne $match) "Start server as $env:USERNAME only"
    }
}
else {
    Report 'Interactive sessions' $false 'query user returned nothing'
}

# Install root
Report 'Install root exists' (Test-Path -LiteralPath $InstallRoot) $InstallRoot
Report 'dxrp-server.cs present' (Test-Path -LiteralPath (Join-Path $InstallRoot 'dxrp-server.cs')) ''

$devEnv = Join-Path $InstallRoot 'secure\development.local.env'
Report 'development.local.env' (Test-Path -LiteralPath $devEnv) $devEnv

# Steam HKCU (this user)
$regPath = 'HKCU:\SOFTWARE\Valve\Steam\ActiveProcess'
$dll64Reg = $null
if (Test-Path -LiteralPath $regPath) {
    $dll64Reg = (Get-ItemProperty -Path $regPath -Name 'SteamClientDll64' -ErrorAction SilentlyContinue).SteamClientDll64
}
Report 'Steam HKCU SteamClientDll64' ($dll64Reg -and (Test-Path -LiteralPath $dll64Reg)) $(if ($dll64Reg) { $dll64Reg } else { 'missing — run fix_dev_server_now.bat' })

# DLLs next to server binary
foreach ($dll in @('steamclient64.dll', 'tier0_s64.dll', 'vstdlib_s64.dll')) {
    $p = Join-Path $InstallRoot $dll
    Report "Install root $dll" (Test-Path -LiteralPath $p) $p
}

Write-Host ''
if ($fail -eq 0) {
    Write-Host 'Gate 0 preflight: OK — start server2_start.bat AS THIS USER.' -ForegroundColor Green
    exit 0
}

Write-Host "Gate 0 preflight: $fail issue(s) — run fix_dev_server_now.bat as $env:USERNAME, then re-test." -ForegroundColor Red
exit 1
