<#
.SYNOPSIS
  Unfreeze s&box when lpbitcoin hub auto-compile stalls DXRP boot.

.DESCRIPTION
  1. Kills frozen sbox-dev
  2. Removes lpbitcoin from DXRP rp.sbproj Resources (DXRP usable again)
  3. Syncs bitcoinhub -> ModelDoc Studio
  4. Mounts hub models only in lightweight modeldoc.sbproj
  5. Launches ModelDoc Studio (not DXRP)

.EXAMPLE
  powershell -File lifepunch\scripts\Unblock-ModelDocEditor.ps1
#>
[CmdletBinding()]
param(
    [switch] $DxrpOnly,
    [switch] $NoLaunch
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$repoRoot = Split-Path $Here -Parent

Stop-Process -Name 'sbox-dev' -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Write-Host 'Stopped sbox-dev (was likely frozen on cpu-gamer import stall).' -ForegroundColor Yellow

$configPath = Join-Path $Here 'dxrp-editor.local.json'
if (Test-Path -LiteralPath $configPath) {
    $cfg = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
    $sbprojPath = [string]$cfg.projectPath
    if (Test-Path -LiteralPath $sbprojPath) {
        $content = Get-Content -LiteralPath $sbprojPath -Raw
        $marker = '"Resources": "'
        $start = $content.IndexOf($marker)
        if ($start -ge 0) {
            $valueStart = $start + $marker.Length
            $valueEnd = $content.IndexOf('"', $valueStart)
            $resourcesBlock = $content.Substring($valueStart, $valueEnd - $valueStart)
            $lines = $resourcesBlock -split '\\n' | Where-Object {
                $_ -and ($_ -notmatch 'addons/lifepunch/lpbitcoin')
            }
            $newResources = ($lines | Select-Object -Unique) -join '\n'
            $content = $content.Substring(0, $valueStart) + $newResources + $content.Substring($valueEnd)
            [System.IO.File]::WriteAllText($sbprojPath, $content)
            Write-Host 'DXRP rp.sbproj: removed lpbitcoin mount (editor boot safe).' -ForegroundColor Green
        }
    }
}

if ($DxrpOnly) {
    Write-Host 'DxrpOnly — relaunch DXRP yourself: Start-SboxDxrpEditor.ps1 -NoSync -SkipPreflight' -ForegroundColor Cyan
    return
}

$studioSbproj = Join-Path $repoRoot 'modeldoc-studio\game\modeldoc.sbproj'
$hubMount = 'addons/lifepunch/lpbitcoin/bitcoinhub/assets/models/**'
$content = Get-Content -LiteralPath $studioSbproj -Raw
$marker = '"Resources": "'
$start = $content.IndexOf($marker)
$valueStart = $start + $marker.Length
$valueEnd = $content.IndexOf('"', $valueStart)
$newResources = (@('scenes/**', $hubMount) -join '\n')
$content = $content.Substring(0, $valueStart) + $newResources + $content.Substring($valueEnd)
[System.IO.File]::WriteAllText($studioSbproj, $content)
Write-Host "ModelDoc Studio Resources -> scenes + $hubMount" -ForegroundColor Green

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Here 'Sync-ModelDocStudio.ps1') -Package lpbitcoin -Entity bitcoinhub

if (-not $NoLaunch) {
    Write-Host 'Relaunching DXRP (lpbitcoin unmounted — safe boot)...' -ForegroundColor Cyan
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Here 'Start-SboxDxrpEditor.ps1') -NoSync -SkipPreflight
}

Write-Host ''
Write-Host 'Hub blocked: cpu_gamer.fbx has ~97 Blender material slots; vmdl remaps stall auto-compile.' -ForegroundColor Yellow
Write-Host 'Next hub step: open cpu-gamer.vmdl in ModelDoc manually (do NOT remount lpbitcoin on boot).' -ForegroundColor Cyan
Write-Host 'DXRP dev work is fine — lpbitcoin stays off rp.sbproj until hub _c exists.' -ForegroundColor DarkGray
