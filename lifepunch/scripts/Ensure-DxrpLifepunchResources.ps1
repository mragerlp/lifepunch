<#
.SYNOPSIS
  Ensure rp.sbproj Resources includes LifePunch addon mounts (clean, one mount per line).
#>
[CmdletBinding()]
param(
    [string[]] $Ident = @('bitcoinmining'),
    [switch] $IncludeStaging,
    [string] $ConfigPath = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $ConfigPath) { $ConfigPath = Join-Path $Here 'dxrp-editor.local.json' }
if (-not (Test-Path -LiteralPath $ConfigPath)) {
    Write-Warning "Skip rp.sbproj Resources patch - missing $ConfigPath"
    return
}

$cfg = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
$sbprojPath = [string]$cfg.projectPath
if ([string]::IsNullOrWhiteSpace($sbprojPath) -or -not (Test-Path -LiteralPath $sbprojPath)) {
    Write-Warning "Skip rp.sbproj Resources patch - bad projectPath: $sbprojPath"
    return
}

$mounts = [System.Collections.Generic.List[string]]::new()
$mounts.Add('ui/*')
$mounts.Add('gameplay/entities/jobs/mayor/gun_license/gun_license.png')

foreach ($ident in $Ident) {
    $mounts.Add("addons/lifepunch/$ident/**")
}
if ($IncludeStaging) {
    $mounts.Add('addons/lifepunch/lpbitcoin/**')
}

$resourcesForFile = ($mounts | Select-Object -Unique) -join '\n'
$content = Get-Content -LiteralPath $sbprojPath -Raw
$content = [regex]::Replace(
    $content,
    '"Resources"\s*:\s*"(?:[^"\\]|\\.)*"',
    '"Resources": "' + ($resourcesForFile -replace '\\', '\\') + '"'
)

[System.IO.File]::WriteAllText($sbprojPath, $content)
Write-Host 'rp.sbproj Resources normalized:' -ForegroundColor Green
$mounts | Select-Object -Unique | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }
Write-Host 'Restart s&box editor if it was open (Resources changed).' -ForegroundColor Yellow
