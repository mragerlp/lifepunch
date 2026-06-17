<#
.SYNOPSIS
  One-shot: Desktop assets -> repo _modeldoc -> DXRP ModelDoc lane -> fresh scene -> editor.

.EXAMPLE
  powershell -File lifepunch\scripts\Setup-ModelDocGreenfieldEditor.ps1
  powershell -File lifepunch\scripts\Setup-ModelDocGreenfieldEditor.ps1 -NoLaunch
#>
[CmdletBinding()]
param(
    [string] $ConfigPath = '',
    [switch] $NoLaunch,
    [switch] $SkipUpstream
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $ConfigPath) { $ConfigPath = Join-Path $Here 'dxrp-editor.local.json' }

$syncDesktop = Join-Path (Split-Path $Here -Parent) 'addons\scripts\Sync-LifepunchDesktopToStaging.ps1'
$laneScript = Join-Path $Here 'Set-DxrpLifepunchModelDocLane.ps1'
$sweepExec = Join-Path $Here 'Sweep-SboxExecSnippets.ps1'
$launchScript = Join-Path $Here 'Start-SboxDxrpEditor.ps1'

Write-Host '=== LIFEPUNCH ModelDoc greenfield editor setup ===' -ForegroundColor Cyan

if (-not $SkipUpstream) {
    $upstreamGate = Join-Path $Here 'Ensure-DxrpUpstreamCurrent.ps1'
    if (Test-Path -LiteralPath $upstreamGate) {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $upstreamGate -FailIfBehind
        if ($LASTEXITCODE -ne 0) {
            Write-Host 'Warning: DXRP upstream behind — continuing anyway (owner READY).' -ForegroundColor Yellow
        }
    }
}

if (Test-Path -LiteralPath $sweepExec) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $sweepExec
}

Write-Host "`n[1/3] Sync Desktop lifepunchaddons -> repo lp* staging" -ForegroundColor Cyan
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $syncDesktop
if ($LASTEXITCODE -ne 0) { throw 'Desktop sync failed' }

Write-Host "`n[2/3] DXRP lane: lifepunchulx + lp* staging" -ForegroundColor Cyan
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $laneScript -ConfigPath $ConfigPath
if ($LASTEXITCODE -ne 0) { throw 'ModelDoc lane setup failed' }

$cfg = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
$dxrpGame = Split-Path -Parent ([string]$cfg.projectPath)
$sceneSrc = Join-Path (Split-Path $Here -Parent) 'addons\Assets\addons\lifepunch\_dev\scenes\lifepunch-modeldoc.scene'
$sceneDst = Join-Path $dxrpGame 'Assets\addons\lifepunch\_dev\scenes\lifepunch-modeldoc.scene'
New-Item -ItemType Directory -Force -Path (Split-Path $sceneDst -Parent) | Out-Null
Copy-Item -LiteralPath $sceneSrc -Destination $sceneDst -Force
Write-Host "`n[3/3] Fresh scene -> $sceneDst" -ForegroundColor Green

Write-Host ''
Write-Host 'Setup complete.' -ForegroundColor Cyan
Write-Host '  Open scene: addons/lifepunch/_dev/scenes/lifepunch-modeldoc.scene' -ForegroundColor DarkGray
Write-Host '  Lane: ULX + lp* staging (no bitcoinmining code)' -ForegroundColor DarkGray
Write-Host '  Restart editor if it was already open (rp.sbproj Resources changed).' -ForegroundColor Yellow

if ($NoLaunch) { return }

Write-Host ''
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $launchScript -NoSync -SkipPreflight -ConfigPath $ConfigPath
