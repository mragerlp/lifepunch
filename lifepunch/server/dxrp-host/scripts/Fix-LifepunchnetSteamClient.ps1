<#
.SYNOPSIS
  Wire Steam + copy redist DLLs for s&box dedicated server (26.06.10+).

.DESCRIPTION
  Two fixes:
  1. HKCU registry -> steamclient DLLs (MUST run as the SAME Windows user who starts server2_start.bat)
  2. Copy steamclient64/tier0_s64/vstdlib_s64 next to sbox-server in each install root

  Do NOT elevate to Administrator unless you also start the server as Administrator.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\Fix-LifepunchnetSteamClient.ps1
#>
[CmdletBinding()]
param(
    [string] $SteamCmdExe = '',
    [string[]] $InstallRoots = @(
        'C:\S&BOX DXRP Server'
    ),
    [switch] $SkipSteamCmdUpdate
)

$ErrorActionPreference = 'Stop'

function Find-SteamCmdExe {
    param(
        [string] $Hint,
        [string[]] $SearchRoots = @()
    )
    $exes = @()
    if ($Hint) { $exes += $Hint }
    foreach ($root in $SearchRoots) {
        if (-not $root) { continue }
        $exes += Join-Path $root 'steamcmd.exe'
        $exes += Join-Path $root 'steamcmd\steamcmd.exe'
    }
    $exes += @(
        'C:\S&BOX DXRP Server\steamcmd.exe',
        'C:\S&BOX DXRP Server\steamcmd\steamcmd.exe',
        'C:\steamcmd\steamcmd.exe',
        'C:\SteamCMD\steamcmd.exe',
        'C:\Program Files\SteamCMD\steamcmd.exe',
        'D:\steamcmd\steamcmd.exe'
    )
    foreach ($p in $exes) {
        if ($p -and (Test-Path -LiteralPath $p)) { return (Resolve-Path -LiteralPath $p).Path }
    }
    return $null
}

function Find-SteamClientDll64 {
    param(
        [string] $SteamDir,
        [string[]] $SearchRoots
    )
    $candidates = @()
    if ($SteamDir) {
        $candidates += Join-Path $SteamDir 'steamclient64.dll'
        $candidates += Join-Path $SteamDir 'sdk_win\redistributable_binaries\win64\steamclient64.dll'
    }
    foreach ($root in $SearchRoots) {
        if (-not $root) { continue }
        $candidates += Join-Path $root 'steamclient64.dll'
        $candidates += Join-Path $root 'dxrp\game\steamclient64.dll'
    }
    foreach ($c in $candidates) {
        if ($c -and (Test-Path -LiteralPath $c)) { return (Resolve-Path -LiteralPath $c).Path }
    }
    return $null
}

function Ensure-SteamSdkDlls {
    param([string] $SteamCmdPath)
    $steamDir = Split-Path -Parent $SteamCmdPath
    $sdkRoot = Join-Path $steamDir 'sdk_win'
    $sdkScript = Join-Path $steamDir 'lifepunch_sdk_win.txt'
    $need = @('steamclient64.dll', 'tier0_s64.dll', 'vstdlib_s64.dll')
    $haveAll = $true
    foreach ($dll in $need) {
        if (-not (Test-Path -LiteralPath (Join-Path $steamDir $dll))) { $haveAll = $false; break }
    }
    if ($haveAll) { return $steamDir }

    if (-not $SkipSteamCmdUpdate) {
        Write-Host 'Fetching Steam redist (app 1007)...' -ForegroundColor Yellow
        @(
            '@ShutdownOnFailedCommand 1',
            '@NoPromptForPassword 1',
            '@sSteamCmdForcePlatformType windows',
            'login anonymous',
            "force_install_dir `"$sdkRoot`"",
            'app_update 1007 validate',
            'quit'
        ) | Set-Content -LiteralPath $sdkScript -Encoding ASCII
        Push-Location $steamDir
        try { & $SteamCmdPath +runscript $sdkScript }
        finally { Pop-Location }
    }
    return $steamDir
}

function Get-SteamDllSources {
    param([string] $SteamDir)
    $paths = @(
        $SteamDir,
        (Join-Path $SteamDir 'sdk_win\redistributable_binaries\win64'),
        (Join-Path $SteamDir 'sdk_win')
    )
    $dedicatedNames = @(
        'sbox dedicated server',
        'Dedicated Server'
    )
    foreach ($n in $dedicatedNames) {
        $paths += Join-Path $SteamDir "steamapps\common\$n"
    }
    return $paths | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -Unique
}

function Copy-SteamDllsToRoot {
    param(
        [string[]] $SourceDirs,
        [string] $DestRoot
    )
    if (-not (Test-Path -LiteralPath $DestRoot)) {
        Write-Host "  Skip missing root: $DestRoot" -ForegroundColor Yellow
        return
    }
    $dlls = @('steamclient64.dll', 'steamclient.dll', 'tier0_s64.dll', 'vstdlib_s64.dll', 'steam_api64.dll')
    foreach ($dll in $dlls) {
        $src = $null
        foreach ($dir in $SourceDirs) {
            $candidate = Join-Path $dir $dll
            if (Test-Path -LiteralPath $candidate) { $src = $candidate; break }
        }
        if (-not $src) { continue }
        Copy-Item -LiteralPath $src -Destination (Join-Path $DestRoot $dll) -Force
        Write-Host "  $DestRoot <- $dll" -ForegroundColor DarkGray
    }
}

Write-Host "Running as: $env:USERDOMAIN\$env:USERNAME (HKCU applies to THIS user only)" -ForegroundColor Cyan

$steamCmd = Find-SteamCmdExe -Hint $SteamCmdExe -SearchRoots $InstallRoots
$steamDir = $null
if ($steamCmd) {
    $steamDir = Split-Path -Parent $steamCmd
    Write-Host "steamcmd: $steamCmd" -ForegroundColor DarkGray
}
else {
    Write-Host 'steamcmd.exe not in search paths — will use existing DLLs in install root if present.' -ForegroundColor Yellow
}

if ($steamCmd -and -not $SkipSteamCmdUpdate) {
    Write-Host 'Updating s&box dedicated server (app 1892930)...' -ForegroundColor Yellow
    Push-Location $steamDir
    try {
        & $steamCmd +login anonymous +app_update 1892930 validate +quit
        if ($LASTEXITCODE -gt 1) {
            Write-Host "WARN: steamcmd app_update exited $LASTEXITCODE — continuing with on-disk DLLs." -ForegroundColor Yellow
        }
    }
    finally { Pop-Location }
}

if ($steamCmd) {
    $steamDir = Ensure-SteamSdkDlls -SteamCmdPath $steamCmd
}

$dll64 = Find-SteamClientDll64 -SteamDir $steamDir -SearchRoots $InstallRoots
if (-not $dll64) {
    $steamHint = Join-Path 'C:\S&BOX DXRP Server' 'steamcmd.exe'
    throw "steamclient64.dll not found. lifepunchnet expects steamcmd at: $steamHint Or install Steam desktop client, then re-run."
}

$regPath = 'HKCU:\SOFTWARE\Valve\Steam\ActiveProcess'
New-Item -Path $regPath -Force | Out-Null
Set-ItemProperty -Path $regPath -Name 'SteamClientDll64' -Value $dll64 -Type String
$dll32Dir = if ($steamDir) { $steamDir } else { Split-Path -Parent $dll64 }
$dll32 = Join-Path $dll32Dir 'steamclient.dll'
if (Test-Path -LiteralPath $dll32) {
    Set-ItemProperty -Path $regPath -Name 'SteamClientDll' -Value $dll32 -Type String
}

Write-Host 'Registry wired (HKCU for current user).' -ForegroundColor Green
Write-Host "  SteamClientDll64 = $dll64" -ForegroundColor DarkGray

$sources = Get-SteamDllSources -SteamDir $(if ($steamDir) { $steamDir } else { $InstallRoots[0] })
foreach ($root in $InstallRoots) {
    if ($root -and (Test-Path -LiteralPath $root)) {
        $sources = @($sources) + @($root) | Select-Object -Unique
    }
}
Write-Host 'Copying Steam redist DLLs into server install roots...' -ForegroundColor Cyan
foreach ($root in $InstallRoots) {
    Copy-SteamDllsToRoot -SourceDirs $sources -DestRoot $root
    $dxrpGame = Join-Path $root 'dxrp\game'
    if (Test-Path -LiteralPath $dxrpGame) {
        Copy-SteamDllsToRoot -SourceDirs $sources -DestRoot $dxrpGame
    }
}

Write-Host ''
Write-Host 'Done. Restart server2_start.bat AS THIS SAME USER (not elevated Admin).' -ForegroundColor Green
Write-Host 'If still failing: install Steam desktop client on lifepunchnet and retry.' -ForegroundColor Yellow
