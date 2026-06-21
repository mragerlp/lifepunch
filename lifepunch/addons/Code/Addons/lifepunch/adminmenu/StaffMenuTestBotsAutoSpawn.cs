// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH ULX for DXRP" (s&box ident: lifepunch.ulx · addon ident: lifepunchulx) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Author account: mrragerlp · Public alias (in-game · Steam · Discord): Bloodwave
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

#if !LIFEPUNCH_LOCAL

using Sandbox;
using Dxura.RP.Game;

namespace LifePunch.DXRP.Addons.StaffMenu;

/// <summary>
/// Editor play only: spawns scroll-test fillers as soon as host + local pawn exist; adds the rank
/// roster once the DXRP portal API is ready (<c>lp_authorize</c>). Fillers need no portal auth.
/// </summary>
public sealed class StaffMenuTestBotsAutoSpawn : GameObjectSystem<StaffMenuTestBotsAutoSpawn>, IGameEvents
{
	[ConVar( "lifepunch_auto_spawn_testbots", ConVarFlags.Saved )]
	public static bool AutoSpawn { get; set; } = true;

	[ConVar( "lifepunch_auto_spawn_testbots_fill", ConVarFlags.Saved )]
	public static int AutoSpawnFill { get; set; } = StaffMenuTestBots.DefaultScrollFillCount;

	private bool _spawnedScrollFill;
	private bool _spawnedRankRoster;

	public StaffMenuTestBotsAutoSpawn( Scene scene ) : base( scene )
	{
		Listen( Stage.StartUpdate, 0, Tick, "LifePunch test bot auto-spawn" );
	}

	private void Tick()
	{
		if ( !Application.IsEditor )
		{
			return;
		}

		if ( !Networking.IsActive )
		{
			_spawnedScrollFill = false;
			_spawnedRankRoster = false;
			return;
		}

		if ( !AutoSpawn || !Networking.IsHost )
		{
			return;
		}

		if ( !Player.Local.IsValid() )
		{
			return;
		}

		if ( !_spawnedScrollFill )
		{
			_spawnedScrollFill = true;
			var filled = StaffMenuTestBots.SpawnScrollFillBots( AutoSpawnFill );
			Log.Info( $"lifepunch_auto_spawn_testbots: {filled} sidebar scroll fillers (no portal auth required)." );
		}

		if ( _spawnedRankRoster )
		{
			return;
		}

		if ( !ServerApiLink.HasAuthorizationKey || !Config.Current.IsReady )
		{
			return;
		}

		var ranks = RankSystem.Instance;
		if ( !ranks.IsValid() || !StaffMenuTestBots.TryFindRankIdByName( ranks, "VIP" ).HasValue )
		{
			return;
		}

		_spawnedRankRoster = true;
		StaffMenuTestBots.SpawnRankBots( false );
		Log.Info( "lifepunch_auto_spawn_testbots: rank bot roster spawned (after portal auth)." );
	}
}

#endif
