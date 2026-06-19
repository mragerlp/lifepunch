// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// ─────────────────────────────────────────────────────────────────────────────

using System;
using System.Linq;
using Sandbox;
using LifePunch.DXRP.Addons;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
#endif

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>Dev spawn — clones v2 prefabs for flatgrass playtest. Remove before portal publish.</summary>
public static class LpBitcoinDevSpawn
{
	private const float GroundTraceUp = 2000f;
	private const float GroundTraceDown = 20000f;

	[ConCmd( "lp_bitcoin_spawn_hub" )]
	public static void SpawnHub()
	{
		if ( !LifePunchMarketSpawn.TryGetIdentitySpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_bitcoin_spawn_hub: no local viewer — play from game.scene first." );
			return;
		}

		var hub = SpawnHubPrefab( transform );
		if ( !hub.IsValid() )
			return;

#if !LIFEPUNCH_LOCAL
		LifePunchMarketSpawn.LogMarketSpawnAudit( "lp_bitcoin_spawn_hub" );
#endif
		Log.Info( "lp_bitcoin_spawn_hub: Steam Machine hub prefab placed." );
	}

	[ConCmd( "lp_bitcoin_hub_ground_fix" )]
	public static void HubGroundFix()
	{
#if !LIFEPUNCH_LOCAL
		if ( !Networking.IsHost )
		{
			Log.Warning( "lp_bitcoin_hub_ground_fix: host only." );
			return;
		}

		var hubs = Game.ActiveScene?.GetAllComponents<LpBitcoinHubEntity>();
		if ( hubs is null || !hubs.Any() )
		{
			Log.Warning( "lp_bitcoin_hub_ground_fix: no hub — run lp_bitcoin_spawn_hub first." );
			return;
		}

		foreach ( var hub in hubs )
		{
			if ( !hub.IsValid() )
				continue;

			var before = hub.GameObject.WorldPosition;
			hub.RestartPrinterSettle();
			LifePunchPropPhysics.LogModelPhysics( hub.GameObject, "hub_ground_fix" );
			Log.Info( $"lp_bitcoin_hub_ground_fix: {before} -> {hub.GameObject.WorldPosition}" );
		}
#else
		Log.Warning( "lp_bitcoin_hub_ground_fix: DXRP play only." );
#endif
	}

	[ConCmd( "lp_bitcoin_spawn_kit" )]
	public static void SpawnKit()
	{
		var hub = SpawnKitInternal();
		if ( hub.IsValid() )
			Log.Info( "lp_bitcoin_spawn_kit: full prefab kit placed — USE hub or terminal." );
	}

	/// <summary>Dev shortcut — power hub + start all linked racks (host play only).</summary>
	[ConCmd( "lp_bitcoin_playtest_mining" )]
	public static void PlaytestMining()
	{
#if LIFEPUNCH_LOCAL
		Log.Warning( "lp_bitcoin_playtest_mining: DXRP project only." );
#else
		if ( !Networking.IsHost )
		{
			Log.Warning( "lp_bitcoin_playtest_mining: host only — Start Hosting then Play." );
			return;
		}

		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_bitcoin_playtest_mining: no active scene." );
			return;
		}

		var hub = scene.GetAllComponents<LpBitcoinHubEntity>()
			.Where( h => h.IsValid() )
			.OrderByDescending( h => h.IsPowered )
			.FirstOrDefault();

		if ( !hub.IsValid() )
		{
			Log.Warning( "lp_bitcoin_playtest_mining: no hub — run lp_bitcoin_spawn_kit first." );
			return;
		}

		hub.BindOwnerFromLocalViewer();
		hub.ApplyPoweredState( true );

		var racks = scene.GetAllComponents<LpBitcoinRackEntity>().Where( r => r.IsValid() ).ToList();
		foreach ( var rack in racks )
			rack.RequestSetMining( true );

		Log.Info( $"lp_bitcoin_playtest_mining: hub ON, {racks.Count} rack(s) mining." );
#endif
	}

	/// <summary>Log fan_spin_* local transforms — use after nudging fans in prefab editor.</summary>
	[ConCmd( "lp_bitcoin_fan_tune" )]
	public static void FanTune()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_bitcoin_fan_tune: no active scene." );
			return;
		}

		foreach ( var rack in scene.GetAllComponents<LpBitcoinRackEntity>().Where( r => r.IsValid() ) )
		{
			var tag = rack.AdvancedRack ? "advanced" : "gpu-rack";
			foreach ( var child in rack.GameObject.Children.Where( c => c.Name.StartsWith( "fan_spin_", StringComparison.OrdinalIgnoreCase ) ) )
				Log.Info( $"BITCOINMINING_FAN_TUNE {tag} {child.Name} pos={child.LocalPosition} rot={child.LocalRotation.Angles()}" );
		}

		foreach ( var hub in scene.GetAllComponents<LpBitcoinHubEntity>().Where( h => h.IsValid() ) )
		{
			var body = hub.GameObject.Components.Get<ModelRenderer>( FindMode.EverythingInSelf );
			if ( body.IsValid() )
			{
				var bb = body.LocalBounds;
				Log.Info( $"BITCOINMINING_FAN_TUNE hub body bounds center={bb.Center} size={bb.Size} maxs={bb.Maxs}" );
			}

			foreach ( var child in hub.GameObject.Children.Where( c => c.Name.StartsWith( "fan_spin", StringComparison.OrdinalIgnoreCase ) ) )
			{
				var fan = child.Components.Get<ModelRenderer>( FindMode.EverythingInSelf );
				if ( fan.IsValid() )
				{
					var fb = fan.LocalBounds;
					Log.Info( $"BITCOINMINING_FAN_TUNE hub {child.Name} fanBounds center={fb.Center} size={fb.Size}" );
				}

				Log.Info( $"BITCOINMINING_FAN_TUNE hub {child.Name} pos={child.LocalPosition} rot={child.LocalRotation.Angles()}" );
			}
		}
	}

	/// <summary>Log lcd_screen local transform — nudge in prefab editor, save, paste values into prefab or send to agent.</summary>
	[ConCmd( "lp_bitcoin_lcd_tune" )]
	public static void LcdTune()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_bitcoin_lcd_tune: no active scene." );
			return;
		}

		var terminals = scene.GetAllComponents<LpBitcoinTerminalEntity>().Where( t => t.IsValid() ).ToList();
		if ( terminals.Count == 0 )
		{
			Log.Warning( "lp_bitcoin_lcd_tune: no terminal — run lp_spawn_staging_terminal first." );
			return;
		}

		foreach ( var terminal in terminals )
		{
			var lcdGo = terminal.GameObject.Children.FirstOrDefault( c => c.Name == "lcd_screen" );
			if ( lcdGo is null || !lcdGo.IsValid() )
			{
				Log.Warning( "lp_bitcoin_lcd_tune: terminal missing lcd_screen child." );
				continue;
			}

			var text = lcdGo.Components.Get<TextRenderer>( FindMode.EverythingInSelf );
			var scale = text.IsValid() ? text.Scale : 0f;
			var align = text.IsValid() ? text.HorizontalAlignment.ToString() : "n/a";
			Log.Info( $"BITCOINMINING_LCD_TUNE terminal pos={terminal.WorldPosition} manualLcd={terminal.ManualLcdPlacement}" );
			Log.Info( $"BITCOINMINING_LCD_TUNE lcd_screen localPos={lcdGo.LocalPosition} localRot={lcdGo.LocalRotation} localRotAngles={lcdGo.LocalRotation.Angles()} localScale={lcdGo.LocalScale}" );
			Log.Info( $"BITCOINMINING_LCD_TUNE TextRenderer scale={scale} horizontalAlignment={align}" );
		}

		Log.Info( "lp_bitcoin_lcd_tune: set ManualLcdPlacement=true on prefab so spawn keeps these values." );
	}

	[ConCmd( "lp_bitcoin_hub_asset_audit" )]
	public static void HubAssetAudit()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_bitcoin_hub_asset_audit: no active scene." );
			return;
		}

		Log.Info( $"BITCOINMINING_HUB_ASSET_AUDIT ident prefab={LpBitcoinIdent.HubPrefabPath} body={LpBitcoinIdent.HubModelPath} fanPath={LpBitcoinIdent.HubFanModelPath} (fan child should be absent while BITCOINMINING-05 parked)" );

		var hubs = scene.GetAllComponents<LpBitcoinHubEntity>().Where( h => h.IsValid() ).ToList();
		if ( hubs.Count == 0 )
		{
			Log.Warning( "lp_bitcoin_hub_asset_audit: no hub in scene — run lp_bitcoin_spawn_hub first." );
			return;
		}

		foreach ( var hub in hubs )
		{
			var body = hub.Components.Get<ModelRenderer>( FindMode.EverythingInSelf );
			var bodyModel = body.IsValid() ? body.Model?.ResourcePath ?? "(null)" : "(no renderer)";
			Log.Info( $"BITCOINMINING_HUB_ASSET_AUDIT hub pos={hub.WorldPosition} bodyModel={bodyModel}" );

			var fanChildren = hub.GameObject.Children
				.Where( c => c.IsValid() && c.Name.StartsWith( "fan_spin", StringComparison.OrdinalIgnoreCase ) )
				.ToList();

			if ( fanChildren.Count == 0 )
			{
				Log.Info( "BITCOINMINING_HUB_ASSET_AUDIT fan_child=NONE (expected while parked)" );
				continue;
			}

			foreach ( var child in fanChildren )
			{
				var fan = child.Components.Get<ModelRenderer>( FindMode.EverythingInSelf );
				var fanModel = fan.IsValid() ? fan.Model?.ResourcePath ?? "(null)" : "(no renderer)";
				Log.Info( $"BITCOINMINING_HUB_ASSET_AUDIT fan_child={child.Name} goEnabled={child.Enabled} rendererEnabled={fan?.Enabled} model={fanModel} pos={child.LocalPosition}" );
			}
		}
	}

	[ConCmd( "lp_bitcoin_hub_power_toggle" )]
	public static void HubPowerToggle()
	{
		var hub = Game.ActiveScene?.GetAllComponents<LpBitcoinHubEntity>().FirstOrDefault( h => h.IsValid() );
		if ( !hub.IsValid() )
		{
			Log.Warning( "lp_bitcoin_hub_power_toggle: no hub — run lp_bitcoin_spawn_hub first." );
			return;
		}

		hub.ApplyPoweredState( !hub.IsPowered );
		Log.Info( $"lp_bitcoin_hub_power_toggle: IsPowered={hub.IsPowered} (green=ON, red=OFF status LED)." );
	}

	[ConCmd( "lp_bitcoin_status_led_tune" )]
	public static void StatusLedTune()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_bitcoin_status_led_tune: no active scene." );
			return;
		}

		// Status LED is mesh emissive only (fence-led vmat) — no runtime point light.
		foreach ( var hub in scene.GetAllComponents<LpBitcoinHubEntity>().Where( h => h.IsValid() ) )
		{
			Log.Info( $"BITCOINMINING_STATUS_LED hub powered={hub.IsPowered} mode=mesh-emissive (lp_bitcoin_hub_material_audit for slots)" );
		}
	}

	[ConCmd( "lp_bitcoin_hub_material_audit" )]
	public static void HubMaterialAudit()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_bitcoin_hub_material_audit: no active scene." );
			return;
		}

		foreach ( var hub in scene.GetAllComponents<LpBitcoinHubEntity>().Where( h => h.IsValid() ) )
		{
			var renderer = hub.Components.Get<ModelRenderer>( FindMode.EverythingInSelf );
			if ( !renderer.IsValid() )
			{
				Log.Warning( "BITCOINMINING_HUB_MATERIAL hub missing ModelRenderer" );
				continue;
			}

			Log.Info( $"BITCOINMINING_HUB_MATERIAL hub model={renderer.Model?.ResourcePath ?? "(null)"} powered={hub.IsPowered} slots={renderer.Materials.Count}" );
			for ( var i = 0; i < renderer.Materials.Count; i++ )
			{
				var mat = renderer.Materials.GetOriginal( i );
				if ( mat is null || !mat.IsValid() )
					continue;

				var selfIllum = mat.GetFeature( "F_SELF_ILLUM" );
				Log.Info( $"BITCOINMINING_HUB_MATERIAL slot={i} path={mat.ResourcePath} F_SELF_ILLUM={selfIllum}" );
			}
		}
	}

	/// <summary>Hub + terminal + one GPU rack + one Advanced GPU rack — flatgrass hero lineup.</summary>
	[ConCmd( "lp_bitcoin_spawn_lineup" )]
	public static void SpawnLineup()
	{
		if ( !LifePunchMarketSpawn.TryGetIdentitySpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_bitcoin_spawn_lineup: no local viewer — play from game.scene first." );
			return;
		}

		var hub = SpawnHubPrefab( transform );
		if ( !hub.IsValid() )
			return;

		var origin = transform.Position;
		var rot = transform.Rotation;
		var groundZ = origin.z;
		SpawnTerminalPrefab( new Transform( SnapToGround( origin + rot.Forward * 100f, groundZ ), rot ) );
		SpawnRackPrefab( RackSpawnTransform( transform, sideOffset: 120f ), hub, advanced: false );
		SpawnRackPrefab( RackSpawnTransform( transform, sideOffset: -120f ), hub, advanced: true );
		Log.Info( "lp_bitcoin_spawn_lineup: Bitcoin Hub + Terminal + GPU Rack + Advanced GPU Rack placed." );
	}

	[ConCmd( "lp_bitcoin_spawn_terminal" )]
	public static void SpawnTerminal()
	{
		if ( !LifePunchMarketSpawn.TryGetIdentitySpawnTransform( out var transform ) )
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
		if ( !LifePunchMarketSpawn.TryGetIdentitySpawnTransform( out var transform ) )
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
		if ( !LifePunchMarketSpawn.TryGetIdentitySpawnTransform( out var transform ) )
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

	/// <summary>Legacy alias — docs/playtest still reference v1 command name.</summary>
	[ConCmd( "lp_spawn_gpu_rack" )]
	public static void SpawnGpuRackLegacy() => SpawnRack();

	/// <summary>Legacy alias — stacked rack spawn.</summary>
	[ConCmd( "lp_spawn_large_gpu_rack" )]
	public static void SpawnLargeGpuRackLegacy() => SpawnAdvancedRack();

	/// <summary>Legacy alias — hub + terminal + standard + advanced rack lineup.</summary>
	[ConCmd( "lp_spawn_bitcoinmining_full_kit" )]
	public static void SpawnBitcoinMiningFullKitLegacy() => SpawnLineup();

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
			if ( !LifePunchMarketSpawn.TryGetIdentitySpawnTransform( out var transform ) )
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

		Log.Info( "BITCOINMINING_SCALE_AUDIT end — bake BoxCollider from model.Bounds; close/reopen prefab tab if green wireframe still stale" );
	}

	/// <summary>Hub facing vs player (H1 orientation). Spawns hub if missing.</summary>
	[ConCmd( "lp_bitcoin_hub_orient_audit" )]
	public static void HubOrientAudit()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_bitcoin_hub_orient_audit: no active scene — Host Play blank.scene first." );
			return;
		}

		var hub = scene.GetAllComponents<LpBitcoinHubEntity>()
			.Where( h => h.IsValid() && !IsPreviewHub( h ) )
			.FirstOrDefault();
		if ( !hub.IsValid() )
		{
			if ( !LifePunchMarketSpawn.TryGetIdentitySpawnTransform( out var transform ) )
			{
				Log.Warning( "lp_bitcoin_hub_orient_audit: no local viewer." );
				return;
			}

			hub = SpawnHubPrefab( transform );
		}

		if ( !hub.IsValid() )
		{
			Log.Warning( "lp_bitcoin_hub_orient_audit: hub spawn failed." );
			return;
		}

		var go = hub.GameObject;
		var hubForward = go.WorldRotation.Forward.WithZ( 0 ).Normal;
		var hubRight = go.WorldRotation.Right.WithZ( 0 ).Normal;
		var playerPos = GetLocalViewerPosition();
		var toPlayer = ( playerPos - go.WorldPosition ).WithZ( 0 ).Normal;
		var facingDot = hubForward.Dot( toPlayer );
		var sideDot = hubRight.Dot( toPlayer );

		Log.Info( "BITCOINMINING_ORIENT_AUDIT begin" );
		Log.Info( $"  hubPos={go.WorldPosition} rot={go.WorldRotation.Angles()}" );
		Log.Info( $"  hubForward(flat)={hubForward} hubRight(flat)={hubRight}" );
		Log.Info( $"  playerPos={playerPos} toPlayer={toPlayer}" );
		Log.Info( $"  panelDot={sideDot:F3} (want < -0.7 — sm_panel on entity -Right after import Y=270, market identity rot)" );
		Log.Info( $"  forwardDot={facingDot:F3} (entity +Forward — fan/back axis; should NOT face player)" );

		if ( sideDot < -0.7f )
			Log.Info( "  PASS: panel/USE (front) toward player — matches DXRP market spawn (identity rotation)." );
		else if ( sideDot > 0.7f )
			Log.Info( "  FAIL: fan/back (+Right) toward player — try import_rotation Y -= 180 (e.g. 270 → 90)." );
		else if ( facingDot > 0.7f || facingDot < -0.7f )
			Log.Info( "  FAIL: long axis toward player — tune import_rotation Y in bitcoinhub.vmdl." );
		else
			Log.Info( "  WARN: ambiguous — use lp_bitcoin_hub_yaw_test or rotate with hands; check ModelDoc preview." );

		Log.Info( "BITCOINMINING_ORIENT_AUDIT end" );
	}

	/// <summary>Spawn hub with extra yaw offset to find correct import_rotation bake.</summary>
	[ConCmd( "lp_bitcoin_hub_yaw_test" )]
	public static void HubYawTest( float yawOffsetDegrees = 0f )
	{
		if ( !LifePunchMarketSpawn.TryGetIdentitySpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_bitcoin_hub_yaw_test: no local viewer." );
			return;
		}

		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_bitcoin_hub_yaw_test: no active scene." );
			return;
		}

		foreach ( var old in scene.GetAllComponents<LpBitcoinHubEntity>().Where( h => h.IsValid() && !IsPreviewHub( h ) ) )
			old.GameObject.Destroy();

		transform.Rotation *= Rotation.FromYaw( yawOffsetDegrees );
		var hub = SpawnHubPrefab( transform );
		if ( !hub.IsValid() )
			return;

		Log.Info( $"lp_bitcoin_hub_yaw_test: spawned with extra yaw={yawOffsetDegrees:F0}° — if panel faces you, set import_rotation Y to this offset (mod 360) in bitcoinhub.vmdl." );
		HubOrientAudit();
	}

	private static Vector3 GetLocalViewerPosition()
	{
#if LIFEPUNCH_LOCAL
		var camera = Game.ActiveScene?.GetAllComponents<CameraComponent>().FirstOrDefault();
		if ( camera.IsValid() )
			return camera.WorldPosition;
#else
		var player = Player.Local;
		if ( player.IsValid() )
			return player.WorldPosition;
#endif
		var cam = Game.ActiveScene?.GetAllComponents<CameraComponent>().FirstOrDefault();
		return cam.IsValid() ? cam.WorldPosition : Vector3.Zero;
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
			if ( !LifePunchMarketSpawn.TryGetIdentitySpawnTransform( out var transform ) )
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
			Log.Warning( "BITCOINMINING_ANIM_AUDIT sequences=0 — open bitcoinhub.vmdl in ModelDoc, star-add fanAction from steam-machine.fbx, recompile, Pull-DxrpCompiledAssetsToRepo." );
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
			if ( !LifePunchMarketSpawn.TryGetIdentitySpawnTransform( out var transform ) )
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

		if ( renderer.IsValid() && renderer.Model is not null )
		{
			var modelBounds = renderer.Model.Bounds;
			Log.Info( $"BITCOINMINING_SCALE_AUDIT {tag} modelBounds center={modelBounds.Center} size={modelBounds.Size} ← copy to prefab BoxCollider" );
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
		if ( !LifePunchMarketSpawn.TryGetIdentitySpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_bitcoin_spawn_kit: no local viewer — play from game.scene first." );
			return null;
		}

		var hub = SpawnHubPrefab( transform );
		if ( !hub.IsValid() )
			return null;

		var origin = transform.Position;
		var rot = transform.Rotation;
		var groundZ = origin.z;
		SpawnRackPrefab( RackSpawnTransform( transform, sideOffset: 100f ), hub, advanced: false );
		SpawnRackPrefab( RackSpawnTransform( transform, sideOffset: -100f ), hub, advanced: false );
		SpawnRackPrefab( RackSpawnTransform( transform, sideOffset: 100f ), hub, advanced: true );
		SpawnRackPrefab( RackSpawnTransform( transform, sideOffset: -200f ), hub, advanced: true );
		SpawnTerminalPrefab( new Transform( SnapToGround( origin + rot.Forward * 100f, groundZ ), rot ) );
		return hub;
	}

	private static Transform RackSpawnTransform( Transform marketSpawn, float sideOffset, float forwardOffset = 0f )
	{
		var rot = marketSpawn.Rotation;
		var pos = marketSpawn.Position + rot.Right * sideOffset + rot.Forward * forwardOffset;
		return new Transform( pos, rot );
	}

	private static LpBitcoinRackEntity SpawnRackPrefab( Transform transform, LpBitcoinHubEntity hub, bool advanced )
	{
		var path = advanced ? LpBitcoinIdent.AdvancedRackPrefabPath : LpBitcoinIdent.RackPrefabPath;
		var label = advanced ? LpBitcoinIdent.AdvancedRackDisplayName : LpBitcoinIdent.RackDisplayName;
		var go = ClonePrefabAt( path, transform );
		if ( !go.IsValid() )
		{
			Log.Error( $"lp_bitcoin: failed to spawn {label} — recompile '{path}'." );
			return null;
		}

		var rack = go.Components.Get<LpBitcoinRackEntity>( FindMode.EverythingInSelfAndDescendants );
		if ( !rack.IsValid() )
			rack = go.AddComponent<LpBitcoinRackEntity>();

		if ( rack.IsValid() )
		{
			rack.AdvancedRack = advanced;
			rack.LinkToHub( hub );
		}

		NetworkSpawnIfNeeded( go );
		Log.Info( $"lp_bitcoin: {label} placed at {go.WorldPosition} (linked to hub)." );
		return rack;
	}

	private static LpBitcoinHubEntity SpawnHubPrefab( Transform transform )
	{
		var go = ClonePrefabAt( LpBitcoinIdent.HubPrefabPath, transform );
		if ( !go.IsValid() )
		{
			Log.Error( "lp_bitcoin: hub prefab missing — recompile bitcoinhub.prefab in editor." );
			return null;
		}

		var hub = go.Components.Get<LpBitcoinHubEntity>( FindMode.EverythingInSelfAndDescendants );
		if ( !hub.IsValid() )
		{
			Log.Error( "lp_bitcoin: bitcoinhub.prefab missing LpBitcoinHubEntity — recompile prefab in editor." );
			go.Destroy();
			return null;
		}

		hub.BindOwnerFromLocalViewer();
		NetworkSpawnIfNeeded( go );
		// Physics: LpBitcoinHubEntity.OnStart — printer gravity, no ground snap.
		return hub;
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

	private static Vector3 SnapToGround( Vector3 horizontalPoint, float referenceZ )
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
			return horizontalPoint.WithZ( referenceZ );

		try
		{
			var start = horizontalPoint.WithZ( referenceZ ) + Vector3.Up * GroundTraceUp;
			var end = horizontalPoint.WithZ( referenceZ ) - Vector3.Up * GroundTraceDown;
			var trace = scene.Trace.Ray( start, end ).Run();
			if ( !trace.Hit )
				return horizontalPoint.WithZ( referenceZ );

			var hit = trace.HitPosition;
			if ( MathF.Abs( hit.z - referenceZ ) > 256f )
				return horizontalPoint.WithZ( referenceZ );

			return hit;
		}
		catch ( Exception ex ) when ( ex.Message.Contains( "Default Surface", StringComparison.OrdinalIgnoreCase ) )
		{
			return horizontalPoint.WithZ( referenceZ );
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
