<#
.SYNOPSIS
  VENGEANCE: prep lifepunchnet DXRP server update for post-s&box engine bumps (26.06.10+).

.DESCRIPTION
  SSH is not open from VENGEANCE — this probes :9101 status, copies the on-box
  update one-liner to clipboard, and opens lifepunchnet RDP.

.PARAMETER IncludeOfficial
  Clipboard one-liner restarts Official (70p) after Dev.

.PARAMETER OpenRdp
  Open Desktop lifepunchnet RDP shortcut (default).

.EXAMPLE
  powershell -File lifepunch\scripts\Invoke-LifepunchnetServerUpdate.ps1
  powershell -File lifepunch\scripts\Invoke-LifepunchnetServerUpdate.ps1 -IncludeOfficial
#>
[CmdletBinding()]
param(
    [switch] $IncludeOfficial,
    [switch] $OpenRdp
)

$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
if (-not $PSBoundParameters.ContainsKey('OpenRdp')) { $OpenRdp = $true }

function Get-WatchConfig {
    $path = Join-Path $Here 'server-host-watch.local.json'
    if (-not (Test-Path -LiteralPath $path)) { return $null }
    return Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
}

Write-Host 'LIFEPUNCH - lifepunchnet server update dispatch' -ForegroundColor Cyan
Write-Host ''

$cfg = Get-WatchConfig
if ($cfg) {
    $hostAddr = [string]$cfg.host
    $port = if ($cfg.statusPort) { [int]$cfg.statusPort } else { 9101 }
    $token = [string]$cfg.token
    try {
        $data = Invoke-RestMethod -Uri "http://${hostAddr}:${port}/status" -Headers @{ Authorization = "Bearer $token" } -TimeoutSec 12
        $uptimeH = [math]::Round($data.boot.uptimeSeconds / 3600, 1)
        Write-Host "lifepunchnet: UP  hostname=$($data.boot.hostname)  uptime=${uptimeH}h" -ForegroundColor Green
        if ($data.git.head) {
            Write-Host "  git: $($data.git.head) - $($data.git.subject)" -ForegroundColor DarkGray
        }
        if ($data.alerts -and $data.alerts.Count -gt 0) {
            Write-Host '  ALERTS:' -ForegroundColor Yellow
            $data.alerts | ForEach-Object { Write-Host "    $_" -ForegroundColor Yellow }
        }
    }
    catch {
        Write-Host "lifepunchnet status probe failed: $_" -ForegroundColor Yellow
    }
}
else {
    Write-Host 'No server-host-watch.local.json — skip status probe.' -ForegroundColor Yellow
}


$oneLiner = @"
cd C:\lifepunch\lifepunch-rdp-server
git pull --rebase
cd lifepunch\server\dxrp-host\scripts
powershell -ExecutionPolicy Bypass -File .\Deploy-DxrpHostLaunchers.ps1
powershell -ExecutionPolicy Bypass -File .\Patch-LifepunchnetUlxCompile.ps1
"@

Set-Clipboard -Value $oneLiner
Write-Host ''
Write-Host 'Copied to clipboard (paste in PowerShell on lifepunchnet RDP — NOT elevated for patch):' -ForegroundColor Green
Write-Host $oneLiner -ForegroundColor White
Write-Host ''
Write-Host 'Then restart Dev: C:\S&BOX DXRP Server\server2_start.bat' -ForegroundColor Cyan
Write-Host 'Patch fixes ULX compile (LifePunchUiScale missing). Portal r7 still needs lifepunchulx upload path.' -ForegroundColor DarkGray
if (-not $IncludeOfficial) {
    Write-Host 'Tip: auto_update_all.bat restarts Official 70p after Dev smoke.' -ForegroundColor DarkGray
}
Write-Host 'Portal check: Version should read 26.06.10+ and Last Pulsed should refresh.' -ForegroundColor Cyan

if ($OpenRdp) {
    $desktop = [Environment]::GetFolderPath('Desktop')
    $lnk = Join-Path $desktop 'lifepunchnet (RDP).lnk'
    if (Test-Path -LiteralPath $lnk) {
        Start-Process -FilePath $lnk
        Write-Host 'Opened lifepunchnet (RDP).' -ForegroundColor Green
    }
    else {
        Write-Host 'No lifepunchnet (RDP).lnk - run Install-LifePunchRemoteShortcuts.ps1' -ForegroundColor Yellow
    }
}
