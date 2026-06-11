<#
.SYNOPSIS
  Archive bitcoin-terminal prop mesh and promote ship tree into bitcoinmining/.

.PARAMETER SourceRoot
  Owner pack folder (default: Downloads bitcointerminal).

.PARAMETER ArchiveRoot
  Full mirror archive (blend stays archive-only).

.EXAMPLE
  powershell -File Intake-BitcoinTerminalAssets.ps1
#>
[CmdletBinding()]
param(
    [string] $SourceRoot = 'C:\Users\jared\Downloads\newaddons\hackerterminal\source\bitcointerminal',
    [string] $ArchiveRoot = 'C:\lifepunch\reference-intake\bitcoinmining\bitcoin-terminal-export',
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$AddonsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$TerminalRoot = Join-Path $AddonsRoot 'Assets\addons\lifepunch\bitcoinmining\models\lifepunch\bitcoinmining\bitcoin-terminal'
$SourceDest = Join-Path $TerminalRoot 'source'

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        if ($WhatIf) { Write-Host "[WhatIf] mkdir $Path" }
        else { New-Item -ItemType Directory -Force -Path $Path | Out-Null }
    }
}

function Copy-File([string]$From, [string]$To, [string]$Label) {
    if (-not (Test-Path -LiteralPath $From)) {
        throw "Missing source file: $From"
    }
    if ($WhatIf) {
        Write-Host "[WhatIf] COPY $Label"
        return
    }
    Ensure-Dir (Split-Path -Parent $To)
    Copy-Item -LiteralPath $From -Destination $To -Force
    Write-Host "  $Label" -ForegroundColor Green
}

Write-Host 'Bitcoin terminal intake' -ForegroundColor Cyan
Write-Host "  Source: $SourceRoot" -ForegroundColor DarkGray
Write-Host "  Archive: $ArchiveRoot" -ForegroundColor DarkGray
Write-Host "  Publish: $TerminalRoot" -ForegroundColor DarkGray

if (-not (Test-Path -LiteralPath $SourceRoot)) {
    throw "Missing source root: $SourceRoot"
}

$fbx = Join-Path $SourceRoot 'computer.fbx'
$blend = Join-Path $SourceRoot 'computer.blend'

if (-not $WhatIf) {
    Ensure-Dir $ArchiveRoot
    & robocopy $SourceRoot $ArchiveRoot /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "Archive failed ($LASTEXITCODE)" }
    Write-Host 'Archive OK' -ForegroundColor Green
}

Copy-File $fbx (Join-Path $SourceDest 'computer.fbx') 'source/computer.fbx -> publish'

if (-not $WhatIf) {
    $n = (Get-ChildItem $TerminalRoot -Recurse -File).Count
    Write-Host "Publish tree - $n files" -ForegroundColor Green
}

Write-Host 'Intake OK' -ForegroundColor Green
Write-Host '  Blend archived only (not in publish tree).' -ForegroundColor DarkGray
Write-Host '  Razor UI stays in Code/Addons/.../BitminerTerminal.razor' -ForegroundColor DarkGray
