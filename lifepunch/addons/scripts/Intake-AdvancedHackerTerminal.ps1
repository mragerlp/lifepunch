<#
.SYNOPSIS
  Intake owner advanced hacker terminal mesh + vengeance UI art.

.PARAMETER SourceRoot
  Owner pack folder (default: addon stuff\hackerjobassets\...\advancedhackerterminal).

.PARAMETER SourceFbx
  Optional explicit FBX (overrides search: source\computer.fbx, *.fbx).

.EXAMPLE
  powershell -File Intake-AdvancedHackerTerminal.ps1
#>
[CmdletBinding()]
param(
    [string] $SourceRoot = '',
    [string] $SourceFbx = '',
    [string] $ArchiveRoot = 'C:\lifepunch\reference-intake\hackerjob\advanced-hacker-terminal-v2',
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$AddonsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$HackerAssets = Join-Path $AddonsRoot 'Assets\addons\lifepunch\hackerjob'
$ModelSource = Join-Path $HackerAssets 'models\lifepunch\hackerjob\advanced-hacker-terminal\source'
$DestFbx = Join-Path $ModelSource 'hacker-terminal.fbx'
$DestUi = Join-Path $HackerAssets 'ui\vengeance'
$IntakeRaw = Join-Path $HackerAssets 'intake-raw\advanced-hacker-terminal-v2'

function Resolve-AdvancedTerminalSourceRoot([string]$Explicit) {
    if ($Explicit) { return $Explicit }
    $candidates = @(
        (Join-Path $env:USERPROFILE 'OneDrive\Desktop\addon stuff\hackerjobassets\Hacker Job\advancedhackerterminal')
        (Join-Path $env:USERPROFILE 'OneDrive\Desktop\advancedhackerterminal')
        (Join-Path $env:USERPROFILE 'Desktop\advancedhackerterminal')
    )
    foreach ($c in $candidates) {
        if (Test-Path -LiteralPath $c) { return $c }
    }
    return $candidates[0]
}

function Resolve-AdvancedTerminalFbx([string]$Root, [string]$Explicit) {
    if ($Explicit -and (Test-Path -LiteralPath $Explicit)) { return $Explicit }
    $named = Join-Path $Root 'source\computer.fbx'
    if (Test-Path -LiteralPath $named) { return $named }
    return Get-ChildItem -LiteralPath $Root -Recurse -File -Filter *.fbx -ErrorAction SilentlyContinue |
        Sort-Object Length -Descending |
        Select-Object -First 1 -ExpandProperty FullName
}

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        if ($WhatIf) { Write-Host "[WhatIf] mkdir $Path" }
        else { New-Item -ItemType Directory -Force -Path $Path | Out-Null }
    }
}

$SourceRoot = Resolve-AdvancedTerminalSourceRoot -Explicit $SourceRoot
if (-not (Test-Path -LiteralPath $SourceRoot)) {
    throw "Missing source root: $SourceRoot"
}

$SourceFbx = Resolve-AdvancedTerminalFbx -Root $SourceRoot -Explicit $SourceFbx
$vengeanceUi = Join-Path $SourceRoot 'vengeance'

Write-Host 'Advanced hacker terminal intake' -ForegroundColor Cyan
Write-Host "  Source root: $SourceRoot" -ForegroundColor DarkGray

if ($WhatIf) {
    Write-Host "[WhatIf] archive + ship copy"
    return
}

Ensure-Dir $ArchiveRoot
Copy-Item -LiteralPath $SourceRoot -Destination (Join-Path $ArchiveRoot 'source-tree') -Recurse -Force
Ensure-Dir $IntakeRaw
Copy-Item -LiteralPath $SourceRoot -Destination (Join-Path $IntakeRaw 'latest') -Recurse -Force
Write-Host '  Archive + intake-raw OK' -ForegroundColor Green

if (-not $SourceFbx -or -not (Test-Path -LiteralPath $SourceFbx)) {
    throw "No FBX under $SourceRoot (expected source\computer.fbx)."
}

Write-Host "  FBX: $SourceFbx" -ForegroundColor DarkGray
Ensure-Dir $ModelSource
Copy-Item -LiteralPath $SourceFbx -Destination $DestFbx -Force
$blend = Join-Path $SourceRoot 'source\computer.blend'
if (Test-Path -LiteralPath $blend) {
    Copy-Item -LiteralPath $blend -Destination (Join-Path $ModelSource 'computer.blend') -Force
}
Write-Host '  hacker-terminal.fbx OK (advanced CRT mesh)' -ForegroundColor Green

if (Test-Path -LiteralPath $vengeanceUi) {
    Ensure-Dir $DestUi
    Get-ChildItem -LiteralPath $vengeanceUi -File -Include *.png,*.jpg,*.jpeg -ErrorAction SilentlyContinue |
        ForEach-Object {
            Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $DestUi $_.Name) -Force
            Write-Host "  ui/vengeance/$($_.Name)" -ForegroundColor DarkGray
        }
    Write-Host '  vengeance UI art OK' -ForegroundColor Green
}

Write-Host 'Next: advanced-hacker-terminal.vmdl in ModelDoc (red pass), compile _c, lp_vengeance_preview.' -ForegroundColor Yellow
