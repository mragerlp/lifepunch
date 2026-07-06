// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Bitcoin Mining" (s&box ident: lifepunch.bitcoinmining · addon ident: bitcoinmining) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Author account: mrragerlp · Public alias (in-game · Steam · Discord): Bloodwave
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System;

namespace LifePunch.DXRP.Addons.BitcoinMining;

/// <summary>
/// Bitcoin Miner hub encryption tiers — defense vs vengeance intrusion.
/// Spec: <c>addons/docs/BITCOINMINING_ENCRYPTION_SPEC.md</c>. UI + host wiring land with hub entity.
/// </summary>
public static class BitcoinMinerEncryptionCatalog
{
	public const int MaxFirewallTier = 3;
	public const int MaxWalletCipherTier = 3;
	public const int MaxIntrusionAlertTier = 3;
	public const int MaxRehackCooldownTier = 3;
	public const int MaxPuzzleHardeningTier = 3;

	public const float BaseWalletStealMin = 1000f;
	public const float BaseWalletStealMax = 2500f;

	public static float GetFirewallFailBonus( int tier )
	{
		var t = Math.Clamp( tier, 0, MaxFirewallTier );
		return t * 0.10f;
	}

	public static float GetWalletCipherStealReduction( int tier )
	{
		var t = Math.Clamp( tier, 0, MaxWalletCipherTier );
		return t * 0.05f;
	}

	public static float GetIntrusionAlertChance( int tier )
	{
		var t = Math.Clamp( tier, 0, MaxIntrusionAlertTier );
		return 0.25f + t * 0.15f;
	}

	public static float GetRehackCooldownBonusSeconds( int tier )
	{
		var t = Math.Clamp( tier, 0, MaxRehackCooldownTier );
		return t * 30f;
	}

	public static float GetPuzzleHardeningSeconds( int tier )
	{
		var t = Math.Clamp( tier, 0, MaxPuzzleHardeningTier );
		return t * 4f;
	}

	public static int GetUpgradeCost( BitcoinMiningAddonEncryptionKind kind, int nextTier ) => kind switch
	{
		BitcoinMiningAddonEncryptionKind.Firewall => nextTier switch { 1 => 5000, 2 => 12000, 3 => 25000, _ => 0 },
		BitcoinMiningAddonEncryptionKind.WalletCipher => nextTier switch { 1 => 4000, 2 => 10000, 3 => 20000, _ => 0 },
		BitcoinMiningAddonEncryptionKind.IntrusionAlert => nextTier switch { 1 => 3500, 2 => 9000, 3 => 18000, _ => 0 },
		BitcoinMiningAddonEncryptionKind.RehackCooldown => nextTier switch { 1 => 4500, 2 => 11000, 3 => 22000, _ => 0 },
		BitcoinMiningAddonEncryptionKind.PuzzleHardening => nextTier switch { 1 => 6000, 2 => 15000, 3 => 30000, _ => 0 },
		_ => 0
	};
}

public enum BitcoinMiningAddonEncryptionKind
{
	Firewall,
	WalletCipher,
	IntrusionAlert,
	RehackCooldown,
	PuzzleHardening
}
