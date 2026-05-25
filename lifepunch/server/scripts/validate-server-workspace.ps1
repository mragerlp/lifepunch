$ErrorActionPreference = 'Stop'

$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$Errors = New-Object System.Collections.Generic.List[string]

function Add-ValidationError {
    param([string]$Message)
    $Errors.Add($Message) | Out-Null
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

foreach ($Directory in @('config', 'change-log', 'scripts')) {
    if (-not (Test-Path -LiteralPath (Join-Path $Root $Directory) -PathType Container)) {
        Add-ValidationError "Missing required server directory: $Directory"
    }
}

foreach ($File in @('README.md', 'SERVER_AUDIT_PROCEDURE.md', 'change-log\README.md')) {
    if (-not (Test-Path -LiteralPath (Join-Path $Root $File) -PathType Leaf)) {
        Add-ValidationError "Missing required server file: $File"
    }
}

$Servers = Test-JsonFile 'config\servers.json'
$ServerPageFields = Test-JsonFile 'config\server-page-fields.json'

if ($null -ne $Servers) {
    $ServerEntries = @($Servers.servers)
    if ([int]$Servers.expectedHostedServers -ne 2) {
        Add-ValidationError 'config\servers.json must expect exactly 2 hosted servers'
    }
    if ($ServerEntries.Count -ne 2) {
        Add-ValidationError "config\servers.json must define exactly 2 servers, found $($ServerEntries.Count)"
    }

    foreach ($ServerId in @('lifepunchdevelopment', 'lifepunchmainserver')) {
        $Match = $ServerEntries | Where-Object { $_.id -eq $ServerId } | Select-Object -First 1
        if ($null -eq $Match) {
            Add-ValidationError "config\servers.json is missing '$ServerId' server entry"
        }
    }

    $Development = $ServerEntries | Where-Object { $_.id -eq 'lifepunchdevelopment' } | Select-Object -First 1
    if ($null -ne $Development -and $Development.displayName -ne 'Development') {
        Add-ValidationError "lifepunchdevelopment displayName must be 'Development'"
    }

    $MainServer = $ServerEntries | Where-Object { $_.id -eq 'lifepunchmainserver' } | Select-Object -First 1
    if ($null -ne $MainServer -and $MainServer.displayName -ne '70p') {
        Add-ValidationError "lifepunchmainserver displayName must be '70p'"
    }
}

if ($null -ne $ServerPageFields) {
    foreach ($ServerId in @('lifepunchmainserver', 'lifepunchdevelopment')) {
        if ($ServerId -notin @($ServerPageFields.servers)) {
            Add-ValidationError "config\server-page-fields.json is missing server '$ServerId'"
        }
    }

    $FieldGroups = @($ServerPageFields.fieldGroups)
    foreach ($RequiredGroup in @('identity', 'runtime', 'configuration', 'release-state', 'operations')) {
        $Match = $FieldGroups | Where-Object { $_.name -eq $RequiredGroup } | Select-Object -First 1
        if ($null -eq $Match) {
            Add-ValidationError "config\server-page-fields.json is missing field group '$RequiredGroup'"
        }
    }
}

foreach ($Forbidden in @('Assets', 'Code', 'gamemodes')) {
    if (Test-Path -LiteralPath (Join-Path $Root $Forbidden)) {
        Add-ValidationError "Server folder must not contain $Forbidden"
    }
}

if ($Errors.Count -gt 0) {
    Write-Host 'LifePunch server workspace validation failed:' -ForegroundColor Red
    foreach ($ErrorMessage in $Errors) {
        Write-Host " - $ErrorMessage" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'LifePunch server workspace validation passed.' -ForegroundColor Green
