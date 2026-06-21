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
using System.Linq;
using System.Threading.Tasks;
using Dxura.RP.Game;
using Dxura.RP.Shared;
using LifePunch.DXRP.Addons.Dev;
using Sandbox;

namespace LifePunch.DXRP.Addons.Dev;

/// <summary>
/// DEV / EDITOR-TEST ONLY — DXRP exposes <c>authorize</c> as a launch ConVar (<c>+authorize</c>),
/// not as an in-game console command. This wrapper sets the token at runtime after host play.
/// </summary>
public static class DxrpPortalDevAuth
{
	[ConCmd( "lp_authorize" )]
	public static void LpAuthorize( string args = "" )
	{
		if ( !Networking.IsHost )
		{
			Log.Warning( "lp_authorize: host only." );
			return;
		}

		var token = NormalizeToken( args );
		if ( string.IsNullOrWhiteSpace( token ) )
		{
			Log.Warning( "lp_authorize <dxrp.net server token>" );
			return;
		}

		ServerApiLink.Token = token;
		Log.Info( "lp_authorize: token set — initializing DXRP portal API..." );
		_ = InitializePortalApi();
	}

	private static string NormalizeToken( string args )
	{
		var token = (args ?? string.Empty).Trim();
		if ( token.StartsWith( "authorize ", System.StringComparison.OrdinalIgnoreCase ) )
		{
			token = token["authorize ".Length..].Trim();
		}

		return token;
	}

	private static async Task InitializePortalApi()
	{
		await GameTask.MainThread();

		// Editor play: GameNetworkManager.OnStart returns early (Scene.IsEditor) so RankSystem may
		// not exist when Initialize() runs — full bootstrap NREs at RankSystem.Instance.SetRanks.
		// Token alone is enough for InitializePlayer refresh (bank/playtime for local smoke).
		if ( Game.ActiveScene?.IsEditor == true )
		{
			await SyncEditorRankTableFromPortal();
			await RefreshConnectedPlayersFromPortal();
			if ( ServerApiLink.HasAuthorizationKey )
			{
				Log.Info( "lp_authorize: editor mode — portal token set; rank table + player stats refreshed (skipped full server bootstrap)." );
			}

			return;
		}

		if ( ServerApiLink.Current == null )
		{
			Log.Warning( "lp_authorize: ServerApiLink not ready yet — retry after scene load." );
			return;
		}

		await ServerApiLink.Current.Initialize();
		await RefreshConnectedPlayersFromPortal();
	}

	/// <summary>
	/// Editor host play spawns players before <see cref="ServerApiLink.HasAuthorizationKey"/> is set,
	/// so DXRP applies a dev fallback (360000 minutes). Re-pull portal stats after auth.
	/// </summary>
	private static async Task SyncEditorRankTableFromPortal()
	{
		if ( !ServerApiLink.HasAuthorizationKey || !Networking.IsHost )
		{
			return;
		}

		InitalizeServerResponseDto? initResponse;
		try
		{
			initResponse = await ServerApiClient.InitializeServer( new InitalizeServerDto
			{
				Version = Application.Version,
				DefaultConfig = Json.Serialize( Config.Current.Game )
			} );
		}
		catch ( System.Exception ex )
		{
			Log.Warning( $"lp_authorize: InitializeServer failed — {ex.Message}" );
			return;
		}

		await GameTask.MainThread();

		if ( initResponse?.Ranks == null )
		{
			Log.Warning( "lp_authorize: InitializeServer returned no rank table (dev rank bots unavailable)." );
			return;
		}

		if ( RankSystem.Instance.IsValid() )
		{
			RankSystem.Instance.SetRanks( initResponse.Ranks );
			if ( initResponse.RankAssignments != null )
			{
				RankSystem.Instance.SetRankAssignments( initResponse.RankAssignments );
			}
		}

		LifePunch.DXRP.Addons.StaffMenu.StaffMenuTestBots.CacheRankDefinitions( initResponse.Ranks );
		Log.Info( $"lp_authorize: cached {initResponse.Ranks.Count()} rank definition(s) for editor dev bots." );
	}

	private static async Task RefreshConnectedPlayersFromPortal()
	{
		if ( !ServerApiLink.HasAuthorizationKey )
		{
			return;
		}

		var players = GameUtils.Players.Where( p => p.IsValid() && p.IsConnected && !p.IsDebugPlayer ).ToList();
		if ( players.Count == 0 )
		{
			return;
		}

		foreach ( var player in players )
		{
			InitalizePlayerResponseDto? initResponse;
			try
			{
				initResponse = await ServerApiClient.InitializePlayer( new InitalizePlayerDto
				{
					Id = player.SteamId,
					Name = player.DisplayName
				} );
			}
			catch ( System.Exception ex )
			{
				Log.Warning( $"lp_authorize: InitializePlayer API failed for {player.DisplayName} — {ex.Message}" );
				continue;
			}

			if ( initResponse == null )
			{
				Log.Warning( $"lp_authorize: InitializePlayer failed for {player.DisplayName} ({player.SteamId})." );
				continue;
			}

			await GameTask.MainThread();

			player.InitalizeHost(
				initResponse.Balance,
				initResponse.Playtime,
				initResponse.Level,
				initResponse.RpName );

			Log.Info(
				$"lp_authorize: refreshed {player.DisplayName} — playtime {initResponse.Playtime}m ({initResponse.Playtime / 60}h), bank ${initResponse.Balance:N0}." );
		}
	}
}

#endif
