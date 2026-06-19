<#
.SYNOPSIS
  Sync LifePunch addons to DXRP, then launch s&box editor on the DXRP project.

.DESCRIPTION
  1. Mirror repo addon trees into the DXRP game project (default: bitcoinmining).
  2. Launch s&box with -project only (normal DXRP route), unless an editor is already
     running — then sync only (no second window). Use -ReplaceExisting for one clean relaunch.

  Portal API is a launch ConVar (+authorize), not an in-game console command.
  After host play, use:  lp_authorize <token from dxrp.net>
  Or launch with -WithAuthorize (passes +authorize from dxrp-editor.local.json).
  api defaults to production — only pass +api staging if you need staging.
  With API connected, editor host play auto-spawns rank bots (lifepunch_auto_spawn_testbots, default 1).

.PARAMETER SyncAddon
  Addon idents to mirror before launch. Default: bitcoinmining only.

.PARAMETER BitcoinOnly
  Purge all non-bitcoin LifePunch addons from DXRP before sync (fresh console).

.PARAMETER SkipConnectivityWatch
  Do not start Watch-CvlConnectivity.ps1 in the background.

.PARAMETER NoLaunch
  Sync/preflight only — never start s&box.

.PARAMETER ReplaceExisting
  Kill all sbox-dev instances, then launch one DXRP editor (use when stuck on blank/wrong project).

.PARAMETER ForceNew
  Always Start-Process even if sbox-dev is already running (causes a second editor — avoid unless intentional).

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File lifepunch\scripts\Start-SboxDxrpEditor.ps1
  powershell -File lifepunch\scripts\Start-SboxDxrpEditor.ps1 -PreflightFix -BitcoinOnly -SyncAddon bitcoinmining
  powershell -File lifepunch\scripts\Start-SboxDxrpEditor.ps1 -NoSync
  powershell -File lifepunch\scripts\Start-SboxDxrpEditor.ps1 -WithAuthorize
  powershell -File lifepunch\scripts\Start-SboxDxrpEditor.ps1 -ReplaceExisting -NoSync
#>
[CmdletBinding()]
param(
    [string[]] $SyncAddon = @('bitcoinmining'),
    [switch] $SyncAllAddons,
    [switch] $NoSync,
    [switch] $WithAuthorize,
    [switch] $SkipPreflight,
    [switch] $PreflightFix,
    [switch] $BitcoinOnly,
    [switch] $SkipConnectivityWatch,
    [switch] $NoLaunch,
    [switch] $ReplaceExisting,
    [switch] $ForceNew,
    [string] $ConfigPath = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }

function Get-SboxDevProcesses {
    @(Get-Process -Name 'sbox-dev' -ErrorAction SilentlyContinue | Where-Object { -not $_.HasExited })
}

function Stop-AllSboxDevEditors {
    $procs = Get-SboxDevProcesses
    if ($procs.Count -eq 0) { return 0 }
    foreach ($proc in $procs) {
        Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
    }
    Start-Sleep -Seconds 2
    return $procs.Count
}

function Focus-SboxDevEditor {
    param([System.Diagnostics.Process]$Process)
    if (-not $Process -or $Process.HasExited -or $Process.MainWindowHandle -eq [IntPtr]::Zero) { return }
    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class LifePunchSboxWindowFocus {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
'@ -ErrorAction SilentlyContinue | Out-Null
    [LifePunchSboxWindowFocus]::ShowWindow($Process.MainWindowHandle, 9) | Out-Null
    [LifePunchSboxWindowFocus]::SetForegroundWindow($Process.MainWindowHandle) | Out-Null
}

if (-not $ConfigPath) { $ConfigPath = Join-Path $Here 'dxrp-editor.local.json' }

$upstreamGate = Join-Path $Here 'Ensure-DxrpUpstreamCurrent.ps1'
if ((Test-Path -LiteralPath $upstreamGate) -and -not $SkipPreflight) {
    Write-Host 'DXRP upstream gate (mragerlp/dxrp-public develop)...' -ForegroundColor Cyan
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $upstreamGate -FailIfBehind
    if ($LASTEXITCODE -ne 0) {
        Write-Host 'Blocked: DXRP develop is behind upstream.' -ForegroundColor Red
        Write-Host '  powershell -File lifepunch\scripts\Ensure-DxrpUpstreamCurrent.ps1 -Sync -UpdatePin -SyncSteam' -ForegroundColor Yellow
        exit 1
    }
    Write-Host ''
}

if (-not $SkipPreflight) {
    $preflight = Join-Path $Here 'Test-PreLaunchCheckup.ps1'
    if (Test-Path -LiteralPath $preflight) {
        Write-Host 'Pre-launch checkup (Cornerman + dual MCP)...' -ForegroundColor Cyan
        if ($PreflightFix) {
            & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $preflight -Fix
        }
        else {
            & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $preflight
        }
        if ($LASTEXITCODE -ne 0) {
            Write-Host 'Pre-launch checkup reported blockers — continuing editor launch.' -ForegroundColor Yellow
            Write-Host '  Re-run: Test-PreLaunchCheckup.ps1 -Fix' -ForegroundColor DarkGray
        }
        Write-Host ''
    }
}

$sweepExec = Join-Path $Here 'Sweep-SboxExecSnippets.ps1'
if (Test-Path -LiteralPath $sweepExec) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $sweepExec
}

$overlaySync = Join-Path $Here 'Sync-DxrpEditorOverlays.ps1'
if (Test-Path -LiteralPath $overlaySync) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $overlaySync -ConfigPath $ConfigPath
}

if (-not $NoSync) {
    if ($BitcoinOnly -or ($PreflightFix -and -not $SyncAllAddons)) {
        $bitcoinOnlyScript = Join-Path $Here 'Set-DxrpLifepunchBitcoinOnly.ps1'
        if (Test-Path -LiteralPath $bitcoinOnlyScript) {
            Write-Host 'Bitcoin-only DXRP purge (remove quarantined addon trees)...' -ForegroundColor Cyan
            & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $bitcoinOnlyScript -ConfigPath $ConfigPath
            Write-Host ''
        }
    }
    $pullCompiled = Join-Path $Here 'Pull-DxrpCompiledAssetsToRepo.ps1'
    if (Test-Path -LiteralPath $pullCompiled) {
        foreach ($ident in $(if ($SyncAllAddons) { @() } else { $SyncAddon })) {
            if ($ident) {
                Write-Host "Rescue compiled assets from DXRP ($ident)..." -ForegroundColor DarkGray
                & $pullCompiled -Addon $ident -ConfigPath $ConfigPath
            }
        }
        Write-Host ''
    }
    $syncScript = Join-Path $Here 'Sync-LifePunchAddonsToDxrp.ps1'
    if (-not (Test-Path -LiteralPath $syncScript)) { throw "Missing $syncScript" }
    $syncArgs = @{ ConfigPath = $ConfigPath }
    if ($SyncAllAddons) { $syncArgs['All'] = $true }
    else { $syncArgs['Addon'] = $SyncAddon }
    & $syncScript @syncArgs
    Write-Host ''
}

if (-not (Test-Path -LiteralPath $ConfigPath)) {
    $example = Join-Path $Here 'dxrp-editor.local.json.example'
    throw @"
Missing $ConfigPath

One-time setup:
  1. Copy dxrp-editor.local.json.example -> dxrp-editor.local.json
  2. Set sboxDevPath and projectPath to your machine
  3. Re-run this script

Example: $example
"@
}

$cfg = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
$sbox = [string]$cfg.sboxDevPath
$project = [string]$cfg.projectPath
$token = if ($cfg.serverToken) { [string]$cfg.serverToken } else { '' }
$api = if ($cfg.api) { [string]$cfg.api } else { 'production' }

if (-not (Test-Path -LiteralPath $sbox)) { throw "sbox-dev not found: $sbox" }
if (-not (Test-Path -LiteralPath $project)) { throw "DXRP project not found: $project" }

$args = @('-project', $project)

if ($WithAuthorize) {
    if ([string]::IsNullOrWhiteSpace($token) -or $token -like 'PASTE*') {
        throw 'WithAuthorize requires serverToken in dxrp-editor.local.json (from dxrp.net server token).'
    }
    $args += '+authorize', $token, '+api', $api
}

Write-Host 'DXRP editor launch...' -ForegroundColor Green
Write-Host "  Project: $project" -ForegroundColor DarkGray
if ($WithAuthorize) {
    Write-Host "  API:     $api (+authorize from config)" -ForegroundColor DarkGray
}
else {
    Write-Host '  Portal API: host play then lp_authorize YOUR_TOKEN (authorize is +launch only)' -ForegroundColor DarkGray
}
Write-Host ''

if ($NoLaunch) {
    Write-Host 'NoLaunch - sync/preflight done; sbox was not started.' -ForegroundColor Cyan
    exit 0
}

$existing = Get-SboxDevProcesses
if ($ReplaceExisting -and $existing.Count -gt 0) {
    $closed = Stop-AllSboxDevEditors
    Write-Host ('ReplaceExisting - closed {0} sbox-dev instance(s).' -f $closed) -ForegroundColor Yellow
    $existing = @()
}

if ($existing.Count -gt 0 -and -not $ForceNew) {
    Focus-SboxDevEditor -Process $existing[0]
    Write-Host 'sbox editor already running - skipped second launch (prevents duplicate windows).' -ForegroundColor Yellow
    Write-Host "  Running: $($existing.Count) instance(s). Focused pid $($existing[0].Id)." -ForegroundColor DarkGray
    Write-Host "  Open DXRP: File -> Open Project -> $project" -ForegroundColor Cyan
    Write-Host '  One clean relaunch: Start-SboxDxrpEditor.ps1 -ReplaceExisting -NoSync' -ForegroundColor DarkGray
    Write-Host '  Intentional second window: -ForceNew' -ForegroundColor DarkGray
}
else {
    if ($existing.Count -gt 0 -and $ForceNew) {
        Write-Host ('ForceNew - launching another editor ({0} already running).' -f $existing.Count) -ForegroundColor Yellow
    }

    Start-Process -FilePath $sbox -ArgumentList $args -WorkingDirectory (Split-Path -Parent $sbox)
    if ($WithAuthorize) {
        Write-Host 'Editor started with +authorize. Wait for compile, then host play.' -ForegroundColor Cyan
        Write-Host '  Rank bots auto-spawn when portal ranks load (lifepunch_auto_spawn_testbots 1).' -ForegroundColor DarkGray
    }
    else {
        Write-Host 'Editor started. Host play, then lp_authorize YOUR_TOKEN if you need portal/API data.' -ForegroundColor Cyan
        Write-Host '  Rank bots wait for lp_authorize - vanilla editor play will NOT spawn them.' -ForegroundColor DarkGray
        Write-Host '  sbox-jtc: open Editor dock MCP Server (jtc) - it does NOT autostart like chomnr.' -ForegroundColor Yellow
        Write-Host '  LifePunch overlay autostarts jtc when Sync-DxrpEditorOverlays.ps1 ran (see dxrp-overlays/Editor).' -ForegroundColor DarkGray
        Write-Host '  Then Cursor Reload Window if sbox-jtc MCP is red.' -ForegroundColor DarkGray
    }
}

if (-not $SkipConnectivityWatch) {
    $watchScript = Join-Path $Here 'Watch-CvlConnectivity.ps1'
    $opsNode = Join-Path $Here 'LifePunch-OpsNode.ps1'
    $isVengeance = $true
    if (Test-Path -LiteralPath $opsNode) {
        . $opsNode
        $isVengeance = Test-IsVengeanceWorkstation
    }
    elseif ($env:COMPUTERNAME.ToUpperInvariant() -notlike '*VENGEANCE*') {
        $isVengeance = $false
    }
    if ($isVengeance -and (Test-Path -LiteralPath $watchScript)) {
        $watchRunning = @(Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction SilentlyContinue |
            Where-Object { $_.CommandLine -and $_.CommandLine -match 'Watch-CvlConnectivity\.ps1' })
        if ($watchRunning.Count -eq 0) {
            $logDir = Join-Path $env:LOCALAPPDATA 'LifePunch'
            New-Item -ItemType Directory -Force -Path $logDir | Out-Null
            $logPath = Join-Path $logDir 'cvl-connectivity-watch.log'
            $errPath = Join-Path $logDir 'cvl-connectivity-watch.err.log'
            Start-Process -FilePath 'powershell.exe' -ArgumentList @(
                '-NoProfile', '-ExecutionPolicy', 'Bypass',
                '-File', $watchScript, '-Quiet'
            ) -WindowStyle Hidden -RedirectStandardOutput $logPath -RedirectStandardError $errPath | Out-Null
            Write-Host "Connectivity watch started (hidden). Log: $logPath" -ForegroundColor DarkGray
            Write-Host '  Stop: powershell -File lifepunch\scripts\Stop-CvlBackgroundWatchers.ps1' -ForegroundColor DarkGray
        }
        else {
            Write-Host "Connectivity watch already running (pid $($watchRunning[0].ProcessId))." -ForegroundColor DarkGray
        }
    }
}
