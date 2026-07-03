# Remove active hub duplicates from legacy bitcoinmining tree after Promote-BitcoinHubToLpBitcoin.ps1
# Also quarantine orphan entity textures if promotion copied sm_* to lpbitcoin already.
param( [switch] $WhatIf )
$ErrorActionPreference = 'Stop'
$repoAddons = (Join-Path $PSScriptRoot '..' | Resolve-Path).Path
$assets = Join-Path $repoAddons 'Assets\addons\lifepunch\bitcoinmining'

$legacyModel = Join-Path $assets 'models\lifepunch\bitcoinmining\bitcoin-miner'
$legacyEntity = Join-Path $assets 'entities\bitcoinminer'

$keepModel = @('MOVED.md', '_archive')
$keepEntity = @('MOVED.md', '_archive')

function Remove-Except([string]$Dir, [string[]]$KeepNames) {
    if (-not (Test-Path -LiteralPath $Dir)) { return }
    Get-ChildItem -LiteralPath $Dir -Force | ForEach-Object {
        if ($KeepNames -contains $_.Name) { return }
        if ($WhatIf) { Write-Host "[WhatIf] remove $($_.FullName)"; return }
        Remove-Item -LiteralPath $_.FullName -Recurse -Force
        Write-Host "Removed: $($_.Name)" -ForegroundColor Yellow
    }
}

Write-Host 'Strip legacy hub duplicates (canonical = lpbitcoin/bitcoinhub)' -ForegroundColor Cyan
Remove-Except $legacyModel $keepModel
Remove-Except $legacyEntity $keepEntity
Write-Host 'Done.' -ForegroundColor Green
