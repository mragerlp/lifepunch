<#
.SYNOPSIS
  Prepare Cornerman (Win11 Pro local AI workstation) for LAN-only remote access:
  OpenSSH Server (terminal / agent / port-tunnel) + Remote Desktop (occasional GUI).

.DESCRIPTION
  Run AS ADMINISTRATOR on Cornerman. Idempotent. Enforces the "0 leaky pipes" posture:
  every firewall rule is scoped to the LAN subnet and the Private profile only - nothing
  is opened to Public/WAN, no port-forwarding. SSH prefers key auth; pass -SshPublicKey
  with VENGEANCE's public key to authorize it. No private keys or secrets are stored here.

.PARAMETER SshPublicKey
  The CLIENT public key (e.g. contents of VENGEANCE's ~/.ssh/cornerman.pub) to authorize.
  Because the owner account is an administrator, it is written to
  %ProgramData%\ssh\administrators_authorized_keys with locked-down ACLs.

.PARAMETER Subnet
  Firewall RemoteAddress scope. Default 'LocalSubnet'. Can be a CIDR like '192.168.1.0/24'.

.PARAMETER DisablePasswordAuth
  After a key is authorized, turn OFF SSH password auth (key-only). Do NOT use until you
  have confirmed key login works, or you can lock yourself out.

.PARAMETER SkipSSH
  Do not configure OpenSSH Server.

.PARAMETER SkipRDP
  Do not configure Remote Desktop.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\Enable-CornermanRemote.ps1 -SshPublicKey "ssh-ed25519 AAAA... jared@VENGEANCE"
#>
[CmdletBinding()]
param(
    [string]$SshPublicKey,
    [string]$Subnet = 'LocalSubnet',
    [switch]$DisablePasswordAuth,
    [switch]$SkipSSH,
    [switch]$SkipRDP
)

$ErrorActionPreference = 'Stop'

function Write-Step($m) { Write-Host "==> $m" -ForegroundColor Green }
function Write-Note($m) { Write-Host "    $m" -ForegroundColor DarkGray }
function Write-Warn2($m) { Write-Host "    ! $m" -ForegroundColor Yellow }

# --- Must be admin ---------------------------------------------------------
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
          ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if (-not $isAdmin) {
    throw "Run this in an ELEVATED PowerShell (Run as administrator)."
}

# --- Network profile sanity (LAN rules only apply on Private) ---------------
Write-Step "Network profile"
$pub = Get-NetConnectionProfile | Where-Object { $_.NetworkCategory -eq 'Public' }
if ($pub) {
    foreach ($p in $pub) {
        Set-NetConnectionProfile -InterfaceIndex $p.InterfaceIndex -NetworkCategory Private
        Write-Note "Set '$($p.Name)' from Public -> Private (so LAN-scoped rules apply)."
    }
}
else { Write-Note "No Public network profiles; good." }

# ---------------------------------------------------------------------------
# SSH (OpenSSH Server)
# ---------------------------------------------------------------------------
if (-not $SkipSSH) {
    Write-Step "OpenSSH Server"
    $cap = Get-WindowsCapability -Online -Name 'OpenSSH.Server*'
    if ($cap.State -ne 'Installed') {
        Write-Note "Installing OpenSSH.Server capability..."
        Add-WindowsCapability -Online -Name $cap.Name | Out-Null
    }
    else { Write-Note "OpenSSH.Server already installed." }

    Set-Service -Name sshd -StartupType Automatic
    Start-Service sshd

    # Default shell -> PowerShell (nicer than cmd over SSH)
    $psPath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
    if (-not (Test-Path 'HKLM:\SOFTWARE\OpenSSH')) { New-Item -Path 'HKLM:\SOFTWARE\OpenSSH' -Force | Out-Null }
    New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell -Value $psPath -PropertyType String -Force | Out-Null

    # Authorize the client public key (admin account -> administrators_authorized_keys)
    if ($SshPublicKey) {
        $akFile = Join-Path $env:ProgramData 'ssh\administrators_authorized_keys'
        $existing = if (Test-Path -LiteralPath $akFile) { Get-Content -LiteralPath $akFile -Raw } else { '' }
        if ($existing -notmatch [regex]::Escape($SshPublicKey.Trim())) {
            Add-Content -LiteralPath $akFile -Value ($SshPublicKey.Trim() + "`n")
            Write-Note "Authorized key added to $akFile"
        }
        else { Write-Note "Key already authorized." }
        # Lock ACLs: only Administrators + SYSTEM, no inheritance (sshd requires this).
        icacls $akFile /inheritance:r /grant 'Administrators:F' /grant 'SYSTEM:F' | Out-Null
    }
    else {
        Write-Warn2 "No -SshPublicKey passed: password auth still on. Re-run with the key, then -DisablePasswordAuth."
    }

    # Key-only auth (only when explicitly asked AND a key is present). Disables BOTH the
    # password method and keyboard-interactive (which on Windows also accepts the password).
    if ($DisablePasswordAuth -and $SshPublicKey) {
        $cfg = Join-Path $env:ProgramData 'ssh\sshd_config'
        $c = Get-Content -LiteralPath $cfg -Raw
        $c = $c -replace '(?m)^\s*#?\s*PasswordAuthentication\s+.*$', 'PasswordAuthentication no'
        if ($c -notmatch '(?m)^\s*PasswordAuthentication\s+no\s*$') { $c += "`nPasswordAuthentication no`n" }
        $c = $c -replace '(?m)^\s*#?\s*KbdInteractiveAuthentication\s+.*$', 'KbdInteractiveAuthentication no'
        if ($c -notmatch '(?m)^\s*KbdInteractiveAuthentication\s+no\s*$') { $c += "`nKbdInteractiveAuthentication no`n" }
        $c = $c -replace '(?m)^\s*#?\s*ChallengeResponseAuthentication\s+.*$', 'ChallengeResponseAuthentication no'
        if ($c -notmatch '(?m)^\s*ChallengeResponseAuthentication\s+no\s*$') { $c += "`nChallengeResponseAuthentication no`n" }
        Set-Content -LiteralPath $cfg -Value $c -Encoding ascii
        Write-Note "Password + keyboard-interactive disabled (key-only)."
    }

    Restart-Service sshd

    # Firewall: LAN-scoped, Private only
    $rule = Get-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -ErrorAction SilentlyContinue
    if ($rule) {
        Set-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -Enabled True -Profile Private -RemoteAddress $Subnet
    }
    else {
        New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd) - LAN only' `
            -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 `
            -Profile Private -RemoteAddress $Subnet | Out-Null
    }
    Write-Note "SSH firewall scoped to $Subnet (Private profile)."
}
else { Write-Note "Skipping SSH (per -SkipSSH)." }

# ---------------------------------------------------------------------------
# RDP (Remote Desktop) - Pro feature
# ---------------------------------------------------------------------------
if (-not $SkipRDP) {
    Write-Step "Remote Desktop (NLA, LAN only)"
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections -Value 0
    # Require Network Level Authentication
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name UserAuthentication -Value 1

    Enable-NetFirewallRule -DisplayGroup 'Remote Desktop' -ErrorAction SilentlyContinue
    Set-NetFirewallRule -DisplayGroup 'Remote Desktop' -Profile Private -RemoteAddress $Subnet
    Write-Note "RDP enabled with NLA; firewall scoped to $Subnet (Private profile)."
    Write-Warn2 "Only members of Administrators / Remote Desktop Users can connect. Use a strong account password."
}
else { Write-Note "Skipping RDP (per -SkipRDP)." }

# ---------------------------------------------------------------------------
# Report connection facts for the VENGEANCE side
# ---------------------------------------------------------------------------
Write-Step "Connection facts (use these from VENGEANCE)"
Write-Host "    Hostname : $env:COMPUTERNAME" -ForegroundColor Cyan
$ips = Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' }
foreach ($ip in $ips) { Write-Host "    LAN IP   : $($ip.IPAddress)  ($($ip.InterfaceAlias))" -ForegroundColor Cyan }
$hostKey = Join-Path $env:ProgramData 'ssh\ssh_host_ed25519_key.pub'
if (Test-Path -LiteralPath $hostKey) {
    Write-Host "    SSH host key fingerprint (verify this on first connect):" -ForegroundColor Cyan
    ssh-keygen -lf $hostKey
}
Write-Host "`nFrom VENGEANCE:  ssh $env:USERNAME@<LAN-IP>   |   RDP:  mstsc /v:<LAN-IP>" -ForegroundColor Green
Write-Host "Revert: stop/disable 'sshd', set fDenyTSConnections=1, disable the firewall rules." -ForegroundColor DarkGray
