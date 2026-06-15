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

	[ConCmd( "lp_spawn_advanced_gpu_rack" )]
	public static void SpawnAdvancedRack()
	{
		if ( !TryGetSpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_spawn_advanced_gpu_rack: no local viewer — play from game.scene first." );
			return;
		}

		var hub = Game.ActiveScene?.GetAllComponents<LpBitcoinHubEntity>().FirstOrDefault( h => h.IsValid() );
		if ( !hub.IsValid() )
		{
			Log.Warning( "lp_spawn_advanced_gpu_rack: no hub in scene — spawn kit or hub first." );
			return;
		}

		SpawnRackPrefab( transform, hub, advanced: true );
		Log.Info( "lp_spawn_advanced_gpu_rack: Advanced GPU Rack placed (2× yield)." );
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

	/// <summary>Hub admin with PIN gate presets — setup (default), unlock (PIN 4242), or blocked (wrong owner).</summary>
	[ConCmd( "lp_hashd_pin_preview" )]
	public static void PreviewHubPinUi( string mode = "setup" )
	{
		var hub = LpBitcoinUi.GetOrCreatePreviewHub( withSampleRacks: true );
		if ( !hub.IsValid() )
		{
			Log.Warning( "lp_hashd_pin_preview: no active scene." );
			return;
		}

		ConfigurePreviewPin( hub, mode );
		LpHashdUiHost.Open( hub );
	}

	private static void ConfigurePreviewPin( LpBitcoinHubEntity hub, string mode )
	{
		var normalized = string.IsNullOrWhiteSpace( mode ) ? "setup" : mode.Trim().ToLowerInvariant();
		switch ( normalized )
		{
			case "unlock":
				hub.BindOwnerFromLocalViewer();
				hub.AccessPinIsSet = true;
				hub.AccessPinHash = LpBitcoinHubPin.Hash( "4242" );
				Log.Info( "lp_hashd_pin_preview unlock: enter PIN 4242 to open hub admin." );
				break;

			case "blocked":
				hub.AccessPinIsSet = true;
				hub.AccessPinHash = LpBitcoinHubPin.Hash( "4242" );
				hub.Owner = 1;
				Log.Info( "lp_hashd_pin_preview blocked: hub owned by another operator — expect access denied." );
				break;

			default:
				hub.BindOwnerFromLocalViewer();
				hub.AccessPinIsSet = false;
				hub.AccessPinHash = 0;
				Log.Info( "lp_hashd_pin_preview setup: secure boot — create a 4–6 digit PIN." );
				break;
		}
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

	/// <summary>Logs mesh + BoxCollider bounds for hub (H1 scale pass). Spawns hub if missing.</summary>
	[ConCmd( "lp_bitcoin_scale_audit" )]
	public static void ScaleAudit()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_bitcoin_scale_audit: no active scene — play from game.scene, not a prefab tab." );
			return;
		}

		var hub = scene.GetAllComponents<LpBitcoinHubEntity>().FirstOrDefault( h => h.IsValid() );
		if ( !hub.IsValid() )
		{
			if ( !TryGetSpawnTransform( out var transform ) )
			{
				Log.Warning( "lp_bitcoin_scale_audit: no local viewer." );
				return;
			}

			Log.Info( "lp_bitcoin_scale_audit: spawning hub for measurement …" );
			hub = SpawnHubPrefab( transform );
		}

		Log.Info( "BITCOINMINING_SCALE_AUDIT begin (mesh=ModelRenderer bounds; collider=BoxCollider.Scale)" );
		if ( hub.IsValid() )
			LogScaleRow( "hub", hub.GameObject );
		else
			Log.Warning( "BITCOINMINING_SCALE_AUDIT hub missing" );

		var terminal = scene.GetAllComponents<LpBitcoinTerminalEntity>().FirstOrDefault( t => t.IsValid() );
		if ( terminal.IsValid() )
			LogScaleRow( "terminal", terminal.GameObject );
		else
			Log.Warning( "BITCOINMINING_SCALE_AUDIT terminal missing — spawn kit first" );

		Log.Info( "BITCOINMINING_SCALE_AUDIT end — terminal target mesh Y ~18u vs collider 14×18×8" );
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
			Log.Info( $"BITCOINMINING_SCALE_AUDIT {tag} mesh size={meshBounds.Size} mins={meshBounds.Mins} maxs={meshBounds.Maxs} model={renderer.Model?.Name ?? "(null)"}" );
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
		SpawnRackPrefab( new Transform( SnapToGround( origin + rot.Right * 80f ), rot ), hub, advanced: false );
		SpawnRackPrefab( new Transform( SnapToGround( origin + rot.Right * 160f ), rot ), hub, advanced: false );
		SpawnRackPrefab( new Transform( SnapToGround( origin + rot.Left * 80f ), rot ), hub, advanced: false );
		SpawnRackPrefab( new Transform( SnapToGround( origin + rot.Left * 160f ), rot ), hub, advanced: true );
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

	private static void SpawnRackPrefab( Transform transform, LpBitcoinHubEntity hub, bool advanced )
	{
		var path = advanced ? LpBitcoinIdent.AdvancedRackPrefabPath : LpBitcoinIdent.RackPrefabPath;
		var go = ClonePrefabAt( path, transform );
		if ( !go.IsValid() )
			return;

		var rack = go.Components.Get<LpBitcoinRackEntity>( FindMode.EverythingInSelfAndDescendants );
		if ( !rack.IsValid() )
			rack = go.AddComponent<LpBitcoinRackEntity>();

		if ( rack.IsValid() )
		{
			rack.AdvancedRack = advanced;
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
