<#
.SYNOPSIS
  Create OneDrive drop folders for Fab manifest intake (Jun 2026).

.EXAMPLE
  powershell -File lifepunch/addons/scripts/Initialize-FabDropFolders.ps1
  powershell -File lifepunch/addons/scripts/Initialize-FabDropFolders.ps1 -WhatIf
#>
[CmdletBinding()]
param(
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'LifePunch-AddonDropPaths.ps1')

$root = Get-LifePunchAddonsDropRoot
if (-not $root) {
    $desktop = Join-Path $env:USERPROFILE 'OneDrive\Desktop'
    $lifepunch = Get-ChildItem -LiteralPath $desktop -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -like 'LIFEPUNCH*' } | Select-Object -First 1
    if ($lifepunch) {
        $root = Join-Path $lifepunch.FullName 'addons'
    }
    else {
        $root = Join-Path $env:USERPROFILE 'OneDrive\Lifepunch\FabDrop\addons'
    }
}

$folders = @(
    'lifepunchbitcoin\bitcointerminal'
    'lifepunchbitcoin\bitcoinminer'
    'lifepunchbitcoin\gpurack'
    'lifepunchhacker\hacker\hackerterminal'
    'lifepunchhacker\hacker\advancedhackerterminal'
    'lifepunchhacker\hacker\serverrack'
    'lifepunchhacker\hacker\advancedserverrack'
    'lifepunchhacker\fbi\governmentserverrack'
    'lifepunchhacker\fbi\governmentterminal'
    'lifepunchhacker\fbi\policeserverrack'
    'lifepunchhacker\fbi\policeterminal'
    'lifepunchblackmarketdealer\blackmarkethub'
    'lifepunchblackmarketdealer\blackmarketterminal'
    'lifepunchblackmarketdealer\blackmarketlocker'
    'lifepunchbanker\bankerhub'
    'lifepunchbanker\bankterminal'
    'lifepunchbanker\bankeratm'
    'lifepunchuniversal\usbflashdrive'
    'lifepunchuniversal\suppressedar15'
)

Write-Host "Fab drop root: $root" -ForegroundColor Cyan

foreach ($rel in $folders) {
    $path = Join-Path $root $rel
    $source = Join-Path $path 'source'
    if ($WhatIf) {
        Write-Host "[WhatIf] mkdir $source"
        continue
    }
    New-Item -ItemType Directory -Force -Path $source | Out-Null
    Write-Host "  OK $rel" -ForegroundColor Green
}

Write-Host ''
Write-Host 'Drop extracted FBX + textures into each folder''s source\ subfolder.' -ForegroundColor DarkGray
Write-Host 'Manifest: lifepunch/addons/docs/FAB_OWNER_MANIFEST_2026.md' -ForegroundColor DarkGray
