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
using System.Collections.Generic;
using System.Linq;
using Dxura.RP.Game;
using Dxura.RP.Game.Addons;
using Dxura.RP.Shared;
using Sandbox;

namespace LifePunch.DXRP.Addons.VisiblePocket;

/// <summary>
/// LifePunch Visible Pocket — per-player slot policy + hotbar HUD on DXRP <see cref="PocketSystem"/>.
/// </summary>
[AddonService]
public sealed class VisiblePocketService : SingletonComponent<VisiblePocketService>, IGameEvents
{
	protected override void OnStart()
	{
		if ( !Config.Current.Game.PocketEnabled )
		{
			Destroy();
			return;
		}

		if ( Networking.IsHost )
		{
			Config.Current.Game.MaxPocketItems = PocketSlotPolicy.MaxTierSlots;
		}

		GameObject.AddComponent<VisiblePocketInputBridge>();
		VisiblePocketHudHost.Mount();
	}

	void IGameEvents.OnPlayerJoined( Player player )
	{
		if ( !Networking.IsHost || !player.IsValid() )
		{
			return;
		}

		VisiblePocketPolicyStore.Refresh( player );
		PushHudState( player );
	}

	void IGameEvents.OnPlayerKillHost( Player player ) => PushHudState( player );

	void IGameEvents.OnPlayerJobChangedHost( Player player, GameModeJobDto before, GameModeJobDto after ) =>
		PushHudState( player );

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
		var count = PocketSystem.LocalPocketCount;

		Log.Info( $"[VisiblePocket] rank='{rankName}' wallet=${player.WalletBalance:N0} policyMax={policyMax} pocketCount={count}" );
	}

	/// <summary>Dev-only: sync global DXRP cap to local player's policy max (legacy test).</summary>
	public static bool TryApplyDevGlobalMax()
	{
		if ( !Networking.IsHost )
		{
			Log.Warning( "[VisiblePocket] lp_pocket_apply_dev requires host." );
			return false;
		}

		var policyMax = ResolveLocalPolicyMax();
		Config.Current.Game.MaxPocketItems = policyMax;
		Log.Info( $"[VisiblePocket] DEV: MaxPocketItems set to {policyMax} (global — legacy)." );
		return true;
	}

	public static void RequestPickup()
	{
		if ( Instance.IsValid() )
		{
			Instance.PickupHost();
		}
	}

	public static void RequestDrop()
	{
		if ( Instance.IsValid() )
		{
			Instance.DropHost();
		}
	}

	public static void RequestHudRefresh()
	{
		if ( Instance.IsValid() )
		{
			Instance.RefreshHudHost();
		}
	}

	[Rpc.Host]
	private void PickupHost()
	{
		VisiblePocketPickupHost.TryPickup( Rpc.Caller );
	}

	[Rpc.Host]
	private void DropHost()
	{
		VisiblePocketDropHost.TryDrop( Rpc.Caller );
	}

	[Rpc.Host]
	private void RefreshHudHost()
	{
		var player = GameUtils.GetPlayerByConnectionId( Rpc.CallerId );
		if ( player.IsValid() )
		{
			VisiblePocketPolicyStore.Refresh( player );
			PushHudState( player );
		}
	}

	public static void PushHudState( Player player )
	{
		if ( !Networking.IsHost || !player.IsValid() )
		{
			return;
		}

		var max = VisiblePocketPolicyStore.Refresh( player );
		var items = PocketSystemAccessor.GetItems( player.SteamId );
		var labels = new List<string>();

		foreach ( var item in items )
		{
			if ( !item.IsValid() )
			{
				continue;
			}

			var name = item.Name.StartsWith( '#' ) ? Language.GetPhrase( item.Name[1..] ) : item.Name;
			labels.Add( TrimLabel( name ) );
		}

		using ( Rpc.FilterInclude( c => c.Id == player.ConnectionId ) )
		{
			ApplyHudState( max, labels.Count, labels.ToArray() );
		}
	}

	[Rpc.Broadcast( NetFlags.HostOnly | NetFlags.Reliable )]
	private static void ApplyHudState( int maxSlots, int count, string[] labels )
	{
		VisiblePocketHudState.Apply( maxSlots, count, labels );
	}

	private static string TrimLabel( string name )
	{
		if ( string.IsNullOrWhiteSpace( name ) )
		{
			return "item";
		}

		return name.Length <= 10 ? name : name[..10];
	}
}
#endif
