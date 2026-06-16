<#
.SYNOPSIS
  Enable inbound SSH on VENGEANCE so Cornerman can forward localhost:9090 -> editor MCP.

.DESCRIPTION
  Green's sbox-editor MCP uses an SSH tunnel (Start-CornermanSboxEditorTunnel.ps1).
  Cornerman -> VENGEANCE:22 must work with key auth. Run elevated once on VENGEANCE.

.PARAMETER CornermanPublicKey
  Contents of Cornerman's id_ed25519.pub. If omitted, fetches via SSH (cornerman host).

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File lifepunch\scripts\Enable-VengeanceSshTunnel.ps1
#>
[CmdletBinding()]
param(
    [string] $CornermanPublicKey = '',
    [string] $Subnet = 'LocalSubnet',
    [string] $SshTarget = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $Here 'Cornerman-Workflow.ps1')

function Write-Step($m) { Write-Host "==> $m" -ForegroundColor Green }
function Write-Note($m) { Write-Host "    $m" -ForegroundColor DarkGray }

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
          ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if (-not $isAdmin) {
    throw 'Run in ELEVATED PowerShell (Run as administrator) on VENGEANCE.'
}

if (-not $CornermanPublicKey) {
    if (-not $SshTarget) { $SshTarget = Get-CornermanSshTarget }
    if (-not (Test-CornermanSshReady -SshTarget $SshTarget)) {
        throw "Cannot fetch Cornerman public key — SSH not ready ($SshTarget). Pass -CornermanPublicKey."
    }
    $r = Invoke-CornermanSshExec -SshTarget $SshTarget -ScriptBlock @'
$pub = Join-Path $env:USERPROFILE '.ssh\id_ed25519.pub'
if (-not (Test-Path -LiteralPath $pub)) { throw "Missing $pub" }
Get-Content -LiteralPath $pub -Raw
'@ -ConnectTimeout 20
    if ($r.ExitCode -ne 0 -or -not $r.Output) {
        throw "Failed to read Cornerman public key: $($r.Output)"
    }
    $CornermanPublicKey = ($r.Output | Where-Object { $_ -match '^ssh-' } | Select-Object -First 1).Trim()
}

if (-not $CornermanPublicKey) { throw 'CornermanPublicKey is empty.' }

Write-Step 'OpenSSH Server (inbound for Green editor tunnel)'
$cap = Get-WindowsCapability -Online -Name 'OpenSSH.Server*'
if ($cap.State -ne 'Installed') {
    Write-Note 'Installing OpenSSH.Server...'
    Add-WindowsCapability -Online -Name $cap.Name | Out-Null
}
else { Write-Note 'OpenSSH.Server already installed.' }

Set-Service -Name sshd -StartupType Automatic
Start-Service sshd

$user = $env:USERNAME
$sshDir = Join-Path $env:USERPROFILE '.ssh'
$authFile = Join-Path $sshDir 'authorized_keys'
New-Item -ItemType Directory -Force -Path $sshDir | Out-Null
$existing = ''
if (Test-Path -LiteralPath $authFile) {
    $existing = Get-Content -LiteralPath $authFile -Raw
}
if ($existing -notmatch [regex]::Escape($CornermanPublicKey.Split()[1])) {
    Add-Content -LiteralPath $authFile -Value $CornermanPublicKey.Trim()
    Write-Note "Appended Cornerman key to $authFile"
}
else {
    Write-Note 'Cornerman key already in authorized_keys'
}

$isUserAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
              ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if ($isUserAdmin) {
    $akFile = Join-Path $env:ProgramData 'ssh\administrators_authorized_keys'
    $akExisting = ''
    if (Test-Path -LiteralPath $akFile) { $akExisting = Get-Content -LiteralPath $akFile -Raw }
    if ($akExisting -notmatch [regex]::Escape($CornermanPublicKey.Split()[1])) {
        Add-Content -LiteralPath $akFile -Value $CornermanPublicKey.Trim()
        icacls $akFile /inheritance:r /grant 'Administrators:F' 'SYSTEM:F' | Out-Null
        Write-Note "Appended Cornerman key to administrators_authorized_keys"
    }
}

$rule = Get-NetFirewallRule -DisplayName 'OpenSSH Server (sshd) - LAN only' -ErrorAction SilentlyContinue
if (-not $rule) {
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP-Vengeance' `
        -DisplayName 'OpenSSH Server (sshd) - LAN only' `
        -Enabled True -Direction Inbound -Protocol TCP -LocalPort 22 `
        -RemoteAddress $Subnet -Profile Private | Out-Null
    Write-Note "Firewall: TCP/22 inbound ($Subnet, Private profile)"
}
else {
    Write-Note 'Firewall rule already present'
}

Restart-Service sshd
Write-Host ''
Write-Host 'VENGEANCE SSH ready for Cornerman editor tunnel.' -ForegroundColor Green
Write-Host 'On Green: schtasks /Run /TN LifePunch-Cornerman-SboxEditor-Tunnel' -ForegroundColor Cyan
