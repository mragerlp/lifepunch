// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Hacker Job" (s&box ident: lifepunch.hackerjob · addon ident: hackerjob) is the sole-owned
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

namespace LifePunch.DXRP.Addons.HackerJob;

/// <summary>
/// DEV / EDITOR-TEST ONLY — excluded from publish staging.
/// </summary>
public static class HackerDevSpawn
{
	private const float SpawnDistanceUnits = 120f;

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

#if LIFEPUNCH_LOCAL
		HackerTerminal.Open( entity );
#else
		entity.RequestOpenTerminal();
#endif

		if ( tier == HackerTerminalTier.Advanced )
			Log.Info( "lp_vengeance_ui: vengeance.exe mounted. Try: govdb → infil govdb-tax-01" );
		else
			Log.Info( "lp_cornerman_ui: mounted. Spawn bots: lifepunch_spawn_testbot Greg → scan → hack <steamid>" );
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
		var prefab = GameObject.GetPrefab( prefabPath );
		if ( !prefab.IsValid() )
		{
			Log.Error( $"Could not load rack prefab '{prefabPath}'." );
			return null;
		}

		var rackGo = prefab.Clone( new CloneConfig { Transform = new Transform( position, rotation ) } );
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

		var prefab = GameObject.GetPrefab( prefabPath );
		if ( !prefab.IsValid() )
			return;

		var forward = ( TryGetViewerPosition( Game.ActiveScene ) ?? position ) - position;
		forward = forward.WithZ( 0 ).Normal;
		if ( forward.Length < 0.01f )
			forward = Vector3.Forward;

		var terminal = prefab.Clone( new CloneConfig
		{
			Transform = new Transform( position, Rotation.LookAt( forward ) )
		} );

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

		var prefab = GameObject.GetPrefab( prefabPath );
		if ( !prefab.IsValid() )
		{
			Log.Error( $"{command}: could not load '{prefabPath}'. Build prefab per ENTITY_PREFAB_BUILD.md." );
			return;
		}

		var terminal = prefab.Clone( new CloneConfig { Transform = transform } );
		if ( !terminal.IsValid() )
		{
			Log.Error( $"{command}: clone failed." );
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
