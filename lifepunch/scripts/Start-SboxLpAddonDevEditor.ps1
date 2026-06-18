<#
.SYNOPSIS
  Sync lp* addons, refresh lpaddondev project, launch s&box editor.

.EXAMPLE
  powershell -File lifepunch\scripts\Start-SboxLpAddonDevEditor.ps1
  powershell -File lifepunch\scripts\Start-SboxLpAddonDevEditor.ps1 -SkipPreflight
#>
[CmdletBinding()]
param(
    [string] $ConfigPath = '',
    [switch] $SkipPreflight,
    [switch] $NoLaunch
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $ConfigPath) { $ConfigPath = Join-Path $Here 'dxrp-editor.local.json' }

$init = Join-Path $Here 'Initialize-LpAddonDevProject.ps1'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $init -ConfigPath $ConfigPath
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$overlaySync = Join-Path $Here 'Sync-DxrpEditorOverlays.ps1'
if (Test-Path -LiteralPath $overlaySync) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $overlaySync -ConfigPath $ConfigPath
}

$mcpInstall = Join-Path $Here 'Install-VengeanceSboxEditorMcp.ps1'
if (Test-Path -LiteralPath $mcpInstall) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $mcpInstall -SkipProbe | Out-Null
}

if ($NoLaunch) { return }

$launch = Join-Path $Here 'Start-SboxDxrpEditor.ps1'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $launch -NoSync -SkipPreflight:$SkipPreflight -ConfigPath $ConfigPath
