$ErrorActionPreference = 'Stop'

$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$Errors = New-Object System.Collections.Generic.List[string]

function Add-ValidationError {
    param([string]$Message)
    $Errors.Add($Message) | Out-Null
}

foreach ($Directory in @(
    'gamemodes',
    'config',
    'docs',
    'scripts'
)) {
    $Path = Join-Path $Root $Directory
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        Add-ValidationError "Missing required gamemode directory: $Directory"
    }
}

function Test-JsonFile {
    param(
        [string]$RelativePath,
        [string]$ExpectedSchemaVersion = '1'
    )

    $Path = Join-Path $Root $RelativePath
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        Add-ValidationError "Missing required file: $RelativePath"
        return $null
    }

    try {
        $Json = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
        if ([string]$Json.schemaVersion -ne $ExpectedSchemaVersion) {
            Add-ValidationError "$RelativePath must use schemaVersion $ExpectedSchemaVersion"
        }
        return $Json
    } catch {
        Add-ValidationError "$RelativePath is not valid JSON: $($_.Exception.Message)"
        return $null
    }
}

$Config = Test-JsonFile 'config\gamemode.json'
$GamemodePage = Test-JsonFile 'config\gamemode-page.json'
$AddonRevisions = Test-JsonFile 'config\addon-revisions.json'
$Equipment = Test-JsonFile 'config\equipment.json'
$Market = Test-JsonFile 'config\market.json'

foreach ($File in @(
    'README.md',
    'docs\GAMEMODE_PIPELINE.md',
    'docs\NETWORK_OPERATIONS.md',
    '..\templates\gamemode-change.md'
)) {
    if (-not (Test-Path -LiteralPath (Join-Path $Root $File) -PathType Leaf)) {
        Add-ValidationError "Missing required file: $File"
    }
}

if ($null -ne $Config) {
    if ($Config.gamemode.dxrpGamemodeId -ne '019e36c0-a67f-701c-90f2-460e0b0f1487') {
        Add-ValidationError 'config\gamemode.json has unexpected LifePunch gamemode id'
    }
}

if ($null -ne $GamemodePage) {
    if ($GamemodePage.gamemode.id -ne '019e36c0-a67f-701c-90f2-460e0b0f1487') {
        Add-ValidationError 'config\gamemode-page.json has unexpected LifePunch gamemode id'
    }

    foreach ($Tab in @('General', 'Addons (8)', 'Content', 'Jobs', 'Market', 'Minigames')) {
        if ($Tab -notin @($GamemodePage.detailView.tabs)) {
            Add-ValidationError "config\gamemode-page.json is missing tab '$Tab'"
        }
    }

    foreach ($Action in @('Save', 'Sync Servers', 'Import', 'Export', 'Reset to Vanilla', 'Delete Game Mode')) {
        if ($Action -notin @($GamemodePage.editMode.actions)) {
            Add-ValidationError "config\gamemode-page.json is missing edit action '$Action'"
        }
    }
}

if ($null -ne $AddonRevisions) {
    if ($AddonRevisions.gamemode.dxrpGamemodeId -ne '019e36c0-a67f-701c-90f2-460e0b0f1487') {
        Add-ValidationError 'config\addon-revisions.json has unexpected LifePunch gamemode id'
    }

    $Ak47Revision = @($AddonRevisions.revisionPins) | Where-Object { $_.package -eq 'lifepunch.ak47' } | Select-Object -First 1
    if ($null -eq $Ak47Revision) {
        Add-ValidationError 'config\addon-revisions.json must track lifepunch.ak47'
    } else {
        if ($Ak47Revision.targetEnvironment -ne 'lifepunchdevelopment') {
            Add-ValidationError 'config\addon-revisions.json AK47 target environment must be lifepunchdevelopment'
        }
        $AllowedAk47Statuses = @('staged-not-published', 'published-and-pinned')
        if ($Ak47Revision.publishStatus -notin $AllowedAk47Statuses) {
            Add-ValidationError 'config\addon-revisions.json AK47 status must be staged-not-published or published-and-pinned'
        }
        if ($Ak47Revision.publishStatus -eq 'published-and-pinned' -and $Ak47Revision.revisionNumber -lt 1) {
            Add-ValidationError 'config\addon-revisions.json AK47 published revision must include a revision number'
        }
    }
}

if ($null -ne $Equipment) {
    if ($Equipment.gamemode.dxrpGamemodeId -ne '019e36c0-a67f-701c-90f2-460e0b0f1487') {
        Add-ValidationError 'config\equipment.json has unexpected LifePunch gamemode id'
    }

    $Ak47Equipment = @($Equipment.equipmentRows) | Where-Object { $_.slug -eq 'ak47' } | Select-Object -First 1
    if ($null -eq $Ak47Equipment) {
        Add-ValidationError 'config\equipment.json must track AK47 equipment row'
    } else {
        if ($Ak47Equipment.package -ne 'lifepunch.ak47') {
            Add-ValidationError 'config\equipment.json AK47 package must be lifepunch.ak47'
        }
        if ($Ak47Equipment.content.type -ne 1) {
            Add-ValidationError 'config\equipment.json AK47 content type must be 1'
        }
        if ($Ak47Equipment.content.primaryReference -ne 'equipment/w_ak47/w_ak47.prefab') {
            Add-ValidationError 'config\equipment.json AK47 primary reference mismatch'
        }
        if ($Ak47Equipment.content.secondaryReference -ne 'equipment/vm_ak47/vm_ak47.prefab') {
            Add-ValidationError 'config\equipment.json AK47 secondary reference mismatch'
        }
        if ($Ak47Equipment.content.worldModelPath -ne 'models/lifepunch/ak47/w_ak47/w_ak47.vmdl') {
            Add-ValidationError 'config\equipment.json AK47 world model path mismatch'
        }
        if ($Ak47Equipment.content.grouping -ne 'Primary') {
            Add-ValidationError 'config\equipment.json AK47 grouping must be Primary'
        }
    }
}

if ($null -ne $Market) {
    if ($Market.gamemode.dxrpGamemodeId -ne '019e36c0-a67f-701c-90f2-460e0b0f1487') {
        Add-ValidationError 'config\market.json has unexpected LifePunch gamemode id'
    }

    $Ak47Market = @($Market.marketRows) | Where-Object { $_.slug -eq 'ak47' } | Select-Object -First 1
    if ($null -ne $Ak47Market) {
        if ($Ak47Market.environment -ne 'lifepunchdevelopment') {
            Add-ValidationError 'config\market.json AK47 market row must target lifepunchdevelopment'
        }
        if ($Ak47Market.revisionNumber -ne 26) {
            Add-ValidationError 'config\market.json AK47 market row must target revision 26'
        }
        if ($Ak47Market.type -ne 'Equipment') {
            Add-ValidationError 'config\market.json AK47 market row must be Equipment'
        }
    }
}

foreach ($Forbidden in @('Assets', 'Code')) {
    if (Test-Path -LiteralPath (Join-Path $Root $Forbidden)) {
        Add-ValidationError "Gamemode lane must not contain addon source folder: $Forbidden"
    }
}

if ($Errors.Count -gt 0) {
    Write-Host 'LifePunch gamemode workspace validation failed:' -ForegroundColor Red
    foreach ($ErrorMessage in $Errors) {
        Write-Host " - $ErrorMessage" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'LifePunch gamemode workspace validation passed.' -ForegroundColor Green
