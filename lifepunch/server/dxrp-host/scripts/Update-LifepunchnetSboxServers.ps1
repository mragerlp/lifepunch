<#
.SYNOPSIS
  lifepunchnet on-box: update s&box dedicated server (26.06.10+) and restart DXRP hosts.

.DESCRIPTION
  Run ELEVATED on lifepunchnet after Steam/engine updates (e.g. 26.06.10).

  1. steamcmd app_update 1892930 validate (dedicated server binaries)
  2. Sync sbox-server.* into install root (if separate from steamcmd tree)
  3. git pull + Deploy-DxrpHostLaunchers.ps1
  4. Restart Development (default); Official with -IncludeOfficial

  Law: Development first on engine bumps — Official only when -IncludeOfficial is set.

.PARAMETER SteamCmdExe
  Path to steamcmd.exe on lifepunchnet.

.PARAMETER IncludeOfficial
  Also restart Server 1 (70p / port 27015). Requires explicit intent — production.

.PARAMETER SkipSteamUpdate
  Only redeploy launchers + restart (dxrp-server.cs will pull/build DXRP).

.PARAMETER NoRestart
  Update binaries only; do not start servers.

.EXAMPLE
  cd C:\lifepunch\lifepunch-rdp-server\lifepunch\server\dxrp-host\scripts
  powershell -ExecutionPolicy Bypass -File .\Update-LifepunchnetSboxServers.ps1

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\Update-LifepunchnetSboxServers.ps1 -IncludeOfficial
#>
[CmdletBinding()]
param(
    [string] $SteamCmdExe = '',
    [string] $OfficialRoot = 'C:\S&BOX DXRP Server',
    [string] $DevelopmentRoot = '',
    [string] $GitRoot = 'C:\lifepunch\lifepunch-rdp-server',
    [switch] $IncludeOfficial,
    [switch] $SkipSteamUpdate,
    [switch] $NoRestart
)

$ErrorActionPreference = 'Stop'

if (-not $DevelopmentRoot) {
    $DevelopmentRoot = $OfficialRoot
}

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
          ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if (-not $isAdmin) { throw 'Run elevated on lifepunchnet (Administrator).' }

function Write-Step($m) { Write-Host "==> $m" -ForegroundColor Cyan }

function Find-SteamCmd {
    param([string] $Hint)
    $candidates = @()
    if ($Hint) { $candidates += $Hint }
    $candidates += @(
        'C:\steamcmd\steamcmd.exe',
        'C:\SteamCMD\steamcmd.exe',
        'C:\Program Files\SteamCMD\steamcmd.exe',
        'D:\steamcmd\steamcmd.exe'
    )
    foreach ($p in $candidates) {
        if ($p -and (Test-Path -LiteralPath $p)) { return (Resolve-Path -LiteralPath $p).Path }
    }
    return $null
}

function Find-DedicatedServerRoot([string] $SteamCmdPath) {
    $steamRoot = Split-Path -Parent $SteamCmdPath
    $names = @(
        'sbox dedicated server',
        'Dedicated Server',
        's&box dedicated server'
    )
    foreach ($n in $names) {
        $p = Join-Path $steamRoot "steamapps\common\$n"
        if (Test-Path -LiteralPath $p) { return (Resolve-Path -LiteralPath $p).Path }
    }
    return $null
}

function Sync-SboxServerBinaries {
    param(
        [string] $SourceRoot,
        [string] $DestRoot,
        [string] $Label
    )
    if (-not (Test-Path -LiteralPath $DestRoot)) {
        Write-Host "  Skip $Label — missing $DestRoot" -ForegroundColor Yellow
        return
    }
    $same = $false
    try {
        $same = ([string](Resolve-Path -LiteralPath $SourceRoot)).Equals(
            [string](Resolve-Path -LiteralPath $DestRoot), [StringComparison]::OrdinalIgnoreCase)
    }
    catch { }
    if ($same) {
        Write-Host "  $Label uses dedicated server root directly — no copy" -ForegroundColor DarkGray
        return
    }

    $patterns = @('sbox-server.exe', 'sbox-server.dll', 'sbox-server.runtimeconfig.json', 'sbox-server.deps.json')
    foreach ($pat in $patterns) {
        Get-ChildItem -LiteralPath $SourceRoot -Filter $pat -File -ErrorAction SilentlyContinue | ForEach-Object {
            Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $DestRoot $_.Name) -Force
            Write-Host "  $Label <- $($_.Name)" -ForegroundColor DarkGray
        }
    }
}

function Register-SteamCmdClientDlls {
    param(
        [string] $SteamCmdPath,
        [string[]] $InstallRoots
    )
    $fix = Join-Path $PSScriptRoot 'Fix-LifepunchnetSteamClient.ps1'
    if (-not (Test-Path -LiteralPath $fix)) { throw "Missing $fix" }
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $fix `
        -SteamCmdExe $SteamCmdPath -InstallRoots $InstallRoots -SkipSteamCmdUpdate
}

function Start-DxrpHost {
    param(
        [string] $InstallRoot,
        [string] $RestartScript,
        [string] $Label
    )
    if (-not (Test-Path -LiteralPath $RestartScript)) {
        throw "Missing $RestartScript"
    }
    Write-Host "Starting $Label in new window ($InstallRoot)..." -ForegroundColor Green
    Start-Process -FilePath 'powershell.exe' -ArgumentList @(
        '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $RestartScript,
        '-InstallRoot', $InstallRoot
    ) -WorkingDirectory $InstallRoot
}

Write-Host ''
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host '  LIFEPUNCH — lifepunchnet s&box + DXRP server update' -ForegroundColor Cyan
Write-Host '  Target engine: 26.06.10+ (post Steam update)' -ForegroundColor Cyan
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host ''

if (-not $SkipSteamUpdate) {
    $steamCmd = Find-SteamCmd -Hint $SteamCmdExe
    if (-not $steamCmd) {
        throw @'
steamcmd.exe not found. Install SteamCMD on lifepunchnet, then re-run.
  https://developer.valvesoftware.com/wiki/SteamCMD
  steamcmd +login anonymous +app_update 1892930 validate +quit
'@
    }

    Write-Step "SteamCMD update (app 1892930 validate)"
    $steamDir = Split-Path -Parent $steamCmd
    Push-Location $steamDir
    try {
        & $steamCmd +login anonymous +app_update 1892930 validate +quit
        if ($LASTEXITCODE -gt 1) { throw "steamcmd exited $LASTEXITCODE" }
    }
    finally { Pop-Location }

    Write-Step 'Wire Steam client DLLs + copy redist into install roots'
    $installRoots = @($OfficialRoot)
    if ($DevelopmentRoot -ne $OfficialRoot) {
        $installRoots += $DevelopmentRoot
    }
    Register-SteamCmdClientDlls -SteamCmdPath $steamCmd -InstallRoots $installRoots

    $dedicatedRoot = Find-DedicatedServerRoot -SteamCmdPath $steamCmd
    if (-not $dedicatedRoot) {
        Write-Host 'WARN: dedicated server folder not found under steamcmd — skipping binary sync.' -ForegroundColor Yellow
        Write-Host '      If installs use per-root copies, verify sbox-server.dll manually.' -ForegroundColor Yellow
    }
    else {
        Write-Step "Sync binaries from $dedicatedRoot"
        Sync-SboxServerBinaries -SourceRoot $dedicatedRoot -DestRoot $OfficialRoot -Label 'Official'
        Sync-SboxServerBinaries -SourceRoot $dedicatedRoot -DestRoot $DevelopmentRoot -Label 'Development'
    }
}
else {
    Write-Host 'SkipSteamUpdate — launcher deploy + restart only.' -ForegroundColor Yellow
}

if (Test-Path -LiteralPath (Join-Path $GitRoot '.git')) {
    Write-Step 'git pull (lifepunch-rdp-server)'
    Push-Location $GitRoot
    git fetch 2>&1 | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
    git pull --rebase 2>&1 | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
    Pop-Location
}

$deploy = Join-Path $PSScriptRoot 'Deploy-DxrpHostLaunchers.ps1'
if (Test-Path -LiteralPath $deploy) {
    Write-Step 'Deploy DXRP host launchers'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $deploy `
        -OfficialRoot $OfficialRoot -DevelopmentRoot $DevelopmentRoot
}

if ($NoRestart) {
    Write-Host ''
    Write-Host 'NoRestart — binaries/launchers updated; servers not started.' -ForegroundColor Green
    exit 0
}

Write-Step 'Stop + restart Development (Server 2)'
$devRestart = Join-Path $DevelopmentRoot 'restart_development.ps1'
if (-not (Test-Path -LiteralPath $devRestart)) {
    $devRestart = Join-Path (Join-Path $PSScriptRoot '..\development') 'restart_development.ps1'
    Copy-Item -LiteralPath $devRestart -Destination (Join-Path $DevelopmentRoot 'restart_development.ps1') -Force -ErrorAction SilentlyContinue
}
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $devRestart -InstallRoot $DevelopmentRoot -NoStart
Start-DxrpHost -InstallRoot $DevelopmentRoot -RestartScript (Join-Path $DevelopmentRoot 'restart_development.ps1') -Label 'Development'

if ($IncludeOfficial) {
    Write-Step 'Stop + restart Official (Server 1 / 70p)'
    $offRestart = Join-Path $OfficialRoot 'restart_official.ps1'
    if (-not (Test-Path -LiteralPath $offRestart)) {
        $offRestart = Join-Path (Join-Path $PSScriptRoot '..\official') 'restart_official.ps1'
        Copy-Item -LiteralPath $offRestart -Destination (Join-Path $OfficialRoot 'restart_official.ps1') -Force -ErrorAction SilentlyContinue
    }
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $offRestart -InstallRoot $OfficialRoot -NoStart
    Start-DxrpHost -InstallRoot $OfficialRoot -RestartScript (Join-Path $OfficialRoot 'restart_official.ps1') -Label 'Official'
}
else {
    Write-Host ''
    Write-Host 'Official NOT restarted (default). After Dev smoke OK, re-run with -IncludeOfficial.' -ForegroundColor Yellow
}

Write-Host ''
Write-Host 'Done. Verify DXRP portal Last Pulsed + Version shows 26.06.10+.' -ForegroundColor Green
Write-Host 'Development console: wait for dxrp-server.cs [7/7] before player smoke.' -ForegroundColor DarkGray
Write-Host ''
