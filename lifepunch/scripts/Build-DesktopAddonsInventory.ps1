# Build Desktop UPLOAD READY ADDONS inventory for Cornerman handoff.
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
. (Join-Path (Split-Path $Here -Parent) 'addons\scripts\LifePunch-AddonDropPaths.ps1')

$desktopAddonsRoot = Join-Path (Get-LifePunchUploadReadyRoot) 'addons'
$lifepunchRoot = Join-Path $desktopAddonsRoot 'lifepunch'

if (-not (Test-Path -LiteralPath $desktopAddonsRoot)) {
    throw "Missing Desktop addons root: $desktopAddonsRoot"
}

function Get-EntityRow {
    param([string]$Pkg, [string]$Ent, [string]$Base)
    $fbxPath = Join-Path $Base 'assets\source\fbx'
    $texPath = Join-Path $Base 'assets\textures'
    $mdlPath = Join-Path $Base 'assets\models'
    [pscustomobject]@{
        Package       = $Pkg
        Entity        = $Ent
        Path          = "lifepunch/$Pkg/$Ent"
        FbxCount      = @(Get-ChildItem $fbxPath -Filter *.fbx -ErrorAction SilentlyContinue).Count
        FbxNames      = (@(Get-ChildItem $fbxPath -Filter *.fbx -ErrorAction SilentlyContinue | ForEach-Object Name) -join '; ')
        TextureCount  = @(Get-ChildItem $texPath -File -ErrorAction SilentlyContinue).Count
        JpegCount     = @(Get-ChildItem $texPath -File -Include *.jpeg,*.jpg -ErrorAction SilentlyContinue).Count
        VmdlCount     = @(Get-ChildItem $mdlPath -Filter *.vmdl -ErrorAction SilentlyContinue).Count
        VmatCount     = @(Get-ChildItem (Join-Path $mdlPath 'materials') -Filter *.vmat -ErrorAction SilentlyContinue).Count
        HasModelBuild = [bool](Test-Path (Join-Path $mdlPath 'MODEL_BUILD.md'))
        HasAudit      = [bool](Test-Path (Join-Path $Base 'audit\manifest.json'))
        HasAssets     = [bool](Test-Path (Join-Path $Base 'assets'))
        Status        = if (-not (Test-Path (Join-Path $Base 'assets'))) { 'PLACEHOLDER' }
                        elseif (@(Get-ChildItem $fbxPath -Filter *.fbx -ErrorAction SilentlyContinue).Count -gt 0 -and
                            @(Get-ChildItem $texPath -File -ErrorAction SilentlyContinue).Count -gt 0 -and
                            @(Get-ChildItem $mdlPath -Filter *.vmdl -ErrorAction SilentlyContinue).Count -gt 0) { 'MODELDOC_DONE' }
                        elseif (@(Get-ChildItem $fbxPath -Filter *.fbx -ErrorAction SilentlyContinue).Count -gt 0 -and
                            @(Get-ChildItem $texPath -File -ErrorAction SilentlyContinue).Count -gt 0) { 'MODELDOC_PENDING' }
                        elseif (@(Get-ChildItem $fbxPath -Filter *.fbx -ErrorAction SilentlyContinue).Count -gt 0) { 'FBX_ONLY' }
                        else { 'AUDIT_OR_EMPTY' }
    }
}

$rows = @()
if (Test-Path -LiteralPath $lifepunchRoot) {
    Get-ChildItem $lifepunchRoot -Directory | ForEach-Object {
        $pkg = $_.Name
        Get-ChildItem $_.FullName -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            $rows += Get-EntityRow -Pkg $pkg -Ent $_.Name -Base $_.FullName
        }
    }
}

# Other top-level folders under addons\ (non-lifepunch)
Get-ChildItem $desktopAddonsRoot -Directory | Where-Object { $_.Name -ne 'lifepunch' } | ForEach-Object {
    $rows += [pscustomobject]@{
        Package       = $_.Name
        Entity        = '(root)'
        Path          = "$($_.Name)/(root)"
        FbxCount      = @(Get-ChildItem $_.FullName -Recurse -Filter *.fbx -ErrorAction SilentlyContinue).Count
        FbxNames      = ''
        TextureCount  = @(Get-ChildItem $_.FullName -Recurse -File -Include *.png,*.jpg,*.jpeg,*.tga -ErrorAction SilentlyContinue).Count
        JpegCount     = 0
        VmdlCount     = @(Get-ChildItem $_.FullName -Recurse -Filter *.vmdl -ErrorAction SilentlyContinue).Count
        VmatCount     = @(Get-ChildItem $_.FullName -Recurse -Filter *.vmat -ErrorAction SilentlyContinue).Count
        HasModelBuild = $false
        HasAudit      = $false
        HasAssets     = $true
        Status        = 'OTHER_ROOT'
    }
}

$repoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
$outDir = Join-Path $repoRoot 'lifepunch\docs\handoff\cornerman-inbox'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$meta = [pscustomobject]@{
    generatedUtc  = (Get-Date).ToUniversalTime().ToString('o')
    desktopRoot   = $desktopAddonsRoot
    lifepunchRoot = $lifepunchRoot
    entityCount   = $rows.Count
    byStatus      = $rows | Group-Object Status | ForEach-Object { @{ $_.Name = $_.Count } }
    entities      = $rows
}

$jsonOut = Join-Path $outDir 'DESKTOP_ADDONS_INVENTORY_2026-06-17.json'
$meta | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $jsonOut -Encoding UTF8

$mdOut = Join-Path $outDir 'DESKTOP_ADDONS_INVENTORY_2026-06-17.md'
$lines = @(
    '# Desktop UPLOAD READY ADDONS inventory',
    '',
    "**Root:** ``$desktopAddonsRoot``",
    "**LifePunch:** ``$lifepunchRoot``",
    "**Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm') UTC-ish local",
    '',
    '| Path | FBX | Tex | VMDL | VMAT | Status |',
    '|------|-----|-----|------|------|--------|'
)
foreach ($r in ($rows | Sort-Object Package, Entity)) {
    $lines += "| ``$($r.Path)`` | $($r.FbxCount) | $($r.TextureCount) | $($r.VmdlCount) | $($r.VmatCount) | $($r.Status) |"
}
$lines += ''
$lines += '## Status key'
$lines += '- **MODELDOC_DONE** — fbx + textures + vmdl present'
$lines += '- **MODELDOC_PENDING** — fbx + textures; needs vmdl/vmat'
$lines += '- **FBX_ONLY** — mesh source only'
$lines += '- **PLACEHOLDER** — no assets folder (audit skeleton only)'
$lines += '- **AUDIT_OR_EMPTY** — assets folder exists but thin'
$lines | Set-Content -LiteralPath $mdOut -Encoding UTF8

Write-Host "Wrote $jsonOut"
Write-Host "Wrote $mdOut"
Write-Host "Entities: $($rows.Count)"
$rows | Group-Object Status | Format-Table Name, Count -AutoSize
