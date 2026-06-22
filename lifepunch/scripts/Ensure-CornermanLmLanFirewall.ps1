<#
.SYNOPSIS
  Allow LM Studio :1234 from LAN on Cornerman (Private profile, LocalSubnet + VENGEANCE).

.DESCRIPTION
  Idempotent. Run on Cornerman (elevated) or via SSH as admin. Does not start LM — pair with
  Start-CornermanLmStudio.ps1.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File Ensure-CornermanLmLanFirewall.ps1
#>
[CmdletBinding()]
param(
    [string[]] $ExtraRemoteHosts = @('192.168.1.236')
)

$ErrorActionPreference = 'Stop'

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
          ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if (-not $isAdmin) {
    Write-Warning 'Not elevated — firewall rule may fail. Run as administrator on Cornerman.'
}

foreach ($p in (Get-NetConnectionProfile | Where-Object { $_.NetworkCategory -eq 'Public' })) {
    Set-NetConnectionProfile -InterfaceIndex $p.InterfaceIndex -NetworkCategory Private
}

$specs = @(
    @{ Name = 'LifePunch-LMStudio-1234'; Remote = 'LocalSubnet' }
)
foreach ($host in $ExtraRemoteHosts) {
    if ($host) {
        $specs += @{ Name = "LifePunch-LMStudio-1234-$($host.Replace('.','-'))"; Remote = $host }
    }
}

foreach ($spec in $specs) {
    $existing = Get-NetFirewallRule -Name $spec.Name -ErrorAction SilentlyContinue
    if ($existing) {
        Set-NetFirewallRule -Name $spec.Name -Enabled True -Profile Any -Direction Inbound -Action Allow | Out-Null
        Write-Host "OK $($spec.Name)"
        continue
    }
    New-NetFirewallRule -DisplayName $spec.Name -Name $spec.Name `
        -Enabled True -Direction Inbound -Protocol TCP -Action Allow `
        -LocalPort 1234 -Profile Any -RemoteAddress $spec.Remote | Out-Null
    Write-Host "ADDED $($spec.Name) -> $($spec.Remote)"
}

$lms = Join-Path $env:USERPROFILE '.lmstudio\bin\lms.exe'
if (Test-Path -LiteralPath $lms) {
    $progRule = 'LifePunch-LMStudio-Program'
    if (-not (Get-NetFirewallRule -Name $progRule -ErrorAction SilentlyContinue)) {
        New-NetFirewallRule -DisplayName 'LifePunch LM Studio (lms.exe)' -Name $progRule `
            -Enabled True -Direction Inbound -Action Allow -Program $lms -Profile Any | Out-Null
        Write-Host "ADDED $progRule"
    }
}
