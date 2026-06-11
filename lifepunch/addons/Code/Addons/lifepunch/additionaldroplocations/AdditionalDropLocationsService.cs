// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Additional Drop Locations" (s&box ident: lifepunch.additionaldroplocations · addon ident: additionaldroplocations) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

#if !LIFEPUNCH_LOCAL
using System.Collections.Generic;
using Dxura.RP.Game;
using Dxura.RP.Game.Addons;
using Sandbox;

namespace LifePunch.DXRP.Addons.AdditionalDropLocations;

/// <summary>
/// Spawns extra DXRP <c>drug_drop</c> sell triggers when the map fitting completes.
/// Drop-in via <see cref="AddonServiceAttribute"/> — no DXRP core edits.
/// Economy-touching (uses gamemode DrugDrop payout path) — Opus review before live ship.
/// </summary>
[AddonService]
public sealed class AdditionalDropLocationsService : SingletonComponent<AdditionalDropLocationsService>, IGameEvents
{
	private readonly List<GameObject> _spawnedDrops = new();

	void IGameEvents.OnMapFitted()
	{
		if ( !Networking.IsHost )
		{
			return;
		}

		ClearSpawned();

		var mapIdent = ResolveMapIdent();
		var spawned = 0;

		foreach ( var site in AdditionalDropLocations.Sites )
		{
			if ( !site.Enabled )
			{
				continue;
			}

			if ( !MapMatches( site.MapIdent, mapIdent ) )
			{
				continue;
			}

			if ( !TrySpawnDrugDrop( site, out var drop ) )
			{
				continue;
			}

			_spawnedDrops.Add( drop );
			spawned++;
		}

		if ( spawned > 0 )
		{
			Log.Info( $"[AdditionalDropLocations] Spawned {spawned} drug drop(s) on map '{mapIdent}'." );
		}
	}

	private static string ResolveMapIdent()
	{
		var mapInstance = Scene.Components.GetAll<MapInstance>( FindMode.EverythingInSelfAndDescendants ).FirstOrDefault();
		if ( mapInstance.IsValid() && !string.IsNullOrWhiteSpace( mapInstance.MapName ) )
		{
			return mapInstance.MapName;
		}

		return string.Empty;
	}

	private static bool MapMatches( string siteMap, string currentMap )
	{
		if ( string.IsNullOrWhiteSpace( siteMap ) || siteMap == "*" )
		{
			return true;
		}

		return string.Equals( siteMap, currentMap, System.StringComparison.OrdinalIgnoreCase );
	}

	private static bool TrySpawnDrugDrop( DropSite site, out GameObject drop )
	{
		drop = default;

		var prefab = PrefabFile.Load( AdditionalDropLocations.DrugDropPrefabPath );
		if ( prefab == null )
		{
			Log.Warning( $"[AdditionalDropLocations] Missing prefab: {AdditionalDropLocations.DrugDropPrefabPath}" );
			return false;
		}

		var scene = SceneUtility.GetPrefabScene( prefab );
		if ( scene == null )
		{
			Log.Warning( $"[AdditionalDropLocations] Failed to load prefab scene: {AdditionalDropLocations.DrugDropPrefabPath}" );
			return false;
		}

		drop = scene.Clone();
		if ( !drop.IsValid() )
		{
			Log.Warning( $"[AdditionalDropLocations] Failed to clone drug drop for site '{site.Ident}'." );
			return false;
		}

		drop.Name = $"DrugDrop ({site.Label})";
		drop.WorldPosition = site.Position;
		drop.WorldRotation = site.Rotation;
		drop.NetworkSpawn();

		return true;
	}

	private void ClearSpawned()
	{
		foreach ( var go in _spawnedDrops )
		{
			if ( go.IsValid() )
			{
				go.Destroy();
			}
		}

		_spawnedDrops.Clear();
	}
}
#endif
