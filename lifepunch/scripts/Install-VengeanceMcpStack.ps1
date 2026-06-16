<#
.SYNOPSIS
  One-shot VENGEANCE MCP stack: sbox + sbox-editor + cornerman-lm (Green LAN).

.DESCRIPTION
  Green is off-Cursor — all MCP runs on Red. cornerman-lm points at Green :1234.

.EXAMPLE
  powershell -File lifepunch\scripts\Install-VengeanceMcpStack.ps1
#>
[CmdletBinding()]
param(
    [switch] $SkipLmClone,
    [switch] $SkipProbe
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }

Write-Host 'VENGEANCE MCP stack (Red-only)' -ForegroundColor Cyan

$lmArgs = @{}
if ($SkipLmClone) { $lmArgs['SkipClone'] = $true }
& (Join-Path $Here 'Install-VengeanceCornermanLmMcp.ps1') @lmArgs

$editorArgs = @{}
if ($SkipProbe) { $editorArgs['SkipProbe'] = $true }
& (Join-Path $Here 'Install-VengeanceSboxEditorMcp.ps1') @editorArgs

Write-Host ''
Write-Host 'Done. Reload Cursor on VENGEANCE -> MCP: sbox, sbox-editor, sbox-jtc, cornerman-lm.' -ForegroundColor Green
Write-Host 'Green: dual-stack required — Restore-CornermanDualStack.ps1 if OFF_CURSOR_ACTIVE.' -ForegroundColor DarkGray
