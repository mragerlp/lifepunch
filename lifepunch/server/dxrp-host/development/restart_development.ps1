# Restart Development (Server 2) — visible console via server2_start.bat

param(
    [string] $InstallRoot = 'C:\Program Files (x86)\Steam\steamapps\common\sbox',
    [int] $GamePort = 27016,
    [switch] $NoStart
)

$ErrorActionPreference = 'Stop'

$hostProcessScript = Join-Path $InstallRoot 'Dxrp-HostProcess.ps1'
if (-not (Test-Path -LiteralPath $hostProcessScript)) {
    $hostProcessScript = Join-Path 'C:\SBOX-DXRP-Server' 'Dxrp-HostProcess.ps1'
}
if (Test-Path -LiteralPath $hostProcessScript) {
    . $hostProcessScript
    Stop-DevelopmentDxrpServer -InstallRoot $InstallRoot -GamePort $GamePort
}

if ($NoStart) {
    Write-Host 'NoStart — Development stopped.' -ForegroundColor Green
    return
}

$startBat = Join-Path $InstallRoot 'server2_start.bat'
if (-not (Test-Path -LiteralPath $startBat)) {
    throw ('Missing ' + $startBat)
}

Write-Host 'Starting Development in visible CMD (server2_start.bat)...' -ForegroundColor Green
# Launch the bat by ABSOLUTE path ($startBat), not the relative name: in a PS 5.1 spawn chain the child
# cmd did not resolve the relative 'server2_start.bat' despite -WorkingDirectory, zombie-ing an idle cmd
# ('... is not recognized as an internal or external command'). Sensor: Blue outbox 0002 trap 2.
Start-Process -FilePath 'cmd.exe' -ArgumentList @('/k', $startBat) -WorkingDirectory $InstallRoot
