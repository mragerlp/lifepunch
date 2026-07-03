// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Visible Pocket for DXRP" (s&box ident: lifepunch.visiblepocket · addon ident: visiblepocket) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Author account: mrragerlp · Public alias (in-game · Steam · Discord): Bloodwave
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System;

namespace LifePunch.DXRP.Addons.VisiblePocket;

/// <summary>
/// Slot tiers from <c>VISIBLE_POCKET_SPEC.md</c>. Rank floors stack with cash unlocks (take higher).
/// </summary>
public static class PocketSlotPolicy
{
	public const int DefaultSlots = 6;
	public const int VipSlots = 8;
	public const int EvipSlots = 12;
	public const int MaxTierSlots = 15;

	public const string VipRankName = "VIP";
	public const string EvipRankName = "EVIP";

	public static readonly (long MinCash, int Slots)[] CashTiers =
	[
		(100_000, 8),
		(250_000, 10),
		(500_000, 12),
		(1_000_000, 15),
	];

	public static int ResolveMaxSlots( long walletBalance, string rankName )
	{
		var max = DefaultSlots;

		foreach ( var tier in CashTiers )
		{
			if ( walletBalance >= tier.MinCash )
			{
				max = Math.Max( max, tier.Slots );
			}
		}

		if ( string.Equals( rankName, EvipRankName, StringComparison.OrdinalIgnoreCase ) )
		{
			max = Math.Max( max, EvipSlots );
		}
		else if ( string.Equals( rankName, VipRankName, StringComparison.OrdinalIgnoreCase ) )
		{
			max = Math.Max( max, VipSlots );
		}

		return max;
	}
}
