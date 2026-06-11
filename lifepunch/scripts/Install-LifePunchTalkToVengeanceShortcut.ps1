# CVL shortcut pairing (Red desktop -> Green command; red relay shortcut on Green desktop only).
# VENGEANCE: GREEN icon "Cornerman — Talk to Vengeance" (signals Cornerman).
# Cornerman: RED icon "Talk to Vengeance" (voice lands on VENGEANCE / Cursor).

param(
    [switch] $SkipCornermanDesktop
)

$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
. (Join-Path $Here 'LifePunch-ShortcutIcons.ps1')

$Launcher = Join-Path $Here 'Start-TalkToVengeance.ps1'
if (-not (Test-Path -LiteralPath $Launcher)) { throw "Missing $Launcher" }

$greenIcon = Get-LifePunchShortcutIconLocation -Tier cornerman
$redIconPath = Get-LifePunchShortcutIconPath -Tier vengeance
$vengeanceShortcutName = 'Cornerman - Talk to Vengeance'
$legacyRedOnVengeance = 'Talk to Vengeance'
$cornermanRedName = 'Talk to Vengeance'

$ps = "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe"
$args = "-NoExit -ExecutionPolicy Bypass -NoProfile -File `"$Launcher`""
$desktop = [Environment]::GetFolderPath('Desktop')
$programs = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\LifePunch'
New-Item -ItemType Directory -Force -Path $programs | Out-Null

function New-Lnk {
    param([string]$Path, [string]$Target, [string]$Arguments, [string]$Icon, [string]$Desc, [string]$WorkDir)
    if (Test-Path -LiteralPath $Path) { Remove-Item -LiteralPath $Path -Force }
    $shell = New-Object -ComObject WScript.Shell
    $sc = $shell.CreateShortcut($Path)
    $sc.TargetPath = $Target
    $sc.Arguments = $Arguments
    $sc.IconLocation = $Icon
    $sc.Description = $Desc
    $sc.WorkingDirectory = $WorkDir
    $sc.Save()
    Write-Host "  $Path" -ForegroundColor Green
}

function Remove-LegacyShortcut {
    param([string]$Name)
    foreach ($root in @($desktop, $programs)) {
        $p = Join-Path $root "$Name.lnk"
        if (Test-Path -LiteralPath $p) {
            Remove-Item -LiteralPath $p -Force
            Write-Host "  Removed legacy: $p" -ForegroundColor Yellow
        }
    }
}

Write-Host ''
Write-Host 'CVL voice shortcuts (Red -> Green pairing)' -ForegroundColor Cyan
$repoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
$desc = 'Red->Green: SSH-start PTT on Cornerman + open RDP; red Talk to Vengeance lives on Green desktop'

# VENGEANCE: green command (signals Cornerman)
New-Lnk (Join-Path $desktop "$vengeanceShortcutName.lnk") $ps $args $greenIcon $desc $repoRoot
New-Lnk (Join-Path $programs "$vengeanceShortcutName.lnk") $ps $args $greenIcon $desc $repoRoot
Remove-LegacyShortcut -Name $legacyRedOnVengeance

if (-not $SkipCornermanDesktop) {
    $cornermanSsh = if ($env:CORNERMAN_SSH) { $env:CORNERMAN_SSH } else { 'cornerman' }
    $rag = 'C:/Projects/cornerman-rag'
    $remoteIcon = "$rag/lifepunch-vengeance.ico"
    $remoteCmd = 'C:\Projects\cornerman-rag\Talk to Vengeance.cmd'
    Write-Host ''
    Write-Host "Green desktop ($cornermanSsh) - red Talk to Vengeance..." -ForegroundColor Cyan
    try {
        & scp.exe -o BatchMode=yes -o ConnectTimeout=8 $redIconPath "${cornermanSsh}:${remoteIcon}" 2>$null
        if ($LASTEXITCODE -eq 0) {
            $iconRemoteLoc = "$remoteIcon,0"
            $ps1 = @'
$shell = New-Object -ComObject WScript.Shell
$desk = [Environment]::GetFolderPath('Desktop')
$p = Join-Path $desk 'Talk to Vengeance.lnk'
$sc = $shell.CreateShortcut($p)
$sc.TargetPath = 'REMOTE_CMD'
$sc.IconLocation = 'REMOTE_ICON'
$sc.Description = 'Voice to VENGEANCE (Red) - F7 arm, F8 talk'
$sc.WorkingDirectory = 'C:\Projects\cornerman-rag'
$sc.Save()
Write-Host "Green desktop shortcut: $p"
'@ -replace 'REMOTE_CMD', $remoteCmd -replace 'REMOTE_ICON', $iconRemoteLoc
            $b64 = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($ps1))
            & ssh.exe -o BatchMode=yes -o ConnectTimeout=8 $cornermanSsh "powershell -NoProfile -EncodedCommand $b64"
        }
        else {
            Write-Host '  Skip Green desktop (scp icon failed)' -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "  Skip Green desktop: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Host ''
Write-Host 'Done.' -ForegroundColor Cyan
Write-Host "  VENGEANCE (Red): green icon  $vengeanceShortcutName" -ForegroundColor DarkGray
Write-Host "  Cornerman (Green): red icon    $cornermanRedName" -ForegroundColor DarkGray
