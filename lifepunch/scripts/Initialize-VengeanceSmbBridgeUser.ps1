<#
.SYNOPSIS
  One-time setup: dedicated local SMB user for headless Cornerman bridge (bypasses MSA/PIN).

.DESCRIPTION
  jared is a Microsoft Account — daily PIN login is NOT valid for SMB network auth.
  This creates local user lpbridge, saves credentials (UTF-8 no BOM), verifies net use,
  then maps the share on Cornerman headlessly.

  Run elevated on VENGEANCE once.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File lifepunch\scripts\Initialize-VengeanceSmbBridgeUser.ps1
#>
[CmdletBinding()]
param(
    [string] $BridgeUser = 'lpbridge',
    [string] $SshTarget = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $Here 'Cornerman-Workflow.ps1')

$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Run elevated (Admin PowerShell) on VENGEANCE.'
}

if (-not $SshTarget) { $SshTarget = Get-CornermanSshTarget }
$hostName = $env:COMPUTERNAME
$smbUser = "$hostName\$BridgeUser"

Write-Host ''
Write-Host 'LIFEPUNCH - SMB bridge user (headless Cornerman)' -ForegroundColor Cyan
Write-Host "Creates local user: $smbUser" -ForegroundColor DarkGray
Write-Host ''
Write-Host 'Why not jared? jared is a Microsoft Account - PIN sign-in is NOT an SMB password.' -ForegroundColor Yellow
Write-Host 'Pick ONE new password for lpbridge (you choose it; not your Windows PIN).' -ForegroundColor Yellow
Write-Host ''

$sec = Read-Host 'New lpbridge password' -AsSecureString
$confirm = Read-Host 'Confirm lpbridge password' -AsSecureString
$b1 = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec)
$b2 = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($confirm)
try {
    $p1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto($b1)
    $p2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto($b2)
    if ($p1 -ne $p2) { throw 'Passwords do not match.' }
    if ($p1.Length -lt 8) { throw 'Use at least 8 characters.' }
}
finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($b1)
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($b2)
}

$existing = Get-LocalUser -Name $BridgeUser -ErrorAction SilentlyContinue
if ($existing) {
    Set-LocalUser -Name $BridgeUser -Password $sec -PasswordNeverExpires $true
    Write-Host "Updated password for $BridgeUser" -ForegroundColor Green
}
else {
    New-LocalUser -Name $BridgeUser -Password $sec -FullName 'LifePunch SMB Bridge' -Description 'Headless Cornerman SboxBridgeIpc only' -PasswordNeverExpires | Out-Null
    Add-LocalGroupMember -Group 'Users' -Member $BridgeUser -ErrorAction SilentlyContinue
    Write-Host "Created local user $BridgeUser" -ForegroundColor Green
}

$saved = Set-VengeanceSmbCredential -User $smbUser -Password $sec
Write-Host "Saved $($saved.UserPath) + $($saved.PasswordPath)" -ForegroundColor Green

$test = Test-VengeanceSmbCredential -User $smbUser -PlainPassword $p1
if (-not $test.Ok) {
    throw "Local SMB verify failed: $($test.Detail)"
}
Write-Host "Local verify OK: $($test.Detail)" -ForegroundColor Green

if (-not (Test-CornermanSshReady -SshTarget $SshTarget)) {
    Write-Host 'Cornerman SSH not ready - credentials saved. Run Connect-CornermanBridge.ps1 when Green is up.' -ForegroundColor Yellow
    exit 0
}

Write-Host 'Mapping on Cornerman (interactive session task)...' -ForegroundColor Cyan
$null = Sync-VengeanceSmbPasswordToCornerman -SshTarget $SshTarget
& (Join-Path $Here 'Install-CornermanBridgeShareMapTask.ps1') -SshTarget $SshTarget -RunNow
if (-not (Test-CornermanBridgeShareReachable -SshTarget $SshTarget)) {
    throw 'Cornerman SMB not reachable. Log into Cornerman (RDP), then re-run this script.'
}
Write-Host ''
Write-Host 'Done. Headless command forever after this:' -ForegroundColor Cyan
Write-Host '  powershell -File lifepunch\scripts\Connect-CornermanBridge.ps1 -SkipLmWarm' -ForegroundColor Gray
