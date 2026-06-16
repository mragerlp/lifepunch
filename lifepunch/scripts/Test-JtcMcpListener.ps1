<#
.SYNOPSIS
  Probe jtc in-editor MCP on :29015/mcp and print fix steps when offline.

.EXAMPLE
  powershell -File lifepunch\scripts\Test-JtcMcpListener.ps1
  powershell -File lifepunch\scripts\Test-JtcMcpListener.ps1 -WaitSeconds 120
#>
[CmdletBinding()]
param(
    [int] $WaitSeconds = 0,
    [int] $PollMs = 2000
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $Here 'Get-SboxMcpPortConfig.ps1')

$cfg = Get-SboxMcpPortConfig
$url = $cfg.JtcUrl

function Test-JtcHttp {
    try {
        $null = Invoke-WebRequest -Uri $url -Method Post -ContentType 'application/json' `
            -Body '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"jtc-probe","version":"1"}}}' `
            -TimeoutSec 3 -UseBasicParsing
        return $true
    }
    catch { return $false }
}

function Write-FixSteps {
    Write-Host ''
    Write-Host 'sbox-jtc fix (jtc does NOT autostart like chomnr):' -ForegroundColor Yellow
    Write-Host '  1. s&box editor open on DXRP (Start-SboxDxrpEditor.ps1)' -ForegroundColor White
    Write-Host '  2. Library Manager -> confirm jtc/mcp-server is added to this project' -ForegroundColor White
    Write-Host '  3. Editor menu -> open dock "MCP Server" (smart_toy icon)' -ForegroundColor White
    Write-Host '  4. Dock header must show green Listening on http://localhost:29015/mcp' -ForegroundColor White
    Write-Host '  5. Cursor -> Reload Window -> MCP sbox-jtc green' -ForegroundColor White
    Write-Host ''
    Write-Host "Probe URL: $url" -ForegroundColor DarkGray
}

if ($WaitSeconds -gt 0) {
    $deadline = (Get-Date).AddSeconds($WaitSeconds)
    while ((Get-Date) -lt $deadline) {
        if (Test-JtcHttp) {
            Write-Host "OK jtc MCP listening at $url" -ForegroundColor Green
            exit 0
        }
        Start-Sleep -Milliseconds $PollMs
    }
}

if (Test-JtcHttp) {
    Write-Host "OK jtc MCP listening at $url" -ForegroundColor Green
    exit 0
}

Write-Host "FAIL jtc MCP not listening ($url) - Cursor will show ERR_CONNECTION_REFUSED" -ForegroundColor Red
Write-FixSteps
exit 1
