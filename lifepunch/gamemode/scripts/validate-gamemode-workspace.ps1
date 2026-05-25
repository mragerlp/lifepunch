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
