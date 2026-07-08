<#
.SYNOPSIS
  Wire Cursor to the LifePunch s&box MCP stack on VENGEANCE.

.DESCRIPTION
  Stack on VENGEANCE:
    sbox         — sboxskinsgg.claudebridge via npx sbox-mcp-server (file IPC, play mode / runtime)
    sbox-editor  — notpointless.chomnr_mcp (HTTP 127.0.0.1:9090/sbox-mcp, ModelDoc / compile)

  Port registry: lifepunch/config/sbox-mcp-ports.json
  Claude Bridge is file IPC only — it does not bind an HTTP port.

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File lifepunch\scripts\Install-VengeanceSboxEditorMcp.ps1
  powershell -File lifepunch\scripts\Install-VengeanceSboxEditorMcp.ps1 -Port 9091
#>
[CmdletBinding()]
param(
    [int] $Port = 0,
    [string] $ConfigPath = '',
    [switch] $SkipProbe
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $Here 'Get-SboxMcpPortConfig.ps1')

function Write-Utf8NoBom {
    param([string] $Path, [string] $Text)
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [IO.File]::WriteAllText($Path, $Text, $utf8)
}

$portCfg = Get-SboxMcpPortConfig
if ($Port -le 0) { $Port = $portCfg.ChomnrPort }

$chomnrUrl = if ($Port -eq $portCfg.ChomnrPort) { $portCfg.ChomnrUrl } else { "http://127.0.0.1:$Port$($portCfg.ChomnrPath)" }

if (-not $ConfigPath) { $ConfigPath = Join-Path $Here 'dxrp-editor.local.json' }

$dxrpGame = 'D:\Steam\steamapps\common\sbox\dxrp\game'
if (Test-Path -LiteralPath $ConfigPath) {
    $cfg = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
    if ($cfg.projectPath) {
        $dxrpGame = Split-Path -Parent ([string]$cfg.projectPath)
    }
}

$libRoot = Join-Path $dxrpGame 'Libraries'
$chomnr = Join-Path $libRoot 'notpointless.chomnr_mcp'
$bridge = Join-Path $libRoot 'sboxskinsgg.claudebridge'
$retarget = Join-Path $libRoot 'notpointless.chomnr_humanoid_retargeter'

Write-Host 'VENGEANCE s&box MCP stack check' -ForegroundColor Cyan
Write-Host "  DXRP game: $dxrpGame" -ForegroundColor DarkGray
Write-Host "  chomnr: $chomnrUrl" -ForegroundColor DarkGray
Write-Host '  bridge: file IPC (no HTTP port)' -ForegroundColor DarkGray

foreach ($pair in @(
        @{ Label = 'chomnr_mcp (editor compile)'; Path = $chomnr }
        @{ Label = 'claudebridge (runtime IPC)'; Path = $bridge }
        @{ Label = 'humanoid_retargeter (optional)'; Path = $retarget }
    )) {
    if (Test-Path -LiteralPath $pair.Path) {
        Write-Host "  OK $($pair.Label)" -ForegroundColor Green
    }
    else {
        Write-Host "  MISSING $($pair.Label) -> $($pair.Path)" -ForegroundColor Red
        if ($pair.Label -match 'chomnr|claudebridge') {
            Write-Host '    Install in s&box: Library Manager -> notpointless/chomnr_mcp + sboxskinsgg/claudebridge' -ForegroundColor Yellow
        }
    }
}

$ipcDir = $portCfg.BridgeIpcDir
$logPath = 'D:\Steam\steamapps\common\sbox\logs\sbox-dev.log'
if (-not (Test-Path -LiteralPath $ipcDir)) {
    New-Item -ItemType Directory -Force -Path $ipcDir | Out-Null
}

$mcpPath = Join-Path $env:USERPROFILE '.cursor\mcp.json'
$mcpDir = Split-Path -Parent $mcpPath
if (-not (Test-Path -LiteralPath $mcpDir)) {
    New-Item -ItemType Directory -Force -Path $mcpDir | Out-Null
}

$servers = [ordered]@{}
if (Test-Path -LiteralPath $mcpPath) {
    $existing = Get-Content -LiteralPath $mcpPath -Raw | ConvertFrom-Json
    if ($existing.mcpServers) {
        foreach ($prop in $existing.mcpServers.PSObject.Properties) {
            $servers[$prop.Name] = $prop.Value
        }
    }
}

# Runtime bridge (file IPC) — keep as sbox
$servers['sbox'] = @{
    command = 'cmd'
    args    = @('/c', 'npx', '-y', 'sbox-mcp-server')
    env     = @{
        SBOX_BRIDGE_IPC_DIR = $ipcDir
        SBOX_LOG_PATH       = $logPath
    }
}

# Editor MCP (HTTP) — chomnr; ModelDoc / compile / imported tools
$servers['sbox-editor'] = @{
    url = $chomnrUrl
}

Write-Utf8NoBom -Path $mcpPath -Text (@{ mcpServers = $servers } | ConvertTo-Json -Depth 8)
Write-Host ''
Write-Host "OK $mcpPath" -ForegroundColor Green
Write-Host '  sbox         -> Claude Bridge (runtime / play mode, file IPC)' -ForegroundColor DarkGray
Write-Host "  sbox-editor  -> $chomnrUrl" -ForegroundColor DarkGray

function Test-HttpMcp([string]$Url, [string]$Label) {
    try {
        $resp = Invoke-WebRequest -Uri $Url -Method Post -ContentType 'application/json' `
            -Body '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"lifepunch-probe","version":"1"}}}' `
            -TimeoutSec 4 -UseBasicParsing
        Write-Host "  OK $Label HTTP $($resp.StatusCode)" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  OFFLINE $Label - open DXRP editor first (Start-SboxDxrpEditor.ps1)" -ForegroundColor Yellow
        Write-Host "  $($_.Exception.Message)" -ForegroundColor DarkGray
        return $false
    }
}

if (-not $SkipProbe) {
    Write-Host ''
    Write-Host 'Probing editor MCP servers (editor must be open)...' -ForegroundColor Cyan
    Test-HttpMcp -Url $chomnrUrl -Label 'chomnr (sbox-editor)' | Out-Null

    $statusPath = Join-Path $ipcDir 'status.json'
    if (Test-Path -LiteralPath $statusPath) {
        Write-Host '  OK Claude Bridge IPC heartbeat present' -ForegroundColor Green
    }
    else {
        Write-Host '  Claude Bridge IPC idle - editor + bridge addon must be running' -ForegroundColor Yellow
    }
}

Write-Host ''
Write-Host 'Next:' -ForegroundColor Cyan
Write-Host '  1. Start-SboxDxrpEditor.ps1' -ForegroundColor White
Write-Host '  2. Editor -> chomnr MCP dock -> Approve writes' -ForegroundColor White
Write-Host '  3. Restart Cursor -> Settings -> MCP -> 3 green (sbox + sbox-editor + cornerman-lm)' -ForegroundColor White
Write-Host '  4. Doc: lifepunch/docs/SBOX_EDITOR_MCP.md' -ForegroundColor DarkGray

$cursorNameFix = Join-Path $Here 'Fix-SboxEditorMcpCursorToolNames.ps1'
if (Test-Path -LiteralPath $cursorNameFix) {
    Write-Host ''
    Write-Host 'Cursor MCP tool-name guard (60 char limit)...' -ForegroundColor Cyan
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $cursorNameFix
}
