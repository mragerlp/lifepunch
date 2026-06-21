<#
.SYNOPSIS
  Seed a clean DXRP editor workbench - sibling folder, no LifePunch mounts by default.

.DESCRIPTION
  One-time (or -ForceRefresh) mirror of your live DXRP game folder into dxrp-vanilla/game,
  then:
    - rp.sbproj Resources reset to DXRP vanilla (ui/* + gun_license only)
    - Assets/addons/lifepunch moved offline (outside the game tree)
    - Code/Addons/lifepunch removed from the vanilla workbench

  Repo remains source of truth. When you need ULX or lpbitcoin in the workbench, sync explicitly:
    Sync-LifePunchAddonsToDxrp.ps1 -Addon adminmenu -ConfigPath dxrp-vanilla-editor.local.json

  Does NOT modify your existing dxrp/game install (reads it as the copy source only).

.EXAMPLE
  powershell -File lifepunch\scripts\Initialize-DxrpVanillaWorkbench.ps1
  powershell -File lifepunch\scripts\Initialize-DxrpVanillaWorkbench.ps1 -ForceRefresh
  powershell -File lifepunch\scripts\Initialize-DxrpVanillaWorkbench.ps1 -Launch
#>
[CmdletBinding()]
param(
    [string] $SourceConfigPath = '',
    [string] $TargetGameRoot = '',
    [switch] $ForceRefresh,
    [switch] $Launch,
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
. (Join-Path $Here 'Dxrp-LifepunchPaths.ps1')
. (Join-Path $Here 'Dxrp-VanillaWipe.ps1')

if (-not $SourceConfigPath) { $SourceConfigPath = Join-Path $Here 'dxrp-editor.local.json' }
if (-not (Test-Path -LiteralPath $SourceConfigPath)) {
    throw "Missing source config $SourceConfigPath - copy dxrp-editor.local.json.example first."
}

$sourceGame = Get-DxrpGameRootFromConfig -ConfigPath $SourceConfigPath
if (-not (Test-Path -LiteralPath $sourceGame)) { throw "Source DXRP game not found: $sourceGame" }

if (-not $TargetGameRoot) {
    $sboxRoot = Split-Path -Parent (Split-Path -Parent $sourceGame)
    $TargetGameRoot = Join-Path $sboxRoot 'dxrp-vanilla\game'
}

$targetGame = $TargetGameRoot
$targetSbproj = Join-Path $targetGame 'rp.sbproj'
$vanillaConfigExample = Join-Path $Here 'dxrp-vanilla-editor.local.json.example'
$vanillaConfigLocal = Join-Path $Here 'dxrp-vanilla-editor.local.json'

function Write-Step([string] $Message) {
    Write-Host $Message -ForegroundColor Cyan
}

function Set-VanillaRpResources {
    param([string] $SbprojPath)
    $vanillaResources = @(
        'ui/*'
        'gameplay/entities/jobs/mayor/gun_license/gun_license.png'
    ) -join '\n'

    $content = Get-Content -LiteralPath $SbprojPath -Raw
    $marker = '"Resources": "'
    $start = $content.IndexOf($marker)
    if ($start -lt 0) { throw "rp.sbproj Resources field not found: $SbprojPath" }
    $valueStart = $start + $marker.Length
    $valueEnd = $content.IndexOf('"', $valueStart)
    $content = $content.Substring(0, $valueStart) + $vanillaResources + $content.Substring($valueEnd)
    if ($WhatIf) {
        Write-Host "[WhatIf] vanilla Resources -> $SbprojPath" -ForegroundColor DarkGray
        return
    }
    [System.IO.File]::WriteAllText($SbprojPath, $content)
    Write-Host "  rp.sbproj -> vanilla Resources" -ForegroundColor Green
}

function Remove-TreeIfExists {
    param([string] $Path, [string] $Label)
    if (-not (Test-Path -LiteralPath $Path)) { return }
    if ($WhatIf) {
        Write-Host "[WhatIf] remove $Label" -ForegroundColor DarkGray
        return
    }
    Remove-Item -LiteralPath $Path -Recurse -Force
    Write-Host "  removed $Label" -ForegroundColor Yellow
}

Stop-Process -Name 'sbox-dev' -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

$needsSeed = $ForceRefresh -or -not (Test-Path -LiteralPath $targetSbproj)
if ($needsSeed) {
    Write-Step "Mirror DXRP -> vanilla workbench"
    Write-Host "  from: $sourceGame"
    Write-Host "  to:   $targetGame"
    if ($WhatIf) {
        Write-Host '[WhatIf] robocopy /E (excluding lifepunch trees)' -ForegroundColor DarkGray
    }
    else {
        New-Item -ItemType Directory -Force -Path $targetGame | Out-Null
        $robocopyArgs = @(
            $sourceGame, $targetGame,
            '/E', '/R:2', '/W:2', '/NFL', '/NDL', '/NJH', '/NJS', '/nc', '/ns', '/np',
            '/XD', 'Assets\addons\lifepunch', 'Code\Addons\lifepunch', 'lpaddondev', '_lifepunch-offline',
            'Code\_sui_scratch', 'Code\_sui_preview'
        )
        & robocopy @robocopyArgs | Out-Null
        if ($LASTEXITCODE -ge 8) { throw "robocopy failed (exit $LASTEXITCODE)" }
        Write-Host '  mirror OK' -ForegroundColor Green
    }
}
else {
    Write-Host "Vanilla workbench already exists: $targetGame" -ForegroundColor DarkGray
    Write-Host '  Pass -ForceRefresh to re-copy from source DXRP.' -ForegroundColor DarkGray
}

if (-not $WhatIf -and -not (Test-Path -LiteralPath $targetSbproj)) {
    throw "Seed failed - missing $targetSbproj"
}

Write-Step 'Strip LifePunch from vanilla workbench'
if (-not $WhatIf) {
    Invoke-DxrpVanillaLifePunchWipe -DxrpGameRoot $targetGame
}
else {
    Write-Host '[WhatIf] Invoke-DxrpVanillaLifePunchWipe' -ForegroundColor DarkGray
}

$exampleJson = @{
    sboxDevPath = 'D:/Steam/steamapps/common/sbox/sbox-dev.exe'
    projectPath = ($targetSbproj -replace '\\', '/')
    serverToken = ''
    api         = 'production'
    _notes      = 'Vanilla DXRP workbench - no LifePunch mounts. Sync addons explicitly via Sync-LifePunchAddonsToDxrp.ps1 -ConfigPath dxrp-vanilla-editor.local.json -Addon <ident>. Launch: Start-SboxDxrpVanillaEditor.ps1'
} | ConvertTo-Json -Depth 3

if (-not $WhatIf) {
    Set-Content -LiteralPath $vanillaConfigExample -Value $exampleJson -Encoding UTF8
    if (-not (Test-Path -LiteralPath $vanillaConfigLocal)) {
        Copy-Item -LiteralPath $vanillaConfigExample -Destination $vanillaConfigLocal -Force
        Write-Host "Created $vanillaConfigLocal (edit sboxDevPath if needed)." -ForegroundColor Green
    }
}

Write-Host ''
Write-Host 'Vanilla DXRP workbench ready.' -ForegroundColor Green
Write-Host "  Game root: $targetGame"
Write-Host '  Launch:    powershell -File lifepunch\scripts\Start-SboxDxrpVanillaEditor.ps1 -ReplaceExisting'
Write-Host '  No LifePunch sync into vanilla (Sync script blocks unless -AllowVanillaSync).' -ForegroundColor DarkGray

if ($Launch -and -not $WhatIf) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Here 'Start-SboxDxrpVanillaEditor.ps1') -ReplaceExisting -SkipPreflight
}
