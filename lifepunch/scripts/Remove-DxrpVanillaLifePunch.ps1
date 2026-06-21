<#
.SYNOPSIS
  Remove all LifePunch trees and lp_* command sources from the dxrp-vanilla workbench.

.EXAMPLE
  powershell -File lifepunch\scripts\Remove-DxrpVanillaLifePunch.ps1
#>
[CmdletBinding()]
param(
    [string] $ConfigPath = '',
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $ConfigPath) { $ConfigPath = Join-Path $Here 'dxrp-vanilla-editor.local.json' }
if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw "Missing $ConfigPath - run Initialize-DxrpVanillaWorkbench.ps1 first."
}

. (Join-Path $Here 'Dxrp-VanillaWipe.ps1')
Invoke-DxrpVanillaLifePunchWipe -ConfigPath $ConfigPath -WhatIf:$WhatIf
