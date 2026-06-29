<#
.SYNOPSIS
  Remove wrong-profile and legacy files from lifepunchnet Official vs Development install roots.

.DESCRIPTION
  Safe to run after Deploy-DxrpHostLaunchers.ps1. Does not touch secure/, dxrp/, sbox-server.*,
  dxrp-server.cs, dxrp-server-config.json, steamcmd, or bin/.
#>
[CmdletBinding()]
param(
    [string] $OfficialRoot = 'C:\SBOX-DXRP-Server',
    [string] $DevelopmentRoot = 'C:\Program Files (x86)\Steam\steamapps\common\sbox'
)

$ErrorActionPreference = 'Stop'

function Remove-IfExists {
    param([string] $Path, [string] $Reason)
    if (Test-Path -LiteralPath $Path) {
        Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host ('  removed: ' + $Path + ' (' + $Reason + ')') -ForegroundColor DarkYellow
    }
}

Write-Host 'Cleaning stale DXRP host files...' -ForegroundColor Cyan

$officialOnlyRemove = @(
    'server2_start.bat',
    'start_dev_server.bat',
    'show_dev_server_log.bat',
    'tail_dev_server_log.bat',
    'restart_development.ps1',
    'Run-DevServer.ps1',
    'dxrp-server-config.development.json.example',
    'Populate-DevEngine.ps1',
    'Update-DevStagingEngine.ps1',
    'Restore-OfficialStableEngine.ps1',
    'auto_update_official_staging.bat',
    'OFFICIAL_PINNED.txt',
    'Ensure-DxrpRpCsproj.ps1'
)

$developmentOnlyRemove = @(
    'server1_start.bat',
    'restart_official.ps1',
    'auto_update_official.bat',
    'auto_update_official_staging.bat',
    'auto_update_all.bat',
    'dxrp-server-config.official.json.example',
    'Ensure-DxrpRpCsproj.ps1'
)

$legacyDirsOfficial = @('_pin-test', 'dev-engine')

Write-Host 'Official:' -ForegroundColor Green
foreach ($name in $officialOnlyRemove) {
    Remove-IfExists -Path (Join-Path $OfficialRoot $name) -Reason 'Dev/legacy on Official root'
}
foreach ($name in $legacyDirsOfficial) {
    Remove-IfExists -Path (Join-Path $OfficialRoot $name) -Reason 'legacy experiment tree'
}

Write-Host 'Development:' -ForegroundColor Green
foreach ($name in $developmentOnlyRemove) {
    Remove-IfExists -Path (Join-Path $DevelopmentRoot $name) -Reason 'Official/legacy on Dev root'
}

Write-Host 'Done.' -ForegroundColor Green
