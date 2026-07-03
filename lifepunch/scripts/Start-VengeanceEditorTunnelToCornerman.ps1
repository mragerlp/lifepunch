<#
.SYNOPSIS
  Reverse SSH tunnel: Green localhost:9090 -> VENGEANCE editor MCP (chomnr).

.DESCRIPTION
  Cornerman cannot reach VENGEANCE:22 (no inbound SSH on Red). This script runs ON
  VENGEANCE and uses the existing VENGEANCE -> Cornerman SSH channel:
    ssh -R 9090:127.0.0.1:9090 cornerman
  Green Cursor keeps http://127.0.0.1:9090/sbox-mcp unchanged.

.EXAMPLE
  powershell -File lifepunch\scripts\Start-VengeanceEditorTunnelToCornerman.ps1 -Background
  powershell -File lifepunch\scripts\Start-VengeanceEditorTunnelToCornerman.ps1 -Stop
#>
[CmdletBinding()]
param(
    [string] $SshTarget = '',
    [int] $RemotePort = 9090,
    [switch] $Background,
    [switch] $Stop,
    [switch] $Force
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $Here 'Cornerman-Workflow.ps1')
. (Join-Path $Here 'Get-SboxMcpPortConfig.ps1')

function Get-CornermanRemoteMcpMode {
    param([string] $Target)
    $cfg = Get-SboxMcpPortConfig
    $path = $cfg.CornermanModeStateFile -replace '\\', '/'
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    $raw = & ssh -o BatchMode=yes -o ConnectTimeout=8 $Target "type `"$($cfg.CornermanModeStateFile)`"" 2>$null
    $ErrorActionPreference = $prev
    if ($LASTEXITCODE -ne 0 -or -not $raw) { return $null }
    try { return ($raw -join "`n" | ConvertFrom-Json) } catch { return $null }
}

if (-not $SshTarget) { $SshTarget = Get-CornermanSshTarget }
if (-not (Test-CornermanSshReady -SshTarget $SshTarget)) {
    throw "Cornerman SSH not ready ($SshTarget)"
}

function Test-EditorMcpLocal([int]$Port) {
    try {
        $null = Invoke-WebRequest -Uri "http://127.0.0.1:$Port/sbox-mcp" -Method Post -ContentType 'application/json' `
            -Body '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"probe","version":"1"}}}' `
            -TimeoutSec 4 -UseBasicParsing
        return $true
    }
    catch { return $false }
}

$forward = "${RemotePort}:127.0.0.1:${RemotePort}"
$url = "http://127.0.0.1:${RemotePort}/sbox-mcp (on Green via reverse tunnel)"

function Get-TunnelPids {
    Get-CimInstance Win32_Process -Filter "Name = 'ssh.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -match [regex]::Escape($forward) -and $_.CommandLine -match [regex]::Escape($SshTarget) }
}

if ($Stop) {
    foreach ($p in Get-TunnelPids) {
        Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue
        Write-Host "Stopped ssh pid $($p.ProcessId)" -ForegroundColor Yellow
    }
    exit 0
}

$remoteMode = Get-CornermanRemoteMcpMode -Target $SshTarget
if ($remoteMode -and $remoteMode.mode -in @('LocalEditor', 'DualEditor') -and -not $Force) {
    throw @"
Cornerman MCP mode is '$($remoteMode.mode)' — reverse tunnel would steal localhost:$RemotePort from local chomnr.
Run Start-VengeanceEditorTunnelToCornerman.ps1 -Stop (already done?) or switch Green to RedEditor:
  powershell -File lifepunch\scripts\Set-CornermanMcpMode.ps1 -Mode RedEditor
Or override once: -Force
"@
}

$existing = Get-TunnelPids
if ($existing) {
    Write-Host "OK reverse tunnel already running (pid $($existing.ProcessId)) -> $url" -ForegroundColor Green
    exit 0
}

if (-not (Test-EditorMcpLocal -Port $RemotePort)) {
    Write-Host "WARN: VENGEANCE editor MCP not responding on :$RemotePort - open sbox editor first." -ForegroundColor Yellow
}

Write-Host "Opening reverse tunnel: Green localhost:$RemotePort -> VENGEANCE :$RemotePort ($SshTarget)" -ForegroundColor Cyan

if ($Background) {
    $args = @(
        '-o', 'BatchMode=yes'
        '-o', 'ExitOnForwardFailure=yes'
        '-o', 'ServerAliveInterval=30'
        '-o', 'ServerAliveCountMax=3'
        '-R', $forward
        '-f', '-N'
        $SshTarget
    )
    Start-Process -FilePath 'ssh.exe' -ArgumentList $args -WindowStyle Hidden
    Start-Sleep -Seconds 2
    if (-not (Get-TunnelPids)) {
        throw 'Reverse tunnel did not start. Confirm VENGEANCE -> Cornerman SSH key works.'
    }
    Write-Host "OK background reverse tunnel -> $url" -ForegroundColor Green
    exit 0
}

Write-Host 'Foreground reverse tunnel (Ctrl+C to stop).' -ForegroundColor DarkGray
& ssh.exe -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 -R $forward -N $SshTarget
