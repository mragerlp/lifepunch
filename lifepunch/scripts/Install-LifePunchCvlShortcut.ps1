# Desktop shortcut: LifePunch — Same Page? (universal CVL checkpoint + hub ingest)

$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
. (Join-Path $Here 'LifePunch-ShortcutIcons.ps1')
$Launcher = Join-Path $Here 'Invoke-CvlUniversal.ps1'

if (-not (Test-Path -LiteralPath $Launcher)) { throw "Missing $Launcher" }

$iconLoc = Get-LifePunchShortcutIconLocation -Tier universal
$shortcutName = 'LifePunch - CVL Same Page'
$desktop = [Environment]::GetFolderPath('Desktop')
$programs = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\LifePunch'
New-Item -ItemType Directory -Force -Path $programs | Out-Null

$shell = New-Object -ComObject WScript.Shell
$ps = "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe"
$args = "-ExecutionPolicy Bypass -NoProfile -File `"$Launcher`" -IngestToHub"

foreach ($dir in @($desktop, $programs)) {
    $lnk = Join-Path $dir "$shortcutName.lnk"
    if (Test-Path -LiteralPath $lnk) { Remove-Item -LiteralPath $lnk -Force }
    $sc = $shell.CreateShortcut($lnk)
    $sc.TargetPath = $ps
    $sc.Arguments = $args
    $sc.IconLocation = $iconLoc
    $sc.Description = 'CVL universal checkpoint: Red+Green+Blue probe, log to lifepunchnet hub'
    $sc.WorkingDirectory = (Resolve-Path (Join-Path $Here '..\..')).Path
    $sc.Save()
    Write-Host "  $($sc.FullName)" -ForegroundColor Green
}

Write-Host ''
Write-Host 'Done. Double-click LifePunch - CVL Same Page before commit/push or move-on.' -ForegroundColor Cyan
