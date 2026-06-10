<#
.SYNOPSIS
  Harden CVL signal ports on lifepunchnet before high-value hub data ships.

.DESCRIPTION
  Scopes :9000 / :9101 / :9102 to VENGEANCE home public IP (same NAT as Cornerman STT).
  Removes unscoped Public allow rules where possible. Run ELEVATED once per IP change.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\Secure-LifepunchnetCvlPorts.ps1 -RemoteAddress 71.250.46.224
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $RemoteAddress,
    [int] $WhisperPort = 9000,
    [int] $StatusPort = 9101,
    [int] $SessionPort = 9102
)

$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
          ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if (-not $isAdmin) { throw 'Run elevated on lifepunchnet.' }

Write-Host ''
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host '  SECURE CVL SIGNAL PORTS (lifepunchnet)' -ForegroundColor Cyan
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host ''

& (Join-Path $here 'Open-LifepunchnetWhisperFirewall.ps1') -RemoteAddress $RemoteAddress -Port $WhisperPort
& (Join-Path $here 'Open-LifepunchnetStatusFirewall.ps1') -RemoteAddress $RemoteAddress -Port $StatusPort
& (Join-Path $here 'Open-LifepunchnetSessionFirewall.ps1') -RemoteAddress $RemoteAddress -Port $SessionPort

$guard = Join-Path $here 'ServerHost-CvlSignalGuard.ps1'
if (Test-Path -LiteralPath $guard) {
    . $guard
    Write-CvlAllowlistFile -RemoteAddress $RemoteAddress
    Write-Host 'HTTP allowlist: C:\lifepunch\status\hub-ingest-allowlist.txt' -ForegroundColor DarkGray
    Write-Host 'Restart LifePunch-SessionHub + LifePunch-ServerHost-StatusServer tasks to apply.' -ForegroundColor Yellow
}

# Drop duplicate/unscoped hub rule from installer when RemoteAddress was omitted earlier.
foreach ($name in @('LifePunch-SessionHub', 'LifePunch-ServerHost-Status')) {
    $rule = Get-NetFirewallRule -DisplayName $name -ErrorAction SilentlyContinue
    if (-not $rule) { continue }
    $af = Get-NetFirewallAddressFilter -AssociatedNetFirewallRule $rule -ErrorAction SilentlyContinue
    $remote = if ($af) { [string]$af.RemoteAddress } else { '' }
    if ($remote -eq '*' -or [string]::IsNullOrWhiteSpace($remote)) {
        Remove-NetFirewallRule -DisplayName $name
        Write-Host "Removed unscoped rule: $name" -ForegroundColor Yellow
    }
}

Write-Host ''
Write-Host 'CVL ports scoped. Re-run when home public IP changes.' -ForegroundColor Green
Write-Host 'VENGEANCE: Test-CvlSecurity.ps1 before Invoke-CvlUniversal / hub ingest.' -ForegroundColor Cyan
Write-Host ''
