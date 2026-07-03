<#
.SYNOPSIS
  Wire Cornerman Cursor + Copilot (VS Code) to the Green MCP triple-stack.

.DESCRIPTION
  Writes the same 3-server MCP config to BOTH:
    - %USERPROFILE%\.cursor\mcp.json          (Cursor on Green)
    - C:\Projects\lifepunch\.vscode\mcp.json  (GitHub Copilot workspace MCP)

  Run FROM VENGEANCE (pushes over SSH):
    powershell -File lifepunch\scripts\Install-CornermanIdeMcp.ps1

  Run ON Cornerman desktop (local rewrite):
    powershell -File C:\lifepunch\cornerman\Install-CornermanIdeMcp.ps1

  Prereq on Green: Map-CornermanBridgeShare.ps1 + editor tunnel :9090 + Red editor open.

.EXAMPLE
  powershell -File lifepunch\scripts\Install-CornermanIdeMcp.ps1
  powershell -File lifepunch\scripts\Install-CornermanIdeMcp.ps1 -SkipLmClone
#>
[CmdletBinding()]
param(
    [string] $SshTarget = '',
    [string] $ShareName = 'SboxBridgeIpc',
    [string] $CornermanLmClone = 'C:\Projects\local-llm-mcp-server',
    [string] $MonorepoRoot = 'C:\Projects\lifepunch',
    [int] $EditorMcpPort = 9090,
    [switch] $SkipLmClone,
    [switch] $SkipShare,
    [switch] $LocalOnly
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $Here 'Cornerman-Workflow.ps1')

function Write-Utf8NoBom {
    param([string] $Path, [string] $Text)
    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [IO.File]::WriteAllText($Path, $Text, $utf8)
}

function New-CornermanGreenMcpJson {
    param(
        [string] $UncIpc,
        [string] $LmClone,
        [int] $Port
    )
    $servers = [ordered]@{
        sbox = @{
            command = 'cmd'
            args    = @('/c', 'npx', '-y', 'sbox-mcp-server')
            env     = @{
                SBOX_BRIDGE_IPC_DIR = $UncIpc
            }
        }
        'sbox-editor' = @{
            url = "http://127.0.0.1:$Port/sbox-mcp"
        }
        'cornerman-lm' = @{
            command = 'node'
            args    = @((Join-Path $LmClone 'dist\index.js'))
        }
    }
    return (@{ mcpServers = $servers } | ConvertTo-Json -Depth 8)
}

$vengeanceHost = $env:COMPUTERNAME
$uncIpc = "\\$vengeanceHost\$ShareName"

if ($LocalOnly -or ($env:COMPUTERNAME -match 'CORNERMAN' -and -not $SshTarget)) {
    Write-Host 'Cornerman local IDE MCP install' -ForegroundColor Cyan
    $mcpJson = New-CornermanGreenMcpJson -UncIpc $uncIpc -LmClone $CornermanLmClone -Port $EditorMcpPort
    $cursorPath = Join-Path $env:USERPROFILE '.cursor\mcp.json'
    $vscodePath = Join-Path $MonorepoRoot '.vscode\mcp.json'
    Write-Utf8NoBom -Path $cursorPath -Text $mcpJson
    Write-Utf8NoBom -Path $vscodePath -Text $mcpJson
    Write-Host "OK Cursor  -> $cursorPath" -ForegroundColor Green
    Write-Host "OK Copilot -> $vscodePath" -ForegroundColor Green
    Write-Host ''
    Write-Host 'Next: Map-CornermanBridgeShare.ps1 · Start-CornermanSboxEditorTunnel.ps1 -Background' -ForegroundColor Cyan
    Write-Host '      Cursor Reload Window · reopen C:\Projects\lifepunch in VS Code for Copilot MCP' -ForegroundColor Cyan
    exit 0
}

if (-not $SshTarget) { $SshTarget = Get-CornermanSshTarget }
if (-not (Test-CornermanSshReady -SshTarget $SshTarget)) {
    throw "Cornerman SSH not ready ($SshTarget)"
}

# Reuse bridge + LM wiring from the existing installer, then add Copilot workspace path.
$bridgeArgs = @{
    SshTarget      = $SshTarget
    ShareName      = $ShareName
    CornermanLmClone = $CornermanLmClone
    EditorMcpPort  = $EditorMcpPort
}
if ($SkipLmClone) { $bridgeArgs['SkipLmClone'] = $true }
if ($SkipShare) { $bridgeArgs['SkipShare'] = $true }
& (Join-Path $Here 'Install-CornermanSboxBridgeMcp.ps1') @bridgeArgs

$mcpJson = New-CornermanGreenMcpJson -UncIpc $uncIpc -LmClone $CornermanLmClone -Port $EditorMcpPort
$vscodePath = Join-Path $MonorepoRoot '.vscode\mcp.json'
Push-CornermanText -Path $vscodePath -Text $mcpJson -SshTarget $SshTarget
Write-Host "OK Cornerman Copilot .vscode/mcp.json -> $vscodePath" -ForegroundColor Green

# On-box copy for local re-run without Red SSH.
$onBox = Join-Path $Here 'Install-CornermanIdeMcp.ps1'
$onBoxDest = 'C:\lifepunch\cornerman\Install-CornermanIdeMcp.ps1'
if (Test-Path -LiteralPath $onBox) {
    Push-CornermanFile -Path $onBoxDest -FileBytes ([IO.File]::ReadAllBytes($onBox)) -SshTarget $SshTarget | Out-Null
    Write-Host "OK on-box script -> $onBoxDest" -ForegroundColor DarkGray
}

Write-Host ''
Write-Host 'Cornerman IDE MCP done (Cursor + Copilot).' -ForegroundColor Green
Write-Host '  Cursor:  Reload Window -> MCP 3/3 (sbox, sbox-editor, cornerman-lm)' -ForegroundColor Cyan
Write-Host '  Copilot: Open folder C:\Projects\lifepunch in VS Code -> MCP tools on chat' -ForegroundColor Cyan
Write-Host '  Paste:   lifepunch/docs/handoff/CORNERMAN_MCP_SETUP_PASTE.txt' -ForegroundColor DarkGray
