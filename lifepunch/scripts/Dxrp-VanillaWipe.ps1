# Shared helpers: strip LifePunch / lp_* command sources from a DXRP game root.

function Get-DxrpGameRootFromConfigPath {
    param([string] $ConfigPath)
    $pathsScript = Join-Path $PSScriptRoot 'Dxrp-LifepunchPaths.ps1'
    . $pathsScript
    return Get-DxrpGameRootFromConfig -ConfigPath $ConfigPath
}

function Test-DxrpVanillaWorkbench {
    param([string] $DxrpGameRoot)
    return ($DxrpGameRoot -match 'dxrp-vanilla')
}

function Remove-DxrpLifePunchTrees {
    param(
        [string] $DxrpGameRoot,
        [switch] $WhatIf
    )

    if (-not (Test-Path -LiteralPath $DxrpGameRoot)) {
        throw "DXRP game root not found: $DxrpGameRoot"
    }

    $paths = @(
        (Join-Path $DxrpGameRoot 'Assets\addons\lifepunch'),
        (Join-Path $DxrpGameRoot 'Code\Addons\lifepunch'),
        (Join-Path $DxrpGameRoot 'addons\lifepunch'),
        (Join-Path $DxrpGameRoot 'lpaddondev'),
        (Join-Path $DxrpGameRoot 'Code\_sui_scratch'),
        (Join-Path $DxrpGameRoot 'Code\_sui_preview'),
        (Join-Path $DxrpGameRoot 'Editor\LpJtcMcpAutostart.cs'),
        (Join-Path $DxrpGameRoot 'Editor\LpJtcMcpAutostart.cs.offline'),
        (Join-Path $DxrpGameRoot 'tailwand.config.json'),
        (Join-Path $DxrpGameRoot '.sbox\project.json')
    )

    foreach ($path in $paths) {
        if (-not (Test-Path -LiteralPath $path)) { continue }
        if ($WhatIf) {
            Write-Host "[WhatIf] remove $path" -ForegroundColor DarkGray
            continue
        }
        if ((Get-Item -LiteralPath $path -Force).PSIsContainer) {
            Remove-Item -LiteralPath $path -Recurse -Force
        }
        else {
            Remove-Item -LiteralPath $path -Force
        }
        Write-Host "  removed $(Split-Path -Leaf $path)" -ForegroundColor Yellow
    }

    # Drop stale compile output so lp_* types cannot linger in cached DLLs.
    foreach ($obj in @('Code\obj', 'Editor\obj', 'Code\bin', 'Editor\bin')) {
        $path = Join-Path $DxrpGameRoot $obj
        if (-not (Test-Path -LiteralPath $path)) { continue }
        if ($WhatIf) {
            Write-Host "[WhatIf] remove $path" -ForegroundColor DarkGray
            continue
        }
        Remove-Item -LiteralPath $path -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  cleared $obj" -ForegroundColor DarkGray
    }
}

function Reset-DxrpVanillaRpResources {
    param(
        [string] $DxrpGameRoot,
        [switch] $WhatIf
    )

    $sbprojPath = Join-Path $DxrpGameRoot 'rp.sbproj'
    if (-not (Test-Path -LiteralPath $sbprojPath)) { return }

    $vanillaResources = @(
        'ui/*'
        'gameplay/entities/jobs/mayor/gun_license/gun_license.png'
    ) -join '\n'

    $content = Get-Content -LiteralPath $sbprojPath -Raw
    $marker = '"Resources": "'
    $start = $content.IndexOf($marker)
    if ($start -lt 0) { throw "rp.sbproj Resources field not found: $sbprojPath" }
    $valueStart = $start + $marker.Length
    $valueEnd = $content.IndexOf('"', $valueStart)
    $content = $content.Substring(0, $valueStart) + $vanillaResources + $content.Substring($valueEnd)

    if ($WhatIf) {
        Write-Host "[WhatIf] vanilla rp.sbproj Resources" -ForegroundColor DarkGray
        return
    }

    [System.IO.File]::WriteAllText($sbprojPath, $content)
    Write-Host '  rp.sbproj -> vanilla Resources (no lifepunch mounts)' -ForegroundColor Green
}

function Invoke-DxrpVanillaLifePunchWipe {
    param(
        [string] $ConfigPath = '',
        [string] $DxrpGameRoot = '',
        [switch] $WhatIf
    )

    if (-not $DxrpGameRoot) {
        if (-not $ConfigPath) { throw 'ConfigPath or DxrpGameRoot required.' }
        $DxrpGameRoot = Get-DxrpGameRootFromConfigPath -ConfigPath $ConfigPath
    }

    Write-Host "Wipe LifePunch / lp_* sources -> $DxrpGameRoot" -ForegroundColor Cyan
    Remove-DxrpLifePunchTrees -DxrpGameRoot $DxrpGameRoot -WhatIf:$WhatIf
    Reset-DxrpVanillaRpResources -DxrpGameRoot $DxrpGameRoot -WhatIf:$WhatIf
    Write-Host 'Vanilla wipe OK - no lp_ ConCmd sources on disk.' -ForegroundColor Green
}
