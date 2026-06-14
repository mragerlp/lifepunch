<#
.SYNOPSIS
  One-time setup for VENGEANCE desk PTT (Python venv + deps).

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File lifepunch\scripts\vengeance-ptt\Install-VengeancePtt.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$Venv = Join-Path $Here '.venv'
$Py = Join-Path $Venv 'Scripts\python.exe'

function Write-Step($m) { Write-Host "==> $m" -ForegroundColor Cyan }

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    throw 'python not on PATH — install Python 3.11+ on VENGEANCE'
}

if (-not (Test-Path -LiteralPath $Py)) {
    Write-Step 'Create venv'
    python -m venv $Venv
}

Write-Step 'Install requirements'
& $Py -m pip install --upgrade pip | Out-Null
& $Py -m pip install -r (Join-Path $Here 'requirements.txt')

Write-Step 'List audio devices'
& $Py (Join-Path $Here 'vengeance_ptt.py') --list-devices

Write-Host ''
Write-Host 'OK — run Start-VengeancePtt.ps1 or Talk-On-Vengeance.cmd' -ForegroundColor Green
