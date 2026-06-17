<#
.SYNOPSIS
  lifepunchnet — start Development server (dxrp-server.cs + dev token). One script, visible errors.

.DESCRIPTION
  1. Verify dxrp-server.cs + DXRP_TOKEN_DEVELOPMENT
  2. Wire Steam (HKCU for THIS user — required after 26.06.10+)
  3. Stop stale sbox-server/dotnet under install root only
  4. dotnet run dxrp-server.cs --token <dev token>

  Run as your normal RDP user (same user who will own the server process). NOT elevated.

.EXAMPLE
  cd C:\S&BOX DXRP Server
  powershell -ExecutionPolicy Bypass -File Run-DevServer.ps1
#>
[CmdletBinding()]
param(
    [string] $InstallRoot = 'C:\S&BOX DXRP Server',
    [switch] $SkipSteamFix,
    [switch] $NoStart
)

$ErrorActionPreference = 'Stop'

function Write-LogLine([string] $Message) {
    $line = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Message"
    Write-Host $line
    if ($script:LogPath) {
        Add-Content -LiteralPath $script:LogPath -Value $line -Encoding UTF8
    }
}

function Import-LocalEnvFile([string] $Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return }
    Get-Content -LiteralPath $Path | ForEach-Object {
        $line = $_.Trim()
        if (-not $line -or $line.StartsWith('#')) { return }
        $eq = $line.IndexOf('=')
        if ($eq -lt 1) { return }
        $name = $line.Substring(0, $eq).Trim()
        $value = $line.Substring($eq + 1).Trim().Trim('"')
        Set-Item -Path "Env:$name" -Value $value
    }
}

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
          ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if ($isAdmin) {
    Write-Host 'WARN: Running elevated — Steam HKCU applies to Administrator.' -ForegroundColor Yellow
    Write-Host '      Start this script as your normal RDP user when possible.' -ForegroundColor Yellow
}

Write-Host ''
Write-Host '========== LIFEPUNCH DEV SERVER (dxrp-server.cs) ==========' -ForegroundColor Green
Write-Host "User:   $env:USERDOMAIN\$env:USERNAME"
Write-Host "Root:   $InstallRoot"
Write-Host '=========================================================' -ForegroundColor Green
Write-Host ''

if (-not (Test-Path -LiteralPath $InstallRoot)) {
    throw "Missing install root: $InstallRoot"
}

$logDir = Join-Path $InstallRoot 'logs'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$script:LogPath = Join-Path $logDir 'dev-server-last.log'
Set-Content -LiteralPath $script:LogPath -Value "=== LIFEPUNCH dev server log $(Get-Date -Format o) ===" -Encoding UTF8

Push-Location $InstallRoot
try {
    if (-not (Test-Path -LiteralPath 'dxrp-server.cs')) {
        throw 'dxrp-server.cs missing in install root — Dxura host files must live here.'
    }

    Import-LocalEnvFile (Join-Path $InstallRoot 'secure\development.local.env')
    if (-not $env:DXRP_TOKEN_DEVELOPMENT) {
        throw 'DXRP_TOKEN_DEVELOPMENT not set — create secure\development.local.env (portal Development server token).'
    }

    $tokenPreview = if ($env:DXRP_TOKEN_DEVELOPMENT.Length -gt 8) {
        $env:DXRP_TOKEN_DEVELOPMENT.Substring(0, 4) + '...' + $env:DXRP_TOKEN_DEVELOPMENT.Substring($env:DXRP_TOKEN_DEVELOPMENT.Length - 4)
    } else { '(short)' }
    Write-Host "Dev token: $tokenPreview" -ForegroundColor DarkGray

    if (-not $SkipSteamFix) {
        $fixCandidates = @(
            (Join-Path $InstallRoot 'Fix-LifepunchnetSteamClient.ps1'),
            'C:\lifepunch\lifepunch-rdp-server\lifepunch\server\dxrp-host\scripts\Fix-LifepunchnetSteamClient.ps1'
        )
        $fix = $fixCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
        if (-not $fix) {
            throw 'Fix-LifepunchnetSteamClient.ps1 not found — git pull lifepunch-rdp-server and Deploy-DxrpHostLaunchers.ps1'
        }
        $steamCmd = Join-Path $InstallRoot 'steamcmd.exe'
        if (-not (Test-Path -LiteralPath $steamCmd)) { $steamCmd = '' }
        Write-Host '==> Steam fix (HKCU + DLLs for this user)...' -ForegroundColor Cyan
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $fix `
            -SteamCmdExe $steamCmd -InstallRoots @($InstallRoot) -SkipSteamCmdUpdate
    }

    $example = 'dxrp-server-config.json.example'
    $config = 'dxrp-server-config.json'
    if (-not (Test-Path -LiteralPath $config) -and (Test-Path -LiteralPath $example)) {
        Copy-Item -LiteralPath $example -Destination $config
    }

    Write-Host '==> Stop stale processes under install root...' -ForegroundColor Cyan
    Get-Process -Name 'sbox-server', 'dotnet' -ErrorAction SilentlyContinue |
        Where-Object { $_.Path -and $_.Path.StartsWith($InstallRoot, [StringComparison]::OrdinalIgnoreCase) } |
        Stop-Process -Force -ErrorAction SilentlyContinue

    if ($NoStart) {
        Write-Host 'NoStart — preflight OK.' -ForegroundColor Green
        return
    }

    Write-LogLine '==> dotnet run dxrp-server.cs --token <DEVELOPMENT> ...'
    Write-LogLine '    Log file: logs\dev-server-last.log'
    Write-LogLine '    Wait for: Connected to Steam + [7/7]'
    Write-Host ''
    & dotnet run dxrp-server.cs --token $env:DXRP_TOKEN_DEVELOPMENT 2>&1 | ForEach-Object {
        $t = $_.ToString()
        Write-Host $t
        if ($script:LogPath) { Add-Content -LiteralPath $script:LogPath -Value $t -Encoding UTF8 }
    }
    if ($LASTEXITCODE -ne 0) {
        throw "dxrp-server.cs exited with code $LASTEXITCODE"
    }
}
catch {
    Write-LogLine "FATAL: $($_.Exception.Message)"
    throw
}
finally {
    Pop-Location
}
