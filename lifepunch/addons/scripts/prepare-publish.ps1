param(
    [Parameter(Mandatory = $true)]
    [string]$Addon,

    [switch]$OpenFolder
)

$ErrorActionPreference = 'Stop'

$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$ManifestPath = Join-Path $Root 'config\addons.json'
$UploadRoot = Join-Path $Root '.dxrp-publish\upload'

$Script:ShipAssetExcludeExtensions = @('.blend', '.fbx', '.tga', '.obj')
$Script:ShipAssetExcludeFolders = @('source', '_archive', 'audit', 'docs', '_dev')

function Test-PublishShipFile {
    param(
        [System.IO.FileInfo]$File,
        [string[]]$RelativeParts,
        [switch]$ShipAssetsOnly
    )

    if ($File.Name -in @('.gitkeep', 'desktop.ini', 'Thumbs.db', 'material-map.json')) {
        return $false
    }

    if ($File.Extension -eq '.md') {
        return $false
    }

    foreach ($Folder in $Script:ShipAssetExcludeFolders) {
        if ($RelativeParts -contains $Folder) {
            return $false
        }
    }

    if ($File.Name -match '(TestBots|DevGive|DevSpawn)') {
        return $false
    }

    if ($ShipAssetsOnly -and $File.Extension -in $Script:ShipAssetExcludeExtensions) {
        return $false
    }

    return $true
}

function Copy-PublishItems {
    param(
        [string]$Source,
        [string]$Destination,
        [switch]$ShipAssetsOnly
    )

    if (-not (Test-Path -LiteralPath $Source -PathType Container)) {
        return
    }

    $SourceRoot = (Resolve-Path -LiteralPath $Source).Path
    Get-ChildItem -LiteralPath $SourceRoot -Recurse -File -Force |
        Where-Object {
            $Relative = $_.FullName.Substring($SourceRoot.Length).TrimStart('\', '/')
            $RelativeParts = $Relative -split '[\\/]'
            Test-PublishShipFile -File $_ -RelativeParts $RelativeParts -ShipAssetsOnly:$ShipAssetsOnly
        } |
        ForEach-Object {
            $Relative = $_.FullName.Substring($SourceRoot.Length).TrimStart('\', '/')
            $Target = Join-Path $Destination $Relative
            $TargetParent = Split-Path -Parent $Target

            if (-not (Test-Path -LiteralPath $TargetParent -PathType Container)) {
                New-Item -ItemType Directory -Force -Path $TargetParent | Out-Null
            }

            Copy-Item -LiteralPath $_.FullName -Destination $Target -Force

            if ($_.Extension -eq '.fbx') {
                Clear-SensitiveBinaryStrings -Path $Target
            }
        }
}

function Clear-SensitiveBinaryStrings {
    param(
        [string]$Path
    )

    $Encoding = [System.Text.Encoding]::GetEncoding(28591)
    $Bytes = [System.IO.File]::ReadAllBytes($Path)
    $Text = $Encoding.GetString($Bytes)

    # Strip any embedded local "<drive>:\Users\<name>\..." path (e.g. baked-in texture
    # references from the source artist's machine). The match is bounded by a control char
    # or quote so it only consumes the printable path string. We keep the trailing basename
    # and left-pad with spaces so the byte length is preserved (binary FBX string properties
    # are length-prefixed, so the byte count must not change).
    $SensitivePathPatterns = @(
        '[A-Za-z]:[\\/]Users[\\/][ -~]*?(?=[\x00-\x1f"])'
    )

    foreach ($Pattern in $SensitivePathPatterns) {
        $Text = [System.Text.RegularExpressions.Regex]::Replace($Text, $Pattern, {
            param($Match)

            $Value = $Match.Value
            $BaseName = ($Value -split '[\\/]')[-1]
            if ([string]::IsNullOrWhiteSpace($BaseName)) {
                $BaseName = 'asset'
            }

            if ($BaseName.Length -ge $Value.Length) {
                return $BaseName.Substring(0, $Value.Length)
            }

            return (' ' * ($Value.Length - $BaseName.Length)) + $BaseName
        })
    }

    [System.IO.File]::WriteAllBytes($Path, $Encoding.GetBytes($Text))
}

# lifepunchulx shares LifePunch UI helpers from Code/Addons/lifepunch/ in the editor sync,
# but the portal ships only Code/Addons/lifepunch/lifepunchulx/ — bundle deps for dedicated-server compile.
$Script:AdminMenuSharedShipFiles = @(
    'LifePunchUiScale.cs',
    'LifePunchUiScrollPolicy.cs',
    'LifePunchScrollRegionPanel.cs',
    'LifePunchScrollLayout.cs',
    'LifePunchSourceMark.cs',
    'LifePunchUiFooter.razor',
    'LifePunchUiFooter.razor.scss'
)

function Add-AdminMenuSharedShipDeps {
    param(
        [string]$SharedCodeRoot,
        [string]$CodeStage
    )

    foreach ($Name in $Script:AdminMenuSharedShipFiles) {
        $Source = Join-Path $SharedCodeRoot $Name
        if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) {
            throw "Missing lifepunchulx shared ship dependency: $Name (expected under $SharedCodeRoot)"
        }

        Copy-Item -LiteralPath $Source -Destination (Join-Path $CodeStage $Name) -Force
    }

    $StaffScss = Join-Path $CodeStage 'StaffMenu.razor.scss'
    if (-not (Test-Path -LiteralPath $StaffScss -PathType Leaf)) {
        throw "Missing staged StaffMenu.razor.scss for publish SCSS patch"
    }

    $ScssText = [System.IO.File]::ReadAllText($StaffScss)
    $ScssText = $ScssText -replace '@import "\.\./LifePunchUiFooter\.razor\.scss";', '@import "LifePunchUiFooter.razor.scss";'
    [System.IO.File]::WriteAllText($StaffScss, $ScssText)
}

& (Join-Path $PSScriptRoot 'validate-layout.ps1')

$Manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
$Package = @($Manifest.addons) | Where-Object { $_.ident -eq $Addon } | Select-Object -First 1

if ($null -eq $Package) {
    $Known = (@($Manifest.addons) | ForEach-Object { $_.ident }) -join ', '
    throw "Unknown addon '$Addon'. Known addons: $Known"
}

if (Test-Path -LiteralPath $UploadRoot) {
    Remove-Item -LiteralPath $UploadRoot -Recurse -Force
}

$Org = [string]$Manifest.org
$AssetsStage = Join-Path $UploadRoot "Assets\addons\$Org\$($Package.ident)"
$CodeStage = Join-Path $UploadRoot "Code\Addons\$Org\$($Package.ident)"

if ($Package.hasAssets) {
    if ($Package.ident -eq 'bitcoinmining') {
        # Runtime paths use lpbitcoin/* — stage ship-tier assets there (not legacy bitcoinmining/).
        $AssetsSource = Join-Path $Root "Assets\addons\$Org\lpbitcoin"
        $AssetsStage = Join-Path $UploadRoot "Assets\addons\$Org\lpbitcoin"
    } else {
        $AssetsSource = Join-Path $Root "Assets\addons\$Org\$($Package.ident)"
    }

    New-Item -ItemType Directory -Force -Path $AssetsStage | Out-Null
    Copy-PublishItems -Source $AssetsSource -Destination $AssetsStage -ShipAssetsOnly:($Package.ident -eq 'bitcoinmining')
}

if ($Package.hasCode) {
    $CodeSource = Join-Path $Root "Code\Addons\$Org\$($Package.ident)"
    New-Item -ItemType Directory -Force -Path $CodeStage | Out-Null
    Copy-PublishItems -Source $CodeSource -Destination $CodeStage

    if ($Package.ident -eq 'bitcoinmining') {
        $HubCodeSource = Join-Path $Root "Code\Addons\$Org\lpbitcoin\bitcoinhub\code"
        Copy-PublishItems -Source $HubCodeSource -Destination $CodeStage
    }

    if ($Package.ident -eq 'adminmenu') {
        $SharedCodeRoot = Join-Path $Root "Code\Addons\$Org"
        Add-AdminMenuSharedShipDeps -SharedCodeRoot $SharedCodeRoot -CodeStage $CodeStage
    }
}

$ContentRows = @(@($Package.contents) | ForEach-Object {
    [ordered]@{
        slug = $_.slug
        name = $_.name
        label = $_.label
        type = $_.type
        primaryReference = $_.primaryReference
        secondaryReference = $_.secondaryReference
        worldModelPath = $_.worldModelPath
        iconPath = $_.iconPath
        grouping = $_.grouping
        implementationStatus = $_.implementationStatus
    }
})

$Readme = @"
DXRP publish staging for $Org.$($Package.ident)
=============================================

Generated from:
  $Root

Upload root:
  $UploadRoot

Package:
  Title:      $($Package.title)
  Kind:       $($Package.kind)
  HasAssets:  $($Package.hasAssets)
  HasCode:    $($Package.hasCode)

Expected DXRP paths:
  Assets/addons/$Org/$($Package.ident)/
  Code/Addons/$Org/$($Package.ident)/

Content rows:
$(
    if ($ContentRows.Count -eq 0) {
        '  (none declared)'
    } else {
        ($ContentRows | ForEach-Object {
            @"
  - $($_.label) [$($_.slug)]
    Name:               $($_.name)
    Type:               $($_.type)
    Primary Reference:  $($_.primaryReference)
    Secondary Reference: $($_.secondaryReference)
    World Model Path:   $($_.worldModelPath)
    Icon Path:          $($_.iconPath)
    Grouping:           $($_.grouping)
"@
        }) -join "`r`n"
    }
)

Do not move files into upload-assets or upload-code. Keep the Assets and Code roots intact.
"@

$StagingRoot = Join-Path $Root '.dxrp-publish'
New-Item -ItemType Directory -Force -Path $StagingRoot | Out-Null
Set-Content -LiteralPath (Join-Path $StagingRoot 'README.txt') -Value $Readme -Encoding UTF8

$PackageExport = [ordered]@{
    schemaVersion = 1
    package = [ordered]@{
        org = $Org
        ident = $Package.ident
        title = $Package.title
        kind = $Package.kind
        dxrpAddonId = $Package.dxrpAddonId
        hasAssets = [bool]$Package.hasAssets
        hasCode = [bool]$Package.hasCode
    }
    contentRows = $ContentRows
}

$PackageExport |
    ConvertTo-Json -Depth 8 |
    Set-Content -LiteralPath (Join-Path $StagingRoot "package-$($Package.ident).json") -Encoding UTF8

$UploadFiles = @()
if (Test-Path -LiteralPath $UploadRoot) {
    $UploadFiles = @(Get-ChildItem -LiteralPath $UploadRoot -Recurse -File -Force)
}

$UploadSizeMb = if ($UploadFiles.Count -gt 0) {
    [math]::Round((($UploadFiles | Measure-Object Length -Sum).Sum / 1MB), 1)
} else {
    0
}

Write-Host "Prepared DXRP publish staging for $Org.$($Package.ident)" -ForegroundColor Green
Write-Host "Upload root: $UploadRoot"
Write-Host "Staging size: $UploadSizeMb MB ($($UploadFiles.Count) files)" -ForegroundColor $(if ($UploadSizeMb -gt 300) { 'Yellow' } else { 'Green' })
if ($UploadSizeMb -gt 300) {
    Write-Warning "Staging exceeds DXRP ~300 MB upload cap — trim source art or run ship-tier audit."
}

if ($OpenFolder) {
    Invoke-Item $UploadRoot
}
