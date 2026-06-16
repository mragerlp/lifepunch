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

		Log.Info( "lp_bitcoin_spawn_hub: Steam Machine hub prefab placed." );
	}

	[ConCmd( "lp_bitcoin_spawn_kit" )]
	public static void SpawnKit()
	{
		var hub = SpawnKitInternal();
		if ( hub.IsValid() )
			Log.Info( "lp_bitcoin_spawn_kit: full prefab kit placed — USE hub or terminal." );
	}

	/// <summary>Hub + terminal + one GPU rack + one Advanced GPU rack — flatgrass hero lineup.</summary>
	[ConCmd( "lp_bitcoin_spawn_lineup" )]
	public static void SpawnLineup()
	{
		if ( !TryGetSpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_bitcoin_spawn_lineup: no local viewer — play from game.scene first." );
			return;
		}

		var hub = SpawnHubPrefab( transform );
		if ( !hub.IsValid() )
			return;

		var origin = hub.WorldPosition;
		var rot = transform.Rotation;
		SpawnTerminalPrefab( new Transform( SnapToGround( origin + rot.Forward * 100f ), rot ) );
		SpawnRackPrefab( new Transform( SnapToGround( origin + rot.Right * 90f ), rot ), hub, advanced: false );
		SpawnRackPrefab( new Transform( SnapToGround( origin + rot.Left * 90f ), rot ), hub, advanced: true );
		Log.Info( "lp_bitcoin_spawn_lineup: Bitcoin Miner + Terminal + GPU Rack + Advanced GPU Rack placed." );
	}

	[ConCmd( "lp_bitcoin_spawn_terminal" )]
	public static void SpawnTerminal()
	{
		if ( !TryGetSpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_bitcoin_spawn_terminal: no local viewer — play from game.scene first." );
			return;
		}

		SpawnTerminalPrefab( transform );
		Log.Info( "lp_bitcoin_spawn_terminal: Bitcoin Terminal placed." );
	}

	[ConCmd( "lp_bitcoin_spawn_rack" )]
	public static void SpawnRack()
	{
		if ( !TryGetSpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_bitcoin_spawn_rack: no local viewer — play from game.scene first." );
			return;
		}

		var hub = Game.ActiveScene?.GetAllComponents<LpBitcoinHubEntity>().FirstOrDefault( h => h.IsValid() );
		if ( !hub.IsValid() )
		{
			Log.Warning( "lp_bitcoin_spawn_rack: no hub in scene — run lp_bitcoin_spawn_hub first." );
			return;
		}

		SpawnRackPrefab( transform, hub, advanced: false );
		Log.Info( "lp_bitcoin_spawn_rack: GPU Rack placed and linked." );
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
		WarnIfWrongPlayScene();
		LpBitcoinUi.CloseAll();
		var hub = LpBitcoinUi.GetOrCreatePreviewHub( withSampleRacks: true );
		if ( !hub.IsValid() )
		{
			Log.Warning( "lp_bitcoin_preview_hub: no active scene." );
			return;
		}

		var panel = LpHashdUiHost.Open( hub );
		panel?.DevBypassPinGate();
		Log.Info( "lp_bitcoin_preview_hub: hub admin open — amber dashboard (PIN bypassed for dev)." );
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
				Log.Info( "lp_hashd_pin_preview setup: secure boot — create a 4-digit PIN." );
				break;
		}
	}

	/// <summary>CRT terminal UI only — no world spawn. Closes hub admin if open.</summary>
	[ConCmd( "lp_bitcoin_preview_terminal" )]
	public static void PreviewTerminalUi()
	{
		WarnIfWrongPlayScene();
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

	/// <summary>Dev automation — open admin on nearest hub (same result as USE after spawn).</summary>
	[ConCmd( "lp_bitcoin_use_hub" )]
	public static void UseSpawnedHub()
	{
		WarnIfWrongPlayScene();
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_bitcoin_use_hub: no active scene." );
			return;
		}

		var hub = scene.GetAllComponents<LpBitcoinHubEntity>()
			.Where( h => h.IsValid() )
			.OrderBy( h => DistanceToViewer( h.WorldPosition ) )
			.FirstOrDefault();

		if ( !hub.IsValid() )
		{
			Log.Warning( "lp_bitcoin_use_hub: no hub — run lp_bitcoin_spawn_hub first." );
			return;
		}

		LpHashdUiHost.Open( hub );
		Log.Info( "lp_bitcoin_use_hub: hub admin opened (USE equivalent)." );
	}

	/// <summary>Mount compiled <c>HashdHubUiLayout</c> from SUI scratch output (btc.png smoke test).</summary>
	[ConCmd( "lp_bitcoin_sui_hub_preview" )]
	public static void PreviewSuiHubLayout()
	{
		WarnIfWrongPlayScene();
		LpBitcoinUi.CloseAll();

		const string layoutType = "LifePunch.DXRP.Addons.Bitcoin.HashdHubUiLayout";
		var typeDesc = TypeLibrary.GetType( layoutType );
		if ( typeDesc is null )
		{
			Log.Warning( "lp_bitcoin_sui_hub_preview: HashdHubUiLayout not loaded — compile hashd-hub-ui.sui (Ctrl+B) in UI Designer first." );
			return;
		}

		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_bitcoin_sui_hub_preview: no active scene." );
			return;
		}

		var host = scene.CreateObject();
		host.Name = "LpSuiHubPreview";
		host.AddComponent<ScreenPanel>();

		if ( host.Components.Create( typeDesc ) is not Component )
		{
			Log.Warning( "lp_bitcoin_sui_hub_preview: failed to mount HashdHubUiLayout." );
			host.Destroy();
			return;
		}

		Log.Info( "lp_bitcoin_sui_hub_preview: SUI layout mounted — check sidebar BTC mark (btc.png)." );
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

		var hub = scene.GetAllComponents<LpBitcoinHubEntity>()
			.Where( h => h.IsValid() && !IsPreviewHub( h ) )
			.OrderByDescending( h => h.Components.Get<ModelRenderer>( FindMode.EverythingInSelf )?.IsValid() == true )
			.FirstOrDefault();
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

		foreach ( var rack in scene.GetAllComponents<LpBitcoinRackEntity>().Where( r => r.IsValid() ) )
		{
			var tag = rack.AdvancedRack ? "advanced-rack" : "gpu-rack";
			LogScaleRow( tag, rack.GameObject );
		}

		Log.Info( "BITCOINMINING_SCALE_AUDIT end — gpu-rack collider target 25×20×36; advanced-rack 52×27×47" );
	}

	/// <summary>Logs compiled vmdl sequences + power anim apply (BITCOINMINING-05).</summary>
	[ConCmd( "lp_bitcoin_anim_audit" )]
	public static void AnimAudit()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_bitcoin_anim_audit: no active scene." );
			return;
		}

		var hub = scene.GetAllComponents<LpBitcoinHubEntity>()
			.Where( h => h.IsValid() && !IsPreviewHub( h ) )
			.FirstOrDefault();
		if ( !hub.IsValid() )
		{
			if ( !TryGetSpawnTransform( out var transform ) )
			{
				Log.Warning( "lp_bitcoin_anim_audit: no hub — spawn with lp_bitcoin_spawn_hub first." );
				return;
			}

			hub = SpawnHubPrefab( transform );
		}

		var renderer = hub.Components.Get<ModelRenderer>( FindMode.EverythingInSelf );
		if ( !renderer.IsValid() )
		{
			Log.Warning( "lp_bitcoin_anim_audit: hub has no ModelRenderer." );
			return;
		}

		var sceneModel = renderer.SceneObject as SceneModel;
		var model = renderer.Model;
		var sequences = LpBitcoinPowerAnim.GetAvailableSequences( renderer, sceneModel );
		Log.Info( $"BITCOINMINING_ANIM_AUDIT model={model?.ResourcePath ?? "(null)"} powered={hub.IsPowered} bones={model?.BoneCount ?? 0} animCount={model?.AnimationCount ?? 0}" );
		if ( sequences.Count == 0 )
		{
			Log.Warning( "BITCOINMINING_ANIM_AUDIT sequences=0 — open bitcoin-miner.vmdl in ModelDoc, star-add fanAction from steam-machine.fbx, recompile, Pull-DxrpCompiledAssetsToRepo." );
			return;
		}

		foreach ( var seq in sequences )
			Log.Info( $"BITCOINMINING_ANIM_AUDIT seq={seq}" );

		if ( LpBitcoinPowerAnim.ApplyHubPower( renderer, true, out var onSeq ) )
			Log.Info( $"BITCOINMINING_ANIM_AUDIT apply ON -> {onSeq}" );
		else
			Log.Warning( "BITCOINMINING_ANIM_AUDIT apply ON failed — fanAction missing from compiled vmdl." );

		if ( LpBitcoinPowerAnim.ApplyHubPower( renderer, false, out var offSeq ) )
			Log.Info( $"BITCOINMINING_ANIM_AUDIT apply OFF -> {offSeq}" );
		else
			Log.Warning( "BITCOINMINING_ANIM_AUDIT apply OFF failed." );

		hub.ApplyPoweredState( true );
	}

	/// <summary>Logs GPU rack + advanced rack vmdl sequences and mining anim apply (BITCOINMINING-01).</summary>
	[ConCmd( "lp_bitcoin_rack_anim_audit" )]
	public static void RackAnimAudit()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_bitcoin_rack_anim_audit: no active scene." );
			return;
		}

		var racks = scene.GetAllComponents<LpBitcoinRackEntity>()
			.Where( r => r.IsValid() )
			.OrderBy( r => r.AdvancedRack )
			.ToList();

		if ( racks.Count == 0 )
		{
			if ( !TryGetSpawnTransform( out var transform ) )
			{
				Log.Warning( "lp_bitcoin_rack_anim_audit: no racks — run lp_bitcoin_spawn_kit first." );
				return;
			}

			Log.Info( "lp_bitcoin_rack_anim_audit: spawning kit …" );
			SpawnKitInternal();
			racks = scene.GetAllComponents<LpBitcoinRackEntity>()
				.Where( r => r.IsValid() )
				.OrderBy( r => r.AdvancedRack )
				.ToList();
		}

		foreach ( var rack in racks )
			LogRackAnimAudit( rack );
	}

	private static void LogRackAnimAudit( LpBitcoinRackEntity rack )
	{
		if ( !rack.IsValid() )
			return;

		var tag = rack.AdvancedRack ? "advanced-rack" : "gpu-rack";
		var renderer = rack.Components.Get<ModelRenderer>( FindMode.EverythingInSelf );
		if ( !renderer.IsValid() )
		{
			Log.Warning( $"BITCOINMINING_RACK_ANIM_AUDIT {tag} no ModelRenderer" );
			return;
		}

		var sceneModel = renderer.SceneObject as SceneModel;
		var model = renderer.Model;
		var sequences = LpBitcoinPowerAnim.GetAvailableSequences( renderer, sceneModel );
		Log.Info( $"BITCOINMINING_RACK_ANIM_AUDIT {tag} model={model?.ResourcePath ?? "(null)"} mining={rack.IsMining} bones={model?.BoneCount ?? 0} animCount={model?.AnimationCount ?? 0}" );

		if ( sequences.Count == 0 )
		{
			var vmdl = rack.AdvancedRack ? "gpu-rack-stacked.vmdl" : "gpu-rack.vmdl";
			Log.Warning( $"BITCOINMINING_RACK_ANIM_AUDIT {tag} sequences=0 — open {vmdl} in ModelDoc, star-add power_on from anim FBX, recompile, Pull-DxrpCompiledAssetsToRepo." );
			return;
		}

		foreach ( var seq in sequences )
			Log.Info( $"BITCOINMINING_RACK_ANIM_AUDIT {tag} seq={seq}" );

		if ( LpBitcoinPowerAnim.ApplyRackPower( renderer, true, out var onSeq ) )
			Log.Info( $"BITCOINMINING_RACK_ANIM_AUDIT {tag} apply ON -> {onSeq}" );
		else
			Log.Warning( $"BITCOINMINING_RACK_ANIM_AUDIT {tag} apply ON failed." );

		if ( LpBitcoinPowerAnim.ApplyRackPower( renderer, false, out var offSeq ) )
			Log.Info( $"BITCOINMINING_RACK_ANIM_AUDIT {tag} apply OFF -> {offSeq}" );
		else
			Log.Warning( $"BITCOINMINING_RACK_ANIM_AUDIT {tag} apply OFF failed." );
	}

	private static bool IsPreviewHub( LpBitcoinHubEntity hub )
	{
		if ( !hub.IsValid() )
			return false;

		var name = hub.GameObject.Name ?? string.Empty;
		return name.StartsWith( "LpBitcoinPreview", StringComparison.OrdinalIgnoreCase );
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

		LifePunchPropPhysics.LogModelPhysics( go, tag );
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
		LifePunchPropPhysics.SetupPhysicalProp( go, alignGround: true );
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

		LifePunchPropPhysics.SetupPhysicalProp( go, alignGround: true );
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
		var baseEntity = go.Components.Get<BaseEntity>( FindMode.EverythingInSelfAndDescendants );
		if ( baseEntity.IsValid() && player.IsValid() )
			baseEntity.BindOwnerFromPlayer( player );

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

	private static float DistanceToViewer( Vector3 worldPos )
	{
#if LIFEPUNCH_LOCAL
		var camera = Game.ActiveScene?.GetAllComponents<CameraComponent>().FirstOrDefault();
		if ( camera.IsValid() )
			return Vector3.DistanceBetween( worldPos, camera.WorldPosition );
#else
		var player = Player.Local;
		if ( player.IsValid() )
			return Vector3.DistanceBetween( worldPos, player.WorldPosition );
#endif
		return 0f;
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

	private static void WarnIfWrongPlayScene()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
			return;

		var name = scene.Name ?? string.Empty;
		if ( name.Contains( "Preview", StringComparison.OrdinalIgnoreCase ) )
		{
			Log.Warning(
				$"Bitcoin UI preview on '{name}' — open scenes/game.scene, click Host Play, then run lp_bitcoin_preview_hub again." );
		}
	}
}
