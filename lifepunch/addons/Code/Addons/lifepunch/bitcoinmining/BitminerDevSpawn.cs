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
	private const float GroundTraceUp = 2000f;
	private const float GroundTraceDown = 20000f;

	/// <summary>Default dev spawn — GPU rack + separate hashd CRT terminal (linked on start).</summary>
	[ConCmd( "lp_spawn_bitminer" )]
	public static void SpawnBitminer() => SpawnBitminerKit();

	/// <summary>Dev smoke — spawn linked kit and open hashd immediately (CRT mesh optional).</summary>
	[ConCmd( "lp_hashd_preview" )]
	public static void HashdPreview()
	{
		var entity = SpawnBitminerKit();
		if ( !entity.IsValid() )
			return;

		// Dev preview — open UI directly (skip RPC host + 8m range search).
		BitminerTerminal.Open( entity );
	}

	[ConCmd( "lp_spawn_bitminer_kit" )]
	public static BitminerEntity SpawnBitminerKit()
	{
		if ( !TryGetSpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_spawn_bitminer: no local viewer (join play mode as a player first)." );
			return null;
		}

		var rig = ClonePrefabAt( Bitminer.WorldPrefabPath, transform );
		if ( !rig.IsValid() )
			return null;

		var entity = rig.Components.Get<BitminerEntity>( FindMode.EverythingInSelfAndDescendants );
		if ( !entity.IsValid() )
		{
			Log.Error( "lp_spawn_bitminer: clone has no BitminerEntity — prefab may be stale." );
			rig.Destroy();
			return null;
		}

		var terminalPos = SnapToGround(
			Game.ActiveScene,
			transform.Position + transform.Rotation.Right * 120f + transform.Rotation.Forward * 40f );
		var terminalTransform = new Transform( terminalPos, transform.Rotation );
		var terminal = ClonePrefabAt( Bitminer.TerminalPrefabPath, terminalTransform );
		if ( terminal.IsValid() )
		{
			var prop = terminal.Components.Get<BitminerTerminalProp>( FindMode.EverythingInSelfAndDescendants );
			if ( prop.IsValid() )
				prop.LinkedRig = entity;
		}

#if !LIFEPUNCH_LOCAL
		var player = Player.Local;
		if ( player.IsValid() )
		{
			rig.NetworkSpawn( player.Network.Owner );
			if ( terminal.IsValid() )
				terminal.NetworkSpawn( player.Network.Owner );
		}
		else
		{
			rig.NetworkSpawn();
			if ( terminal.IsValid() )
				terminal.NetworkSpawn();
		}
#endif

		Log.Info( "lp_spawn_bitminer: gpu-rack + bitcoin-terminal placed. Use hashd on rig or USE the CRT." );
		return entity;
	}

	[ConCmd( "lp_spawn_advanced_bitminer" )]
	public static void SpawnAdvancedBitminer()
	{
		if ( !TryGetSpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_spawn_advanced_bitminer: no local viewer." );
			return;
		}

		var rig = ClonePrefabAt( Bitminer.AdvancedPrefabPath, transform );
		if ( !rig.IsValid() )
			return;

#if !LIFEPUNCH_LOCAL
		var player = Player.Local;
		if ( player.IsValid() )
			rig.NetworkSpawn( player.Network.Owner );
		else
			rig.NetworkSpawn();
#endif

		Log.Info( "lp_spawn_advanced_bitminer: stacked gpu-rack placed (2× yield)." );
	}

	/// <summary>All three entities — terminal + small rack + advanced rack.</summary>
	[ConCmd( "lp_spawn_bitminer_full_kit" )]
	public static void SpawnBitminerFullKit()
	{
		if ( !TryGetSpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_spawn_bitminer_full_kit: no local viewer." );
			return;
		}

		var small = ClonePrefabAt( Bitminer.WorldPrefabPath, transform );
		if ( !small.IsValid() )
			return;

		var scene = Game.ActiveScene;
		var advancedPos = SnapToGround( scene, transform.Position + transform.Rotation.Right * -160f );
		var advanced = ClonePrefabAt( Bitminer.AdvancedPrefabPath, new Transform( advancedPos, transform.Rotation ) );

		var terminalPos = SnapToGround(
			scene,
			transform.Position + transform.Rotation.Right * 120f + transform.Rotation.Forward * 40f );
		var terminal = ClonePrefabAt( Bitminer.TerminalPrefabPath, new Transform( terminalPos, transform.Rotation ) );

		var smallEntity = small.Components.Get<BitminerEntity>( FindMode.EverythingInSelfAndDescendants );
		if ( terminal.IsValid() && smallEntity.IsValid() )
		{
			var prop = terminal.Components.Get<BitminerTerminalProp>( FindMode.EverythingInSelfAndDescendants );
			if ( prop.IsValid() )
				prop.LinkedRig = smallEntity;
		}

#if !LIFEPUNCH_LOCAL
		var player = Player.Local;
		if ( player.IsValid() )
		{
			small.NetworkSpawn( player.Network.Owner );
			if ( advanced.IsValid() )
				advanced.NetworkSpawn( player.Network.Owner );
			if ( terminal.IsValid() )
				terminal.NetworkSpawn( player.Network.Owner );
		}
		else
		{
			small.NetworkSpawn();
			if ( advanced.IsValid() )
				advanced.NetworkSpawn();
			if ( terminal.IsValid() )
				terminal.NetworkSpawn();
		}
#endif

		Log.Info( "lp_spawn_bitminer_full_kit: terminal + small + advanced racks placed." );
	}

	[ConCmd( "lp_spawn_bitcoin_terminal" )]
	public static void SpawnBitcoinTerminal()
	{
		if ( !TryGetSpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_spawn_bitcoin_terminal: no local viewer." );
			return;
		}

		var terminal = ClonePrefabAt( Bitminer.TerminalPrefabPath, transform );
		if ( !terminal.IsValid() )
			return;

#if !LIFEPUNCH_LOCAL
		var player = Player.Local;
		if ( player.IsValid() )
			terminal.NetworkSpawn( player.Network.Owner );
		else
			terminal.NetworkSpawn();
#endif

		Log.Info( "lp_spawn_bitcoin_terminal: CRT placed — auto-links to nearest rig within 4m." );
	}

	private static GameObject ClonePrefabAt( string prefabPath, Transform transform )
	{
#if LIFEPUNCH_LOCAL
		var prefab = GameObject.GetPrefab( prefabPath );
		if ( !prefab.IsValid() )
		{
			Log.Error( $"bitminer spawn: could not load '{prefabPath}'." );
			return default;
		}

		return prefab.Clone( new CloneConfig { Transform = transform } );
#else
		var prefabFile = PrefabFile.Load( prefabPath );
		if ( prefabFile == null )
		{
			Log.Error( $"bitminer spawn: PrefabFile.Load failed '{prefabPath}'." );
			return default;
		}

		var prefabScene = SceneUtility.GetPrefabScene( prefabFile );
		if ( prefabScene == null )
		{
			Log.Error( $"bitminer spawn: GetPrefabScene failed '{prefabPath}'." );
			return default;
		}

		var clone = prefabScene.Clone();
		if ( !clone.IsValid() )
		{
			Log.Error( "bitminer spawn: scene clone failed." );
			return default;
		}

		clone.WorldTransform = transform;
		return clone;
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

	/// <summary>Range + link diagnostics (replaces broken bridge __Exec_*.cs snippets).</summary>
	[ConCmd( "lp_bitminer_debug" )]
	public static void DebugBitminers()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_bitminer_debug: no active scene — enter play mode on a map, not a prefab stage." );
			return;
		}

		var viewer = BitminerTerminalHost.LocalViewerPosition( scene );
		if ( !viewer.HasValue )
		{
			Log.Warning( "lp_bitminer_debug: no viewer (join as player or use editor camera in play)." );
			return;
		}

		Log.Info( $"BITMINER_DEBUG viewer={viewer.Value}" );

		var rigs = scene.GetAllComponents<BitminerEntity>().ToArray();
		Log.Info( $"BITMINER_DEBUG rigs={rigs.Length} terminals={scene.GetAllComponents<BitminerTerminalProp>().Count()}" );

		foreach ( var rig in rigs )
		{
			if ( !rig.IsValid() )
				continue;

			var delta = rig.WorldPosition - viewer.Value;
			var horizontal = new Vector3( delta.x, delta.y, 0f ).Length;
			var vertical = MathF.Abs( delta.z );
			var inHashdRange = horizontal <= 8f * 39.3701f && vertical <= 4f * 39.3701f;
			Log.Info(
				$"BITMINER_DEBUG rig={rig.GameObject.Name} advanced={rig.AdvancedRack} pos={rig.WorldPosition} horiz={horizontal:0} vert={vertical:0} hashd_ok={inHashdRange}" );
		}

		foreach ( var prop in scene.GetAllComponents<BitminerTerminalProp>() )
		{
			if ( !prop.IsValid() )
				continue;

			var linked = prop.LinkedRig.IsValid() ? prop.LinkedRig.GameObject.Name : "(none)";
			Log.Info( $"BITMINER_DEBUG terminal={prop.GameObject.Name} pos={prop.WorldPosition} linked={linked}" );
		}

		if ( rigs.Length == 0 )
			Log.Warning( "BITMINER_DEBUG no rigs — run lp_spawn_bitminer or lp_hashd_preview (prefab editor stage has no runtime entities)." );
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

		var position = SnapToGround( scene, camera.WorldPosition + forward * SpawnDistanceUnits );
		transform = new Transform( position, Rotation.LookAt( forward ) );
		return true;
	}

	private static bool TryGetSpawnTransform( out Transform transform )
	{
#if LIFEPUNCH_LOCAL
		return TryGetCameraSpawnTransform( Game.ActiveScene, out transform );
#else
		var scene = Game.ActiveScene;
		var player = Player.Local;
		if ( player.IsValid() )
		{
			var aim = player.Controller.IsValid()
				? player.Controller.EyeAngles.ToRotation()
				: player.WorldRotation;
			var flatForward = aim.Forward.WithZ( 0 ).Normal;
			if ( flatForward.Length < 0.01f )
				flatForward = Vector3.Forward;

			var position = SnapToGround( scene, player.WorldPosition + flatForward * SpawnDistanceUnits );
			transform = new Transform( position, Rotation.LookAt( flatForward ) );
			return true;
		}

		// Editor play before DXRP spawns a pawn — same camera fallback as LIFEPUNCH_LOCAL.
		return TryGetCameraSpawnTransform( scene, out transform );
#endif
	}

	/// <summary>
	/// Drop a horizontal spawn point to the nearest world surface below (sidewalk, not fountain water).
	/// </summary>
	private static Vector3 SnapToGround( Scene scene, Vector3 horizontalPoint )
	{
		if ( scene is null )
			return horizontalPoint;

		var start = horizontalPoint + Vector3.Up * GroundTraceUp;
		var end = horizontalPoint - Vector3.Up * GroundTraceDown;
		var trace = scene.Trace.Ray( start, end ).Run();

		return trace.Hit ? trace.HitPosition : horizontalPoint;
	}
}
