# Drop Reset-CornermanClone.ps1 on Green inbox (works mid-rebase — script lives outside clone).
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
. (Join-Path $Here 'Cornerman-Workflow.ps1')

$src = Join-Path $Here 'Reset-CornermanClone.ps1'
$bytes = [System.IO.File]::ReadAllBytes($src)
Push-CornermanFile -Path 'C:\lifepunch\cornerman\inbox\Reset-CornermanClone.ps1' -FileBytes $bytes
Write-Host 'OK inbox\Reset-CornermanClone.ps1' -ForegroundColor Green
Write-Host 'Green run: powershell -NoProfile -ExecutionPolicy Bypass -File C:\lifepunch\cornerman\inbox\Reset-CornermanClone.ps1' -ForegroundColor Cyan
