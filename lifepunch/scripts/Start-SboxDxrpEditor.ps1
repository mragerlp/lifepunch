<#
.SYNOPSIS
  Sync LifePunch addons to DXRP, then launch s&box editor on the DXRP project.

.DESCRIPTION
  1. Mirror repo addon trees into the DXRP game project (default: bitcoinmining).
  2. Launch s&box with -project only (normal DXRP route).

  Paste your server API key in the in-game console when you need portal data:
    authorize <token from dxrp.net>
    api production

  Optional -WithAuthorize still passes +authorize from dxrp-editor.local.json.

.PARAMETER SyncAddon
  Addon idents to mirror before launch. Default: bitcoinmining.

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
    [string[]] $SyncAddon = @('bitcoinmining', 'hackerjob'),
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
        $pfArgs = @{}
        if ($PreflightFix) { $pfArgs['Fix'] = $true }
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $preflight @pfArgs
        if ($LASTEXITCODE -ne 0) {
            Write-Host 'Pre-launch checkup reported blockers — continuing editor launch.' -ForegroundColor Yellow
            Write-Host '  Re-run: Test-PreLaunchCheckup.ps1 -Fix' -ForegroundColor DarkGray
        }
        Write-Host ''
    }
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
    Write-Host '  API key: paste in console when needed — authorize <token>' -ForegroundColor DarkGray
}
Write-Host ''

Start-Process -FilePath $sbox -ArgumentList $args -WorkingDirectory (Split-Path -Parent $sbox)
if ($WithAuthorize) {
    Write-Host 'Editor started with +authorize. Wait for compile, then host play.' -ForegroundColor Cyan
}
else {
    Write-Host 'Editor started. Host play, then authorize <token> in console if you need portal/API data.' -ForegroundColor Cyan
}

if (-not $SkipConnectivityWatch) {
    $watchScript = Join-Path $Here 'Watch-CvlConnectivity.ps1'
    if (Test-Path -LiteralPath $watchScript) {
        $statePath = Join-Path $env:LOCALAPPDATA 'LifePunch\cvl-connectivity-state.json'
        $startWatch = $true
        if (Test-Path -LiteralPath $statePath) {
            try {
                $saved = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
                if ($saved.ts) {
                    $age = ((Get-Date).ToUniversalTime() - [datetime]$saved.ts).TotalSeconds
                    if ($age -lt 90) { $startWatch = $false }
                }
            }
            catch { }
        }
        if ($startWatch) {
            Start-Process -FilePath 'powershell.exe' -ArgumentList @(
                '-NoExit', '-NoProfile', '-ExecutionPolicy', 'Bypass',
                '-File', $watchScript
            ) -WindowStyle Minimized | Out-Null
            Write-Host 'Connectivity watch started (toast on MCP/Tier-3 drop). Minimized PowerShell window.' -ForegroundColor DarkGray
        }
        else {
            Write-Host 'Connectivity watch already active (recent state file).' -ForegroundColor DarkGray
        }
    }
}
