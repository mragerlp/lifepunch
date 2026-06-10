<#
.SYNOPSIS
  Build lifepunch-ops-deploy.zip for RDP handoff and GitLab lane pulls.
#>
[CmdletBinding()]
param(
    [string] $OutputZip = ''
)

$ErrorActionPreference = 'Stop'
$pack = $PSScriptRoot
if (-not $OutputZip) {
    $OutputZip = Join-Path (Split-Path -Parent $pack) 'lifepunch-ops-deploy.zip'
}
$zipPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputZip)
$zipDir = Split-Path -Parent $zipPath
if (-not (Test-Path -LiteralPath $zipDir)) { New-Item -ItemType Directory -Force -Path $zipDir | Out-Null }

if (Test-Path -LiteralPath $zipPath) { Remove-Item -LiteralPath $zipPath -Force }
Compress-Archive -Path $pack -DestinationPath $zipPath -CompressionLevel Optimal
Write-Host "Built: $zipPath ($((Get-Item $zipPath).Length) bytes)" -ForegroundColor Cyan
