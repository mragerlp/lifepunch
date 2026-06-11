# Desktop shortcut: DXRP Editor (sync addons + open rp.sbproj via Start-SboxDxrpEditor.ps1)

$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
. (Join-Path $Here 'LifePunch-ShortcutIcons.ps1')
$Launcher = Join-Path $Here 'Start-SboxDxrpEditor.ps1'

if (-not (Test-Path -LiteralPath $Launcher)) { throw "Missing $Launcher" }

$iconLoc = Get-LifePunchShortcutIconLocation -Tier vengeance
$shortcutName = 'DXRP Editor - VENGEANCE'
$desktop = [Environment]::GetFolderPath('Desktop')
$programs = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\LifePunch'
New-Item -ItemType Directory -Force -Path $programs | Out-Null

$shell = New-Object -ComObject WScript.Shell
$ps = "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe"
$args = "-ExecutionPolicy Bypass -NoProfile -File `"$Launcher`""

foreach ($dir in @($desktop, $programs)) {
    $lnk = Join-Path $dir "$shortcutName.lnk"
    if (Test-Path -LiteralPath $lnk) { Remove-Item -LiteralPath $lnk -Force }
    $sc = $shell.CreateShortcut($lnk)
    $sc.TargetPath = $ps
    $sc.Arguments = $args
    $sc.IconLocation = $iconLoc
    $sc.Description = 'Sync LifePunch addons and launch s&box DXRP (authorize token in console when needed)'
    $sc.WorkingDirectory = (Resolve-Path (Join-Path $Here '..\..')).Path
    $sc.Save()
    Write-Host "  $($sc.FullName)" -ForegroundColor Green
}

Write-Host ''
Write-Host 'Done. Double-click DXRP Editor on VENGEANCE.' -ForegroundColor Cyan
$config = Join-Path $Here 'dxrp-editor.local.json'
if (-not (Test-Path -LiteralPath $config)) {
    Write-Host 'Requires: copy dxrp-editor.local.json.example -> dxrp-editor.local.json (paths only)' -ForegroundColor Yellow
}
