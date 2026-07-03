<#
.SYNOPSIS
  Mirror owner Desktop UPLOAD READY ADDONS -> repo lp* staging (alias).

.EXAMPLE
  powershell -File lifepunchaddons\scripts\Sync-LifepunchDesktopToModeldoc.ps1
#>
[CmdletBinding()]
param(
    [string] $DesktopRoot = '',
    [string] $RepoModelDoc = ''
)

$Here = $PSScriptRoot
$staging = Join-Path $Here 'Sync-LifepunchDesktopToStaging.ps1'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $staging -DesktopRoot $DesktopRoot
