<#
.SYNOPSIS
  Sync LifePunch addons to DXRP, then launch s&box editor with the server API token.

.DESCRIPTION
  1. Mirror repo addon trees into the DXRP game project (default: bitcoinmining).
  2. Launch s&box with +authorize so ServerApiLink / portal data is available.

  Token lives in gitignored dxrp-editor.local.json (copy from .example once).

.PARAMETER SyncAddon
  Addon idents to mirror before launch. Default: bitcoinmining.

.PARAMETER SyncAllAddons
  Mirror every lifepunch addon folder in the repo.

.PARAMETER NoSync
  Skip repo -> DXRP mirror (editor only).

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File lifepunch\scripts\Start-SboxDxrpEditor.ps1
  powershell -File lifepunch\scripts\Start-SboxDxrpEditor.ps1 -SyncAddon ak47,bitcoinmining
  powershell -File lifepunch\scripts\Start-SboxDxrpEditor.ps1 -NoSync
#>
[CmdletBinding()]
param(
    [string[]] $SyncAddon = @('bitcoinmining'),
    [switch] $SyncAllAddons,
    [switch] $NoSync,
    [string] $ConfigPath = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $ConfigPath) { $ConfigPath = Join-Path $Here 'dxrp-editor.local.json' }

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
  2. Paste your DXRP server token from dxrp.net (Server -> Generate Token)
  3. Re-run this script

Example: $example
"@
}

$cfg = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
$sbox = [string]$cfg.sboxDevPath
$project = [string]$cfg.projectPath
$token = [string]$cfg.serverToken
$api = if ($cfg.api) { [string]$cfg.api } else { 'production' }

if (-not (Test-Path -LiteralPath $sbox)) { throw "s&box not found: $sbox" }
if (-not (Test-Path -LiteralPath $project)) { throw "DXRP project not found: $project" }
if ([string]::IsNullOrWhiteSpace($token) -or $token -like 'PASTE*') {
    throw 'Set serverToken in dxrp-editor.local.json (from dxrp.net server token).'
}

$args = @(
    '-project', $project,
    '+authorize', $token,
    '+api', $api
)

Write-Host 'Launching DXRP editor with server API token...' -ForegroundColor Green
Write-Host "  Project: $project" -ForegroundColor DarkGray
Write-Host "  API:     $api" -ForegroundColor DarkGray
Write-Host '  Token:   (from dxrp-editor.local.json)' -ForegroundColor DarkGray
Write-Host ''

Start-Process -FilePath $sbox -ArgumentList $args -WorkingDirectory (Split-Path -Parent $sbox)
Write-Host 'Editor started. Wait for compile, then Claude Bridge / host play will see HasAuthorizationKey=true.' -ForegroundColor Cyan
