<#
.SYNOPSIS
  Start LM Studio server on Cornerman and optionally warm a Tier-3 model.

.PARAMETER WarmModel
  distill = qwen/qwen3.6-35b-a3b (doc prep default)
  coder   = qwen2.5-coder-32b-instruct
  none    = server only

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File Start-CornermanLmStudio.ps1 -WarmModel distill
#>
[CmdletBinding()]
param(
    [ValidateSet('distill', 'coder', 'none')]
    [string] $WarmModel = 'distill',
    [string] $BindHost = '192.168.1.227',
    [int] $Port = 1234,
    [switch] $Quiet
)

$ErrorActionPreference = 'Stop'

function Write-Lms([string]$m) {
    if (-not $Quiet) { Write-Host $m }
}

function Get-LmsExe {
    $candidates = @(
        (Join-Path $env:USERPROFILE '.lmstudio\bin\lms.exe'),
        (Join-Path $env:LOCALAPPDATA 'LM Studio\bin\lms.exe')
    )
    foreach ($c in $candidates) {
        if (Test-Path -LiteralPath $c) { return $c }
    }
    $pathHit = Get-Command lms -ErrorAction SilentlyContinue
    if ($pathHit) { return $pathHit.Source }
    throw 'lms CLI not found. Install LM Studio and ensure lms is on PATH or under ~/.lmstudio/bin/'
}

$lms = Get-LmsExe
Write-Lms "LM Studio: $lms"

& $lms server start --port $Port --bind $BindHost 2>&1 | ForEach-Object { Write-Lms $_ }
if ($LASTEXITCODE -ne 0) { throw "lms server start failed (exit $LASTEXITCODE)" }

$modelId = switch ($WarmModel) {
    'distill' { 'qwen/qwen3.6-35b-a3b' }
    'coder'   { 'qwen2.5-coder-32b-instruct' }
    default   { $null }
}

if ($modelId) {
    Write-Lms "Loading $modelId (gpu max)..."
    & $lms load $modelId --gpu max -y 2>&1 | ForEach-Object { Write-Lms $_ }
    if ($LASTEXITCODE -ne 0) { throw "lms load failed for $modelId (exit $LASTEXITCODE)" }
}

try {
    $uri = "http://${BindHost}:${Port}/v1/models"
    $models = (Invoke-RestMethod -Uri $uri -TimeoutSec 15).data.id
    Write-Lms "Tier-3 OK: $uri"
    if (-not $Quiet) { $models | ForEach-Object { Write-Host "  $_" } }
}
catch {
    throw "LM Studio server up but probe failed: $uri ($($_.Exception.Message))"
}
