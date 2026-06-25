<#
.SYNOPSIS
  Build LIFEPUNCH Design Architect ChatGPT continuity package (flat upload-safe filenames).

.DESCRIPTION
  Package format v2 — two content chunks (19 + readme each) plus README zip.
  Writes UTF-8 without BOM. Records SHA-256 per zip in PACKAGE_MANIFEST.md.
  Continuity kit law: lifepunch/docs/handoff/ARCHITECT_CONTINUITY_KIT_LAW.md
  GitHub authoritative; ZIP = snapshot. Full rebuild on law/onboarding/CURRENT_STATE/decisions/ACTIVE_WORKSTREAM changes.

.EXAMPLE
  powershell -File lifepunch\scripts\Build-ArchitectChatGptOnboardZip.ps1 -Build
#>
[CmdletBinding()]
param(
    [switch] $Build,
    [string] $OutputDir = ''
)

$ErrorActionPreference = 'Stop'
$PackageFormatVersion = '2.0'
$SupersededCommit = '1e2c9af'

$Here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$RepoRoot = Split-Path -Parent (Split-Path -Parent $Here)
$Lifepunch = Join-Path $RepoRoot 'lifepunch'
$Docs = Join-Path $Lifepunch 'docs'
$AddonsDocs = Join-Path $Lifepunch 'addons\docs'
$Handoff = Join-Path $Docs 'handoff'
$Decisions = Join-Path $Docs 'DECISIONS'

function Write-Utf8NoBom([string]$Path, [string]$Content) {
    $enc = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Content, $enc)
}

function Test-Mojibake([string]$Text) {
    $badA = [char]0x00E2 + [char]0x20AC
    $badB = [char]0x00C2 + [char]0x00B7
    if ($Text.Contains($badA)) { return $true }
    if ($Text.Contains($badB)) { return $true }
    return $false
}

$Tm = [char]0x2122

function Get-FileSha256([string]$Path) {
    (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

$commit = (git -C $RepoRoot rev-parse --short HEAD 2>$null)
if (-not $commit) { $commit = 'unknown' }
$stamp = Get-Date -Format 'yyyy-MM-dd'
$utc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd HH:mm') + ' UTC'
$bundlePrefix = "LIFEPUNCH-Architect-ChatGPT-$stamp-$commit"

$desktop = [Environment]::GetFolderPath('Desktop')
if (-not $desktop) { $desktop = Join-Path $env:USERPROFILE 'Desktop' }
$outDir = if ($OutputDir) { $OutputDir } else { $desktop }

$stageRoot = Join-Path $env:TEMP $bundlePrefix
if (Test-Path -LiteralPath $stageRoot) { Remove-Item -LiteralPath $stageRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $stageRoot | Out-Null

# Flat package filename -> repo source + authority class
$filePlan = @(
    @{ Package = 'NEW_CHAT_BOOTSTRAP_PASTE.txt'; Src = Join-Path $Handoff 'NEW_CHAT_BOOTSTRAP_PASTE.txt'; Authority = 'paste/template' }
    @{ Package = 'ARCHITECT_PROJECT_INSTRUCTIONS.txt'; Src = Join-Path $Handoff 'ARCHITECT_PROJECT_INSTRUCTIONS.txt'; Authority = 'paste/template' }
    @{ Package = 'ARCHITECT_ONBOARDING_PASTE.txt'; Src = Join-Path $Handoff 'ARCHITECT_ONBOARDING_PASTE.txt'; Authority = 'paste/template' }
    @{ Package = 'CHATGPT_STEP1_PASTE.txt'; Src = Join-Path $Handoff 'CHATGPT_STEP1_PASTE.txt'; Authority = 'paste/template' }
    @{ Package = 'WORKFLOW_IDEATION_FIRST.md'; Src = Join-Path $Docs 'WORKFLOW_IDEATION_FIRST.md'; Authority = 'design canon' }
    @{ Package = 'ARCHITECT_CURRENT_STATE.md'; Src = Join-Path $Handoff 'ARCHITECT_CURRENT_STATE.md'; Authority = 'current state' }
    @{ Package = 'LIFEPUNCH_GAMEPLAY_LAWS.md'; Src = Join-Path $Docs 'LIFEPUNCH_GAMEPLAY_LAWS.md'; Authority = 'design canon' }
    @{ Package = 'LIFEPUNCH_FEEL.md'; Src = Join-Path $Docs 'LIFEPUNCH_FEEL.md'; Authority = 'design canon' }
    @{ Package = 'TERMINOLOGY.md'; Src = Join-Path $Docs 'TERMINOLOGY.md'; Authority = 'design canon' }
    @{ Package = 'OWNERSHIP_MATRIX.md'; Src = Join-Path $Docs 'OWNERSHIP_MATRIX.md'; Authority = 'design canon' }
    @{ Package = 'ACTIVE_WORKSTREAM.md'; Src = Join-Path $AddonsDocs 'ACTIVE_WORKSTREAM.md'; Authority = 'repo law / owner law' }
    @{ Package = 'CYBER_REFERENCE_LAWS.md'; Src = Join-Path $AddonsDocs 'CYBER_REFERENCE_LAWS.md'; Authority = 'repo law / owner law' }
    @{ Package = 'BITCOIN_SHIP_ROADMAP.md'; Src = Join-Path $AddonsDocs 'BITCOIN_SHIP_ROADMAP.md'; Authority = 'owner law / roadmap' }
    @{ Package = 'DECISIONS_INDEX.md'; Src = Join-Path $Decisions 'README.md'; Authority = 'decision index' }
    @{ Package = 'ARCHITECT.md'; Src = Join-Path $Docs 'ARCHITECT.md'; Authority = 'design canon' }
    @{ Package = 'PATTERN_LIBRARY.md'; Src = Join-Path $Docs 'PATTERN_LIBRARY.md'; Authority = 'design canon' }
    @{ Package = 'BITCOIN_PLAYER_DESIGN.md'; Src = Join-Path $AddonsDocs 'BITCOIN_PLAYER_DESIGN.md'; Authority = 'design canon' }
    @{ Package = 'BITCOIN_CONTROLLER_PATTERN.md'; Src = Join-Path $AddonsDocs 'BITCOIN_CONTROLLER_PATTERN.md'; Authority = 'design canon' }
    @{ Package = 'BITCOIN_DATA_FLOW.md'; Src = Join-Path $AddonsDocs 'BITCOIN_DATA_FLOW.md'; Authority = 'design canon' }
    @{ Package = 'BITCOIN_UPGRADE_TAXONOMY.md'; Src = Join-Path $AddonsDocs 'BITCOIN_UPGRADE_TAXONOMY.md'; Authority = 'design canon' }
    @{ Package = 'LIFEPUNCH_HUB_PATTERN.md'; Src = Join-Path $AddonsDocs 'LIFEPUNCH_HUB_PATTERN.md'; Authority = 'design canon' }
    @{ Package = 'LIFEPUNCH_CYBER_SYSTEM_PATTERN.md'; Src = Join-Path $AddonsDocs 'LIFEPUNCH_CYBER_SYSTEM_PATTERN.md'; Authority = 'design canon' }
    @{ Package = 'BUSINESS_CONTEXT.md'; Src = Join-Path $Docs 'BUSINESS_CONTEXT.md'; Authority = 'design canon' }
    @{ Package = 'CYBER_ECONOMY_RAILS.md'; Src = Join-Path $AddonsDocs 'CYBER_ECONOMY_RAILS.md'; Authority = 'repo economy law' }
    @{ Package = 'TERMINAL_BRAND_MATRIX.md'; Src = Join-Path $AddonsDocs 'TERMINAL_BRAND_MATRIX.md'; Authority = 'design canon' }
    @{ Package = 'LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md'; Src = Join-Path $AddonsDocs 'LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md'; Authority = 'repo machine law' }
    @{ Package = 'CHATGPT_FOOD_PIPELINE.md'; Src = Join-Path $Docs 'CHATGPT_FOOD_PIPELINE.md'; Authority = 'design canon' }
    @{ Package = 'OPUS_USAGE_LAW.md'; Src = Join-Path $Docs 'OPUS_USAGE_LAW.md'; Authority = 'repo model-routing law' }
    @{ Package = 'BLOODWAVE_ALIAS.md'; Src = Join-Path $Docs 'BLOODWAVE_ALIAS.md'; Authority = 'design canon' }
)

Get-ChildItem -LiteralPath $Decisions -Filter 'DECISION-*.md' | Sort-Object Name | ForEach-Object {
    $filePlan += @{ Package = $_.Name; Src = $_.FullName; Authority = 'decision record' }
}

$chunk01Names = @(
    'NEW_CHAT_BOOTSTRAP_PASTE.txt', 'ARCHITECT_PROJECT_INSTRUCTIONS.txt', 'ARCHITECT_ONBOARDING_PASTE.txt',
    'CHATGPT_STEP1_PASTE.txt', 'WORKFLOW_IDEATION_FIRST.md', 'ARCHITECT_CURRENT_STATE.md',
    'LIFEPUNCH_GAMEPLAY_LAWS.md', 'LIFEPUNCH_FEEL.md', 'TERMINOLOGY.md', 'OWNERSHIP_MATRIX.md',
    'ACTIVE_WORKSTREAM.md', 'CYBER_REFERENCE_LAWS.md', 'BITCOIN_SHIP_ROADMAP.md', 'DECISIONS_INDEX.md',
    'ARCHITECT.md', 'PATTERN_LIBRARY.md', 'BITCOIN_PLAYER_DESIGN.md', 'BITCOIN_CONTROLLER_PATTERN.md',
    'BITCOIN_DATA_FLOW.md'
)

$chunk02Names = @(
    'BITCOIN_UPGRADE_TAXONOMY.md', 'LIFEPUNCH_HUB_PATTERN.md', 'LIFEPUNCH_CYBER_SYSTEM_PATTERN.md',
    'BUSINESS_CONTEXT.md', 'CYBER_ECONOMY_RAILS.md', 'TERMINAL_BRAND_MATRIX.md',
    'LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md', 'CHATGPT_FOOD_PIPELINE.md', 'OPUS_USAGE_LAW.md',
    'BLOODWAVE_ALIAS.md', 'DECISION-0001-Single-Authoritative-Owner.md',
    'DECISION-0002-Hub-Owns-Mining.md', 'DECISION-0003-No-NPC-Core-Progression.md',
    'DECISION-0004-Three-Rack-Limit.md', 'DECISION-0005-Terminal-Never-Mines.md',
    'DECISION-0006-Hub-Controller-Upgrades.md', 'DECISION-0007-Preserve-Hub-UI-Shell.md',
    'DECISION-0008-Fantasy-Check-Gate.md', 'DECISION-0009-Gameplay-Laws-Document.md'
)

$planByName = @{}
foreach ($e in $filePlan) { $planByName[$e.Package] = $e }

$manifestRows = [System.Collections.Generic.List[string]]::new()
$staged = [System.Collections.Generic.List[object]]::new()

foreach ($e in $filePlan) {
    if (-not (Test-Path -LiteralPath $e.Src)) {
        throw "Missing source: $($e.Src)"
    }
    $destFull = Join-Path $stageRoot $e.Package
    Copy-Item -LiteralPath $e.Src -Destination $destFull -Force
    $relRepo = $e.Src.Replace($RepoRoot + '\', '').Replace($RepoRoot + '/', '')
    $manifestRows.Add("| ``$($e.Package)`` | ``$relRepo`` | $($e.Authority) |")
    $staged.Add([PSCustomObject]@{ Package = $e.Package; Full = $destFull; Authority = $e.Authority })
}

if ($staged.Count -ne 38) {
    throw "Expected 38 content files; got $($staged.Count)"
}

function Build-ChunkReadme([string]$Num, [string[]]$Names, [int]$TotalChunks) {
    $fileList = ($Names | ForEach-Object { "- ``$_``" }) -join "`n"
    return @"
# Chunk $Num of $TotalChunks - LIFEPUNCH$Tm Design Architect upload

**Source:** github.com/mragerlp/lifepunch @ ``$commit`` | **Generated:** $utc

Upload this zip to **LIFEPUNCH$Tm ChatGPT Project knowledge** as one batch (20 files max: this readme + $($Names.Count) content files).

## Files in this chunk

$fileList

## Upload order

1. Upload **$bundlePrefix-00-README.zip** first - read ``START_HERE.md`` before other chunks.
2. Upload **$bundlePrefix-01-chunk.zip** then **$bundlePrefix-02-chunk.zip**.
3. Set Project custom instructions from ``ARCHITECT_PROJECT_INSTRUCTIONS.txt`` (chunk 01).

## New chat (one conversation)

After both chunks are uploaded, paste only:

``NEW_CHAT_BOOTSTRAP_PASTE.txt``

For new product ideation use ``CHATGPT_STEP1_PASTE.txt``.

GitHub monorepo wins over uploaded copies. Refresh ``ARCHITECT_CURRENT_STATE.md`` when phase changes.

**Note:** Some repo paths referenced in docs are intentionally excluded from this compact package (Integration Architect use). GitHub remains authoritative.
"@
}

$chunkDirs = @(
    @{ Num = '01'; Names = $chunk01Names; Readme = 'CHUNK_01_README.md' }
    @{ Num = '02'; Names = $chunk02Names; Readme = 'CHUNK_02_README.md' }
)

$chunkManifest = [System.Collections.Generic.List[string]]::new()

foreach ($chunk in $chunkDirs) {
    $chunkDir = Join-Path $stageRoot "_chunks\chunk-$($chunk.Num)"
    New-Item -ItemType Directory -Force -Path $chunkDir | Out-Null

    foreach ($name in $chunk.Names) {
        if (-not $planByName.ContainsKey($name)) { throw "Chunk file not in plan: $name" }
        $src = Join-Path $stageRoot $name
        Copy-Item -LiteralPath $src -Destination (Join-Path $chunkDir $name) -Force
    }

    $readmeText = Build-ChunkReadme -Num $chunk.Num -Names $chunk.Names -TotalChunks 2
    Write-Utf8NoBom (Join-Path $chunkDir $chunk.Readme) $readmeText
    $chunkManifest.Add("| $($chunk.Num) | $($chunk.Names.Count) content + $($chunk.Readme) | ``$bundlePrefix-$($chunk.Num)-chunk.zip`` | 20 |")
}

$startHere = @"
# LIFEPUNCH$Tm Design Architect - ChatGPT setup (read first)

**Source:** github.com/mragerlp/lifepunch @ ``$commit`` | **Generated:** $utc

This package is split into **upload batches of no more than 20 files** for the current workflow.

---

## Step 0 - You are reading this (zip 00)

Upload or paste this file into the LIFEPUNCH$Tm ChatGPT Project **before** uploading chunk zips.

---

## Step 1 - Project custom instructions (one time)

From **chunk 01** after upload, copy into Project instructions:

``ARCHITECT_PROJECT_INSTRUCTIONS.txt``

(or full ``ARCHITECT_ONBOARDING_PASTE.txt``)

---

## Step 2 - Upload chunk zips to Project knowledge

Upload each zip **in order**. Each chunk has **19 content files + one unique chunk readme** (20 total).

| Chunk | Contents | Zip filename |
|-------|----------|--------------|
$($chunkManifest -join "`n")

All filenames are **flat and unique** - do not rely on folder paths being preserved by the upload UI.

---

## Step 3 - One new chat (performance)

Do **not** paste the whole library. After both chunks are uploaded:

1. Paste ``NEW_CHAT_BOOTSTRAP_PASTE.txt`` only.
2. For **new product ideation**, paste ``CHATGPT_STEP1_PASTE.txt``.

---

## Authority

- **GitHub monorepo** wins over uploaded package copies.
- **``ARCHITECT_CURRENT_STATE.md``** is the volatile status file (repo: ``lifepunch/docs/handoff/ARCHITECT_CURRENT_STATE.md``).
- **HOLD:** RFC-0005 hub upgrade + economy overhaul until Bloodwave GO.
- **Phase A Hub** is active; Terminal locked until H10.

Some repo paths are referenced for Integration Architect use and are intentionally excluded from this compact Design Architect package.

See ``PACKAGE_MANIFEST.md`` in this zip for the full file index and SHA-256 checksums.
"@

Write-Utf8NoBom (Join-Path $stageRoot 'START_HERE.md') $startHere

$excluded = @(
    'AGENT_ONBOARDING.md', 'MACHINE_CAST.md', 'DESIGN_DECISION_LOG.md', 'AGENT_SYNC_BROADCAST.txt',
    'KNOWLEDGE/**', 'RFC-0005', 'scratch/**', 'templates/**', 'deprecated/**',
    'gameplay code', 'compiled assets', 'secrets', 'API keys', 'bearer tokens',
    'generated ModelDoc assets', 'stale upload packages', 'old session overrides'
) -join ' | '

$pkgManifest = @"
# Package manifest (LIFEPUNCH$Tm Design Architect - compact)

| Field | Value |
|-------|-------|
| Package format version | $PackageFormatVersion |
| Source repo | https://github.com/mragerlp/lifepunch |
| Source commit | ``$commit`` |
| Generated (UTC) | $utc |
| Superseded package commit | ``$SupersededCommit`` |
| Content files | 38 |
| Chunk zips | 2 (19 + chunk readme each) |
| Upload batch limit | 20 files per batch (workflow) |

## Chunk map

| Chunk | Contents | Zip filename | File count |
|-------|----------|--------------|------------|
$($chunkManifest -join "`n")

## SHA-256 (filled after -Build)

| Zip | SHA-256 |
|-----|---------|
| PLACEHOLDER | (run with -Build) |

## All package files

| Package filename | Repo path | Authority class |
|------------------|-----------|-----------------|
$($manifestRows -join "`n")

## Deliberate exclusions (repo-only)

$excluded
"@

Write-Utf8NoBom (Join-Path $stageRoot 'PACKAGE_MANIFEST.md') $pkgManifest

if (-not $Build) {
    Write-Host "Staged: $stageRoot" -ForegroundColor Cyan
    Write-Host "Content files: 38 -> 2 chunks (19 + readme each) + README zip" -ForegroundColor Cyan
    Write-Host "Pass -Build to write zips to: $outDir" -ForegroundColor Yellow
    exit 0
}

New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$zip00 = Join-Path $outDir "$bundlePrefix-00-README.zip"
if (Test-Path -LiteralPath $zip00) { Remove-Item -LiteralPath $zip00 -Force }
Compress-Archive -Path @(
    (Join-Path $stageRoot 'START_HERE.md')
    (Join-Path $stageRoot 'PACKAGE_MANIFEST.md')
) -DestinationPath $zip00 -Force

$shaRows = [System.Collections.Generic.List[string]]::new()
$shaRows.Add("| ``$bundlePrefix-00-README.zip`` | $(Get-FileSha256 $zip00) | 2 |")
Write-Host "OK $zip00 (2 files)" -ForegroundColor Green

foreach ($chunk in $chunkDirs) {
    $chunkDir = Join-Path $stageRoot "_chunks\chunk-$($chunk.Num)"
    $zipChunk = Join-Path $outDir "$bundlePrefix-$($chunk.Num)-chunk.zip"
    if (Test-Path -LiteralPath $zipChunk) { Remove-Item -LiteralPath $zipChunk -Force }
    Compress-Archive -Path (Join-Path $chunkDir '*') -DestinationPath $zipChunk -Force
    $count = (Get-ChildItem -LiteralPath $chunkDir -File).Count
    if ($count -ne 20) { throw "Chunk $($chunk.Num) expected 20 files; got $count" }
    $shaRows.Add("| ``$bundlePrefix-$($chunk.Num)-chunk.zip`` | $(Get-FileSha256 $zipChunk) | 20 |")
    Write-Host "OK $zipChunk ($count files)" -ForegroundColor Green
}

# Rewrite manifest with checksums
$pkgManifestFinal = @"
# Package manifest (LIFEPUNCH$Tm Design Architect - compact)

| Field | Value |
|-------|-------|
| Package format version | $PackageFormatVersion |
| Source repo | https://github.com/mragerlp/lifepunch |
| Source commit | ``$commit`` |
| Generated (UTC) | $utc |
| Superseded package commit | ``$SupersededCommit`` |
| Content files | 38 |
| Chunk zips | 2 (19 + chunk readme each) |
| Upload batch limit | 20 files per batch (workflow) |

## Chunk map

| Chunk | Contents | Zip filename | File count |
|-------|----------|--------------|------------|
$($chunkManifest -join "`n")

## SHA-256

| Zip | SHA-256 | Files |
|-----|---------|-------|
$($shaRows -join "`n")

## All package files

| Package filename | Repo path | Authority class |
|------------------|-----------|-----------------|
$($manifestRows -join "`n")

## Deliberate exclusions (repo-only)

$excluded
"@

Write-Utf8NoBom (Join-Path $stageRoot 'PACKAGE_MANIFEST.md') $pkgManifestFinal
if (Test-Path -LiteralPath $zip00) { Remove-Item -LiteralPath $zip00 -Force }
Compress-Archive -Path @(
    (Join-Path $stageRoot 'START_HERE.md')
    (Join-Path $stageRoot 'PACKAGE_MANIFEST.md')
) -DestinationPath $zip00 -Force
Write-Host "OK $zip00 (manifest with SHA-256 refreshed)" -ForegroundColor Green

# Validate no duplicate basenames across chunk zips
$allNames = @()
foreach ($chunk in $chunkDirs) {
    $chunkDir = Join-Path $stageRoot "_chunks\chunk-$($chunk.Num)"
    $allNames += Get-ChildItem -LiteralPath $chunkDir -File | ForEach-Object { $_.Name }
}
$dups = $allNames | Group-Object | Where-Object { $_.Count -gt 1 }
if ($dups) { throw "Duplicate basenames in package: $($dups.Name -join ', ')" }

Remove-Item -LiteralPath $stageRoot -Recurse -Force
Write-Host ""
Write-Host "Upload order: 00-README -> 01-chunk -> 02-chunk -> custom instructions -> NEW_CHAT_BOOTSTRAP_PASTE" -ForegroundColor Cyan
