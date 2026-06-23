$ErrorActionPreference = 'Stop'

$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$ManifestPath = Join-Path $Root 'config\addons.json'
$ValidKinds = @('weapon', 'simple-entity', 'interactive-entity', 'code-only')
$ValidWeaponGroupings = @('Primary', 'Secondary', 'Utility', 'Melee')

$Errors = New-Object System.Collections.Generic.List[string]

function Add-LayoutError {
    param([string]$Message)
    $Errors.Add($Message) | Out-Null
}

function Test-RequiredDirectory {
    param([string]$RelativePath)

    $Path = Join-Path $Root $RelativePath
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        Add-LayoutError "Missing required directory: $RelativePath"
    }
}

function Test-RequiredFile {
    param([string]$RelativePath)

    $Path = Join-Path $Root $RelativePath
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        Add-LayoutError "Missing required file: $RelativePath"
    }
}

function Test-ManifestProperty {
    param(
        [object]$Object,
        [string]$Name
    )

    return $Object.PSObject.Properties.Name -contains $Name
}

function Test-ContentReference {
    param(
        [string]$Reference,
        [string]$Context,
        [string]$ExpectedPrefix
    )

    if ([string]::IsNullOrWhiteSpace($Reference)) {
        Add-LayoutError "$Context is empty"
        return
    }

    if ($Reference.Contains('\')) {
        Add-LayoutError "$Context must use forward slashes: $Reference"
    }

    if ($Reference.StartsWith('/') -or $Reference.StartsWith('Assets/')) {
        Add-LayoutError "$Context must be relative to the mounted Assets root: $Reference"
    }

    if (-not [string]::IsNullOrWhiteSpace($ExpectedPrefix) -and -not $Reference.StartsWith($ExpectedPrefix)) {
        Add-LayoutError "$Context must start with '$ExpectedPrefix': $Reference"
    }
}

function Test-MountedAssetReferenceFile {
    param(
        [string]$Reference,
        [string]$Context
    )

    if ([string]::IsNullOrWhiteSpace($Reference) -or -not $Reference.StartsWith('addons/')) {
        return
    }

    $RelativePath = Join-Path 'Assets' ($Reference -replace '/', '\')
    Test-RequiredFile $RelativePath
}

$RequiredDirectories = @(
    'Assets',
    'Assets\addons',
    'Assets\addons\official',
    'Assets\addons\lifepunch',
    'Code',
    'Code\Addons',
    'Code\Addons\Official',
    'Code\Addons\lifepunch',
    'config',
    'docs',
    'scripts'
)

foreach ($Directory in $RequiredDirectories) {
    Test-RequiredDirectory $Directory
}

Test-RequiredFile 'config\addons.json'

$Manifest = $null
if (Test-Path -LiteralPath $ManifestPath -PathType Leaf) {
    try {
        $Manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
    } catch {
        Add-LayoutError "config\addons.json is not valid JSON: $($_.Exception.Message)"
    }
}

$AssetsOrgRoot = Join-Path $Root 'Assets\addons'
if (Test-Path -LiteralPath $AssetsOrgRoot -PathType Container) {
    $AllowedAssetOrgs = @('official', 'lifepunch')
    Get-ChildItem -LiteralPath $AssetsOrgRoot -Directory -Force | ForEach-Object {
        if ($_.Name -notin $AllowedAssetOrgs) {
            Add-LayoutError "Unexpected assets org folder: Assets\addons\$($_.Name)"
        }
    }
}

$CodeOrgRoot = Join-Path $Root 'Code\Addons'
if (Test-Path -LiteralPath $CodeOrgRoot -PathType Container) {
    $AllowedCodeOrgs = @('Official', 'lifepunch')
    Get-ChildItem -LiteralPath $CodeOrgRoot -Directory -Force | ForEach-Object {
        if ($_.Name -notin $AllowedCodeOrgs) {
            Add-LayoutError "Unexpected code org folder: Code\Addons\$($_.Name)"
        }
    }
}

$LegacyFolders = Get-ChildItem -LiteralPath $Root -Directory -Recurse -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -in @('upload-assets', 'upload-code') }

foreach ($Folder in $LegacyFolders) {
    $Relative = Resolve-Path -LiteralPath $Folder.FullName -Relative
    Add-LayoutError "Legacy flat publish folder is not allowed: $Relative"
}

if ($null -ne $Manifest) {
    if ($Manifest.schemaVersion -ne 1) {
        Add-LayoutError 'config\addons.json must use schemaVersion 1'
    }

    if ($Manifest.org -ne 'lifepunch') {
        Add-LayoutError "Manifest org must be 'lifepunch'"
    }

    $Addons = @($Manifest.addons)
    if ($Addons.Count -eq 0) {
        Add-LayoutError 'Manifest must declare at least one addon package'
    }

    $SeenIdents = New-Object System.Collections.Generic.HashSet[string]

    foreach ($Addon in $Addons) {
        foreach ($RequiredProperty in @('ident', 'title', 'kind', 'hasAssets', 'hasCode', 'dxrpAddonId', 'contents')) {
            if (-not (Test-ManifestProperty $Addon $RequiredProperty)) {
                Add-LayoutError "Manifest addon is missing property '$RequiredProperty'"
            }
        }

        $Ident = [string]$Addon.ident
        $Kind = [string]$Addon.kind
        $HasAssets = [bool]$Addon.hasAssets
        $HasCode = [bool]$Addon.hasCode

        if ([string]::IsNullOrWhiteSpace($Ident) -or $Ident -notmatch '^[a-z0-9][a-z0-9-]*$') {
            Add-LayoutError "Manifest addon ident must be lowercase package text: $Ident"
            continue
        }

        if (-not $SeenIdents.Add($Ident)) {
            Add-LayoutError "Duplicate manifest addon ident: $Ident"
        }

        if ($Kind -notin $ValidKinds) {
            Add-LayoutError "Manifest addon '$Ident' has invalid kind '$Kind'"
        }

        if ($Kind -eq 'code-only' -and ($HasAssets -or -not $HasCode)) {
            Add-LayoutError "Manifest addon '$Ident' is code-only and must set hasAssets=false, hasCode=true"
        }

        if ($Kind -eq 'interactive-entity' -and (-not $HasAssets -or -not $HasCode)) {
            Add-LayoutError "Manifest addon '$Ident' is interactive-entity and must set hasAssets=true, hasCode=true"
        }

        if ($Kind -in @('weapon', 'simple-entity') -and -not $HasAssets) {
            Add-LayoutError "Manifest addon '$Ident' kind '$Kind' must set hasAssets=true"
        }

        if ($HasAssets) {
            Test-RequiredDirectory "Assets\addons\lifepunch\$Ident"
        }

        if ($HasCode) {
            Test-RequiredDirectory "Code\Addons\lifepunch\$Ident"
        }

        if (Test-Path -LiteralPath (Join-Path $Root "Assets\$Ident") -PathType Container) {
            Add-LayoutError "LifePunch assets must be under Assets\addons\lifepunch\$Ident, not Assets\$Ident"
        }

        if (Test-Path -LiteralPath (Join-Path $Root "Code\$Ident") -PathType Container) {
            Add-LayoutError "LifePunch code must be under Code\Addons\lifepunch\$Ident, not Code\$Ident"
        }

        $Contents = @($Addon.contents)
        foreach ($Content in $Contents) {
            $ContentContext = "$Ident content '$($Content.label)'"
            $Type = $Content.type

            if ($Kind -eq 'weapon') {
                if ($Type -ne 1) {
                    Add-LayoutError "$ContentContext must use DXRP type 1 for weapon content"
                }

                Test-ContentReference ([string]$Content.primaryReference) "$ContentContext primaryReference" "addons/lifepunch/$Ident/equipment/"

                # secondaryReference (viewmodel) may be either this addon's own equipment prefab,
                # or a base-game/shared viewmodel (e.g. gameplay/equipment/weapons/m4a1/vm_m4a1.prefab)
                # used as an intentional placeholder. Base-content refs are not in this repo, so they
                # are validated for shape only (no file-existence / addon-prefix requirement).
                $SecondaryRef = [string]$Content.secondaryReference
                if ([string]::IsNullOrWhiteSpace($SecondaryRef)) {
                    Add-LayoutError "$ContentContext secondaryReference is empty"
                } elseif ($SecondaryRef.StartsWith('addons/')) {
                    Test-ContentReference $SecondaryRef "$ContentContext secondaryReference" "addons/lifepunch/$Ident/equipment/"
                } else {
                    Test-ContentReference $SecondaryRef "$ContentContext secondaryReference" ''
                }

                Test-ContentReference ([string]$Content.worldModelPath) "$ContentContext worldModelPath" "addons/lifepunch/$Ident/models/"

                if (Test-ManifestProperty $Content 'iconPath' -and -not [string]::IsNullOrWhiteSpace([string]$Content.iconPath)) {
                    $IconPathForValidation = ([string]$Content.iconPath).TrimStart('/')
                    Test-ContentReference $IconPathForValidation "$ContentContext iconPath" "addons/lifepunch/$Ident/ui/"
                    Test-MountedAssetReferenceFile $IconPathForValidation "$ContentContext iconPath"
                }

                if ([string]::IsNullOrWhiteSpace([string]$Content.grouping) -or [string]$Content.grouping -notin $ValidWeaponGroupings) {
                    Add-LayoutError "$ContentContext grouping must be one of: $($ValidWeaponGroupings -join ', ')"
                }
            } elseif ($Kind -in @('simple-entity', 'interactive-entity')) {
                if ($Type -ne 0) {
                    Add-LayoutError "$ContentContext must use DXRP type 0 for entity content"
                }

                Test-ContentReference ([string]$Content.primaryReference) "$ContentContext primaryReference" "addons/lifepunch/$Ident/entities/"

                if (Test-ManifestProperty $Content 'secondaryReference' -and -not [string]::IsNullOrWhiteSpace([string]$Content.secondaryReference)) {
                    Add-LayoutError "$ContentContext must not set secondaryReference"
                }
            } elseif ($Kind -eq 'code-only' -and $Contents.Count -gt 0) {
                Add-LayoutError "Code-only addon '$Ident' must not declare asset content rows"
            }
        }
    }
}

# lifepunchulx (adminmenu) — r6 ship gate: six publish files only. Test bots live in Code/_dev/.
$AdminMenuCodeRoot = Join-Path $Root 'Code\Addons\lifepunch\adminmenu'
if (Test-Path -LiteralPath $AdminMenuCodeRoot -PathType Container) {
    $AllowedAdminMenuShipFiles = @(
        'StaffMenu.razor',
        'StaffMenu.razor.scss',
        'StaffMenuActions.cs',
        'StaffMenuHost.cs',
        'StaffSettingsService.cs',
        'WaypointSyncService.cs'
    )

    Get-ChildItem -LiteralPath $AdminMenuCodeRoot -File -Force | ForEach-Object {
        $Name = $_.Name
        if ($Name -match '(?i)TestBots|DevGive|DevSpawn') {
            Add-LayoutError "adminmenu (lifepunchulx) must not contain editor-only helpers (move to Code/_dev/): $Name"
            return
        }

        if ($_.Extension -in @('.cs', '.razor', '.scss') -and
            $AllowedAdminMenuShipFiles -notcontains $Name) {
            Add-LayoutError "adminmenu (lifepunchulx) unexpected source (r6 ship 6 only): $Name"
        }
    }
}

if ($Errors.Count -gt 0) {
    Write-Host 'DXRP layout validation failed:' -ForegroundColor Red
    foreach ($ErrorMessage in $Errors) {
        Write-Host " - $ErrorMessage" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'DXRP layout validation passed.' -ForegroundColor Green
