# Allow VENGEANCE (owner home IP) to reach lifepunchnet session hub :9102.
# Run ELEVATED on lifepunchnet after Install-LifepunchnetSessionHub.ps1.

param(
    [Parameter(Mandatory = $true)]
    [string] $RemoteAddress,
    [int] $Port = 9102
)

$ErrorActionPreference = 'Stop'

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
          ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if (-not $isAdmin) { throw 'Run elevated on lifepunchnet.' }

$ruleName = 'LifePunch-SessionHub-Public'
$existing = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
if ($existing) {
    Remove-NetFirewallRule -DisplayName $ruleName
}

New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Action Allow `
    -Protocol TCP -LocalPort $Port -Profile Public -RemoteAddress $RemoteAddress.Trim() | Out-Null

Write-Host "Firewall: TCP $Port open on Public profile for $RemoteAddress" -ForegroundColor Green
Write-Host 'From VENGEANCE: start-session-sync.ps1 or curl /status with Bearer token.' -ForegroundColor Cyan
