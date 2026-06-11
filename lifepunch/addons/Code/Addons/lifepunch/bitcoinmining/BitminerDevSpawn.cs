// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Bitcoin Mining" (s&box ident: lifepunch.bitcoinmining · addon ident: bitcoinmining) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System.Linq;
using Sandbox;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
#endif

namespace LifePunch.DXRP.Addons.BitcoinMining;

/// <summary>
/// DEV / EDITOR-TEST ONLY — remove before portal publish.
/// Clones <see cref="Bitminer.WorldPrefabPath"/> in front of the local viewer for hashd / mining CLI tests.
/// </summary>
public static class BitminerDevSpawn
{
	private const float SpawnDistanceUnits = 120f;

	[ConCmd( "lp_spawn_bitminer" )]
	public static void SpawnBitminer()
	{
		if ( !TryGetSpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_spawn_bitminer: no local viewer (join play mode as a player first)." );
			return;
		}

		var prefab = GameObject.GetPrefab( Bitminer.WorldPrefabPath );
		if ( !prefab.IsValid() )
		{
			Log.Error( $"lp_spawn_bitminer: could not load '{Bitminer.WorldPrefabPath}'." );
			return;
		}

		var rig = prefab.Clone( new CloneConfig { Transform = transform } );
		if ( !rig.IsValid() )
		{
			Log.Error( "lp_spawn_bitminer: clone failed." );
			return;
		}

#if !LIFEPUNCH_LOCAL
		var player = Player.Local;
		if ( player.IsValid() )
			rig.NetworkSpawn( player.Network.Owner );
		else
			rig.NetworkSpawn();
#endif

		Log.Info( $"lp_spawn_bitminer: rig at {rig.WorldPosition}. Stand within 8m and run hashd or mine." );
	}

	private static bool TryGetSpawnTransform( out Transform transform )
	{
#if LIFEPUNCH_LOCAL
		var scene = Game.ActiveScene;
		var camera = scene?.GetAllComponents<CameraComponent>().FirstOrDefault();
		if ( !camera.IsValid() )
		{
			transform = default;
			return false;
		}

		var forward = camera.WorldRotation.Forward.WithZ( 0 ).Normal;
		if ( forward.Length < 0.01f )
			forward = Vector3.Forward;

		transform = new Transform(
			camera.WorldPosition + forward * SpawnDistanceUnits,
			Rotation.LookAt( forward ) );
		return true;
#else
		var player = Player.Local;
		if ( !player.IsValid() || !player.Controller.IsValid() )
		{
			transform = default;
			return false;
		}

		var aim = player.Controller.EyeAngles.ToRotation();
		var flatForward = aim.Forward.WithZ( 0 ).Normal;
		if ( flatForward.Length < 0.01f )
			flatForward = Vector3.Forward;

		transform = new Transform(
			player.WorldPosition + flatForward * SpawnDistanceUnits,
			Rotation.LookAt( flatForward ) );
		return true;
#endif
	}
}
