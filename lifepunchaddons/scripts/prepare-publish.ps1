param(
    [Parameter(Mandatory = $true)]
    [string]$Addon,

    [switch]$OpenFolder,

    # Ship-tier: read Assets (*_c) + Code from the live DXRP editor game tree.
    [switch]$FromDxrpGame,

    [string]$DxrpConfigPath = ''
)

$ErrorActionPreference = 'Stop'

$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$ManifestPath = Join-Path $Root 'config\addons.json'
$UploadRoot = Join-Path $Root '.dxrp-publish\upload'
$Script:AssetsSourceKind = 'repo'
$Script:AssetsSourcePath = ''
$Script:CodeSourceKind = 'repo'
$Script:CodeSourcePath = ''
$Script:HubCodeSourcePath = ''

$Script:ShipAssetExcludeExtensions = @('.blend', '.fbx', '.tga', '.obj')
$Script:ShipAssetExcludeFolders = @('source', '_archive', 'audit', 'docs', '_dev')
$Script:PortalUploadMaxMb = 300

# Parked — not in Rev 3 ship set (portal BTC redeem rail deferred).
$Script:BitcoinShipAssetPrunePatterns = @(
    'btccashredeem.prefab',
    'btccashredeem.prefab_c',
    'btccashredeem.vmdl',
    'btccashredeem.vmdl_c'
)

function Test-BitcoinParkedAssetFile {
    param([string]$FileName)

    if ($FileName -like 'btccashredeem*') { return $true }
    return $FileName -in $Script:BitcoinShipAssetPrunePatterns
}

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

    if ($ShipAssetsOnly -and (Test-BitcoinParkedAssetFile -FileName $File.Name)) {
        return $false
    }

    if ($ShipAssetsOnly -and $File.Extension -in $Script:ShipAssetExcludeExtensions) {
        return $false
    }

    return $true
}

function Resolve-DxrpGameRoot {
    param([string]$ConfigPath)

    if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
        $ConfigPath = Join-Path $Root '..\scripts\dxrp-editor.local.json'
    }

    if (-not (Test-Path -LiteralPath $ConfigPath)) {
        throw "Missing DXRP editor config: $ConfigPath (copy dxrp-editor.local.json.example)."
    }

    $cfg = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
    $project = [string]$cfg.projectPath
    if ([string]::IsNullOrWhiteSpace($project) -or -not (Test-Path -LiteralPath $project)) {
        throw "DXRP project not found in config: $project"
    }

    return (Split-Path -Parent $project)
}

function Get-PublishAssetFolderName {
    param([string]$Ident)

    if ($Ident -eq 'bitcoinmining') { return 'lpbitcoin' }
    return $Ident
}

function Resolve-PortalUploadLayout {
    param(
        [Parameter(Mandatory = $true)]
        $Package,
        [string]$Org,
        [string]$UploadRoot
    )

    $publishFolder = Get-DxrpPublishFolderName -Package $Package
    $assetFolder = Get-PublishAssetFolderName -Ident $Package.ident

    if ($Package.ident -eq 'bitcoinmining') {
        $packageRoot = Join-Path $UploadRoot (Join-Path $Org $assetFolder)
        return [ordered]@{
            Layout          = 'lifepunch-package'
            NetworkFolder   = $Org
            PackageFolder   = $assetFolder
            PackageRoot     = $packageRoot
            AssetsStage     = Join-Path $packageRoot 'Assets'
            AssetsMountRoot = Join-Path $packageRoot (Join-Path 'Assets' (Join-Path 'addons' (Join-Path $Org $assetFolder)))
            CodeStage       = Join-Path $packageRoot 'Code'
            PublishFolder   = $assetFolder
        }
    }

    return [ordered]@{
        Layout          = 'game-mirror'
        NetworkFolder   = $Org
        PackageFolder   = $publishFolder
        PackageRoot     = $UploadRoot
        AssetsStage     = Join-Path $UploadRoot (Join-Path 'Assets' (Join-Path 'addons' (Join-Path $Org $assetFolder)))
        AssetsMountRoot = Join-Path $UploadRoot (Join-Path 'Assets' (Join-Path 'addons' (Join-Path $Org $assetFolder)))
        CodeStage       = Join-Path $UploadRoot (Join-Path 'Code' (Join-Path 'Addons' (Join-Path $Org $publishFolder)))
        PublishFolder   = $publishFolder
    }
}

function Invoke-PruneLpBitcoinPublishStaging {
    param(
        [string]$AssetsMountRoot,
        [string]$CodeStage
    )

    $removed = 0

    if (Test-Path -LiteralPath $AssetsMountRoot) {
        foreach ($pattern in $Script:BitcoinShipAssetPrunePatterns) {
            Get-ChildItem -LiteralPath $AssetsMountRoot -Recurse -File -Force -Filter $pattern -ErrorAction SilentlyContinue |
                ForEach-Object {
                    Remove-Item -LiteralPath $_.FullName -Force
                    $removed++
                }
        }

        Get-ChildItem -LiteralPath $AssetsMountRoot -Recurse -File -Force -Filter 'btccashredeem*' -ErrorAction SilentlyContinue |
            ForEach-Object {
                Remove-Item -LiteralPath $_.FullName -Force
                $removed++
            }

        # Retired top-level slot folder (advanced rack lives under gpurack/).
        $retiredSlot = Join-Path $AssetsMountRoot 'advancedgpurack'
        if (Test-Path -LiteralPath $retiredSlot) {
            Remove-Item -LiteralPath $retiredSlot -Recurse -Force
            $removed++
        }
    }

    if (Test-Path -LiteralPath $CodeStage) {
        Get-ChildItem -LiteralPath $CodeStage -Recurse -File -Force -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match '(DevSpawn|TestBots|DevGive)' } |
            ForEach-Object {
                Remove-Item -LiteralPath $_.FullName -Force
                $removed++
            }
    }

    if ($removed -gt 0) {
        Write-Host "  pruned $removed non-ship / dev-only file(s)" -ForegroundColor DarkGray
    }
}

function Write-PublishSizeReport {
    param(
        [string]$UploadRoot,
        [string]$AssetsStage,
        [string]$CodeStage
    )

    $assetsBytes = 0L
    $codeBytes = 0L
    if (Test-Path -LiteralPath $AssetsStage) {
        $assetsBytes = (Get-ChildItem -LiteralPath $AssetsStage -Recurse -File -Force -ErrorAction SilentlyContinue |
            Measure-Object Length -Sum).Sum
    }
    if (Test-Path -LiteralPath $CodeStage) {
        $codeBytes = (Get-ChildItem -LiteralPath $CodeStage -Recurse -File -Force -ErrorAction SilentlyContinue |
            Measure-Object Length -Sum).Sum
    }

    $totalMb = [math]::Round((($assetsBytes + $codeBytes) / 1MB), 1)
    $assetsMb = [math]::Round(($assetsBytes / 1MB), 1)
    $codeMb = [math]::Round(($codeBytes / 1MB), 1)

    Write-Host "  size budget: $totalMb MB total (Assets $assetsMb MB + Code $codeMb MB) cap $($Script:PortalUploadMaxMb) MB" -ForegroundColor $(if ($totalMb -gt $Script:PortalUploadMaxMb) { 'Yellow' } else { 'Green' })

    if ($totalMb -gt $Script:PortalUploadMaxMb) {
        Write-Warning "Over DXRP portal cap ($totalMb MB > $($Script:PortalUploadMaxMb) MB). Trim source art, drop non-ship assets, or re-run after ModelDoc ship audit."
        $largest = @(Get-ChildItem -LiteralPath $UploadRoot -Recurse -File -Force -ErrorAction SilentlyContinue |
            Sort-Object Length -Descending |
            Select-Object -First 8)
        foreach ($file in $largest) {
            $rel = $file.FullName.Substring($UploadRoot.Length).TrimStart('\', '/')
            $mb = [math]::Round($file.Length / 1MB, 2)
            Write-Host "    $mb MB  $rel" -ForegroundColor DarkYellow
        }
    }

    return [ordered]@{
        totalMb  = $totalMb
        assetsMb = $assetsMb
        codeMb   = $codeMb
    }
}

function Test-PublishCompiledAssetCoverage {
    param([string]$AssetsRoot)

    if (-not (Test-Path -LiteralPath $AssetsRoot)) {
        return [ordered]@{ compiled = 0; total = 0; missing = @('(assets root missing)') }
    }

    $shipFiles = @(Get-ChildItem -LiteralPath $AssetsRoot -Recurse -File -Force -ErrorAction SilentlyContinue |
        Where-Object {
            $Relative = $_.FullName.Substring($AssetsRoot.Length).TrimStart('\', '/')
            $RelativeParts = $Relative -split '[\\/]'
            Test-PublishShipFile -File $_ -RelativeParts $RelativeParts -ShipAssetsOnly
        })

    $compiled = @($shipFiles | Where-Object { $_.Extension -match '_c$' })
    $missing = @()

    foreach ($prefab in @($shipFiles | Where-Object { $_.Extension -eq '.prefab' })) {
        $compiledSibling = $prefab.FullName + '_c'
        if (-not (Test-Path -LiteralPath $compiledSibling)) {
            $missing += ($prefab.FullName.Substring($AssetsRoot.Length).TrimStart('\', '/'))
        }
    }

    foreach ($vmdl in @($shipFiles | Where-Object { $_.Extension -eq '.vmdl' })) {
        $compiledSibling = $vmdl.FullName + '_c'
        if (-not (Test-Path -LiteralPath $compiledSibling)) {
            $missing += ($vmdl.FullName.Substring($AssetsRoot.Length).TrimStart('\', '/'))
        }
    }

    return [ordered]@{
        compiled = $compiled.Count
        total    = $shipFiles.Count
        missing  = @($missing | Select-Object -Unique)
    }
}

function Get-DxrpPublishFolderName {
    param(
        [Parameter(Mandatory = $true)]
        $Package
    )

    if ($Package.PSObject.Properties['dxrpAddonIdentifier'] -and -not [string]::IsNullOrWhiteSpace( $Package.dxrpAddonIdentifier )) {
        return [string]$Package.dxrpAddonIdentifier
    }

    if ($Package.PSObject.Properties['packageSlug'] -and -not [string]::IsNullOrWhiteSpace( $Package.packageSlug )) {
        return [string]$Package.packageSlug
    }

    return [string]$Package.ident
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
$PublishFolder = Get-DxrpPublishFolderName -Package $Package
$Layout = Resolve-PortalUploadLayout -Package $Package -Org $Org -UploadRoot $UploadRoot
$AssetsStage = [string]$Layout.AssetsStage
$AssetsMountRoot = [string]$Layout.AssetsMountRoot
$CodeStage = [string]$Layout.CodeStage
$Script:PortalLayout = [string]$Layout.Layout
$dxrpGame = $null
if ($FromDxrpGame) {
    $dxrpGame = Resolve-DxrpGameRoot -ConfigPath $DxrpConfigPath
}

if ($Package.hasAssets) {
    $assetFolder = Get-PublishAssetFolderName -Ident $Package.ident

    if ($FromDxrpGame) {
        $AssetsSource = Join-Path $dxrpGame "Assets\addons\$Org\$assetFolder"
        $Script:AssetsSourceKind = 'dxrp-game'
        $Script:AssetsSourcePath = $AssetsSource

        if (-not (Test-Path -LiteralPath $AssetsSource -PathType Container)) {
            throw "FromDxrpGame: DXRP assets missing at: $AssetsSource. Run Sync-LifePunchAddonsToDxrp.ps1, compile in ModelDoc, then retry."
        }
    } elseif ($Package.ident -eq 'bitcoinmining') {
        $AssetsSource = Join-Path $Root "Assets\addons\$Org\lpbitcoin"
        $Script:AssetsSourcePath = $AssetsSource
    } else {
        $AssetsSource = Join-Path $Root "Assets\addons\$Org\$($Package.ident)"
        $Script:AssetsSourcePath = $AssetsSource
    }

    New-Item -ItemType Directory -Force -Path $AssetsMountRoot | Out-Null
    Copy-PublishItems -Source $AssetsSource -Destination $AssetsMountRoot -ShipAssetsOnly:($Package.ident -eq 'bitcoinmining')

    $coverage = Test-PublishCompiledAssetCoverage -AssetsRoot $AssetsMountRoot
    Write-Host "Assets source: $Script:AssetsSourceKind -> $Script:AssetsSourcePath" -ForegroundColor Cyan
    Write-Host "  ship files: $($coverage.total) | compiled _c: $($coverage.compiled)" -ForegroundColor $(if ($coverage.compiled -gt 0) { 'Green' } else { 'Yellow' })
    if ($coverage.missing.Count -gt 0) {
        Write-Warning "Missing compiled siblings for $($coverage.missing.Count) prefab/vmdl - open ModelDoc on DXRP game Assets and recompile before portal upload."
        $coverage.missing | Select-Object -First 8 | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkYellow }
        if ($coverage.missing.Count -gt 8) {
            Write-Host "    ... + $($coverage.missing.Count - 8) more" -ForegroundColor DarkYellow
        }
    }
}

if ($Package.hasCode) {
    if ($FromDxrpGame) {
        $CodeSource = Join-Path $dxrpGame "Code\Addons\$Org\$($Package.ident)"
        $Script:CodeSourceKind = 'dxrp-game'
        $Script:CodeSourcePath = $CodeSource

        if (-not (Test-Path -LiteralPath $CodeSource -PathType Container)) {
            throw "FromDxrpGame: DXRP code missing at: $CodeSource. Run Sync-LifePunchAddonsToDxrp.ps1, Stop then Play (compile), then retry."
        }
    } else {
        $CodeSource = Join-Path $Root "Code\Addons\$Org\$($Package.ident)"
        $Script:CodeSourcePath = $CodeSource
    }

    New-Item -ItemType Directory -Force -Path $CodeStage | Out-Null
    Copy-PublishItems -Source $CodeSource -Destination $CodeStage

    if ($Package.ident -eq 'bitcoinmining') {
        if ($FromDxrpGame) {
            $HubCodeSource = Join-Path $dxrpGame "Code\Addons\$Org\lpbitcoin\bitcoinhub\code"
        } else {
            $HubCodeSource = Join-Path $Root "Code\Addons\$Org\lpbitcoin\bitcoinhub\code"
        }

        $Script:HubCodeSourcePath = $HubCodeSource
        Copy-PublishItems -Source $HubCodeSource -Destination $CodeStage
    }

    if ($Package.ident -eq 'adminmenu') {
        if ($FromDxrpGame) {
            $SharedCodeRoot = Join-Path $dxrpGame "Code\Addons\$Org"
        } else {
            $SharedCodeRoot = Join-Path $Root "Code\Addons\$Org"
        }

        Add-AdminMenuSharedShipDeps -SharedCodeRoot $SharedCodeRoot -CodeStage $CodeStage
    }

    $codeFiles = @(Get-ChildItem -LiteralPath $CodeStage -Recurse -File -Force -ErrorAction SilentlyContinue)
    Write-Host "Code source: $Script:CodeSourceKind -> $Script:CodeSourcePath" -ForegroundColor Cyan
    if ($Script:HubCodeSourcePath) {
        Write-Host "  + hub code: $Script:HubCodeSourcePath" -ForegroundColor DarkGray
    }
    Write-Host "  staged code files: $($codeFiles.Count)" -ForegroundColor Green
}

if ($Package.ident -eq 'bitcoinmining') {
    Invoke-PruneLpBitcoinPublishStaging -AssetsMountRoot $AssetsMountRoot -CodeStage $CodeStage
}

$sizeReport = Write-PublishSizeReport -UploadRoot $UploadRoot -AssetsStage $AssetsStage -CodeStage $CodeStage

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

Assets source ($Script:AssetsSourceKind):
  $Script:AssetsSourcePath

Code source ($Script:CodeSourceKind):
  $Script:CodeSourcePath
$(if ($Script:HubCodeSourcePath) { "  + hub: $Script:HubCodeSourcePath" } else { '' })

Upload root:
  $UploadRoot

Portal upload layout ($Script:PortalLayout):
  lifepunch/lpbitcoin/Assets/   (bitcoin: runtime paths under addons/lifepunch/lpbitcoin/)
  lifepunch/lpbitcoin/Code/

Package:
  Title:      $($Package.title)
  Kind:       $($Package.kind)
  HasAssets:  $($Package.hasAssets)
  HasCode:    $($Package.hasCode)

Expected portal paths (bitcoin):
  upload/lifepunch/lpbitcoin/Assets/addons/lifepunch/lpbitcoin/{bitcoinhub,hashdterminal,gpurack}/
  upload/lifepunch/lpbitcoin/Code/

Expected DXRP paths (other addons, game-mirror layout):
  Assets/addons/$Org/$PublishFolder/
  Code/Addons/$Org/$PublishFolder/

Size (Assets + Code): $($sizeReport.totalMb) MB (cap $($Script:PortalUploadMaxMb) MB)

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
        publishFolder = $Layout.PublishFolder
        portalLayout = $Layout.Layout
        uploadAssetsRoot = if ($Layout.Layout -eq 'lifepunch-package') { "lifepunch/$($Layout.PackageFolder)/Assets" } else { "Assets/addons/$Org/$($Layout.PublishFolder)" }
        uploadCodeRoot = if ($Layout.Layout -eq 'lifepunch-package') { "lifepunch/$($Layout.PackageFolder)/Code" } else { "Code/Addons/$Org/$($Layout.PublishFolder)" }
        sboxIdentifier = $Package.sboxIdentifier
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

Write-Host "Prepared DXRP publish staging for $Org.$($Package.ident)" -ForegroundColor Green
Write-Host "Upload root: $UploadRoot"
if ($Layout.Layout -eq 'lifepunch-package') {
    Write-Host "Portal pick:" -ForegroundColor Cyan
    Write-Host "  Assets -> lifepunch\lpbitcoin\Assets" -ForegroundColor Cyan
    Write-Host "  Code   -> lifepunch\lpbitcoin\Code" -ForegroundColor Cyan
}
Write-Host "Staging size: $($sizeReport.totalMb) MB (Assets $($sizeReport.assetsMb) + Code $($sizeReport.codeMb))" -ForegroundColor $(if ($sizeReport.totalMb -gt $Script:PortalUploadMaxMb) { 'Yellow' } else { 'Green' })
if ($sizeReport.totalMb -gt $Script:PortalUploadMaxMb) {
    Write-Warning "Staging exceeds DXRP $($Script:PortalUploadMaxMb) MB upload cap - trim before portal upload."
}

$UploadFiles = @()
if (Test-Path -LiteralPath $UploadRoot) {
    $UploadFiles = @(Get-ChildItem -LiteralPath $UploadRoot -Recurse -File -Force)
}
Write-Host "  $($UploadFiles.Count) files staged" -ForegroundColor DarkGray

if ($OpenFolder) {
    Invoke-Item $UploadRoot
}
