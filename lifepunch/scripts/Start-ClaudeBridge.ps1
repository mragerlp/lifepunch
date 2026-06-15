<#
.SYNOPSIS
  Point Claude Code (or any Anthropic client) at Cornerman LM Studio.

.DESCRIPTION
  LM Studio 0.4.1+ exposes /v1/messages (Anthropic-compatible). This script sets
  ANTHROPIC_BASE_URL + ANTHROPIC_AUTH_TOKEN for the current session and probes the
  Cornerman endpoint. See lifepunch/docs/CORNERMAN_LM_STUDIO.md

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File Start-ClaudeBridge.ps1
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File Start-ClaudeBridge.ps1 -Model qwen2.5-coder-32b-instruct -LaunchClaude
#>
[CmdletBinding()]
param(
    [string] $CornermanHost = '192.168.1.227',
    [int] $Port = 1234,
    [string] $Model = 'qwen/qwen3.6-35b-a3b',
    [switch] $LaunchClaude,
    [switch] $Quiet
)

$ErrorActionPreference = 'Stop'

$base = "http://${CornermanHost}:${Port}"
$env:ANTHROPIC_BASE_URL = $base
$env:ANTHROPIC_AUTH_TOKEN = 'lmstudio'

function Write-Bridge([string]$m) {
    if (-not $Quiet) { Write-Host $m }
}

Write-Bridge "Claude Bridge -> $base"
Write-Bridge "  ANTHROPIC_BASE_URL=$base"
Write-Bridge "  ANTHROPIC_AUTH_TOKEN=lmstudio"

try {
    $models = (Invoke-RestMethod -Uri "$base/v1/models" -TimeoutSec 15).data.id
    Write-Bridge 'Models on endpoint:'
    $models | ForEach-Object { Write-Bridge "  $_" }
    if ($Model -notin $models) {
        Write-Host "WARN: -Model '$Model' not in loaded list - JIT may load on first request." -ForegroundColor Yellow
    }
}
catch {
    throw "Cannot reach LM Studio at $base - start Cornerman Tier-3 first (Start-CornermanLmStudio.ps1). $($_.Exception.Message)"
}

Write-Bridge ''
Write-Bridge "Run Claude Code:  claude --model `"$Model`""
Write-Bridge 'Cursor/VS Code: add claudeCode.environmentVariables in settings (see CORNERMAN_LM_STUDIO.md)'

if ($LaunchClaude) {
    $claude = Get-Command claude -ErrorAction SilentlyContinue
    if (-not $claude) {
        throw 'claude CLI not on PATH. Install Claude Code or omit -LaunchClaude.'
    }
    Write-Bridge "Launching: claude --model $Model"
    & claude --model $Model
}
