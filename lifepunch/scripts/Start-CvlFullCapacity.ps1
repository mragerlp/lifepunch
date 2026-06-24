<#
.SYNOPSIS
  Wire full CVL stack — Red editor bridge + Green triple MCP (sbox, sbox-editor, cornerman-lm).

.DESCRIPTION
  Run from VENGEANCE after s&box editor is open (Claude Bridge heartbeat required).

  Red:  bloat cleanup, SMB share, reverse editor tunnel :9090, mcp.json refresh
  Green: bridge scripts, SMB map task, editor tunnel, close LM Studio GUI (Tier-3 lms serve stays)

  Pass: Get-CvlConnectivityStatus.ps1 -> allOk: true

.EXAMPLE
  powershell -File lifepunch\scripts\Start-CvlFullCapacity.ps1
  powershell -File lifepunch\scripts\Start-SboxDxrpEditor.ps1 -FullCapacity
#>
[CmdletBinding()]
param(
    [switch] $SkipBloat,
    [switch] $MirrorOnly,
    [switch] $PromptForPassword,
    [string] $SshTarget = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }

function Write-Step([string]$msg) {
    Write-Host ''
    Write-Host "== $msg" -ForegroundColor Cyan
}

Write-Host ''
Write-Host '=== CVL full capacity ===' -ForegroundColor Green
Write-Host '  Requires: s&box editor open on VENGEANCE (bridge IPC heartbeat)' -ForegroundColor DarkGray

if (-not $SkipBloat) {
    Write-Step 'VENGEANCE bloat cleanup'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Here 'Invoke-VengeanceBloatCleanup.ps1')
}

$ipcDir = Join-Path $env:TEMP 'sbox-bridge-ipc'
$statusPath = Join-Path $ipcDir 'status.json'
if (-not (Test-Path -LiteralPath $statusPath)) {
    Write-Host ''
    Write-Host 'WARN: bridge IPC missing — launch editor first:' -ForegroundColor Yellow
    Write-Host '  powershell -File lifepunch\scripts\Start-SboxDxrpEditor.ps1' -ForegroundColor DarkGray
}

Write-Step 'Red bridge MCP refresh'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Here 'Install-CornermanSboxBridgeMcp.ps1')

Write-Step 'Green dual-stack (bridge + LM headless + editor tunnel)'
$restoreArgs = @('-File', (Join-Path $Here 'Restore-CornermanDualStack.ps1'))
if ($MirrorOnly) { $restoreArgs += '-MirrorOnly' }
if ($PromptForPassword) { $restoreArgs += '-PromptForPassword' }
if ($SshTarget) { $restoreArgs += @('-SshTarget', $SshTarget) }
& powershell.exe -NoProfile -ExecutionPolicy Bypass @restoreArgs

Write-Step 'Red reverse tunnel (Green localhost:9090 -> chomnr)'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Here 'Start-VengeanceEditorTunnelToCornerman.ps1') -Background

Write-Step 'Connectivity probe'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Here 'Get-CvlConnectivityStatus.ps1') -Pretty

$probeJson = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Here 'Get-CvlConnectivityStatus.ps1') | ConvertFrom-Json
if ($probeJson.allOk) {
    Write-Host ''
    Write-Host 'FULL CAPACITY OK — Green: Reload Cursor window if MCP pills are red.' -ForegroundColor Green
    exit 0
}

Write-Host ''
Write-Host 'FULL CAPACITY INCOMPLETE — down:' -ForegroundColor Yellow
$probeJson.down | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
Write-Host 'On Green desktop if SMB/tunnel still red: Map-CornermanBridgeShare.ps1 then Reload Window.' -ForegroundColor DarkGray
exit 1
