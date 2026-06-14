# LifePunch — compare local s&box engine version vs last-reviewed patch log.
# Exit 0 = OK (in sync). Exit 1 = WARN (engine newer than doc — triage required).
param(
    [string]$SboxRoot = 'D:\Steam\steamapps\common\sbox',
    [string]$PatchDoc = (Join-Path $PSScriptRoot '..\addons\docs\SBOX_ENGINE_PATCHES.md')
)

$ErrorActionPreference = 'Stop'

function Get-EngineVersionFromLog {
    param([string]$LogPath)
    if (-not (Test-Path -LiteralPath $LogPath)) { return $null }
    $found = Select-String -Path $LogPath -Pattern 'Editor Startup version (\S+)' -AllMatches
    if (-not $found) { return $null }
    return $found[-1].Matches[0].Groups[1].Value
}

function Get-LastReviewedEngine {
    param([string]$DocPath)
    if (-not (Test-Path -LiteralPath $DocPath)) { return $null }
    $line = Select-String -Path $DocPath -Pattern '\*\*Last reviewed engine\*\* \| `([^`]+)`' | Select-Object -First 1
    if (-not $line) { return $null }
    return $line.Matches[0].Groups[1].Value
}

function Normalize-EngineVersion {
    param([string]$Version)
    if ([string]::IsNullOrWhiteSpace($Version)) { return $null }
    if ($Version -match '^(\d+\.\d+\.\d+)') { return $Matches[1] }
    return $Version.Trim()
}

function Compare-EngineVersions {
    param([string]$A, [string]$B)
    $pa = $A.Split('.') | ForEach-Object { [int]$_ }
    $pb = $B.Split('.') | ForEach-Object { [int]$_ }
    $max = [Math]::Max($pa.Count, $pb.Count)
    for ($i = 0; $i -lt $max; $i++) {
        $va = if ($i -lt $pa.Count) { $pa[$i] } else { 0 }
        $vb = if ($i -lt $pb.Count) { $pb[$i] } else { 0 }
        if ($va -gt $vb) { return 1 }
        if ($va -lt $vb) { return -1 }
    }
    return 0
}

$logPath = Join-Path $SboxRoot 'logs\sbox-dev.log'
$localRaw = Get-EngineVersionFromLog -LogPath $logPath
$localNorm = Normalize-EngineVersion -Version $localRaw
$reviewedNorm = Normalize-EngineVersion -Version (Get-LastReviewedEngine -DocPath $PatchDoc)

$localLabel = if ($localRaw) { $localRaw } else { '(unknown - open editor once)' }
$reviewedLabel = if ($reviewedNorm) { $reviewedNorm } else { '(missing - fix SBOX_ENGINE_PATCHES.md)' }

Write-Host 's&box engine patch status'
Write-Host "  Local (log):     $localLabel"
Write-Host "  Last reviewed:   $reviewedLabel"
Write-Host "  Patch doc:       $PatchDoc"

if (-not $reviewedNorm) {
    Write-Host '  Status: WARN - patch doc has no lastReviewedEngine' -ForegroundColor Yellow
    exit 1
}

if (-not $localNorm) {
    Write-Host '  Status: OK - local version unknown; cannot compare' -ForegroundColor DarkYellow
    Write-Host '  -> Launch s&box editor once, then re-run.' -ForegroundColor DarkYellow
    exit 0
}

if ($localNorm -eq $reviewedNorm) {
    Write-Host '  Status: OK - engine matches last-reviewed patch' -ForegroundColor Green
    exit 0
}

$cmp = Compare-EngineVersions -A $localNorm -B $reviewedNorm
if ($cmp -gt 0) {
    Write-Host "  Status: WARN - local $localNorm is NEWER than reviewed $reviewedNorm" -ForegroundColor Yellow
    Write-Host '  -> Read https://sbox.game/news - update addons/docs/SBOX_ENGINE_PATCHES.md - run regression checklist.' -ForegroundColor Yellow
    exit 1
}

Write-Host "  Status: OK - local $localNorm is older or same family as reviewed $reviewedNorm" -ForegroundColor Green
exit 0
