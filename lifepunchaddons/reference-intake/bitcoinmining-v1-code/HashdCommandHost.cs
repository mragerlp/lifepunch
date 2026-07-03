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
using System.Linq;
using Sandbox;
using LifePunch.DXRP.Addons;

namespace LifePunch.DXRP.Addons.BitcoinMining;

/// <summary>
/// Dev-only hashd open shim for local/editor builds. Players USE the Bitcoin Miner hub — see
/// <c>docs/BITCOINMINING_TERMINAL_DOCTRINE.md</c>.
/// </summary>
internal static class HashdCommandHost
{
#if LIFEPUNCH_LOCAL
	[ConCmd( "hashd" )]
	public static void HashdConCmd( string args = "" ) => HandleOpenCommand( args );

	[ConCmd( "mine" )]
	public static void MineConCmd( string args = "" ) => HandleOpenCommand( args );
#endif

	private static void HandleOpenCommand( string args )
	{
		if ( IsCloseRequest( args ) )
		{
			HashdTerminalHost.CloseOpen();
			return;
		}

		OpenNearestHub();
	}

	/// <summary>Shared dev open path for <c>hashd</c> and <c>lp_hashd_preview</c>.</summary>
	public static void OpenNearestHub()
	{
		var scene = Sandbox.Game.ActiveScene;
		if ( scene is null )
			return;

		var viewerPos = HashdTerminalHost.LocalViewerPosition( scene );
		if ( !viewerPos.HasValue )
			return;

		var hub = FindNearestHub( scene, viewerPos.Value, poweredOnly: true );
		if ( hub.IsValid() )
		{
			hub.RequestOpenHashd();
			return;
		}

		var offlineHub = FindNearestHub( scene, viewerPos.Value, poweredOnly: false );
		if ( offlineHub.IsValid() && !offlineHub.IsPowered )
		{
			offlineHub.RequestOpenPowerGate();
			return;
		}

		NotifyNoHubInRange();
	}

	private static bool IsCloseRequest( string args )
	{
		var trimmed = ( args ?? "" ).Trim();
		return trimmed.Equals( "close", StringComparison.OrdinalIgnoreCase );
	}

	private static BitcoinMinerHubEntity FindNearestHub( Scene scene, Vector3 viewerPos, bool poweredOnly )
	{
		BitcoinMinerHubEntity best = null;
		var bestHorizontal = float.MaxValue;

		foreach ( var hub in scene.GetAllComponents<BitcoinMinerHubEntity>() )
		{
			if ( !hub.IsValid() )
				continue;

			if ( poweredOnly && !hub.IsPowered )
				continue;

			if ( !LifePunchMenuInteractRange.IsInOpenRange( viewerPos, hub.WorldPosition, out var horizontal ) )
				continue;

			if ( horizontal < bestHorizontal )
			{
				bestHorizontal = horizontal;
				best = hub;
			}
		}

		return best;
	}

	private static void NotifyNoHubInRange()
	{
		Log.Info( "[hashd] No Bitcoin Miner hub in range — USE the hub to open the terminal." );
	}
}
