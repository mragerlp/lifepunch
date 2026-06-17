# Build JSON snapshot of Assets + Code addon trees for Cornerman handoff.
$ErrorActionPreference = 'Stop'
$Here = $PSScriptRoot
$RepoRoot = (Resolve-Path (Join-Path $Here '..\..')).Path
$roots = @(
    (Join-Path $RepoRoot 'lifepunch\addons\Assets\addons\lifepunch'),
    (Join-Path $RepoRoot 'lifepunch\addons\Code\Addons\lifepunch')
)
$rows = @()
foreach ($root in $roots) {
    Get-ChildItem $root -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $ident = $_.Name
        $files = @(Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue)
        $rows += [pscustomobject]@{
            Tree    = if ($root -like '*Assets*') { 'Assets' } else { 'Code' }
            Ident   = $ident
            Files   = $files.Count
            Vmdl    = @($files | Where-Object { $_.Extension -eq '.vmdl' }).Count
            Vmat    = @($files | Where-Object { $_.Extension -eq '.vmat' }).Count
            Fbx     = @($files | Where-Object { $_.Extension -eq '.fbx' }).Count
            Cs      = @($files | Where-Object { $_.Extension -eq '.cs' }).Count
            Prefab  = @($files | Where-Object { $_.Extension -eq '.prefab' }).Count
            Texture = @($files | Where-Object { $_.Extension -match '\.(png|jpg|jpeg|tga)$' }).Count
        }
    }
}
$outDir = Join-Path $RepoRoot 'lifepunch\docs\handoff\cornerman-inbox'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$out = Join-Path $outDir 'REPO_ADDONS_SNAPSHOT_2026-06-17.json'
$rows | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath $out -Encoding UTF8
Write-Host "Wrote $($rows.Count) rows -> $out"
