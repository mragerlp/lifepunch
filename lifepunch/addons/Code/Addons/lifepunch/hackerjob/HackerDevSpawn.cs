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
	public static void SpawnTerminal()
	{
		if ( !TryGetSpawnTransform( out var transform ) )
		{
			Log.Warning( "lp_spawn_hacker_terminal: no local viewer." );
			return;
		}

		var prefab = GameObject.GetPrefab( HackerJob.WorldPrefabPath );
		if ( !prefab.IsValid() )
		{
			Log.Error( $"lp_spawn_hacker_terminal: could not load '{HackerJob.WorldPrefabPath}'." );
			return;
		}

		var terminal = prefab.Clone( new CloneConfig { Transform = transform } );
		if ( !terminal.IsValid() )
		{
			Log.Error( "lp_spawn_hacker_terminal: clone failed." );
			return;
		}

#if !LIFEPUNCH_LOCAL
		var player = Player.Local;
		if ( player.IsValid() )
			terminal.NetworkSpawn( player.Network.Owner );
		else
			terminal.NetworkSpawn();
#endif

		Log.Info( "lp_spawn_hacker_terminal: placed. Stand within 6m and run cornerman or hack." );
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
