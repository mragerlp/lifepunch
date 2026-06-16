<#
.SYNOPSIS
  Copy LifePunch DXRP editor overlays into the local DXRP game tree.

.EXAMPLE
  powershell -File lifepunch\scripts\Sync-DxrpEditorOverlays.ps1
#>
[CmdletBinding()]
param(
    [string] $ConfigPath = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$repoRoot = Split-Path -Parent $Here
$overlayRoot = Join-Path $repoRoot 'dxrp-overlays'

if (-not $ConfigPath) { $ConfigPath = Join-Path $Here 'dxrp-editor.local.json' }
$dxrpGame = 'D:\Steam\steamapps\common\sbox\dxrp\game'
if (Test-Path -LiteralPath $ConfigPath) {
    $cfg = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
    if ($cfg.projectPath) {
        $dxrpGame = Split-Path -Parent ([string]$cfg.projectPath)
    }
}

if (-not (Test-Path -LiteralPath $overlayRoot)) {
    Write-Host "No overlays at $overlayRoot" -ForegroundColor DarkGray
    exit 0
}

Get-ChildItem -LiteralPath $overlayRoot -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring($overlayRoot.Length).TrimStart('\', '/')
    $dest = Join-Path $dxrpGame $rel
    $destDir = Split-Path -Parent $dest
    if (-not (Test-Path -LiteralPath $destDir)) {
        New-Item -ItemType Directory -Force -Path $destDir | Out-Null
    }
    Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
    Write-Host "  overlay -> $rel" -ForegroundColor DarkGray
}

Write-Host 'OK DXRP editor overlays synced' -ForegroundColor Green
