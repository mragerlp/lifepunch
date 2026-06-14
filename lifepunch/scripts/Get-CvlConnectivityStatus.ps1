<#
.SYNOPSIS
  Probe MCP + Tier-3 connectivity on VENGEANCE and Cornerman. Emits one JSON line.

.EXAMPLE
  powershell -File Get-CvlConnectivityStatus.ps1
  powershell -File Get-CvlConnectivityStatus.ps1 -Pretty
#>
[CmdletBinding()]
param(
    [switch] $Pretty,
    [string] $SshTarget = '',
    [int] $EditorPort = 9090
)

$ErrorActionPreference = 'SilentlyContinue'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $Here 'Cornerman-Workflow.ps1')

if (-not $SshTarget) { $SshTarget = Get-CornermanSshTarget }

$cornermanIp = '192.168.1.229'
$hostsPath = Join-Path $Here 'remote-hosts.json'
if (Test-Path -LiteralPath $hostsPath) {
    $h = Get-Content -LiteralPath $hostsPath -Raw | ConvertFrom-Json
    if ($h.cornerman.host) { $cornermanIp = [string]$h.cornerman.host }
}

function Test-EditorMcp([int]$Port) {
    try {
        $null = Invoke-WebRequest -Uri "http://127.0.0.1:$Port/sbox-mcp" -Method Post -ContentType 'application/json' `
            -Body '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"probe","version":"1"}}}' `
            -TimeoutSec 4 -UseBasicParsing
        return $true
    }
    catch { return $false }
}

function Test-BridgeIpc {
    $statusPath = Join-Path $env:TEMP 'sbox-bridge-ipc\status.json'
    if (-not (Test-Path -LiteralPath $statusPath)) { return $false }
    try {
        $st = Get-Content -LiteralPath $statusPath -Raw | ConvertFrom-Json
        if (-not $st.heartbeat) { return $false }
        $hb = [datetime]::Parse(
            [string]$st.heartbeat,
            $null,
            [System.Globalization.DateTimeStyles]::RoundtripKind
        ).ToUniversalTime()
        return ((Get-Date).ToUniversalTime() - $hb).TotalSeconds -lt 120
    }
    catch { return $false }
}

function Get-RemoteHealth([string]$ScriptName, [string]$Target) {
    $onBox = "C:\lifepunch\cornerman\$ScriptName"
    $r = Invoke-CornermanSshExec -SshTarget $Target -ScriptBlock @"
if (Test-Path -LiteralPath '$onBox') {
  & powershell -NoProfile -ExecutionPolicy Bypass -File '$onBox'
}
"@ -ConnectTimeout 35
    if ($r.ExitCode -ne 0) { return $null }
    $jsonLine = ($r.Output -split "`n" | Where-Object { $_.Trim().StartsWith('{') } | Select-Object -Last 1)
    if (-not $jsonLine) { return $null }
    return ($jsonLine | ConvertFrom-Json)
}

$mcpPath = Join-Path $env:USERPROFILE '.cursor\mcp.json'
$mcpKeys = @()
if (Test-Path -LiteralPath $mcpPath) {
    $mj = Get-Content -LiteralPath $mcpPath -Raw | ConvertFrom-Json
    if ($mj.mcpServers) { $mcpKeys = @($mj.mcpServers.PSObject.Properties.Name) }
}

$sshOk = Test-CornermanSshReady -SshTarget $SshTarget
$green = $null
if ($sshOk) { $green = Get-RemoteHealth 'Get-CornermanHealthProbe.ps1' $SshTarget }

$tier3Api = $false
try {
    $null = Invoke-RestMethod -Uri "http://${cornermanIp}:1234/v1/models" -TimeoutSec 6
    $tier3Api = $true
}
catch { }

$down = [System.Collections.Generic.List[string]]::new()
$checks = [ordered]@{}

$checks['vengeance.sboxBridge'] = Test-BridgeIpc
$checks['vengeance.sboxEditor'] = Test-EditorMcp -Port $EditorPort
$checks['vengeance.mcpDual'] = ('sbox' -in $mcpKeys) -and ('sbox-editor' -in $mcpKeys)

$checks['cornerman.ssh'] = $sshOk
$checks['cornerman.tier3Api'] = $tier3Api
$checks['cornerman.tier3Serve'] = [bool]($green -and $green.lmServeOk)
$checks['cornerman.lmWatchdog'] = [bool]($green -and $green.lmWatchdogOk)
$checks['cornerman.smbBridge'] = [bool]($green -and $green.smbShareOk)
$checks['cornerman.editorTunnel'] = [bool]($green -and $green.tunnel9090Ok)
$checks['cornerman.mcpTriple'] = [bool]($green -and $green.mcpTripleOk)

$labels = @{
    'vengeance.sboxBridge'    = 'VENGEANCE sbox (Claude Bridge)'
    'vengeance.sboxEditor'    = 'VENGEANCE sbox-editor (chomnr)'
    'vengeance.mcpDual'       = 'VENGEANCE mcp.json dual stack'
    'cornerman.ssh'           = 'Cornerman SSH'
    'cornerman.tier3Api'      = 'Cornerman Tier-3 API :1234'
    'cornerman.tier3Serve'    = 'Cornerman Tier-3 VRAM serve'
    'cornerman.lmWatchdog'    = 'Cornerman LM watchdog'
    'cornerman.smbBridge'     = 'Cornerman SMB sbox bridge'
    'cornerman.editorTunnel'  = 'Cornerman editor tunnel :9090'
    'cornerman.mcpTriple'     = 'Cornerman mcp.json triple'
}

foreach ($kv in $checks.GetEnumerator()) {
    if (-not $kv.Value) { $down.Add($labels[$kv.Key]) }
}

$payload = [ordered]@{
    ts        = (Get-Date).ToUniversalTime().ToString('o')
    node      = $env:COMPUTERNAME
    checks    = $checks
    down      = @($down)
    allOk     = ($down.Count -eq 0)
    cornerman = $green
}

if ($Pretty) { $payload | ConvertTo-Json -Depth 6 } else { $payload | ConvertTo-Json -Compress -Depth 6 }
