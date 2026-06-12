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

/// Opens a terminal <strong>login session</strong> at the nearest powered CRT.

/// Does not execute hack commands — those run only inside the ops console prompt.

/// See <c>docs/TERMINAL_SESSION_DOCTRINE.md</c>.

/// </summary>

internal static class HackerCommandHost

{

#if LIFEPUNCH_LOCAL
	/// <summary>Dev smoke — log into cornerman.exe at nearest CRT. Players USE the terminal.</summary>
	[ConCmd( "cornerman" )]
	public static void CornermanConCmd( string args = "" ) => HandleLoginCommand( HackerTerminalTier.Standard, args );

	/// <summary>Dev smoke — log into vengeance.exe at nearest Advanced CRT.</summary>
	[ConCmd( "vengeance" )]
	public static void VengeanceConCmd( string args = "" ) => HandleLoginCommand( HackerTerminalTier.Advanced, args );
#endif



	private static void HandleLoginCommand( HackerTerminalTier tier, string args )

	{

		if ( IsCloseRequest( args ) )

		{

			HackerTerminalHost.CloseOpen();

			Log.Info( "[terminal] session closed." );

			return;

		}



		var scene = Sandbox.Game.ActiveScene;

		if ( scene is null )

			return;



		var viewerPos = HackerTerminalHost.LocalViewerPosition( scene );

		if ( !viewerPos.HasValue )

		{

			Log.Info( "[terminal] No local player — join play mode first." );

			return;

		}



		var nearest = FindNearestTerminal( scene, viewerPos.Value, tier );

		if ( !nearest.IsValid() )

		{

			var label = tier == HackerTerminalTier.Advanced ? "Advanced Hacking Terminal" : "Hacker Terminal";

			Log.Info( $"[terminal] No powered {label} in range (6m). USE the CRT to log in." );

			return;

		}



		if ( !nearest.IsPowered )

		{

			Log.Info( "[terminal] Offline — power ON the Server Rack first." );

			return;

		}



		nearest.RequestOpenTerminal();

	}



	private static bool IsCloseRequest( string args )

	{

		var trimmed = ( args ?? "" ).Trim();

		return trimmed.Equals( "close", StringComparison.OrdinalIgnoreCase );

	}



	private static HackerTerminalEntity FindNearestTerminal( Scene scene, Vector3 viewerPos, HackerTerminalTier tier )

	{

		HackerTerminalEntity best = null;

		var bestHorizontal = float.MaxValue;



		foreach ( var terminal in scene.GetAllComponents<HackerTerminalEntity>() )

		{

			if ( !terminal.IsValid() || !terminal.GameObject.IsValid() )

				continue;



			if ( terminal.Tier != tier )

				continue;



			if ( !HackerTerminalRange.IsInOpenRange( viewerPos, terminal.WorldPosition ) )

				continue;



			var delta = terminal.WorldPosition - viewerPos;

			var horizontal = new Vector3( delta.x, delta.y, 0f ).Length;

			if ( horizontal < bestHorizontal )

			{

				bestHorizontal = horizontal;

				best = terminal;

			}

		}



		return best;

	}

}


