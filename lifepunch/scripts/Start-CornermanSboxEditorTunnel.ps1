<#
.SYNOPSIS
  SSH local forward: Cornerman localhost:9090 -> VENGEANCE editor MCP (chomnr).

.DESCRIPTION
  chomnr_mcp binds 127.0.0.1 on VENGEANCE only. Cornerman uses the same Cursor URL
  (http://127.0.0.1:9090/sbox-mcp) after this tunnel is up.

  Requires:
    - VENGEANCE s&box editor open (chomnr MCP autostart)
    - SSH from Cornerman -> VENGEANCE (key-based auth for -Background)

  Run ON Cornerman (desktop or: ssh -t cornerman powershell -File ...).

.EXAMPLE
  powershell -File C:\lifepunch\cornerman\Start-CornermanSboxEditorTunnel.ps1
  powershell -File C:\lifepunch\cornerman\Start-CornermanSboxEditorTunnel.ps1 -Background
#>
[CmdletBinding()]
param(
    [string] $VengeanceHost = '192.168.1.236',
    [string] $SshUser = 'jared',
    [int] $LocalPort = 9090,
    [int] $RemotePort = 9090,
    [switch] $Background,
    [switch] $Stop
)

$ErrorActionPreference = 'Stop'
$forward = "${LocalPort}:127.0.0.1:${RemotePort}"
$sshTarget = "${SshUser}@${VengeanceHost}"
$url = "http://127.0.0.1:${LocalPort}/sbox-mcp"

function Get-TunnelPids {
    Get-CimInstance Win32_Process -Filter "Name = 'ssh.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -match [regex]::Escape($forward) }
}

if ($Stop) {
    $pids = Get-TunnelPids
    foreach ($p in $pids) {
        Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue
        Write-Host "Stopped ssh pid $($p.ProcessId)" -ForegroundColor Yellow
    }
    exit 0
}

$existing = Get-TunnelPids
if ($existing) {
    Write-Host "OK tunnel already running (pid $($existing.ProcessId)) -> $url" -ForegroundColor Green
    exit 0
}

$listener = Get-NetTCPConnection -LocalPort $LocalPort -State Listen -ErrorAction SilentlyContinue |
    Where-Object { $_.OwningProcess -ne 0 }
if ($listener) {
    Write-Host "WARN: port $LocalPort already in use (pid $($listener.OwningProcess)). Stop other service or change chomnr port." -ForegroundColor Yellow
    exit 1
}

Write-Host "Opening SSH tunnel: localhost:$LocalPort -> VENGEANCE:$RemotePort ($sshTarget)" -ForegroundColor Cyan

if ($Background) {
    $args = @('-o', 'BatchMode=yes', '-o', 'ExitOnForwardFailure=yes', '-N', '-L', $forward, $sshTarget)
    Start-Process -FilePath 'ssh' -ArgumentList $args -WindowStyle Hidden
    Start-Sleep -Seconds 2
    if (-not (Get-TunnelPids)) {
        Write-Host 'FAIL: tunnel did not start. Set up SSH key Cornerman -> VENGEANCE, or run without -Background for password prompt.' -ForegroundColor Red
        exit 1
    }
    Write-Host "OK background tunnel -> $url" -ForegroundColor Green
    exit 0
}

Write-Host 'Foreground tunnel (Ctrl+C to stop). For Cursor, prefer -Background in a desktop session.' -ForegroundColor DarkGray
& ssh -o ExitOnForwardFailure=yes -N -L $forward $sshTarget
