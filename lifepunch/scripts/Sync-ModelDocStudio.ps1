<#
.SYNOPSIS
  Sync lp* ModelDoc assets into the standalone ModelDoc Studio game project.

.EXAMPLE
  powershell -File lifepunch\scripts\Sync-ModelDocStudio.ps1
  powershell -File lifepunch\scripts\Sync-ModelDocStudio.ps1 -Package lpbitcoin -Entity bitcoinhub
#>
[CmdletBinding()]
param(
    [string[]] $Package = @('lpbitcoin'),
    [string] $Entity = '',
    [string] $ConfigPath = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$repoRoot = Split-Path $Here -Parent
$placeScript = Join-Path (Resolve-Path (Join-Path $Here '..\..\lifepunchaddons')).Path 'scripts\Place-LifepunchModelDocAssets.ps1'

foreach ($pkg in $Package) {
    if ($Entity) {
        & $placeScript -Package $pkg -Entity $Entity -Studio
    }
    else {
        & $placeScript -Package $pkg -Studio
    }
}

# Update sbproj Resources for mounted packages
$sbprojPath = Join-Path $repoRoot 'modeldoc-studio\game\modeldoc.sbproj'
$content = Get-Content -LiteralPath $sbprojPath -Raw
$marker = '"Resources": "'
$start = $content.IndexOf($marker)
if ($start -lt 0) { throw 'modeldoc.sbproj Resources field not found' }
$valueStart = $start + $marker.Length
$valueEnd = $content.IndexOf('"', $valueStart)
$lines = @('scenes/**')
foreach ($pkg in $Package) {
    if ($Entity) {
        # Phase A: mount models only — source FBX stays on disk for vmdl refs, not boot-scanned.
        $lines += "addons/lifepunch/$pkg/$Entity/assets/models/**"
    }
    else {
        $lines += "addons/lifepunch/$pkg/**"
    }
}
$newResources = ($lines -join '\n')
$content = $content.Substring(0, $valueStart) + $newResources + $content.Substring($valueEnd)
[System.IO.File]::WriteAllText($sbprojPath, $content)
Write-Host "Updated Resources: $($Package -join ', ')" -ForegroundColor Green
