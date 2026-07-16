# Restart Official (Server 1 / 70p) — visible console via server1_start.bat

param(
    [string] $InstallRoot = 'C:\SBOX-DXRP-Server',
    [int] $GamePort = 27015,
    [switch] $NoStart
)

$ErrorActionPreference = 'Stop'

$hostProcessScript = Join-Path $InstallRoot 'Dxrp-HostProcess.ps1'
if (-not (Test-Path -LiteralPath $hostProcessScript)) {
    $hostProcessScript = Join-Path $PSScriptRoot '..\scripts\Dxrp-HostProcess.ps1'
    if (-not (Test-Path -LiteralPath $hostProcessScript)) {
        $hostProcessScript = Join-Path (Split-Path $PSScriptRoot -Parent) 'scripts\Dxrp-HostProcess.ps1'
    }
}
if (Test-Path -LiteralPath $hostProcessScript) {
    . $hostProcessScript
    Stop-OfficialDxrpServer -InstallRoot $InstallRoot -GamePort $GamePort
}

if ($NoStart) {
    Write-Host 'NoStart — Official stopped.' -ForegroundColor Green
    return
}

$startBat = Join-Path $InstallRoot 'server1_start.bat'
if (-not (Test-Path -LiteralPath $startBat)) {
    throw ('Missing ' + $startBat)
}

Write-Host 'Starting Official in visible CMD (server1_start.bat)...' -ForegroundColor Green
# Launch the bat by ABSOLUTE path ($startBat), not the relative name: in a PS 5.1 spawn chain the child
# cmd did not resolve the relative 'server1_start.bat' despite -WorkingDirectory, zombie-ing an idle cmd
# ('... is not recognized as an internal or external command'). Sensor: Blue outbox 0002 trap 2.
Start-Process -FilePath 'cmd.exe' -ArgumentList @('/k', $startBat) -WorkingDirectory $InstallRoot
