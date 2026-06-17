<#
.SYNOPSIS
  Resolve canonical OneDrive LIFEPUNCH addon drop folders (owner source of truth).

.DESCRIPTION
  Owner drops under:
    %USERPROFILE%\OneDrive\Desktop\LIFEPUNCH*\addons\

  Package layout (Jun 2026):
    lifepunchhacker\hacker\serverrack | advancedserverrack | hackerterminal | advancedhackerterminal
    lifepunchhacker\fbi\governmentserverrack | governmentterminal
    lifepunchbitcoin\bitcoinminer | gpurack | bitcointerminal
    lifepunchblackmarketdealer\blackmarkethub | blackmarketterminal | blackmarketcardreader

  Canonical map: addons/docs/MODEL_INTAKE_DROP_MAP.md
#>

function Get-LifePunchAddonsDropRoot {
    $desktop = Join-Path $env:USERPROFILE 'OneDrive\Desktop'
    if (-not (Test-Path -LiteralPath $desktop)) {
        return $null
    }

    foreach ($dir in Get-ChildItem -LiteralPath $desktop -Directory -ErrorAction SilentlyContinue) {
        $addons = Join-Path $dir.FullName 'addons'
        if (-not (Test-Path -LiteralPath $addons)) { continue }
        return (Resolve-Path -LiteralPath $addons).Path
    }

    return $null
}

# Relative paths under addons\ (keys = intake script lookup id)
$script:LifePunchEntityDropMap = @{
    'hacker.server-rack'           = 'lifepunchhacker\hacker\serverrack'
    'hacker.advanced-server-rack'  = 'lifepunchhacker\hacker\advancedserverrack'
    'hacker.hacker-terminal'       = 'lifepunchhacker\hacker\hackerterminal'
    'hacker.advanced-hacker-terminal' = 'lifepunchhacker\hacker\advancedhackerterminal'
    'fbi.government-server-rack'   = 'lifepunchhacker\fbi\governmentserverrack'
    'fbi.government-terminal'      = 'lifepunchhacker\fbi\governmentterminal'
    'bitcoin.bitcoin-miner'        = 'lifepunchbitcoin\bitcoinminer'
    'bitcoin.gpu-rack'             = 'lifepunchbitcoin\gpurack'
    'bitcoin.bitcoin-terminal'     = 'lifepunchbitcoin\bitcointerminal'
    'blackmarket.hub'              = 'lifepunchblackmarketdealer\blackmarkethub'
    'blackmarket.terminal'         = 'lifepunchblackmarketdealer\blackmarketterminal'
    'blackmarket.cardreader'       = 'lifepunchblackmarketdealer\blackmarketcardreader'
}

function Get-LifePunchEntityDrop {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Key,

        [string[]] $LegacyNames = @()
    )

    $root = Get-LifePunchAddonsDropRoot
    if ($root -and $script:LifePunchEntityDropMap.ContainsKey($Key)) {
        $rel = $script:LifePunchEntityDropMap[$Key]
        $path = Join-Path $root $rel
        if (Test-Path -LiteralPath $path) {
            return (Resolve-Path -LiteralPath $path).Path
        }
        return $path
    }

    foreach ($name in $LegacyNames) {
        if ($root) {
            $legacy = Join-Path $root $name
            if (Test-Path -LiteralPath $legacy) {
                return (Resolve-Path -LiteralPath $legacy).Path
            }
        }
        $dl = Join-Path $env:USERPROFILE "Downloads\$name"
        if (Test-Path -LiteralPath $dl) {
            return (Resolve-Path -LiteralPath $dl).Path
        }
    }

    if ($root -and $script:LifePunchEntityDropMap.ContainsKey($Key)) {
        return (Join-Path $root $script:LifePunchEntityDropMap[$Key])
    }
    if ($LegacyNames.Count -gt 0) {
        return (Join-Path $env:USERPROFILE "Downloads\$($LegacyNames[0])")
    }
    throw "Unknown entity drop key: $Key"
}

# Back-compat shim for scripts still calling Get-LifePunchAddonDrop -Name serverrack
function Get-LifePunchAddonDrop {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Name,

        [string] $FallbackRelative = ''
    )

    $map = @{
        serverrack       = 'hacker.server-rack'
        blackmarkethub   = 'blackmarket.hub'
        gpurack          = 'bitcoin.gpu-rack'
        bitcoinminer     = 'bitcoin.bitcoin-miner'
        governmentterminal = 'fbi.government-terminal'
    }
    if ($map.ContainsKey($Name)) {
        return Get-LifePunchEntityDrop -Key $map[$Name] -LegacyNames @($Name)
    }

    $root = Get-LifePunchAddonsDropRoot
    if ($root) {
        $onedrive = Join-Path $root $Name
        if (Test-Path -LiteralPath $onedrive) {
            return (Resolve-Path -LiteralPath $onedrive).Path
        }
    }
    if ($FallbackRelative) {
        $fallback = Join-Path $env:USERPROFILE $FallbackRelative
        if (Test-Path -LiteralPath $fallback) {
            return (Resolve-Path -LiteralPath $fallback).Path
        }
    }
    return Join-Path $env:USERPROFILE "Downloads\$Name"
}

function Resolve-LifePunchServerRackGlassRoot {
    [CmdletBinding()]
    param(
        [string] $ServerRackRoot = '',
        [string] $GlassSourceRoot = ''
    )

    if ($GlassSourceRoot -and (Test-Path -LiteralPath $GlassSourceRoot)) {
        return (Resolve-Path -LiteralPath $GlassSourceRoot).Path
    }

    if ($ServerRackRoot -and (Test-Path -LiteralPath $ServerRackRoot)) {
        foreach ($name in @('Materials', 'serverglassmaterial', 'Materials\materials')) {
            $nested = Join-Path $ServerRackRoot $name
            if (Test-Path -LiteralPath $nested) {
                return (Resolve-Path -LiteralPath $nested).Path
            }
        }
    }

    $addonsRoot = Get-LifePunchAddonsDropRoot
    if ($addonsRoot) {
        foreach ($name in @('serverrackglass', 'serverglassmaterial')) {
            $candidate = Join-Path $addonsRoot $name
            if (Test-Path -LiteralPath $candidate) {
                return (Resolve-Path -LiteralPath $candidate).Path
            }
        }
    }

    $legacyGlass = Join-Path $env:USERPROFILE 'Downloads\serverrackglass'
    if (Test-Path -LiteralPath $legacyGlass) {
        return (Resolve-Path -LiteralPath $legacyGlass).Path
    }

    if ($ServerRackRoot -and (Test-Path -LiteralPath $ServerRackRoot)) {
        return (Resolve-Path -LiteralPath $ServerRackRoot).Path
    }

    return $null
}
