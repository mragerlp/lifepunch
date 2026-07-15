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

using System;

namespace LifePunch.DXRP.Addons.HackerJob;

/// <summary>
/// Server-rack upgrade tiers — installed via <see cref="HackerServerRackMenu"/>.
/// </summary>
public static class HackerUpgradeCatalog
{
	public static int MaxDetectionTier => HackerJobConfigRuntime.Current.MaxDetectionTier;
	public static int MaxPuzzleTimeTier => HackerJobConfigRuntime.Current.MaxPuzzleTimeTier;
	public static int MaxRewardTier => HackerJobConfigRuntime.Current.MaxRewardTier;
	public static int MaxCooldownTier => HackerJobConfigRuntime.Current.MaxCooldownTier;

	public static int AdvancedMaxDetectionTier => HackerJobConfigRuntime.Current.AdvancedMaxDetectionTier;
	public static int AdvancedMaxPuzzleTimeTier => HackerJobConfigRuntime.Current.AdvancedMaxPuzzleTimeTier;
	public static int AdvancedMaxRewardTier => HackerJobConfigRuntime.Current.AdvancedMaxRewardTier;
	public static int AdvancedMaxCooldownTier => HackerJobConfigRuntime.Current.AdvancedMaxCooldownTier;

	public static int GetMaxTier( HackerRackTier rackTier, HackerUpgradeKind kind ) => rackTier switch
	{
		HackerRackTier.Advanced => kind switch
		{
			HackerUpgradeKind.Detection => AdvancedMaxDetectionTier,
			HackerUpgradeKind.PuzzleTime => AdvancedMaxPuzzleTimeTier,
			HackerUpgradeKind.Reward => AdvancedMaxRewardTier,
			HackerUpgradeKind.Cooldown => AdvancedMaxCooldownTier,
			_ => 0
		},
		_ => kind switch
		{
			HackerUpgradeKind.Detection => MaxDetectionTier,
			HackerUpgradeKind.PuzzleTime => MaxPuzzleTimeTier,
			HackerUpgradeKind.Reward => MaxRewardTier,
			HackerUpgradeKind.Cooldown => MaxCooldownTier,
			_ => 0
		}
	};

	public static float BasePuzzleSeconds => HackerJobConfigRuntime.Current.BasePuzzleSeconds;
	public static float BaseHackCooldownSeconds => HackerJobConfigRuntime.Current.BaseHackCooldownSeconds;
	public static float BaseRewardMultiplier => HackerJobConfigRuntime.Current.BaseRewardMultiplier;

	/// <summary>Chance police counterplay fires on failed hack (wanted and/or panic).</summary>
	public static float GetDetectionAlertChance( int detectionTier )
	{
		var tier = Math.Clamp( detectionTier, 0, MaxDetectionTier );
		return tier switch
		{
			0 => HackerJobConfigRuntime.Current.DetectionAlertChanceTier0,
			1 => HackerJobConfigRuntime.Current.DetectionAlertChanceTier1,
			2 => HackerJobConfigRuntime.Current.DetectionAlertChanceTier2,
			3 => HackerJobConfigRuntime.Current.DetectionAlertChanceTier3,
			4 => HackerJobConfigRuntime.Current.DetectionAlertChanceTier4,
			_ => HackerJobConfigRuntime.Current.DetectionAlertChanceTier0
		};
	}

	public static float GetPuzzleTimeLimitSeconds( int puzzleTimeTier )
	{
		var tier = Math.Clamp( puzzleTimeTier, 0, MaxPuzzleTimeTier );
		return BasePuzzleSeconds + tier * HackerJobConfigRuntime.Current.PuzzleSecondsPerTier;
	}

	public static float GetRewardMultiplier( int rewardTier )
	{
		var tier = Math.Clamp( rewardTier, 0, MaxRewardTier );
		return tier switch
		{
			0 => HackerJobConfigRuntime.Current.RewardMultiplierTier0,
			1 => HackerJobConfigRuntime.Current.RewardMultiplierTier1,
			2 => HackerJobConfigRuntime.Current.RewardMultiplierTier2,
			3 => HackerJobConfigRuntime.Current.RewardMultiplierTier3,
			_ => BaseRewardMultiplier
		};
	}

	public static float GetHackCooldownSeconds( int cooldownTier )
	{
		var tier = Math.Clamp( cooldownTier, 0, MaxCooldownTier );
		return Math.Max(
			HackerJobConfigRuntime.Current.MinimumHackCooldownSeconds,
			BaseHackCooldownSeconds - tier * HackerJobConfigRuntime.Current.HackCooldownSecondsPerTier );
	}

	public static int GetUpgradeCost( HackerUpgradeKind kind, int nextTier )
	{
		return kind switch
		{
			HackerUpgradeKind.Detection => nextTier switch
			{
				1 => HackerJobConfigRuntime.Current.DetectionCostTier1,
				2 => HackerJobConfigRuntime.Current.DetectionCostTier2,
				3 => HackerJobConfigRuntime.Current.DetectionCostTier3,
				4 => HackerJobConfigRuntime.Current.DetectionCostTier4,
				_ => 0
			},
			HackerUpgradeKind.PuzzleTime => nextTier switch
			{
				1 => HackerJobConfigRuntime.Current.PuzzleTimeCostTier1,
				2 => HackerJobConfigRuntime.Current.PuzzleTimeCostTier2,
				3 => HackerJobConfigRuntime.Current.PuzzleTimeCostTier3,
				4 => HackerJobConfigRuntime.Current.PuzzleTimeCostTier4,
				_ => 0
			},
			HackerUpgradeKind.Reward => nextTier switch
			{
				1 => HackerJobConfigRuntime.Current.RewardCostTier1,
				2 => HackerJobConfigRuntime.Current.RewardCostTier2,
				3 => HackerJobConfigRuntime.Current.RewardCostTier3,
				_ => 0
			},
			HackerUpgradeKind.Cooldown => nextTier switch
			{
				1 => HackerJobConfigRuntime.Current.CooldownCostTier1,
				2 => HackerJobConfigRuntime.Current.CooldownCostTier2,
				3 => HackerJobConfigRuntime.Current.CooldownCostTier3,
				_ => 0
			},
			_ => 0
		};
	}

	public static string GetUpgradeLabel( HackerUpgradeKind kind, int tier )
	{
		return kind switch
		{
			HackerUpgradeKind.Detection => $"Detection L{tier} — alert {(int)(GetDetectionAlertChance( tier ) * 100)}%",
			HackerUpgradeKind.PuzzleTime => $"Puzzle Time L{tier} — {GetPuzzleTimeLimitSeconds( tier ):0}s limit",
			HackerUpgradeKind.Reward => $"Reward L{tier} — {GetRewardMultiplier( tier ):0.00}× payout",
			HackerUpgradeKind.Cooldown => $"Cooldown L{tier} — {GetHackCooldownSeconds( tier ):0}s between hacks",
			_ => kind.ToString()
		};
	}
}

public enum HackerUpgradeKind
{
	Detection,
	PuzzleTime,
	Reward,
	Cooldown
}
