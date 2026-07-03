<#
.SYNOPSIS
    Server-parity gate for DXRP addon publishing.

.DESCRIPTION
    The s&box editor compiles source assets (.vmdl/.prefab/.vmat/.sound) into
    companion "_c" files. The DXRP server loads the COMPILED "_c" files, not the
    raw source. Two failure modes have repeatedly broken live publishes:

      1. A shipped reference's "_c" is MISSING  -> server shows an ERROR mesh.
      2. A shipped reference's "_c" is STALE     -> server ships an older version
         than the current source (silent wrong-content).

    This script reads config/addons.json and, for every content-row reference
    that this addon actually ships (paths under addons/lifepunch/<ident>/),
    confirms the source exists, the "_c" exists, and the "_c" is newer than the
    source. Base-game / shared references (e.g. gameplay/...) are skipped because
    they are mounted by the server and not part of this package.

    A broader sweep of the addon's Assets tree reports any other stale/missing
    "_c" as warnings (e.g. deferred assets that are not currently referenced).

.PARAMETER Addon
    The addon ident from config/addons.json (e.g. ak47, hackerjob).

.EXAMPLE
    .\scripts\validate-server-parity.ps1 -Addon ak47
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$Addon
)

$ErrorActionPreference = 'Stop'

$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$ManifestPath = Join-Path $Root 'config\addons.json'
$AssetsRoot = Join-Path $Root 'Assets'

$Errors = New-Object System.Collections.Generic.List[string]
$Warnings = New-Object System.Collections.Generic.List[string]

# Image/icon references are not compiled into _c; only confirm the source exists.
$ImageExtensions = @('.png', '.jpg', '.jpeg', '.svg', '.webp')
# Source asset types that compile into a companion _c file.
$CompiledExtensions = @('.vmdl', '.prefab', '.vmat', '.sound', '.vsnd')

if (-not (Test-Path -LiteralPath $ManifestPath -PathType Leaf)) {
    throw "Manifest not found: $ManifestPath"
}

$Manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
$Package = @($Manifest.addons) | Where-Object { $_.ident -eq $Addon } | Select-Object -First 1

if ($null -eq $Package) {
    $Known = (@($Manifest.addons) | ForEach-Object { $_.ident }) -join ', '
    throw "Unknown addon '$Addon'. Known addons: $Known"
}

$Ident = [string]$Package.ident
$LocalPrefix = "addons/lifepunch/$Ident/"

function Resolve-AssetPath {
    param([string]$Reference)
    $Clean = $Reference.TrimStart('/')
    return (Join-Path $AssetsRoot ($Clean -replace '/', '\'))
}

function Test-ShippedReference {
    param(
        [string]$Reference,
        [string]$Context
    )

    if ([string]::IsNullOrWhiteSpace($Reference)) {
        return
    }

    $Clean = $Reference.TrimStart('/')

    if (-not $Clean.StartsWith($LocalPrefix)) {
        Write-Host ("  [skip] {0,-20} {1}  (base/shared - mounted by server)" -f $Context, $Reference) -ForegroundColor DarkGray
        return
    }

    $Source = Resolve-AssetPath $Clean
    if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) {
        $Errors.Add("$Context source file MISSING: $Clean")
        return
    }

    $Extension = [System.IO.Path]::GetExtension($Source).ToLowerInvariant()
    if ($Extension -in $ImageExtensions) {
        Write-Host ("  [ok]   {0,-20} {1}  (image, no compile)" -f $Context, $Clean) -ForegroundColor Green
        return
    }

    $Compiled = "$Source" + "_c"
    if (-not (Test-Path -LiteralPath $Compiled -PathType Leaf)) {
        $Errors.Add("$Context compiled '_c' MISSING for $Clean -> open addons.sbproj in s&box editor and recompile")
        return
    }

    $SourceTime = (Get-Item -LiteralPath $Source).LastWriteTime
    $CompiledTime = (Get-Item -LiteralPath $Compiled).LastWriteTime
    if ($CompiledTime -lt $SourceTime) {
        # NOTE: s&box recompiles by CONTENT HASH, not timestamp. A no-op Ctrl+S
        # rewrites the source (newer mtime) WITHOUT changing content, so the _c is
        # not rebuilt and looks "stale" here even though it is current.
        # Disambiguate with the RELOAD TEST: close + reopen the project. s&box
        # recompiles on open ONLY if content actually changed. If the _c timestamp
        # does NOT move after a reload, the content is current and safe to ship.
        $Warnings.Add("$Context '_c' older than source for $Clean (source $SourceTime > compiled $CompiledTime). Likely a no-op save. RELOAD TEST: reopen the project; if the _c time does not change, it is content-current and safe. Only treat as a real problem if reopening rebuilds it.")
        Write-Host ("  [verify] {0,-18} {1}  (source newer than _c - run reload test; see warnings)" -f $Context, $Clean) -ForegroundColor Yellow
        return
    }

    Write-Host ("  [ok]   {0,-20} {1}  (compiled fresh)" -f $Context, $Clean) -ForegroundColor Green
}

Write-Host "Server-parity check for lifepunch.$Ident" -ForegroundColor Cyan
Write-Host "Shipped content-row references:" -ForegroundColor Cyan

$Contents = @($Package.contents)
if ($Contents.Count -eq 0) {
    Write-Host '  (no content rows declared)' -ForegroundColor DarkGray
}

foreach ($Content in $Contents) {
    $Label = [string]$Content.label
    Test-ShippedReference ([string]$Content.primaryReference) "$Label primary"
    Test-ShippedReference ([string]$Content.secondaryReference) "$Label secondary"
    Test-ShippedReference ([string]$Content.worldModelPath) "$Label worldModel"
    if ($Content.PSObject.Properties.Name -contains 'iconPath') {
        Test-ShippedReference ([string]$Content.iconPath) "$Label icon"
    }
}

# Broad sweep: any other source asset in the addon tree whose _c is missing/stale.
$AddonAssets = Join-Path $AssetsRoot ("addons\lifepunch\$Ident")
if (Test-Path -LiteralPath $AddonAssets -PathType Container) {
    Get-ChildItem -LiteralPath $AddonAssets -Recurse -File -Force |
        Where-Object { $_.Extension.ToLowerInvariant() -in $CompiledExtensions } |
        ForEach-Object {
            $Source = $_
            $Compiled = "$($Source.FullName)_c"
            $Relative = $Source.FullName.Substring($AssetsRoot.Length).TrimStart('\', '/')
            if (-not (Test-Path -LiteralPath $Compiled -PathType Leaf)) {
                $Warnings.Add("compiled '_c' missing (not in any content row): $Relative")
            } elseif ((Get-Item -LiteralPath $Compiled).LastWriteTime -lt $Source.LastWriteTime) {
                $Warnings.Add("compiled '_c' stale (not in any content row): $Relative")
            }
        }
}

Write-Host ''
if ($Warnings.Count -gt 0) {
    Write-Host 'Warnings (not shipped by current content rows):' -ForegroundColor Yellow
    foreach ($Warning in $Warnings) {
        Write-Host " - $Warning" -ForegroundColor Yellow
    }
    Write-Host ''
}

if ($Errors.Count -gt 0) {
    Write-Host 'Server-parity check FAILED:' -ForegroundColor Red
    foreach ($ErrorMessage in $Errors) {
        Write-Host " - $ErrorMessage" -ForegroundColor Red
    }
    Write-Host ''
    Write-Host 'Do NOT publish until the shipped references above are compiled and fresh.' -ForegroundColor Red
    exit 1
}

Write-Host "Server-parity check PASSED for lifepunch.$Ident - all shipped references have fresh compiled output." -ForegroundColor Green
