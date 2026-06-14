// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// ─────────────────────────────────────────────────────────────────────────────

using System;
using System.Linq;
using Sandbox;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
#endif

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>Dev spawn — clones v2 prefabs for flatgrass playtest. Remove before portal publish.</summary>
public static class LpBitcoinDevSpawn
{
	private const float SpawnDistanceUnits = 140f;
	private const float GroundTraceUp = 2000f;
	private const float GroundTraceDown = 20000f;

	[ConCmd( "lp_bitcoin_spawn_hub" )]
	public static void SpawnHub()
	{
		if ( !TryGetSpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_bitcoin_spawn_hub: no local viewer — play from game.scene first." );
			return;
		}

		var hub = SpawnHubPrefab( transform );
		if ( !hub.IsValid() )
			return;

		Log.Info( "lp_bitcoin_spawn_hub: Ophion hub prefab placed." );
	}

	[ConCmd( "lp_bitcoin_spawn_kit" )]
	public static void SpawnKit()
	{
		var hub = SpawnKitInternal();
		if ( hub.IsValid() )
			Log.Info( "lp_bitcoin_spawn_kit: full prefab kit placed — USE hub or terminal." );
	}

	/// <summary>Hub admin UI only — no world spawn. Closes terminal if open.</summary>
	[ConCmd( "lp_bitcoin_preview_hub" )]
	public static void PreviewHubUi()
	{
		var hub = LpBitcoinUi.GetOrCreatePreviewHub( withSampleRacks: true );
		if ( !hub.IsValid() )
		{
			Log.Warning( "lp_bitcoin_preview_hub: no active scene." );
			return;
		}

		LpHashdUiHost.Open( hub );
		Log.Info( "lp_bitcoin_preview_hub: hub admin panel only (amber ops)." );
	}

	/// <summary>CRT terminal UI only — no world spawn. Closes hub admin if open.</summary>
	[ConCmd( "lp_bitcoin_preview_terminal" )]
	public static void PreviewTerminalUi()
	{
		var hub = LpBitcoinUi.GetOrCreatePreviewHub( withSampleRacks: true );
		if ( !hub.IsValid() )
		{
			Log.Warning( "lp_bitcoin_preview_terminal: no active scene." );
			return;
		}

		LpBitcoinTerminalUiHost.Open( hub );
		Log.Info( "lp_bitcoin_preview_terminal: CRT terminal only (rig@hub>)." );
	}

	/// <summary>Close whichever bitcoin UI is open.</summary>
	[ConCmd( "lp_bitcoin_ui_close" )]
	public static void CloseUi()
	{
		LpBitcoinUi.CloseAll();
		Log.Info( "lp_bitcoin_ui_close: all bitcoin UI closed." );
	}

	[ConCmd( "lp_bitcoin_ui_preview" )]
	public static void UiPreview()
	{
		var hub = SpawnKitInternal();
		if ( !hub.IsValid() )
			return;

		LpHashdUiHost.Open( hub );
		Log.Info( "lp_bitcoin_ui_preview: kit spawned + hub admin panel." );
	}

	[ConCmd( "lp_bitcoin_terminal_preview" )]
	public static void TerminalPreview()
	{
		var hub = SpawnKitInternal();
		if ( !hub.IsValid() )
			return;

		LpBitcoinTerminalUiHost.Open( hub );
		Log.Info( "lp_bitcoin_terminal_preview: kit spawned + CRT terminal." );
	}

	private static LpBitcoinHubEntity SpawnKitInternal()
	{
		if ( !TryGetSpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_bitcoin_spawn_kit: no local viewer — play from game.scene first." );
			return null;
		}

		var hub = SpawnHubPrefab( transform );
		if ( !hub.IsValid() )
			return null;

		var origin = hub.WorldPosition;
		var rot = transform.Rotation;
		SpawnRackPrefab( new Transform( SnapToGround( origin + rot.Right * 80f ), rot ), hub, large: false );
		SpawnRackPrefab( new Transform( SnapToGround( origin + rot.Right * 160f ), rot ), hub, large: false );
		SpawnRackPrefab( new Transform( SnapToGround( origin + rot.Left * 80f ), rot ), hub, large: false );
		SpawnRackPrefab( new Transform( SnapToGround( origin + rot.Left * 160f ), rot ), hub, large: true );
		SpawnTerminalPrefab( new Transform( SnapToGround( origin + rot.Forward * 100f ), rot ) );
		return hub;
	}

	private static LpBitcoinHubEntity SpawnHubPrefab( Transform transform )
	{
		var go = ClonePrefabAt( LpBitcoinIdent.HubPrefabPath, transform );
		if ( !go.IsValid() )
		{
			Log.Error( "lp_bitcoin: hub prefab missing — recompile bitcoin-miner.prefab in editor." );
			return null;
		}

		var hub = go.Components.Get<LpBitcoinHubEntity>( FindMode.EverythingInSelfAndDescendants );
		if ( !hub.IsValid() )
			hub = go.AddComponent<LpBitcoinHubEntity>();

		if ( !hub.IsValid() )
		{
			Log.Error( "lp_bitcoin: could not attach LpBitcoinHubEntity to hub prefab clone." );
			go.Destroy();
			return null;
		}

		hub.BindOwnerFromLocalViewer();
		NetworkSpawnIfNeeded( go );
		return hub;
	}

	private static void SpawnRackPrefab( Transform transform, LpBitcoinHubEntity hub, bool large )
	{
		var path = large ? LpBitcoinIdent.LargeRackPrefabPath : LpBitcoinIdent.RackPrefabPath;
		var go = ClonePrefabAt( path, transform );
		if ( !go.IsValid() )
			return;

		var rack = go.Components.Get<LpBitcoinRackEntity>( FindMode.EverythingInSelfAndDescendants );
		if ( !rack.IsValid() )
			rack = go.AddComponent<LpBitcoinRackEntity>();

		if ( rack.IsValid() )
		{
			rack.LargeRack = large;
			rack.LinkToHub( hub );
		}

		NetworkSpawnIfNeeded( go );
	}

	private static void SpawnTerminalPrefab( Transform transform )
	{
		var go = ClonePrefabAt( LpBitcoinIdent.TerminalPrefabPath, transform );
		if ( !go.IsValid() )
			return;

		NetworkSpawnIfNeeded( go );
	}

	private static void NetworkSpawnIfNeeded( GameObject go )
	{
		if ( !go.IsValid() )
			return;

#if !LIFEPUNCH_LOCAL
		var player = Player.Local;
		if ( player.IsValid() )
			go.NetworkSpawn( player.Network.Owner );
		else
			go.NetworkSpawn();
#endif
	}

	private static GameObject ClonePrefabAt( string prefabPath, Transform transform )
	{
#if LIFEPUNCH_LOCAL
		var prefab = GameObject.GetPrefab( prefabPath );
		if ( !prefab.IsValid() )
		{
			Log.Error( $"lp_bitcoin: could not load prefab '{prefabPath}'." );
			return default;
		}

		return prefab.Clone( new CloneConfig { Transform = transform } );
#else
		var prefabFile = PrefabFile.Load( prefabPath );
		if ( prefabFile == null )
		{
			Log.Error( $"lp_bitcoin: PrefabFile.Load failed '{prefabPath}'." );
			return default;
		}

		var prefabScene = SceneUtility.GetPrefabScene( prefabFile );
		if ( prefabScene == null )
		{
			Log.Error( $"lp_bitcoin: GetPrefabScene failed '{prefabPath}'." );
			return default;
		}

		var clone = prefabScene.Clone();
		if ( !clone.IsValid() )
		{
			Log.Error( "lp_bitcoin: scene clone failed." );
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

		var position = SnapToGround( camera.WorldPosition + forward * SpawnDistanceUnits );
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

			var position = SnapToGround( player.WorldPosition + flatForward * SpawnDistanceUnits );
			transform = new Transform( position, Rotation.LookAt( flatForward ) );
			return true;
		}

		var cam = scene?.GetAllComponents<CameraComponent>().FirstOrDefault();
		if ( !cam.IsValid() )
		{
			transform = default;
			return false;
		}

		var camForward = cam.WorldRotation.Forward.WithZ( 0 ).Normal;
		if ( camForward.Length < 0.01f )
			camForward = Vector3.Forward;

		var camPosition = SnapToGround( cam.WorldPosition + camForward * SpawnDistanceUnits );
		transform = new Transform( camPosition, Rotation.LookAt( camForward ) );
		return true;
#endif
	}

	private static Vector3 SnapToGround( Vector3 horizontalPoint )
	{
		var scene = Game.ActiveScene;
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
