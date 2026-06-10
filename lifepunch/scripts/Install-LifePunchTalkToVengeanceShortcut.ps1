# Talk to Vengeance — green (Cornerman) icon. VENGEANCE desktop SSH-starts the PTT relay on Cornerman.
# Also refreshes the Cornerman desktop shortcut (local .cmd) when SSH is available.

param(
    [switch] $SkipCornermanDesktop
)

$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
. (Join-Path $Here 'LifePunch-ShortcutIcons.ps1')

$Launcher = Join-Path $Here 'Start-TalkToVengeance.ps1'
if (-not (Test-Path -LiteralPath $Launcher)) { throw "Missing $Launcher" }

$iconLoc = Get-LifePunchShortcutIconLocation -Tier cornerman
$iconPath = Get-LifePunchShortcutIconPath -Tier cornerman
$shortcutName = 'Talk to Vengeance'
$ps = "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe"
$args = "-ExecutionPolicy Bypass -NoProfile -File `"$Launcher`""
$desktop = [Environment]::GetFolderPath('Desktop')
$programs = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\LifePunch'
New-Item -ItemType Directory -Force -Path $programs | Out-Null

function New-Lnk {
    param([string]$Path, [string]$Target, [string]$Arguments, [string]$Icon, [string]$Desc, [string]$WorkDir)
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

Write-Host ''
Write-Host 'Talk to Vengeance shortcuts (green = Cornerman)' -ForegroundColor Cyan
$repoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
$desc = 'SSH-start Cornerman PTT relay (F7 arm, F8 talk) — voice to VENGEANCE Cursor'
New-Lnk (Join-Path $desktop "$shortcutName.lnk") $ps $args $iconLoc $desc $repoRoot
New-Lnk (Join-Path $programs "$shortcutName.lnk") $ps $args $iconLoc $desc $repoRoot

if (-not $SkipCornermanDesktop) {
    $cornermanSsh = if ($env:CORNERMAN_SSH) { $env:CORNERMAN_SSH } else { 'cornerman' }
    $rag = 'C:/Projects/cornerman-rag'
    $remoteIcon = "$rag/lifepunch-cornerman.png"
    $remoteCmd = 'C:\Projects\cornerman-rag\Talk to Vengeance.cmd'
    Write-Host ''
    Write-Host "Cornerman desktop ($cornermanSsh)..." -ForegroundColor Cyan
    try {
        & scp.exe -o BatchMode=yes -o ConnectTimeout=8 $iconPath "${cornermanSsh}:${remoteIcon}" 2>$null
        if ($LASTEXITCODE -eq 0) {
            $iconRemoteLoc = "$remoteIcon,0"
            $ps1 = @"
`$shell = New-Object -ComObject WScript.Shell
`$desk = [Environment]::GetFolderPath('Desktop')
`$p = Join-Path `$desk 'Talk to Vengeance.lnk'
`$sc = `$shell.CreateShortcut(`$p)
`$sc.TargetPath = '$remoteCmd'
`$sc.IconLocation = '$iconRemoteLoc'
`$sc.Description = 'Voice relay PTT — F7 arm, F8 talk'
`$sc.WorkingDirectory = 'C:\Projects\cornerman-rag'
`$sc.Save()
Write-Host "Cornerman desktop shortcut: `$p"
"@
            $b64 = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($ps1))
            & ssh.exe -o BatchMode=yes -o ConnectTimeout=8 $cornermanSsh "powershell -NoProfile -EncodedCommand $b64"
        }
        else {
            Write-Host '  Skip Cornerman desktop (scp icon failed)' -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "  Skip Cornerman desktop: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Host ''
Write-Host 'Done. VENGEANCE: double-click Talk to Vengeance to SSH-start the relay on Cornerman.' -ForegroundColor Cyan
