<#
.SYNOPSIS
  Shared Fab DataCenter server-rack intake (mesh + trim + glass).

.DESCRIPTION
  Dot-source from Intake-HackerServerRack.ps1 / Intake-GovernmentServerRack.ps1.
#>

function Import-FabServerRackAssets {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $SourceRoot,

        [Parameter(Mandatory)]
        [string] $DestFbxPath,

        [Parameter(Mandatory)]
        [string] $DestTrimDir,

        [Parameter(Mandatory)]
        [string] $DestGlassDir,

        [string] $GlassSourceRoot = '',
        [string] $MeshFilter = 'Servers.fbx',
        [switch] $WhatIf
    )

    function Resolve-FabMesh([string]$Root, [string[]]$Names) {
        foreach ($name in $Names) {
            foreach ($rel in @(
                "Servers\Model\$name"
                "Model\$name"
                "Servers\$name"
                $name
            )) {
                $path = Join-Path $Root $rel
                if (Test-Path -LiteralPath $path) { return (Resolve-Path -LiteralPath $path).Path }
            }
            $hits = Get-ChildItem -LiteralPath $Root -Recurse -File -Filter $name -ErrorAction SilentlyContinue
            if ($hits) { return ($hits | Sort-Object Length -Descending | Select-Object -First 1).FullName }
        }
        return $null
    }

    function Resolve-TextureTier([string]$Root, [string[]]$Tiers) {
        foreach ($tier in $Tiers) {
            foreach ($rel in @(
                "Servers\Texture\$tier"
                "Texture\$tier"
                "serverrack\Texture\$tier"
            )) {
                $dir = Join-Path $Root $rel
                if (Test-Path -LiteralPath $dir) { return $dir }
            }
        }
        $fallback = Get-ChildItem -LiteralPath $Root -Recurse -Directory -ErrorAction SilentlyContinue |
            Where-Object { $null -ne $_.Parent -and $_.Parent.Name -eq 'Texture' -and $_.Name -eq '2K' } |
            Select-Object -First 1
        if ($fallback) { return $fallback.FullName }
        return $null
    }

    function Resolve-GlassTextures([string]$Root) {
        foreach ($rel in @('Glass_Cover_Material\2K', 'Glass_Cover_Material\4K', 'Glass_Cover_Material\1K')) {
            $dir = Join-Path $Root $rel
            if (Test-Path -LiteralPath $dir) { return (Resolve-Path -LiteralPath $dir).Path }
        }

        $fab2k = Get-ChildItem -LiteralPath $Root -Recurse -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -eq '2K' -and $_.Parent.Name -eq 'Glass_Cover_Material' } |
            Select-Object -First 1
        if ($fab2k) { return $fab2k.FullName }

        $materials = Get-ChildItem -LiteralPath $Root -Recurse -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -eq 'materials' } |
            Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'Glass_Cover_BaseColor.png') } |
            Select-Object -First 1
        if ($materials) { return $materials.FullName }

        $hasGlass = Get-ChildItem -LiteralPath $Root -Recurse -File -Filter 'Glass_Cover_BaseColor.png' -ErrorAction SilentlyContinue |
            Select-Object -First 1
        if ($hasGlass) { return $hasGlass.Directory.FullName }

        return $null
    }

    if (-not (Test-Path -LiteralPath $SourceRoot)) {
        throw "Missing source root: $SourceRoot"
    }

    $meshNames = switch ($MeshFilter) {
        'Servers_Rows.fbx' { @('Servers_Rows.fbx', 'servers_rows.fbx') }
        default { @('Servers.fbx', 'servers.fbx') }
    }

    $sourceFbx = Resolve-FabMesh -Root $SourceRoot -Names $meshNames
    if (-not $sourceFbx) {
        throw "Missing $($meshNames[0]) under $SourceRoot"
    }

    $trimTex = Resolve-TextureTier -Root $SourceRoot -Tiers @('2K', '4K', '1K')
    $glassSearchRoots = @($GlassSourceRoot, $SourceRoot) | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -Unique
    $glassTex = $null
    foreach ($root in $glassSearchRoots) {
        $glassTex = Resolve-GlassTextures -Root $root
        if ($glassTex) { break }
    }

    if ($WhatIf) {
        Write-Host "[WhatIf] $sourceFbx -> $DestFbxPath"
        return @{ Mesh = $sourceFbx; Trim = $trimTex; Glass = $glassTex }
    }

    $destParent = Split-Path -Parent $DestFbxPath
    if (-not (Test-Path -LiteralPath $destParent)) {
        New-Item -ItemType Directory -Force -Path $destParent | Out-Null
    }
    Copy-Item -LiteralPath $sourceFbx -Destination $DestFbxPath -Force

    if ($trimTex) {
        if (-not (Test-Path -LiteralPath $DestTrimDir)) {
            New-Item -ItemType Directory -Force -Path $DestTrimDir | Out-Null
        }
        & robocopy $trimTex $DestTrimDir /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    }

    if ($glassTex) {
        if (-not (Test-Path -LiteralPath $DestGlassDir)) {
            New-Item -ItemType Directory -Force -Path $DestGlassDir | Out-Null
        }
        & robocopy $glassTex $DestGlassDir /E /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    }

    return @{
        Mesh  = $sourceFbx
        Trim  = $trimTex
        Glass = $glassTex
    }
}
