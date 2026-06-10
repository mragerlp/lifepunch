# Dot-source from shortcut installers. Resolves tier icon paths for .lnk IconLocation.
# universal = tri-stack (all 3 nodes) — e.g. Start Day: gate + watchers + Cornerman relay. See SHORTCUT_ICONS.md.

function Get-LifePunchBrandingRoot {
    $scripts = $PSScriptRoot
    if (-not $scripts) { $scripts = Split-Path -Parent $MyInvocation.MyCommand.Path }
    return (Resolve-Path (Join-Path $scripts '..\branding')).Path
}

function Get-LifePunchShortcutIconPublishDir {
    return (Join-Path $env:USERPROFILE 'Documents\LifePunch-Icons')
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
    $pngName = $map[$Tier]
    $icoName = [System.IO.Path]::ChangeExtension($pngName, '.ico')
    $publish = Join-Path (Get-LifePunchShortcutIconPublishDir) $icoName
    if (Test-Path -LiteralPath $publish) { return $publish }
    $root = Get-LifePunchBrandingRoot
    $repoIco = Join-Path $root "shortcut-icons\$icoName"
    if (Test-Path -LiteralPath $repoIco) { return $repoIco }
    $png = Join-Path $root "shortcut-icons\$name"
    if (Test-Path -LiteralPath $png) { return $png }
    $fallback = Join-Path $root 'cornerman\cornerman-terminal-icon.ico'
    if (Test-Path -LiteralPath $fallback) { return $fallback }
    throw "Missing shortcut icon for tier '$Tier': $ico (run Build-LifePunchShortcutIcons.ps1)"
}

function Get-LifePunchShortcutIconLocation {
    param(
        [Parameter(Mandatory)]
        [ValidateSet('universal', 'vengeance', 'cornerman', 'lifepunchnet')]
        [string] $Tier
    )
    $path = Get-LifePunchShortcutIconPath -Tier $Tier
    if ($path -like '*.ico') { return "$path,0" }
    # PNG in IconLocation is ignored by Windows Explorer — build .ico first.
    return "$path,0"
}
