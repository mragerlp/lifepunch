<#
.SYNOPSIS
  Make Cornerman boot to desktop without a keyboard/mouse — auto-login + never-sleep + SSH/RDP always on.

.DESCRIPTION
  Run ONCE on Cornerman in ELEVATED PowerShell (one-time keyboard plug-in is OK).
  After this, drive the box from VENGEANCE via RDP (Cornerman shortcut) or SSH.

  Does NOT store the password in this repo. You enter it at runtime (or pass -PasswordSecure).

.PARAMETER UserName
  Account to auto-login. Default: current user (jared).

.PARAMETER PasswordPlain
  Optional — avoid if you can; prefer interactive prompt. Never commit this value.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\Enable-CornermanHeadless.ps1

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\Enable-CornermanRemote.ps1 -SshPublicKey "..." -DisablePasswordAuth
  powershell -ExecutionPolicy Bypass -File .\Enable-CornermanHeadless.ps1
#>
[CmdletBinding()]
param(
    [string]$UserName = $env:USERNAME,
    [string]$PasswordPlain
)

$ErrorActionPreference = 'Stop'

function Write-Step($m) { Write-Host "==> $m" -ForegroundColor Green }
function Write-Note($m) { Write-Host "    $m" -ForegroundColor DarkGray }
function Write-Warn2($m) { Write-Host "    ! $m" -ForegroundColor Yellow }

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
          ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if (-not $isAdmin) {
    throw 'Run in ELEVATED PowerShell (Run as administrator).'
}

if (-not $PasswordPlain) {
    Write-Host ''
    Write-Host 'Enter the Windows PASSWORD for auto-login (not your PIN).' -ForegroundColor Yellow
    Write-Host 'Cornerman will boot straight to desktop so VENGEANCE can RDP/SSH without local KB/mouse.' -ForegroundColor DarkGray
    $sec = Read-Host 'Password' -AsSecureString
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec)
    try { $PasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr) }
    finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
}

if ([string]::IsNullOrWhiteSpace($PasswordPlain)) {
    throw 'Password required for auto-login.'
}

$domain = $env:COMPUTERNAME

Write-Step 'Power — stay awake on AC (no sleep/hibernate)'
powercfg -change -standby-timeout-ac 0
powercfg -change -hibernate-timeout-ac 0
powercfg -change -disk-timeout-ac 0
powercfg -change -monitor-timeout-ac 30
powercfg /hibernate off
Write-Note 'Plugged-in: never sleep. Display may turn off after 30 min (OK for headless).'

Write-Step 'Auto-login at boot'
$reg = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
Set-ItemProperty -Path $reg -Name AutoAdminLogon -Value '1' -Type String
Set-ItemProperty -Path $reg -Name DefaultUserName -Value $UserName -Type String
Set-ItemProperty -Path $reg -Name DefaultDomainName -Value $domain -Type String
Set-ItemProperty -Path $reg -Name DefaultPassword -Value $PasswordPlain -Type String
Set-ItemProperty -Path $reg -Name ForceAutoLogon -Value '1' -Type String -ErrorAction SilentlyContinue
Write-Note "Auto-login enabled for $domain\$UserName"
Write-Warn2 'Password is stored in the registry (standard Windows autologon). LAN-only box; do not expose RDP to WAN.'

Write-Step 'Reduce lock-screen friction'
$pers = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization'
if (-not (Test-Path $pers)) { New-Item -Path $pers -Force | Out-Null }
Set-ItemProperty -Path $pers -Name NoLockScreen -Value 1 -Type DWord -Force
# Sign-in not required when waking display
powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_NONE CONSOLELOCK 0
powercfg /SETACTIVE SCHEME_CURRENT
Write-Note 'Lock screen suppressed; console lock timeout 0 on AC.'

Write-Step 'SSH + RDP services — start automatically'
foreach ($svc in 'sshd', 'TermService') {
    try {
        Set-Service -Name $svc -StartupType Automatic -ErrorAction Stop
        Start-Service -Name $svc -ErrorAction SilentlyContinue
        Write-Note "$svc = Automatic"
    }
    catch {
        Write-Warn2 "$svc not configured yet — run Enable-CornermanRemote.ps1 first."
    }
}

Write-Step 'Network profile — Private (LAN firewall rules)'
$pub = Get-NetConnectionProfile | Where-Object { $_.NetworkCategory -eq 'Public' }
foreach ($p in $pub) {
    Set-NetConnectionProfile -InterfaceIndex $p.InterfaceIndex -NetworkCategory Private
    Write-Note "Set '$($p.Name)' Public -> Private."
}

Write-Step 'Done'
Write-Host ''
Write-Host '  Reboot Cornerman once. It should land on desktop with no keyboard.' -ForegroundColor Cyan
Write-Host '  From VENGEANCE: Cornerman (RDP) shortcut or  ssh cornerman' -ForegroundColor Cyan
Write-Host ''
Write-Host '  To UNDO auto-login (elevated):' -ForegroundColor DarkGray
Write-Host '    Remove-ItemProperty HKLM:\...\Winlogon DefaultPassword, AutoAdminLogon' -ForegroundColor DarkGray
Write-Host ''
