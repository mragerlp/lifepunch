# Drop Reset-CornermanClone.ps1 + shortcut installer on Green inbox (works mid-rebase).
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
. (Join-Path $Here 'Cornerman-Workflow.ps1')

$drops = @(
    @{ local = 'Reset-CornermanClone.ps1'; remote = 'Reset-CornermanClone.ps1' },
    @{ local = 'Install-CornermanResetCloneShortcut.ps1'; remote = 'Install-CornermanResetCloneShortcut.ps1' },
    @{ local = 'cornerman-inbox\Cornerman-Sync-from-Red.cmd'; remote = 'Cornerman-Sync-from-Red.cmd' }
)

foreach ($d in $drops) {
    $src = Join-Path $Here $d.local
    if (-not (Test-Path -LiteralPath $src)) { throw "Missing $src" }
    $bytes = [System.IO.File]::ReadAllBytes($src)
    Push-CornermanFile -Path "C:\lifepunch\cornerman\inbox\$($d.remote)" -FileBytes $bytes
    Write-Host "OK inbox\$($d.remote)" -ForegroundColor Green
}

Write-Host ''
Write-Host 'Green — one-time shortcut install:' -ForegroundColor Cyan
Write-Host '  powershell -NoProfile -ExecutionPolicy Bypass -File C:\lifepunch\cornerman\inbox\Install-CornermanResetCloneShortcut.ps1' -ForegroundColor White
Write-Host 'Green — run sync (or double-click desktop shortcut after install):' -ForegroundColor Cyan
Write-Host '  C:\lifepunch\cornerman\inbox\Cornerman-Sync-from-Red.cmd' -ForegroundColor White
