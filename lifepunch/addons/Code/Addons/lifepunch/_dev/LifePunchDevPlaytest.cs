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
	/// <summary>Canonical DXRP dev play scene — core prefab + dev plane, no hammer map.</summary>
	public const string DevPlayScenePath = "scenes/blank.scene";

	/// <summary>
	/// Reminder: Host Play from <see cref="DevPlayScenePath"/> (Editor → Assets/scenes/blank.scene).
	/// More minimal than flatgrass — no map load, faster boot, clean scale shots.
	/// </summary>
	[ConCmd( "lp_dev_scene" )]
	public static void DevSceneInfo()
	{
		Log.Info( $"LifePunch dev play: open {DevPlayScenePath} in the editor, then Host Play." );
		Log.Info( "  Ground = models/dev/plane.vmdl (100×100). Use lp_map_flatgrass only when you need hammer terrain." );
	}

	/// <summary>Legacy — swap game.scene map to flatgrass. Prefer Host Play from blank.scene instead.</summary>
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
			Log.Warning( $"lp_map_flatgrass: no MapInstance — you are probably on {DevPlayScenePath} already (preferred)." );
			return;
		}

		map.MapName = "facepunch.flatgrass";
		Log.Info( "lp_map_flatgrass: loading facepunch.flatgrass … (legacy; prefer blank.scene for dev)" );
	}
}
