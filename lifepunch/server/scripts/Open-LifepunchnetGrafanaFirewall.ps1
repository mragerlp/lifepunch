# Allow VENGEANCE home public IP to reach Grafana :3000 on lifepunchnet.
# Run ELEVATED on lifepunchnet after Install-LifepunchnetObservability.ps1.

param(
    [Parameter(Mandatory = $true)]
    [string] $RemoteAddress,
    [int] $Port = 3000
)

$ErrorActionPreference = 'Stop'

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
          ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if (-not $isAdmin) { throw 'Run elevated on lifepunchnet.' }

$ruleName = 'LifePunch-Grafana-Public'
$existing = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
if ($existing) { Remove-NetFirewallRule -DisplayName $ruleName }

New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Action Allow `
    -Protocol TCP -LocalPort $Port -Profile Public -RemoteAddress $RemoteAddress.Trim() | Out-Null

Write-Host "Firewall: TCP $Port open on Public profile for $RemoteAddress" -ForegroundColor Green
Write-Host 'VENGEANCE: browse http://<lifepunchnet-ip>:3000 (admin password on-box secrets\grafana-admin.txt)' -ForegroundColor Cyan
