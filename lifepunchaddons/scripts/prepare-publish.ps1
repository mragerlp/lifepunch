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

# ── SHARED-INFRA OWNERSHIP MAP ───────────────────────────────────────────────────────────
# The LifePunch shared infra lives FLAT at Code/Addons/lifepunch/*.cs — deliberately, because
# the editor compiles the repo as one tree and StaffMenu.razor.scss imports LifePunchUiFooter
# by relative path ("../"). The portal, however, ships only Code/Addons/lifepunch/<ident>/, so
# a flat file reaches a dedicated server ONLY if some addon's bundle carries it.
#
# All addon code compiles into dxura.rp TOGETHER, so a class carried by two published addons is
# a duplicate-definition error (CS0101). Therefore each shared file has EXACTLY ONE owner here,
# and every other addon consumes it as a cross-addon dependency — which requires the owner addon
# to be INSTALLED in the gamemode.
#
# Ownership is a stager-level map, NOT a repo layout. Moving a file's owner is a one-line edit
# here plus a republish of the two addons; the repo tree never moves.
#
# adminmenu (portal ident: lifepunchulx) is the carrier. It already shipped the UI helpers; the
# gameplay/economy infra below was owned by NOBODY, which husked dxura.rp on the lpbitcoin r1
# boot (every consumer referenced classes no addon published). See the closure gate at the end
# of Copy-AddonCode — that failure class now dies at stage time, not on a live server.
$Script:SharedInfraOwner = [ordered]@{
    # UI helpers — shipped in lifepunchulx since r14 (the one set that resolved on r1).
    'LifePunchUiScale.cs'            = 'adminmenu'
    'LifePunchUiScrollPolicy.cs'     = 'adminmenu'
    'LifePunchScrollRegionPanel.cs'  = 'adminmenu'   # also carries LifePunchScrollRegionBootstrap
    'LifePunchScrollLayout.cs'       = 'adminmenu'
    'LifePunchSourceMark.cs'         = 'adminmenu'
    'LifePunchUiFooter.razor'        = 'adminmenu'
    'LifePunchUiFooter.razor.scss'   = 'adminmenu'

    # Gameplay / economy infra — previously unowned. Consumers span lpbitcoin, hackerjob,
    # visiblepocket and advanceddrugprocessing, so they must live in exactly one carrier.
    'LifePunchUpgradeTracks.cs'      = 'adminmenu'   # + LifePunchTrackDef, LifePunchTrackSubjectKind
    'LifePunchUpgradeLedger.cs'      = 'adminmenu'
    'LifePunchEntityOwnership.cs'    = 'adminmenu'   # + TryBindSpawnOwnerHost extension
    'LifePunchPropPhysics.cs'        = 'adminmenu'
    'LifePunchMenuInteractGate.cs'   = 'adminmenu'
    'LifePunchMenuInputBlock.cs'     = 'adminmenu'
    'LifePunchMachineDestroyFx.cs'   = 'adminmenu'
    'LifePunchGroundContact.cs'      = 'adminmenu'
    'LifePunchTerminalLcd.cs'        = 'adminmenu'

    # TRANSITIVE deps of the block above -- the shared files reference each other. Derived from
    # the closure gate, not by hand: LifePunchUpgradeLedger -> ILifePunchPurchaseEvent, and
    # LifePunchMenuInteractGate -> LifePunchInteractTags + LifePunchMenuInteractRange. Omitting
    # these ships a carrier that is itself unresolvable, which husks the server exactly as before.
    'ILifePunchPurchaseEvent.cs'     = 'adminmenu'
    'LifePunchInteractTags.cs'       = 'adminmenu'
    'LifePunchMenuInteractRange.cs'  = 'adminmenu'
}

function Get-SharedInfraFilesOwnedBy {
    param(
        [string]$Ident
    )

    @($Script:SharedInfraOwner.Keys | Where-Object { $Script:SharedInfraOwner[$_] -eq $Ident })
}

function Add-SharedInfraShipDeps {
    param(
        [string]$Ident,
        [string]$SharedCodeRoot,
        [string]$CodeStage
    )

    $Owned = Get-SharedInfraFilesOwnedBy -Ident $Ident
    if ($Owned.Count -eq 0) {
        return
    }

    foreach ($Name in $Owned) {
        $Source = Join-Path $SharedCodeRoot $Name
        if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) {
            throw "Missing shared-infra ship dependency for '$Ident': $Name (expected under $SharedCodeRoot)"
        }

        Copy-Item -LiteralPath $Source -Destination (Join-Path $CodeStage $Name) -Force
    }

    Write-Host "  + shared infra ($Ident owns $($Owned.Count) file(s) from Code\Addons\$Org\)" -ForegroundColor DarkGray
}

# ── SHARED SCSS RESOLVER ─────────────────────────────────────────────────────────────────
# Stylesheets are NOT types. A shared .scss is a preprocessor include, so copying it into every
# consuming bundle is harmless -- unlike a shared .cs/.razor TYPE, where a second copy is CS0101.
# They therefore get the opposite treatment to $Script:SharedInfraOwner: duplicate freely.
#
# In the repo, panel SCSS reaches the shared sheets by RELATIVE path ("../LifePunchUiShell.scss",
# "../../../../LifePunchUiFooter.razor.scss") because the editor compiles one tree. Those paths
# escape the bundle, so on a dedicated server they resolve to nothing. This generalizes the old
# adminmenu-only StaffMenu patch: for every staged .scss that imports a flat shared sheet, drop a
# copy NEXT TO IT and rewrite the import to a bare sibling.
#
# The copy is renamed to "_shared_<Name>.scss" deliberately: a file still called "X.razor.scss"
# would sit in a bundle with no "X.razor" beside it, and s&box associates a component's stylesheet
# by exactly that name. The underscore partial carries no ".razor." fragment, so it can only ever
# be an @import target. The OWNER addon still ships the true "X.razor.scss" via the map above, so
# its component keeps its own styles.
function Resolve-SharedScssImports {
    param(
        [string]$Ident,
        [string]$SharedCodeRoot,
        [string]$CodeStage
    )

    $SharedSheets = @{}
    foreach ($Sheet in @(Get-ChildItem -LiteralPath $SharedCodeRoot -File -Filter '*.scss' -ErrorAction SilentlyContinue)) {
        $SharedSheets[$Sheet.Name] = $Sheet
    }

    if ($SharedSheets.Count -eq 0) {
        return
    }

    $Rewritten = 0
    foreach ($Staged in @(Get-ChildItem -LiteralPath $CodeStage -Recurse -File -Filter '*.scss' -ErrorAction SilentlyContinue)) {
        $Text = [System.IO.File]::ReadAllText($Staged.FullName)
        $Original = $Text

        foreach ($Match in [regex]::Matches($Original, '@import\s+"([^"]+)"\s*;')) {
            $ImportPath = $Match.Groups[1].Value
            if ($ImportPath -notmatch '\.\./') {
                continue
            }

            $Leaf = ($ImportPath -split '/')[-1]
            if (-not $SharedSheets.ContainsKey($Leaf)) {
                continue
            }

            # "LifePunchUiFooter.razor.scss" -> "_shared_LifePunchUiFooter.scss"
            $Base = $Leaf -replace '\.razor\.scss$', '' -replace '\.scss$', ''
            $PartialName = "_shared_$Base.scss"
            $PartialPath = Join-Path $Staged.DirectoryName $PartialName

            if (-not (Test-Path -LiteralPath $PartialPath -PathType Leaf)) {
                Copy-Item -LiteralPath $SharedSheets[$Leaf].FullName -Destination $PartialPath -Force
            }

            $Text = $Text.Replace($Match.Value, "@import `"$PartialName`";")
            $Rewritten++
        }

        if ($Text -ne $Original) {
            [System.IO.File]::WriteAllText($Staged.FullName, $Text)
        }
    }

    if ($Rewritten -gt 0) {
        Write-Host "  + shared scss: $Rewritten import(s) vendored as _shared_*.scss partials" -ForegroundColor DarkGray
    }
}

# ── STAGE-TIME DEPENDENCY-CLOSURE GATE ───────────────────────────────────────────────────
# The editor compiles repo-wide, so it can NEVER catch an unshipped shared dependency; the
# first sensor was a husked gamemode on a live server. This gate reads the staged bytes in
# isolation and asserts every LifePunch* / ILifePunch* type the bundle references is reachable
# on a dedicated server: defined in this bundle, or owned by another addon that is published.
# Anything else throws — same spirit as the ship-dependency throw above, but computed rather
# than hand-listed, so a NEW shared class cannot silently escape the map.
#
# Scope: type-level (class/interface/enum/struct/record). An extension method rides its
# declaring type's file, so covering the type covers the method.
function Assert-StagedCodeClosure {
    param(
        [string]$Ident,
        [string]$SharedCodeRoot,
        [string]$CodeStage
    )

    $TypeDefPattern = '(?:class|interface|enum|struct|record)\s+(I?LifePunch\w+)'
    $RefPattern     = '\bI?LifePunch\w+\b'

    $StagedFiles = @(Get-ChildItem -LiteralPath $CodeStage -Recurse -File -Force -Include *.cs, *.razor -ErrorAction SilentlyContinue)

    # A .razor component is FILENAME-typed -- "LifePunchUiFooter.razor" declares the type
    # LifePunchUiFooter via @namespace/@inherits, with no "class X" to match. Scanning only for
    # type declarations misses it and reports a real, correctly-owned dependency as unresolvable.
    function Get-DefinedTypes {
        param([System.IO.FileInfo[]]$Files)

        $Map = @{}
        foreach ($File in $Files) {
            if ($File.Name -like '*.razor') {
                $Map[[System.IO.Path]::GetFileNameWithoutExtension($File.Name)] = $File
            }

            $Text = [System.IO.File]::ReadAllText($File.FullName)
            foreach ($M in [regex]::Matches($Text, $TypeDefPattern)) {
                $Map[$M.Groups[1].Value] = $File
            }
        }

        $Map
    }

    # Types this bundle defines itself.
    $DefinedHere = (Get-DefinedTypes -Files $StagedFiles).Keys

    # Every LifePunch* type this bundle references -- from CODE only. Comments and string literals
    # must be stripped first, or a name that is merely mentioned reads as a dependency: adminmenu's
    # StaffMenuHost has `MenuObjectName = "LifePunchUlx"`, a GameObject name, not a type.
    # A .razor tag (<LifePunchUiFooter />) is not quoted, so it survives the strip, as it must.
    function Remove-CodeNoise {
        param([string]$Text)

        $Text = [regex]::Replace($Text, '@\*[\s\S]*?\*@', ' ')          # razor comments
        $Text = [regex]::Replace($Text, '/\*[\s\S]*?\*/', ' ')          # block comments
        $Text = [regex]::Replace($Text, '(?m)//.*$', ' ')               # line comments
        $Text = [regex]::Replace($Text, '@"(?:[^"]|"")*"', '""')        # verbatim strings
        $Text = [regex]::Replace($Text, '"(?:\\.|[^"\\])*"', '""')      # string literals
        $Text
    }

    $Referenced = New-Object System.Collections.Generic.HashSet[string]
    foreach ($File in $StagedFiles) {
        $Text = Remove-CodeNoise ([System.IO.File]::ReadAllText($File.FullName))
        foreach ($M in [regex]::Matches($Text, $RefPattern)) {
            [void]$Referenced.Add($M.Value)
        }
    }

    # Where each shared type is DEFINED in the repo, and therefore which addon publishes it.
    $DefiningFile = Get-DefinedTypes -Files @(Get-ChildItem -LiteralPath $SharedCodeRoot -Recurse -File -Force -Include *.cs, *.razor -ErrorAction SilentlyContinue)

    # Stylesheet basenames are NOT types (e.g. "LifePunchUiShell" exists only as LifePunchUiShell.scss).
    # They are vendored per-bundle by Resolve-SharedScssImports, so they must not be closure-checked
    # as C# symbols -- but a shared sheet with NO .scss on disk would still be a real miss, so this
    # exemption is keyed to a file that actually exists.
    $SharedSheetNames = New-Object System.Collections.Generic.HashSet[string]
    foreach ($Sheet in @(Get-ChildItem -LiteralPath $SharedCodeRoot -File -Filter '*.scss' -ErrorAction SilentlyContinue)) {
        [void]$SharedSheetNames.Add(($Sheet.Name -replace '\.razor\.scss$', '' -replace '\.scss$', ''))
    }

    $SharedRootFull = (Resolve-Path -LiteralPath $SharedCodeRoot).Path
    $Unresolved = @()
    $CrossAddon = @{}

    foreach ($Symbol in $Referenced) {
        if ($DefinedHere -contains $Symbol) {
            continue
        }

        if ($SharedSheetNames.Contains($Symbol)) {
            continue   # a stylesheet, vendored by Resolve-SharedScssImports -- not a C# type
        }

        if (-not $DefiningFile.ContainsKey($Symbol)) {
            $Unresolved += "$Symbol - referenced by the bundle, DEFINED NOWHERE under Code\Addons\$Org\"
            continue
        }

        $File = $DefiningFile[$Symbol]
        $Relative = $File.FullName.Substring($SharedRootFull.Length).TrimStart('\', '/')
        $Parts = $Relative -split '[\\/]'

        if ($Parts.Count -eq 1) {
            # A FLAT shared file. It reaches a dedicated server only if the map gives it an owner.
            $Owner = $Script:SharedInfraOwner[$Parts[0]]
            if (-not $Owner) {
                $Unresolved += "$Symbol ($($Parts[0])) - flat shared infra with NO OWNER in `$Script:SharedInfraOwner; no addon publishes it"
            } elseif ($Owner -eq $Ident) {
                $Unresolved += "$Symbol ($($Parts[0])) - owned by '$Ident' but NOT STAGED (Add-SharedInfraShipDeps did not copy it)"
            } else {
                $CrossAddon[$Owner] = $true
            }
        } else {
            # Defined inside another addon's folder — a cross-addon dependency on that addon.
            if ($Parts[0] -ne $Ident) {
                $CrossAddon[$Parts[0]] = $true
            }
        }
    }

    if ($Unresolved.Count -gt 0) {
        $Detail = ($Unresolved | Sort-Object | ForEach-Object { "  - $_" }) -join "`n"
        throw "DEPENDENCY CLOSURE FAILED for '$Ident': the staged bundle references types no published addon carries. A dedicated server will fail to compile dxura.rp (gamemode husk).`n$Detail`nFix: give each file an owner in `$Script:SharedInfraOwner, then republish the owner addon."
    }

    if ($CrossAddon.Keys.Count -gt 0) {
        $Owners = ($CrossAddon.Keys | Sort-Object) -join ', '
        Write-Host "  closure gate: PASS (cross-addon deps: $Owners - these MUST be installed in the gamemode)" -ForegroundColor Yellow
    } else {
        Write-Host "  closure gate: PASS (bundle is self-contained)" -ForegroundColor Green
    }
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

    if ($FromDxrpGame) {
        $SharedCodeRoot = Join-Path $dxrpGame "Code\Addons\$Org"
    } else {
        $SharedCodeRoot = Join-Path $Root "Code\Addons\$Org"
    }

    # Any addon that OWNS shared infra carries it in its bundle (adminmenu today, per the map).
    Add-SharedInfraShipDeps -Ident $Package.ident -SharedCodeRoot $SharedCodeRoot -CodeStage $CodeStage

    # Shared stylesheets are vendored into whichever bundle imports them (duplication is safe).
    Resolve-SharedScssImports -Ident $Package.ident -SharedCodeRoot $SharedCodeRoot -CodeStage $CodeStage

    $codeFiles = @(Get-ChildItem -LiteralPath $CodeStage -Recurse -File -Force -ErrorAction SilentlyContinue)
    Write-Host "Code source: $Script:CodeSourceKind -> $Script:CodeSourcePath" -ForegroundColor Cyan
    if ($Script:HubCodeSourcePath) {
        Write-Host "  + hub code: $Script:HubCodeSourcePath" -ForegroundColor DarkGray
    }
    Write-Host "  staged code files: $($codeFiles.Count)" -ForegroundColor Green

    # Every bundle is asserted closed against a dedicated-server compile before it can ship.
    Assert-StagedCodeClosure -Ident $Package.ident -SharedCodeRoot $SharedCodeRoot -CodeStage $CodeStage
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
