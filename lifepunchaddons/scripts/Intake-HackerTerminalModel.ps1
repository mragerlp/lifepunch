<#
.SYNOPSIS
  Intake criminal hacker terminal (blend + textures) into lifepunch hackerjob.

.EXAMPLE
  powershell -File Intake-HackerTerminalModel.ps1
  powershell -File Intake-HackerTerminalModel.ps1 -ExportFbx
#>
[CmdletBinding()]
param(
    [string] $SourceRoot = '',
    [string] $SourceFbx = '',
    [string] $ArchiveRoot = 'C:\lifepunch\reference-intake\hackerjob\hackerterminal-v2',
    [switch] $ExportFbx,
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'LifePunch-AddonDropPaths.ps1')

if (-not $SourceRoot) {
    $SourceRoot = Get-LifePunchEntityDrop -Key 'hacker.hacker-terminal' -LegacyNames @('hackerterminal')
}

$AddonsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$HackerAssets = Join-Path $AddonsRoot 'Assets\addons\lifepunch\hackerjob'
$ModelRoot = Join-Path $HackerAssets 'models\lifepunch\hackerjob\hacker-terminal'
$DestSource = Join-Path $ModelRoot 'source'
$DestTex = Join-Path $DestSource 'textures'
$DestFbx = Join-Path $DestSource 'hacker-terminal.fbx'
$IntakeRaw = Join-Path $HackerAssets 'intake-raw\hackerterminal-v2'

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        if ($WhatIf) { Write-Host "[WhatIf] mkdir $Path" }
        else { New-Item -ItemType Directory -Force -Path $Path | Out-Null }
    }
}

function Resolve-HackerTerminalBlend([string]$Root) {
    $names = @(
        (Join-Path $Root 'source\computer thing.blend')
        (Join-Path $Root 'computer thing.blend')
        (Join-Path $Root 'source\computer.blend')
        (Join-Path $Root 'computer.blend')
    )
    foreach ($p in $names) {
        if (Test-Path -LiteralPath $p) { return $p }
    }
    $hit = Get-ChildItem -LiteralPath $Root -Recurse -File -Filter '*.blend' -ErrorAction SilentlyContinue |
        Sort-Object Length -Descending | Select-Object -First 1
    if ($hit) { return $hit.FullName }
    return $null
}

function Resolve-HackerTerminalFbx([string]$Root, [string]$Explicit) {
    if ($Explicit -and (Test-Path -LiteralPath $Explicit)) { return $Explicit }
    $candidates = @(
        (Join-Path $Root 'hackerterminal.fbx')
        (Join-Path $Root 'source\hackerterminal.fbx')
        (Join-Path $Root 'hacker-terminal.fbx')
        (Join-Path $Root 'source\hacker-terminal.fbx')
        (Join-Path $Root 'computer.fbx')
        (Join-Path $Root 'source\computer.fbx')
    )
    $found = $candidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
    if ($found) { return $found }
    $hit = Get-ChildItem -LiteralPath $Root -Recurse -File -Filter '*.fbx' -ErrorAction SilentlyContinue |
        Sort-Object Length -Descending | Select-Object -First 1
    if ($hit) { return $hit.FullName }
    return $null
}

if (-not (Test-Path -LiteralPath $SourceRoot)) {
    throw "Missing drop: $SourceRoot"
}

$blend = Resolve-HackerTerminalBlend -Root $SourceRoot
$sourceFbx = Resolve-HackerTerminalFbx -Root $SourceRoot -Explicit $SourceFbx

Write-Host 'Hacker terminal model intake (criminal lane)' -ForegroundColor Cyan
Write-Host "  Drop:  $SourceRoot" -ForegroundColor DarkGray
Write-Host "  Blend: $blend" -ForegroundColor DarkGray
Write-Host "  FBX:   $sourceFbx" -ForegroundColor DarkGray

if (-not $WhatIf) {
    Ensure-Dir $ArchiveRoot
    & robocopy $SourceRoot $ArchiveRoot /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "Archive robocopy failed ($LASTEXITCODE)" }
    Ensure-Dir $IntakeRaw
    & robocopy $SourceRoot $IntakeRaw /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "Intake-raw robocopy failed ($LASTEXITCODE)" }
}

Ensure-Dir $DestSource
Ensure-Dir $DestTex

if ($blend -and -not $WhatIf) {
    Copy-Item -LiteralPath $blend -Destination (Join-Path $DestSource 'computer-thing.blend') -Force
}

$textureNames = @('BM_BAKE_5.png', 'internal_ground_ao_texture.jpeg')
foreach ($name in $textureNames) {
    foreach ($base in @($SourceRoot, (Join-Path $SourceRoot 'textures'))) {
        $src = Join-Path $base $name
        if (-not (Test-Path -LiteralPath $src)) { continue }
        if ($WhatIf) {
            Write-Host "[WhatIf] texture $name"
        } else {
            Copy-Item -LiteralPath $src -Destination (Join-Path $DestTex $name) -Force
            Write-Host "  texture: $name" -ForegroundColor DarkGray
        }
        break
    }
}

if ($sourceFbx) {
    if (-not $WhatIf) {
        Copy-Item -LiteralPath $sourceFbx -Destination $DestFbx -Force
        Write-Host '  hacker-terminal.fbx (from drop)' -ForegroundColor Green
    }
}
elseif ($blend) {
    $doExport = $ExportFbx -or -not (Test-Path -LiteralPath $DestFbx)
    if ($doExport -and -not $WhatIf) {
        $exportScript = Join-Path $PSScriptRoot 'Export-HackerTerminalFbx.ps1'
        & $exportScript -SourceRoot $SourceRoot
    }
    elseif (-not (Test-Path -LiteralPath $DestFbx)) {
        throw "No FBX in drop and export skipped. Run with -ExportFbx."
    }
}
else {
    if (Test-Path -LiteralPath $DestFbx) {
        Write-Host 'Drop has no blend/FBX — keeping existing repo FBX.' -ForegroundColor Yellow
        exit 0
    }
    throw "Missing blend or FBX under $SourceRoot"
}

if (-not $WhatIf -and -not (Test-Path -LiteralPath $DestFbx)) {
    throw "Intake finished without hacker-terminal.fbx at $DestFbx"
}

Write-Host 'Intake OK — compile hacker-terminal.vmdl in ModelDoc (import_scale 0.0195).' -ForegroundColor Green
