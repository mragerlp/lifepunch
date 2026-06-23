// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "lifepunchulx" (s&box ident: lifepunch.lifepunchulx · addon ident: lifepunchulx) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Author account: mrragerlp · Public alias (in-game · Steam · Discord): Bloodwave
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

#if !LIFEPUNCH_LOCAL
using System;
using System.Linq;
using System.Threading.Tasks;
using Dxura.RP.Game;
using Dxura.RP.Game.Addons;
using Dxura.RP.Shared;
using Sandbox;

namespace LifePunch.DXRP.Addons.StaffMenu;

/// <summary>
/// Self-contained host bridge for the admin menu's Waypoints list — DROP-IN, no DXRP core edits required.
///
/// The waypoint store is host/token-scoped (<see cref="ServerApiClient"/> needs the server authorization
/// key), so the client-side menu can't read it directly. This component is auto-attached to the networked
/// core root on every peer by DXRP's <c>AddonServiceRegistry</c> (via <see cref="AddonServiceAttribute"/>),
/// giving the addon its OWN host RPC: the client asks the host, the host reads its per-server store and
/// returns the names to just the calling client (mirrors the ForceScreenshot filtered round-trip).
///
/// Server-agnostic by construction: each server reads its own token-scoped store, so every owner sees their
/// own waypoints with zero config — and because it lives entirely in the addon, it works on any DXRP server
/// the addon is dropped into without modifying <c>AdminSystem</c> or anything else in core.
/// </summary>
[AddonService]
public sealed class WaypointSyncService : SingletonComponent<WaypointSyncService>
{
	// Must match Dxura.RP.Game.Commands.WaypointCommand.StorePrefix so we read exactly what /waypoint writes.
	private const string WaypointStorePrefix = "commands:waypoint:";

	/// <summary>
	/// Client→host request for the saved waypoint names. Re-validates <see cref="Permission.CommandWaypointUse"/>
	/// host-side (the menu's UI gating is cosmetic only), then reads + returns asynchronously.
	/// </summary>
	[Rpc.Host]
	public void RequestWaypointsHost()
	{
		var caller = Rpc.Caller;
		if ( !RankSystem.HasPermission( caller.SteamId, Permission.CommandWaypointUse ) )
		{
			return;
		}

		_ = SendWaypointsToCaller( caller );
	}

	private async Task SendWaypointsToCaller( Connection connection )
	{
		var entries = await ServerApiClient.ListStore( WaypointStorePrefix );

		var names = entries
			.Select( entry => entry.Key.StartsWith( WaypointStorePrefix, StringComparison.OrdinalIgnoreCase )
				? entry.Key[WaypointStorePrefix.Length..]
				: null )
			.Where( name => !string.IsNullOrWhiteSpace( name ) )
			.Select( name => name! )
			.OrderBy( name => name, StringComparer.OrdinalIgnoreCase )
			.ToArray();

		await GameTask.MainThread();

		// A stale connection (caller disconnected mid-read) simply matches nothing here — safe no-op.
		using ( Rpc.FilterInclude( c => c == connection ) )
		{
			ReceiveWaypointsClient( names );
		}
	}

	[Rpc.Broadcast( NetFlags.HostOnly | NetFlags.Reliable )]
	private void ReceiveWaypointsClient( string[] names )
	{
		StaffMenuHost.OnWaypointsReceived( names );
	}
}
#endif
