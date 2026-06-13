<#
.SYNOPSIS
  Green off-Cursor: warm LM, archive/remove Cursor MCP config, write marker.

.DESCRIPTION
  Run ON Cornerman (or via SSH). Prevents accidental Green Cursor from loading
  the old triple-MCP stack (SMB sbox + tunnel sbox-editor + local cornerman-lm).

.EXAMPLE
  powershell -File C:\lifepunch\cornerman\Apply-CornermanOffCursor.ps1
  ssh cornerman powershell -File C:\lifepunch\cornerman\Apply-CornermanOffCursor.ps1
#>
[CmdletBinding()]
param(
    [string] $OnBoxDir = 'C:\lifepunch\cornerman',
    [string] $LmScript = 'C:\lifepunch\cornerman\Start-CornermanLmStudio.ps1'
)

$ErrorActionPreference = 'Stop'

function Write-Step($m) { Write-Host ('==> ' + $m) -ForegroundColor Cyan }

New-Item -ItemType Directory -Force -Path $OnBoxDir | Out-Null

Write-Step 'Warm LM Studio daily lane (distill + embed)'
if (Test-Path -LiteralPath $LmScript) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $LmScript -WarmModel daily -Quiet
}
else {
    Write-Host "WARN: missing $LmScript" -ForegroundColor Yellow
}

$mcpPath = Join-Path $env:USERPROFILE '.cursor\mcp.json'
if (Test-Path -LiteralPath $mcpPath) {
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $archive = Join-Path (Split-Path -Parent $mcpPath) "mcp.json.off-cursor-archived-$stamp"
    Copy-Item -LiteralPath $mcpPath -Destination $archive -Force
    Remove-Item -LiteralPath $mcpPath -Force
    Write-Step "Archived Green mcp.json -> $archive"
}
else {
    Write-Step 'No active Green mcp.json (already off-Cursor)'
}

$marker = Join-Path $OnBoxDir 'OFF_CURSOR_ACTIVE.txt'
@(
    "off-cursor applied $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
    'Green role: headless LM Studio :1234 only',
    'Cursor MCP: VENGEANCE only (Install-VengeanceMcpStack.ps1)'
) | Set-Content -LiteralPath $marker -Encoding UTF8
Write-Step "Marker -> $marker"

$hostsPath = Join-Path $OnBoxDir '..\scripts\remote-hosts.json'
$greenIp = '192.168.1.229'
$repoHosts = 'C:\Projects\lifepunch\lifepunch\scripts\remote-hosts.json'
if (Test-Path -LiteralPath $repoHosts) {
    $h = Get-Content -LiteralPath $repoHosts -Raw | ConvertFrom-Json
    if ($h.cornerman.host) { $greenIp = [string]$h.cornerman.host }
}
try {
    $models = (Invoke-RestMethod -Uri "http://${greenIp}:1234/v1/models" -TimeoutSec 8).data.id
    Write-Step "LAN API OK — $($models.Count) models at http://${greenIp}:1234"
}
catch {
    Write-Host "WARN: LAN API probe failed — $($_.Exception.Message)" -ForegroundColor Yellow
    exit 1
}

Write-Host ''
Write-Host 'Green off-Cursor complete. Close Cursor on Cornerman.' -ForegroundColor Green
