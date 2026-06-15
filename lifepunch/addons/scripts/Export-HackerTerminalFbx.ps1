<#
.SYNOPSIS
  Export owner hacker terminal blend to hacker-terminal.fbx for ModelDoc.

.EXAMPLE
  powershell -File Export-HackerTerminalFbx.ps1
#>
[CmdletBinding()]
param(
    [string] $SourceRoot = '',
    [string] $BlenderExe = "${env:ProgramFiles}\Blender Foundation\Blender 5.1\blender.exe",
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'LifePunch-AddonDropPaths.ps1')

if (-not $SourceRoot) {
    $SourceRoot = Get-LifePunchEntityDrop -Key 'hacker.hacker-terminal' -LegacyNames @('hackerterminal')
}

$AddonsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$ModelSource = Join-Path $AddonsRoot 'Assets\addons\lifepunch\hackerjob\models\lifepunch\hackerjob\hacker-terminal\source'
$OutFbx = Join-Path $ModelSource 'hacker-terminal.fbx'
$Py = Join-Path $PSScriptRoot 'Export-HackerTerminalFbx.py'

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

$Blend = Resolve-HackerTerminalBlend -Root $SourceRoot
if (-not $Blend) {
    throw "Missing blend under $SourceRoot"
}

if (-not (Test-Path -LiteralPath $BlenderExe)) {
    $found = Get-ChildItem "${env:ProgramFiles}\Blender Foundation" -Recurse -Filter blender.exe -ErrorAction SilentlyContinue |
        Select-Object -First 1 -ExpandProperty FullName
    if ($found) { $BlenderExe = $found }
    else { throw "Blender not found. Install Blender or pass -BlenderExe." }
}

if ($WhatIf) {
    Write-Host "[WhatIf] $BlenderExe --background $Blend -> $OutFbx"
    exit 0
}

if (-not (Test-Path -LiteralPath $ModelSource)) {
    New-Item -ItemType Directory -Force -Path $ModelSource | Out-Null
}

Write-Host 'Export hacker terminal FBX' -ForegroundColor Cyan
Write-Host "  Blend: $Blend"
Write-Host "  Out:   $OutFbx"

& $BlenderExe --background $Blend --python $Py -- $Blend $OutFbx
if ($LASTEXITCODE -ne 0) { throw "Blender export failed ($LASTEXITCODE)" }
if (-not (Test-Path -LiteralPath $OutFbx)) { throw "FBX not written: $OutFbx" }
$size = (Get-Item -LiteralPath $OutFbx).Length
if ($size -lt 1000) { throw "FBX looks empty ($size bytes): $OutFbx" }

Write-Host 'Export OK' -ForegroundColor Green
