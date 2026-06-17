# Runs ON Cornerman (Green). Deterministic sweep - no Cursor, no LM required.
# Input:  C:\lifepunch\cornerman\inbox\DESKTOP_ADDONS_INVENTORY_2026-06-17.json
#         C:\lifepunch\cornerman\inbox\REPO_ADDONS_SNAPSHOT_2026-06-17.json
#         C:\lifepunch\cornerman\inbox\package-staging.json
# Output: C:\Projects\cornerman-rag\outbox\*_2026-06-17.*
#         C:\lifepunch\cornerman\outbox\SWEEP_STATUS.json
param(
    [string] $DateStamp = '2026-06-17'
)

$ErrorActionPreference = 'Stop'
$Inbox  = 'C:\lifepunch\cornerman\inbox'
$OutRag = 'C:\Projects\cornerman-rag\outbox'
$OutLp  = 'C:\lifepunch\cornerman\outbox'
$Repo   = 'C:\Projects\lifepunch'
$Assets = Join-Path $Repo 'lifepunch\addons\Assets\addons\lifepunch'

New-Item -ItemType Directory -Force -Path $OutRag, $OutLp | Out-Null

function Write-Out([string]$Name, [string]$Text) {
    $p1 = Join-Path $OutRag $Name
    $p2 = Join-Path $OutLp $Name
    Set-Content -LiteralPath $p1 -Value $Text -Encoding UTF8
    Set-Content -LiteralPath $p2 -Value $Text -Encoding UTF8
    Write-Host "Wrote $Name"
}

$desktopJson = Join-Path $Inbox "DESKTOP_ADDONS_INVENTORY_$DateStamp.json"
$repoJson    = Join-Path $Inbox "REPO_ADDONS_SNAPSHOT_$DateStamp.json"
$stagingJson = Join-Path $Inbox 'package-staging.json'

foreach ($f in @($desktopJson, $repoJson, $stagingJson)) {
    if (-not (Test-Path -LiteralPath $f)) { throw "Missing inbox input: $f" }
}

$desktop = Get-Content -LiteralPath $desktopJson -Raw | ConvertFrom-Json
$repoSnap = Get-Content -LiteralPath $repoJson -Raw | ConvertFrom-Json
$staging = Get-Content -LiteralPath $stagingJson -Raw | ConvertFrom-Json

function Get-FbxMaterialSlots([string]$FbxPath) {
    if (-not (Test-Path -LiteralPath $FbxPath)) { return @() }
    $pyFile = Join-Path $env:TEMP 'lp_fbx_slots.py'
    @'
import re, sys, json
p = sys.argv[1]
data = open(p, "rb").read()
hits = set()
for s in re.findall(rb"[\x20-\x7e]{3,}", data):
    t = s.decode("ascii", "ignore")
    if t.startswith(("Animation", "Layer", "Mapping", "Reference", "Fbx", "Version")):
        continue
    if any(k in t for k in ("MI", "mat", "Material", "tex", "Tex", "ORM", "Base", "Bullet", "Locker", "Safe", "GPU", "Terminal", "ATM", "AR_15", "Krinkov")):
        if len(t) < 64 and "/" not in t and "\\" not in t:
            hits.add(t)
print(json.dumps(sorted(hits)[:50]))
'@ | Set-Content -LiteralPath $pyFile -Encoding UTF8
    try {
        $raw = & python $pyFile $FbxPath 2>$null
        if ($raw) { return @($raw | ConvertFrom-Json) }
    }
    catch { }
    return @()
}

function Get-EntityRepoStats([string]$Pkg, [string]$Ent) {
    $base = Join-Path $Assets (Join-Path $Pkg $Ent)
    if (-not (Test-Path -LiteralPath $base)) {
        return @{ Exists = $false; Fbx = 0; Tex = 0; Vmdl = 0; Vmat = 0 }
    }
    $files = @(Get-ChildItem $base -Recurse -File -ErrorAction SilentlyContinue)
    return @{
        Exists = $true
        Fbx    = @($files | Where-Object { $_.Extension -eq '.fbx' }).Count
        Tex    = @($files | Where-Object { $_.Extension -match '\.(png|jpg|jpeg|tga)$' }).Count
        Vmdl   = @($files | Where-Object { $_.Extension -eq '.vmdl' }).Count
        Vmat   = @($files | Where-Object { $_.Extension -eq '.vmat' }).Count
    }
}

$priorityMap = @{
    'lpbitcoin'     = 'P0'
    'lpweapons'     = 'P0'
    'lphacker'      = 'P1'
    'lpbanker'      = 'P1'
    'lpblackmarket' = 'P2'
    'lpgovernment'  = 'P2'
    'lppolice'      = 'P2'
    'lpflashdrive'  = 'P2'
    'lpchemist'     = 'P2'
    'lpdrugdrops'   = 'P2'
}

$slotResults = @{}
$gapRows = @()
$dossierSections = @()
$bucketA = @(); $bucketB = @(); $bucketC = @()

foreach ($ent in $desktop.entities) {
    $pkg = $ent.Package
    $slot = $ent.Entity
    $path = $ent.Path
    $prio = if ($priorityMap.ContainsKey($pkg)) { $priorityMap[$pkg] } else { 'P2' }

    $repo = Get-EntityRepoStats -Pkg $pkg -Ent $slot
    $gap = if (-not $repo.Exists) { 'REPO_MISSING' }
    elseif ($ent.FbxCount -gt $repo.Fbx) { 'DESKTOP_AHEAD' }
    elseif ($ent.FbxCount -lt $repo.Fbx) { 'REPO_AHEAD' }
    else { 'ALIGNED' }

    $gapRows += [pscustomobject]@{
        Path = $path; Priority = $prio; DesktopStatus = $ent.Status
        DesktopFbx = $ent.FbxCount; DesktopTex = $ent.TextureCount
        RepoExists = $repo.Exists; RepoFbx = $repo.Fbx; RepoTex = $repo.Tex
        RepoVmdl = $repo.Vmdl; Gap = $gap
    }

    $fbxSlots = @()
    $fbxPath = $null
    if ($repo.Exists) {
        $fbxFile = Get-ChildItem (Join-Path $Assets "$pkg\$slot\assets\source\fbx") -Filter *.fbx -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($fbxFile) {
            $fbxPath = $fbxFile.FullName
            $fbxSlots = @(Get-FbxMaterialSlots -FbxPath $fbxPath)
        }
    }
    $slotResults[$path] = @{
        fbxFile = if ($fbxPath) { Split-Path $fbxPath -Leaf } else { $ent.FbxNames }
        slots   = $fbxSlots
    }

    $redAction = switch ($ent.Status) {
        'MODELDOC_PENDING' { 'Create vmdl + vmats; ORM @channels=G/B; compile _c' }
        'FBX_ONLY'         { 'Owner: add textures to Desktop, sync, then ModelDoc' }
        'AUDIT_OR_EMPTY'   { 'Owner: complete Fab drop or defer' }
        default            { 'Review' }
    }

    if ($ent.Status -eq 'MODELDOC_PENDING') { $bucketA += $path }
    elseif ($ent.Status -eq 'FBX_ONLY')    { $bucketB += $path }
    else                                    { $bucketC += $path }

    $dossierSections += @(
        "### $path ($prio)",
        "| Field | Value |",
        "|-------|-------|",
        "| Desktop status | $($ent.Status) |",
        "| FBX | $($ent.FbxNames) ($($ent.FbxCount)) |",
        "| Textures | $($ent.TextureCount) |",
        "| Repo | exists=$($repo.Exists) fbx=$($repo.Fbx) tex=$($repo.Tex) vmdl=$($repo.Vmdl) |",
        "| Gap | $gap |",
        "| Material slots (FBX strings) | $(if ($fbxSlots.Count) { ($fbxSlots -join ', ') } else { 'none extracted' }) |",
        "| Red first action | $redAction |",
        ''
    )
}

# Group dossiers by package
$pkgGroups = $desktop.entities | Group-Object Package
$pkgMd = @("# Package dossiers - $DateStamp", '', "Generated on Green by Run-ModelDocGreenfieldSweep.ps1", '')
foreach ($g in ($pkgGroups | Sort-Object Name)) {
    $pkgMd += "## $($g.Name) ($($priorityMap[$g.Name]))"
    $pkgMd += ''
    foreach ($ent in $g.Group) {
        $path = $ent.Path
        $section = $dossierSections | Where-Object { $_ -match [regex]::Escape("### $path") }
        # re-emit from stored data - simpler: inline again
        $repo = Get-EntityRepoStats -Pkg $ent.Package -Ent $ent.Entity
        $slots = $slotResults[$path].slots
        $pkgMd += "### $path"
        $pkgMd += "- Status: **$($ent.Status)** · FBX: $($ent.FbxNames) · Tex: $($ent.TextureCount)"
        $pkgMd += "- Repo: exists=$($repo.Exists) vmdl=$($repo.Vmdl) vmat=$($repo.Vmat)"
        $pkgMd += "- Slots: $(if ($slots.Count) { ($slots -join ', ') } else { 'n/a' })"
        $pkgMd += ''
    }
}

$top10 = ($bucketA | Select-Object -First 10)
$rollupMd = @(
    "# ModelDoc readiness rollup - $DateStamp",
    '',
    "**Source:** Desktop inventory (inbox) + repo scan on Green clone",
    '',
    "## Counts",
    "- **A (ModelDoc today):** $($bucketA.Count)",
    "- **B (FBX only):** $($bucketB.Count)",
    "- **C (audit/empty):** $($bucketC.Count)",
    '',
    "## Top 10 for Red first session",
    ($top10 | ForEach-Object { "1. $_" }),
    '',
    "## Bucket A - all",
    ($bucketA | ForEach-Object { "- $_" }),
    '',
    "## Bucket B",
    ($bucketB | ForEach-Object { "- $_" }),
    '',
    "## Bucket C",
    ($bucketC | ForEach-Object { "- $_" })
) -join "`n"

$gapMd = @(
    "# Repo vs Desktop staging gap - $DateStamp",
    '',
    '| Path | Prio | Desktop | Repo fbx/tex/vmdl | Gap |',
    '|------|------|---------|-------------------|-----|'
)
foreach ($r in ($gapRows | Sort-Object Priority, Path)) {
    $gapMd += "| ``$($r.Path)`` | $($r.Priority) | $($r.DesktopStatus) | $($r.RepoFbx)/$($r.RepoTex)/$($r.RepoVmdl) | $($r.Gap) |"
}
$gapMd = $gapMd -join "`n"

$publishMd = @(
    "# DXRP publish readiness map - $DateStamp",
    '',
    'Future ship gate per package (document only).',
    '',
    '| Package | repoIdent | Entities ready (A bucket) | Blockers |',
    '|---------|-----------|---------------------------|----------|'
)
foreach ($pkgName in ($staging.packages.PSObject.Properties.Name | Sort-Object)) {
    $pkg = $staging.packages.$pkgName
    $ready = @($bucketA | Where-Object { $_ -like "lifepunch/$pkgName/*" }).Count
    $publishMd += "| $pkgName | $($pkg.repoIdent) | $ready | No _c compile · no prepare-publish yet |"
}
$publishMd += ''
$publishMd += '## Per-package checklist (all)'
$publishMd += '- [ ] All entity vmdl/vmat compile to _c'
$publishMd += '- [ ] `prepare-publish.ps1 -Addon <repoIdent>`'
$publishMd += '- [ ] Upload Assets + Code from `.dxrp-publish/upload`'
$publishMd += '- [ ] Portal content row + gamemode pin'
$publishMd = $publishMd -join "`n"

$slotsJson = ($slotResults | ConvertTo-Json -Depth 5)

Write-Out "PACKAGE_DOSSIERS_$DateStamp.md" ($pkgMd -join "`n")
Write-Out "MODELDOC_READINESS_ROLLUP_FULL_$DateStamp.md" $rollupMd
Write-Out "REPO_STAGING_GAP_FULL_$DateStamp.md" $gapMd
Write-Out "FBX_MATERIAL_SLOTS_$DateStamp.json" $slotsJson
Write-Out "DXRP_PUBLISH_READINESS_$DateStamp.md" $publishMd
Write-Out "SYNC_WORKFLOW_LAW_$DateStamp.md" @"
# Sync workflow law - $DateStamp

1. Never run ``Sync-LifepunchDesktopToStaging.ps1`` until Desktop entity has real assets OR vmdl work is committed.
2. Morning order on VENGEANCE: Desktop sync → ModelDoc in repo → ``Set-DxrpLifepunchModelDocLane.ps1`` → bridge recompile.
3. MIR hazard: placeholder Desktop dirs can wipe uncommitted repo vmdl files.
"@

$status = @{
    ok           = $true
    completedUtc = (Get-Date).ToUniversalTime().ToString('o')
    host         = $env:COMPUTERNAME
    entityCount  = $desktop.entities.Count
    bucketA      = $bucketA.Count
    bucketB      = $bucketB.Count
    bucketC      = $bucketC.Count
    top10        = $top10
} | ConvertTo-Json -Depth 4

Set-Content -LiteralPath (Join-Path $OutLp "SWEEP_STATUS.json") -Value $status -Encoding UTF8
Set-Content -LiteralPath (Join-Path $OutRag "SWEEP_STATUS.json") -Value $status -Encoding UTF8
Write-Host "SWEEP OK"
