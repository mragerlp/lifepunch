// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LifePunch Dev Tools" (s&box ident: lifepunch.dev · addon ident: dev) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Author account: mrragerlp · Public alias (in-game · Steam · Discord): Bloodwave
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System.Linq;
using Sandbox;

namespace LifePunch.DXRP.Addons.Dev;

/// <summary>
/// Shared dev ConCmds used across multiple LifePunch addon playtest lanes.
/// </summary>
public static class LifePunchDevPlaytest
{
	/// <summary>Swap active map to flatgrass for scale/playtest clarity (no downtown clutter).</summary>
	[ConCmd( "lp_map_flatgrass" )]
	public static void MapFlatgrass()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_map_flatgrass: no active scene." );
			return;
		}

		var map = scene.GetAllComponents<MapInstance>().FirstOrDefault();
		if ( !map.IsValid() )
		{
			Log.Warning( "lp_map_flatgrass: no MapInstance in scene." );
			return;
		}

		map.MapName = "facepunch.flatgrass";
		Log.Info( "lp_map_flatgrass: loading facepunch.flatgrass …" );
	}
}
