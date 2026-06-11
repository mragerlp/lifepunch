// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Visible Pocket for DXRP" (s&box ident: lifepunch.visiblepocket · addon ident: visiblepocket) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
using Dxura.RP.Game.Addons;
using Sandbox;

namespace LifePunch.DXRP.Addons.VisiblePocket;

/// <summary>
/// Drop-in policy service for Visible Pocket. P1: dev commands + policy resolution only.
/// Per-player slot enforcement blocked on DXRP global <c>MaxPocketItems</c> — see POCKET-01.
/// </summary>
[AddonService]
public sealed class VisiblePocketService : SingletonComponent<VisiblePocketService>
{
	public static int ResolveLocalPolicyMax()
	{
		var player = Player.Local;
		if ( !player.IsValid() )
		{
			return PocketSlotPolicy.DefaultSlots;
		}

		var rankName = RankSystem.Instance.IsValid()
			? RankSystem.Instance.GetRankName( player.SteamId )
			: string.Empty;

		return PocketSlotPolicy.ResolveMaxSlots( (long)player.WalletBalance, rankName );
	}

	public static void LogPolicyStatus()
	{
		var player = Player.Local;
		if ( !player.IsValid() )
		{
			Log.Warning( "[VisiblePocket] No local player." );
			return;
		}

		var rankName = RankSystem.Instance.IsValid()
			? RankSystem.Instance.GetRankName( player.SteamId )
			: "(no RankSystem)";
		var policyMax = PocketSlotPolicy.ResolveMaxSlots( (long)player.WalletBalance, rankName );
		var globalMax = Config.Current.Game.MaxPocketItems;
		var count = PocketSystem.LocalPocketCount;

		Log.Info( $"[VisiblePocket] rank='{rankName}' wallet=${player.WalletBalance:N0} policyMax={policyMax} dxrpGlobalMax={globalMax} pocketCount={count}" );

		if ( policyMax > globalMax )
		{
			Log.Warning( "[VisiblePocket] policyMax > dxrpGlobalMax — run lp_pocket_apply_dev on host to test tier pickup." );
		}
	}

	/// <summary>Dev-only: sync global DXRP cap to local player's policy max (all players share cap).</summary>
	public static bool TryApplyDevGlobalMax()
	{
		if ( !Networking.IsHost )
		{
			Log.Warning( "[VisiblePocket] lp_pocket_apply_dev requires host." );
			return false;
		}

		var policyMax = ResolveLocalPolicyMax();
		Config.Current.Game.MaxPocketItems = policyMax;
		Log.Info( $"[VisiblePocket] DEV: MaxPocketItems set to {policyMax} (global — not per-player)." );
		return true;
	}
}
#endif
