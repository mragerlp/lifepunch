<#
.SYNOPSIS
  Mirror normalized Desktop lifepunchaddons -> repo lp* staging (alias).

.EXAMPLE
  powershell -File lifepunch\addons\scripts\Sync-LifepunchDesktopToModeldoc.ps1
#>
[CmdletBinding()]
param(
    [string] $DesktopRoot = "$env:USERPROFILE\OneDrive\Desktop\lifepunchaddons",
    [string] $RepoModelDoc = ''
)

$Here = $PSScriptRoot
$staging = Join-Path $Here 'Sync-LifepunchDesktopToStaging.ps1'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $staging -DesktopRoot $DesktopRoot
