<#
.SYNOPSIS
  Pull hub source art from DXRP back to repo — fallback only.

  Prefer owner drop + Intake-LpBitcoinGreenfield.ps1:
    %USERPROFILE%\OneDrive\Desktop\addon test\addons\lifepunch\lpbitcoin\

.EXAMPLE
  powershell -File lifepunch\addons\scripts\Pull-LpBitcoinHubSourceFromDxrp.ps1
  powershell -File lifepunch\addons\scripts\Pull-LpBitcoinHubSourceFromDxrp.ps1 -SyncDxrp
#>
[CmdletBinding()]
param(
    [switch] $SyncDxrp
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $Here '..\..\scripts\Dxrp-LifepunchPaths.ps1')

$configPath = Join-Path (Split-Path $Here -Parent) '..\scripts\dxrp-editor.local.json'
if (-not (Test-Path -LiteralPath $configPath)) { throw "Missing $configPath" }

$dxrpGame = Get-DxrpGameRootFromConfig -ConfigPath $configPath
$src = Join-Path (Get-DxrpLifepunchAddonsDiskRoot -DxrpGameRoot $dxrpGame) 'lpbitcoin\bitcoinhub\assets'
$repoAddons = (Resolve-Path (Join-Path $Here '..')).Path
$dest = Join-Path $repoAddons 'Assets\addons\lifepunch\lpbitcoin\bitcoinhub\assets'

if (-not (Test-Path -LiteralPath $src)) { throw "Missing DXRP hub assets: $src" }

Write-Host 'Pull lpbitcoin/bitcoinhub/assets (DXRP -> repo)' -ForegroundColor Cyan
Write-Host "  From: $src" -ForegroundColor DarkGray
Write-Host "  To:   $dest" -ForegroundColor DarkGray

foreach ($rel in @('source\fbx', 'source\blend', 'textures')) {
    $from = Join-Path $src $rel
    $to = Join-Path $dest $rel
    if (-not (Test-Path -LiteralPath $from)) { continue }
    New-Item -ItemType Directory -Force -Path $to | Out-Null
    & robocopy $from $to /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy $rel failed ($LASTEXITCODE)" }
    Write-Host "  pulled $rel" -ForegroundColor Green
}

if ($SyncDxrp) {
    $prep = Join-Path (Split-Path $Here -Parent) '..\scripts\Prepare-LpBitcoinModelDoc.ps1'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $prep -Entity bitcoinhub
}

Write-Host 'Pull OK — commit repo when mesh is stable.' -ForegroundColor Green
