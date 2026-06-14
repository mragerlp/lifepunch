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
/// Editor play only: after the DXRP portal API initializes (<c>authorize</c> + host play),
/// clears any stale bots and spawns the full rank roster via <see cref="StaffMenuTestBots"/>.
/// Skips vanilla editor runs without <see cref="ServerApiLink.HasAuthorizationKey"/> so rank
/// assignments match the live LifePunch server node.
/// </summary>
public sealed class StaffMenuTestBotsAutoSpawn : GameObjectSystem<StaffMenuTestBotsAutoSpawn>, IGameEvents
{
	[ConVar( "lifepunch_auto_spawn_testbots", ConVarFlags.Saved )]
	public static bool AutoSpawn { get; set; } = true;

	private bool _spawnedThisSession;

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
			_spawnedThisSession = false;
			return;
		}

		if ( _spawnedThisSession || !AutoSpawn || !Networking.IsHost )
		{
			return;
		}

		if ( !ServerApiLink.HasAuthorizationKey || !Config.Current.IsReady )
		{
			return;
		}

		var ranks = RankSystem.Instance;
		if ( !ranks.IsValid() || !ranks.FindRankIdByName( "VIP" ).HasValue )
		{
			return;
		}

		if ( !Player.Local.IsValid() )
		{
			return;
		}

		_spawnedThisSession = true;
		StaffMenuTestBots.ClearTestBots();
		StaffMenuTestBots.SpawnRankBots( false );
		Log.Info( "lifepunch_auto_spawn_testbots: spawned rank bot roster (no Owner mirror)." );
	}
}

#endif
