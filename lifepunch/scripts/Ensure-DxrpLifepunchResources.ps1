<#
.SYNOPSIS
  Ensure rp.sbproj Resources includes LifePunch addon mounts (merge — never drop unrelated mounts).
#>
[CmdletBinding()]
param(
    [string[]] $Ident = @(),
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

$dxrpGame = Split-Path -Parent $sbprojPath
$dxrpAssetsRoot = Join-Path $dxrpGame 'Assets\addons\lifepunch'

function Get-ResourceMountLines([string]$RawContent) {
    $m = [regex]::Match($RawContent, '"Resources"\s*:\s*"((?:[^"\\]|\\.)*)"')
    if (-not $m.Success) { return @() }
    $escaped = $m.Groups[1].Value
    $unescaped = $escaped -replace '\\n', [Environment]::NewLine
    return @($unescaped -split '\r?\n' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
}

function Resolve-MountIdent([string]$Ident) {
    if ($Ident -in @('lpbitcoin', 'lifepunchbitcoin', 'bitcoinmining')) { return $null }
    return $Ident
}

$content = Get-Content -LiteralPath $sbprojPath -Raw
$existing = Get-ResourceMountLines $content

$mounts = [System.Collections.Generic.List[string]]::new()
$seen = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)

function Add-Mount([string]$Line) {
    if ([string]::IsNullOrWhiteSpace($Line)) { return }
    $Line = $Line.Trim().TrimEnd('\')
    if ([string]::IsNullOrWhiteSpace($Line)) { return }
    if ($seen.Add($Line)) { $mounts.Add($Line) | Out-Null }
}

foreach ($line in @('ui/*', 'gameplay/entities/jobs/mayor/gun_license/gun_license.png')) {
    Add-Mount $line
}

foreach ($line in $existing) {
    $line = $line.Trim().TrimEnd('\')
    if ($line -notmatch '^addons/lifepunch/') {
        if ($line -in @('ui/*', 'gameplay/entities/jobs/mayor/gun_license/gun_license.png')) { continue }
        Add-Mount $line
    }
}

foreach ($line in $existing) {
    $line = $line.Trim().TrimEnd('\')
    if ($line -notmatch '^addons/lifepunch/([^/]+)/') { continue }
    $folder = $Matches[1]
    if ($folder -eq 'bitcoinmining') { continue }
    if ($folder -eq 'UPLOAD') { continue }
    $folderPath = Join-Path $dxrpAssetsRoot $folder
    if (Test-Path -LiteralPath $folderPath) {
        Add-Mount $line
    }
}

foreach ($ident in $Ident) {
    $mountIdent = Resolve-MountIdent $ident
    if (-not $mountIdent) { continue }
    Add-Mount "addons/lifepunch/$mountIdent/**"
}

if ($IncludeStaging) {
    Add-Mount 'addons/lifepunch/lpbitcoin/**'
}

$resourcesForFile = ($mounts | Select-Object -Unique) -join '\n'
$content = [regex]::Replace(
    $content,
    '"Resources"\s*:\s*"(?:[^"\\]|\\.)*"',
    '"Resources": "' + ($resourcesForFile -replace '\\', '\\') + '"'
)

[System.IO.File]::WriteAllText($sbprojPath, $content)
Write-Host 'rp.sbproj Resources merged (existing LifePunch mounts preserved):' -ForegroundColor Green
$mounts | Select-Object -Unique | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }
Write-Host 'Restart s&box editor if it was open (Resources changed).' -ForegroundColor Yellow
