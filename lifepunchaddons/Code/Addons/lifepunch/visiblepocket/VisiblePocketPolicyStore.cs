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

#if !LIFEPUNCH_LOCAL
using System.Collections.Generic;
using Dxura.RP.Game;
using Sandbox;

namespace LifePunch.DXRP.Addons.VisiblePocket;

/// <summary>Server-side per-player slot caps from wallet + rank policy.</summary>
internal static class VisiblePocketPolicyStore
{
	private static readonly Dictionary<long, int> MaxBySteamId = new();

	public static int GetMaxSlots( Player player )
	{
		if ( !player.IsValid() )
		{
			return PocketSlotPolicy.DefaultSlots;
		}

		if ( MaxBySteamId.TryGetValue( player.SteamId, out var cached ) )
		{
			return cached;
		}

		return Refresh( player );
	}

	public static int Refresh( Player player )
	{
		if ( !player.IsValid() )
		{
			return PocketSlotPolicy.DefaultSlots;
		}

		var rankName = RankSystem.Instance.IsValid()
			? RankSystem.Instance.GetRankName( player.SteamId )
			: string.Empty;

		var max = PocketSlotPolicy.ResolveMaxSlots( (long)player.WalletBalance, rankName );
		MaxBySteamId[player.SteamId] = max;
		return max;
	}

	public static void Remove( long steamId ) => MaxBySteamId.Remove( steamId );
}
#endif
