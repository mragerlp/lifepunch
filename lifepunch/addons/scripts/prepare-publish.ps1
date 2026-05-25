param(
    [Parameter(Mandatory = $true)]
    [string]$Addon,

    [switch]$OpenFolder
)

$ErrorActionPreference = 'Stop'

$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$ManifestPath = Join-Path $Root 'config\addons.json'
$UploadRoot = Join-Path $Root '.dxrp-publish\upload'

function Copy-PublishItems {
    param(
        [string]$Source,
        [string]$Destination
    )

    if (-not (Test-Path -LiteralPath $Source -PathType Container)) {
        return
    }

    Get-ChildItem -LiteralPath $Source -Force |
        Where-Object { $_.Name -ne '.gitkeep' } |
        ForEach-Object {
            Copy-Item -LiteralPath $_.FullName -Destination $Destination -Recurse -Force
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
$AssetsStage = Join-Path $UploadRoot "Assets\addons\$Org\$($Package.ident)"
$CodeStage = Join-Path $UploadRoot "Code\Addons\$Org\$($Package.ident)"

if ($Package.hasAssets) {
    $AssetsSource = Join-Path $Root "Assets\addons\$Org\$($Package.ident)"
    New-Item -ItemType Directory -Force -Path $AssetsStage | Out-Null
    Copy-PublishItems -Source $AssetsSource -Destination $AssetsStage
}

if ($Package.hasCode) {
    $CodeSource = Join-Path $Root "Code\Addons\$Org\$($Package.ident)"
    New-Item -ItemType Directory -Force -Path $CodeStage | Out-Null
    Copy-PublishItems -Source $CodeSource -Destination $CodeStage
}

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

Do not move files into upload-assets or upload-code. Keep the Assets and Code roots intact.
"@

$StagingRoot = Join-Path $Root '.dxrp-publish'
New-Item -ItemType Directory -Force -Path $StagingRoot | Out-Null
Set-Content -LiteralPath (Join-Path $StagingRoot 'README.txt') -Value $Readme -Encoding UTF8

Write-Host "Prepared DXRP publish staging for $Org.$($Package.ident)" -ForegroundColor Green
Write-Host "Upload root: $UploadRoot"

if ($OpenFolder) {
    Invoke-Item $UploadRoot
}
