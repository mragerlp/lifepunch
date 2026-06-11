<#
.SYNOPSIS
  Seed hackerjob CRT source meshes from the LifePunch-owned bitminer computer.fbx family.

.DESCRIPTION
  Copies computer.fbx into hacker-terminal and advanced-hacker-terminal source/ folders.
  Reference-only archive optional. Never pulls raw CS2 or third-party exports into publish.

.PARAMETER SourceFbx
  LifePunch-owned FBX (default: bitminer bitcoin-terminal ship tree).

.PARAMETER ArchiveRoot
  Optional mirror under reference-intake.

.EXAMPLE
  powershell -File Seed-HackerTerminalCrt.ps1
#>
[CmdletBinding()]
param(
    [string] $SourceFbx = '',
    [string] $ArchiveRoot = 'C:\lifepunch\reference-intake\hackerjob\crt-computer',
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$AddonsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$AssetsRoot = Join-Path $AddonsRoot 'Assets\addons\lifepunch\hackerjob\models\lifepunch\hackerjob'

if (-not $SourceFbx) {
    $SourceFbx = Join-Path $AddonsRoot 'Assets\addons\lifepunch\bitcoinmining\models\lifepunch\bitcoinmining\bitcoin-terminal\source\computer.fbx'
}

$targets = @(
    @{ slug = 'hacker-terminal'; dest = Join-Path $AssetsRoot 'hacker-terminal\source\computer.fbx' }
    @{ slug = 'advanced-hacker-terminal'; dest = Join-Path $AssetsRoot 'advanced-hacker-terminal\source\computer.fbx' }
)

function Ensure-Dir([string]$Path) {
    if ($WhatIf) { Write-Host "[WhatIf] mkdir $Path"; return }
    if (-not (Test-Path -LiteralPath $Path)) { New-Item -ItemType Directory -Force -Path $Path | Out-Null }
}

function Copy-Fbx([string]$From, [string]$To, [string]$Label) {
    if (-not (Test-Path -LiteralPath $From)) {
        throw "Missing LifePunch source FBX: $From`nRun Intake-BitcoinTerminalAssets.ps1 on bitminer first, or pass -SourceFbx."
    }
    if ($WhatIf) {
        Write-Host "[WhatIf] COPY $Label"
        return
    }
    Ensure-Dir (Split-Path -Parent $To)
    Copy-Item -LiteralPath $From -Destination $To -Force
    Write-Host "  $Label" -ForegroundColor Green
}

Write-Host 'Hacker terminal CRT seed' -ForegroundColor Cyan
Write-Host "  Source: $SourceFbx" -ForegroundColor DarkGray
Write-Host "  Dest:   $AssetsRoot" -ForegroundColor DarkGray

if (-not $WhatIf) {
    Ensure-Dir $ArchiveRoot
    Copy-Item -LiteralPath $SourceFbx -Destination (Join-Path $ArchiveRoot 'computer.fbx') -Force
    Write-Host 'Archive OK' -ForegroundColor Green
}

foreach ($t in $targets) {
    Copy-Fbx $SourceFbx $t.dest "$($t.slug) <- computer.fbx"
}

if (-not $WhatIf) {
    $n = (Get-ChildItem (Join-Path $AddonsRoot 'Assets\addons\lifepunch\hackerjob') -Recurse -File -ErrorAction SilentlyContinue).Count
    Write-Host "hackerjob Assets tree - $n files" -ForegroundColor Green
}

Write-Host 'Seed OK - open hacker-terminal.vmdl and advanced-hacker-terminal.vmdl in ModelDoc.' -ForegroundColor Green
