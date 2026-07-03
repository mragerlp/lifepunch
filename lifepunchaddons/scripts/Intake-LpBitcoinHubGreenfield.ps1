<#
.SYNOPSIS
  Intake owner hub art into lpbitcoin/bitcoinhub/assets (greenfield staging).

.DESCRIPTION
  Thin wrapper — use Intake-LpBitcoinGreenfield.ps1 for full lane intake.

.EXAMPLE
  powershell -File lifepunchaddons\scripts\Intake-LpBitcoinHubGreenfield.ps1
  powershell -File lifepunchaddons\scripts\Intake-LpBitcoinHubGreenfield.ps1 -SyncDxrp
#>
[CmdletBinding()]
param(
    [string] $SourceRoot = '',
    [switch] $SyncDxrp,
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$master = Join-Path $PSScriptRoot 'Intake-LpBitcoinGreenfield.ps1'
$args = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $master, '-Entity', 'bitcoinhub')
if ($SourceRoot) { $args += @('-SourceRoot', $SourceRoot) }
if ($SyncDxrp) { $args += '-SyncDxrp' }
if ($WhatIf) { $args += '-WhatIf' }
& powershell.exe @args
