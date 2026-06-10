# Dot-source from shortcut installers. Resolves tier icon paths for .lnk IconLocation.

function Get-LifePunchBrandingRoot {
    $scripts = $PSScriptRoot
    if (-not $scripts) { $scripts = Split-Path -Parent $MyInvocation.MyCommand.Path }
    return (Resolve-Path (Join-Path $scripts '..\branding')).Path
}

function Get-LifePunchShortcutIconPath {
    param(
        [Parameter(Mandatory)]
        [ValidateSet('universal', 'vengeance', 'cornerman', 'lifepunchnet')]
        [string] $Tier
    )
    $map = @{
        universal   = 'lifepunch-universal.png'
        vengeance   = 'lifepunch-vengeance.png'
        cornerman   = 'lifepunch-cornerman.png'
        lifepunchnet = 'lifepunch-lifepunchnet.png'
    }
    $root = Get-LifePunchBrandingRoot
    $path = Join-Path $root "shortcut-icons\$($map[$Tier])"
    if (-not (Test-Path -LiteralPath $path)) {
        $fallback = Join-Path $root 'cornerman\cornerman-terminal-icon.ico'
        if (Test-Path -LiteralPath $fallback) { return $fallback }
        throw "Missing shortcut icon for tier '$Tier': $path"
    }
    return $path
}

function Get-LifePunchShortcutIconLocation {
    param(
        [Parameter(Mandatory)]
        [ValidateSet('universal', 'vengeance', 'cornerman', 'lifepunchnet')]
        [string] $Tier
    )
    $path = Get-LifePunchShortcutIconPath -Tier $Tier
    if ($path -like '*.ico') { return "$path,0" }
    return $path
}
