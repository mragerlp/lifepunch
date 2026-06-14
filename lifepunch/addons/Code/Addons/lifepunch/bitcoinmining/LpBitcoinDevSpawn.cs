// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// is the sole-owned intellectual property of lifepunch.co. It is NOT licensed for resale,
// redistribution, sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Author account: mrragerlp · Public alias (in-game · Steam · Discord): Bloodwave
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using Sandbox;

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>Dev-only placeholders until v2 prefabs ship — greenfield playtest path.</summary>
public static class LpBitcoinDevSpawn
{
	private const string PlaceholderModel = "models/dev/box.vmdl";

	[ConCmd( "lp_bitcoin_spawn_hub" )]
	public static void SpawnHub()
	{
		var viewer = GetViewerPosition();
		if ( viewer is null )
		{
			Log.Warning( "lp_bitcoin_spawn_hub: no local viewer — play from game.scene first." );
			return;
		}

		SpawnHubAt( viewer.Value + Vector3.Forward * 120f + Vector3.Up * 8f );
		Log.Info( "lp_bitcoin_spawn_hub: v2 hub placed (placeholder box)." );
	}

	[ConCmd( "lp_bitcoin_spawn_kit" )]
	public static void SpawnKit()
	{
		var viewer = GetViewerPosition();
		if ( viewer is null )
		{
			Log.Warning( "lp_bitcoin_spawn_kit: no local viewer — play from game.scene first." );
			return;
		}

		var hub = SpawnHubAt( viewer.Value + Vector3.Forward * 140f );
		if ( hub is null )
			return;

		var origin = hub.WorldPosition;
		SpawnRackAt( origin + Vector3.Right * 80f, hub, large: false );
		SpawnRackAt( origin + Vector3.Right * 160f, hub, large: false );
		SpawnRackAt( origin + Vector3.Left * 80f, hub, large: false );
		SpawnRackAt( origin + Vector3.Left * 160f, hub, large: true );
		Log.Info( "lp_bitcoin_spawn_kit: v2 full kit (hub + 3 small + 1 large placeholders)." );
	}

	private static Vector3? GetViewerPosition()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
			return null;

		var cam = scene.Camera;
		return cam.IsValid() ? cam.WorldPosition : null;
	}

	private static LpBitcoinHubEntity SpawnHubAt( Vector3 pos )
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
			return null;

		var go = scene.CreateObject();
		go.Name = "LpBitcoinHub";
		go.WorldPosition = pos;
		go.WorldScale = new Vector3( 2.5f, 2f, 1.8f );

		var renderer = go.AddComponent<ModelRenderer>();
		renderer.Model = Model.Load( PlaceholderModel );

		var hub = go.AddComponent<LpBitcoinHubEntity>();
		hub.BindOwnerFromLocalViewer();
		return hub;
	}

	private static void SpawnRackAt( Vector3 pos, LpBitcoinHubEntity hub, bool large )
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
			return;

		var go = scene.CreateObject();
		go.Name = large ? "LpBitcoinRackLarge" : "LpBitcoinRack";
		go.WorldPosition = pos;
		go.WorldScale = large ? new Vector3( 1.6f, 1.2f, 2.2f ) : new Vector3( 1.2f, 1f, 1.6f );

		var renderer = go.AddComponent<ModelRenderer>();
		renderer.Model = Model.Load( PlaceholderModel );
		renderer.Tint = large ? new Color( 0.35f, 0.45f, 0.9f ) : new Color( 0.25f, 0.3f, 0.7f );

		var rack = go.AddComponent<LpBitcoinRackEntity>();
		rack.LargeRack = large;
		rack.LinkToHub( hub );
	}
}
