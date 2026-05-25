$ErrorActionPreference = 'Stop'

$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$LifePunchRoot = Join-Path $Root 'lifepunch'
$Errors = New-Object System.Collections.Generic.List[string]

function Add-WorkspaceError {
    param([string]$Message)
    $Errors.Add($Message) | Out-Null
}

foreach ($Directory in @('lifepunch', 'scripts')) {
    if (-not (Test-Path -LiteralPath (Join-Path $Root $Directory) -PathType Container)) {
        Add-WorkspaceError "Missing required workspace directory: $Directory"
    }
}

foreach ($Forbidden in @('Assets', 'Code', 'config', 'gamemodes', 'lifepunchaddons', 'lifepunchgamemode', 'secure', 'docs')) {
    if (Test-Path -LiteralPath (Join-Path $Root $Forbidden)) {
        Add-WorkspaceError "Top-level '$Forbidden' is not allowed; use lifepunch\..."
    }
}

$LifePunchValidator = Join-Path $LifePunchRoot 'scripts\validate-lifepunch-workspace.ps1'

if (-not (Test-Path -LiteralPath $LifePunchValidator -PathType Leaf)) {
    Add-WorkspaceError 'Missing LifePunch validator: lifepunch\scripts\validate-lifepunch-workspace.ps1'
}

$LegacyFolders = Get-ChildItem -LiteralPath $Root -Directory -Recurse -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -in @('upload-assets', 'upload-code') }

foreach ($Folder in $LegacyFolders) {
    $Relative = Resolve-Path -LiteralPath $Folder.FullName -Relative
    Add-WorkspaceError "Legacy flat publish folder is not allowed: $Relative"
}

if ($Errors.Count -gt 0) {
    Write-Host 'LifePunch DXRP workspace validation failed:' -ForegroundColor Red
    foreach ($ErrorMessage in $Errors) {
        Write-Host " - $ErrorMessage" -ForegroundColor Red
    }
    exit 1
}

& $LifePunchValidator
if (-not $?) {
    exit 1
}

Write-Host 'LifePunch DXRP workspace validation passed.' -ForegroundColor Green
