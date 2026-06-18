<#
.SYNOPSIS
  Create / refresh lpaddondev — DXRP-disk addon-only editor (no rp gamemode mounts).

.DESCRIPTION
  Project: D:/Steam/.../dxrp/game/lpaddondev/lpaddondev.sbproj
  Mounts:   addons/lifepunch/_dev/** + lp* entity models-only (no source FBX scan)
  Assets:   junction -> dxrp/game/Assets/addons/lifepunch
  MCP:      junction Libraries -> dxrp/game/Libraries

  Does NOT touch rp.sbproj Resources.

.EXAMPLE
  powershell -File lifepunch\scripts\Initialize-LpAddonDevProject.ps1
#>
[CmdletBinding()]
param(
    [string] $ConfigPath = ''
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $ConfigPath) { $ConfigPath = Join-Path $Here 'dxrp-editor.local.json' }
if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw "Missing $ConfigPath — copy dxrp-editor.local.json.example first."
}

$cfg = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
$dxrpGame = Split-Path -Parent ([string]$cfg.projectPath)
if (-not (Test-Path -LiteralPath $dxrpGame)) { throw "DXRP game folder not found: $dxrpGame" }

$repoAddons = (Resolve-Path (Join-Path $Here '..\addons')).Path
$repoAssetsRoot = Join-Path $repoAddons 'Assets\addons\lifepunch'
$dxrpAssetsRoot = Join-Path $dxrpGame 'Assets\addons\lifepunch'
$devFolder = '_dev'

$stagingPath = Join-Path $repoAddons 'config\package-staging.json'
$staging = Get-Content -LiteralPath $stagingPath -Raw | ConvertFrom-Json
$stagingPackages = @($staging.packages.PSObject.Properties.Name)

$projRoot = Join-Path $dxrpGame 'lpaddondev'
$projAssets = Join-Path $projRoot 'Assets'
$projAddonsLink = Join-Path $projAssets 'addons\lifepunch'
$projLibrariesLink = Join-Path $projRoot 'Libraries'
$sbprojPath = Join-Path $projRoot 'lpaddondev.sbproj'
$slnxPath = Join-Path $projRoot 'lpaddondev.slnx'
$dxrpLibraries = Join-Path $dxrpGame 'Libraries'

function Ensure-Junction {
    param(
        [string] $Link,
        [string] $Target
    )
    if (-not (Test-Path -LiteralPath $Target)) {
        New-Item -ItemType Directory -Force -Path $Target | Out-Null
    }
    $parent = Split-Path -Parent $Link
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    if (Test-Path -LiteralPath $Link) {
        $item = Get-Item -LiteralPath $Link -Force
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { return }
        throw "Path exists and is not a junction: $Link"
    }
    cmd /c mklink /J "`"$Link`"" "`"$Target`"" | Out-Null
}

Write-Host 'lpaddondev — sync repo lp* staging -> DXRP Assets/addons/lifepunch' -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path $dxrpAssetsRoot | Out-Null
foreach ($pkg in $stagingPackages) {
    $src = Join-Path $repoAssetsRoot $pkg
    if (-not (Test-Path -LiteralPath $src)) { continue }
    $dst = Join-Path $dxrpAssetsRoot $pkg
    & robocopy $src $dst /MIR /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy failed: $pkg" }
    Write-Host "  synced $pkg" -ForegroundColor Green
}
$devSrc = Join-Path $repoAssetsRoot $devFolder
if (Test-Path -LiteralPath $devSrc) {
    & robocopy $devSrc (Join-Path $dxrpAssetsRoot $devFolder) /MIR /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
    if ($LASTEXITCODE -ge 8) { throw 'robocopy _dev failed' }
    Write-Host '  synced _dev' -ForegroundColor Green
}

Write-Host 'lpaddondev — project tree + junctions' -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path $projRoot | Out-Null
Ensure-Junction -Link $projAddonsLink -Target $dxrpAssetsRoot
Ensure-Junction -Link $projLibrariesLink -Target $dxrpLibraries

$resourceLines = @(
    "addons/lifepunch/$devFolder/**"
)
foreach ($pkg in $stagingPackages) {
    $entities = $staging.packages.$pkg.entities
    if (-not $entities) { continue }
    foreach ($ent in $entities.PSObject.Properties.Name) {
        $resourceLines += "addons/lifepunch/$pkg/$ent/assets/models/**"
    }
}
$resources = ($resourceLines | Select-Object -Unique) -join '\n'

$sbproj = @"
{
  "Title": "lpaddondev",
  "Type": "addon",
  "Org": "local",
  "Ident": "lpaddondev",
  "Schema": 1,
  "IncludeSourceFiles": false,
  "Resources": "$resources",
  "PackageReferences": [],
  "EditorReferences": null,
  "Mounts": null,
  "IsStandaloneOnly": false,
  "Metadata": {
    "MaxPlayers": 64,
    "MinPlayers": 1,
    "TickRate": 50,
    "GameNetworkType": "Multiplayer",
    "MapSelect": "Unrestricted",
    "MapList": [
      "facepunch.flatgrass"
    ],
    "RankType": "None",
    "PerMapRanking": false,
    "LeaderboardType": "None",
    "CsProjName": "",
    "StartupScene": "addons/lifepunch/_dev/scenes/lifepunch-modeldoc.scene"
  }
}
"@
[System.IO.File]::WriteAllText($sbprojPath, $sbproj)

$slnx = @'
<Solution>
  <Configurations>
    <Platform Name="Any CPU" />
  </Configurations>
  <Folder Name="/Addons/">
    <Project Path="D:/Steam/steamapps/common/sbox/addons/base/code/Base Library.csproj" />
  </Folder>
  <Folder Name="/Libraries/">
    <Project Path="Libraries/jtc.mcp-server/Editor/mcp-server.editor.csproj" />
    <Project Path="Libraries/notpointless.chomnr_mcp/Editor/chomnr_mcp.editor.csproj" />
    <Project Path="Libraries/sboxskinsgg.claudebridge/Code/claudebridge.csproj" />
    <Project Path="Libraries/sboxskinsgg.claudebridge/Editor/claudebridge.editor.csproj" />
    <Project Path="Libraries/sboxskinsgg.claudebridge/UnitTests/claudebridge.unittest.csproj" />
  </Folder>
  <Folder Name="/Tools/">
    <Project Path="D:/Steam/steamapps/common/sbox/addons/tools/Code/Base Editor Library.csproj" />
    <Project Path="D:/Steam/steamapps/common/sbox/editor/ActionGraph/Code/actiongraph.csproj" />
    <Project Path="D:/Steam/steamapps/common/sbox/editor/DooEditor/Code/dooeditor.csproj" />
    <Project Path="D:/Steam/steamapps/common/sbox/editor/Hammer/Code/hammer.csproj" />
    <Project Path="D:/Steam/steamapps/common/sbox/editor/MovieMaker/Code/moviemaker.csproj" />
    <Project Path="D:/Steam/steamapps/common/sbox/editor/ShaderGraph/Code/shadergraph.csproj" />
  </Folder>
</Solution>
'@
[System.IO.File]::WriteAllText($slnxPath, $slnx)

$cfg.projectPath = ($sbprojPath -replace '\\', '/')
$utf8 = New-Object System.Text.UTF8Encoding $false
[IO.File]::WriteAllText($ConfigPath, ($cfg | ConvertTo-Json -Depth 5), $utf8)

$sboxConfig = Join-Path (Split-Path -Parent $dxrpGame) '..\config\addons.json'
$sboxConfig = [IO.Path]::GetFullPath((Join-Path $dxrpGame '..\..\config\addons.json'))
if (Test-Path -LiteralPath $sboxConfig) {
    $entries = @(Get-Content -LiteralPath $sboxConfig -Raw | ConvertFrom-Json)
    $norm = ($sbprojPath -replace '\\', '/').ToLowerInvariant()
    $found = $false
    foreach ($e in $entries) {
        if (($e.Path -replace '\\', '/').ToLowerInvariant() -eq $norm) { $found = $true; break }
    }
    if (-not $found) {
        $entries += [pscustomobject]@{
            Path       = $sbprojPath.ToLowerInvariant()
            Active     = $false
            Pinned     = $false
            LastOpened = (Get-Date).ToString('o')
        }
        [IO.File]::WriteAllText($sboxConfig, ($entries | ConvertTo-Json -Depth 5))
    }
}

Write-Host ''
Write-Host 'OK lpaddondev ready' -ForegroundColor Green
Write-Host "  Project: $sbprojPath" -ForegroundColor DarkGray
Write-Host "  Assets:  junction -> $dxrpAssetsRoot" -ForegroundColor DarkGray
Write-Host "  Mounts:  _dev + lp* models-only (no gamemode, no ULX, no source FBX scan)" -ForegroundColor DarkGray
Write-Host "  Scene:   addons/lifepunch/_dev/scenes/lifepunch-modeldoc.scene" -ForegroundColor DarkGray
Write-Host "  dxrp-editor.local.json projectPath updated." -ForegroundColor DarkGray
