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
	public const int MaxDetectionTier = 4;
	public const int MaxPuzzleTimeTier = 4;
	public const int MaxRewardTier = 3;
	public const int MaxCooldownTier = 3;

	public const int AdvancedMaxDetectionTier = 5;
	public const int AdvancedMaxPuzzleTimeTier = 5;
	public const int AdvancedMaxRewardTier = 3;
	public const int AdvancedMaxCooldownTier = 3;

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

	public const float BasePuzzleSeconds = 45f;
	public const float BaseHackCooldownSeconds = 120f;
	public const float BaseRewardMultiplier = 1f;

	/// <summary>Chance police counterplay fires on failed hack (wanted and/or panic).</summary>
	public static float GetDetectionAlertChance( int detectionTier )
	{
		var tier = Math.Clamp( detectionTier, 0, MaxDetectionTier );
		return tier switch
		{
			0 => 1.00f,
			1 => 0.75f,
			2 => 0.50f,
			3 => 0.25f,
			4 => 0.10f,
			_ => 1f
		};
	}

	public static float GetPuzzleTimeLimitSeconds( int puzzleTimeTier )
	{
		var tier = Math.Clamp( puzzleTimeTier, 0, MaxPuzzleTimeTier );
		return BasePuzzleSeconds + tier * 8f;
	}

	public static float GetRewardMultiplier( int rewardTier )
	{
		var tier = Math.Clamp( rewardTier, 0, MaxRewardTier );
		return tier switch
		{
			0 => 1.00f,
			1 => 1.25f,
			2 => 1.55f,
			3 => 2.00f,
			_ => 1f
		};
	}

	public static float GetHackCooldownSeconds( int cooldownTier )
	{
		var tier = Math.Clamp( cooldownTier, 0, MaxCooldownTier );
		return Math.Max( 30f, BaseHackCooldownSeconds - tier * 25f );
	}

	public static int GetUpgradeCost( HackerUpgradeKind kind, int nextTier )
	{
		return kind switch
		{
			HackerUpgradeKind.Detection => nextTier switch { 1 => 2500, 2 => 6000, 3 => 12000, 4 => 22000, _ => 0 },
			HackerUpgradeKind.PuzzleTime => nextTier switch { 1 => 2000, 2 => 5000, 3 => 10000, 4 => 18000, _ => 0 },
			HackerUpgradeKind.Reward => nextTier switch { 1 => 3500, 2 => 9000, 3 => 18000, _ => 0 },
			HackerUpgradeKind.Cooldown => nextTier switch { 1 => 3000, 2 => 8000, 3 => 15000, _ => 0 },
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
