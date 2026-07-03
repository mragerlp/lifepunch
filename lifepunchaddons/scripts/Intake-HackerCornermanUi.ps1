<#
.SYNOPSIS
  Intake owner Cornerman UI PNGs into lifepunch hackerjob ui/cornerman/.

.PARAMETER SourceRoot
  Default: addon stuff\hackerjobassets\...\Hacker Terminal\cornerman

.EXAMPLE
  powershell -File Intake-HackerCornermanUi.ps1
#>
[CmdletBinding()]
param(
    [string] $SourceRoot = '',
    [string] $ArchiveRoot = 'C:\lifepunch\reference-intake\hackerjob\cornerman-ui',
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$AddonsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$HackerAssets = Join-Path $AddonsRoot 'Assets\addons\lifepunch\hackerjob'
$DestUi = Join-Path $HackerAssets 'ui\cornerman'

function Resolve-CornermanUiSource([string]$Explicit) {
    if ($Explicit) { return $Explicit }
    $candidates = @(
        (Join-Path $env:USERPROFILE 'OneDrive\Desktop\addon stuff\hackerjobassets\Hacker Job\Hacker Terminal\cornerman')
        (Join-Path $env:USERPROFILE 'OneDrive\Desktop\cornerman')
    )
    foreach ($c in $candidates) {
        if (Test-Path -LiteralPath $c) { return $c }
    }
    return $candidates[0]
}

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        if (-not $WhatIf) { New-Item -ItemType Directory -Force -Path $Path | Out-Null }
    }
}

$SourceRoot = Resolve-CornermanUiSource -Explicit $SourceRoot
if (-not (Test-Path -LiteralPath $SourceRoot)) {
    throw "Missing $SourceRoot - drop Cornerman UI PNGs first."
}

$pngs = @(
    Get-ChildItem -LiteralPath $SourceRoot -File -Filter '*.png' -ErrorAction SilentlyContinue
    Get-ChildItem -LiteralPath $SourceRoot -File -Filter '*.jpg' -ErrorAction SilentlyContinue
    Get-ChildItem -LiteralPath $SourceRoot -File -Filter '*.jpeg' -ErrorAction SilentlyContinue
) | Where-Object { $_ }
if (-not $pngs) {
    throw "No PNG/JPG under $SourceRoot"
}

Write-Host 'Cornerman UI intake' -ForegroundColor Cyan
Write-Host "  Source: $SourceRoot" -ForegroundColor DarkGray

if ($WhatIf) {
    $pngs | ForEach-Object { Write-Host "[WhatIf] ui/cornerman/$($_.Name)" }
    return
}

Ensure-Dir $ArchiveRoot
Ensure-Dir $DestUi
Copy-Item -LiteralPath (Join-Path $SourceRoot '*') -Destination $ArchiveRoot -Recurse -Force
$pngs | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $DestUi $_.Name) -Force
    Write-Host "  ui/cornerman/$($_.Name)" -ForegroundColor DarkGray
}

Write-Host '  cornerman UI art OK' -ForegroundColor Green
Write-Host 'Next: wire PNGs into HackerTerminal.razor chrome when owner approves SCSS swap.' -ForegroundColor Yellow
