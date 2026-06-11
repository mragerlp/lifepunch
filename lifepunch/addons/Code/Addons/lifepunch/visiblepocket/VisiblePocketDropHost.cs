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
using Dxura.RP.Game;
using Dxura.RP.Shared;
using Sandbox;

namespace LifePunch.DXRP.Addons.VisiblePocket;

internal static class VisiblePocketDropHost
{
	public static void TryDrop( Connection caller )
	{
		var callerId = caller.Id;
		if ( Cooldown.Current.CheckAndStartCooldown( $"{callerId}:pocket", Config.Current.Game.PocketCooldown ) )
		{
			return;
		}

		var player = GameUtils.GetPlayerByConnectionId( callerId );
		if ( !player.IsValid() )
		{
			return;
		}

		var pockets = PocketSystemAccessor.GetPockets();
		if ( pockets == null || !pockets.TryGetValue( player.SteamId, out var pocket ) || pocket.Count == 0 )
		{
			player.Error( "#notify.pocket.drop.nothing" );
			return;
		}

		var item = pocket[^1];
		if ( !item.IsValid() )
		{
			pocket.Remove( item );
			VisiblePocketService.PushHudState( player );
			return;
		}

		item.Tags.Remove( Constants.PocketTag );
		pocket.Remove( item );

		item.Enabled = true;
		item.WorldPosition = GameUtils.GetSpawnPosition( player.AimRay );

		var rb = item.GetComponent<Rigidbody>();
		if ( rb.IsValid() )
		{
			rb.MotionEnabled = true;
		}

		ResetItemDecay( item );

		item.Network.Refresh();
		item.Network.AssignOwnership( player.Connection );
		OcclusionSystem.Current?.BroadcastForceCheckHost( player.Connection );

		PocketSystem.Instance.SyncPocketCount( player, pocket.Count );
		VisiblePocketService.PushHudState( player );

		var itemName = item.Name.StartsWith( '#' ) ? Language.GetPhrase( item.Name[1..] ) : item.Name;
		_ = ServerApiClient.Audit( "PocketDrop", $"{player.SteamName} ({player.SteamId}) dropped from pocket {itemName}", player.SteamId );
		player.Success( string.Format( Language.GetPhrase( "notify.pocket.drop.success" ), itemName ) );
	}

	private static void ResetItemDecay( GameObject item )
	{
		var timedDestroy = item.GetComponent<TimedDestroy>( true );
		if ( timedDestroy.IsValid() )
		{
			timedDestroy.ResetTimer();
		}
	}
}
#endif
