<#
.SYNOPSIS
  Intake owner hacker terminal FBX into lifepunch hackerjob (replaces seeded computer.fbx).

.PARAMETER SourceFbx
  Default: Downloads\hackerterminal\hackerterminal.fbx

.EXAMPLE
  powershell -File Intake-HackerTerminalModel.ps1
#>
[CmdletBinding()]
param(
    [string] $SourceFbx = "$env:USERPROFILE\Downloads\hackerterminal\hackerterminal.fbx",
    [string] $ArchiveRoot = 'C:\lifepunch\reference-intake\hackerjob\hackerterminal-v2',
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$AddonsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$HackerAssets = Join-Path $AddonsRoot 'Assets\addons\lifepunch\hackerjob'
$IntakeRaw = Join-Path $HackerAssets 'intake-raw\hackerterminal-v2'

$Targets = @(
    @{ slug = 'hacker-terminal'; rel = 'models\lifepunch\hackerjob\hacker-terminal\source\hacker-terminal.fbx' }
    @{ slug = 'advanced-hacker-terminal'; rel = 'models\lifepunch\hackerjob\advanced-hacker-terminal\source\hacker-terminal.fbx' }
)

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        if ($WhatIf) { Write-Host "[WhatIf] mkdir $Path" }
        else { New-Item -ItemType Directory -Force -Path $Path | Out-Null }
    }
}

function Write-Utf8NoBom([string]$Path, [string]$Content) {
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Content, $utf8)
}

if (-not (Test-Path -LiteralPath $SourceFbx)) {
    throw "Missing FBX: $SourceFbx"
}

Write-Host 'Hacker terminal model intake' -ForegroundColor Cyan
Write-Host "  Source: $SourceFbx" -ForegroundColor DarkGray
Write-Host "  Archive: $ArchiveRoot" -ForegroundColor DarkGray

if (-not $WhatIf) {
    Ensure-Dir $ArchiveRoot
    Copy-Item -LiteralPath $SourceFbx -Destination (Join-Path $ArchiveRoot 'hackerterminal.fbx') -Force
    Ensure-Dir $IntakeRaw
    Copy-Item -LiteralPath $SourceFbx -Destination (Join-Path $IntakeRaw 'hackerterminal.fbx') -Force
    Write-Host 'Archive OK' -ForegroundColor Green
}

foreach ($t in $Targets) {
    $dest = Join-Path $HackerAssets $t.rel
    if ($WhatIf) {
        Write-Host "[WhatIf] $($t.slug) -> $dest" -ForegroundColor DarkGray
        continue
    }
    Ensure-Dir (Split-Path -Parent $dest)
    Copy-Item -LiteralPath $SourceFbx -Destination $dest -Force
    Write-Host "  $($t.slug) OK" -ForegroundColor Green
}

Write-Host 'Intake OK - update vmdl filename + ModelDoc material slots, then compile.' -ForegroundColor Green
