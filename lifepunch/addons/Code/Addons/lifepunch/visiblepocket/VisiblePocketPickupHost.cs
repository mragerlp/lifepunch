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

/// <summary>
/// Policy-aware pocket pickup — mirrors DXRP <c>PocketSystem.PickupHost</c> with per-player caps.
/// </summary>
internal static class VisiblePocketPickupHost
{
	private static readonly object PickupLock = new();

	public static void TryPickup( Connection caller )
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

		var scene = PocketSystem.Instance.Scene ?? Game.ActiveScene;
		var trace = scene.Trace.Ray( player.AimRay, Config.Current.Game.ReachDistance )
			.IgnoreGameObjectHierarchy( PocketSystem.Instance.GameObject )
			.WithTag( Constants.EntityTag )
			.Run();

		if ( !trace.Hit )
		{
			return;
		}

		var pickupObj = trace.GameObject.Root;
		if ( !pickupObj.IsValid() )
		{
			return;
		}

		if ( pickupObj.Tags.Has( VisiblePocket.NoPocketTag ) )
		{
			player.Error( "#notify.pocket.forbidden" );
			return;
		}

		if ( !pickupObj.Tags.Has( Constants.PocketItemTag ) || !GameUtils.HasPermission( caller, pickupObj ) )
		{
			player.Error( "#notify.pocket.forbidden" );
			return;
		}

		var pockets = PocketSystemAccessor.GetPockets();
		if ( pockets == null )
		{
			return;
		}

		if ( !pockets.TryGetValue( player.SteamId, out var pocket ) )
		{
			pocket = new List<GameObject>();
			pockets[player.SteamId] = pocket;
		}

		var policyMax = VisiblePocketPolicyStore.GetMaxSlots( player );
		if ( pocket.Count >= policyMax )
		{
			player.Error( "#notify.pocket.full" );
			return;
		}

		lock ( PickupLock )
		{
			if ( !pickupObj.Tags.Has( Constants.PocketTag ) )
			{
				pickupObj.Network.DropOwnership();
				pickupObj.Tags.Add( Constants.PocketTag );
				pickupObj.OnPlayerInteractHost( player );
			}
			else
			{
				return;
			}
		}

		pocket.Add( pickupObj );
		pickupObj.Enabled = false;
		pickupObj.Network.Refresh();

		PocketSystem.Instance.SyncPocketCount( player, pocket.Count );
		VisiblePocketService.PushHudState( player );

		var pickupName = pickupObj.Name.StartsWith( '#' )
			? Language.GetPhrase( pickupObj.Name[1..] )
			: pickupObj.Name;
		_ = ServerApiClient.Audit( "PocketPickup", $"{player.SteamName} ({player.SteamId}) pocketed {pickupName}", player.SteamId );
		player.Success( string.Format( Language.GetPhrase( "notify.pocket.pickup" ), pickupName ) );
	}
}
#endif
