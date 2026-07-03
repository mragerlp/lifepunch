// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Advanced Drug Processing" (s&box ident: lifepunch.advanceddrugprocessing · addon ident: advanceddrugprocessing) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Author account: mrragerlp · Public alias (in-game · Steam · Discord): Bloodwave
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System.Linq;
using Sandbox;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
#endif

namespace LifePunch.DXRP.Addons.AdvancedDrugProcessing;

/// <summary>DEV ONLY — remove before portal publish.</summary>
public static class MethLabDevSpawn
{
	private const float SpawnDistanceUnits = 120f;

	[ConCmd( "lp_spawn_methlab" )]
	public static void SpawnMethLab()
	{
		if ( !TryGetSpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_spawn_methlab: no local viewer." );
			return;
		}

		var lab = CloneWorldPrefab( transform );
		if ( !lab.IsValid() )
			return;

		var entity = lab.Components.Get<MethLabEntity>( FindMode.EverythingInSelfAndDescendants );
		if ( !entity.IsValid() )
		{
			Log.Error( "lp_spawn_methlab: prefab missing MethLabEntity — wire component in editor." );
			lab.Destroy();
			return;
		}

#if !LIFEPUNCH_LOCAL
		var player = Player.Local;
		if ( player.IsValid() )
			lab.NetworkSpawn( player.Network.Owner );
		else
			lab.NetworkSpawn();
#endif

		Log.Info( $"lp_spawn_methlab: lab at {lab.WorldPosition}. Run lp_meth_fill then Use." );
	}

	[ConCmd( "lp_meth_fill" )]
	public static void FillNearestLab()
	{
		var lab = FindNearestLab();
		if ( !lab.IsValid() )
		{
			Log.Warning( "lp_meth_fill: no meth lab in scene." );
			return;
		}

		lab.DevFillIngredients();
		Log.Info( "lp_meth_fill: reagents loaded on nearest lab." );
	}

	[ConCmd( "lp_meth_status" )]
	public static void MethStatus()
	{
		var labs = Game.ActiveScene?.GetAllComponents<MethLabEntity>().ToArray() ?? [];
		var summary = string.Join( "; ", labs.Select( l => $"{l.Stage}@{l.WorldPosition}" ) );
		Log.Info( $"METH_TEST labs={labs.Length} {summary}" );
	}

	private static MethLabEntity FindNearestLab()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
			return null;

		var viewer = GetViewerPosition( scene );
		return scene.GetAllComponents<MethLabEntity>()
			.OrderBy( l => ( l.WorldPosition - viewer ).Length )
			.FirstOrDefault();
	}

	private static Vector3 GetViewerPosition( Scene scene )
	{
#if !LIFEPUNCH_LOCAL
		if ( Player.Local.IsValid() )
			return Player.Local.WorldPosition;
#endif
		var camera = scene.GetAllComponents<CameraComponent>().FirstOrDefault();
		return camera.IsValid() ? camera.WorldPosition : Vector3.Zero;
	}

	private static GameObject CloneWorldPrefab( Transform transform )
	{
#if LIFEPUNCH_LOCAL
		var prefab = GameObject.GetPrefab( AdvancedDrugProcessing.WorldPrefabPath );
		if ( !prefab.IsValid() )
		{
			Log.Error( $"lp_spawn_methlab: could not load '{AdvancedDrugProcessing.WorldPrefabPath}'." );
			return default;
		}

		return prefab.Clone( new CloneConfig { Transform = transform } );
#else
		var prefabFile = PrefabFile.Load( AdvancedDrugProcessing.WorldPrefabPath );
		if ( prefabFile == null )
		{
			Log.Error( $"lp_spawn_methlab: PrefabFile.Load failed '{AdvancedDrugProcessing.WorldPrefabPath}'." );
			return default;
		}

		var prefabScene = SceneUtility.GetPrefabScene( prefabFile );
		if ( prefabScene == null )
			return default;

		var lab = prefabScene.Clone();
		if ( !lab.IsValid() )
			return default;

		lab.WorldTransform = transform;
		return lab;
#endif
	}

	private static bool TryGetSpawnTransform( out Transform transform )
	{
#if LIFEPUNCH_LOCAL
		return TryGetCameraSpawn( Game.ActiveScene, out transform );
#else
		var player = Player.Local;
		if ( player.IsValid() )
		{
			var aim = player.Controller.IsValid()
				? player.Controller.EyeAngles.ToRotation()
				: player.WorldRotation;
			var forward = aim.Forward.WithZ( 0 ).Normal;
			if ( forward.Length < 0.01f )
				forward = Vector3.Forward;

			transform = new Transform(
				player.WorldPosition + forward * SpawnDistanceUnits,
				Rotation.LookAt( forward ) );
			return true;
		}

		return TryGetCameraSpawn( Game.ActiveScene, out transform );
#endif
	}

	private static bool TryGetCameraSpawn( Scene scene, out Transform transform )
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
}
