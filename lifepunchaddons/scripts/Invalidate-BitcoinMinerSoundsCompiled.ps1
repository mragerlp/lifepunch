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
  Drop stale bitcoinminer sound _c files that still reference legacy bitcoinmining/ wav paths.

.DESCRIPTION
  Compiled .vsnd_c / .sound_c baked deps like:
    addons/lifepunch/bitcoinmining/sounds/bitcoinminer/*.wav
  After lpbitcoin path migration, on-demand recompile fails and hub SFX 404.

.PARAMETER IncludeDxrp
  Also purge the DXRP game copy (requires dxrp-editor.local.json).

.EXAMPLE
  powershell -File Invalidate-BitcoinMinerSoundsCompiled.ps1 -IncludeDxrp
#>
[CmdletBinding()]
param(
    [switch] $WhatIf,
    [switch] $IncludeDxrp
)

$ErrorActionPreference = 'Stop'
$repoSounds = Join-Path (Resolve-Path (Join-Path $PSScriptRoot '..')).Path `
    'Assets\addons\lifepunch\lpbitcoin\bitcoinhub\assets\sounds\bitcoinminer'

$patterns = @('*.sound_c', '*.vsnd_c')

function Remove-CompiledSounds {
    param([string]$Root, [string]$Label)
    if (-not (Test-Path -LiteralPath $Root)) {
        Write-Host "Skip $Label - not found" -ForegroundColor DarkGray
        return
    }
    foreach ($pat in $patterns) {
        Get-ChildItem -LiteralPath $Root -Recurse -Filter $pat -File -ErrorAction SilentlyContinue |
            ForEach-Object {
                if ($WhatIf) {
                    Write-Host "[WhatIf] remove $($_.FullName)" -ForegroundColor DarkGray
                    return
                }
                Remove-Item -LiteralPath $_.FullName -Force
                Write-Host "Removed: $($_.Name) [$Label]" -ForegroundColor Yellow
            }
    }
}

Write-Host 'Invalidate bitcoinminer sound compiled assets (_c)' -ForegroundColor Cyan
Remove-CompiledSounds -Root $repoSounds -Label 'repo'

if ($IncludeDxrp) {
    $cfg = Join-Path (Resolve-Path (Join-Path $PSScriptRoot '..\..\scripts')).Path 'dxrp-editor.local.json'
    if (Test-Path -LiteralPath $cfg) {
        $dxrp = (Get-Content $cfg -Raw | ConvertFrom-Json).projectPath
        $dxrpSounds = Join-Path (Split-Path $dxrp -Parent) `
            'Assets\addons\lifepunch\lpbitcoin\bitcoinhub\assets\sounds\bitcoinminer'
        Remove-CompiledSounds -Root $dxrpSounds -Label 'DXRP'
    }
}

Write-Host 'Done. In editor: select each .wav under bitcoinminer, compile to .vsnd, then compile .sound.' -ForegroundColor Green
