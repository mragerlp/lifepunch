<#
.SYNOPSIS
  Launch s&box editor on standalone LIFEPUNCH ModelDoc Studio (no DXRP).

.EXAMPLE
  powershell -File lifepunch\scripts\Start-SboxModelDocStudio.ps1
  powershell -File lifepunch\scripts\Start-SboxModelDocStudio.ps1 -Package lpbitcoin -Entity bitcoinhub
#>
[CmdletBinding()]
param(
    [string[]] $Package = @('lpbitcoin'),
    [string] $Entity = '',
    [switch] $NoSync,
    [string] $ConfigPath = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $ConfigPath) { $ConfigPath = Join-Path $Here 'modeldoc-studio.local.json' }

$sweepExec = Join-Path $Here 'Sweep-SboxExecSnippets.ps1'
if (Test-Path -LiteralPath $sweepExec) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $sweepExec
}

if (-not $NoSync) {
    $sync = Join-Path $Here 'Sync-ModelDocStudio.ps1'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $sync -Package $Package $(if ($Entity) { '-Entity'; $Entity })
    Write-Host ''
}

if (-not (Test-Path -LiteralPath $ConfigPath)) {
    $example = Join-Path $Here 'modeldoc-studio.local.json.example'
    $defaultProject = (Resolve-Path (Join-Path $Here '..\modeldoc-studio\game\modeldoc.sbproj')).Path
    @"
Missing $ConfigPath

Copy modeldoc-studio.local.json.example -> modeldoc-studio.local.json
Default projectPath: $defaultProject
"@ | Write-Host -ForegroundColor Red
    exit 1
}

$cfg = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
$sbox = [string]$cfg.sboxDevPath
$project = [string]$cfg.projectPath

if (-not (Test-Path -LiteralPath $sbox)) { throw "s&box not found: $sbox" }
if (-not (Test-Path -LiteralPath $project)) { throw "ModelDoc Studio project not found: $project" }

Write-Host 'Launching ModelDoc Studio (no DXRP gamemode)...' -ForegroundColor Green
Write-Host "  Project: $project" -ForegroundColor DarkGray
Write-Host '  Scene:   scenes/modeldoc-blank.scene' -ForegroundColor DarkGray
Write-Host '  Law:     MODELDOC_STUDIO_LANE.md' -ForegroundColor DarkGray
Write-Host ''

Start-Process -FilePath $sbox -ArgumentList @('-project', $project) -WorkingDirectory (Split-Path -Parent $sbox)
