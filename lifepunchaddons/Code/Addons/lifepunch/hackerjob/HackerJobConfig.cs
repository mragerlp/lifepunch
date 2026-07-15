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

namespace LifePunch.DXRP.Addons.HackerJob;

/// <summary>
/// T3 shipped defaults for existing Hacker Job gameplay tunables. The defaults mirror the
/// pre-HK-S3 hardcoded values exactly. Every value in this class is PROPOSED and remains subject
/// to Bloodwave balance review; portal Config Override JSON may replace them after Save + Sync +
/// restart. Gameplay numbers only — secrets never belong on this client-visible config surface.
/// </summary>
public sealed class HackerJobConfig
{
	// PROPOSED — standard rack tier caps.
	public int MaxDetectionTier { get; init; } = 4;
	public int MaxPuzzleTimeTier { get; init; } = 4;
	public int MaxRewardTier { get; init; } = 3;
	public int MaxCooldownTier { get; init; } = 3;

	// PROPOSED — advanced rack tier caps.
	public int AdvancedMaxDetectionTier { get; init; } = 5;
	public int AdvancedMaxPuzzleTimeTier { get; init; } = 5;
	public int AdvancedMaxRewardTier { get; init; } = 3;
	public int AdvancedMaxCooldownTier { get; init; } = 3;

	// PROPOSED — puzzle, cooldown, and reward curves.
	public float BasePuzzleSeconds { get; init; } = 45f;
	public float PuzzleSecondsPerTier { get; init; } = 8f;
	public float BaseHackCooldownSeconds { get; init; } = 120f;
	public float HackCooldownSecondsPerTier { get; init; } = 25f;
	public float MinimumHackCooldownSeconds { get; init; } = 30f;
	public float BaseRewardMultiplier { get; init; } = 1f;

	// PROPOSED — failed-hack alert chance by detection tier.
	public float DetectionAlertChanceTier0 { get; init; } = 1.00f;
	public float DetectionAlertChanceTier1 { get; init; } = 0.75f;
	public float DetectionAlertChanceTier2 { get; init; } = 0.50f;
	public float DetectionAlertChanceTier3 { get; init; } = 0.25f;
	public float DetectionAlertChanceTier4 { get; init; } = 0.10f;

	// PROPOSED — payout multiplier by reward tier.
	public float RewardMultiplierTier0 { get; init; } = 1.00f;
	public float RewardMultiplierTier1 { get; init; } = 1.25f;
	public float RewardMultiplierTier2 { get; init; } = 1.55f;
	public float RewardMultiplierTier3 { get; init; } = 2.00f;

	// PROPOSED — detection upgrade costs.
	public int DetectionCostTier1 { get; init; } = 2_500;
	public int DetectionCostTier2 { get; init; } = 6_000;
	public int DetectionCostTier3 { get; init; } = 12_000;
	public int DetectionCostTier4 { get; init; } = 22_000;

	// PROPOSED — puzzle-time upgrade costs.
	public int PuzzleTimeCostTier1 { get; init; } = 2_000;
	public int PuzzleTimeCostTier2 { get; init; } = 5_000;
	public int PuzzleTimeCostTier3 { get; init; } = 10_000;
	public int PuzzleTimeCostTier4 { get; init; } = 18_000;

	// PROPOSED — reward upgrade costs.
	public int RewardCostTier1 { get; init; } = 3_500;
	public int RewardCostTier2 { get; init; } = 9_000;
	public int RewardCostTier3 { get; init; } = 18_000;

	// PROPOSED — cooldown upgrade costs.
	public int CooldownCostTier1 { get; init; } = 3_000;
	public int CooldownCostTier2 { get; init; } = 8_000;
	public int CooldownCostTier3 { get; init; } = 15_000;

	// PROPOSED — rack access and scan defaults.
	public int PinLength { get; init; } = 4;
	public float PinSessionSeconds { get; init; } = 900f;
	public float HashdScanDistance { get; init; } = 2500f;
}

/// <summary>
/// Process-wide view of the config read by the terminal content entry. Shipped defaults are
/// available before any terminal starts, preserving existing static call sites.
/// </summary>
internal static class HackerJobConfigRuntime
{
	public static HackerJobConfig Current { get; private set; } = new();

	public static void Apply( HackerJobConfig config )
	{
		Current = config ?? new HackerJobConfig();
	}
}
