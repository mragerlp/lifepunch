<#
.SYNOPSIS
  Wire Cornerman Cursor MCP to VENGEANCE s&box Claude Bridge (shared file IPC).

.DESCRIPTION
  The Claude Bridge addon always polls %TEMP%\sbox-bridge-ipc on the machine running
  s&box (VENGEANCE). Cornerman MCP must use the SAME directory via an SMB share.

  1. Share VENGEANCE's bridge IPC folder (admin).
  2. Push Cornerman %USERPROFILE%\.cursor\mcp.json (sbox + cornerman-lm).
  3. Bootstrap local-llm-mcp-server on Cornerman (localhost LM Studio).

  Run from VENGEANCE after s&box editor is open (Start-SboxDxrpEditor.ps1).

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File lifepunch\scripts\Install-CornermanSboxBridgeMcp.ps1
#>
[CmdletBinding()]
param(
    [string] $SshTarget = '',
    [string] $ShareName = 'SboxBridgeIpc',
    [string] $CornermanLmClone = 'C:\Projects\local-llm-mcp-server',
    [switch] $SkipShare,
    [switch] $SkipLmClone
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $Here 'Cornerman-Workflow.ps1')

if (-not $SshTarget) { $SshTarget = Get-CornermanSshTarget }

function Write-Utf8NoBom {
    param([string] $Path, [string] $Text)
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [IO.File]::WriteAllText($Path, $Text, $utf8)
}

$ipcDir = Join-Path $env:TEMP 'sbox-bridge-ipc'
if (-not (Test-Path -LiteralPath $ipcDir)) {
    New-Item -ItemType Directory -Force -Path $ipcDir | Out-Null
}

$vengeanceHost = $env:COMPUTERNAME
$uncIpc = "\\$vengeanceHost\$ShareName"

$shareReady = $false
if (-not $SkipShare) {
    $existing = Get-SmbShare -Name $ShareName -ErrorAction SilentlyContinue
    if ($existing) {
        if ($existing.Path -ne $ipcDir) {
            Remove-SmbShare -Name $ShareName -Force -ErrorAction SilentlyContinue
            $existing = $null
        }
    }
    if (-not $existing) {
        Write-Host "Sharing $ipcDir as $ShareName (LAN read/write)..." -ForegroundColor Cyan
        try {
            New-SmbShare -Name $ShareName -Path $ipcDir -FullAccess 'Everyone' -Description 's&box Claude Bridge IPC (VENGEANCE editor)' -ErrorAction Stop | Out-Null
            $shareReady = $true
        }
        catch {
            Write-Host 'WARN: SMB share needs elevation - re-run this script in an elevated PowerShell once:' -ForegroundColor Yellow
            Write-Host "  net share $ShareName=`"$ipcDir`" /GRANT:Everyone,FULL" -ForegroundColor DarkGray
        }
    }
    else {
        $shareReady = $true
    }
    if ($shareReady) {
        Write-Host "OK SMB -> $uncIpc" -ForegroundColor Green
    }
}
else {
    $shareReady = Test-Path -LiteralPath $uncIpc
}

if (-not (Test-CornermanSshReady -SshTarget $SshTarget)) {
    throw "Cornerman SSH not ready ($SshTarget)"
}

if (-not $SkipLmClone) {
    $vengeanceClone = 'C:\Users\jared\Projects\local-llm-mcp-server'
    $r = Invoke-CornermanSshExec -SshTarget $SshTarget -ScriptBlock @"
if (-not (Test-Path -LiteralPath '$CornermanLmClone\.git')) {
  New-Item -ItemType Directory -Force -LiteralPath (Split-Path -Parent '$CornermanLmClone') | Out-Null
  git clone --depth 1 https://github.com/georgepok/local-llm-mcp-server.git '$CornermanLmClone'
}
Push-Location '$CornermanLmClone'
if (-not (Test-Path -LiteralPath 'node_modules')) { npm install 2>&1 }
npm run build 2>&1
Pop-Location
"@ -ConnectTimeout 180
    if ($r.ExitCode -ne 0) {
        Write-Warning "Cornerman local-llm-mcp-server build exit=$($r.ExitCode)"
        if ($r.Output) { Write-Host $r.Output }
    }
    else {
        Write-Host 'OK Cornerman local-llm-mcp-server built' -ForegroundColor Green
    }

    $lmConfig = @{
        lmStudio = @{
            baseUrl         = 'http://127.0.0.1:1234/v1'
            defaultModel    = 'qwen/qwen3.6-35b-a3b'
            timeout         = 600000
            retries         = 3
            adaptiveTimeout = $true
        }
        models = @{
            reasoning = @{
                name          = 'Cornerman Distill (local)'
                description   = 'Tier-3 distill on Green LM Studio'
                capabilities  = @('reasoning', 'analysis', 'summarization')
                defaultParams = @{
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
            cacheEnabled          = $true
            cacheTTL              = 3600
            maxConcurrentRequests = 3
            requestTimeout        = 120000
        }
        features = @{
            enableStreamingResponses = $true
            enableMultimodalSupport  = $false
            enableCustomPrompts      = $true
            enableAnalytics          = $false
        }
    }
    $cfgJson = ($lmConfig | ConvertTo-Json -Depth 6)
    Push-CornermanText -Path (Join-Path $CornermanLmClone 'config.json') -Text $cfgJson -SshTarget $SshTarget
}

$mcp = @{
    mcpServers = @{
        sbox = @{
            command = 'cmd'
            args    = @('/c', 'npx', '-y', 'sbox-mcp-server')
            env     = @{
                SBOX_BRIDGE_IPC_DIR = $uncIpc
            }
        }
        'cornerman-lm' = @{
            command = 'node'
            args    = @((Join-Path $CornermanLmClone 'dist\index.js'))
        }
    }
}
$mcpJson = ($mcp | ConvertTo-Json -Depth 8)
$cornermanMcpPath = Join-Path $env:USERPROFILE '.cursor\mcp.json'
Push-CornermanText -Path $cornermanMcpPath -Text $mcpJson -SshTarget $SshTarget
Write-Host "OK Cornerman mcp.json -> $cornermanMcpPath" -ForegroundColor Green

# Verify UNC from Cornerman
$probe = Invoke-CornermanSshExec -SshTarget $SshTarget -ScriptBlock @"
`$ok = Test-Path -LiteralPath '$uncIpc'
`$status = Join-Path '$uncIpc' 'status.json'
`$hb = if (Test-Path -LiteralPath `$status) { (Get-Content -LiteralPath `$status -Raw | ConvertFrom-Json).heartbeat } else { 'missing' }
Write-Output "ipc_share=`$ok heartbeat=`$hb"
"@ -ConnectTimeout 20
Write-Host "Cornerman probe: $($probe.Output -join ' ')" -ForegroundColor $(if ($probe.ExitCode -eq 0) { 'Green' } else { 'Yellow' })

Write-Host ''
Write-Host 'Next on Cornerman:' -ForegroundColor Cyan
Write-Host '  1. Open Cursor on Green -> Settings -> MCP -> enable sbox + cornerman-lm (both green)' -ForegroundColor Cyan
Write-Host '  2. sbox editor must stay open on VENGEANCE (Start-SboxDxrpEditor.ps1)' -ForegroundColor Cyan
Write-Host "  3. IPC share: $uncIpc  (local: $ipcDir)" -ForegroundColor DarkGray
