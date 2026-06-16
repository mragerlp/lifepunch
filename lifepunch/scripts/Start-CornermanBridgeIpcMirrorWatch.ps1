<#
.SYNOPSIS
  Keep Green sbox-bridge-ipc-mirror fresh over SSH (no SMB password).

.EXAMPLE
  powershell -File lifepunch\scripts\Start-CornermanBridgeIpcMirrorWatch.ps1 -Background
  powershell -File lifepunch\scripts\Start-CornermanBridgeIpcMirrorWatch.ps1 -IntervalSeconds 15
#>
[CmdletBinding()]
param(
    [int] $IntervalSeconds = 20,
    [string] $SshTarget = '',
    [switch] $Background
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$syncScript = Join-Path $Here 'Sync-CornermanBridgeIpcMirror.ps1'

if ($Background) {
    $selfPid = $PID
    $dupes = @(Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction SilentlyContinue |
        Where-Object {
            $_.ProcessId -ne $selfPid -and
            $_.CommandLine -and
            $_.CommandLine -match 'Start-CornermanBridgeIpcMirrorWatch\.ps1' -and
            $_.CommandLine -notmatch '-Background'
        })
    if ($dupes.Count -gt 0) {
        Write-Host "OK mirror watch already running (pid $($dupes[0].ProcessId))" -ForegroundColor Green
        exit 0
    }

    $logDir = Join-Path $env:LOCALAPPDATA 'LifePunch'
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null
    $args = @(
        '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $MyInvocation.MyCommand.Path,
        '-IntervalSeconds', $IntervalSeconds
    )
    if ($SshTarget) { $args += @('-SshTarget', $SshTarget) }
    Start-Process -FilePath 'powershell.exe' -ArgumentList $args `
        -WindowStyle Hidden -WorkingDirectory (Split-Path -Parent $Here)
    Write-Host "OK mirror watch started (every ${IntervalSeconds}s)" -ForegroundColor Green
    exit 0
}

while ($true) {
    try {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $syncScript -SshTarget $SshTarget 2>$null | Out-Null
    }
    catch { }
    Start-Sleep -Seconds $IntervalSeconds
}
