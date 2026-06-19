# Drop stale _c for bitcoinhub slot so ModelDoc recompiles from .vmdl / .vmat sources.
param(
    [switch] $WhatIf,
    [switch] $IncludeDxrp
)

$ErrorActionPreference = 'Stop'
$repoHub = Join-Path (Resolve-Path (Join-Path $PSScriptRoot '..')).Path 'Assets\addons\lifepunch\lpbitcoin\bitcoinhub'

$patterns = @('*.vmdl_c', '*.vmat_c', '*.prefab_c', '*.vtex_c')

function Remove-Compiled([string]$Root, [string]$Label) {
    if (-not (Test-Path -LiteralPath $Root)) {
        Write-Host "Skip $Label - not found" -ForegroundColor DarkGray
        return
    }
    foreach ($pat in $patterns) {
        Get-ChildItem -LiteralPath $Root -Recurse -Filter $pat -File -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -notmatch '\\_archive\\' } |
            ForEach-Object {
                if ($WhatIf) { Write-Host "[WhatIf] remove $($_.FullName)"; return }
                Remove-Item -LiteralPath $_.FullName -Force
                Write-Host "Removed: $($_.Name) [$Label]" -ForegroundColor Yellow
            }
    }
}

Write-Host 'Invalidate bitcoinhub compiled assets (_c)' -ForegroundColor Cyan
Remove-Compiled $repoHub 'repo'

if ($IncludeDxrp) {
    $cfg = Join-Path (Resolve-Path (Join-Path $PSScriptRoot '..\..\scripts')).Path 'dxrp-editor.local.json'
    if (Test-Path -LiteralPath $cfg) {
        $dxrp = (Get-Content $cfg -Raw | ConvertFrom-Json).projectPath
        $dxrpHub = Join-Path (Split-Path $dxrp -Parent) 'Assets\addons\lifepunch\lpbitcoin\bitcoinhub'
        Remove-Compiled $dxrpHub 'DXRP'
    }
}

Write-Host 'Done. Restart editor, open bitcoinhub.vmdl, Compile in ModelDoc.' -ForegroundColor Green
