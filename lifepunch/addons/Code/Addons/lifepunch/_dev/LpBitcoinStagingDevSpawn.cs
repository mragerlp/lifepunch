// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LifePunch Dev Tools" (s&box ident: lifepunch.dev · addon ident: dev) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System.Linq;
using Sandbox;

namespace LifePunch.DXRP.Addons.Dev;

/// <summary>
/// Model Foundation playtest — spawns <c>lpbitcoin</c> staging meshes only (not legacy ship prefabs).
/// </summary>
public static class LpBitcoinStagingDevSpawn
{
	public const string StagingHubVmdl =
		"addons/lifepunch/lpbitcoin/bitcoinhub/assets/models/bitcoin-hub.vmdl";

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
