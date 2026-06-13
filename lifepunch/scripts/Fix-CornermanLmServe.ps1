<#
.SYNOPSIS
  One-shot from VENGEANCE: sync LM scripts, warm daily lane, verify VRAM, ensure watchdog.

.DESCRIPTION
  Cornerman Tier-3 serve = LM Studio headless server on :1234 with distill + embed IN VRAM.
  Coder stays on disk until WarmCoder. No GUI required; no persistent SSH terminal required.

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File lifepunch\scripts\Fix-CornermanLmServe.ps1
#>
[CmdletBinding()]
param(
    [string] $SshTarget = '',
    [switch] $SkipWatchdog
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $Here 'Cornerman-Workflow.ps1')

if (-not $SshTarget) { $SshTarget = Get-CornermanSshTarget }

function Write-Step([string]$m, [string]$Color = 'Cyan') {
    Write-Host $m -ForegroundColor $Color
}

if (-not (Test-CornermanSshReady -SshTarget $SshTarget)) {
    throw "Cornerman SSH not ready ($SshTarget)"
}

Write-Step '=== Fix Cornerman LM serve (headless, no GUI) ==='

Write-Step '1/4 Sync reboot scripts to Green...'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Here 'Sync-CornermanRebootScripts.ps1')

Write-Step '2/4 Warm daily lane (lms server + distill + embed in VRAM)...'
$lms = 'C:\lifepunch\cornerman\Start-CornermanLmStudio.ps1'
$warm = Invoke-CornermanSshExec -SshTarget $SshTarget -ScriptBlock @"
if (-not (Test-Path -LiteralPath '$lms')) { throw 'Missing $lms' }
& powershell -NoProfile -ExecutionPolicy Bypass -File '$lms' -WarmModel daily
"@ -ConnectTimeout 300
if ($warm.ExitCode -ne 0) {
    throw "Warm failed (exit $($warm.ExitCode)): $($warm.Output)"
}
if ($warm.Output) { Write-Host $warm.Output }

if (-not $SkipWatchdog) {
    Write-Step '3/4 Ensure LM watchdog scheduled task...'
    $watch = 'C:\lifepunch\cornerman\Install-CornermanLmWatchdog.ps1'
    $wd = Invoke-CornermanSshExec -SshTarget $SshTarget -ScriptBlock @"
if (-not (Test-Path -LiteralPath '$watch')) { throw 'Missing $watch' }
& powershell -NoProfile -ExecutionPolicy Bypass -File '$watch'
"@ -ConnectTimeout 120
    if ($wd.ExitCode -ne 0) {
        Write-Step "Watchdog install skipped or needs elevated RDP once: $($wd.Output)" 'Yellow'
    }
    elseif ($wd.Output) { Write-Host $wd.Output }
}
else {
    Write-Step '3/4 Watchdog skipped (-SkipWatchdog)' 'DarkGray'
}

Write-Step '4/4 Probe VRAM truth (lms ps, not /v1/models catalog)...'
$probeOnBox = 'C:\lifepunch\cornerman\Get-CvlCornermanProbe.ps1'
$chk = Invoke-CornermanSshExec -SshTarget $SshTarget -ScriptBlock @"
if (-not (Test-Path -LiteralPath '$probeOnBox')) { throw 'Missing $probeOnBox — sync failed' }
& powershell -NoProfile -ExecutionPolicy Bypass -File '$probeOnBox'
"@ -ConnectTimeout 30
$jsonLine = ($chk.Output -split "`n" | Where-Object { $_.Trim().StartsWith('{') } | Select-Object -Last 1)
if (-not $jsonLine) {
    throw "Probe failed: $($chk.Output)"
}
$state = $jsonLine | ConvertFrom-Json

Write-Host ''
Write-Step 'RESULT' 'Green'
Write-Host ("  LM server (:1234)     {0}" -f $(if ($state.lmStudioOk) { 'UP' } else { 'DOWN' }))
Write-Host ("  Catalog (3 on disk)   {0}" -f $(if ($state.lmCatalogOk) { 'OK' } else { 'MISSING' }))
Write-Host ("  Serve (VRAM daily)    {0}" -f $(if ($state.lmServeOk) { 'OK — distill+embed loaded' } else { 'FAIL — run warm again' }))
Write-Host ("  VRAM loaded ({0})       {1}" -f $state.lmVramCount, $state.lmVramLoaded)
Write-Host ("  Watchdog task         {0}" -f $(if ($state.lmWatchdogOk) { 'OK' } else { 'MISSING — RDP elevated Install-CornermanLmWatchdog.ps1' }))
Write-Host ''
Write-Host '  GUI required?         NO — lms server runs headless' -ForegroundColor DarkGray
Write-Host '  SSH terminal required? NO — watchdog keeps :1234 up while jared is logged in' -ForegroundColor DarkGray
Write-Host '  Coder in VRAM?        ON DEMAND — Send-CornermanWorkflow.ps1 -Action WarmCoder' -ForegroundColor DarkGray

if (-not $state.lmTier3Ok) { exit 1 }
exit 0
