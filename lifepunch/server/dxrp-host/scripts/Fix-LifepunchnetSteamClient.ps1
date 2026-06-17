<#
.SYNOPSIS
  Wire SteamCMD steamclient DLLs so s&box dedicated server can connect to Steam.

.DESCRIPTION
  s&box 26.06.10+ no longer ships Steam client binaries with the dedicated server.
  Without HKCU registry entries, the server shows "not connected to Steam".

  Law: https://sbox.game/dev/doc/networking/dedicated-servers/ (Steam Client Binaries)

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\Fix-LifepunchnetSteamClient.ps1
#>
[CmdletBinding()]
param(
    [string] $SteamCmdExe = ''
)

$ErrorActionPreference = 'Stop'

function Find-SteamCmdDir {
    param([string] $Hint)
    $exes = @()
    if ($Hint) { $exes += $Hint }
    $exes += @(
        'C:\steamcmd\steamcmd.exe',
        'C:\SteamCMD\steamcmd.exe',
        'C:\Program Files\SteamCMD\steamcmd.exe',
        'D:\steamcmd\steamcmd.exe'
    )
    foreach ($p in $exes) {
        if ($p -and (Test-Path -LiteralPath $p)) {
            return (Resolve-Path -LiteralPath (Split-Path -Parent $p)).Path
        }
    }
    return $null
}

$steamDir = Find-SteamCmdDir -Hint $SteamCmdExe
if (-not $steamDir) {
    throw @'
steamcmd not found. Install SteamCMD first, then run once:
  steamcmd +login anonymous +app_update 1892930 validate +quit
'@
}

$dll64 = Join-Path $steamDir 'steamclient64.dll'
$dll32 = Join-Path $steamDir 'steamclient.dll'
if (-not (Test-Path -LiteralPath $dll64)) {
    throw "Missing $dll64 — run steamcmd +app_update 1892930 validate first."
}

$regPath = 'HKCU:\SOFTWARE\Valve\Steam\ActiveProcess'
New-Item -Path $regPath -Force | Out-Null
Set-ItemProperty -Path $regPath -Name 'SteamClientDll64' -Value $dll64 -Type String
if (Test-Path -LiteralPath $dll32) {
    Set-ItemProperty -Path $regPath -Name 'SteamClientDll' -Value $dll32 -Type String
}

Write-Host 'Steam client DLL registry wired.' -ForegroundColor Green
Write-Host "  SteamClientDll64 = $dll64" -ForegroundColor DarkGray
if (Test-Path -LiteralPath $dll32) {
    Write-Host "  SteamClientDll   = $dll32" -ForegroundColor DarkGray
}
Write-Host 'Restart the DXRP server console (server2_start.bat) for this user session.' -ForegroundColor Cyan
