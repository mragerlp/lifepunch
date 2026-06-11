<#
.SYNOPSIS
  Wire Cornerman LM Studio into Cursor MCP (two eyes: s&box + local distill).

.DESCRIPTION
  Installs local-llm-mcp-server on VENGEANCE, points config at Cornerman :1234,
  merges cornerman-lm into %USERPROFILE%\.cursor\mcp.json alongside sbox.

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File lifepunch\scripts\Install-VengeanceCornermanLmMcp.ps1
#>
[CmdletBinding()]
param(
    [string] $CloneRoot = 'C:\Users\jared\Projects\local-llm-mcp-server',
    [string] $CornermanHost = '',
    [int] $LmPort = 1234,
    [switch] $SkipClone
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }

function Write-Utf8NoBom {
    param([string] $Path, [string] $Text)
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [IO.File]::WriteAllText($Path, $Text, $utf8)
}

if (-not $CornermanHost) {
    $hostsPath = Join-Path $Here 'remote-hosts.json'
    if (Test-Path -LiteralPath $hostsPath) {
        $hosts = Get-Content -LiteralPath $hostsPath -Raw | ConvertFrom-Json
        $CornermanHost = [string]$hosts.cornerman.host
    }
    if (-not $CornermanHost) {
        $CornermanHost = '192.168.1.229'
    }
}

function Test-LmStudio {
    param([string] $HostIp)
    try {
        $null = Invoke-RestMethod -Uri "http://${HostIp}:${LmPort}/v1/models" -TimeoutSec 6
        return $true
    }
    catch { return $false }
}

if (-not (Test-LmStudio -HostIp $CornermanHost)) {
    Write-Host "WARN: LM Studio not reachable at http://${CornermanHost}:${LmPort}" -ForegroundColor Yellow
    Write-Host '      Run: Send-CornermanWorkflow.ps1 -Action WarmDistill' -ForegroundColor DarkGray
}

if (-not $SkipClone) {
    if (-not (Test-Path -LiteralPath $CloneRoot)) {
        Write-Host "Cloning local-llm-mcp-server -> $CloneRoot" -ForegroundColor Cyan
        git clone --depth 1 https://github.com/georgepok/local-llm-mcp-server.git $CloneRoot
    }
    $tsconfig = Join-Path $CloneRoot 'tsconfig.json'
    if (Test-Path -LiteralPath $tsconfig) {
        $raw = Get-Content -LiteralPath $tsconfig -Raw
        if ($raw -notmatch 'mcp-test-client') {
            $raw = $raw -replace '"exclude": \["node_modules", "dist"\]', '"exclude": ["node_modules", "dist", "src/mcp-test-client.ts"]'
            Set-Content -LiteralPath $tsconfig -Value $raw -NoNewline
        }
    }
    Push-Location $CloneRoot
    if (-not (Test-Path -LiteralPath (Join-Path $CloneRoot 'node_modules'))) {
        npm install 2>&1 | Write-Host
    }
    npm run build 2>&1 | Write-Host
    Pop-Location
}

$entry = Join-Path $CloneRoot 'dist\index.js'
if (-not (Test-Path -LiteralPath $entry)) {
    throw "Missing $entry - build failed"
}

$config = @{
    lmStudio = @{
        baseUrl          = "http://${CornermanHost}:${LmPort}/v1"
        defaultModel     = 'qwen/qwen3.6-35b-a3b'
        timeout          = 600000
        retries          = 3
        adaptiveTimeout  = $true
    }
    models = @{
        reasoning = @{
            name             = 'Cornerman Distill'
            description      = 'Tier-3 distill on Green LM Studio'
            capabilities     = @('reasoning', 'analysis', 'summarization')
            defaultParams    = @{
                temperature = 0.3
                max_tokens  = 4096
                top_p       = 0.9
            }
        }
    }
    privacy = @{
        defaultLevel     = 'moderate'
        enableLogging    = $false
        logRetentionDays = 7
    }
    performance = @{
        cacheEnabled           = $true
        cacheTTL               = 3600
        maxConcurrentRequests  = 3
        requestTimeout         = 120000
    }
    features = @{
        enableStreamingResponses = $true
        enableMultimodalSupport  = $false
        enableCustomPrompts      = $true
        enableAnalytics          = $false
    }
}
$configPath = Join-Path $CloneRoot 'config.json'
Write-Utf8NoBom -Path $configPath -Text ($config | ConvertTo-Json -Depth 6)
Write-Host "OK config.json -> http://${CornermanHost}:${LmPort}/v1" -ForegroundColor Green

$ipcDir = Join-Path $env:TEMP 'sbox-bridge-ipc'
$logPath = 'D:\Steam\steamapps\common\sbox\logs\sbox-dev.log'
if (-not (Test-Path -LiteralPath $ipcDir)) {
    New-Item -ItemType Directory -Force -Path $ipcDir | Out-Null
}

$mcpPath = Join-Path $env:USERPROFILE '.cursor\mcp.json'
$dir = Split-Path -Parent $mcpPath
if (-not (Test-Path -LiteralPath $dir)) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

$mcp = @{ mcpServers = @{} }
if (Test-Path -LiteralPath $mcpPath) {
    $mcp = Get-Content -LiteralPath $mcpPath -Raw | ConvertFrom-Json
    if (-not $mcp.mcpServers) {
        $mcp | Add-Member -NotePropertyName mcpServers -NotePropertyValue ([pscustomobject]@{}) -Force
    }
}

# Preserve sbox if present; refresh cornerman-lm entry.
$servers = @{}
if ($mcp.mcpServers.PSObject.Properties['sbox']) {
    $servers['sbox'] = @{
        command = 'cmd'
        args    = @('/c', 'npx', '-y', 'sbox-mcp-server')
        env     = @{
            SBOX_BRIDGE_IPC_DIR = $ipcDir
            SBOX_LOG_PATH       = $logPath
        }
    }
}
$servers['cornerman-lm'] = @{
    command = 'node'
    args    = @($entry)
}

Write-Utf8NoBom -Path $mcpPath -Text (@{ mcpServers = $servers } | ConvertTo-Json -Depth 8)
Write-Host "OK $mcpPath (sbox + cornerman-lm)" -ForegroundColor Green
Write-Host ''
Write-Host 'Restart Cursor -> Settings -> MCP -> confirm sbox + cornerman-lm are green.' -ForegroundColor Cyan
Write-Host "sbox IPC: $ipcDir" -ForegroundColor DarkGray
Write-Host 'Cornerman remote bridge: Install-CornermanSboxBridgeMcp.ps1' -ForegroundColor DarkGray
Write-Host 'Two eyes: sbox (editor) + cornerman-lm (local_reasoning / distill).' -ForegroundColor Cyan
