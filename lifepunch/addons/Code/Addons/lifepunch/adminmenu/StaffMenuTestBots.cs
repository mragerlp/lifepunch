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

using System.Collections.Generic;
using Sandbox;
using Dxura.RP.Game;

namespace LifePunch.DXRP.Addons.StaffMenu;

/// <summary>
/// DEV / EDITOR-TEST ONLY — DO NOT SHIP. Exclude before publishing the admin-menu addon.
///
/// Spawns host-owned dummy "players" so staff-menu features that need a SECOND player can be tested
/// solo in editor play: the profile-pane Goto/Bring/Return box, target selection, CanTarget gating,
/// and the Waypoints "Return a player" list. The dummy is cloned from
/// <see cref="GameNetworkManager.PlayerPrefab"/>, given a fake SteamId, host-spawned (no real
/// connection — it simply stands there), and registered in <see cref="GameNetworkManager.Players"/>
/// so the menu roster shows it as a non-staff (targetable) player.
///
/// Usage (in-game console during play):
///   lifepunch_spawn_testbot          → spawns "Test Dummy N" near the local player (fake id, no rank)
///   lifepunch_spawn_testbot Greg     → spawns a bot named "Greg"
///   lifepunch_spawn_rankbots         → spawns one bot per rank (Regular/VIP/EVIP/Mod/Admin/Super Admin)
///                                      plus Player Bot 1/2. Pass `true` to also spawn Greg (Owner mirror).
///   lifepunch_spawn_all_testbots     → alias for lifepunch_spawn_rankbots true (full roster incl. Greg)
///   lifepunch_auto_spawn_testbots 1  → on editor host play, auto-spawn after portal API init (default 1)
///   lifepunch_list_ranks             → logs which rank names resolve (confirms the live portal strings)
///   lifepunch_botsay "Greg hi there" → makes a spawned bot talk in chat (first token = bot, rest = msg)
///   lifepunch_remove_testbot Greg     → removes one spawned bot by name or SteamId
///   lifepunch_clear_testbots         → removes all spawned bots and clears their rank assignments
/// </summary>
public static class StaffMenuTestBots
{
	// Obviously-fake SteamId base (not a real account), incremented per spawn so each is unique.
	private const long FakeSteamIdBase = 76500000000000000L;

	private static int _spawnCount;
	private static readonly List<long> _spawned = new();

	[ConCmd( "lifepunch_spawn_testbot" )]
	public static void SpawnTestBot( string name = "" )
	{
		if ( !Application.IsEditor )
		{
			Log.Warning( "lifepunch_spawn_testbot: editor-only dev command." );
			return;
		}

		if ( !Networking.IsHost )
		{
			Log.Warning( "lifepunch_spawn_testbot: must be host (editor play)." );
			return;
		}

		var fakeId = FakeSteamIdBase + ++_spawnCount;
		var botName = string.IsNullOrWhiteSpace( name ) ? $"Test Dummy {_spawnCount}" : name;

		var player = SpawnBot( botName, fakeId, SpawnNearLocal() );
		if ( player.IsValid() )
		{
			Log.Info( $"lifepunch_spawn_testbot: spawned '{botName}' (fake SteamId {fakeId})." );
		}
	}

	// Shared spawn path for every bot variant. Mirrors DXRP's own DebugPlayerSpawner: clone the player
	// prefab, give it the supplied identity, mark it a debug player, kill its controller/physics so it
	// just stands there, network-spawn it, then DROP OWNERSHIP. Dropping ownership is the critical bit —
	// a host-owned pawn would share the host's ConnectionId and clobber the host's entry in
	// GameNetworkManager.PlayersByConnectionIdCache, which made the host resolve OUR command caller as
	// the bot (the "Missing permission for /goto" error). Unowned ⇒ ConnectionId = Guid.Empty ⇒ no
	// collision with the real host connection. Returns the spawned player, or null on failure.
	private static Player SpawnBot( string name, long steamId, Vector3 position )
	{
		var manager = GameNetworkManager.Instance;
		if ( !manager.IsValid() || !manager.PlayerPrefab.IsValid() )
		{
			Log.Error( "testbot: GameNetworkManager / PlayerPrefab unavailable." );
			return null;
		}

		if ( manager.Players.ContainsKey( steamId ) )
		{
			Log.Warning( $"testbot: a player with SteamId {steamId} already exists; skipping '{name}'." );
			return null;
		}

		var go = manager.PlayerPrefab.Clone();
		if ( !go.IsValid() )
		{
			Log.Error( "testbot: failed to clone PlayerPrefab." );
			return null;
		}

		go.Name = $"TestBot ({name})";

		var player = go.GetComponent<Player>();
		if ( !player.IsValid() )
		{
			Log.Error( "testbot: cloned PlayerPrefab has no Player component." );
			go.Destroy();
			return null;
		}

		player.SteamId = steamId;
		player.SteamName = name;
		player.Job = GameModeJobs.Default;
		player.IsDebugPlayer = true;

		if ( player.Controller.IsValid() )
		{
			player.Controller.Enabled = false;
		}

		var rb = player.GetComponent<Rigidbody>();
		if ( rb.IsValid() )
		{
			rb.MotionEnabled = false;
		}

		go.NetworkSpawn( NetworkSpawnOptions.Default );
		go.Network.DropOwnership();

		manager.Players[steamId] = player;

		// Sane stats so the profile pane renders (bank balance, playtime, level, rp name).
		player.InitalizeHost( 50000, 6000, 5, name );

		// Proper body init + position (SpawnHost sets up the visible pawn).
		player.SpawnHost();
		player.TeleportHost( new Transform( position, Rotation.Identity ) );

		_spawned.Add( steamId );
		return player;
	}

	[ConCmd( "lifepunch_clear_testbots" )]
	public static void ClearTestBots()
	{
		if ( !Application.IsEditor || !Networking.IsHost )
		{
			return;
		}

		var removed = 0;
		foreach ( var id in _spawned.ToArray() )
		{
			if ( RemoveBot( id ) )
				removed++;
		}

		_spawned.Clear();
		Log.Info( $"lifepunch_clear_testbots: removed {removed} dummy player(s)." );
	}

	[ConCmd( "lifepunch_remove_testbot" )]
	public static void RemoveTestBot( string nameOrId = "Greg" )
	{
		if ( !Application.IsEditor || !Networking.IsHost )
		{
			Log.Warning( "lifepunch_remove_testbot: editor host-only dev command." );
			return;
		}

		var steamId = ResolveBotSteamId( nameOrId );
		if ( steamId == 0 )
			steamId = FindDebugBotSteamId( nameOrId );

		if ( steamId == 0 )
		{
			Log.Warning( $"lifepunch_remove_testbot: no spawned bot matches '{nameOrId}'." );
			return;
		}

		if ( !RemoveBot( steamId ) )
		{
			Log.Warning( $"lifepunch_remove_testbot: could not remove '{nameOrId}'." );
			return;
		}

		_spawned.Remove( steamId );
		Log.Info( $"lifepunch_remove_testbot: removed '{nameOrId}'." );
	}

	private static bool RemoveBot( long steamId )
	{
		var manager = GameNetworkManager.Instance;
		var ranks = RankSystem.Instance;

		if ( manager.IsValid() && manager.Players.TryGetValue( steamId, out var player ) && player.IsValid() )
			player.GameObject.Destroy();

		manager?.Players.Remove( steamId );

		if ( ranks.IsValid() )
			ranks.SetPlayerRanks( steamId, new List<Guid>() );

		return true;
	}

	// One bot per rank, in display order. Rank "" means no assignment — a regular/default player who
	// holds no explicit rank (so GetPlayerRank falls back to the portal's default "None"). Named ranks
	// resolve against the live portal via RankSystem.FindRankIdByName (lifepunch_list_ranks confirms the
	// strings). The SteamIds are PUBLIC placeholder accounts so each bot resolves a real Steam avatar in
	// the menus/chat — swap freely; they only need to be valid, public, and NOT the dev's own id (a bot
	// sharing the dev's id would share rank/CanTarget state). "Greg" mirrors Owner for killswitch tests.
	private static readonly (string Name, string Rank, long SteamId)[] RankBots =
	{
		( "Regular Bot", "", 76561198172576363L ),
		( "VIP Bot", "VIP", 76561197960287930L ),
		( "EVIP Bot", "EVIP", 76561198200329058L ),
		( "Mod Bot", "Mod", 76561198163939993L ),
		( "Admin Bot", "Admin", 76561198042858602L ),
		( "Super Admin Bot", "Super Admin", 76561198822683862L ),
		( "Greg", "Owner", 76561198010565263L ),
		// Extra regular players to push the roster count up for admin-menu layout/density testing.
		( "Player Bot 1", "", 76561197964781654L ),
		( "Player Bot 2", "", 76561198005079964L )
	};

	[ConCmd( "lifepunch_spawn_all_testbots" )]
	public static void SpawnAllTestBots()
	{
		SpawnRankBots( true );
	}

	[ConCmd( "lifepunch_spawn_rankbots" )]
	public static void SpawnRankBots( bool includeOwner = false )
	{
		if ( !Application.IsEditor )
		{
			Log.Warning( "lifepunch_spawn_rankbots: editor-only dev command." );
			return;
		}

		if ( !Networking.IsHost )
		{
			Log.Warning( "lifepunch_spawn_rankbots: must be host (editor play)." );
			return;
		}

		var ranks = RankSystem.Instance;
		if ( !ranks.IsValid() )
		{
			Log.Error( "lifepunch_spawn_rankbots: RankSystem unavailable (not connected to the portal yet?)." );
			return;
		}

		var index = 0;
		foreach ( var def in RankBots )
		{
			// The Owner-mirror ("Greg") can't be targeted by the owner and is only for killswitch/owner
			// tests, so skip it unless explicitly requested (lifepunch_spawn_rankbots true).
			if ( !includeOwner && def.Rank == "Owner" )
			{
				continue;
			}

			var player = SpawnBot( def.Name, def.SteamId, SpawnFannedOut( index++ ) );
			if ( !player.IsValid() )
			{
				continue;
			}

			if ( string.IsNullOrEmpty( def.Rank ) )
			{
				Log.Info( $"lifepunch_spawn_rankbots: '{def.Name}' spawned as regular (no rank)." );
				continue;
			}

			var rankId = ranks.FindRankIdByName( def.Rank );
			if ( !rankId.HasValue )
			{
				Log.Warning( $"lifepunch_spawn_rankbots: rank '{def.Rank}' not found for '{def.Name}' — left as regular." );
				continue;
			}

			ranks.SetPlayerRanks( def.SteamId, new List<Guid> { rankId.Value } );
			Log.Info( $"lifepunch_spawn_rankbots: '{def.Name}' spawned as '{def.Rank}'." );
		}
	}

	[ConCmd( "lifepunch_list_ranks" )]
	public static void ListRanks()
	{
		if ( !Application.IsEditor || !Networking.IsHost )
		{
			Log.Warning( "lifepunch_list_ranks: editor host-only dev command." );
			return;
		}

		var ranks = RankSystem.Instance;
		if ( !ranks.IsValid() )
		{
			Log.Error( "lifepunch_list_ranks: RankSystem unavailable (not connected to the portal yet?)." );
			return;
		}

		// RankSystem.Ranks is private and the editor bridge can't read the dictionary contents, so we
		// probe the expected ladder plus common variants by name to confirm which strings the portal
		// actually loaded. Anything that resolves to a Guid is a real rank we can assign to a bot.
		var candidates = new[]
		{
			"Owner", "Super Admin", "Admin", "Mod", "Moderator", "Trial Mod",
			"EVIP", "Extreme VIP", "Elite VIP", "VIP", "Donator", "Donor",
			"Member", "User", "Default", "None"
		};

		Log.Info( "[lifepunch_list_ranks] probing rank names (name -> rank Guid):" );
		foreach ( var name in candidates )
		{
			var id = ranks.FindRankIdByName( name );
			Log.Info( $"  {name,-14} -> {(id.HasValue ? id.Value.ToString() : "(not found)")}" );
		}

		// Ground truth straight from the live data: the local player's resolved rank name + order.
		var localId = Sandbox.Game.SteamId;
		Log.Info( $"[lifepunch_list_ranks] local ({localId}) resolves to rank '{ranks.GetRankName( localId )}' (order {ranks.GetRankOrder( localId )})." );
	}

	// One quoted string arg, e.g.  lifepunch_botsay "Greg hello world". The ConCmd binder rejects a
	// string[] param (ToType can't build one from console input) and multi-arg binding is unreliable, so
	// we take the whole thing and split the first token off as the bot, leaving the rest as the message.
	[ConCmd( "lifepunch_botsay" )]
	public static void BotSay( string args = "" )
	{
		if ( !Application.IsEditor || !Networking.IsHost )
		{
			Log.Warning( "lifepunch_botsay: editor host-only dev command." );
			return;
		}

		var trimmed = ( args ?? "" ).Trim();
		var split = trimmed.IndexOf( ' ' );
		var message = split > 0 ? trimmed[(split + 1)..].Trim() : "";
		if ( split <= 0 || string.IsNullOrWhiteSpace( message ) )
		{
			Log.Warning( "lifepunch_botsay: usage  lifepunch_botsay \"<bot name|steamId> <message>\"" );
			return;
		}

		var botToken = trimmed[..split];
		var steamId = ResolveBotSteamId( botToken );
		if ( steamId == 0 )
		{
			Log.Warning( $"lifepunch_botsay: no spawned bot matches '{botToken}'. Spawn some with lifepunch_spawn_rankbots first." );
			return;
		}

		// Chat.Current is a GameObjectSystem (not a Component), so it has no IsValid() — use a null check.
		var chat = Chat.Current;
		if ( chat == null )
		{
			Log.Error( "lifepunch_botsay: Chat unavailable." );
			return;
		}

		chat.BroadcastBotChat( steamId, message, MessageType.GlobalChat );
	}

	// Resolve a spawned bot by raw SteamId or by a case-insensitive substring of its display name.
	private static long ResolveBotSteamId( string token )
	{
		if ( long.TryParse( token, out var rawId ) && _spawned.Contains( rawId ) )
		{
			return rawId;
		}

		var manager = GameNetworkManager.Instance;
		if ( !manager.IsValid() )
		{
			return 0;
		}

		foreach ( var id in _spawned )
		{
			if ( manager.Players.TryGetValue( id, out var player ) && player.IsValid() &&
			     player.DisplayName.Contains( token, StringComparison.OrdinalIgnoreCase ) )
			{
				return id;
			}
		}

		return 0;
	}

	// Fallback when _spawned was cleared or hot-reloaded — match debug players live in the roster.
	private static long FindDebugBotSteamId( string token )
	{
		var manager = GameNetworkManager.Instance;
		if ( !manager.IsValid() )
			return 0;

		foreach ( var (id, player) in manager.Players )
		{
			if ( !player.IsValid() || !player.IsDebugPlayer )
				continue;

			if ( id.ToString() == token
			     || player.SteamName.Contains( token, StringComparison.OrdinalIgnoreCase )
			     || player.DisplayName.Contains( token, StringComparison.OrdinalIgnoreCase ) )
			{
				return id;
			}
		}

		return 0;
	}

	// A spot a short distance in front of the local player so the dummy is easy to see and teleport-test.
	private static Vector3 SpawnNearLocal()
	{
		var local = Player.Local;
		if ( local.IsValid() )
		{
			return local.WorldPosition + local.WorldRotation.Forward * 80f + Vector3.Up * 10f;
		}

		return Vector3.Zero;
	}

	// Spread rank bots along a row in front of the local player so they don't stack on one spot.
	private static Vector3 SpawnFannedOut( int index )
	{
		var local = Player.Local;
		if ( !local.IsValid() )
		{
			return Vector3.Zero;
		}

		var rot = local.WorldRotation;
		var lateral = ( index - 3 ) * 50f; // centre the row on the forward axis
		return local.WorldPosition + rot.Forward * 110f + rot.Right * lateral + Vector3.Up * 10f;
	}
}

#endif
