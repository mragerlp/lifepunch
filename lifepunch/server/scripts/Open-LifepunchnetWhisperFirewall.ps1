# Scope lifepunchnet Whisper :9000 to trusted source IP(s) only. Run ELEVATED on lifepunchnet.
# Docker binds 0.0.0.0:9000 — Windows firewall MUST narrow who can reach STT from the internet.

param(
    [Parameter(Mandatory = $true)]
    [string] $RemoteAddress,
    [int] $Port = 9000
)

$ErrorActionPreference = 'Stop'

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
          ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if (-not $isAdmin) { throw 'Run elevated on lifepunchnet.' }

$remote = $RemoteAddress.Trim()
$ruleName = 'LifePunch-Whisper-Public'

$existing = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
if ($existing) { Remove-NetFirewallRule -DisplayName $ruleName }

# Default-deny posture on Public for the STT port (remove broad allow if present).
foreach ($legacy in @('LifePunch-Whisper', 'Docker Whisper', 'Whisper-9000')) {
    $r = Get-NetFirewallRule -DisplayName $legacy -ErrorAction SilentlyContinue
    if ($r) {
        Remove-NetFirewallRule -DisplayName $legacy
        Write-Host "Removed legacy rule: $legacy" -ForegroundColor Yellow
    }
}

New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Action Allow `
    -Protocol TCP -LocalPort $Port -Profile Public -RemoteAddress $remote | Out-Null

Write-Host "Firewall: TCP $Port Public profile -> RemoteAddress $remote only" -ForegroundColor Green
Write-Host 'Cornerman + VENGEANCE share home egress IP when on the same LAN NAT.' -ForegroundColor DarkGray
