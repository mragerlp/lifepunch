# ─────────────────────────────────────────────────────────────────────────────
# PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
#
# "LifePunch Addons" (s&box ident: lifepunch.addons · addon ident: lifepunch) is the sole-owned
# intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
# sublicensing, copying, or reuse by ANY person or entity — including DXRP and
# LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
# Author account: mrragerlp · Public alias (in-game · Steam · Discord): Bloodwave
# Presence in this repository or on the DXRP portal grants no rights to anyone else.
# ─────────────────────────────────────────────────────────────────────────────
<#
.SYNOPSIS
  Strip OneDrive addon-test absolute texture paths from hashdterminal.fbx.

.DESCRIPTION
  ModelDoc fails when FBX embeds paths like:
    C:\Users\...\OneDrive\Desktop\addon test\...\Textures\textures4k\Monitor_Color.tga
  Rewrites them to content-relative paths under the DXRP game tree (same byte length).

.PARAMETER FbxPath
  Path to hashdterminal.fbx (repo or DXRP copy).

.EXAMPLE
  powershell -File Repair-LpHashdTerminalFbxEmbeddedPaths.ps1
  powershell -File Repair-LpHashdTerminalFbxEmbeddedPaths.ps1 -FbxPath D:\...\hashdterminal.fbx
#>
[CmdletBinding()]
param(
    [string] $FbxPath = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }

if (-not $FbxPath) {
    $FbxPath = Join-Path $Here '..\Assets\addons\lifepunch\lpbitcoin\hashdterminal\assets\source\fbx\hashdterminal.fbx'
}
$FbxPath = (Resolve-Path -LiteralPath $FbxPath).Path

$encoding = [System.Text.Encoding]::GetEncoding('iso-8859-1')
$content = [System.IO.File]::ReadAllText($FbxPath, $encoding)

if ($content -notmatch 'addon test') {
    Write-Host "OK (no addon test paths): $FbxPath" -ForegroundColor DarkGray
    return
}

function Get-Padded([string]$Value, [int]$TargetLength) {
    if ($Value.Length -gt $TargetLength) {
        throw "Value longer than target ($($Value.Length) > $TargetLength): $Value"
    }
    return $Value + (' ' * ($TargetLength - $Value.Length))
}

$pathReplacements = @(
    @{
        Old = 'C:\Users\jared\OneDrive\Desktop\addon test\addons\lifepunch\lpbitcoin\hashdterminal\assets\Textures\textures4k\'
        New = Get-Padded 'addons/lifepunch/lpbitcoin/hashdterminal/assets/textures/' 111
    },
    @{
        Old = 'addon test\addons\lifepunch\lpbitcoin\hashdterminal\assets\Textures\textures4k\'
        New = Get-Padded 'addons/lifepunch/lpbitcoin/hashdterminal/assets/textures/' 79
    },
    @{
        Old = 'C:\Users\jared\OneDrive\Desktop\addon test\addons\lifepunch\lpbitcoin\hashdterminal\assets\source\HASHDTerminal.blend'
        New = Get-Padded 'addons/lifepunch/lpbitcoin/hashdterminal/assets/source/hashdterminal.blend' 117
    },
    @{
        Old = 'addon test\addons\lifepunch\lpbitcoin\hashdterminal\assets\source\HASHDTerminal.blend'
        New = Get-Padded 'addons/lifepunch/lpbitcoin/hashdterminal/assets/source/hashdterminal.blend' 85
    }
)

$fileRenames = @(
    @{ Old = 'Monitor_Color.tga'; New = 'monitor_color.tga' },
    @{ Old = 'Monitor_Emissive.tga'; New = 'monitor_emissive.tga' },
    @{ Old = 'Monitor_Normal.tga'; New = 'monitor_normal.tga' },
    @{ Old = 'Monitor_Roughness.tga'; New = 'monitor_roughness.tga' },
    @{ Old = 'Monitor_Metallic.tga'; New = 'monitor_metallic.tga' },
    @{ Old = 'Keyboard_mause_Color.tga'; New = 'keyboard_mause_color.tga' },
    @{ Old = 'Keyboard_mause_Normal.tga'; New = 'keyboard_mause_normal.tga' },
    @{ Old = 'Keyboard_mause_Roughness.tga'; New = 'keyboard_mause_roughness.tga' },
    @{ Old = 'Keyboard_mause_Metallic.tga'; New = 'keyboard_mause_metallic.tga' },
    @{ Old = 'Monitor_Color.vmat'; New = 'monitor_color.tga ' },
    @{ Old = 'Keyboard_mause_Color.vmat'; New = 'keyboard_mause_color.tga ' }
)

$patched = $content
foreach ($pair in $pathReplacements) {
    if ($pair.Old.Length -ne $pair.New.Length) {
        throw "Path length mismatch: $($pair.Old.Length) vs $($pair.New.Length)"
    }
    if ($patched.Contains($pair.Old)) {
        $patched = $patched.Replace($pair.Old, $pair.New)
    }
}

foreach ($pair in $fileRenames) {
    if ($pair.Old.Length -ne $pair.New.Length) {
        throw "Rename length mismatch: $($pair.Old) -> $($pair.New)"
    }
    $patched = $patched.Replace($pair.Old, $pair.New)
}

if ($patched -match 'addon test') {
    throw "Repair incomplete - addon test still present in $FbxPath"
}

if ($patched -eq $content) {
    Write-Host "No changes applied: $FbxPath" -ForegroundColor Yellow
    return
}

$backup = "$FbxPath.bak-addon-test-paths"
if (-not (Test-Path -LiteralPath $backup)) {
    Copy-Item -LiteralPath $FbxPath -Destination $backup -Force
}

[System.IO.File]::WriteAllText($FbxPath, $patched, $encoding)
Write-Host "Repaired embedded texture paths: $FbxPath" -ForegroundColor Green
Write-Host "  Backup: $backup" -ForegroundColor DarkGray
