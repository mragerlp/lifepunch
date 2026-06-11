<#
.SYNOPSIS
  Scaffold all LifePunch Gun Dealer weapons (except AK golden kit) and print the production queue.

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File Start-WeaponMassProduction.ps1
#>
$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$ProdPath = Join-Path $Here '..\config\weapon-production.json'
$NewWeapon = Join-Path $Here 'New-LifePunchWeapon.ps1'

$prod = Get-Content -LiteralPath $ProdPath -Raw | ConvertFrom-Json
$queue = @($prod.weapons) | Sort-Object { [int]$_.queueOrder }

Write-Host ''
Write-Host 'LifePunch weapon mass production' -ForegroundColor Cyan
Write-Host "Reference intake: $($prod.referenceIntakeRoot)" -ForegroundColor DarkGray
Write-Host ''

foreach ($w in $queue) {
    if ($w.ident -eq 'ak47') {
        Write-Host "[$($w.queueOrder)] AK-47 - ACTIVE KIT (golden reference)" -ForegroundColor Green
        continue
    }
    Write-Host "[$($w.queueOrder)] Scaffolding $($w.title) ($($w.ident))..." -ForegroundColor Yellow
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $NewWeapon -Ident $w.ident
}

Write-Host ''
Write-Host 'Queue (Gun Dealer - 5 classes):' -ForegroundColor Cyan
foreach ($w in $queue) {
    $line = '  {0}. {1,-12} class={2,-14} CS2={3}' -f $w.queueOrder, $w.ident, $w.dxrpClassWeapon, $w.cs2Mesh
    Write-Host $line
}

Write-Host ''
Write-Host 'Next: Source 2 Viewer export, reference intake, FBX, editor prefabs' -ForegroundColor Cyan
Write-Host 'Validate: powershell -File validate-layout.ps1' -ForegroundColor DarkGray
