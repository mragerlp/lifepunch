<#
.SYNOPSIS
  Smoke-test xAI Grok /v1/responses using lifepunch/secure/xai.local.env

.EXAMPLE
  powershell -File lifepunch\scripts\Test-XaiGrokApi.ps1
#>
[CmdletBinding()]
param(
    [string] $EnvFile = '',
    [string] $Prompt = 'Reply with exactly: GROK_OK'
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$MonorepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path

if (-not $EnvFile) {
    $EnvFile = Join-Path $MonorepoRoot 'lifepunch\secure\xai.local.env'
}

if (-not (Test-Path -LiteralPath $EnvFile)) {
    throw "Missing $EnvFile - copy from lifepunch/secure/templates/xai.local.env.example"
}

Get-Content -LiteralPath $EnvFile | ForEach-Object {
    if ($_ -match '^\s*#' -or $_ -notmatch '=') { return }
    $name, $value = $_ -split '=', 2
    Set-Item -Path "Env:$($name.Trim())" -Value $value.Trim()
}

if (-not $env:XAI_API_KEY) { throw 'XAI_API_KEY not set in env file' }
$base = if ($env:XAI_API_BASE) { $env:XAI_API_BASE.TrimEnd('/') } else { 'https://api.x.ai/v1' }
$model = if ($env:XAI_GROK_MODEL) { $env:XAI_GROK_MODEL } else { 'grok-build-0.1' }

$body = @{
    model = $model
    input = @(
        @{ role = 'system'; content = 'You are Grok, a highly intelligent, helpful AI assistant.' }
        @{ role = 'user'; content = $Prompt }
    )
} | ConvertTo-Json -Depth 6

$headers = @{
    Authorization = "Bearer $($env:XAI_API_KEY)"
    'Content-Type' = 'application/json'
}

Write-Host "POST $base/responses (model=$model)" -ForegroundColor Cyan
$response = Invoke-RestMethod -Uri "$base/responses" -Method Post -Headers $headers -Body $body
$response | ConvertTo-Json -Depth 12
Write-Host 'OK' -ForegroundColor Green
