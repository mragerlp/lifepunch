# Import HASHD terminal 4K TGAs into lpbitcoin staging (lowercase paths — Source 2 dependency law).
param(
    [string]$SourceDir = (Join-Path $env:USERPROFILE 'Downloads\textures\textures4k'),
    [string]$HashdRoot = (Join-Path $PSScriptRoot '..\Assets\addons\lifepunch\lpbitcoin\hashdterminal')
)

$ErrorActionPreference = 'Stop'
$dest = Join-Path (Resolve-Path -LiteralPath $HashdRoot).Path 'assets\textures'

if (-not (Test-Path -LiteralPath $SourceDir)) {
    throw "Source not found: $SourceDir"
}

New-Item -ItemType Directory -Force -Path $dest | Out-Null

Get-ChildItem -LiteralPath $SourceDir -Filter '*.tga' -File | ForEach-Object {
    if ($_.Name -like '*Height*') { return }
    $lower = $_.Name.ToLowerInvariant()
    $target = Join-Path $dest $lower
    Copy-Item -LiteralPath $_.FullName -Destination $target -Force
    Write-Host "Imported: $lower" -ForegroundColor Green
}

Get-ChildItem -LiteralPath $dest -Filter '*.png' -File -ErrorAction SilentlyContinue | Remove-Item -Force
Get-ChildItem -LiteralPath $dest -Filter '*.generated.*' -File -ErrorAction SilentlyContinue | Remove-Item -Force

Write-Host "Import-HashdTerminalTextures: done -> $dest" -ForegroundColor Cyan
