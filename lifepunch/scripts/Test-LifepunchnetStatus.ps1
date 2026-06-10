# One-shot status API test from VENGEANCE (uses server-host-watch.local.json).

param(
    [string] $ConfigPath = $(Join-Path $PSScriptRoot 'server-host-watch.local.json')
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw "Missing $ConfigPath - copy from server-host-watch.local.json.example and add token."
}

$cfg = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
$hostAddr = [string]$cfg.host
$port = if ($cfg.statusPort) { [int]$cfg.statusPort } else { 9101 }
$token = [string]$cfg.token

Write-Host "Testing http://${hostAddr}:${port}/status ..." -ForegroundColor Cyan

$rdp = (Test-NetConnection -ComputerName $hostAddr -Port 3389 -WarningAction SilentlyContinue).TcpTestSucceeded
$api = (Test-NetConnection -ComputerName $hostAddr -Port $port -WarningAction SilentlyContinue).TcpTestSucceeded
Write-Host "  RDP :3389  -> $(if ($rdp) { 'open' } else { 'closed' })"
Write-Host "  API :$port -> $(if ($api) { 'open' } else { 'closed - fix firewall on lifepunchnet' })"

if (-not $api) { exit 1 }

$headers = @{ Authorization = "Bearer $token" }
$data = Invoke-RestMethod -Uri "http://${hostAddr}:${port}/status" -Headers $headers -TimeoutSec 15
Write-Host '  API auth   -> OK' -ForegroundColor Green
Write-Host "  Uptime     -> $([math]::Round($data.boot.uptimeSeconds / 3600, 1))h"
if ($data.whisper) {
    $w = if ($data.whisper.running) { 'running' } else { 'down' }
    Write-Host "  Whisper    -> $w ($($data.whisper.detail))"
}
