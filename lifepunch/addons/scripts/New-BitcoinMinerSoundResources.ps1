<#
.SYNOPSIS
  Author .sound JSON resources for bitcoinminer P0 slots (post-intake, pre-vsnd compile).
#>
[CmdletBinding()]
param(
    [string] $SoundRoot
)

if (-not $SoundRoot) {
    $scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
    $AddonsRoot = (Resolve-Path (Join-Path $scriptDir '..')).Path
    $SoundRoot = Join-Path $AddonsRoot 'Assets\addons\lifepunch\bitcoinmining\sounds\bitcoinminer'
}

$ErrorActionPreference = 'Stop'

$Falloff = @(
    @{ y = 1; out = -1.8; in = 0; mode = 'Mirrored'; x = 0 },
    @{ y = 0.22; out = -3.5; in = 3.5; mode = 'Mirrored'; x = 0.05 },
    @{ y = 0.04; out = -0.16; in = 0.16; mode = 'Mirrored'; x = 0.2 },
    @{ y = 0; out = 0; in = 0; mode = 'Mirrored'; x = 1 }
)

$Slots = @(
    @{ Name = 'hub-startup'; Decibels = 72 },
    @{ Name = 'hub-fan-loop'; Decibels = 56 },
    @{ Name = 'hub-fan-down'; Decibels = 64 },
    @{ Name = 'server-hum'; Decibels = 58 },
    @{ Name = 'keyboard'; Decibels = 70 },
    @{ Name = 'glitch'; Decibels = 66 },
    @{ Name = 'error'; Decibels = 68 }
)

foreach ( $slot in $Slots ) {
    $doc = [ordered]@{
        SelectionMode = 'Random'
        DistanceAttenuation = $true
        UI = $false
        Volume = '1'
        Sounds = @("addons/lifepunch/bitcoinmining/sounds/bitcoinminer/$($slot.Name).vsnd")
        Transmission = $true
        Pitch = '1'
        AirAbsorption = $true
        Decibels = $slot.Decibels
        Falloff = $Falloff
        __version = 1
        Occlusion = $true
        Distance = 15000
        OcclusionRadius = 64
        __references = @()
        DefaultMixer = @{
            Id = '00000000-0000-0000-0000-000000000000'
            Name = 'unknown'
        }
    }

    $path = Join-Path $SoundRoot "$($slot.Name).sound"
    $json = ($doc | ConvertTo-Json -Depth 6)
    Set-Content -LiteralPath $path -Value $json -Encoding UTF8
    Write-Host "  OK $($slot.Name).sound" -ForegroundColor Green
}

Write-Host "Sound resources written under $SoundRoot" -ForegroundColor Cyan
Write-Host 'Compile .vsnd in s&box editor after Sync-LifePunchAddonsToDxrp.ps1 -Addon bitcoinmining' -ForegroundColor DarkGray
