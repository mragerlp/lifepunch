<#
.SYNOPSIS
  Intake owner government terminal pack into lifepunch governmentdatacenter (police-terminal).

.PARAMETER SourceRoot
  Default: addon stuff\hackerjobassets\...\governmentterminal

.EXAMPLE
  powershell -File Intake-GovernmentTerminal.ps1
#>
[CmdletBinding()]
param(
    [string] $SourceRoot = '',
    [string] $ArchiveRoot = 'C:\lifepunch\reference-intake\governmentdatacenter\government-terminal',
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$AddonsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$GovAssets = Join-Path $AddonsRoot 'Assets\addons\lifepunch\governmentdatacenter'
$ModelSource = Join-Path $GovAssets 'models\lifepunch\governmentdatacenter\police-terminal\source'
$DestUi = Join-Path $GovAssets 'ui\lifepunchnet'
$IntakeRaw = Join-Path $GovAssets 'intake-raw\government-terminal'

function Resolve-GovernmentTerminalSource([string]$Explicit) {
    if ($Explicit) { return $Explicit }
    $candidates = @(
        (Join-Path $env:USERPROFILE 'OneDrive\Desktop\addon stuff\hackerjobassets\Hacker Job\governmentterminal')
        (Join-Path $env:USERPROFILE 'OneDrive\Desktop\governmentterminal')
        (Join-Path $env:USERPROFILE 'OneDrive\Desktop\governmentdatacenter')
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

$SourceRoot = Resolve-GovernmentTerminalSource -Explicit $SourceRoot
if (-not (Test-Path -LiteralPath $SourceRoot)) {
    throw "Missing $SourceRoot - drop government terminal pack first."
}

$mesh = Get-ChildItem -LiteralPath (Join-Path $SourceRoot 'source') -File -Include *.obj,*.fbx,*.dae -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $mesh) {
    $mesh = Get-ChildItem -LiteralPath $SourceRoot -Recurse -File -Include *.obj,*.fbx,*.dae -ErrorAction SilentlyContinue | Select-Object -First 1
}
if (-not $mesh) {
    throw "No mesh under $SourceRoot"
}

$uiDir = Join-Path $SourceRoot 'razor'
if (-not (Test-Path -LiteralPath $uiDir)) {
    $uiDir = $SourceRoot
}

Write-Host 'Government terminal intake' -ForegroundColor Cyan
Write-Host "  Source: $SourceRoot" -ForegroundColor DarkGray
Write-Host "  Mesh: $($mesh.Name)" -ForegroundColor DarkGray

if ($WhatIf) {
    Write-Host '[WhatIf] police-terminal source + ui/lifepunchnet + intake-raw'
    return
}

Ensure-Dir $ArchiveRoot
Ensure-Dir $IntakeRaw
Ensure-Dir $ModelSource
Ensure-Dir (Join-Path $ModelSource 'textures')
Ensure-Dir $DestUi
Ensure-Dir (Join-Path $GovAssets 'entities\police-terminal')

Copy-Item -LiteralPath $SourceRoot -Destination (Join-Path $ArchiveRoot 'source-tree') -Recurse -Force
Copy-Item -LiteralPath $SourceRoot -Destination (Join-Path $IntakeRaw 'latest') -Recurse -Force

$destMesh = Join-Path $ModelSource 'police-terminal.obj'
Copy-Item -LiteralPath $mesh.FullName -Destination $destMesh -Force
Write-Host '  police-terminal.obj OK' -ForegroundColor Green

$texSrc = Join-Path $SourceRoot 'textures'
$destTex = Join-Path $ModelSource 'textures'
if (Test-Path -LiteralPath $texSrc) {
    Copy-Item -Path "$texSrc\*" -Destination $destTex -Force
    Write-Host "  source/textures: $((Get-ChildItem -LiteralPath $destTex -File).Count) files" -ForegroundColor Green
}

@('*.png', '*.jpg', '*.jpeg') | ForEach-Object {
    Get-ChildItem -LiteralPath $uiDir -File -Filter $_ -ErrorAction SilentlyContinue
} |
    ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $DestUi $_.Name) -Force
        Write-Host "  ui/lifepunchnet/$($_.Name)" -ForegroundColor DarkGray
    }

Write-Host 'Next: police-terminal.vmdl in ModelDoc, prefab, compile _c - unblocks vengeance govdb scan.' -ForegroundColor Yellow
Write-Host 'Intake OK' -ForegroundColor Green
