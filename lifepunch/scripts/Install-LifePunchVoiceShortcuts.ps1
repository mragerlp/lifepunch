# Desktop + Start menu shortcut: LifePunch Voice Comms (starts all VENGEANCE voice windows).

param(
    [switch] $PinTaskbar
)

$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..')).Path
$Launcher = Join-Path $Here 'start-voice-comms.ps1'
$Preflight = Join-Path $Here 'Test-VoiceCommsReady.ps1'

if (-not (Test-Path -LiteralPath $Launcher)) { throw "Missing $Launcher" }

$icon = Join-Path $RepoRoot 'branding\cornerman\cornerman-terminal-icon.ico'
if (-not (Test-Path -LiteralPath $icon)) { throw "Missing $icon" }
$iconLoc = "$icon,0"

$shortcutName = 'LifePunch Voice Comms'
$preflightName = 'LifePunch Voice Preflight'
$desktop = [Environment]::GetFolderPath('Desktop')
$programs = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\LifePunch'
New-Item -ItemType Directory -Force -Path $programs | Out-Null

function New-Lnk([string]$Path, [string]$Target, [string]$Args, [string]$Desc) {
    $shell = New-Object -ComObject WScript.Shell
    $sc = $shell.CreateShortcut($Path)
    $sc.TargetPath = $Target
    $sc.Arguments = $Args
    $sc.IconLocation = $iconLoc
    $sc.Description = $Desc
    $sc.WorkingDirectory = (Resolve-Path (Join-Path $Here '..\..')).Path
    $sc.Save()
    Write-Host "  $($sc.FullName)" -ForegroundColor Green
}

$ps = "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe"
$launchArgs = "-ExecutionPolicy Bypass -NoProfile -File `"$Launcher`""
$preflightArgs = "-ExecutionPolicy Bypass -NoProfile -File `"$Preflight`""

Write-Host ''
Write-Host 'LifePunch voice comms shortcuts' -ForegroundColor Cyan
New-Lnk (Join-Path $desktop "$shortcutName.lnk") $ps $launchArgs 'Cornerman voice -> Cursor paste + lifepunchnet session hub'
New-Lnk (Join-Path $programs "$shortcutName.lnk") $ps $launchArgs 'Cornerman voice -> Cursor paste + lifepunchnet session hub'
New-Lnk (Join-Path $programs "$preflightName.lnk") $ps $preflightArgs 'Check SSH, Whisper :9000, session hub :9102'
Write-Host ''
Write-Host 'Done. Double-click LifePunch Voice Comms before Cornerman voice work.' -ForegroundColor Cyan
Write-Host 'Cornerman still needs Talk to Vengeance running locally.' -ForegroundColor DarkGray

if ($PinTaskbar) {
    Write-Host 'Pin manually: right-click shortcut -> Pin to taskbar' -ForegroundColor DarkGray
}
