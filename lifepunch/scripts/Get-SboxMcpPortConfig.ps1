<#
.SYNOPSIS
  Load canonical s&box MCP port/transport settings from lifepunch/config/sbox-mcp-ports.json.

.EXAMPLE
  . .\Get-SboxMcpPortConfig.ps1
  $cfg = Get-SboxMcpPortConfig
  $cfg.ChomnrUrl
#>
function Get-SboxMcpPortConfig {
    [CmdletBinding()]
    param(
        [string] $ConfigPath = ''
    )

    $Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
    if (-not $ConfigPath) {
        $ConfigPath = Join-Path (Split-Path -Parent $Here) 'config\sbox-mcp-ports.json'
    }

    $chomnrPort = 9090
    $chomnrPath = '/sbox-mcp'
    $ipcDir = Join-Path $env:TEMP 'sbox-bridge-ipc'

    $chomnrHost = '127.0.0.1'
    $blenderBridgePort = 8099
    $blenderBridgeStatusPath = '/status'
    $blenderBridgeHost = '127.0.0.1'

    $cornermanModes = @{}
    $cornermanModeStateFile = 'C:\lifepunch\cornerman\mcp-mode.json'
    $cornermanRedChomnrPort = 9090
    $raw = $null
    if (Test-Path -LiteralPath $ConfigPath) {
        $raw = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
        if ($raw.chomnr.port) { $chomnrPort = [int]$raw.chomnr.port }
        if ($raw.chomnr.path) { $chomnrPath = [string]$raw.chomnr.path }
        if ($raw.chomnr.host) { $chomnrHost = [string]$raw.chomnr.host }
        if ($raw.blenderBridge.port) { $blenderBridgePort = [int]$raw.blenderBridge.port }
        if ($raw.blenderBridge.statusPath) { $blenderBridgeStatusPath = [string]$raw.blenderBridge.statusPath }
        if ($raw.blenderBridge.host) { $blenderBridgeHost = [string]$raw.blenderBridge.host }
        if ($raw.cornerman) {
            if ($raw.cornerman.modeStateFile) { $cornermanModeStateFile = [string]$raw.cornerman.modeStateFile -replace '/', '\' }
            if ($raw.cornerman.red.chomnrPort) { $cornermanRedChomnrPort = [int]$raw.cornerman.red.chomnrPort }
            foreach ($prop in $raw.cornerman.modes.PSObject.Properties) {
                $cornermanModes[$prop.Name] = $prop.Value
            }
        }
    }

    $chomnrUrl = "http://${chomnrHost}:$chomnrPort$chomnrPath"
    $blenderBridgeStatusUrl = "http://${blenderBridgeHost}:$blenderBridgePort$blenderBridgeStatusPath"

    [pscustomobject]@{
        ConfigPath              = $ConfigPath
        ChomnrPort              = $chomnrPort
        ChomnrPath              = $chomnrPath
        ChomnrUrl               = $chomnrUrl
        BridgeIpcDir            = $ipcDir
        BlenderBridgePort       = $blenderBridgePort
        BlenderBridgeStatusUrl  = $blenderBridgeStatusUrl
        CornermanModeStateFile  = $cornermanModeStateFile
        CornermanModes          = $cornermanModes
        CornermanRedChomnrPort  = $cornermanRedChomnrPort
    }
}

function Test-BlenderBridgeStatus {
    [CmdletBinding()]
    param(
        [string] $StatusUrl = '',
        [int] $TimeoutSec = 4
    )

    if (-not $StatusUrl) {
        $StatusUrl = (Get-SboxMcpPortConfig).BlenderBridgeStatusUrl
    }

    try {
        $r = Invoke-RestMethod -Uri $StatusUrl -TimeoutSec $TimeoutSec
        return [bool]($r -and $r.service -eq 'BlenderBridge' -and $r.running)
    }
    catch {
        return $false
    }
}
