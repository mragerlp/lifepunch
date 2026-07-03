<#
.SYNOPSIS
  Wire Cornerman Cursor + Copilot to the Green MCP stack (mode-aware).

.DESCRIPTION
  Modes (see lifepunch/docs/CORNERMAN_MCP_MODES.md):
    RedEditor   — Green drives Red editor via tunnel; sbox IPC via \\VENGEANCE\SboxBridgeIpc
    LocalEditor — Green local editor; local bridge IPC + chomnr on :9091 (no Red tunnel)
    DualEditor  — Red + Green editors parallel; same as LocalEditor ports on Green

  Run FROM VENGEANCE:
    powershell -File lifepunch\scripts\Install-CornermanIdeMcp.ps1 -Mode RedEditor

  Run ON Cornerman:
    powershell -File lifepunch\scripts\Set-CornermanMcpMode.ps1 -Mode LocalEditor

.EXAMPLE
  powershell -File lifepunch\scripts\Install-CornermanIdeMcp.ps1 -Mode RedEditor
  powershell -File lifepunch\scripts\Install-CornermanIdeMcp.ps1 -LocalOnly -Mode LocalEditor
#>
[CmdletBinding()]
param(
    [ValidateSet('RedEditor', 'LocalEditor', 'DualEditor')]
    [string] $Mode = 'RedEditor',
    [string] $SshTarget = '',
    [string] $ShareName = 'SboxBridgeIpc',
    [string] $VengeanceHost = 'VENGEANCE',
    [string] $CornermanLmClone = 'C:\Projects\local-llm-mcp-server',
    [string] $MonorepoRoot = 'C:\Projects\lifepunch',
    [int] $EditorMcpPort = 0,
    [switch] $SkipLmClone,
    [switch] $SkipShare,
    [switch] $LocalOnly
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $Here 'Cornerman-Workflow.ps1')
. (Join-Path $Here 'Get-SboxMcpPortConfig.ps1')

function Write-Utf8NoBom {
    param([string] $Path, [string] $Text)
    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [IO.File]::WriteAllText($Path, $Text, $utf8)
}

function Get-CornermanModeLayout {
    param(
        [string] $ModeName,
        [string] $VengeanceHostName,
        [string] $Share,
        [int] $PortOverride
    )

    $cfg = Get-SboxMcpPortConfig
    $modeCfg = $cfg.CornermanModes[$ModeName]
    if (-not $modeCfg) {
        throw "Unknown Cornerman MCP mode: $ModeName"
    }

    $port = if ($PortOverride -gt 0) { $PortOverride } else { [int]$modeCfg.chomnrPort }
    $bridgeKind = [string]$modeCfg.bridgeIpc

    $ipcDir = if ($bridgeKind -eq 'local') {
        Join-Path $env:LOCALAPPDATA 'Temp\sbox-bridge-ipc'
    }
    else {
        "\\$VengeanceHostName\$Share"
    }

    [pscustomobject]@{
        Mode                   = $ModeName
        BridgeIpcDir           = $ipcDir
        ChomnrPort             = $port
        ChomnrUrl              = "http://127.0.0.1:$port/sbox-mcp"
        AllowRedReverseTunnel  = [bool]$modeCfg.allowRedReverseTunnel
        JtcPort                = $modeCfg.jtcPort
    }
}

function New-CornermanMcpJson {
    param(
        [string] $BridgeIpcDir,
        [string] $LmClone,
        [int] $Port
    )
    $servers = [ordered]@{
        sbox = @{
            command = 'cmd'
            args    = @('/c', 'npx', '-y', 'sbox-mcp-server')
            env     = @{
                SBOX_BRIDGE_IPC_DIR = $BridgeIpcDir
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

function Write-CornermanMcpModeState {
    param(
        [string] $StatePath,
        [pscustomobject] $Layout
    )
    $state = [ordered]@{
        mode                  = $Layout.Mode
        chomnrPort            = $Layout.ChomnrPort
        bridgeIpcDir          = $Layout.BridgeIpcDir
        allowRedReverseTunnel = $Layout.AllowRedReverseTunnel
        updatedAt             = (Get-Date).ToUniversalTime().ToString('o')
    }
    Write-Utf8NoBom -Path $StatePath -Text (($state | ConvertTo-Json -Depth 4) + "`n")
}

function Install-CornermanMcpConfigs {
    param(
        [string] $McpJson,
        [string] $MonorepoRootPath,
        [string] $ModeStatePath,
        [pscustomobject] $Layout
    )
    $cursorPath = Join-Path $env:USERPROFILE '.cursor\mcp.json'
    $vscodePath = Join-Path $MonorepoRootPath '.vscode\mcp.json'
    Write-Utf8NoBom -Path $cursorPath -Text $McpJson
    Write-Utf8NoBom -Path $vscodePath -Text $McpJson
    Write-CornermanMcpModeState -StatePath $ModeStatePath -Layout $Layout
    Write-Host "OK Cursor  -> $cursorPath" -ForegroundColor Green
    Write-Host "OK Copilot -> $vscodePath" -ForegroundColor Green
    Write-Host "OK mode    -> $ModeStatePath ($($Layout.Mode))" -ForegroundColor Green
}

$portCfg = Get-SboxMcpPortConfig
$layout = Get-CornermanModeLayout -ModeName $Mode -VengeanceHostName $VengeanceHost -Share $ShareName -PortOverride $EditorMcpPort
$mcpJson = New-CornermanMcpJson -BridgeIpcDir $layout.BridgeIpcDir -LmClone $CornermanLmClone -Port $layout.ChomnrPort
$modeStatePath = $portCfg.CornermanModeStateFile

if ($LocalOnly -or ($env:COMPUTERNAME -match 'CORNERMAN' -and -not $SshTarget)) {
    Write-Host "Cornerman local IDE MCP install - mode: $Mode" -ForegroundColor Cyan
    Install-CornermanMcpConfigs -McpJson $mcpJson -MonorepoRootPath $MonorepoRoot -ModeStatePath $modeStatePath -Layout $layout
    Write-Host ''
    switch ($Mode) {
        'RedEditor' {
            Write-Host 'Next: Map-CornermanBridgeShare.ps1 · editor tunnel :9090 · Red editor open' -ForegroundColor Cyan
            Write-Host '      Or ask Red: Start-VengeanceEditorTunnelToCornerman.ps1 -Background' -ForegroundColor Cyan
        }
        'LocalEditor' {
            Write-Host 'Next: Ensure Red tunnel STOPPED (Start-VengeanceEditorTunnelToCornerman.ps1 -Stop on Red)' -ForegroundColor Yellow
            Write-Host '      chomnr dock on Green -> port' $layout.ChomnrPort '-> Apply -> restart MCP server' -ForegroundColor Cyan
        }
        'DualEditor' {
            Write-Host 'Next: Red uses :9090 · Green chomnr on' $layout.ChomnrPort '- no tunnels between machines' -ForegroundColor Cyan
        }
    }
    Write-Host '      Cursor Reload Window · Copilot reopen C:\Projects\lifepunch' -ForegroundColor Cyan
    exit 0
}

if (-not $SshTarget) { $SshTarget = Get-CornermanSshTarget }
if (-not (Test-CornermanSshReady -SshTarget $SshTarget)) {
    throw "Cornerman SSH not ready ($SshTarget)"
}

foreach ($scriptName in @('Install-CornermanIdeMcp.ps1', 'Set-CornermanMcpMode.ps1')) {
    $src = Join-Path $Here $scriptName
    $dest = Join-Path 'C:\lifepunch\cornerman' $scriptName
    if (Test-Path -LiteralPath $src) {
        Push-CornermanFile -Path $dest -FileBytes ([IO.File]::ReadAllBytes($src)) -SshTarget $SshTarget | Out-Null
        Write-Host "OK on-box script -> $dest" -ForegroundColor DarkGray
    }
}

if ($Mode -eq 'RedEditor') {
    $bridgeArgs = @{
        SshTarget        = $SshTarget
        ShareName        = $ShareName
        CornermanLmClone = $CornermanLmClone
        EditorMcpPort    = $layout.ChomnrPort
    }
    if ($SkipLmClone) { $bridgeArgs['SkipLmClone'] = $true }
    if ($SkipShare) { $bridgeArgs['SkipShare'] = $true }
    & (Join-Path $Here 'Install-CornermanSboxBridgeMcp.ps1') @bridgeArgs
}

$vscodePath = Join-Path $MonorepoRoot '.vscode\mcp.json'
Push-CornermanText -Path $vscodePath -Text $mcpJson -SshTarget $SshTarget
Write-Host "OK Cornerman Copilot .vscode/mcp.json -> $vscodePath" -ForegroundColor Green

$stateJson = (@{
    mode                  = $layout.Mode
    chomnrPort            = $layout.ChomnrPort
    bridgeIpcDir          = $layout.BridgeIpcDir
    allowRedReverseTunnel = $layout.AllowRedReverseTunnel
    updatedAt             = (Get-Date).ToUniversalTime().ToString('o')
} | ConvertTo-Json -Depth 4) + "`n"
Push-CornermanText -Path $modeStatePath -Text $stateJson -SshTarget $SshTarget
Write-Host "OK mode state -> $modeStatePath ($Mode)" -ForegroundColor Green

$cursorRemote = 'C:\Users\jared\.cursor\mcp.json'
Push-CornermanText -Path $cursorRemote -Text $mcpJson -SshTarget $SshTarget
Write-Host "OK Cornerman Cursor -> $cursorRemote" -ForegroundColor Green

Write-Host ''
Write-Host "Cornerman IDE MCP done - mode: $Mode" -ForegroundColor Green
if ($Mode -eq 'RedEditor') {
    & (Join-Path $Here 'Start-VengeanceEditorTunnelToCornerman.ps1') -Stop -ErrorAction SilentlyContinue | Out-Null
    Write-Host '  Red: Start-VengeanceEditorTunnelToCornerman.ps1 -Background (after Red editor :9090 up)' -ForegroundColor Cyan
}
else {
    & (Join-Path $Here 'Start-VengeanceEditorTunnelToCornerman.ps1') -Stop
    Write-Host '  Red reverse tunnel stopped (required for local Green editor).' -ForegroundColor Yellow
    Write-Host "  Green: chomnr MCP dock -> port $($layout.ChomnrPort) -> Apply" -ForegroundColor Cyan
}
Write-Host '  Green: Cursor Reload Window -> MCP 3/3' -ForegroundColor Cyan
Write-Host '  Doc:   lifepunch/docs/CORNERMAN_MCP_MODES.md' -ForegroundColor DarkGray
