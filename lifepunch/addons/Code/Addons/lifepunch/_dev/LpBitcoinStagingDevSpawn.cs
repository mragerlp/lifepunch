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

namespace LifePunch.DXRP.Addons.Dev;

/// <summary>
/// Model Foundation playtest — spawns <c>lpbitcoin</c> staging meshes and hub prop candidates.
/// </summary>
public static class LpBitcoinStagingDevSpawn
{
	public const string StagingHubVmdl =
		"addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/bitcoin-miner/bitcoin-miner.vmdl";

	static readonly (string Id, string Vmdl, string Note)[] HubModelCandidates =
	{
		( "steam-machine", "addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/bitcoin-miner/bitcoin-miner.vmdl", "Legacy ship hub — sm_* vmats + _c in repo" ),
		( "sketchfab-pc", "addons/lifepunch/lpbitcoin/bitcoinhub/assets/models/bitcoin-hub.vmdl", "PARKED — texture mount broken in play" ),
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

		if ( !TryGetSpawnTransform( out var transform ) )
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

	[ConCmd( "lp_spawn_staging_hub" )]
	public static void SpawnStagingHub()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "lp_spawn_staging_hub: no active scene — Host Play from game.scene first." );
			return;
		}

		if ( !TryGetSpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_spawn_staging_hub: no local viewer." );
			return;
		}

		foreach ( var existing in scene.GetAllObjects( true ) )
		{
			if ( existing.Name == "lpbitcoin_staging_hub" )
				existing.Destroy();
		}

		var model = Model.Load( StagingHubVmdl );
		if ( !model.IsValid )
		{
			Log.Error( $"lp_spawn_staging_hub: could not load '{StagingHubVmdl}' — compile bitcoin-hub.vmdl in ModelDoc first." );
			return;
		}

		var go = scene.CreateObject();
		go.Name = "lpbitcoin_staging_hub";
		go.WorldTransform = transform;

		var renderer = go.Components.Create<ModelRenderer>();
		renderer.Model = model;

		var bounds = model.Bounds;
		Log.Info( $"lp_spawn_staging_hub: bitcoin hub placed at {go.WorldPosition} — bounds size={bounds.Size} center={bounds.Center}" );
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

		GameObject hub = default;
		foreach ( var go in scene.GetAllObjects( true ) )
		{
			if ( go.Name == "lpbitcoin_staging_hub" )
			{
				hub = go;
				break;
			}
		}

		if ( !hub.IsValid() )
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

		var b = renderer.Model.Bounds;
		Log.Info( $"LPBITCOIN_STAGING_HUB_AUDIT center={b.Center} size={b.Size} worldPos={hub.WorldPosition}" );
	}

	static bool TryGetSpawnTransform( out Transform transform )
	{
		transform = default;
		const float spawnDistance = 80f;
		var scene = Game.ActiveScene;
		var player = Player.Local;
		if ( player.IsValid() && player.Controller.IsValid() )
		{
			var flatForward = player.Controller.EyeAngles.ToRotation().Forward.WithZ( 0 ).Normal;
			if ( flatForward.Length < 0.01f )
				flatForward = Vector3.Forward;

			var pos = player.WorldPosition + flatForward * spawnDistance;
			pos = new Vector3( pos.x, pos.y, 0f );
			transform = new Transform( pos, Rotation.LookAt( flatForward ) );
			return true;
		}

		var camera = scene?.GetAllComponents<CameraComponent>().FirstOrDefault();
		if ( camera.IsValid() )
		{
			var camForward = camera.WorldRotation.Forward.WithZ( 0 ).Normal;
			if ( camForward.Length < 0.01f )
				camForward = Vector3.Forward;

			var pos = camera.WorldPosition + camForward * spawnDistance;
			pos = new Vector3( pos.x, pos.y, 0f );
			transform = new Transform( pos, Rotation.LookAt( camForward ) );
			return true;
		}

		// blank.scene — spawn close to origin on the ground plane.
		transform = new Transform( new Vector3( 0f, spawnDistance, 0f ), Rotation.Identity );
		return true;
	}
}
