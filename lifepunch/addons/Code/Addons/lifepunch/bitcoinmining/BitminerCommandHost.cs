// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Bitcoin Mining" (s&box ident: lifepunch.bitcoinmining · addon ident: bitcoinmining) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System;
using System.Linq;
using Sandbox;

namespace LifePunch.DXRP.Addons.BitcoinMining;

/// <summary>
/// Console/chat entry points for the LIFEPUNCH hashd terminal (Phase 1).
/// Opens the CLI on the nearest <see cref="BitminerEntity"/> within range.
/// </summary>
internal static class BitminerCommandHost
{
	// Source units ≈ inches; ~8 m horizontal / ~4 m vertical open range.
	private const float MetersToUnits = 39.3701f;
	private const float OpenHorizontalUnits = 8f * MetersToUnits;
	private const float OpenVerticalUnits = 4f * MetersToUnits;

	[ConCmd( "hashd" )]
	public static void HashdConCmd( string args = "" ) => HandleOpenCommand( args );

	[ConCmd( "mine" )]
	public static void MineConCmd( string args = "" ) => HandleOpenCommand( args );

	private static void HandleOpenCommand( string args )
	{
		if ( IsCloseRequest( args ) )
		{
			BitminerTerminalHost.CloseOpen();
			return;
		}

		var scene = Sandbox.Game.ActiveScene;
		if ( scene is null )
			return;

		var viewerPos = BitminerTerminalHost.LocalViewerPosition( scene );
		if ( !viewerPos.HasValue )
			return;

		var nearest = FindNearestRig( scene, viewerPos.Value );
		if ( !nearest.IsValid() )
		{
			NotifyNoRigInRange();
			return;
		}

		nearest.RequestOpenTerminal();
	}

	private static bool IsCloseRequest( string args )
	{
		var trimmed = ( args ?? "" ).Trim();
		return trimmed.Equals( "close", StringComparison.OrdinalIgnoreCase );
	}

	private static BitminerEntity FindNearestRig( Scene scene, Vector3 viewerPos )
	{
		BitminerEntity best = null;
		var bestHorizontal = float.MaxValue;

		foreach ( var rig in scene.GetAllComponents<BitminerEntity>() )
		{
			if ( !rig.IsValid() || !rig.GameObject.IsValid() )
				continue;

			var delta = rig.WorldPosition - viewerPos;
			var horizontal = new Vector3( delta.x, delta.y, 0f ).Length;
			var vertical = MathF.Abs( delta.z );

			if ( horizontal > OpenHorizontalUnits || vertical > OpenVerticalUnits )
				continue;

			if ( horizontal < bestHorizontal )
			{
				bestHorizontal = horizontal;
				best = rig;
			}
		}

		return best;
	}

	private static void NotifyNoRigInRange()
	{
		Log.Info( "[hashd] No Bitcoin Miner rig in range." );
	}
}
