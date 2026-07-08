<#
.SYNOPSIS
  Ship-tier publish staging for lifepunch.bitcoin — Assets + Code from DXRP editor game tree.

.DESCRIPTION
  Canonical compile + playtest truth (ModelDoc *_c + editor-compiled C#/Razor):

    Assets:  <dxrp-game>\Assets\addons\lifepunch\lpbitcoin\
    Code:    <dxrp-game>\Code\Addons\lifepunch\bitcoinmining\
             + <dxrp-game>\Code\Addons\lifepunch\lpbitcoin\bitcoinhub\code\  (merged into portal bundle)

  Default: Pull-DxrpCompiledAssetsToRepo.ps1 backports *_c into git, then stages from DXRP game paths.
  Output:  lifepunchaddons/.dxrp-publish/upload/lifepunch/lpbitcoin/{Assets,Code}/

.PARAMETER SkipPull
  Do not backport compiled *_c from DXRP into the repo before staging (default: pull first).

.PARAMETER OpenFolder
  Open .dxrp-publish/upload when done.

.EXAMPLE
  powershell -File lifepunch\scripts\Prepare-LpBitcoinPublish.ps1
  powershell -File lifepunch\scripts\Prepare-LpBitcoinPublish.ps1 -SkipPull -OpenFolder
#>
[CmdletBinding()]
param(
    [switch] $SkipPull,
    [switch] $OpenFolder,
    [string] $DxrpConfigPath = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$RepoRoot = Split-Path -Parent $Here
$AddonsRoot = (Resolve-Path (Join-Path $Here '..\..\lifepunchaddons')).Path
$PreparePublish = Join-Path $AddonsRoot 'scripts\prepare-publish.ps1'
$PullCompiled = Join-Path $Here 'Pull-DxrpCompiledAssetsToRepo.ps1'

if (-not $DxrpConfigPath) {
    $DxrpConfigPath = Join-Path $Here 'dxrp-editor.local.json'
}

if (-not (Test-Path -LiteralPath $PreparePublish)) {
    throw "Missing prepare-publish.ps1: $PreparePublish"
}

$cfg = Get-Content -LiteralPath $DxrpConfigPath -Raw | ConvertFrom-Json
$dxrpGame = Split-Path -Parent ([string]$cfg.projectPath)
$dxrpAssets = Join-Path $dxrpGame 'Assets\addons\lifepunch\lpbitcoin'
$dxrpCode = Join-Path $dxrpGame 'Code\Addons\lifepunch\bitcoinmining'
$dxrpHubCode = Join-Path $dxrpGame 'Code\Addons\lifepunch\lpbitcoin\bitcoinhub\code'

Write-Host 'LIFEPUNCH Bitcoin — portal publish prep' -ForegroundColor Cyan
Write-Host "  DXRP game root: $dxrpGame" -ForegroundColor DarkGray
Write-Host "  Assets: $dxrpAssets" -ForegroundColor DarkGray
Write-Host "  Code:   $dxrpCode" -ForegroundColor DarkGray
Write-Host "          + $dxrpHubCode" -ForegroundColor DarkGray

if (-not (Test-Path -LiteralPath $dxrpAssets -PathType Container)) {
    throw @"
DXRP lpbitcoin assets missing. Run:
  powershell -File lifepunch\scripts\Sync-LifePunchAddonsToDxrp.ps1 -Addon lpbitcoin
Then compile vmdl/prefab in ModelDoc and retry.
"@
}

if (-not (Test-Path -LiteralPath $dxrpCode -PathType Container)) {
    throw @"
DXRP bitcoinmining code missing. Run:
  powershell -File lifepunch\scripts\Sync-LifePunchAddonsToDxrp.ps1 -Addon lpbitcoin
Then Stop -> Play (compile) and retry.
"@
}

if (-not $SkipPull) {
    Write-Host 'Pulling compiled *_c from DXRP -> repo (git backup)...' -ForegroundColor Cyan
    & $PullCompiled -Addon lpbitcoin -ConfigPath $DxrpConfigPath
}

$prepareArgs = @{
    Addon           = 'bitcoinmining'
    FromDxrpGame    = $true
    DxrpConfigPath  = $DxrpConfigPath
}
if ($OpenFolder) { $prepareArgs['OpenFolder'] = $true }

& $PreparePublish @prepareArgs

Write-Host ''
Write-Host 'Portal upload (pick these two folders on dxrp.net):' -ForegroundColor Green
Write-Host '  lifepunch\lpbitcoin\Assets' -ForegroundColor Green
Write-Host '  lifepunch\lpbitcoin\Code' -ForegroundColor Green
Write-Host 'Staging root: lifepunchaddons/.dxrp-publish/upload/' -ForegroundColor DarkGray
Write-Host 'Package export: .dxrp-publish/package-bitcoinmining.json' -ForegroundColor DarkGray
