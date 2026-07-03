<#
.SYNOPSIS
  Switch Cornerman MCP mode (local editor vs Red-backed).

.EXAMPLE
  # On Cornerman desktop — local editor session:
  powershell -File C:\lifepunch\cornerman\Set-CornermanMcpMode.ps1 -Mode LocalEditor

  # From Red — push RedEditor wiring:
  powershell -File lifepunch\scripts\Set-CornermanMcpMode.ps1 -Mode RedEditor
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('RedEditor', 'LocalEditor', 'DualEditor')]
    [string] $Mode,
    [string] $MonorepoRoot = 'C:\Projects\lifepunch',
    [string] $VengeanceHost = 'VENGEANCE',
    [switch] $LocalOnly,
    [switch] $SkipTunnelStop
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$installScript = Join-Path $Here 'Install-CornermanIdeMcp.ps1'
if (-not (Test-Path -LiteralPath $installScript)) {
    $installScript = Join-Path (Split-Path -Parent $Here) 'scripts\Install-CornermanIdeMcp.ps1'
}
if (-not (Test-Path -LiteralPath $installScript)) {
    throw "Install-CornermanIdeMcp.ps1 not found near $Here"
}

$tunnelScript = Join-Path (Split-Path -Parent $installScript) 'Start-CornermanSboxEditorTunnel.ps1'
if (-not (Test-Path -LiteralPath $tunnelScript)) {
    $tunnelScript = 'C:\lifepunch\cornerman\Start-CornermanSboxEditorTunnel.ps1'
}

if (-not $SkipTunnelStop -and (Test-Path -LiteralPath $tunnelScript)) {
    & $tunnelScript -Stop 2>$null
    Write-Host 'Stopped Green forward editor tunnel (if any).' -ForegroundColor DarkGray
}

if ($Mode -in @('LocalEditor', 'DualEditor')) {
    Write-Host 'Local Green editor mode — ask Red to run:' -ForegroundColor Yellow
    Write-Host '  powershell -File lifepunch\scripts\Start-VengeanceEditorTunnelToCornerman.ps1 -Stop' -ForegroundColor Yellow
}

$installArgs = @{
    Mode          = $Mode
    MonorepoRoot  = $MonorepoRoot
    VengeanceHost = $VengeanceHost
}
$onCornerman = ($env:COMPUTERNAME -match 'CORNERMAN')
if ($LocalOnly -or $onCornerman) {
    $installArgs['LocalOnly'] = $true
    & $installScript @installArgs
}
else {
    & $installScript @installArgs
}

Write-Host ''
Write-Host "Cornerman MCP mode set: $Mode" -ForegroundColor Green
Write-Host 'Cursor -> Reload Window' -ForegroundColor Cyan
