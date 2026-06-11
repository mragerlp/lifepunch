# VENGEANCE: deploy Cornerman (Sync from Red) to cornerman-rag + inbox + Green desktop shortcut.
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
. (Join-Path $Here 'Cornerman-Workflow.ps1')
. (Join-Path $Here 'LifePunch-ShortcutIcons.ps1')

$rag = 'C:\Projects\cornerman-rag'
$inbox = 'C:\lifepunch\cornerman\inbox'

$fileDrops = @(
    @{ local = 'Reset-CornermanClone.ps1'; rag = 'Reset-CornermanClone.ps1'; inbox = 'Reset-CornermanClone.ps1' },
    @{ local = 'Install-CornermanResetCloneShortcut.ps1'; rag = 'Install-CornermanResetCloneShortcut.ps1'; inbox = 'Install-CornermanResetCloneShortcut.ps1' },
    @{ local = 'cornerman-rag\Cornerman (Sync from Red).cmd'; rag = 'Cornerman (Sync from Red).cmd'; inbox = $null }
)

foreach ($d in $fileDrops) {
    $src = Join-Path $Here $d.local
    if (-not (Test-Path -LiteralPath $src)) { throw "Missing $src" }
    $bytes = [System.IO.File]::ReadAllBytes($src)
    Push-CornermanFile -Path (Join-Path $rag $d.rag) -FileBytes $bytes
    Write-Host "OK rag\$($d.rag)" -ForegroundColor Green
    if ($d.inbox) {
        Push-CornermanFile -Path (Join-Path $inbox $d.inbox) -FileBytes $bytes
        Write-Host "OK inbox\$($d.inbox)" -ForegroundColor DarkGray
    }
}

$iconPath = Get-LifePunchShortcutIconPath -Tier cornerman
Write-Host ''
Write-Host 'Publishing green tier icon to cornerman-rag...' -ForegroundColor Cyan
try {
    $iconBytes = [System.IO.File]::ReadAllBytes($iconPath)
    Push-CornermanFile -Path (Join-Path $rag 'lifepunch-cornerman.ico') -FileBytes $iconBytes
    Write-Host 'OK rag\lifepunch-cornerman.ico' -ForegroundColor Green
}
catch {
    Write-Host "  Icon push skipped: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ''
Write-Host 'Installing Green desktop shortcut...' -ForegroundColor Cyan
$installResult = Invoke-CornermanSshExec -ScriptBlock @"
& powershell -NoProfile -ExecutionPolicy Bypass -File '$rag\Install-CornermanResetCloneShortcut.ps1'
"@
if ($installResult.ExitCode -ne 0) {
    throw "Shortcut install failed: $($installResult.Output)"
}
Write-Host $installResult.Output

Write-Host ''
Write-Host 'Cornerman (Sync from Red) - uniform with Cornerman (RDP) naming.' -ForegroundColor Cyan
Write-Host '  Desktop + Start Menu\LifePunch - green icon - launches cornerman-rag\.cmd' -ForegroundColor DarkGray
