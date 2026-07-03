<#
.SYNOPSIS
  Scan _modeldoc packages and emit classification audit artifacts.

.DESCRIPTION
  Writes per-package:
    audit/manifest.json (aggregate)
    issues.md
    duplicate_report.md
  Writes repo summary:
    addons/docs/ASSET_CLASSIFICATION_REPORT_<date>.md

.EXAMPLE
  powershell -File lifepunchaddons\scripts\Invoke-LifepunchAssetClassificationAudit.ps1
#>
[CmdletBinding()]
param(
    [string] $ModelDocRoot = '',
    [string] $ReportDate = (Get-Date -Format 'yyyy-MM')
)

$ErrorActionPreference = 'Stop'
$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$AddonsRoot = Split-Path $Here -Parent
$configPath = Join-Path $AddonsRoot 'config\package-staging.json'
$config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
if (-not $ModelDocRoot) {
    $ModelDocRoot = Join-Path $AddonsRoot 'Assets\addons\lifepunch'
}

$PackageMeta = [ordered]@{
    lpbitcoin       = @{ priority = 'P0'; slug = 'lifepunchbitcoin'; role = 'Bitcoin mining chain (highest priority)' }
    lphacker        = @{ priority = 'P1'; slug = 'lifepunchhacker'; role = 'Cybercrime progression (basic + advanced tiers)' }
    lppolice        = @{ priority = 'P1'; slug = 'TBD'; role = 'Law enforcement hub + terminal (separate from lpgovernment)' }
    lpgovernment    = @{ priority = 'P1'; slug = 'TBD'; role = 'Government hub + terminal' }
    lpblackmarket   = @{ priority = 'P2'; slug = 'TBD'; role = 'Underground BTC economy' }
    lpbanker        = @{ priority = 'P2'; slug = 'lifepunchbanker'; role = 'Legitimate financial economy' }
    lpflashdrive    = @{ priority = 'P3'; slug = 'defer'; role = 'USB storage + electronics table (gameplay later)' }
    lpweapons       = @{ priority = 'parallel'; slug = 'lifepunchak47+'; role = 'Weapon pipeline (parallel to prop pass)' }
}

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
    }
}

function Get-SlotInventory([string]$SlotPath) {
    $slotName = Split-Path $SlotPath -Leaf
    $fbxDir = Join-Path $SlotPath 'assets\source\fbx'
    $objDir = Join-Path $SlotPath 'assets\source\obj'
    $blendDir = Join-Path $SlotPath 'assets\source\blend'
    $texDir = Join-Path $SlotPath 'assets\textures'
    $manifestPath = Join-Path $SlotPath 'audit\manifest.json'

    $fbx = @(Get-ChildItem $fbxDir -File -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.DirectoryName -notmatch '\\_(alt|parts|reference_anim)\\' -and $_.Name -notmatch '^_' })
    $fbxRoot = @(Get-ChildItem $fbxDir -File -ErrorAction SilentlyContinue)
    $obj = @(Get-ChildItem $objDir -File -ErrorAction SilentlyContinue)
    $blend = @(Get-ChildItem $blendDir -File -ErrorAction SilentlyContinue)
    $tex = @(Get-ChildItem $texDir -File -ErrorAction SilentlyContinue)
    $allFiles = @(Get-ChildItem $SlotPath -Recurse -File -ErrorAction SilentlyContinue)
    $sizeBytes = ($allFiles | Measure-Object -Property Length -Sum).Sum

    $manifest = $null
    if (Test-Path -LiteralPath $manifestPath) {
        try { $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json } catch { }
    }

    $primary = [string]$manifest.primary_mesh
    $primaryExt = if ($primary) { [System.IO.Path]::GetExtension($primary).ToLowerInvariant() } else { '' }
    $hasFbxPrimary = $primary -match '\.fbx$'
    $hasObjPrimary = $primary -match '\.obj$'
    $hasBlendPrimary = $primary -match '\.blend$'
    $solidColorOk = ($slotName -eq 'bitcoinhub') -and ($tex.Count -eq 0)

    $issues = @()
    if ($manifest -and $manifest.issues) { $issues += @($manifest.issues) }
    if (-not $hasFbxPrimary -and -not $solidColorOk) {
        if ($hasBlendPrimary) { $issues += 'BLOCKER: primary_mesh is blend-only — export FBX for ModelDoc or document blend import path' }
        elseif ($hasObjPrimary) { $issues += 'WARN: primary_mesh is OBJ — OK for ModelDoc OBJ import; prefer FBX if Fab provides one' }
        elseif (-not $primary) { $issues += 'WARN: no primary_mesh in slot manifest' }
    }
    if ($tex.Count -eq 0 -and -not $solidColorOk -and $slotName -notmatch 'hub$') {
        $issues += 'WARN: zero files in assets/textures (hub slots may use shared trim sheets - verify)'
    }

    [PSCustomObject]@{
        Slot           = $slotName
        Role           = [string]$manifest.role
        PrimaryMesh    = $primary
        FBXRootCount   = $fbxRoot.Count
        FBXTotalCount  = $fbx.Count
        OBJCount       = $obj.Count
        BlendCount     = $blend.Count
        TextureCount   = $tex.Count
        SizeMB         = [math]::Round(($sizeBytes / 1MB), 2)
        Issues         = $issues | Select-Object -Unique
        ManifestNotes  = @($manifest.notes)
        HasFbxPrimary  = $hasFbxPrimary
        SolidColorOk   = $solidColorOk
    }
}

function Get-HealthScore($slots) {
    $score = 100
    foreach ($s in $slots) {
        if (-not $s.HasFbxPrimary -and -not $s.SolidColorOk) {
            if ($s.PrimaryMesh -match '\.blend$') { $score -= 20 }
            elseif ($s.PrimaryMesh -match '\.obj$') { $score -= 12 }
            else { $score -= 15 }
        }
        foreach ($i in $s.Issues) {
            if ($i -match '^BLOCKER') { $score -= 8 }
            elseif ($i -match '^WARN') { $score -= 3 }
        }
    }
    if ($score -lt 0) { $score = 0 }
    if ($score -gt 100) { $score = 100 }
    return $score
}

if (-not (Test-Path -LiteralPath $ModelDocRoot)) { throw "Missing ModelDoc root: $ModelDocRoot" }

Write-Host "Asset classification audit -> lp* staging under $ModelDocRoot" -ForegroundColor Cyan

$allSlots = @()
$filenameIndex = @{}

foreach ($pkg in $PackageMeta.Keys) {
    $pkgPath = Join-Path $ModelDocRoot $pkg
    if (-not (Test-Path -LiteralPath $pkgPath)) { continue }
    Get-ChildItem $pkgPath -Directory | Where-Object { $_.Name -notin @('audit') } | ForEach-Object {
        $inv = Get-SlotInventory $_.FullName
        $inv | Add-Member -NotePropertyName Package -NotePropertyValue $pkg -Force
        $allSlots += $inv

        if ($inv.PrimaryMesh) {
            $leaf = Split-Path $inv.PrimaryMesh -Leaf
            if (-not $filenameIndex.ContainsKey($leaf)) { $filenameIndex[$leaf] = @() }
            $filenameIndex[$leaf] += [PSCustomObject]@{ Package = $pkg; Slot = $inv.Slot; Path = "$pkg/$($inv.Slot)" }
        }
    }
}

$totalSizeMB = [math]::Round((($allSlots | Measure-Object -Property SizeMB -Sum).Sum), 2)
$duplicateRows = @()
foreach ($kv in $filenameIndex.GetEnumerator()) {
    if ($kv.Value.Count -gt 1) {
        $duplicateRows += [PSCustomObject]@{
            Filename = $kv.Key
            Occurrences = $kv.Value.Count
            Locations = ($kv.Value | ForEach-Object { $_.Path }) -join '; '
            SamePackageOnly = (($kv.Value | Select-Object -ExpandProperty Package -Unique).Count -eq 1)
        }
    }
}

$optimization = @()
$heavy = $allSlots | Where-Object { $_.SizeMB -gt 200 } | Sort-Object SizeMB -Descending
foreach ($h in $heavy) {
    $optimization += "- **$($h.Package)/$($h.Slot)** ($($h.SizeMB) MB): large extracted/ + 4K dupes on Desktop; game/textures is subset only - do not delete owner drop"
}
$optimization += '- **lpflashdrive/usbflashdrive**: preserve all color variant textures - optimize at ship (_c), not by deleting variants'
$optimization += '- **lpbitcoin/gpurack + advancedgpurack**: shared Crypto Farm textures by design - dedupe in ModelDoc vmats only'

$estSavingsMB = [math]::Round(($heavy | Where-Object { $_.SizeMB -gt 400 } | ForEach-Object { $_.SizeMB * 0.85 } | Measure-Object -Sum).Sum, 0)
if (-not $estSavingsMB) { $estSavingsMB = 0 }

foreach ($pkg in ($PackageMeta.Keys)) {
    $pkgPath = Join-Path $ModelDocRoot $pkg
    if (-not (Test-Path -LiteralPath $pkgPath)) { continue }

    $slots = @($allSlots | Where-Object { $_.Package -eq $pkg })
    $meta = $PackageMeta[$pkg]
    $health = Get-HealthScore $slots
    $pkgSize = [math]::Round((($slots | Measure-Object -Property SizeMB -Sum).Sum), 2)

    Ensure-Dir (Join-Path $pkgPath 'audit')

    $pkgManifest = @{
        package = $pkg
        priority = $meta.priority
        packageSlug = $meta.slug
        role = $meta.role
        generated = (Get-Date).ToString('o')
        slotCount = $slots.Count
        totalSizeMB = $pkgSize
        healthScore = $health
        slots = @($slots | ForEach-Object {
            @{
                slot = $_.Slot
                role = $_.Role
                primary_mesh = $_.PrimaryMesh
                fbx = $_.FBXRootCount
                obj = $_.OBJCount
                blend = $_.BlendCount
                textures = $_.TextureCount
                sizeMB = $_.SizeMB
                issues = @($_.Issues)
            }
        })
    }
    ($pkgManifest | ConvertTo-Json -Depth 8) | Set-Content -LiteralPath (Join-Path $pkgPath 'audit\manifest.json') -Encoding UTF8

    $pkgDupes = $duplicateRows | Where-Object {
        $_.Locations -match "^$pkg/" -or ($_.Locations -split '; ' | Where-Object { $_ -match "^$pkg/" })
    }
    $crossDupes = $duplicateRows | Where-Object { -not $_.SamePackageOnly -and ($_.Locations -match $pkg) }

    $issuesMd = @(
        "# $pkg - issues",
        '',
        "**Priority:** $($meta.priority) | **Health score:** $health/100 | **Size:** $pkgSize MB",
        '',
        'See ASSET_CLASSIFICATION_LAW.md - do not merge this package with visually similar folders.',
        '',
        '## Slot status',
        ''
    )
    foreach ($s in $slots) {
        $issuesMd += "### $($s.Slot)"
        $issuesMd += "- Role: $($s.Role)"
        $issuesMd += "- Primary: $($s.PrimaryMesh)"
        $issuesMd += "- FBX/OBJ/Blend/Tex: $($s.FBXRootCount)/$($s.OBJCount)/$($s.BlendCount)/$($s.TextureCount) | $($s.SizeMB) MB"
        if ($s.Issues.Count -eq 0) {
            $issuesMd += '- Issues: none flagged'
        } else {
            foreach ($i in $s.Issues) { $issuesMd += "- $i" }
        }
        if ($s.ManifestNotes) {
            foreach ($n in $s.ManifestNotes) { if ($n) { $issuesMd += "- Note: $n" } }
        }
        $issuesMd += ''
    }
    $issuesMd += '## Pending ModelDoc metrics'
    $issuesMd += '- Triangle counts: run after vmdl compile (not available from filesystem scan)'
    $issuesMd += '- Scale consistency: compare spawned bounds in lifepunch-modeldoc.scene'
    $issuesMd += ''
    ($issuesMd -join "`n") | Set-Content -LiteralPath (Join-Path $pkgPath 'issues.md') -Encoding UTF8

    $dupMd = @(
        "# $pkg - duplicate report",
        '',
        '**Law:** duplicate filenames across packages are NOT merge signals - separate gameplay packages.',
        '',
        '## Within-package filename collisions',
        ''
    )
    $within = $duplicateRows | Where-Object { $_.SamePackageOnly -and ($_.Locations -match "^$pkg/") }
    if ($within.Count -eq 0) {
        $dupMd += '- None (unique primary mesh names per slot, or single occurrence).'
    } else {
        foreach ($d in $within) {
            $dupMd += "- **$($d.Filename)** x$($d.Occurrences): $($d.Locations) - keep both slots; verify mesh identity in ModelDoc before sharing vmats"
        }
    }
    $dupMd += ''
    $dupMd += '## Cross-package filename matches (same leaf name - do NOT merge packages)'
    $dupMd += ''
    $crossForPkg = $duplicateRows | Where-Object {
        -not $_.SamePackageOnly -and (($_.Locations -split '; ') | Where-Object { $_ -match "^$pkg/" })
    }
    if ($crossForPkg.Count -eq 0) {
        $dupMd += '- No cross-package primary mesh filename collisions involving this package.'
    } else {
        foreach ($d in $crossForPkg) {
            $dupMd += "- **$($d.Filename)**: $($d.Locations) - intentional parallel Fab exports; stay in separate packages"
        }
    }
    $dupMd += ''
    ($dupMd -join "`n") | Set-Content -LiteralPath (Join-Path $pkgPath 'duplicate_report.md') -Encoding UTF8

    Write-Host "  OK $pkg health=$health size=${pkgSize}MB" -ForegroundColor Green
}

$reportPath = Join-Path $AddonsRoot "docs\ASSET_CLASSIFICATION_REPORT_$ReportDate.md"
$missingTex = $allSlots | Where-Object { $_.TextureCount -eq 0 -and -not $_.SolidColorOk }

$recExports = $allSlots | ForEach-Object {
    $ready = if ($_.HasFbxPrimary) { 'FBX ready' } elseif ($_.PrimaryMesh -match '\.obj$') { 'OBJ - import or re-export FBX' } elseif ($_.PrimaryMesh -match '\.blend$') { 'Blend-only - export FBX first' } else { 'Set primary_mesh' }
    '| {0} | {1} | {2} | {3} |' -f $_.Package, $_.Slot, $_.PrimaryMesh, $ready
}

$healthTable = $PackageMeta.Keys | ForEach-Object {
    $p = $_
    $s = @($allSlots | Where-Object { $_.Package -eq $p })
    if ($s.Count -eq 0) { return }
    $h = Get-HealthScore $s
    $sz = [math]::Round((($s | Measure-Object -Property SizeMB -Sum).Sum), 2)
    "| $p | $($PackageMeta[$p].priority) | $($s.Count) | $sz | $h/100 |"
} | Where-Object { $_ }

$report = @(
    '# LIFEPUNCH Asset Classification Report',
    '',
    "**Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm') | **Source:** Assets/addons/lifepunch/lp*",
    '',
    'Canonical law: ASSET_CLASSIFICATION_LAW.md | Regenerate: Invoke-LifepunchAssetClassificationAudit.ps1',
    '',
    '---',
    '',
    '## 1. Asset inventory',
    '',
    '| Package | Slot | Primary mesh | FBX | OBJ | Blend | Tex | Size MB |',
    '|---------|------|--------------|-----|-----|-------|-----|---------|'
)
foreach ($s in ($allSlots | Sort-Object Package, Slot)) {
    $report += '| {0} | {1} | {2} | {3} | {4} | {5} | {6} | {7} |' -f $s.Package, $s.Slot, $s.PrimaryMesh, $s.FBXRootCount, $s.OBJCount, $s.BlendCount, $s.TextureCount, $s.SizeMB
}
$report += ''
$report += "**Total staged size (all slots):** $totalSizeMB MB across $($allSlots.Count) entity slots in $($PackageMeta.Count) packages."
$report += ''
$report += '---'
$report += ''
$report += '## 2. Duplicate inventory (primary mesh filename)'
$report += ''
if ($duplicateRows.Count -eq 0) {
    $report += 'No duplicate primary mesh filenames detected.'
} else {
    $report += '| Filename | Count | Locations | Merge? |'
    $report += '|----------|-------|-----------|--------|'
    foreach ($d in ($duplicateRows | Sort-Object Filename)) {
        $merge = if ($d.SamePackageOnly) { 'No - same package tiers/slots' } else { 'No - separate packages' }
        $report += "| $($d.Filename) | $($d.Occurrences) | $($d.Locations) | $merge |"
    }
}
$report += ''
$report += '---'
$report += ''
$report += '## 3. Missing / thin texture inventory'
$report += ''
$report += '| Package | Slot | Notes |'
$report += '|---------|------|-------|'
foreach ($m in $missingTex) {
    $note = if ($m.Slot -match 'hub$') { 'Hub - verify trim sheets; may be OK' } else { 'Review game/textures vs Fab 2K pack' }
    $report += "| $($m.Package) | $($m.Slot) | $note |"
}
$report += ''
$report += '**Expected zero-texture slot:** lpbitcoin/bitcoinhub (CPU GAMER solid vertex colors - LifePunch vmats in ModelDoc).'
$report += ''
$report += '---'
$report += ''
$report += '## 4. Recommended game-ready exports'
$report += ''
$report += '| Package | Slot | Primary | Status |'
$report += '|---------|------|---------|--------|'
$report += $recExports
$report += ''
$report += '**P0 order:** gpurack (resolve static body) -> hashdterminal -> bitcoinhub (cpu-gamer.vmdl in progress) -> advancedgpurack.'
$report += ''
$report += '---'
$report += ''
$report += '## 5. Estimated optimization opportunities'
$report += ''
$report += ($optimization -join "`n")
$report += ''
$report += '---'
$report += ''
$report += '## 6. Storage savings (estimate only)'
$report += ''
$report += "- **Staged total today:** $totalSizeMB MB under lp* staging (includes blend + extracted mirrors on Desktop, not all in git)."
$report += "- **Rough savings if 4K/extracted kept on Desktop only (not duplicated into git):** ~$estSavingsMB MB for banker + terminal slots - do not delete owner drop; stop copying 4K into repo when 2K suffices."
$report += '- **Ship-time savings:** compile to _c, strip unused LODs after ModelDoc audit - separate pass.'
$report += ''
$report += '---'
$report += ''
$report += '## 7. Package health scores'
$report += ''
$report += '| Package | Priority | Slots | Size MB | Health |'
$report += '|---------|----------|-------|---------|--------|'
$report += $healthTable
$report += ''
$report += '---'
$report += ''
$report += '## Objective'
$report += ''
$report += 'Protect source assets while producing clean integration-ready packages for future s&box implementation. Never merge packages - filename similarity is expected across Fab CRT/server/safe families.'
$report += ''

($report -join "`n") | Set-Content -LiteralPath $reportPath -Encoding UTF8
Write-Host "`nReport -> $reportPath" -ForegroundColor Cyan
Write-Host 'Done.' -ForegroundColor Green
