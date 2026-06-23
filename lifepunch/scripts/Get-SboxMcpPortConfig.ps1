<#
.SYNOPSIS
  Load canonical s&box MCP port/transport settings from lifepunch/config/sbox-mcp-ports.json.

.EXAMPLE
  . .\Get-SboxMcpPortConfig.ps1
  $cfg = Get-SboxMcpPortConfig
  $cfg.JtcUrl
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
    $jtcPort = 29015
    $jtcPath = '/mcp'
    $ipcDir = Join-Path $env:TEMP 'sbox-bridge-ipc'

    $jtcHost = 'localhost'
    $chomnrHost = '127.0.0.1'
    $blenderBridgePort = 8099
    $blenderBridgeStatusPath = '/status'
    $blenderBridgeHost = '127.0.0.1'

    if (Test-Path -LiteralPath $ConfigPath) {
        $raw = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
        if ($raw.chomnr.port) { $chomnrPort = [int]$raw.chomnr.port }
        if ($raw.chomnr.path) { $chomnrPath = [string]$raw.chomnr.path }
        if ($raw.chomnr.host) { $chomnrHost = [string]$raw.chomnr.host }
        if ($raw.jtc.port) { $jtcPort = [int]$raw.jtc.port }
        if ($raw.jtc.path) { $jtcPath = [string]$raw.jtc.path }
        if ($raw.jtc.host) { $jtcHost = [string]$raw.jtc.host }
        if ($raw.blenderBridge.port) { $blenderBridgePort = [int]$raw.blenderBridge.port }
        if ($raw.blenderBridge.statusPath) { $blenderBridgeStatusPath = [string]$raw.blenderBridge.statusPath }
        if ($raw.blenderBridge.host) { $blenderBridgeHost = [string]$raw.blenderBridge.host }
    }

    $chomnrUrl = "http://${chomnrHost}:$chomnrPort$chomnrPath"
    $jtcUrl = "http://${jtcHost}:$jtcPort$jtcPath"
    $blenderBridgeStatusUrl = "http://${blenderBridgeHost}:$blenderBridgePort$blenderBridgeStatusPath"

    [pscustomobject]@{
        ConfigPath              = $ConfigPath
        ChomnrPort              = $chomnrPort
        ChomnrPath              = $chomnrPath
        ChomnrUrl               = $chomnrUrl
        JtcPort                 = $jtcPort
        JtcPath                 = $jtcPath
        JtcUrl                  = $jtcUrl
        BridgeIpcDir            = $ipcDir
        BlenderBridgePort       = $blenderBridgePort
        BlenderBridgeStatusUrl  = $blenderBridgeStatusUrl
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
