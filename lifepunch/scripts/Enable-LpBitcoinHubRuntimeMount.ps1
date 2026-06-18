<#
.SYNOPSIS
  Mount compiled bitcoinhub models in rp.sbproj so Model.Load works in Host Play.

.DESCRIPTION
  Vanilla boot (Reset-DxrpVanillaBoot) strips all lifepunch mounts — correct for compile
  stalls, but playtest ConCmds need the hub _c path in Resources.

  Mounts ONLY bitcoinhub/assets/models/** (compiled vmdl/vmat/_c). Source FBX stays off
  Resources. With bitcoin-hub.vmdl_c on disk, boot loads compiled hub without re-importing source FBX.

.EXAMPLE
  powershell -File lifepunch\scripts\Enable-LpBitcoinHubRuntimeMount.ps1
#>
[CmdletBinding()]
param(
    [string] $ConfigPath = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $ConfigPath) { $ConfigPath = Join-Path $Here 'dxrp-editor.local.json' }
if (-not (Test-Path -LiteralPath $ConfigPath)) { throw "Missing $ConfigPath" }

$cfg = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
$sbprojPath = [string]$cfg.projectPath
$hubMountModels = 'addons/lifepunch/lpbitcoin/bitcoinhub/assets/models/**'
$hubMountTextures = 'addons/lifepunch/lpbitcoin/bitcoinhub/assets/textures/**'

$hubVmdlC = Join-Path (Split-Path -Parent $sbprojPath) 'Assets\addons\lifepunch\lpbitcoin\bitcoinhub\assets\models\bitcoin-hub.vmdl_c'
if (-not (Test-Path -LiteralPath $hubVmdlC)) {
    throw "Missing compiled hub: $hubVmdlC - compile bitcoin-hub.vmdl in ModelDoc first."
}

$content = Get-Content -LiteralPath $sbprojPath -Raw
$marker = '"Resources": "'
$start = $content.IndexOf($marker)
if ($start -lt 0) { throw 'rp.sbproj Resources field not found' }
$valueStart = $start + $marker.Length
$valueEnd = $content.IndexOf('"', $valueStart)
$current = $content.Substring($valueStart, $valueEnd - $valueStart)
$lines = [System.Collections.Generic.List[string]]::new()
foreach ($line in ($current -split '\\n')) {
    $t = $line.Trim()
    if ($t) { $lines.Add($t) }
}
foreach ($m in @($hubMountModels, $hubMountTextures)) {
    if ($lines -notcontains $m) { $lines.Add($m) }
}

$newResources = ($lines | Select-Object -Unique) -join '\n'
$content = $content.Substring(0, $valueStart) + $newResources + $content.Substring($valueEnd)
[System.IO.File]::WriteAllText($sbprojPath, $content)

Write-Host 'rp.sbproj: mounted bitcoinhub models for runtime load' -ForegroundColor Green
Write-Host "  + $hubMountModels" -ForegroundColor DarkGray
Write-Host "  + $hubMountTextures" -ForegroundColor DarkGray
Write-Host 'Restart the DXRP editor (or reload project) then Host Play blank.scene -> lp_spawn_staging_hub' -ForegroundColor Yellow
