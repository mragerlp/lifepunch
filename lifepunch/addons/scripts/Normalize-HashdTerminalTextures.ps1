# Normalize hashd-terminal asset paths for Source 2 (dependency paths are lowercase on disk).
# Run with s&box STOPPED, then: Clean-HashdTerminalAssetCache.ps1 + Sync-LifePunchAddonsToDxrp.ps1 -Addon bitcoinmining
param(
    [string]$HashdRoot = (Join-Path $PSScriptRoot '..\Assets\addons\lifepunch\lpbitcoin\hashdterminal')
)

$ErrorActionPreference = 'Stop'
$HashdRoot = (Resolve-Path -LiteralPath $HashdRoot).Path
$RepoTextures = Join-Path $HashdRoot 'assets\textures'
$RepoFbx = Join-Path $HashdRoot 'assets\source\fbx'

function Set-LowercaseFileName {
    param(
        [System.IO.FileInfo]$File,
        [string]$Extension
    )
    $lower = $File.Name.ToLowerInvariant()
    if ($File.Name.Equals($lower, [StringComparison]::Ordinal)) { return $false }
    $temp = Join-Path $File.DirectoryName ("__casetmp_" + [guid]::NewGuid().ToString('N') + $Extension)
    Move-Item -LiteralPath $File.FullName -Destination $temp
    Move-Item -LiteralPath $temp -Destination (Join-Path $File.DirectoryName $lower)
    Write-Host "Renamed: $($File.Name) -> $lower" -ForegroundColor Green
    return $true
}

if (Test-Path -LiteralPath $RepoTextures) {
    Get-ChildItem -LiteralPath $RepoTextures -Filter '*.tga' -File -ErrorAction SilentlyContinue |
        ForEach-Object {
            Remove-Item -LiteralPath $_.FullName -Force
            Write-Host "Removed TGA: $($_.Name)" -ForegroundColor Yellow
        }

    Get-ChildItem -LiteralPath $HashdRoot -Recurse -Filter '*.generated.*' -File -ErrorAction SilentlyContinue |
        ForEach-Object {
            Remove-Item -LiteralPath $_.FullName -Force
            Write-Host "Removed cache: $($_.FullName.Substring($HashdRoot.Length + 1))" -ForegroundColor Yellow
        }

    $renamed = 0
    Get-ChildItem -LiteralPath $RepoTextures -Filter '*.png' -File |
        ForEach-Object { if (Set-LowercaseFileName -File $_ -Extension '.png') { $renamed++ } }
    Write-Host "Textures: $renamed PNG rename(s)" -ForegroundColor Cyan
}

if (Test-Path -LiteralPath $RepoFbx) {
    $fbxRenamed = 0
    Get-ChildItem -LiteralPath $RepoFbx -Filter '*.fbx' -File |
        ForEach-Object { if (Set-LowercaseFileName -File $_ -Extension '.fbx') { $fbxRenamed++ } }
    Write-Host "FBX: $fbxRenamed rename(s)" -ForegroundColor Cyan
}

Write-Host "Normalize-HashdTerminalTextures: done ($HashdRoot)" -ForegroundColor Green
Write-Host 'Next: Clean-HashdTerminalAssetCache.ps1, then Sync-LifePunchAddonsToDxrp.ps1 -Addon bitcoinmining (editor stopped).' -ForegroundColor DarkGray
