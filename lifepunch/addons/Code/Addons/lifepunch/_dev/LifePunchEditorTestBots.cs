// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LifePunch Dev Tools" (s&box ident: lifepunch.dev · addon ident: dev) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Author account: mrragerlp · Public alias (in-game · Steam · Discord): Bloodwave
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

#if !LIFEPUNCH_LOCAL

using System.Collections.Generic;
using System.Linq;
using Sandbox;
using Dxura.RP.Game;
using Dxura.RP.Shared;

namespace LifePunch.DXRP.Addons.Dev;

/// <summary>
/// DEV / EDITOR-TEST ONLY — lives under <c>Code/_dev</c>, not lifepunchulx. Never publish.
///
/// Spawns host-owned dummy players for solo editor playtests (menus, hacker scan, weapons, scroll UX).
/// Registers clones in <see cref="GameNetworkManager.Players"/> like real roster entries.
///
/// Console: lifepunch_spawn_testbot · lifepunch_spawn_rankbots · lifepunch_spawn_scroll_testbots ·
/// lifepunch_clear_testbots · lifepunch_list_ranks · lifepunch_botsay
/// </summary>
public static class LifePunchEditorTestBots
{
	private const long FakeSteamIdBase = 76500000000000000L;

	private static int _spawnCount;
	private static readonly List<long> _spawned = new();
	private static readonly Dictionary<string, Guid> _rankIdsByName =
		new( StringComparer.OrdinalIgnoreCase );

	public const int DefaultScrollFillCount = 18;

	internal static void CacheRankDefinitions( IEnumerable<RankDto> definitions )
	{
		_rankIdsByName.Clear();
		if ( definitions == null )
		{
			return;
		}

		foreach ( var rank in definitions )
		{
			if ( rank == null )
			{
				continue;
			}

			var name = NormalizeRankName( rank.Name );
			if ( string.IsNullOrWhiteSpace( name ) )
			{
				continue;
			}

			_rankIdsByName[name] = rank.Id;
		}
	}

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
		player.InitalizeHost( 50000, 6000, 5, name );
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

		var manager = GameNetworkManager.Instance;
		var ranks = RankSystem.Instance;
		var removed = 0;

		foreach ( var id in _spawned )
		{
			if ( manager.IsValid() && manager.Players.TryGetValue( id, out var player ) && player.IsValid() )
			{
				player.GameObject.Destroy();
			}

			manager?.Players.Remove( id );

			if ( ranks.IsValid() )
			{
				ranks.SetPlayerRanks( id, new List<Guid>() );
			}

			removed++;
		}

		_spawned.Clear();
		Log.Info( $"lifepunch_clear_testbots: removed {removed} dummy player(s)." );
	}

	private static readonly (string Name, string Rank, long SteamId)[] RankBots =
	{
		( "Regular Bot", "", 76561198172576363L ),
		( "VIP Bot", "VIP", 76561197960287930L ),
		( "EVIP Bot", "EVIP", 76561198200329058L ),
		( "Mod Bot", "Mod", 76561198163939993L ),
		( "Admin Bot", "Admin", 76561198042858602L ),
		( "Super Admin Bot", "Super Admin", 76561198822683862L ),
		( "Greg", "Owner", 76561198010565263L ),
		( "Player Bot 1", "", 76561197964781654L ),
		( "Player Bot 2", "", 76561198005079964L ),
		( "Player Bot 3", "", 76561198012345678L ),
		( "Player Bot 4", "", 76561198023456789L ),
		( "Player Bot 5", "", 76561198034567890L )
	};

	[ConCmd( "lifepunch_spawn_scroll_testbots" )]
	public static void SpawnScrollTestBots()
	{
		if ( !Application.IsEditor )
		{
			Log.Warning( "lifepunch_spawn_scroll_testbots: editor-only dev command." );
			return;
		}

		if ( !Networking.IsHost )
		{
			Log.Warning( "lifepunch_spawn_scroll_testbots: must be host (editor play)." );
			return;
		}

		ClearTestBots();
		SpawnRankBots( false );
		var filled = SpawnScrollFillBots( DefaultScrollFillCount );
		Log.Info( $"lifepunch_spawn_scroll_testbots: rank roster + {filled} scroll fillers spawned." );
	}

	public static int SpawnScrollFillBots( int count )
	{
		if ( count <= 0 || !Application.IsEditor || !Networking.IsHost )
		{
			return 0;
		}

		var spawned = 0;
		for ( var i = 0; i < count; i++ )
		{
			var fakeId = FakeSteamIdBase + ++_spawnCount;
			var name = $"Scroll Fill {i + 1}";
			if ( SpawnBot( name, fakeId, SpawnFannedOut( RankBots.Length + i ) ).IsValid() )
			{
				spawned++;
			}
		}

		return spawned;
	}

	[ConCmd( "lifepunch_spawn_all_testbots" )]
	public static void SpawnAllTestBots()
	{
		SpawnRankBots( true );
	}

	[ConCmd( "lifepunch_spawn_rankbots" )]
	public static void SpawnRankBots( bool includeOwner = true )
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
			Log.Error( "lifepunch_spawn_rankbots: RankSystem unavailable (run lp_authorize first?)." );
			return;
		}

		var index = 0;
		foreach ( var def in RankBots )
		{
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

			var rankId = TryFindRankIdByName( ranks, def.Rank );
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
			Log.Error( "lifepunch_list_ranks: RankSystem unavailable." );
			return;
		}

		var candidates = new[]
		{
			"Owner", "Super Admin", "Admin", "Mod", "Moderator", "Trial Mod",
			"EVIP", "Extreme VIP", "Elite VIP", "VIP", "Donator", "Donor",
			"Member", "User", "Default", "None"
		};

		Log.Info( "[lifepunch_list_ranks] probing rank names (name -> rank Guid):" );
		foreach ( var name in candidates )
		{
			var id = TryFindRankIdByName( ranks, name );
			Log.Info( $"  {name,-14} -> {(id.HasValue ? id.Value.ToString() : "(not found)")}" );
		}

		var localId = Sandbox.Game.SteamId;
		Log.Info( $"[lifepunch_list_ranks] local ({localId}) -> '{ranks.GetRankName( localId )}' (order {ranks.GetRankOrder( localId )})." );
	}

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
			Log.Warning( $"lifepunch_botsay: no spawned bot matches '{botToken}'." );
			return;
		}

		var chat = Chat.Current;
		if ( chat == null )
		{
			Log.Error( "lifepunch_botsay: Chat unavailable." );
			return;
		}

		var manager = GameNetworkManager.Instance;
		var botName = botToken;
		if ( manager.IsValid() && manager.Players.TryGetValue( steamId, out var bot ) && bot.IsValid() )
		{
			botName = bot.DisplayName;
		}

		chat.BroadcastChat( $"{botName}: {message}", MessageType.GlobalChat );
	}

	internal static Guid? TryFindRankIdByName( RankSystem ranks, string rankName )
	{
		if ( !ranks.IsValid() || string.IsNullOrWhiteSpace( rankName ) )
		{
			return null;
		}

		var key = NormalizeRankName( rankName );
		if ( _rankIdsByName.TryGetValue( key, out var id ) )
		{
			return id;
		}

		return null;
	}

	internal static long ResolveSpawnedBotSteamId( string token )
		=> ResolveBotSteamId( token );

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

	private static Vector3 SpawnNearLocal()
	{
		var local = Player.Local;
		if ( local.IsValid() )
		{
			return local.WorldPosition + local.WorldRotation.Forward * 80f + Vector3.Up * 10f;
		}

		return Vector3.Zero;
	}

	private static Vector3 SpawnFannedOut( int index )
	{
		var local = Player.Local;
		if ( !local.IsValid() )
		{
			return Vector3.Zero;
		}

		var rot = local.WorldRotation;
		var lateral = ( index - 3 ) * 50f;
		return local.WorldPosition + rot.Forward * 110f + rot.Right * lateral + Vector3.Up * 10f;
	}

	private static string NormalizeRankName( string raw )
	{
		if ( string.IsNullOrEmpty( raw ) )
		{
			return "";
		}

		var sb = new System.Text.StringBuilder( raw.Length );
		foreach ( var c in raw )
		{
			if ( char.IsControl( c ) || char.IsSurrogate( c ) )
			{
				continue;
			}

			var cat = System.Globalization.CharUnicodeInfo.GetUnicodeCategory( c );
			if ( cat is System.Globalization.UnicodeCategory.Format
				or System.Globalization.UnicodeCategory.PrivateUse )
			{
				continue;
			}

			sb.Append( c );
		}

		return sb.ToString().Trim();
	}
}

#endif
