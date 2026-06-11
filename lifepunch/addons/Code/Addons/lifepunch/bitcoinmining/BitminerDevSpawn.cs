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

		var rig = CloneWorldPrefab( transform );
		if ( !rig.IsValid() )
			return;

		var entity = rig.Components.Get<BitminerEntity>( FindMode.EverythingInSelfAndDescendants );
		if ( !entity.IsValid() )
		{
			Log.Error( "lp_spawn_bitminer: clone has no BitminerEntity — prefab may be stale." );
			rig.Destroy();
			return;
		}

#if !LIFEPUNCH_LOCAL
		var player = Player.Local;
		if ( player.IsValid() )
			rig.NetworkSpawn( player.Network.Owner );
		else
			rig.NetworkSpawn();
#endif

		Log.Info( $"lp_spawn_bitminer: rig at {rig.WorldPosition} (entity ok). Stand within 8m and run hashd or mine." );
	}

	private static GameObject CloneWorldPrefab( Transform transform )
	{
#if LIFEPUNCH_LOCAL
		var prefab = GameObject.GetPrefab( Bitminer.WorldPrefabPath );
		if ( !prefab.IsValid() )
		{
			Log.Error( $"lp_spawn_bitminer: could not load '{Bitminer.WorldPrefabPath}'." );
			return default;
		}

		return prefab.Clone( new CloneConfig { Transform = transform } );
#else
		var prefabFile = PrefabFile.Load( Bitminer.WorldPrefabPath );
		if ( prefabFile == null )
		{
			Log.Error( $"lp_spawn_bitminer: PrefabFile.Load failed '{Bitminer.WorldPrefabPath}'." );
			return default;
		}

		var prefabScene = SceneUtility.GetPrefabScene( prefabFile );
		if ( prefabScene == null )
		{
			Log.Error( $"lp_spawn_bitminer: GetPrefabScene failed '{Bitminer.WorldPrefabPath}'." );
			return default;
		}

		var rig = prefabScene.Clone();
		if ( !rig.IsValid() )
		{
			Log.Error( "lp_spawn_bitminer: scene clone failed." );
			return default;
		}

		rig.WorldTransform = transform;
		return rig;
#endif
	}

	[ConCmd( "lp_bitminer_count" )]
	public static void CountBitminers()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_bitminer_count: no active scene." );
			return;
		}

		var rigs = scene.GetAllComponents<BitminerEntity>().ToArray();
		var positions = string.Join( "; ", rigs.Select( r => r.WorldPosition.ToString() ) );
		Log.Info( $"BITMINER_TEST rigs={rigs.Length} pos={positions}" );
	}

	private static bool TryGetCameraSpawnTransform( Scene scene, out Transform transform )
	{
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
	}

	private static bool TryGetSpawnTransform( out Transform transform )
	{
#if LIFEPUNCH_LOCAL
		return TryGetCameraSpawnTransform( Game.ActiveScene, out transform );
#else
		var player = Player.Local;
		if ( player.IsValid() )
		{
			var aim = player.Controller.IsValid()
				? player.Controller.EyeAngles.ToRotation()
				: player.WorldRotation;
			var flatForward = aim.Forward.WithZ( 0 ).Normal;
			if ( flatForward.Length < 0.01f )
				flatForward = Vector3.Forward;

			transform = new Transform(
				player.WorldPosition + flatForward * SpawnDistanceUnits,
				Rotation.LookAt( flatForward ) );
			return true;
		}

		// Editor play before DXRP spawns a pawn — same camera fallback as LIFEPUNCH_LOCAL.
		return TryGetCameraSpawnTransform( Game.ActiveScene, out transform );
#endif
	}
}
