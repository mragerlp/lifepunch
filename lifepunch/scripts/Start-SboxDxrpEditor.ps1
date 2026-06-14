<#
.SYNOPSIS
  Sync LifePunch addons to DXRP, then launch s&box editor on the DXRP project.

.DESCRIPTION
  1. Mirror repo addon trees into the DXRP game project (default: bitcoinmining).
  2. Launch s&box with -project only (normal DXRP route).

  Portal API is a launch ConVar (+authorize), not an in-game console command.
  After host play, use:  lp_authorize <token from dxrp.net>
  Or launch with -WithAuthorize (passes +authorize from dxrp-editor.local.json).
  api defaults to production — only pass +api staging if you need staging.
  With API connected, editor host play auto-spawns rank bots (lifepunch_auto_spawn_testbots, default 1).

.PARAMETER SyncAddon
  Addon idents to mirror before launch. Default: bitcoinmining, hackerjob, adminmenu.

.PARAMETER SyncAllAddons
  Mirror every lifepunch addon folder in the repo.

.PARAMETER NoSync
  Skip repo -> DXRP mirror (editor only).

.PARAMETER WithAuthorize
  Pass +authorize and +api from dxrp-editor.local.json (legacy automation).

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File lifepunch\scripts\Start-SboxDxrpEditor.ps1
  powershell -File lifepunch\scripts\Start-SboxDxrpEditor.ps1 -SyncAddon ak47,bitcoinmining
  powershell -File lifepunch\scripts\Start-SboxDxrpEditor.ps1 -NoSync
  powershell -File lifepunch\scripts\Start-SboxDxrpEditor.ps1 -WithAuthorize
#>
[CmdletBinding()]
param(
    [string[]] $SyncAddon = @('bitcoinmining', 'hackerjob', 'adminmenu'),
    [switch] $SyncAllAddons,
    [switch] $NoSync,
    [switch] $WithAuthorize,
    [switch] $SkipPreflight,
    [switch] $PreflightFix,
    [switch] $SkipConnectivityWatch,
    [string] $ConfigPath = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $ConfigPath) { $ConfigPath = Join-Path $Here 'dxrp-editor.local.json' }

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

if (-not $NoSync) {
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

if (-not (Test-Path -LiteralPath $sbox)) { throw "s&box not found: $sbox" }
if (-not (Test-Path -LiteralPath $project)) { throw "DXRP project not found: $project" }

$args = @('-project', $project)

if ($WithAuthorize) {
    if ([string]::IsNullOrWhiteSpace($token) -or $token -like 'PASTE*') {
        throw 'WithAuthorize requires serverToken in dxrp-editor.local.json (from dxrp.net server token).'
    }
    $args += '+authorize', $token, '+api', $api
}

Write-Host 'Launching DXRP editor (normal project open)...' -ForegroundColor Green
Write-Host "  Project: $project" -ForegroundColor DarkGray
if ($WithAuthorize) {
    Write-Host "  API:     $api (+authorize from config)" -ForegroundColor DarkGray
}
else {
    Write-Host '  Portal API: host play then lp_authorize <token> (authorize is +launch only)' -ForegroundColor DarkGray
}
Write-Host ''

Start-Process -FilePath $sbox -ArgumentList $args -WorkingDirectory (Split-Path -Parent $sbox)
if ($WithAuthorize) {
    Write-Host 'Editor started with +authorize. Wait for compile, then host play.' -ForegroundColor Cyan
    Write-Host '  Rank bots auto-spawn when portal ranks load (lifepunch_auto_spawn_testbots 1).' -ForegroundColor DarkGray
}
else {
    Write-Host 'Editor started. Host play, then lp_authorize <token> if you need portal/API data.' -ForegroundColor Cyan
    Write-Host '  Rank bots wait for lp_authorize — vanilla editor play will NOT spawn them.' -ForegroundColor DarkGray
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
