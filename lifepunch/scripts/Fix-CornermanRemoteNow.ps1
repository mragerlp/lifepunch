<#
.SYNOPSIS
  On-box emergency fix when Cornerman is up locally but VENGEANCE cannot RDP/SSH.

  Run AS ADMINISTRATOR on Cornerman (physical keyboard).

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File Fix-CornermanRemoteNow.ps1
#>
[CmdletBinding()]
param(
    [string] $SshPublicKey = 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEbpoK+D7qryuZJX9rLJxkgOu8mZJuDhT2BNEaMQwBS9 jared@VENGEANCE'
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }

Write-Host ''
Write-Host '=== Cornerman remote fix ===' -ForegroundColor Cyan
Write-Host "Computer: $env:COMPUTERNAME  User: $env:USERNAME"

Write-Host ''
Write-Host 'LAN addresses:' -ForegroundColor Yellow
Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' } |
    ForEach-Object { Write-Host "  $($_.IPAddress)  ($($_.InterfaceAlias))" }

Write-Host ''
Write-Host 'Network profile:' -ForegroundColor Yellow
Get-NetConnectionProfile | ForEach-Object {
    Write-Host "  $($_.Name): $($_.NetworkCategory)"
}

$remote = Join-Path $Here 'Enable-CornermanRemote.ps1'
if (-not (Test-Path -LiteralPath $remote)) {
    throw "Missing $remote - run from repo lifepunch\scripts or copy script to USB"
}

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $remote -SshPublicKey $SshPublicKey -Subnet '192.168.1.0/24'

$boot = Join-Path $Here 'Install-CornermanHeadlessBoot.ps1'
if (Test-Path -LiteralPath $boot) {
    Write-Host ''
    Write-Host 'Headless boot tasks...' -ForegroundColor Yellow
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $boot
}

Write-Host ''
Write-Host 'From VENGEANCE try:' -ForegroundColor Green
Write-Host '  mstsc /v:<LAN-IP-above>   (account PASSWORD, not PIN)'
Write-Host '  ssh cornerman'
