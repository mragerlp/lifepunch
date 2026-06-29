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

.PARAMETER UseStagingBranch
  Legacy switch: staging for both roots when syncing from SteamCMD. Prefer -OfficialUseStaging.

.PARAMETER OfficialStaging
  Deprecated alias; staging is already the default for Official (staging gamemode on portal).

.PARAMETER OfficialRelease
  Use SteamCMD release (no beta) for Official. Default is staging — matches Dev + portal staging gamemode.

.PARAMETER UpdateOfficialBinaries
  Run SteamCMD and copy sbox-server.* into OfficialRoot. auto_update_all / auto_update_official pass this.

.PARAMETER UpdateDevelopmentBinaries
  Copy SteamCMD dedicated server into DevelopmentRoot. Default off — Dev uses Steam Betas -> staging.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\Update-LifepunchnetSboxServers.ps1 -UpdateOfficialBinaries -IncludeOfficial
#>
[CmdletBinding()]
param(
    [string] $SteamCmdExe = '',
    [string] $OfficialRoot = 'C:\SBOX-DXRP-Server',
    [string] $DevelopmentRoot = 'C:\Program Files (x86)\Steam\steamapps\common\sbox',
    [string] $GitRoot = 'C:\lifepunch\lifepunch-rdp-server',
    [switch] $IncludeOfficial,
    [switch] $UseStagingBranch,
    [switch] $OfficialStaging,
    [switch] $OfficialRelease,
    [switch] $UpdateOfficialBinaries,
    [switch] $UpdateDevelopmentBinaries,
    [switch] $OfficialOnly,
    [switch] $SkipSteamUpdate,
    [switch] $NoRestart
)

function Invoke-SteamCmdAppUpdate {
    param(
        [string] $SteamCmdPath,
        [bool] $Staging,
        [string] $ForceInstallDir = ''
    )
    $label = if ($Staging) { 'staging beta' } else { 'release' }
    $dirNote = if ($ForceInstallDir) { " -> $ForceInstallDir" } else { '' }
    Write-Step "SteamCMD app_update 1892930 ($label$dirNote)"
    $steamDir = Split-Path -Parent $SteamCmdPath
    Push-Location $steamDir
    try {
        $steamArgs = @()
        if ($ForceInstallDir) { $steamArgs += '+force_install_dir', $ForceInstallDir }
        $steamArgs += '+login', 'anonymous', '+app_update', '1892930'
        if ($Staging) { $steamArgs += '-beta', 'staging' }
        $steamArgs += 'validate', '+quit'
        & $SteamCmdPath @steamArgs
        if ($LASTEXITCODE -gt 1) { throw "steamcmd exited $LASTEXITCODE" }
    }
    finally { Pop-Location }
}

$ErrorActionPreference = 'Stop'

if ($UseStagingBranch) {
    if (-not $UpdateDevelopmentBinaries) { $UpdateDevelopmentBinaries = $true }
}

if ($IncludeOfficial -and -not $UpdateOfficialBinaries) {
    $UpdateOfficialBinaries = $true
}

if ($UseStagingBranch -and ($IncludeOfficial -or $UpdateOfficialBinaries) -and -not $UpdateDevelopmentBinaries) {
    $UpdateDevelopmentBinaries = $true
}

$officialUseStaging = -not $OfficialRelease.IsPresent

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
          ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if (-not $isAdmin) { throw 'Run elevated on lifepunchnet (Administrator).' }

function Write-Step($m) { Write-Host "==> $m" -ForegroundColor Cyan }

function Find-SteamCmd {
    param(
        [string] $Hint,
        [string[]] $InstallRoots = @()
    )
    $candidates = @()
    if ($Hint) { $candidates += $Hint }
    foreach ($root in $InstallRoots) {
        if (-not $root) { continue }
        $candidates += Join-Path $root 'steamcmd.exe'
        $candidates += Join-Path $root 'steamcmd\steamcmd.exe'
    }
    $candidates += @(
        'C:\S&BOX DXRP Server\steamcmd.exe',
        'C:\S&BOX DXRP Server\steamcmd\steamcmd.exe',
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

    $patterns = @(
        '.version',
        'sbox-server.exe',
        'sbox-server.dll',
        'sbox-server.runtimeconfig.json',
        'sbox-server.deps.json'
    )
    foreach ($pat in $patterns) {
        Get-ChildItem -LiteralPath $SourceRoot -Filter $pat -File -ErrorAction SilentlyContinue | ForEach-Object {
            Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $DestRoot $_.Name) -Force
            Write-Host "  $Label <- $($_.Name)" -ForegroundColor DarkGray
        }
    }
}

function Get-InteractiveUsername {
    try {
        $sessions = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop
        if ($sessions.UserName) {
            return ($sessions.UserName -split '\\')[-1]
        }
    }
    catch { }
    return $env:USERNAME
}

function Invoke-SteamFixAsInteractiveUser {
    param(
        [string] $SteamCmdPath,
        [string[]] $InstallRoots
    )
    $fix = Join-Path $PSScriptRoot 'Fix-LifepunchnetSteamClient.ps1'
    if (-not (Test-Path -LiteralPath $fix)) { throw "Missing $fix" }

    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
              ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

    if (-not $isAdmin) {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $fix `
            -SteamCmdExe $SteamCmdPath -InstallRoots $InstallRoots -SkipSteamCmdUpdate
        return
    }

    # Elevated auto_update: HKCU is Administrator's — wrong user. Run fix as logged-on RDP user.
    $runUser = Get-InteractiveUsername
    $taskName = "LifepunchSteamFix_$([guid]::NewGuid().ToString('N').Substring(0, 8))"
    $wrapper = Join-Path $env:TEMP "lifepunch-steamfix-$taskName.ps1"
    $rootsLiteral = ($InstallRoots | ForEach-Object { "'$($_ -replace "'", "''")'" }) -join ','
    @"
& '$($fix -replace "'", "''")' -SteamCmdExe '$($SteamCmdPath -replace "'", "''")' -InstallRoots @($rootsLiteral) -SkipSteamCmdUpdate
"@ | Set-Content -LiteralPath $wrapper -Encoding UTF8
    $tr = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$wrapper`""
    Write-Host "  Steam HKCU fix as interactive user: $runUser (not Administrator)" -ForegroundColor Yellow
    schtasks /Create /TN $taskName /TR $tr /SC ONCE /ST 00:00 /RU $runUser /IT /F | Out-Null
    schtasks /Run /TN $taskName | Out-Null
    Start-Sleep -Seconds 8
    schtasks /Delete /TN $taskName /F 2>$null | Out-Null
    Remove-Item -LiteralPath $wrapper -Force -ErrorAction SilentlyContinue
}

function Start-DxrpHost {
    param(
        [string] $InstallRoot,
        [string] $RestartScript,
        [string] $Label
    )

    $startBat = if ($Label -eq 'Official') { 'server1_start.bat' } else { 'server2_start.bat' }
    $startPath = Join-Path $InstallRoot $startBat
    if (-not (Test-Path -LiteralPath $startPath)) {
        throw ('Missing ' + $startPath)
    }

    $windowTitle = if ($Label -eq 'Official') { 'LIFEPUNCH Official 70p' } else { 'LIFEPUNCH Development' }
    Write-Host ('Starting ' + $Label + ' in visible CMD: ' + $startBat) -ForegroundColor Green
    Start-Process -FilePath 'cmd.exe' -ArgumentList @('/c', 'start', $windowTitle, 'cmd', '/k', $startBat) -WorkingDirectory $InstallRoot
}

Write-Host ''
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host '  LIFEPUNCH — lifepunchnet s&box + DXRP server update' -ForegroundColor Cyan
$officialEngineLabel = if ($officialUseStaging) { 'staging (SteamCMD -beta staging)' } else { 'release (SteamCMD validate, no beta)' }
Write-Host "  Official engine: s&box $officialEngineLabel -> C:\SBOX-DXRP-Server" -ForegroundColor Cyan
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host ''

if (-not $SkipSteamUpdate) {
    $installRoots = @($OfficialRoot)
    if ($DevelopmentRoot -ne $OfficialRoot) {
        $installRoots += $DevelopmentRoot
    }

    $steamCmd = Find-SteamCmd -Hint $SteamCmdExe -InstallRoots $installRoots
    if (-not $steamCmd) {
        throw @'
steamcmd.exe not found. Install SteamCMD on lifepunchnet, then re-run.
  https://developer.valvesoftware.com/wiki/SteamCMD
  steamcmd +login anonymous +app_update 1892930 validate +quit
'@
    }

    if ($UpdateOfficialBinaries) {
        Invoke-SteamCmdAppUpdate -SteamCmdPath $steamCmd -Staging:$officialUseStaging -ForceInstallDir $OfficialRoot
        $dedicatedRoot = Find-DedicatedServerRoot -SteamCmdPath $steamCmd
        if (-not $dedicatedRoot) {
            $dedicatedRoot = Join-Path $OfficialRoot 'steamapps\common\sbox dedicated server'
            if (-not (Test-Path -LiteralPath $dedicatedRoot)) { $dedicatedRoot = $null }
        }
        if ($dedicatedRoot) {
            Write-Step "Sync $(if ($officialUseStaging) { 'staging' } else { 'release' }) binaries -> Official ($OfficialRoot)"
            Sync-SboxServerBinaries -SourceRoot $dedicatedRoot -DestRoot $OfficialRoot -Label 'Official'
        }
        else {
            Write-Host 'WARN: dedicated server folder not found — skipping Official binary sync.' -ForegroundColor Yellow
        }
    }
    else {
        Write-Host 'UpdateOfficialBinaries skipped — Official sbox-server.* unchanged (use -UpdateOfficialBinaries or auto_update_all.bat).' -ForegroundColor DarkGray
    }

    if ($UpdateDevelopmentBinaries) {
        $devStaging = if ($UseStagingBranch) { $true } else { $false }
        if (-not $UpdateOfficialBinaries -or ($devStaging -ne $officialUseStaging)) {
            Invoke-SteamCmdAppUpdate -SteamCmdPath $steamCmd -Staging:$devStaging -ForceInstallDir $OfficialRoot
        }
        $devSource = Find-DedicatedServerRoot -SteamCmdPath $steamCmd
        if (-not $devSource) {
            $devSource = Join-Path $OfficialRoot 'steamapps\common\sbox dedicated server'
            if (-not (Test-Path -LiteralPath $devSource)) { $devSource = $null }
        }
        if ($devSource) {
            Write-Step "Sync $(if ($devStaging) { 'staging' } else { 'release' }) binaries -> Development ($DevelopmentRoot)"
            Sync-SboxServerBinaries -SourceRoot $devSource -DestRoot $DevelopmentRoot -Label 'Development'
        }
        else {
            Write-Host 'WARN: dedicated server folder not found — skipping Development binary sync.' -ForegroundColor Yellow
        }
    }
    else {
        Write-Host 'Development binaries: Steam client folder (not overwritten by SteamCMD). Set Steam Betas -> staging on the RDP user.' -ForegroundColor DarkGray
    }

    Write-Step 'Wire Steam client DLLs + copy redist into install roots'
    Invoke-SteamFixAsInteractiveUser -SteamCmdPath $steamCmd -InstallRoots $installRoots
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
if ($OfficialOnly) {
    Write-Host 'OfficialOnly — Development not restarted.' -ForegroundColor DarkGray
}
else {
$devRestart = Join-Path $DevelopmentRoot 'restart_development.ps1'
if (-not (Test-Path -LiteralPath $devRestart)) {
    $devRestart = Join-Path (Join-Path $PSScriptRoot '..\development') 'restart_development.ps1'
    Copy-Item -LiteralPath $devRestart -Destination (Join-Path $DevelopmentRoot 'restart_development.ps1') -Force -ErrorAction SilentlyContinue
}
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $devRestart -InstallRoot $DevelopmentRoot -NoStart
Start-DxrpHost -InstallRoot $DevelopmentRoot -RestartScript (Join-Path $DevelopmentRoot 'restart_development.ps1') -Label 'Development'
}

if ($IncludeOfficial -or $OfficialOnly) {
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
    Write-Host 'Official NOT restarted. Use -IncludeOfficial, -OfficialOnly, or auto_update_all.bat.' -ForegroundColor Yellow
}

Write-Host ''
Write-Host 'Done. Verify DXRP portal Last Pulsed + Version shows 26.06.10+.' -ForegroundColor Green
Write-Host 'Development console: wait for dxrp-server.cs [7/7] before player smoke.' -ForegroundColor DarkGray
Write-Host ''
