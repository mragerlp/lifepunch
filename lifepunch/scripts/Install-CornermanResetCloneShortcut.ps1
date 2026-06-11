# Cornerman (Green) desktop shortcut - hard-sync clone to origin/main.
# Run on Green once (or after Red re-pushes inbox script). Safe mid-rebase.
$ErrorActionPreference = 'Stop'

$InboxScript = 'C:\lifepunch\cornerman\inbox\Reset-CornermanClone.ps1'
if (-not (Test-Path -LiteralPath $InboxScript)) {
    throw "Missing $InboxScript - run Push-CornermanResetScript.ps1 from VENGEANCE first."
}

$Here = $PSScriptRoot
$icon = $null
if (Test-Path (Join-Path $Here 'LifePunch-ShortcutIcons.ps1')) {
    . (Join-Path $Here 'LifePunch-ShortcutIcons.ps1')
    try { $icon = Get-LifePunchShortcutIconLocation -Tier cornerman } catch { }
}
if (-not $icon) {
    $ragIco = 'C:\Projects\cornerman-rag\lifepunch-cornerman.ico'
    if (Test-Path -LiteralPath $ragIco) { $icon = "$ragIco,0" }
}

$shortcutName = 'Cornerman - Sync from Red'
$ps = "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe"
$args = "-NoExit -ExecutionPolicy Bypass -NoProfile -File `"$InboxScript`""
$desc = 'Green: abort stuck rebase, git reset --hard origin/main (Red owns commits)'

$desktop = [Environment]::GetFolderPath('Desktop')
$programs = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\LifePunch'
New-Item -ItemType Directory -Force -Path $programs | Out-Null

function New-Lnk {
    param([string]$Path, [string]$Target, [string]$Arguments, [string]$IconLoc, [string]$Description)
    if (Test-Path -LiteralPath $Path) { Remove-Item -LiteralPath $Path -Force }
    $shell = New-Object -ComObject WScript.Shell
    $sc = $shell.CreateShortcut($Path)
    $sc.TargetPath = $Target
    $sc.Arguments = $Arguments
    if ($IconLoc) { $sc.IconLocation = $IconLoc }
    $sc.Description = $Description
    $sc.WorkingDirectory = 'C:\Projects\lifepunch'
    $sc.Save()
    Write-Host "  $Path" -ForegroundColor Green
}

Write-Host ''
Write-Host $shortcutName -ForegroundColor Cyan
New-Lnk (Join-Path $desktop "$shortcutName.lnk") $ps $args $icon $desc
New-Lnk (Join-Path $programs "$shortcutName.lnk") $ps $args $icon $desc
Write-Host ''
Write-Host 'Done. Double-click shortcut when Red pushed and Green clone is behind or stuck.' -ForegroundColor Cyan
