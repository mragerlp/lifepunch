# Green desktop: Cornerman (Sync from Red) - matches Cornerman (RDP) naming + green tier icon.
# Deployed to C:\Projects\cornerman-rag\ via Push-CornermanResetScript.ps1 (VENGEANCE).
$ErrorActionPreference = 'Stop'

$RagRoot = 'C:\Projects\cornerman-rag'
$ShortcutName = 'Cornerman (Sync from Red)'
$LauncherCmd = Join-Path $RagRoot 'Cornerman (Sync from Red).cmd'
$ResetPs1 = Join-Path $RagRoot 'Reset-CornermanClone.ps1'
$IconIco = Join-Path $RagRoot 'lifepunch-cornerman.ico'

if (-not (Test-Path -LiteralPath $ResetPs1)) {
    throw "Missing $ResetPs1 - run Push-CornermanResetScript.ps1 from VENGEANCE."
}
if (-not (Test-Path -LiteralPath $LauncherCmd)) {
    throw "Missing $LauncherCmd - run Push-CornermanResetScript.ps1 from VENGEANCE."
}

$iconLoc = $null
if (Test-Path -LiteralPath $IconIco) {
    $iconLoc = "$IconIco,0"
}

$desktop = [Environment]::GetFolderPath('Desktop')
$programs = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\LifePunch'
New-Item -ItemType Directory -Force -Path $programs | Out-Null

function New-Lnk {
    param([string]$Path, [string]$Target, [string]$IconLoc, [string]$Description)
    if (Test-Path -LiteralPath $Path) { Remove-Item -LiteralPath $Path -Force }
    $shell = New-Object -ComObject WScript.Shell
    $sc = $shell.CreateShortcut($Path)
    $sc.TargetPath = $Target
    if ($IconLoc) { $sc.IconLocation = $IconLoc }
    $sc.Description = $Description
    $sc.WorkingDirectory = $RagRoot
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

$desc = 'Cornerman: abort stuck rebase, git reset --hard origin/main (Red owns commits)'

Write-Host ''
Write-Host $ShortcutName -ForegroundColor Cyan
Remove-LegacyShortcut -Name 'Cornerman - Sync from Red'
New-Lnk (Join-Path $desktop "$ShortcutName.lnk") $LauncherCmd $iconLoc $desc
New-Lnk (Join-Path $programs "$ShortcutName.lnk") $LauncherCmd $iconLoc $desc
Write-Host ''
Write-Host 'Done. Green tier icon = local Cornerman ops (see SHORTCUT_ICONS.md).' -ForegroundColor Cyan
