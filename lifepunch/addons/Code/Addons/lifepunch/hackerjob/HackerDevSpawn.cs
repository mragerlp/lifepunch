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
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
#endif

namespace LifePunch.DXRP.Addons.HackerJob;

/// <summary>
/// DEV / EDITOR-TEST ONLY — excluded from publish staging.
/// </summary>
public static class HackerDevSpawn
{
	private const float SpawnDistanceUnits = 120f;
	private const float GroundTraceUp = 2000f;
	private const float GroundTraceDown = 20000f;

	/// <summary>
	/// Opens cornerman.exe UI immediately — no prefab or world entity required (editor smoke test).
	/// </summary>
	[ConCmd( "lp_cornerman_ui" )]
	public static void OpenTerminalUi() => OpenTerminalUi( HackerTerminalTier.Standard );

	[ConCmd( "lp_vengeance_ui" )]
	public static void OpenAdvancedTerminalUi() => OpenTerminalUi( HackerTerminalTier.Advanced );

	private static void OpenTerminalUi( HackerTerminalTier tier )
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_cornerman_ui: no active scene." );
			return;
		}

		var stub = scene.CreateObject();
		stub.Name = tier == HackerTerminalTier.Advanced
			? "AdvancedHackerTerminalDevStub"
			: "HackerTerminalDevStub";
		var entity = stub.AddComponent<HackerTerminalEntity>();
		entity.Tier = tier;

		// Dev stub is local UI smoke — bypass RPC (unspawned GO would fail RequestOpenTerminal).
		if ( !HackerTerminal.Open( entity ) )
		{
			Log.Warning( tier == HackerTerminalTier.Advanced
				? "lp_vengeance_ui: failed — see [cornerman] errors above."
				: "lp_cornerman_ui: failed — see [cornerman] errors above." );
		}
	}

	[ConCmd( "lp_spawn_hacker_terminal" )]
	public static void SpawnTerminal() => SpawnTerminal( HackerTerminalTier.Standard );

	[ConCmd( "lp_spawn_advanced_hacker_terminal" )]
	public static void SpawnAdvancedTerminal() => SpawnTerminal( HackerTerminalTier.Advanced );

	/// <summary>Spawn standard CRT and open cornerman.exe immediately.</summary>
	[ConCmd( "lp_cornerman_preview" )]
	public static void CornermanPreview() => PreviewTerminal( HackerTerminalTier.Standard );

	/// <summary>Spawn advanced CRT and open vengeance.exe immediately.</summary>
	[ConCmd( "lp_vengeance_preview" )]
	public static void VengeancePreview() => PreviewTerminal( HackerTerminalTier.Advanced );

	[ConCmd( "lp_spawn_server_rack" )]
	public static void SpawnServerRack() => SpawnServerRackEntity( HackerJob.ServerRackWorldPrefabPath, powered: false );

	[ConCmd( "lp_spawn_advanced_server_rack" )]
	public static void SpawnAdvancedServerRack() =>
		SpawnServerRackEntity( HackerJob.AdvancedServerRackWorldPrefabPath, powered: false );

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

	/// <summary>Spawn powered basic + advanced racks with cornerman + vengeance terminals.</summary>
	[ConCmd( "lp_hacker_kit_preview" )]
	public static void HackerKitPreview()
	{
		if ( !TryGetSpawnTransform( out var transform ) )
		{
			Log.Warning( $"{HackerJob.DevHackerKitPreviewCommand}: no local viewer." );
			return;
		}

		var basicPos = transform.Position + transform.Rotation.Left * 120f;
		var advancedPos = transform.Position + transform.Rotation.Right * 120f;

		var basicRack = SpawnServerRackAt( HackerJob.ServerRackWorldPrefabPath, basicPos, transform.Rotation, powered: true );
		var advancedRack = SpawnServerRackAt( HackerJob.AdvancedServerRackWorldPrefabPath, advancedPos, transform.Rotation, powered: true );
		if ( !basicRack.IsValid() && !advancedRack.IsValid() )
			return;

		if ( basicRack.IsValid() )
			SpawnTerminalNear( HackerTerminalTier.Standard, basicRack.WorldPosition + Vector3.Forward * 80f );
		if ( advancedRack.IsValid() )
			SpawnTerminalNear( HackerTerminalTier.Advanced, advancedRack.WorldPosition + Vector3.Forward * 80f );

		Log.Info( $"{HackerJob.DevHackerKitPreviewCommand}: basic + advanced racks ON, cornerman + vengeance placed. Interact racks for upgrades." );
	}

	private static void PreviewTerminal( HackerTerminalTier tier )
	{
		var entity = SpawnTerminalEntity( tier );
		if ( !entity.IsValid() )
			return;

#if LIFEPUNCH_LOCAL
		HackerTerminal.Open( entity );
#else
		entity.RequestOpenTerminal();
#endif
	}

	private static HackerTerminalEntity SpawnTerminalEntity( HackerTerminalTier tier )
	{
		SpawnTerminal( tier );
		var scene = Game.ActiveScene;
		if ( scene is null )
			return null;

		HackerTerminalEntity best = null;
		var bestDist = float.MaxValue;
		var viewer = TryGetViewerPosition( scene );
		if ( !viewer.HasValue )
			return scene.GetAllComponents<HackerTerminalEntity>().LastOrDefault();

		foreach ( var entity in scene.GetAllComponents<HackerTerminalEntity>() )
		{
			if ( !entity.IsValid() || entity.Tier != tier )
				continue;

			var dist = ( entity.WorldPosition - viewer.Value ).Length;
			if ( dist < bestDist )
			{
				bestDist = dist;
				best = entity;
			}
		}

		return best;
	}

	private static Vector3? TryGetViewerPosition( Scene scene )
	{
#if LIFEPUNCH_LOCAL
		var camera = scene?.GetAllComponents<CameraComponent>().FirstOrDefault();
		return camera.IsValid() ? camera.WorldPosition : (Vector3?)null;
#else
		if ( Player.Local.IsValid() )
			return Player.Local.WorldPosition;

		var camera = scene?.GetAllComponents<CameraComponent>().FirstOrDefault();
		return camera.IsValid() ? camera.WorldPosition : (Vector3?)null;
#endif
	}

	private static HackerServerRackEntity SpawnServerRackEntity( string prefabPath, bool powered )
	{
		if ( !TryGetSpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_spawn_server_rack: no local viewer." );
			return null;
		}

		var rack = SpawnServerRackAt( prefabPath, transform.Position, transform.Rotation, powered );
		if ( rack.IsValid() )
			Log.Info( $"Rack placed at viewer (power={( powered ? "ON" : "OFF" )}) — {prefabPath}" );

		return rack;
	}

	private static HackerServerRackEntity SpawnServerRackAt( string prefabPath, Vector3 position, Rotation rotation, bool powered )
	{
		var rackGo = ClonePrefabAt( prefabPath, new Transform( position, rotation ) );
		if ( !rackGo.IsValid() )
			return null;

		var rack = rackGo.Components.Get<HackerServerRackEntity>( FindMode.EverythingInSelfAndDescendants );
		if ( rack.IsValid() )
			rack.IsPowered = powered;

#if !LIFEPUNCH_LOCAL
		var player = Player.Local;
		if ( player.IsValid() )
			rackGo.NetworkSpawn( player.Network.Owner );
		else
			rackGo.NetworkSpawn();
#endif

		return rack;
	}

	private static void SpawnTerminalNear( HackerTerminalTier tier, Vector3 position )
	{
		var prefabPath = tier == HackerTerminalTier.Advanced
			? HackerJob.AdvancedWorldPrefabPath
			: HackerJob.WorldPrefabPath;

		var forward = ( TryGetViewerPosition( Game.ActiveScene ) ?? position ) - position;
		forward = forward.WithZ( 0 ).Normal;
		if ( forward.Length < 0.01f )
			forward = Vector3.Forward;

		var grounded = SnapToGround( Game.ActiveScene, position );
		var terminal = ClonePrefabAt( prefabPath, new Transform( grounded, Rotation.LookAt( forward ) ) );
		if ( !terminal.IsValid() )
			return;

		var entity = terminal.Components.Get<HackerTerminalEntity>( FindMode.EverythingInSelfAndDescendants );
		if ( entity.IsValid() )
		{
			entity.Tier = tier;
			entity.RefreshScreenIdle();
		}

#if !LIFEPUNCH_LOCAL
		var player = Player.Local;
		if ( player.IsValid() )
			terminal.NetworkSpawn( player.Network.Owner );
		else
			terminal.NetworkSpawn();
#endif
	}

	private static void SpawnTerminal( HackerTerminalTier tier )
	{
		var command = tier == HackerTerminalTier.Advanced
			? HackerJob.DevAdvancedSpawnCommand
			: HackerJob.DevSpawnCommand;
		var prefabPath = tier == HackerTerminalTier.Advanced
			? HackerJob.AdvancedWorldPrefabPath
			: HackerJob.WorldPrefabPath;

		if ( !TryGetSpawnTransform( out var transform ) )
		{
			Log.Warning( $"{command}: no local viewer." );
			return;
		}

		var terminal = ClonePrefabAt( prefabPath, transform );
		if ( !terminal.IsValid() )
		{
			Log.Error( $"{command}: could not load or clone '{prefabPath}'. Recompile prefab in editor if missing prefab_c." );
			return;
		}

		var entity = terminal.Components.Get<HackerTerminalEntity>( FindMode.EverythingInSelfAndDescendants );
		if ( entity.IsValid() )
			entity.Tier = tier;

#if !LIFEPUNCH_LOCAL
		var player = Player.Local;
		if ( player.IsValid() )
			terminal.NetworkSpawn( player.Network.Owner );
		else
			terminal.NetworkSpawn();
#endif

		var program = tier == HackerTerminalTier.Advanced
			? HackerJob.AdvancedProgramName
			: HackerJob.InGameProgramName;
		Log.Info( $"{command}: placed ({program}). Stand within 6m and interact or use lp_cornerman_ui / lp_vengeance_ui." );
	}

	private static GameObject ClonePrefabAt( string prefabPath, Transform transform )
	{
#if LIFEPUNCH_LOCAL
		var prefab = GameObject.GetPrefab( prefabPath );
		if ( !prefab.IsValid() )
		{
			Log.Error( $"hackerjob spawn: could not load '{prefabPath}'." );
			return default;
		}

		return prefab.Clone( new CloneConfig { Transform = transform } );
#else
		var prefabFile = PrefabFile.Load( prefabPath );
		if ( prefabFile == null )
		{
			Log.Error( $"hackerjob spawn: PrefabFile.Load failed '{prefabPath}'." );
			return default;
		}

		var prefabScene = SceneUtility.GetPrefabScene( prefabFile );
		if ( prefabScene == null )
		{
			Log.Error( $"hackerjob spawn: GetPrefabScene failed '{prefabPath}'." );
			return default;
		}

		var clone = prefabScene.Clone();
		if ( !clone.IsValid() )
		{
			Log.Error( $"hackerjob spawn: scene clone failed '{prefabPath}'." );
			return default;
		}

		clone.WorldTransform = transform;
		return clone;
#endif
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

		var position = SnapToGround( scene, camera.WorldPosition + forward * SpawnDistanceUnits );
		transform = new Transform( position, Rotation.LookAt( forward ) );
		return true;
#else
		var scene = Game.ActiveScene;
		var player = Player.Local;
		if ( player.IsValid() && player.Controller.IsValid() )
		{
			var aim = player.Controller.EyeAngles.ToRotation();
			var flatForward = aim.Forward.WithZ( 0 ).Normal;
			if ( flatForward.Length < 0.01f )
				flatForward = Vector3.Forward;

			var position = SnapToGround( scene, player.WorldPosition + flatForward * SpawnDistanceUnits );
			transform = new Transform( position, Rotation.LookAt( flatForward ) );
			return true;
		}

		// Editor play before DXRP pawn — camera fallback with ground snap.
		var camera = scene?.GetAllComponents<CameraComponent>().FirstOrDefault();
		if ( !camera.IsValid() )
		{
			transform = default;
			return false;
		}

		var camForward = camera.WorldRotation.Forward.WithZ( 0 ).Normal;
		if ( camForward.Length < 0.01f )
			camForward = Vector3.Forward;

		var camPosition = SnapToGround( scene, camera.WorldPosition + camForward * SpawnDistanceUnits );
		transform = new Transform( camPosition, Rotation.LookAt( camForward ) );
		return true;
#endif
	}

	private static Vector3 SnapToGround( Scene scene, Vector3 horizontalPoint )
	{
		if ( scene is null )
			return horizontalPoint;

		try
		{
			var start = horizontalPoint + Vector3.Up * GroundTraceUp;
			var end = horizontalPoint - Vector3.Up * GroundTraceDown;
			var trace = scene.Trace.Ray( start, end ).Run();
			return trace.Hit ? trace.HitPosition : horizontalPoint;
		}
		catch ( Exception ex ) when ( ex.Message.Contains( "Default Surface", StringComparison.OrdinalIgnoreCase ) )
		{
			return horizontalPoint;
		}
	}
}
