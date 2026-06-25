<#
.SYNOPSIS
  Exit off-Cursor mode and wire Green triple MCP (sbox + sbox-editor + cornerman-lm).

.DESCRIPTION
  Full capacity requires dual-stack on BOTH machines. This script:
    1. Removes OFF_CURSOR_ACTIVE marker on Green
    2. Pushes on-box scripts + refreshes Green mcp.json
    3. Sync SSH IPC mirror to Green (fallback) + headless SMB when secret exists
    4. Installs editor tunnel watchdog + starts tunnel
    5. Keeps Tier-3 headless (LM GUI closed)

  Run from VENGEANCE while s&box editor is open on Red.

.EXAMPLE
  powershell -File lifepunch\scripts\Restore-CornermanDualStack.ps1
  powershell -File lifepunch\scripts\Restore-CornermanDualStack.ps1 -MirrorOnly
#>
[CmdletBinding()]
param(
    [switch] $PromptForPassword,
    [switch] $MirrorOnly,
    [switch] $TrySmbMap,
    [string] $SshTarget = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $Here 'Cornerman-Workflow.ps1')

if (-not $SshTarget) { $SshTarget = Get-CornermanSshTarget }
if (-not (Test-CornermanSshReady -SshTarget $SshTarget)) {
    throw "Cornerman SSH not ready ($SshTarget)"
}

function Write-Step([string]$msg) {
    Write-Host ''
    Write-Host "== $msg" -ForegroundColor Cyan
}

$onBox = 'C:\lifepunch\cornerman'
$marker = Join-Path $onBox 'OFF_CURSOR_ACTIVE.txt'

Write-Step 'Remove off-Cursor marker'
$r = Invoke-CornermanSshExec -SshTarget $SshTarget -ScriptBlock @"
if (Test-Path -LiteralPath '$marker') {
  Remove-Item -LiteralPath '$marker' -Force
  'removed'
} else { 'absent' }
"@ -ConnectTimeout 15
Write-Host "  $($r.Output)" -ForegroundColor Green

Write-Step 'Sync Green on-box scripts'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Here 'Sync-CornermanRebootScripts.ps1')

Write-Step 'Bridge share + Green mcp.json + LM warm'
$bridgeArgs = @('-File', (Join-Path $Here 'Connect-CornermanBridge.ps1'), '-SshTarget', $SshTarget)
if ($MirrorOnly) { $bridgeArgs += '-MirrorOnly' }
elseif ($PSBoundParameters.ContainsKey('TrySmbMap') -and -not $TrySmbMap) { $bridgeArgs += '-MirrorOnly' }
if ($PromptForPassword) { $bridgeArgs += '-PromptForPassword' }
& powershell.exe -NoProfile -ExecutionPolicy Bypass @bridgeArgs

Write-Step 'Green editor tunnel watchdog + tunnel'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Here 'Send-CornermanWorkflow.ps1') `
    -Action InstallGreenMcp -SshTarget $SshTarget -NoHubIngest

$tunnel = Join-Path $onBox 'Start-CornermanSboxEditorTunnel.ps1'
$tr = Invoke-CornermanSshExec -SshTarget $SshTarget -ScriptBlock @"
if (Test-Path -LiteralPath '$tunnel') {
  & powershell -NoProfile -ExecutionPolicy Bypass -File '$tunnel' -Background
} else { throw 'missing tunnel script' }
"@ -ConnectTimeout 30
Write-Host "  $($tr.Output)" -ForegroundColor $(if ($tr.ExitCode -eq 0) { 'Green' } else { 'Yellow' })

Write-Step 'Close LM Studio GUI on Green (keep headless serve)'
$closeGui = Join-Path $Here 'Close-CornermanLmStudioGui.ps1'
if (Test-Path -LiteralPath $closeGui) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $closeGui -SshTarget $SshTarget -Quiet
}

Write-Host ''
Write-Host 'Green dual-stack restore done.' -ForegroundColor Green
Write-Host 'On Cornerman: open Cursor -> Reload Window -> MCP should show 3/3 green when VENGEANCE editor is open.' -ForegroundColor Cyan
