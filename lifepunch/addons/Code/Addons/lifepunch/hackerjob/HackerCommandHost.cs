// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Hacker Job" (s&box ident: lifepunch.hackerjob · addon ident: hackerjob) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System;
using System.Linq;
using Sandbox;

namespace LifePunch.DXRP.Addons.HackerJob;

/// <summary>
/// Console entry points for the Hacker Terminal (Phase 1 shell).
/// Opens <c>cornerman.exe</c> on the nearest <see cref="HackerTerminalEntity"/> within range.
/// </summary>
internal static class HackerCommandHost
{
	private const float MetersToUnits = 39.3701f;
	private const float OpenHorizontalUnits = 6f * MetersToUnits;
	private const float OpenVerticalUnits = 3f * MetersToUnits;

	[ConCmd( "cornerman" )]
	public static void CornermanConCmd( string args = "" ) => HandleOpenCommand( args );

	[ConCmd( "hack" )]
	public static void HackConCmd( string args = "" ) => HandleOpenCommand( args );

	private static void HandleOpenCommand( string args )
	{
		if ( IsCloseRequest( args ) )
		{
			HackerTerminalHost.CloseOpen();
			return;
		}

		var scene = Sandbox.Game.ActiveScene;
		if ( scene is null )
			return;

		var viewerPos = HackerTerminalHost.LocalViewerPosition( scene );
		if ( !viewerPos.HasValue )
			return;

		var nearest = FindNearestTerminal( scene, viewerPos.Value );
		if ( !nearest.IsValid() )
		{
			Log.Info( "[cornerman] No Hacker Terminal in range." );
			return;
		}

		if ( !nearest.IsPowered )
		{
			Log.Info( "[cornerman] Terminal offline — power ON the Server Rack first." );
			return;
		}

		nearest.RequestOpenTerminal();
	}

	private static bool IsCloseRequest( string args )
	{
		var trimmed = ( args ?? "" ).Trim();
		return trimmed.Equals( "close", StringComparison.OrdinalIgnoreCase );
	}

	private static HackerTerminalEntity FindNearestTerminal( Scene scene, Vector3 viewerPos )
	{
		HackerTerminalEntity best = null;
		var bestHorizontal = float.MaxValue;

		foreach ( var terminal in scene.GetAllComponents<HackerTerminalEntity>() )
		{
			if ( !terminal.IsValid() || !terminal.GameObject.IsValid() )
				continue;

			var delta = terminal.WorldPosition - viewerPos;
			var horizontal = new Vector3( delta.x, delta.y, 0f ).Length;
			var vertical = MathF.Abs( delta.z );

			if ( horizontal > OpenHorizontalUnits || vertical > OpenVerticalUnits )
				continue;

			if ( horizontal < bestHorizontal )
			{
				bestHorizontal = horizontal;
				best = terminal;
			}
		}

		return best;
	}
}
