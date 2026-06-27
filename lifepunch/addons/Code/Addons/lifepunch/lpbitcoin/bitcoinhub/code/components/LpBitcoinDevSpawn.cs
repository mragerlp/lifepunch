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

	[ConCmd( "lp_bitcoin_clear_spawns" )]
	public static void ClearSpawns()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_bitcoin_clear_spawns: no active scene." );
			return;
		}

		LpBitcoinUi.CloseAll();

		var destroyed = 0;
		foreach ( var hub in scene.GetAllComponents<LpBitcoinHubEntity>().ToArray() )
		{
			if ( !hub.IsValid() || !hub.GameObject.IsValid() )
				continue;

			hub.GameObject.Destroy();
			destroyed++;
		}

		foreach ( var rack in scene.GetAllComponents<LpBitcoinRackEntity>().ToArray() )
		{
			if ( !rack.IsValid() || !rack.GameObject.IsValid() )
				continue;

			rack.GameObject.Destroy();
			destroyed++;
		}

		foreach ( var terminal in scene.GetAllComponents<LpBitcoinTerminalEntity>().ToArray() )
		{
			if ( !terminal.IsValid() || !terminal.GameObject.IsValid() )
				continue;

			terminal.GameObject.Destroy();
			destroyed++;
		}

		foreach ( var go in scene.GetAllObjects( true ).Where( g => g.Name == "lpbitcoin_staging_hub" ).ToArray() )
		{
			go.Destroy();
			destroyed++;
		}

		Log.Info( $"lp_bitcoin_clear_spawns: removed {destroyed} object(s)." );
	}

	[ConCmd( "lp_bitcoin_spawn_kit" )]
	public static void SpawnKit()
	{
		var hub = SpawnKitInternal();
		if ( hub.IsValid() )
			Log.Info( "lp_bitcoin_spawn_kit: hub + terminal + 2× GPU Rack placed — USE hub or terminal." );
	}

	/// <summary>Dev shortcut — link nearest unlinked terminal to nearest hub (playtest only).</summary>
	[ConCmd( "lp_bitcoin_link_terminal" )]
	public static void LinkTerminal()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_bitcoin_link_terminal: no active scene." );
			return;
		}

		var hub = scene.GetAllComponents<LpBitcoinHubEntity>()
			.Where( h => h.IsValid() )
			.OrderBy( h => DistanceToViewer( h.WorldPosition ) )
			.FirstOrDefault();

		if ( !hub.IsValid() )
		{
			Log.Warning( "lp_bitcoin_link_terminal: no hub — run lp_bitcoin_spawn_kit first." );
			return;
		}

		hub.BindOwnerFromLocalViewer();
		if ( !hub.IsPowered )
		{
			Log.Warning( "lp_bitcoin_link_terminal: hub power off — run lp_bitcoin_hub_power_toggle or use header switch first." );
			return;
		}

		var terminal = LpBitcoinTerminalEntity.FindNearestUnlinked( hub );
		if ( !terminal.IsValid() )
		{
			Log.Warning( "lp_bitcoin_link_terminal: no unlinked terminal in range — spawn one near the hub." );
			return;
		}

		hub.LinkTerminalHost( terminal );
		Log.Info( $"lp_bitcoin_link_terminal: linked={hub.HasLinkedTerminal()} terminal={terminal.WorldPosition}" );
	}

	/// <summary>Dev shortcut — power hub + start all linked racks (does not link terminal or racks).</summary>
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
			.FirstOrDefault();

		if ( !hub.IsValid() )
		{
			Log.Warning( "lp_bitcoin_playtest_mining: no hub — run lp_bitcoin_spawn_kit first." );
			return;
		}

		hub.BindOwnerFromLocalViewer();
		hub.ApplyPoweredState( true );

		var racks = hub.GetLinkedRacks();
		foreach ( var rack in racks )
			rack.RequestSetMining( true );

		Log.Info( $"lp_bitcoin_playtest_mining: hub ON, {racks.Count} linked rack(s) mining." );
#endif
	}

	/// <summary>Dev shortcut — link nearest terminal + all unlinked racks in range (skips player setup).</summary>
	[ConCmd( "lp_bitcoin_dev_link_all" )]
	public static void DevLinkAll()
	{
#if LIFEPUNCH_LOCAL
		Log.Warning( "lp_bitcoin_dev_link_all: DXRP project only." );
#else
		if ( !Networking.IsHost )
		{
			Log.Warning( "lp_bitcoin_dev_link_all: host only." );
			return;
		}

		var scene = Game.ActiveScene;
		if ( scene is null )
			return;

		var hub = scene.GetAllComponents<LpBitcoinHubEntity>().FirstOrDefault( h => h.IsValid() );
		if ( !hub.IsValid() )
		{
			Log.Warning( "lp_bitcoin_dev_link_all: no hub." );
			return;
		}

		hub.BindOwnerFromLocalViewer();

		if ( !hub.HasLinkedTerminal() )
		{
			var terminal = LpBitcoinTerminalEntity.FindNearestUnlinked( hub );
			if ( terminal.IsValid() )
				hub.LinkTerminalHost( terminal );
		}

		var linked = 0;
		while ( true )
		{
			var rack = LpBitcoinRackEntity.FindNearestUnlinked( hub, hub.RackLinkRange );
			if ( !rack.IsValid() )
				break;

			rack.LinkToHub( hub );
			linked++;
		}

		Log.Info( $"lp_bitcoin_dev_link_all: terminal={( hub.HasLinkedTerminal() ? "linked" : "none" )}, racks={linked}." );
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
			var tag = LpBitcoinIdent.RackSlug;
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

		foreach ( var hub in scene.GetAllComponents<LpBitcoinHubEntity>().Where( h => h.IsValid() ) )
		{
			var renderer = hub.Components.Get<ModelRenderer>( FindMode.EverythingInSelf );
			var legacyStatusLed = hub.GameObject.Children
				.FirstOrDefault( c => c.IsValid() && c.Name.Equals( "status_led", StringComparison.OrdinalIgnoreCase ) );
			var legacyGlow = hub.GameObject.Children
				.FirstOrDefault( c => c.IsValid() && c.Name.Equals( "hub_status_glow", StringComparison.OrdinalIgnoreCase ) );

			Log.Info(
				$"BITCOINMINING_STATUS_LED hub powered={hub.IsPowered} emissive=fence-led-mesh-only legacyStatusLed={( legacyStatusLed.IsValid() ? "present (respawn hub to purge)" : "none" )} legacyGlow={( legacyGlow.IsValid() ? "present (respawn hub to purge)" : "none" )}" );

			if ( !renderer.IsValid() )
				continue;

			var bounds = renderer.LocalBounds;
			Log.Info(
				$"BITCOINMINING_STATUS_LED bounds center={bounds.Center} size={bounds.Size} mins={bounds.Mins} maxs={bounds.Maxs}" );

			for ( var i = 0; i < renderer.Materials.Count; i++ )
			{
				var mat = renderer.Materials.GetOriginal( i );
				if ( mat is null || !mat.IsValid() )
					continue;

				if ( !mat.ResourcePath.Contains( "fence-led", StringComparison.OrdinalIgnoreCase ) )
					continue;

				Log.Info( $"BITCOINMINING_STATUS_LED slot={i} path={mat.ResourcePath} F_SELF_ILLUM={mat.GetFeature( "F_SELF_ILLUM" )}" );
			}
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

	/// <summary>Hub + terminal + one GPU rack farm — flatgrass hero lineup.</summary>
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
		SpawnRackPrefab( RackSpawnTransform( transform, sideOffset: -120f ) );
		Log.Info( "lp_bitcoin_spawn_lineup: Bitcoin Hub + Terminal + GPU Rack placed." );
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

		SpawnRackPrefab( transform );
		Log.Info( "lp_bitcoin_spawn_rack: GPU Rack placed (unlinked — register at rig0> link)." );
	}

	[ConCmd( "lp_bitcoin_spawn_stacked_rack" )]
	public static void SpawnStackedRack()
	{
		if ( !LifePunchMarketSpawn.TryGetIdentitySpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_bitcoin_spawn_stacked_rack: no local viewer — play from game.scene first." );
			return;
		}

		SpawnStackedRackPrefab( transform );
		Log.Info( "lp_bitcoin_spawn_stacked_rack: stacked GPU Rack placed (unlinked — register at rig0> link)." );
	}

	/// <summary>Hub + terminal + standard rack + stacked rack — flatgrass hero lineup (no auto-link).</summary>
	[ConCmd( "lp_bitcoin_spawn_four_prefabs" )]
	public static void SpawnFourPrefabs()
	{
		if ( !LifePunchMarketSpawn.TryGetIdentitySpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_bitcoin_spawn_four_prefabs: no local viewer — play from game.scene first." );
			return;
		}

		var hub = SpawnHubPrefab( transform );
		if ( !hub.IsValid() )
			return;

		var origin = transform.Position;
		var rot = transform.Rotation;
		var groundZ = origin.z;
		SpawnTerminalPrefab( new Transform( SnapToGround( origin + rot.Forward * 100f, groundZ ), rot ) );
		SpawnRackPrefab( RackSpawnTransform( transform, sideOffset: -120f ) );
		SpawnStackedRackPrefab( RackSpawnTransform( transform, sideOffset: 120f ) );
		Log.Info( "lp_bitcoin_spawn_four_prefabs: hub + terminal + gpu-rack + gpu-rack-stacked placed (unlinked)." );
		LogBitcoinSpawnAudit();
	}

	/// <summary>Full realistic set: 1 Hub + 1 Terminal + 2 standard GPU Racks + 1 Advanced GPU Rack.</summary>
	[ConCmd( "lp_bitcoin_spawn_five_prefabs" )]
	public static void SpawnFivePrefabs()
	{
		if ( !LifePunchMarketSpawn.TryGetIdentitySpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_bitcoin_spawn_five_prefabs: no local viewer — play from game.scene first." );
			return;
		}

		var hub = SpawnHubPrefab( transform );
		if ( !hub.IsValid() )
			return;

		var origin = transform.Position;
		var rot = transform.Rotation;
		var groundZ = origin.z;

		SpawnTerminalPrefab( new Transform( SnapToGround( origin + rot.Forward * 110f, groundZ ), rot ) );

		// Two standard racks on the left side
		SpawnRackPrefab( RackSpawnTransform( transform, sideOffset: -130f ) );
		SpawnRackPrefab( RackSpawnTransform( transform, sideOffset: -260f ) );

		// One advanced rack on the right side
		SpawnStackedRackPrefab( RackSpawnTransform( transform, sideOffset: +130f ) );

		Log.Info( "lp_bitcoin_spawn_five_prefabs: 1 hub + 1 terminal + 2× standard rack + 1 advanced rack placed (unlinked)." );
		LogBitcoinSpawnAudit();
	}

	/// <summary>Legacy alias — same as <see cref="SpawnRack"/> (advanced tier merged into GPU Rack).</summary>
	[ConCmd( "lp_spawn_advanced_gpu_rack" )]
	public static void SpawnAdvancedRack() => SpawnRack();

	/// <summary>Legacy alias — docs/playtest still reference v1 command name.</summary>
	[ConCmd( "lp_spawn_gpu_rack" )]
	public static void SpawnGpuRackLegacy() => SpawnRack();

	/// <summary>Legacy alias — stacked rack spawn.</summary>
	[ConCmd( "lp_spawn_large_gpu_rack" )]
	public static void SpawnLargeGpuRackLegacy() => SpawnStackedRack();

	/// <summary>Legacy — hub + terminal + advanced GPU rack (standard rack parked).</summary>
	[ConCmd( "lp_spawn_bitcoinmining_full_kit" )]
	public static void SpawnBitcoinMiningFullKitLegacy()
	{
		if ( !LifePunchMarketSpawn.TryGetIdentitySpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_spawn_bitcoinmining_full_kit: no local viewer — play from game.scene first." );
			return;
		}

		var origin = transform.Position;
		var rot = transform.Rotation;
		var groundZ = origin.z;

		var hub = SpawnHubPrefab( new Transform( SnapToGround( origin, groundZ ), rot ) );
		var advanced = SpawnRackPrefab( RackSpawnTransform( transform, sideOffset: -120f ) );
		var terminal = SpawnTerminalPrefab(
			new Transform( SnapToGround( origin + rot.Forward * 100f, groundZ ), rot ) );

		if ( hub.IsValid() && terminal.IsValid() && hub.IsPowered )
			hub.LinkTerminalHost( terminal );

		Log.Info(
			$"lp_spawn_bitcoinmining_full_kit: hub={( hub.IsValid() ? "ok" : "FAIL" )} advanced={( advanced.IsValid() ? "ok" : "FAIL" )} terminal={( terminal.IsValid() ? "ok" : "FAIL" )} linked={( hub.IsValid() && hub.HasLinkedTerminal() ).ToString().ToLowerInvariant()}." );

		LogBitcoinSpawnAudit();
	}

	[ConCmd( "lp_gpu_rack_count" )]
	public static void LogGpuRackCount() => LogBitcoinSpawnAudit();

	[ConCmd( "lp_bitcoin_spawn_audit" )]
	public static void LogBitcoinSpawnAudit()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_gpu_rack_count: no active scene." );
			return;
		}

		var racks = scene.GetAllComponents<LpBitcoinRackEntity>().Where( r => r.IsValid() ).ToList();
		var hubs = scene.GetAllComponents<LpBitcoinHubEntity>().Where( h => h.IsValid() ).ToList();
		var terminals = scene.GetAllComponents<LpBitcoinTerminalEntity>().Where( t => t.IsValid() ).ToList();
		Log.Info(
			$"lp_bitcoin_spawn_audit: hubs={hubs.Count} racks={racks.Count} terminals={terminals.Count}" );

		foreach ( var hub in hubs )
			LogSpawnEntityRow( "bitcoin-hub", hub.GameObject, LpBitcoinIdent.HubModelPath );

		foreach ( var terminal in terminals )
		{
			var linked = terminal.IsLinkedToHub();
			LogSpawnEntityRow( "bitcoin-terminal", terminal.GameObject, LpBitcoinIdent.TerminalModelPath );
			Log.Info( $"    terminal linkedToHub={linked} lcdManual={terminal.ManualLcdPlacement}" );
		}

		foreach ( var rack in racks )
			LogSpawnEntityRow( LpBitcoinIdent.RackSlug, rack.GameObject, LpBitcoinIdent.RackModelPath );
	}

	private static void LogSpawnEntityRow( string tag, GameObject go, string expectedModelPath )
	{
		if ( !go.IsValid() )
		{
			Log.Warning( $"  {tag}: invalid GameObject" );
			return;
		}

		var renderer = go.Components.Get<ModelRenderer>( FindMode.EverythingInSelf );
		var model = renderer.IsValid() ? renderer.Model : null;
		var modelPath = model.IsValid() ? model.ResourcePath : "(missing — recompile vmdl in ModelDoc)";
		var bounds = model.IsValid() ? model.Bounds : default;
		Log.Info( $"  {tag} pos={go.WorldPosition} model={modelPath} boundsSize={bounds.Size}" );
		if ( !model.IsValid() )
			Log.Warning( $"  {tag}: open '{expectedModelPath}' in ModelDoc and compile." );
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

	/// <summary>Hub admin on the upgrades sub-view — sample racks + buy buttons (PIN bypassed).</summary>
	[ConCmd( "lp_bitcoin_preview_hub_upgrades" )]
	public static void PreviewHubUpgradesUi()
	{
		WarnIfWrongPlayScene();
		LpBitcoinUi.CloseAll();
		var hub = LpBitcoinUi.GetOrCreatePreviewHub( withSampleRacks: true );
		if ( !hub.IsValid() )
		{
			Log.Warning( "lp_bitcoin_preview_hub_upgrades: no active scene." );
			return;
		}

		var panel = LpHashdUiHost.Open( hub );
		panel?.DevBypassPinGate();
		panel?.DevOpenUpgradesForFirstLinkedRack();
		Log.Info( "lp_bitcoin_preview_hub_upgrades: rack upgrades open — check buy buttons + intro line." );
	}

	/// <summary>Hub admin on the wallet tab — cash-out tiles + bank deposit preview (PIN bypassed).</summary>
	[ConCmd( "lp_bitcoin_preview_hub_wallet" )]
	public static void PreviewHubWalletUi()
	{
		WarnIfWrongPlayScene();
		LpBitcoinUi.CloseAll();
		var hub = LpBitcoinUi.GetOrCreatePreviewHub( withSampleRacks: true );
		if ( !hub.IsValid() )
		{
			Log.Warning( "lp_bitcoin_preview_hub_wallet: no active scene." );
			return;
		}

		var panel = LpHashdUiHost.Open( hub );
		panel?.DevBypassPinGate();
		panel?.DevOpenWalletTab();
		Log.Info( "lp_bitcoin_preview_hub_wallet: wallet tab open — check cash-out tile layout." );
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
			var tag = LpBitcoinIdent.RackSlug;
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
			.OrderBy( r => r.GameObject.Name )
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
				.OrderBy( r => r.GameObject.Name )
				.ToList();
		}

		foreach ( var rack in racks )
			LogRackAnimAudit( rack );
	}

	private static void LogRackAnimAudit( LpBitcoinRackEntity rack )
	{
		if ( !rack.IsValid() )
			return;

		var tag = LpBitcoinIdent.RackSlug;
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
			var vmdl = "gpu-rack-stacked.vmdl";
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
		SpawnRackPrefab( RackSpawnTransform( transform, sideOffset: 100f ) );
		SpawnRackPrefab( RackSpawnTransform( transform, sideOffset: -100f ) );
		SpawnTerminalPrefab( new Transform( SnapToGround( origin + rot.Forward * 100f, groundZ ), rot ) );
		return hub;
	}

	private static Transform RackSpawnTransform( Transform marketSpawn, float sideOffset, float forwardOffset = 0f )
	{
		var rot = marketSpawn.Rotation;
		var groundZ = marketSpawn.Position.z;
		var horizontal = marketSpawn.Position + rot.Right * sideOffset + rot.Forward * forwardOffset;
		var pos = SnapToGround( horizontal, groundZ );
		return new Transform( pos, rot );
	}

	private static LpBitcoinRackEntity SpawnRackPrefab( Transform transform )
		=> SpawnRackPrefabInternal( transform, stacked: false );

	private static LpBitcoinRackEntity SpawnStackedRackPrefab( Transform transform )
		=> SpawnRackPrefabInternal( transform, stacked: true );

	private static void ApplyStackedRackModel( GameObject go )
	{
		var stackedModel = Model.Load( LpBitcoinIdent.StackedRackModelPath );
		if ( !stackedModel.IsValid() )
		{
			Log.Warning(
				$"lp_bitcoin: stacked vmdl missing — compile '{LpBitcoinIdent.StackedRackModelPath}' in ModelDoc." );
			return;
		}

		var renderer = go.Components.Get<ModelRenderer>( FindMode.EverythingInSelf );
		if ( renderer.IsValid() )
			renderer.Model = stackedModel;
	}

	private static LpBitcoinRackEntity SpawnRackPrefabInternal( Transform transform, bool stacked )
	{
		var path = stacked ? LpBitcoinIdent.StackedRackPrefabPath : LpBitcoinIdent.RackPrefabPath;
		var label = stacked ? $"{LpBitcoinIdent.RackDisplayName} (stacked)" : LpBitcoinIdent.RackDisplayName;
		var go = ClonePrefabAt( path, transform );
		if ( !go.IsValid() && stacked )
		{
			Log.Warning(
				$"lp_bitcoin: '{path}' missing — fallback gpu-rack prefab + stacked vmdl (bake prefab_c in editor)." );
			go = ClonePrefabAt( LpBitcoinIdent.RackPrefabPath, transform );
			if ( go.IsValid() )
				ApplyStackedRackModel( go );
		}

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
			rack.AdvancedRack = stacked;
			rack.DevSpawnAsWorldMachine = true;
		}

		NetworkSpawnIfNeeded( go );

		var renderer = go.Components.Get<ModelRenderer>( FindMode.EverythingInSelf );
		if ( !renderer.IsValid() || !renderer.Model.IsValid() )
			Log.Warning( $"lp_bitcoin: {label} spawned but model missing — open '{path}' + vmdl in ModelDoc and recompile." );

		Log.Info( $"lp_bitcoin: {label} placed at {go.WorldPosition} (unlinked — register at rig0> link)." );
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
			Log.Warning(
				"lp_bitcoin: bitcoinhub.prefab missing LpBitcoinHubEntity — adding at runtime (open prefab in editor + compile to bake prefab_c)." );
			hub = go.AddComponent<LpBitcoinHubEntity>();
		}

		if ( !hub.IsValid() )
		{
			Log.Error( "lp_bitcoin: failed to attach LpBitcoinHubEntity — check game compile for Code/lpbitcoin/bitcoinhub." );
			go.Destroy();
			return null;
		}

		var visuals = go.Components.Get<LpBitcoinHubVisuals>( FindMode.EverythingInSelfAndDescendants );
		if ( !visuals.IsValid() )
			visuals = go.AddComponent<LpBitcoinHubVisuals>();

		if ( visuals.IsValid() && !visuals.Hub.IsValid() )
			visuals.Hub = hub;

		hub.DevSpawnAsWorldMachine = true;
		hub.BindOwnerFromLocalViewer();
		NetworkSpawnIfNeeded( go );
		// Physics: LpBitcoinHubEntity.OnStart — printer gravity, no ground snap.
		return hub;
	}

	private static LpBitcoinTerminalEntity SpawnTerminalPrefab( Transform transform )
	{
		var go = ClonePrefabAt( LpBitcoinIdent.TerminalPrefabPath, transform );
		if ( !go.IsValid() )
		{
			Log.Error( $"lp_bitcoin: failed to spawn terminal — recompile '{LpBitcoinIdent.TerminalPrefabPath}'." );
			return null;
		}

		var terminal = go.Components.Get<LpBitcoinTerminalEntity>( FindMode.EverythingInSelfAndDescendants );
		if ( !terminal.IsValid() )
			terminal = go.AddComponent<LpBitcoinTerminalEntity>();

		if ( terminal.IsValid() )
			terminal.DevSpawnAsWorldMachine = true;

		NetworkSpawnIfNeeded( go );

		var renderer = go.Components.Get<ModelRenderer>( FindMode.EverythingInSelf );
		if ( !renderer.IsValid() || !renderer.Model.IsValid() )
			Log.Warning( $"lp_bitcoin: terminal spawned but model missing — open '{LpBitcoinIdent.TerminalModelPath}' in ModelDoc and recompile." );

		Log.Info( $"lp_bitcoin: terminal placed at {go.WorldPosition}" );
		return terminal;
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
