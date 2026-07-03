// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LifePunch Dev Tools" (s&box ident: lifepunch.dev · addon ident: dev) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System.Collections.Generic;
using System.Linq;
using Sandbox;
using LifePunch.DXRP.Addons;
using LifePunch.DXRP.Addons.Bitcoin;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
#endif

namespace LifePunch.DXRP.Addons.Dev;

/// <summary>
/// Model Foundation playtest — spawns <c>lpbitcoin</c> staging meshes and hub prop candidates.
/// Spawn law: same as DXRP market — aim-ray surface + buffer, <see cref="Rotation.Identity"/> (orientation = vmdl import_rotation only).
/// </summary>
public static class LpBitcoinStagingDevSpawn
{
	public const string StagingHubVmdl =
		"addons/lifepunch/lpbitcoin/bitcoinhub/assets/models/bitcoinhub.vmdl";

	public const string StagingHubPrefab =
		"addons/lifepunch/lpbitcoin/bitcoinhub/assets/entities/bitcoinhub.prefab";

	public const string StagingTerminalVmdl =
		"addons/lifepunch/lpbitcoin/hashdterminal/assets/models/hashdterminal.vmdl";

	public const string ShippedTerminalPrefab = LpBitcoinIdent.TerminalPrefabPath;

	public const string DxrpPrinterPrefab = "gameplay/entities/printer/printer.prefab";

	static readonly (string Id, string Vmdl, string Note)[] HubModelCandidates =
	{
		( "steam-machine", "addons/lifepunch/lpbitcoin/bitcoinhub/assets/models/bitcoinhub.vmdl", "Ship hub — lpbitcoin/bitcoinhub staging" ),
		( "dxrp-printer", "gameplay/entities/printer/models/printer.vmdl", "DXRP ingame prop — collider reference" ),
		( "dxrp-slot", "gameplay/entities/jobs/casino_manager/slot_machine/model/slot_machine.vmdl", "DXRP ingame — boxy machine silhouette" ),
		( "dxrp-dry-rack", "gameplay/entities/jobs/drug_dealer/dry_rack/model/dry_rack.vmdl", "DXRP ingame — rack/shelf form" ),
	};

	[ConCmd( "lp_staging_model_list" )]
	public static void StagingModelList()
	{
		Log.Info( "LPBITCOIN_HUB_MODEL_CANDIDATES (use lp_staging_model_lineup or lp_spawn_staging_model <id>)" );
		foreach ( var (id, vmdl, note) in HubModelCandidates )
			Log.Info( $"  {id}: {vmdl} — {note}" );
	}

	[ConCmd( "lp_staging_model_lineup" )]
	public static void StagingModelLineup()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_staging_model_lineup: no active scene — Host Play blank.scene first." );
			return;
		}

		ClearModelPreviews( scene );

		const float spacing = 120f;
		var rowStart = new Vector3( -(HubModelCandidates.Length - 1) * spacing * 0.5f, 120f, 0f );

		for ( var i = 0; i < HubModelCandidates.Length; i++ )
		{
			var (id, vmdl, note) = HubModelCandidates[i];
			var pos = rowStart + new Vector3( i * spacing, 0f, 0f );
			SpawnModelPreview( scene, id, vmdl, new Transform( pos, Rotation.Identity ), note );
		}

		Log.Info( "lp_staging_model_lineup: hub candidates placed in a row — compare materials + scale in viewport." );
	}

	/// <summary>Four steam-machine previews @ Y=0/90/180/270 (identity spawn row) — pick correct front, bake Y into vmdl import_rotation.</summary>
	[ConCmd( "lp_staging_hub_facing_row" )]
	public static void StagingHubFacingRow()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_staging_hub_facing_row: no active scene — Host Play blank.scene first." );
			return;
		}

		ClearModelPreviews( scene );

		const float spacing = 80f;
		var basePos = new Vector3( 0f, 160f, 0f );
		var yaws = new[] { 0f, 90f, 180f, 270f };

		for ( var i = 0; i < yaws.Length; i++ )
		{
			var yaw = yaws[i];
			var pos = basePos + new Vector3( ( i - 1.5f ) * spacing, 0f, 0f );
			var rot = Rotation.FromYaw( yaw );
			SpawnModelPreview( scene, $"steam-y{yaw:F0}", StagingHubVmdl, new Transform( pos, rot ),
				$"Y={yaw:F0}° — panel/LED side should read as FRONT toward -Y spawn" );
		}

		Log.Info( "lp_staging_hub_facing_row: stand @ origin facing +Y — whichever preview shows panel toward you wins; bake that Y into import_rotation." );
	}

	[ConCmd( "lp_spawn_staging_model" )]
	public static void SpawnStagingModel( string id )
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_spawn_staging_model: no active scene." );
			return;
		}

		if ( string.IsNullOrWhiteSpace( id ) )
		{
			StagingModelList();
			return;
		}

		var match = HubModelCandidates.FirstOrDefault( c => c.Id.Equals( id, System.StringComparison.OrdinalIgnoreCase ) );
		if ( match.Vmdl is null )
		{
			Log.Warning( $"lp_spawn_staging_model: unknown id '{id}' — run lp_staging_model_list." );
			return;
		}

		if ( !LifePunchMarketSpawn.TryGetIdentitySpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_spawn_staging_model: no local viewer." );
			return;
		}

		ClearModelPreviews( scene );
		SpawnModelPreview( scene, match.Id, match.Vmdl, transform, match.Note );
	}

	static void SpawnModelPreview( Scene scene, string id, string vmdlPath, Transform transform, string note )
	{
		var model = Model.Load( vmdlPath );
		if ( !model.IsValid )
		{
			Log.Warning( $"LPBITCOIN_MODEL_PREVIEW {id}: FAILED load '{vmdlPath}' — mount/compile missing?" );
			return;
		}

		var go = scene.CreateObject();
		go.Name = $"lpbitcoin_model_preview_{id}";
		go.WorldTransform = transform;

		var renderer = go.Components.Create<ModelRenderer>();
		renderer.Model = model;

		var b = model.Bounds;
		Log.Info( $"LPBITCOIN_MODEL_PREVIEW {id}: ok size={b.Size} center={b.Center} pos={go.WorldPosition} — {note}" );
	}

	static void ClearModelPreviews( Scene scene )
	{
		foreach ( var existing in scene.GetAllObjects( true ).Where( go => go.Name.StartsWith( "lpbitcoin_model_preview_" ) ).ToList() )
			existing.Destroy();
	}

	/// <summary>Steam Machine PC workstation — mesh-only preview at market spawn.</summary>
	[ConCmd( "lp_staging_terminal_clear" )]
	public static void StagingTerminalClear()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_staging_terminal_clear: no active scene." );
			return;
		}

		ClearStagingTerminal( scene );
		Log.Info( "lp_staging_terminal_clear: removed staging terminal previews (stops hashd vmat hot-loop if compare was left spawned)." );
	}

	[ConCmd( "lp_spawn_staging_terminal" )]
	public static void SpawnStagingTerminal()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_spawn_staging_terminal: no active scene — Host Play first." );
			return;
		}

		if ( !LifePunchMarketSpawn.TryGetIdentitySpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_spawn_staging_terminal: no local viewer." );
			return;
		}

		ClearStagingTerminal( scene );
		SpawnStagingTerminalEntity( scene, transform );
	}

	/// <summary>Mesh-only preview — scale/material compare without gameplay stack.</summary>
	[ConCmd( "lp_spawn_staging_terminal_mesh" )]
	public static void SpawnStagingTerminalMesh()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_spawn_staging_terminal_mesh: no active scene — Host Play first." );
			return;
		}

		if ( !LifePunchMarketSpawn.TryGetIdentitySpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_spawn_staging_terminal_mesh: no local viewer." );
			return;
		}

		ClearStagingTerminal( scene );
		SpawnModelPreview( scene, "hashdterminal", StagingTerminalVmdl, transform,
			"HASHD terminal mesh-only — use lp_spawn_staging_terminal for gameplay entity" );
	}

	/// <summary>Legacy CRT vs new HASHD mesh side-by-side (identity rotation).</summary>
	[ConCmd( "lp_staging_terminal_compare" )]
	public static void StagingTerminalCompare()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_staging_terminal_compare: no active scene." );
			return;
		}

		if ( !LifePunchMarketSpawn.TryGetIdentitySpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_staging_terminal_compare: no local viewer." );
			return;
		}

		ClearStagingTerminal( scene );

		const float spacing = 100f;
		var left = transform.WithPosition( transform.Position - transform.Rotation.Right * spacing * 0.5f );
		var right = transform.WithPosition( transform.Position + transform.Rotation.Right * spacing * 0.5f );
		var prefabGo = ClonePrefabAt( ShippedTerminalPrefab, left );
		if ( prefabGo.IsValid() )
			prefabGo.Name = "staging-terminal-prefab";
		SpawnModelPreview( scene, "hashdterminal", StagingTerminalVmdl, right, "hashdterminal.vmdl (right)" );
		Log.Info( "lp_staging_terminal_compare: prefab left, raw vmdl right — same market spawn row." );
	}

	/// <summary>Four Y rotations @ staging terminal vmdl — pick front face for import_rotation bake.</summary>
	[ConCmd( "lp_staging_terminal_facing_row" )]
	public static void StagingTerminalFacingRow()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_staging_terminal_facing_row: no active scene." );
			return;
		}

		ClearStagingTerminal( scene );

		const float spacing = 80f;
		var basePos = new Vector3( 0f, 160f, 0f );
		var yaws = new[] { 0f, 90f, 180f, 270f };

		for ( var i = 0; i < yaws.Length; i++ )
		{
			var yaw = yaws[i];
			var pos = basePos + new Vector3( ( i - 1.5f ) * spacing, 0f, 0f );
			SpawnModelPreview( scene, $"hashd-y{yaw:F0}", StagingTerminalVmdl, new Transform( pos, Rotation.FromYaw( yaw ) ),
				$"Y={yaw:F0}° — monitor should face player at identity spawn" );
		}

		Log.Info( "lp_staging_terminal_facing_row: stand @ origin facing +Y — pick monitor-toward-you, bake Y into vmdl import_rotation." );
	}

	/// <summary>Alias — same as lp_spawn_staging_terminal (gameplay prefab + HASHD vmdl).</summary>
	[ConCmd( "lp_spawn_staging_terminal_prop" )]
	public static void SpawnStagingTerminalProp()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_spawn_staging_terminal_prop: no active scene." );
			return;
		}

		if ( !LifePunchMarketSpawn.TryGetIdentitySpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_spawn_staging_terminal_prop: no local viewer." );
			return;
		}

		ClearStagingTerminal( scene );
		SpawnStagingTerminalEntity( scene, transform );
	}

	static void SpawnStagingTerminalEntity( Scene scene, Transform transform )
	{
		var go = ClonePrefabAt( ShippedTerminalPrefab, transform );
		if ( !go.IsValid() )
		{
			Log.Error( $"lp_spawn_staging_terminal: could not load '{ShippedTerminalPrefab}' — recompile prefab in editor." );
			return;
		}

		go.Name = "lpbitcoin_staging_terminal";

		var terminal = go.Components.Get<LpBitcoinTerminalEntity>( FindMode.EverythingInSelfAndDescendants );
		if ( !terminal.IsValid() )
		{
			Log.Error( "lp_spawn_staging_terminal: prefab missing LpBitcoinTerminalEntity." );
			go.Destroy();
			return;
		}

		var model = Model.Load( StagingTerminalVmdl );
		if ( model.IsValid )
		{
			var renderer = go.Components.Get<ModelRenderer>( FindMode.EverythingInSelf );
			if ( renderer.IsValid() )
				renderer.Model = model;
		}
		else
		{
			Log.Warning( $"lp_spawn_staging_terminal: staging vmdl not loaded — using prefab default '{LpBitcoinIdent.TerminalModelPath}'." );
		}

		NetworkSpawnIfNeeded( go );
		LifePunchPropPhysics.LogModelPhysics( go, "staging_terminal" );
		Log.Info( $"lp_spawn_staging_terminal: Bitcoin Terminal entity at {go.WorldPosition} — gravity drop, model collider, 100 HP, USE opens rig0." );
	}

	[ConCmd( "lp_spawn_staging_hub" )]
	public static void SpawnStagingHub()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_spawn_staging_hub: no active scene — Host Play from game.scene first." );
			return;
		}

		if ( !LifePunchMarketSpawn.TryGetIdentitySpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_spawn_staging_hub: no local viewer." );
			return;
		}

#if !LIFEPUNCH_LOCAL
		LifePunchMarketSpawn.LogMarketSpawnAudit( "lp_spawn_staging_hub" );
#endif

		ClearStagingHub( scene );

		var go = ClonePrefabAt( StagingHubPrefab, transform );
		if ( !go.IsValid() )
		{
			Log.Error( $"lp_spawn_staging_hub: could not load '{StagingHubPrefab}' — compile bitcoinhub.prefab in editor." );
			return;
		}

		go.Name = "lpbitcoin_staging_hub";

		LpBitcoinStagingHubPowerCommands.EnsureHubGameplayStack( go );

		NetworkSpawnIfNeeded( go );
		LifePunchPropPhysics.SetupGrabbablePlaceableProp( go, alignGround: true );
		LifePunchPropPhysics.LogModelPhysics( go, "staging_hub" );
		Log.Info( $"lp_spawn_staging_hub: prefab placed at {go.WorldPosition} — market spawn + ground align" );
	}

	/// <summary>Dev only — re-place existing hub at current market spawn point (does not simulate purchase).</summary>
	[ConCmd( "lp_recall_staging_hub" )]
	public static void RecallStagingHub()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_recall_staging_hub: no active scene." );
			return;
		}

		if ( !TryFindStagingHub( scene, out var hub ) )
		{
			Log.Warning( "lp_recall_staging_hub: no hub — run lp_spawn_staging_hub first." );
			return;
		}

		if ( !LifePunchMarketSpawn.TryGetIdentitySpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_recall_staging_hub: no local viewer." );
			return;
		}

#if !LIFEPUNCH_LOCAL
		LifePunchMarketSpawn.LogMarketSpawnAudit( "lp_recall_staging_hub" );
#endif

		hub.WorldTransform = transform;
		hub.Components.Get<LpBitcoinHubEntity>( FindMode.EverythingInSelf )?.RestartPrinterSettle();
		Log.Info( $"lp_recall_staging_hub: moved to {hub.WorldPosition} — ground realigned" );
	}

	[ConCmd( "lp_staging_hub_ground_fix" )]
	public static void StagingHubGroundFix()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_staging_hub_ground_fix: no active scene." );
			return;
		}

		if ( !TryFindStagingHub( scene, out var hub ) )
		{
			Log.Warning( "lp_staging_hub_ground_fix: no hub — run lp_spawn_staging_hub first." );
			return;
		}

		LifePunchPropPhysics.SetupGrabbablePlaceableProp( hub, alignGround: true );
		Log.Info( $"lp_staging_hub_ground_fix: feet aligned at {hub.WorldPosition}" );
	}

#if !LIFEPUNCH_LOCAL
	[ConCmd( "lp_staging_hub_spawn_audit" )]
	public static void StagingHubSpawnAudit()
	{
		LifePunchMarketSpawn.LogMarketSpawnAudit( "lp_staging_hub_spawn_audit" );
		Log.Info( "lp_staging_hub_spawn_audit: aim at where you want the hub, then lp_spawn_staging_hub or lp_recall_staging_hub." );
	}
#endif

	/// <summary>Side-by-side reference — DXRP money printer prefab with Rigidbody + BoxCollider.</summary>
	[ConCmd( "lp_spawn_staging_printer_ref" )]
	public static void SpawnStagingPrinterRef()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_spawn_staging_printer_ref: no active scene." );
			return;
		}

		if ( !LifePunchMarketSpawn.TryGetIdentitySpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_spawn_staging_printer_ref: no local viewer." );
			return;
		}

		foreach ( var existing in scene.GetAllObjects( true ) )
		{
			if ( existing.Name == "lpbitcoin_staging_printer_ref" )
				existing.Destroy();
		}

		var offset = transform.Rotation.Right * 180f;
		var go = ClonePrefabAt( DxrpPrinterPrefab, transform.WithPosition( transform.Position + offset ) );
		if ( !go.IsValid() )
		{
			Log.Error( $"lp_spawn_staging_printer_ref: could not load '{DxrpPrinterPrefab}'." );
			return;
		}

		go.Name = "lpbitcoin_staging_printer_ref";
		LifePunchGroundContact.AlignMeshBottom( go );
		NetworkSpawnIfNeeded( go );
		LifePunchPropPhysics.LogModelPhysics( go, "printer_ref" );
		Log.Info( "lp_spawn_staging_printer_ref: DXRP printer placed beside aim point — compare feet-on-ground + collision." );
	}

	[ConCmd( "lp_staging_hub_scale_audit" )]
	public static void StagingHubScaleAudit()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_staging_hub_scale_audit: no active scene." );
			return;
		}

		if ( !TryFindStagingHub( scene, out var hub ) )
		{
			Log.Warning( "lp_staging_hub_scale_audit: run lp_spawn_staging_hub first." );
			return;
		}

		var renderer = hub.Components.Get<ModelRenderer>( FindMode.EverythingInSelf );
		if ( !renderer.IsValid() || !renderer.Model.IsValid )
		{
			Log.Warning( "lp_staging_hub_scale_audit: hub has no valid ModelRenderer." );
			return;
		}

		var rigidbody = hub.Components.Get<Rigidbody>( FindMode.EverythingInSelf );
		var box = hub.Components.Get<BoxCollider>( FindMode.EverythingInSelf );
		var b = renderer.Model.Bounds;
		Log.Info( $"LPBITCOIN_STAGING_HUB_AUDIT center={b.Center} size={b.Size} worldPos={hub.WorldPosition} rigidbody={rigidbody.IsValid()} gravity={rigidbody.IsValid() && rigidbody.Gravity} boxCollider={box.IsValid()}" );
		LifePunchPropPhysics.LogModelPhysics( hub, "staging_hub_audit" );
	}

	/// <summary>Trace from local player into staging hub — confirms solid hit (not walk-through).</summary>
	[ConCmd( "lp_staging_hub_collision_probe" )]
	public static void StagingHubCollisionProbe()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_staging_hub_collision_probe: no active scene." );
			return;
		}

		if ( !TryFindStagingHub( scene, out var hub ) )
		{
			Log.Warning( "lp_staging_hub_collision_probe: run lp_spawn_staging_hub first." );
			return;
		}

#if !LIFEPUNCH_LOCAL
		var player = Player.Local;
		if ( !player.IsValid() )
		{
			Log.Warning( "lp_staging_hub_collision_probe: no local player." );
			return;
		}

		var start = player.AimRay.Position;
		var end = start + player.AimRay.Forward * 512f;
#else
		var camera = scene.GetAllComponents<CameraComponent>().FirstOrDefault();
		if ( !camera.IsValid() )
		{
			Log.Warning( "lp_staging_hub_collision_probe: no camera." );
			return;
		}

		var start = camera.WorldPosition;
		var end = start + camera.WorldRotation.Forward * 512f;
#endif

		var trace = scene.Trace.Ray( start, end )
			.WithAnyTags( "solid", "entity" )
			.Run();

		var hitHub = trace.Hit && trace.GameObject.IsValid() &&
		             ( trace.GameObject == hub || trace.GameObject.Root == hub );
		Log.Info( $"LPBITCOIN_STAGING_HUB_COLLISION hit={trace.Hit} hitHub={hitHub} object={trace.GameObject?.Name ?? "(none)"} distance={trace.Distance:F1}" );

		if ( trace.Hit && !hitHub )
			Log.Warning( "lp_staging_hub_collision_probe: aim at hub — trace hit something else." );
		else if ( !trace.Hit )
			Log.Warning( "lp_staging_hub_collision_probe: no hit — collider missing or nocollide." );
	}

	static void ClearStagingHub( Scene scene )
	{
		foreach ( var existing in scene.GetAllObjects( true ) )
		{
			if ( existing.Name == "lpbitcoin_staging_hub" )
				existing.Destroy();
		}
	}

	static void ClearStagingTerminal( Scene scene )
	{
		ClearModelPreviews( scene );

		foreach ( var existing in scene.GetAllObjects( true ) )
		{
			if ( existing.Name is "lpbitcoin_staging_terminal_prop" or "lpbitcoin_staging_terminal" )
				existing.Destroy();
		}
	}

	static bool TryFindStagingHub( Scene scene, out GameObject hub )
	{
		hub = default;
		foreach ( var go in scene.GetAllObjects( true ) )
		{
			if ( go.Name == "lpbitcoin_staging_hub" )
			{
				hub = go;
				return true;
			}
		}

		return false;
	}

	static void EnsurePhysicalPropComponents( GameObject go )
	{
		if ( !go.Components.Get<ModelRenderer>( FindMode.EverythingInSelf ).IsValid() )
		{
			var model = Model.Load( StagingHubVmdl );
			if ( model.IsValid )
			{
				var renderer = go.Components.Create<ModelRenderer>();
				renderer.Model = model;
			}
		}

		if ( !go.Components.Get<Rigidbody>( FindMode.EverythingInSelf ).IsValid() )
		{
			var body = go.Components.Create<Rigidbody>();
			body.Gravity = true;
			body.MotionEnabled = false;
		}

		if ( !go.Components.Get<BoxCollider>( FindMode.EverythingInSelf ).IsValid() )
			go.Components.Create<BoxCollider>();

		LifePunchPropPhysics.SettleAsWorldMachine( go );
	}

	static GameObject ClonePrefabAt( string prefabPath, Transform transform )
	{
#if LIFEPUNCH_LOCAL
		var prefab = GameObject.GetPrefab( prefabPath );
		if ( !prefab.IsValid() )
		{
			Log.Error( $"lp_staging: could not load prefab '{prefabPath}'." );
			return default;
		}

		return prefab.Clone( new CloneConfig { Transform = transform } );
#else
		var prefabFile = PrefabFile.Load( prefabPath );
		if ( prefabFile == null )
		{
			Log.Error( $"lp_staging: PrefabFile.Load failed '{prefabPath}'." );
			return default;
		}

		var prefabScene = SceneUtility.GetPrefabScene( prefabFile );
		if ( prefabScene == null )
		{
			Log.Error( $"lp_staging: GetPrefabScene failed '{prefabPath}'." );
			return default;
		}

		var clone = prefabScene.Clone();
		if ( !clone.IsValid() )
		{
			Log.Error( "lp_staging: scene clone failed." );
			return default;
		}

		clone.WorldTransform = transform;
		return clone;
#endif
	}

	static void NetworkSpawnIfNeeded( GameObject go )
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
}
