<#
// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Hacker Job" (s&box ident: lifepunch.hackerjob · addon ident: hackerjob) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Author account: mrragerlp · Public alias (in-game · Steam · Discord): Bloodwave
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

.SYNOPSIS
  Verify HK-S3 config extraction preserves every shipped hackerjob default.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$codeRoot = (Resolve-Path (Join-Path $here '..\Code\Addons\lifepunch\hackerjob')).Path
$failures = New-Object 'System.Collections.Generic.List[string]'
$passes = 0

function Read-Source {
    param([string] $Name)

    $path = Join-Path $codeRoot $Name
    if (-not (Test-Path -LiteralPath $path)) {
        $failures.Add("missing file: $Name")
        return ''
    }

    return [System.IO.File]::ReadAllText($path)
}

function Assert-Match {
    param(
        [string] $Name,
        [string] $Text,
        [string] $Pattern
    )

    if ([regex]::IsMatch($Text, $Pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)) {
        $script:passes++
        Write-Host "PASS [$Name]" -ForegroundColor Green
        return
    }

    $failures.Add("$Name - expected pattern not found")
}

$config = Read-Source 'HackerJobConfig.cs'
$job = Read-Source 'HackerJob.cs'
$catalog = Read-Source 'HackerUpgradeCatalog.cs'
$pin = Read-Source 'HackerServerRackAccessPin.cs'
$scan = Read-Source 'HackerScanService.cs'
$terminal = Read-Source 'HackerTerminalEntity.cs'

$expectedDefaults = [ordered]@{
    MaxDetectionTier = '4'
    MaxPuzzleTimeTier = '4'
    MaxRewardTier = '3'
    MaxCooldownTier = '3'
    AdvancedMaxDetectionTier = '5'
    AdvancedMaxPuzzleTimeTier = '5'
    AdvancedMaxRewardTier = '3'
    AdvancedMaxCooldownTier = '3'
    BasePuzzleSeconds = '45f'
    PuzzleSecondsPerTier = '8f'
    BaseHackCooldownSeconds = '120f'
    HackCooldownSecondsPerTier = '25f'
    MinimumHackCooldownSeconds = '30f'
    BaseRewardMultiplier = '1f'
    DetectionAlertChanceTier0 = '1\.00f'
    DetectionAlertChanceTier1 = '0\.75f'
    DetectionAlertChanceTier2 = '0\.50f'
    DetectionAlertChanceTier3 = '0\.25f'
    DetectionAlertChanceTier4 = '0\.10f'
    RewardMultiplierTier0 = '1\.00f'
    RewardMultiplierTier1 = '1\.25f'
    RewardMultiplierTier2 = '1\.55f'
    RewardMultiplierTier3 = '2\.00f'
    DetectionCostTier1 = '2_?500'
    DetectionCostTier2 = '6_?000'
    DetectionCostTier3 = '12_?000'
    DetectionCostTier4 = '22_?000'
    PuzzleTimeCostTier1 = '2_?000'
    PuzzleTimeCostTier2 = '5_?000'
    PuzzleTimeCostTier3 = '10_?000'
    PuzzleTimeCostTier4 = '18_?000'
    RewardCostTier1 = '3_?500'
    RewardCostTier2 = '9_?000'
    RewardCostTier3 = '18_?000'
    CooldownCostTier1 = '3_?000'
    CooldownCostTier2 = '8_?000'
    CooldownCostTier3 = '15_?000'
    PinLength = '4'
    PinSessionSeconds = '900f'
    HashdScanDistance = '2500f'
}

foreach ($entry in $expectedDefaults.GetEnumerator()) {
    Assert-Match "default parity $($entry.Key)" $config (
        "public\s+\w+\s+$([regex]::Escape($entry.Key))\s*\{\s*get;\s*init;\s*\}\s*=\s*$($entry.Value)\s*;"
    )
}

Assert-Match 'all extracted values marked PROPOSED' $config 'Every value in this class is PROPOSED'
Assert-Match 'runtime default exists' $config 'public\s+static\s+HackerJobConfig\s+Current\s*\{\s*get;\s*private\s+set;\s*\}\s*=\s*new\(\s*\)'
Assert-Match 'terminal reads T3 config' $terminal 'GetConfig\(\s*new\s+HackerJobConfig\(\s*\)\s*\)'
Assert-Match 'terminal applies config' $terminal 'HackerJobConfigRuntime\.Apply\(\s*config\s*\)'
Assert-Match 'job puzzle default config backed' $job 'DefaultPuzzleTimeLimitSeconds\s*=>\s*HackerJobConfigRuntime\.Current\.BasePuzzleSeconds'
Assert-Match 'catalog reads runtime config' $catalog 'HackerJobConfigRuntime\.Current'
Assert-Match 'PIN reads runtime config' $pin 'HackerJobConfigRuntime\.Current\.Pin'
Assert-Match 'scan default reads runtime config' $scan 'HackerJobConfigRuntime\.Current\.HashdScanDistance'

Write-Host "Hackerjob config parity contracts: $passes passed, $($failures.Count) failed" -ForegroundColor Cyan
if ($failures.Count -gt 0) {
    foreach ($failure in $failures) {
        Write-Host "FAIL [$failure]" -ForegroundColor Red
    }
    exit 1
}

exit 0
