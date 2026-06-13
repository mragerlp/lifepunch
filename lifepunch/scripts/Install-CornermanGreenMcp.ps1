<#
.SYNOPSIS
  One-shot Green install: editor tunnel watchdog + bridge share ensure + mcp.json refresh.

.DESCRIPTION
  Run elevated ON Cornerman once (or from Red: Send-CornermanWorkflow.ps1 -Action InstallGreenMcp).

.EXAMPLE
  powershell -File C:\lifepunch\cornerman\Install-CornermanGreenMcp.ps1
  powershell -File C:\lifepunch\cornerman\Install-CornermanGreenMcp.ps1 -MapBridge
#>
[CmdletBinding()]
param(
    [switch] $MapBridge,
    [SecureString] $BridgePassword,
    [string] $OnBoxDir = 'C:\lifepunch\cornerman'
)

$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot

if ($MapBridge) {
    $map = Join-Path $OnBoxDir 'Map-CornermanBridgeShare.ps1'
    if (-not (Test-Path -LiteralPath $map)) {
        $map = Join-Path $here 'Map-CornermanBridgeShare.ps1'
    }
    if (-not (Test-Path -LiteralPath $map)) { throw "Missing Map-CornermanBridgeShare.ps1" }
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $map -Password $BridgePassword
    if ($BridgePassword) {
        $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($BridgePassword)
        try {
            $plain = [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
            cmdkey /generic:LifePunch/VengeanceSmb /user:VENGEANCE\jared /pass:$plain 2>$null | Out-Null
        }
        finally {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }
    }
}

$tunnelInstall = Join-Path $OnBoxDir 'Install-CornermanSboxEditorTunnelWatchdog.ps1'
if (-not (Test-Path -LiteralPath $tunnelInstall)) {
    $tunnelInstall = Join-Path $here 'Install-CornermanSboxEditorTunnelWatchdog.ps1'
}
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $tunnelInstall

$ensure = Join-Path $OnBoxDir 'Ensure-CornermanBridgeShare.ps1'
if (Test-Path -LiteralPath $ensure) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $ensure
}

Write-Host 'Green MCP install done. Restart Cursor on Cornerman if MCP still yellow.' -ForegroundColor Cyan
