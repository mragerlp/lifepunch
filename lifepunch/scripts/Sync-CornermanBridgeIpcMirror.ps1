<#
.SYNOPSIS
  Mirror VENGEANCE sbox-bridge-ipc to Green over SSH (SMB-free fallback).

.DESCRIPTION
  When \\VENGEANCE\SboxBridgeIpc cannot be mapped, sync IPC files to
  C:\lifepunch\cornerman\sbox-bridge-ipc-mirror on Green and point Cornerman
  sbox MCP env SBOX_BRIDGE_IPC_DIR at the mirror.

.EXAMPLE
  powershell -File lifepunch\scripts\Sync-CornermanBridgeIpcMirror.ps1
  powershell -File lifepunch\scripts\Sync-CornermanBridgeIpcMirror.ps1 -UpdateMcpJson
#>
[CmdletBinding()]
param(
    [string] $SshTarget = '',
    [string] $MirrorOnGreen = 'C:\lifepunch\cornerman\sbox-bridge-ipc-mirror',
    [switch] $UpdateMcpJson
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $Here 'Cornerman-Workflow.ps1')

if (-not $SshTarget) { $SshTarget = Get-CornermanSshTarget }
if (-not (Test-CornermanSshReady -SshTarget $SshTarget)) {
    throw "Cornerman SSH not ready ($SshTarget)"
}

$ipcDir = Join-Path $env:TEMP 'sbox-bridge-ipc'
if (-not (Test-Path -LiteralPath $ipcDir)) {
    throw "Missing VENGEANCE bridge IPC dir: $ipcDir (open s&box editor first)"
}

$mkdir = Invoke-CornermanSshExec -SshTarget $SshTarget -ScriptBlock @"
New-Item -ItemType Directory -Force -Path '$MirrorOnGreen' | Out-Null
"@ -ConnectTimeout 15
if ($mkdir.ExitCode -ne 0) { throw "Cannot create mirror on Green: $($mkdir.Output)" }

$files = @(Get-ChildItem -LiteralPath $ipcDir -File -ErrorAction SilentlyContinue)
if ($files.Count -eq 0) {
    Write-Host 'WARN: no IPC files to mirror yet (editor bridge may still be starting)' -ForegroundColor Yellow
}

$pushed = 0
foreach ($f in $files) {
    $remote = Join-Path $MirrorOnGreen $f.Name
    Push-CornermanFile -Path $remote -FileBytes ([IO.File]::ReadAllBytes($f.FullName)) -SshTarget $SshTarget | Out-Null
    $pushed++
}

Write-Host "OK mirrored $pushed file(s) -> $MirrorOnGreen on Green" -ForegroundColor Green

if ($UpdateMcpJson) {
    $cornermanLmClone = 'C:\Projects\local-llm-mcp-server'
    $editorPort = 9090
    $servers = [ordered]@{
        sbox = @{
            command = 'cmd'
            args    = @('/c', 'npx', '-y', 'sbox-mcp-server')
            env     = @{ SBOX_BRIDGE_IPC_DIR = $MirrorOnGreen }
        }
        'cornerman-lm' = @{
            command = 'node'
            args    = @((Join-Path $cornermanLmClone 'dist\index.js'))
        }
        'sbox-editor' = @{
            url = "http://127.0.0.1:$editorPort/sbox-mcp"
        }
    }
    $mcp = @{ mcpServers = $servers }
    $json = ($mcp | ConvertTo-Json -Depth 8)
    $cornermanMcp = Join-Path $env:USERPROFILE '.cursor\mcp.json'
    Push-CornermanText -Path $cornermanMcp -Text $json -SshTarget $SshTarget
    Write-Host "OK Green mcp.json sbox IPC -> $MirrorOnGreen" -ForegroundColor Green
}

$probe = Invoke-CornermanSshExec -SshTarget $SshTarget -ScriptBlock @"
`$status = Join-Path '$MirrorOnGreen' 'status.json'
`$ok = Test-Path -LiteralPath `$status
`$hb = 'missing'
if (`$ok) {
  try { `$hb = (Get-Content -LiteralPath `$status -Raw | ConvertFrom-Json).heartbeat } catch { `$hb = 'parse-fail' }
}
Write-Output "mirror_ok=`$ok heartbeat=`$hb"
"@ -ConnectTimeout 20
Write-Host "Green mirror probe: $($probe.Output -join ' ')" -ForegroundColor $(if ($probe.Output -match 'mirror_ok=True') { 'Green' } else { 'Yellow' })
