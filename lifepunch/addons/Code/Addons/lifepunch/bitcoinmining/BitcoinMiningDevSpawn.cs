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
using LifePunch.DXRP.Addons;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
#endif

namespace LifePunch.DXRP.Addons.BitcoinMining;

/// <summary>
/// DEV / EDITOR-TEST ONLY — excluded from publish staging (<c>*DevSpawn.cs</c>).
/// Clones <see cref="BitcoinMiningAddon.WorldPrefabPath"/> in front of the local viewer for hashd / mining CLI tests.
/// </summary>
public static class BitcoinMiningDevSpawn
{
	private const float SpawnDistanceUnits = 120f;
	private const float GroundTraceUp = 2000f;
	private const float GroundTraceDown = 20000f;

	/// <summary>Default dev spawn — GPU rack + separate hashd CRT terminal (linked on start).</summary>
	[ConCmd( "lp_spawn_gpu_rack" )]
	public static void SpawnBitcoinMiningAddon() => SpawnBitcoinMiningAddonKit();

	/// <summary>Hub + 3 small racks + 1 large rack (owner canon layout).</summary>
	[ConCmd( "lp_spawn_bitcoin_miner_hub" )]
	public static BitcoinMinerHubEntity SpawnBitcoinMinerHub()
	{
		if ( !TryGetSpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_spawn_bitcoin_miner_hub: no local viewer." );
			return null;
		}

		var scene = Game.ActiveScene;
		var hubPos = SnapToGround( scene, transform.Position );
		var hubGo = ClonePrefabAt( BitcoinMiningAddon.HubPrefabPath, new Transform( hubPos, transform.Rotation ) );
		if ( !hubGo.IsValid() )
		{
			Log.Warning( "lp_spawn_bitcoin_miner_hub: hub prefab missing — compile ModelDoc + prefab first." );
			return null;
		}

		var hub = hubGo.Components.Get<BitcoinMinerHubEntity>( FindMode.EverythingInSelfAndDescendants );
		if ( !hub.IsValid() )
		{
			Log.Error( "lp_spawn_bitcoin_miner_hub: clone has no BitcoinMinerHubEntity." );
			hubGo.Destroy();
			return null;
		}

		var offsets = new[]
		{
			transform.Rotation.Right * 140f,
			transform.Rotation.Right * -140f,
			transform.Rotation.Forward * 140f
		};

		for ( var i = 0; i < offsets.Length; i++ )
		{
			var pos = SnapToGround( scene, transform.Position + offsets[i] );
			var rack = ClonePrefabAt( BitcoinMiningAddon.WorldPrefabPath, new Transform( pos, transform.Rotation ) );
			NetworkSpawnIfNeeded( rack );
		}

		var largePos = SnapToGround( scene, transform.Position + transform.Rotation.Forward * -160f );
		var large = ClonePrefabAt( BitcoinMiningAddon.AdvancedPrefabPath, new Transform( largePos, transform.Rotation ) );
		NetworkSpawnIfNeeded( large );

		NetworkSpawnIfNeeded( hubGo );

		Log.Info( "lp_spawn_bitcoin_miner_hub: hub OFFLINE — USE hub → click POWER ON on rail. lp_hub_power 1 to skip boot." );
		return hub;
	}

	/// <summary>Hub prefab only — no linked racks (model/scale pass).</summary>
	[ConCmd( "lp_spawn_bitcoin_miner_hub_only" )]
	public static BitcoinMinerHubEntity SpawnBitcoinMinerHubOnly()
	{
		if ( !TryGetSpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_spawn_bitcoin_miner_hub_only: no local viewer." );
			return null;
		}

		var scene = Game.ActiveScene;
		var hubPos = SnapToGround( scene, transform.Position );
		var hubGo = ClonePrefabAt( BitcoinMiningAddon.HubPrefabPath, new Transform( hubPos, transform.Rotation ) );
		if ( !hubGo.IsValid() )
		{
			Log.Warning( "lp_spawn_bitcoin_miner_hub_only: hub prefab missing — compile ModelDoc + prefab first." );
			return null;
		}

		var hub = hubGo.Components.Get<BitcoinMinerHubEntity>( FindMode.EverythingInSelfAndDescendants );
		if ( !hub.IsValid() )
		{
			Log.Error( "lp_spawn_bitcoin_miner_hub_only: clone has no BitcoinMinerHubEntity." );
			hubGo.Destroy();
			return null;
		}

		NetworkSpawnIfNeeded( hubGo );
		Log.Info( "lp_spawn_bitcoin_miner_hub_only: Ophion hub placed (no racks)." );
		return hub;
	}

	/// <summary>Remove LifePunch dev-spawned bitcoinmining entities in the active scene.</summary>
	[ConCmd( "lp_clear_bitcoinmining_spawns" )]
	public static void ClearBitcoinMiningSpawns()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_clear_bitcoinmining_spawns: no active scene." );
			return;
		}

		var destroyed = 0;
		foreach ( var hub in scene.GetAllComponents<BitcoinMinerHubEntity>().ToArray() )
		{
			if ( hub.IsValid() && hub.GameObject.IsValid() )
			{
				hub.GameObject.Destroy();
				destroyed++;
			}
		}

		foreach ( var rig in scene.GetAllComponents<GpuRackEntity>().ToArray() )
		{
			if ( rig.IsValid() && rig.GameObject.IsValid() )
			{
				rig.GameObject.Destroy();
				destroyed++;
			}
		}

		foreach ( var term in scene.GetAllComponents<BitcoinTerminalProp>().ToArray() )
		{
			if ( term.IsValid() && term.GameObject.IsValid() )
			{
				term.GameObject.Destroy();
				destroyed++;
			}
		}

		Log.Info( $"lp_clear_bitcoinmining_spawns: removed {destroyed} object(s)." );
	}

	[ConCmd( "lp_hub_power" )]
	public static void HubPower( string arg = "1" )
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_hub_power: no active scene." );
			return;
		}

		var hub = scene.GetAllComponents<BitcoinMinerHubEntity>().FirstOrDefault( h => h.IsValid() );
		if ( !hub.IsValid() )
		{
			Log.Warning( "lp_hub_power: no hub — run lp_spawn_bitcoin_miner_hub first." );
			return;
		}

		var powered = arg.Trim() is not ( "0" or "off" or "false" );
		hub.RequestSetPowered( powered );
		Log.Info( $"lp_hub_power: hub {( powered ? "ON" : "OFF" )}." );
	}

	/// <summary>Dev smoke — spawn hub + racks and open hashd from the hub.</summary>
	[ConCmd( "lp_hashd_preview" )]
	public static void HashdPreview()
	{
		var hub = SpawnBitcoinMinerHub();
		if ( !hub.IsValid() )
			return;

		hub.RequestSetPowered( true );
		hub.RequestOpenHashd();
	}

	/// <summary>Dev smoke — ghost-console PIN gate. Modes: unlock (default), setup, blocked.</summary>
	[ConCmd( "lp_hashd_pin_preview" )]
	public static void HashdPinPreview( string mode = "unlock" )
	{
		var hub = SpawnBitcoinMinerHub();
		if ( !hub.IsValid() )
			return;

		switch ( mode.Trim().ToLowerInvariant() )
		{
			case "setup":
				HashdTerminal.OpenHubPinSetup( hub );
				Log.Info( "lp_hashd_pin_preview: GATEKEEPER SET PIN — spawner registers first PIN." );
				break;
			case "blocked":
				HashdTerminal.OpenHubPinBlocked( hub );
				Log.Info( "lp_hashd_pin_preview: GATEKEEPER LOCKED — non-spawner view (no input)." );
				break;
			default:
				HashdTerminal.OpenHubPinUnlock( hub );
				Log.Info( "lp_hashd_pin_preview: GATEKEEPER ENTER PIN — ghost console behind veil." );
				break;
		}
	}

	[ConCmd( "lp_spawn_gpu_rack_kit" )]
	public static GpuRackEntity SpawnBitcoinMiningAddonKit()
	{
		if ( !TryGetSpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_spawn_gpu_rack: no local viewer (join play mode as a player first)." );
			return null;
		}

		var rig = ClonePrefabAt( BitcoinMiningAddon.WorldPrefabPath, transform );
		if ( !rig.IsValid() )
			return null;

		var entity = rig.Components.Get<GpuRackEntity>( FindMode.EverythingInSelfAndDescendants );
		if ( !entity.IsValid() )
		{
			Log.Error( "lp_spawn_gpu_rack: clone has no GpuRackEntity — prefab may be stale." );
			rig.Destroy();
			return null;
		}

		var terminalPos = SnapToGround(
			Game.ActiveScene,
			transform.Position + transform.Rotation.Right * 120f + transform.Rotation.Forward * 40f );
		var terminalTransform = new Transform( terminalPos, transform.Rotation );
		var terminal = ClonePrefabAt( BitcoinMiningAddon.TerminalPrefabPath, terminalTransform );
		if ( terminal.IsValid() )
		{
			var prop = terminal.Components.Get<BitcoinTerminalProp>( FindMode.EverythingInSelfAndDescendants );
			if ( prop.IsValid() )
				prop.LinkedRig = entity;
		}

		NetworkSpawnIfNeeded( rig );
		NetworkSpawnIfNeeded( terminal );

		Log.Info( "lp_spawn_gpu_rack: gpu-rack + CRT kit placed. Link racks to a Bitcoin Miner hub — USE the hub." );
		return entity;
	}

	[ConCmd( "lp_spawn_large_gpu_rack" )]
	public static void SpawnAdvancedBitcoinMiningAddon()
	{
		if ( !TryGetSpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_spawn_large_gpu_rack: no local viewer." );
			return;
		}

		var rig = ClonePrefabAt( BitcoinMiningAddon.AdvancedPrefabPath, transform );
		if ( !rig.IsValid() )
			return;

#if !LIFEPUNCH_LOCAL
		var player = Player.Local;
		if ( player.IsValid() )
			rig.NetworkSpawn( player.Network.Owner );
		else
			rig.NetworkSpawn();
#endif

		Log.Info( "lp_spawn_large_gpu_rack: stacked gpu-rack placed (2× yield)." );
	}

	/// <summary>All three entities — terminal + small rack + advanced rack.</summary>
	[ConCmd( "lp_spawn_bitcoinmining_full_kit" )]
	public static void SpawnBitcoinMiningAddonFullKit()
	{
		if ( !TryGetSpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_spawn_bitcoinmining_full_kit: no local viewer." );
			return;
		}

		var small = ClonePrefabAt( BitcoinMiningAddon.WorldPrefabPath, transform );
		if ( !small.IsValid() )
			return;

		var scene = Game.ActiveScene;
		var advancedPos = SnapToGround( scene, transform.Position + transform.Rotation.Right * -160f );
		var advanced = ClonePrefabAt( BitcoinMiningAddon.AdvancedPrefabPath, new Transform( advancedPos, transform.Rotation ) );

		var terminalPos = SnapToGround(
			scene,
			transform.Position + transform.Rotation.Right * 120f + transform.Rotation.Forward * 40f );
		var terminal = ClonePrefabAt( BitcoinMiningAddon.TerminalPrefabPath, new Transform( terminalPos, transform.Rotation ) );

		var smallEntity = small.Components.Get<GpuRackEntity>( FindMode.EverythingInSelfAndDescendants );
		if ( terminal.IsValid() && smallEntity.IsValid() )
		{
			var prop = terminal.Components.Get<BitcoinTerminalProp>( FindMode.EverythingInSelfAndDescendants );
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

		Log.Info( "lp_spawn_bitcoinmining_full_kit: terminal + small + advanced racks placed." );
	}

	[ConCmd( "lp_spawn_bitcoin_terminal" )]
	public static void SpawnBitcoinTerminal()
	{
		if ( !TryGetSpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_spawn_bitcoin_terminal: no local viewer." );
			return;
		}

		var terminal = ClonePrefabAt( BitcoinMiningAddon.TerminalPrefabPath, transform );
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

	private static void NetworkSpawnIfNeeded( GameObject go )
	{
		if ( !go.IsValid() )
			return;

#if !LIFEPUNCH_LOCAL
		var player = Player.Local;
		if ( player.IsValid() )
		{
			var owned = go.Components.Get<BitcoinMinerHubEntity>( FindMode.EverythingInSelfAndDescendants );
			if ( owned.IsValid() )
				owned.Owner = player.SteamId;

			go.NetworkSpawn( player.Network.Owner );
		}
		else
		{
			go.NetworkSpawn();
		}
#endif
	}

	private static GameObject ClonePrefabAt( string prefabPath, Transform transform )
	{
#if LIFEPUNCH_LOCAL
		var prefab = GameObject.GetPrefab( prefabPath );
		if ( !prefab.IsValid() )
		{
			Log.Error( $"gpu-rack spawn: could not load '{prefabPath}'." );
			return default;
		}

		return prefab.Clone( new CloneConfig { Transform = transform } );
#else
		var prefabFile = PrefabFile.Load( prefabPath );
		if ( prefabFile == null )
		{
			Log.Error( $"gpu-rack spawn: PrefabFile.Load failed '{prefabPath}'." );
			return default;
		}

		var prefabScene = SceneUtility.GetPrefabScene( prefabFile );
		if ( prefabScene == null )
		{
			Log.Error( $"gpu-rack spawn: GetPrefabScene failed '{prefabPath}'." );
			return default;
		}

		var clone = prefabScene.Clone();
		if ( !clone.IsValid() )
		{
			Log.Error( "gpu-rack spawn: scene clone failed." );
			return default;
		}

		clone.WorldTransform = transform;
		return clone;
#endif
	}

	[ConCmd( "lp_gpu_rack_count" )]
	public static void CountBitcoinMiningAddons()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_gpu_rack_count: no active scene." );
			return;
		}

		var rigs = scene.GetAllComponents<GpuRackEntity>().ToArray();
		var positions = string.Join( "; ", rigs.Select( r => r.WorldPosition.ToString() ) );
		Log.Info( $"BITCOINMINING_TEST rigs={rigs.Length} pos={positions}" );
	}

	/// <summary>Hub, rig, hashd UI, and link diagnostics (replaces MCP execute_csharp snippets).</summary>
	[ConCmd( "lp_bitcoinmining_debug" )]
	[ConCmd( "lp_gpu_rack_debug" )]
	[ConCmd( "lp_hashd_debug" )]
	public static void DebugBitcoinMiningAddons()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_gpu_rack_debug: no active scene — enter play mode on a map, not a prefab stage." );
			return;
		}

		var viewer = HashdTerminalHost.LocalViewerPosition( scene );
		if ( !viewer.HasValue )
		{
			Log.Warning( "lp_gpu_rack_debug: no viewer (join as player or use editor camera in play)." );
			return;
		}

		Log.Info( $"BITCOINMINING_DEBUG viewer={viewer.Value}" );
		Log.Info( $"BITCOINMINING_DEBUG hashd_open={HashdTerminalHost.IsOpen}" );

		var hubs = scene.GetAllComponents<BitcoinMinerHubEntity>().ToArray();
		Log.Info( $"BITCOINMINING_DEBUG hubs={hubs.Length}" );
		foreach ( var hub in hubs )
		{
			if ( !hub.IsValid() )
				continue;

			var linked = BitcoinMinerHubRegistry.GetLinkedRacks( hub ).Count();
			Log.Info(
				$"BITCOINMINING_DEBUG hub={hub.GameObject.Name} owner={hub.Owner} powered={hub.IsPowered} btc={hub.BitcoinAmount:F8} linked_racks={linked}" );
		}

		var rigs = scene.GetAllComponents<GpuRackEntity>().ToArray();
		Log.Info( $"BITCOINMINING_DEBUG rigs={rigs.Length} terminals={scene.GetAllComponents<BitcoinTerminalProp>().Count()}" );

		foreach ( var rig in rigs )
		{
			if ( !rig.IsValid() )
				continue;

			var delta = rig.WorldPosition - viewer.Value;
			var horizontal = new Vector3( delta.x, delta.y, 0f ).Length;
			var vertical = MathF.Abs( delta.z );
			var inHashdRange = LifePunchMenuInteractRange.IsInOpenRange( viewer.Value, rig.WorldPosition );
			Log.Info(
				$"BITCOINMINING_DEBUG rig={rig.GameObject.Name} advanced={rig.AdvancedRack} pos={rig.WorldPosition} horiz={horizontal:0} vert={vertical:0} hashd_ok={inHashdRange}" );
		}

		foreach ( var prop in scene.GetAllComponents<BitcoinTerminalProp>() )
		{
			if ( !prop.IsValid() )
				continue;

			var linked = prop.LinkedRig.IsValid() ? prop.LinkedRig.GameObject.Name : "(none)";
			Log.Info( $"BITCOINMINING_DEBUG terminal={prop.GameObject.Name} pos={prop.WorldPosition} linked={linked}" );
		}

		if ( rigs.Length == 0 )
			Log.Warning( "BITCOINMINING_DEBUG no rigs — run lp_spawn_gpu_rack or lp_hashd_preview (prefab editor stage has no runtime entities)." );
	}


	/// <summary>
	/// Logs mesh bounds + BoxCollider scale for hub / small rack / large rack (MODEL_SCALE_DOCTRINE flatgrass pass).
	/// Spawns a fresh row when any type is missing.
	/// </summary>
	[ConCmd( "lp_bitcoinmining_scale_audit" )]
	public static void ScaleAudit()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_bitcoinmining_scale_audit: no active scene — play on a map, not a prefab stage." );
			return;
		}

		if ( !TryGetSpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_bitcoinmining_scale_audit: no local viewer." );
			return;
		}

		var hub = scene.GetAllComponents<BitcoinMinerHubEntity>().FirstOrDefault( h => h.IsValid() );
		var smallRacks = scene.GetAllComponents<GpuRackEntity>()
			.Where( r => r.IsValid() && !r.AdvancedRack )
			.ToArray();
		var largeRacks = scene.GetAllComponents<GpuRackEntity>()
			.Where( r => r.IsValid() && r.AdvancedRack )
			.ToArray();

		if ( !hub.IsValid() || smallRacks.Length == 0 || largeRacks.Length == 0 )
		{
			Log.Info( "lp_bitcoinmining_scale_audit: spawning hub + racks for measurement …" );
			SpawnBitcoinMinerHub();
			hub = scene.GetAllComponents<BitcoinMinerHubEntity>().FirstOrDefault( h => h.IsValid() );
			smallRacks = scene.GetAllComponents<GpuRackEntity>().Where( r => r.IsValid() && !r.AdvancedRack ).ToArray();
			largeRacks = scene.GetAllComponents<GpuRackEntity>().Where( r => r.IsValid() && r.AdvancedRack ).ToArray();
		}

		Log.Info( "BITCOINMINING_SCALE_AUDIT begin (mesh=ModelRenderer bounds; collider=BoxCollider.Scale)" );
		if ( hub.IsValid() )
			LogScaleRow( "hub", hub.GameObject );
		else
			Log.Warning( "BITCOINMINING_SCALE_AUDIT hub missing" );

		if ( smallRacks.Length > 0 )
			LogScaleRow( "gpu-rack", smallRacks[0].GameObject );
		else
			Log.Warning( "BITCOINMINING_SCALE_AUDIT gpu-rack missing" );

		if ( largeRacks.Length > 0 )
			LogScaleRow( "large-gpu-rack", largeRacks[0].GameObject );
		else
			Log.Warning( "BITCOINMINING_SCALE_AUDIT large-gpu-rack missing" );

		Log.Info( "BITCOINMINING_SCALE_AUDIT end — hierarchy: large > gpu-rack > hub (visual height)" );
	}

	private static void LogScaleRow( string tag, GameObject go )
	{
		if ( !go.IsValid() )
		{
			Log.Warning( $"BITCOINMINING_SCALE_AUDIT {tag}: invalid GameObject" );
			return;
		}

		var worldBounds = go.GetBounds();
		Log.Info( $"BITCOINMINING_SCALE_AUDIT {tag} go={go.Name} pos={go.WorldPosition} goBounds size={worldBounds.Size} extents={worldBounds.Extents}" );

		var renderer = go.Components.Get<ModelRenderer>( FindMode.EverythingInSelfAndDescendants );
		if ( renderer.IsValid() )
		{
			var meshBounds = renderer.Bounds;
			Log.Info( $"BITCOINMINING_SCALE_AUDIT {tag} mesh size={meshBounds.Size} extents={meshBounds.Extents} model={renderer.Model?.Name ?? "(null)"}" );
		}
		else
		{
			Log.Warning( $"BITCOINMINING_SCALE_AUDIT {tag} no ModelRenderer" );
		}

		var collider = go.Components.Get<BoxCollider>( FindMode.EverythingInSelfAndDescendants );
		if ( collider.IsValid() )
			Log.Info( $"BITCOINMINING_SCALE_AUDIT {tag} collider scale={collider.Scale} center={collider.Center}" );
		else
			Log.Warning( $"BITCOINMINING_SCALE_AUDIT {tag} no BoxCollider" );
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

		try
		{
			var start = horizontalPoint + Vector3.Up * GroundTraceUp;
			var end = horizontalPoint - Vector3.Up * GroundTraceDown;
			var trace = scene.Trace.Ray( start, end ).Run();
			return trace.Hit ? trace.HitPosition : horizontalPoint;
		}
		catch ( Exception ex ) when ( ex.Message.Contains( "Default Surface", StringComparison.OrdinalIgnoreCase ) )
		{
			// DXRP editor play can run traces before the surface registry is ready (map still fitting).
			return horizontalPoint;
		}
	}
}
