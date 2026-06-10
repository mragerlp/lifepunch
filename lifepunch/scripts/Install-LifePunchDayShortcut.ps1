# Desktop shortcut: LifePunch — Start Day (one-click day live).

param(
    [switch] $PinTaskbar
)

$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
. (Join-Path $Here 'LifePunch-ShortcutIcons.ps1')
$Launcher = Join-Path $Here 'Start-LifePunchDay.ps1'

if (-not (Test-Path -LiteralPath $Launcher)) { throw "Missing $Launcher" }

$iconLoc = Get-LifePunchShortcutIconLocation -Tier universal

$shortcutName = 'LifePunch — Start Day'
$desktop = [Environment]::GetFolderPath('Desktop')
$programs = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\LifePunch'
New-Item -ItemType Directory -Force -Path $programs | Out-Null

$shell = New-Object -ComObject WScript.Shell
$ps = "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe"
$args = "-ExecutionPolicy Bypass -NoProfile -File `"$Launcher`" -OpenRdpOnFailure"

foreach ($dir in @($desktop, $programs)) {
    $lnk = Join-Path $dir "$shortcutName.lnk"
    if (Test-Path -LiteralPath $lnk) { Remove-Item -LiteralPath $lnk -Force }
    $sc = $shell.CreateShortcut($lnk)
    $sc.TargetPath = $ps
    $sc.Arguments = $args
    $sc.IconLocation = $iconLoc
    $sc.Description = 'LifePunch day live: lifepunchnet STT + Cornerman relay + paste watcher'
    $sc.WorkingDirectory = (Resolve-Path (Join-Path $Here '..\..')).Path
    $sc.Save()
    Write-Host "  $($sc.FullName)" -ForegroundColor Green
}

Write-Host ''
Write-Host 'Done. Double-click LifePunch — Start Day to go live.' -ForegroundColor Cyan
Write-Host 'Requires: server-host-watch.local.json, ssh cornerman, lifepunchnet :9000 up.' -ForegroundColor DarkGray
Write-Host 'Refresh RDP shortcuts: Install-LifePunchRemoteShortcuts.ps1' -ForegroundColor DarkGray

if ($PinTaskbar) {
    Write-Host 'Pin manually: right-click shortcut -> Pin to taskbar' -ForegroundColor DarkGray
}
