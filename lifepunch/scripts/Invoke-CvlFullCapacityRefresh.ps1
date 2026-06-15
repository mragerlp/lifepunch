<#
.SYNOPSIS
  One-shot CVL full-capacity refresh after stack updates (s&box, DXRP, MCP, LLMs).

.DESCRIPTION
  Runs the maintenance chain in safe order:
    1. Sync Cornerman on-box scripts (+ model catalog JSON)
    2. Fix Cornerman Tier-3 serve if unhealthy
    3. Guard Cursor MCP tool names (chomnr 60-char limit)
    4. Refresh VENGEANCE mcp.json (sbox + sbox-editor + cornerman-lm)
    5. Restore Green dual-stack (SMB/tunnel/mcp) when SSH available
    6. Pre-launch checkup -Fix
    7. Emit Get-CvlConnectivityStatus JSON

  Does NOT: Steam update, Library Manager bumps, git pull (use -GitPull to add).

.EXAMPLE
  powershell -File lifepunch\scripts\Invoke-CvlFullCapacityRefresh.ps1
  powershell -File lifepunch\scripts\Invoke-CvlFullCapacityRefresh.ps1 -GitPull
  powershell -File lifepunch\scripts\Invoke-CvlFullCapacityRefresh.ps1 -SkipGreen
#>
[CmdletBinding()]
param(
    [switch] $GitPull,
    [switch] $SkipGreen,
    [switch] $SkipPreLaunch,
    [switch] $Quiet,
    [string] $SshTarget = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$RepoRoot = Split-Path -Parent $Here

function Write-Step([string]$msg) {
    if (-not $Quiet) { Write-Host "`n== $msg" -ForegroundColor Cyan }
}

if ($GitPull) {
    Write-Step 'Git pull --rebase (monorepo)'
    $status = git -C $RepoRoot status --porcelain 2>$null
    if ($status) {
        Write-Host '  SKIP: working tree not clean — commit or stash first' -ForegroundColor Yellow
    }
    else {
        git -C $RepoRoot fetch origin 2>&1 | Out-Host
        git -C $RepoRoot pull --rebase origin main 2>&1 | Out-Host
    }
}

Write-Step 'Sync Cornerman reboot scripts + Tier-3 catalog'
$sync = Join-Path $Here 'Sync-CornermanRebootScripts.ps1'
if (Test-Path -LiteralPath $sync) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $sync
}

Write-Step 'Cornerman Tier-3 serve'
. (Join-Path $Here 'Cornerman-Workflow.ps1')
if (-not $SshTarget) { $SshTarget = Get-CornermanSshTarget }
$statusScript = Join-Path $Here 'Get-CvlConnectivityStatus.ps1'
$pre = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $statusScript 2>$null | ConvertFrom-Json
if ($SkipGreen -or -not (Test-CornermanSshReady -SshTarget $SshTarget)) {
    if (-not $Quiet) { Write-Host '  SKIP Green LM fix (SSH unavailable or -SkipGreen)' -ForegroundColor DarkGray }
}
elseif (-not $pre.checks.'cornerman.tier3Serve') {
    $lmFix = Join-Path $Here 'Fix-CornermanLmServe.ps1'
    if (Test-Path -LiteralPath $lmFix) {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $lmFix
    }
}
else {
    if (-not $Quiet) { Write-Host '  OK Tier-3 already serving' -ForegroundColor Green }
}

Write-Step 'Cursor MCP tool-name guard (chomnr)'
$nameFix = Join-Path $Here 'Fix-SboxEditorMcpCursorToolNames.ps1'
if (Test-Path -LiteralPath $nameFix) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $nameFix -ProbeEditorMcp
}

Write-Step 'Refresh VENGEANCE MCP stack'
$mcpStack = Join-Path $Here 'Install-VengeanceMcpStack.ps1'
if (Test-Path -LiteralPath $mcpStack) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $mcpStack -SkipProbe
}

if (-not $SkipGreen -and (Test-CornermanSshReady -SshTarget $SshTarget)) {
    Write-Step 'Restore Green dual-stack'
    $restore = Join-Path $Here 'Restore-CornermanDualStack.ps1'
    if (Test-Path -LiteralPath $restore) {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $restore -SshTarget $SshTarget
    }
}

if (-not $SkipPreLaunch) {
    Write-Step 'Pre-launch checkup -Fix'
    $prelaunch = Join-Path $Here 'Test-PreLaunchCheckup.ps1'
    if (Test-Path -LiteralPath $prelaunch) {
        $plArgs = @{ Fix = $true }
        if ($Quiet) { $plArgs['Quiet'] = $true }
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $prelaunch @plArgs
    }
}

Write-Step 'Connectivity status'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $statusScript -Pretty

if (-not $Quiet) {
    Write-Host ''
    Write-Host 'If tool overrides changed: restart editor MCP server + Cursor Reload Window.' -ForegroundColor Cyan
    Write-Host 'Runbook: lifepunch/docs/CVL_FULL_CAPACITY_UPDATES.md' -ForegroundColor DarkGray
}
