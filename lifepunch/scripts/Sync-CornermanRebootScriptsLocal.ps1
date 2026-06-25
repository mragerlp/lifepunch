<#
.SYNOPSIS
  Copy reboot-critical Cornerman scripts to C:\lifepunch\cornerman (run ON Green).

.EXAMPLE
  powershell -File lifepunch\scripts\Sync-CornermanRebootScriptsLocal.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$onBox = 'C:\lifepunch\cornerman'
$configDir = Join-Path $onBox 'config'

New-Item -ItemType Directory -Force -Path $onBox, $configDir | Out-Null

$files = @(
    'Invoke-CornermanHeadlessBoot.ps1',
    'Start-CornermanLmStudio.ps1',
    'Ensure-CornermanLmLanFirewall.ps1',
    'Install-CornermanHeadlessBoot.ps1',
    'Map-CornermanBridgeShare.ps1',
    'Ensure-CornermanBridgeShare.ps1',
    'Start-CornermanSboxEditorTunnel.ps1',
    'Install-CornermanSboxEditorTunnelWatchdog.ps1',
    'Install-CornermanGreenMcp.ps1',
    'Connect-CornermanBridge.ps1',
    'Install-CornermanLmWatchdog.ps1',
    'Get-CvlCornermanProbe.ps1',
    'Get-CornermanHealthProbe.ps1',
    'Remove-CornermanLemonade.ps1',
    'Close-CornermanLmStudioGui.ps1'
)

foreach ($name in $files) {
    $local = Join-Path $Here $name
    if (-not (Test-Path -LiteralPath $local)) { throw "Missing $local" }
    Copy-Item -LiteralPath $local -Destination (Join-Path $onBox $name) -Force
    Write-Host "OK $name" -ForegroundColor Green
}

$configSrc = Join-Path (Split-Path -Parent $Here) 'config\cornerman-tier3-models.json'
if (-not (Test-Path -LiteralPath $configSrc)) { throw "Missing $configSrc" }
Copy-Item -LiteralPath $configSrc -Destination (Join-Path $configDir 'cornerman-tier3-models.json') -Force
Write-Host 'OK cornerman-tier3-models.json -> config\' -ForegroundColor Green

Write-Host ''
Write-Host "Synced to $onBox" -ForegroundColor Cyan
