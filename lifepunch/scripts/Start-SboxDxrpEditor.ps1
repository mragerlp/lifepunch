<#
.SYNOPSIS
  Launch s&box editor on DXRP with the server API token applied automatically.

.DESCRIPTION
  DXRP reads the portal server token from the ConVar "authorize" (ServerApiLink.Token).
  That ConVar is NOT saved across restarts — this script passes +authorize on launch so you
  never paste it into the in-game console manually.

  Token lives in gitignored dxrp-editor.local.json (copy from .example once).

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File lifepunch\scripts\Start-SboxDxrpEditor.ps1
#>
[CmdletBinding()]
param(
    [string] $ConfigPath = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $ConfigPath) { $ConfigPath = Join-Path $Here 'dxrp-editor.local.json' }

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

# DXRP official launcher pattern: +authorize <token> (see dxrp-server.cs)
$args = @(
    "-project", $project,
    "+authorize", $token,
    "+api", $api
)

Write-Host 'Launching DXRP editor with server API token...' -ForegroundColor Green
Write-Host "  Project: $project" -ForegroundColor DarkGray
Write-Host "  API:     $api" -ForegroundColor DarkGray
Write-Host '  Token:   (from dxrp-editor.local.json)' -ForegroundColor DarkGray
Write-Host ''

Start-Process -FilePath $sbox -ArgumentList $args -WorkingDirectory (Split-Path -Parent $sbox)
Write-Host 'Editor started. Wait for compile, then Claude Bridge / host play will see HasAuthorizationKey=true.' -ForegroundColor Cyan
