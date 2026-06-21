<#
.SYNOPSIS
  Launch s&box on the clean dxrp-vanilla workbench (no automatic LifePunch sync).

.DESCRIPTION
  Thin wrapper around Start-SboxDxrpEditor.ps1 using dxrp-vanilla-editor.local.json.
  Default: -NoSync so nothing from the repo touches the vanilla tree unless you pass -SyncAddon.

  First-time setup:
    powershell -File lifepunch\scripts\Initialize-DxrpVanillaWorkbench.ps1

.EXAMPLE
  powershell -File lifepunch\scripts\Start-SboxDxrpVanillaEditor.ps1 -ReplaceExisting
  powershell -File lifepunch\scripts\Start-SboxDxrpVanillaEditor.ps1 -SyncAddon adminmenu
#>
[CmdletBinding()]
param(
    [string[]] $SyncAddon = @(),
    [switch] $SyncAllAddons,
    [switch] $WithAuthorize,
    [switch] $SkipPreflight,
    [switch] $ReplaceExisting,
    [switch] $NoLaunch
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$ConfigPath = Join-Path $Here 'dxrp-vanilla-editor.local.json'

if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw @"
Missing $ConfigPath

Run once:
  powershell -File lifepunch\scripts\Initialize-DxrpVanillaWorkbench.ps1
"@
}

. (Join-Path $Here 'Dxrp-VanillaWipe.ps1')
Invoke-DxrpVanillaLifePunchWipe -ConfigPath $ConfigPath

$launchArgs = @{
    ConfigPath       = $ConfigPath
    SkipPreflight    = $SkipPreflight.IsPresent
    ReplaceExisting  = $ReplaceExisting.IsPresent
    NoLaunch         = $NoLaunch.IsPresent
    SkipOverlays     = $true
}
if ($WithAuthorize) { $launchArgs['WithAuthorize'] = $true }
if ($SyncAllAddons) { $launchArgs['SyncAllAddons'] = $true; $launchArgs['NoSync'] = $false }
elseif ($SyncAddon.Count -gt 0) { $launchArgs['SyncAddon'] = $SyncAddon; $launchArgs['NoSync'] = $false }
else { $launchArgs['NoSync'] = $true }

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Here 'Start-SboxDxrpEditor.ps1') @launchArgs
