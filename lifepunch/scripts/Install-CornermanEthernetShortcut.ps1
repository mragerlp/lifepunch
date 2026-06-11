# Desktop\Launch shortcut: Cornerman Ethernet RDP (pinned LAN IP after cable plug-in).
#
#   powershell -ExecutionPolicy Bypass -File Install-CornermanEthernetShortcut.ps1
#
# Override IP: $env:LIFEPUNCH_CORNERMAN_ETHERNET_HOST = '192.168.1.229'

param(
    [string] $HostAddress = '',
    [string] $LaunchFolder = ''
)

$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
. (Join-Path $Here 'LifePunch-ShortcutIcons.ps1')

$basePath = Join-Path $Here 'remote-hosts.json'
$localPath = Join-Path $Here 'remote-hosts.local.json'
if (-not (Test-Path -LiteralPath $basePath)) { throw "Missing $basePath" }

$cfg = Get-Content -LiteralPath $basePath -Raw | ConvertFrom-Json
$node = $cfg.cornermanEthernet
if (-not $node) { throw 'remote-hosts.json missing cornermanEthernet entry' }

if (Test-Path -LiteralPath $localPath) {
    $local = Get-Content -LiteralPath $localPath -Raw | ConvertFrom-Json
    if ($local.cornermanEthernet.host) { $node.host = $local.cornermanEthernet.host }
    elseif ($local.cornerman.host) { $node.host = $local.cornerman.host }
}

if ($env:LIFEPUNCH_CORNERMAN_ETHERNET_HOST) {
    $HostAddress = $env:LIFEPUNCH_CORNERMAN_ETHERNET_HOST.Trim()
}
elseif ($env:LIFEPUNCH_CORNERMAN_HOST) {
    $HostAddress = $env:LIFEPUNCH_CORNERMAN_HOST.Trim()
}
elseif (-not $HostAddress) {
    $HostAddress = [string]$node.host
}

if ([string]::IsNullOrWhiteSpace($HostAddress)) {
    throw 'Cornerman ethernet host not set — edit remote-hosts.json or set LIFEPUNCH_CORNERMAN_ETHERNET_HOST'
}

if (-not $LaunchFolder) {
    $LaunchFolder = Join-Path ([Environment]::GetFolderPath('Desktop')) 'Launch'
}

$rdpDir = Join-Path $env:USERPROFILE 'Documents\LifePunch-RDP'
$programs = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\LifePunch'
$icon = Get-LifePunchShortcutIconLocation -Tier cornerman
$rdpFile = Join-Path $rdpDir 'cornerman-ethernet.rdp'
$shortcutName = [string]$node.shortcutName

New-Item -ItemType Directory -Force -Path $rdpDir, $LaunchFolder, $programs | Out-Null

$rdpContent = @"
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
Set-Content -LiteralPath $rdpFile -Value $rdpContent -Encoding Unicode

$shell = New-Object -ComObject WScript.Shell
$places = @(
    (Join-Path $LaunchFolder "$shortcutName.lnk"),
    (Join-Path $programs "$shortcutName.lnk")
)

Write-Host ''
Write-Host 'Cornerman Ethernet RDP shortcut' -ForegroundColor Cyan
Write-Host "  Host: $HostAddress" -ForegroundColor DarkGray
Write-Host "  RDP:  $rdpFile" -ForegroundColor DarkGray
Write-Host ''

foreach ($place in $places) {
    if (Test-Path -LiteralPath $place) { Remove-Item -LiteralPath $place -Force }
    $sc = $shell.CreateShortcut($place)
    $sc.TargetPath = "$env:WINDIR\System32\mstsc.exe"
    $sc.Arguments = "`"$rdpFile`""
    $sc.IconLocation = $icon
    $sc.Description = [string]$node.description
    $sc.WorkingDirectory = $rdpDir
    $sc.Save()
    Write-Host "  $($sc.FullName)" -ForegroundColor Green
}

Write-Host ''
Write-Host 'Done. Double-click Cornerman Ethernet (RDP) in Desktop\Launch.' -ForegroundColor Cyan
