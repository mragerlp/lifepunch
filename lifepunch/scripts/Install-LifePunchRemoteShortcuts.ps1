# Create LifePunch RDP shortcuts (Cornerman + lifepunchnet) on Desktop, Start menu, optional taskbar.
# Both shortcuts use cornerman-terminal-icon.ico (same as Talk to Vengeance on Cornerman).
#
# First run (lifepunchnet IP unknown):
#   Copy remote-hosts.local.json.example -> remote-hosts.local.json and set lifepunchnet.host
#   OR:  $env:LIFEPUNCH_LIFEPUNCHNET_HOST = '205.209.104.22'; .\Install-LifePunchRemoteShortcuts.ps1
#
# Re-run anytime to refresh shortcuts after IP changes.

param(
    [switch] $PinTaskbar,
    [switch] $DesktopOnly
)

$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..')).Path

function Read-HostConfig {
    $basePath = Join-Path $Here 'remote-hosts.json'
    $localPath = Join-Path $Here 'remote-hosts.local.json'
    if (-not (Test-Path -LiteralPath $basePath)) {
        throw "Missing $basePath"
    }
    $cfg = Get-Content -LiteralPath $basePath -Raw | ConvertFrom-Json
    if (Test-Path -LiteralPath $localPath) {
        $local = Get-Content -LiteralPath $localPath -Raw | ConvertFrom-Json
        if ($local.lifepunchnet.host) { $cfg.lifepunchnet.host = $local.lifepunchnet.host }
        elseif ($local.serverHost.host) { $cfg.lifepunchnet.host = $local.serverHost.host }
        if ($local.cornerman.host) { $cfg.cornerman.host = $local.cornerman.host }
    }
    if ($env:LIFEPUNCH_LIFEPUNCHNET_HOST) {
        $cfg.lifepunchnet.host = $env:LIFEPUNCH_LIFEPUNCHNET_HOST.Trim()
    }
    elseif ($env:LIFEPUNCH_SERVER_HOST) {
        $cfg.lifepunchnet.host = $env:LIFEPUNCH_SERVER_HOST.Trim()
    }
    if ($env:LIFEPUNCH_CORNERMAN_HOST) {
        $cfg.cornerman.host = $env:LIFEPUNCH_CORNERMAN_HOST.Trim()
    }
    return $cfg
}

function Get-IconPath([string]$iconFile, [string]$brandingFolder) {
    $path = Join-Path $RepoRoot "branding\$brandingFolder\$iconFile"
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Missing icon: $path"
    }
    return "$path,0"
}

function New-RdpFile {
    param(
        [string]$Path,
        [string]$HostAddress,
        [string]$DisplayName
    )
    $content = @"
screen mode id:i:2
use multimon:i:0
desktopwidth:i:1920
desktopheight:i:1080
session bpp:i:32
winposstr:s:0,1,0,0,1920,1080
compression:i:1
keyboardhook:i:2
audiocapturemode:i:0
videoplaybackmode:i:1
connection type:i:7
networkautodetect:i:1
bandwidthautodetect:i:1
displayconnectionbar:i:1
enableworkspacereconnect:i:0
disable wallpaper:i:0
allow font smoothing:i:1
allow desktop composition:i:1
disable full window drag:i:0
disable menu anims:i:0
disable themes:i:0
disable cursor setting:i:0
bitmapcachepersistenable:i:1
full address:s:$HostAddress
audiomode:i:0
redirectprinters:i:0
redirectcomports:i:0
redirectsmartcards:i:0
redirectclipboard:i:1
redirectposdevices:i:0
autoreconnection enabled:i:1
authentication level:i:2
prompt for credentials:i:1
negotiate security layer:i:1
remoteapplicationmode:i:0
alternate shell:s:
shell working directory:s:
gatewayhostname:s:
gatewayusagemethod:i:4
gatewaycredentialssource:i:4
gatewayprofileusagemethod:i:0
promptcredentialonce:i:0
gatewaybrokeringtype:i:0
use redirection server name:i:0
rdgiskdcproxy:i:0
kdcproxyname:s:
drivestoredirect:s:C:\;
"@
    Set-Content -LiteralPath $Path -Value $content -Encoding Unicode
    Write-Host "  RDP file: $Path ($DisplayName -> $HostAddress)" -ForegroundColor DarkGray
}

function New-RemoteShortcut {
    param(
        [string]$ShortcutPath,
        [string]$TargetHost,
        [string]$RdpFile,
        [string]$IconLocation,
        [string]$Description
    )
    $shell = New-Object -ComObject WScript.Shell
    $sc = $shell.CreateShortcut($ShortcutPath)
    $sc.TargetPath = "$env:WINDIR\System32\mstsc.exe"
    $sc.Arguments = "`"$RdpFile`""
    $sc.IconLocation = $IconLocation
    $sc.Description = $Description
    $sc.WorkingDirectory = Split-Path $RdpFile -Parent
    $sc.Save()
    Write-Host "  Shortcut: $ShortcutPath" -ForegroundColor Green
}

function Pin-ShortcutToTaskbar {
    param([string]$ShortcutPath)
    try {
        $full = (Resolve-Path -LiteralPath $ShortcutPath).Path
        $folder = Split-Path $full -Parent
        $name = Split-Path $full -Leaf
        $shell = New-Object -ComObject Shell.Application
        $item = $shell.Namespace($folder).ParseName($name)
        foreach ($verb in $item.Verbs()) {
            $label = ($verb.Name -replace [char]0x200B, '').Trim()
            if ($label -match 'Pin to Taskbar') {
                $verb.DoIt()
                Write-Host "  Pinned to taskbar: $name" -ForegroundColor Cyan
                return
            }
        }
        Write-Host "  Taskbar pin skipped (run shortcut -> right-click -> Pin to taskbar): $name" -ForegroundColor Yellow
    }
    catch {
        Write-Host "  Taskbar pin failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

$cfg = Read-HostConfig
$rdpDir = Join-Path $env:USERPROFILE 'Documents\LifePunch-RDP'
$desktop = [Environment]::GetFolderPath('Desktop')
$programs = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\LifePunch'
New-Item -ItemType Directory -Force -Path $rdpDir, $programs | Out-Null

Write-Host ''
Write-Host 'LifePunch remote desktop shortcuts' -ForegroundColor Cyan
Write-Host "  Repo icons: $RepoRoot\branding" -ForegroundColor DarkGray
Write-Host ''

$targets = @(
    @{
        Key = 'cornerman'
        Branding = 'cornerman'
        Node = $cfg.cornerman
    },
    @{
        Key = 'lifepunchnet'
        Branding = 'cornerman'
        Node = $cfg.lifepunchnet
    }
)

$created = @()
foreach ($t in $targets) {
    $node = $t.Node
    $hostAddr = [string]$node.host
    $icon = Get-IconPath -iconFile $node.icon -brandingFolder $t.Branding
    $rdpFile = Join-Path $rdpDir "$($t.Key).rdp"

    Write-Host "$($node.displayName):" -ForegroundColor White
    if ([string]::IsNullOrWhiteSpace($hostAddr)) {
        Write-Host '  Host not set - edit the .rdp file on first connect, then set remote-hosts.local.json and re-run.' -ForegroundColor Yellow
        New-RdpFile -Path $rdpFile -HostAddress 'CONFIGURE-ME' -DisplayName $node.displayName
    }
    else {
        New-RdpFile -Path $rdpFile -HostAddress $hostAddr -DisplayName $node.displayName
    }

    $places = @(
        (Join-Path $desktop "$($node.shortcutName).lnk")
    )
    if (-not $DesktopOnly) {
        $places += Join-Path $programs "$($node.shortcutName).lnk"
    }

    foreach ($place in $places) {
        New-RemoteShortcut `
            -ShortcutPath $place `
            -TargetHost $hostAddr `
            -RdpFile $rdpFile `
            -IconLocation $icon `
            -Description $node.description
        $created += $place
    }
    Write-Host ''
}

if ($PinTaskbar) {
    foreach ($place in $created) {
        if ($place -like "*$desktop*") {
            Pin-ShortcutToTaskbar -ShortcutPath $place
        }
    }
}

Write-Host 'Done.' -ForegroundColor Green
Write-Host '  Cornerman voice relay stays separate: Talk to Vengeance on the Cornerman desktop.' -ForegroundColor DarkGray
if ([string]::IsNullOrWhiteSpace([string]$cfg.lifepunchnet.host)) {
    Write-Host ''
    Write-Host '  lifepunchnet IP: copy remote-hosts.local.json.example -> remote-hosts.local.json' -ForegroundColor Yellow
    Write-Host '  Set lifepunchnet.host to your server IP, then re-run this script.' -ForegroundColor Yellow
}
