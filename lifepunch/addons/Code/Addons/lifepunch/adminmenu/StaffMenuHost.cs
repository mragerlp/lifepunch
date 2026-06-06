// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "DXRP Admin Menu" (addon ident: adminmenu / dxrpadminmenu) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System.Collections.Generic;
using System.Linq;
using Sandbox;
using Sandbox.UI;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
#endif

namespace LifePunch.DXRP.Addons.StaffMenu;

/// <summary>
/// A player row the menu can render and target. Define-free so it flows through the
/// Dxura-free <see cref="StaffMenu"/> razor. <see cref="GroupName"/> buckets the roster by staff tier
/// (the player's rank name) with all non-staff collapsed into "Players"; <see cref="GroupOrder"/>
/// sorts the groups (highest rank first, "Players" last). <see cref="Role"/> is the player's real,
/// sanitised rank name for the detail pane (distinct from <see cref="GroupName"/>, which buckets
/// non-staff under "Players"); <see cref="RankColorHex"/> is the rank colour as "#RRGGBB";
/// <see cref="PlayTimeMinutes"/> is DXRP playtime in minutes (display as <c>/ 60</c> hours).
/// </summary>
public readonly record struct StaffMenuPlayer(
	long SteamId,
	string Name,
	bool CanTarget,
	string GroupName,
	int GroupOrder,
	string Role,
	string RankColorHex,
	int PlayTimeMinutes );

/// <summary>
/// Richer, live per-player info for the selected-player detail pane. Define-free so it flows through the
/// Dxura-free razor. Computed on demand for the selected player only (not every row every frame).
/// <see cref="Found"/> is false for an off-roster / disconnected target (only <see cref="SteamId"/> is
/// then meaningful).
/// </summary>
public readonly record struct StaffPlayerDetail(
	long SteamId,
	string Name,
	string Role,
	string RankColorHex,
	int PlayTimeMinutes,
	string Job,
	string JobColorHex,
	int Wallet,
	int Bank,
	int Health,
	int MaxHealth,
	int Armor,
	int Kills,
	int Deaths,
	bool Found );

/// <summary>
/// Dual-build host bindings for the staff menu.
///
/// All DXRP coupling lives here behind <c>#if !LIFEPUNCH_LOCAL</c> so <c>StaffMenu.razor</c> and
/// <c>StaffMenuActions.cs</c> stay define-free and compile in the standalone s&amp;box editor. On the
/// dxrp.net build the real branch binds to <c>RankSystem</c> (client-side permission reads),
/// <c>AdminSystem</c> host RPCs, and <c>Chat.ExecuteCommandHost</c>. The local branch returns
/// permissive stubs and a dummy roster so the UI renders and clicks log instead of dispatching.
///
/// This mirrors the proven <c>BitminerTerminalHost</c> pattern: the engine define
/// <c>LIFEPUNCH_LOCAL</c> reliably reaches plain .cs files even when the editor's Razor pass
/// does not honour it.
/// </summary>
internal static class StaffMenuHost
{
	private static StaffMenu? _instance;

	/// <summary>Whether the menu is currently mounted/open.</summary>
	public static bool IsOpen => _instance.IsValid();

	/// <summary>The local viewer's Steam ID. Define-free: valid in both builds.</summary>
	public static long LocalSteamId => Sandbox.Game.SteamId;

	/// <summary>
	/// The local viewer's rank order on the live ladder (Mod=4, Admin=5, Super Admin=10, Owner=69).
	/// Drives the configurable ban-duration cap. In the editor build we pretend Super Admin so the
	/// full catalog renders.
	/// </summary>
	public static int LocalRankOrder
	{
#if LIFEPUNCH_LOCAL
		get => 10;
#else
		get => RankSystem.Instance.IsValid() ? RankSystem.Instance.GetRankOrder( LocalSteamId ) : 0;
#endif
	}

	// --- Open / close ------------------------------------------------------

	/// <summary>
	/// Console + chat entry point. Staff bind any key to the <c>staffmenu</c> console command
	/// (e.g. <c>bind f4 staffmenu</c>), so the open key is per-staff-member and server-agnostic.
	/// </summary>
	[ConCmd( "staffmenu" )]
	public static void StaffMenuConCmd() => Toggle();

	/// <summary>Alias console command.</summary>
	[ConCmd( "adminmenu" )]
	public static void AdminMenuConCmd() => Toggle();

	/// <summary>
	/// Open the menu if closed, else close it. Open-for-all by design: any player may open it via the
	/// command; non-staff simply see an empty catalog (every action is permission-gated per-row). This
	/// matches the portal model where access is decided purely by rank grants on the viewer's Steam ID.
	/// </summary>
	public static void Toggle()
	{
		if ( IsOpen )
		{
			RequestClose();
			return;
		}

		_instance = Mount();
		if ( _instance.IsValid() )
		{
			SetCursorMode( true );
		}
	}

	/// <summary>Close and tear down the open menu, if any.</summary>
	public static void RequestClose()
	{
		if ( _instance.IsValid() )
		{
			Close( _instance );
		}

		_instance = null;
		SetCursorMode( false );
	}

	/// <summary>
	/// While the menu is open we release the local player's look controls so the cursor frees up and the
	/// panel becomes clickable. DXRP's <c>Player.LockCamera</c> drives <c>Controller.UseLookControls</c>
	/// each frame (see <c>Player.Camera.cs</c>) — the same hook the command wheel and camera zoom use, so
	/// we reuse the engine mechanism rather than touching the cursor directly. No-op in the editor build.
	/// </summary>
	private static void SetCursorMode( bool menuOpen )
	{
#if !LIFEPUNCH_LOCAL
		if ( Player.Local.IsValid() )
		{
			Player.Local.LockCamera = menuOpen;
		}
#endif
	}

	private static StaffMenu? Mount()
	{
		// Close any prior instance first (guards against a stale component surviving a hotload/reload).
		var existing = Sandbox.Game.ActiveScene?.GetAllComponents<StaffMenu>().FirstOrDefault();
		if ( existing.IsValid() )
		{
			Close( existing );
		}

#if LIFEPUNCH_LOCAL
		// Local editor build: no DXRP HUD root, so host the panel on a dedicated ScreenPanel object.
		var scene = Sandbox.Game.ActiveScene;
		if ( scene is null )
		{
			return null;
		}

		var go = scene.CreateObject();
		go.Name = MenuObjectName;
		go.AddComponent<ScreenPanel>();
		return go.AddComponent<StaffMenu>();
#else
		// DXRP build: mount into the HUD root ScreenPanel (the panel the engine routes the cursor/clicks
		// to). A standalone ScreenPanel never receives pointer input while the HUD owns the cursor — this
		// is the proven BitminerTerminal pattern. The panel still opts into clicks via pointer-events:all.
		return GameManager.ShowUi<StaffMenu>();
#endif
	}

	private const string MenuObjectName = "LifePunchStaffMenu";

	private static void Close( StaffMenu menu )
	{
		if ( !menu.IsValid() )
		{
			return;
		}

#if LIFEPUNCH_LOCAL
		// Local build hosts the panel on its own object, so destroy the whole object.
		if ( menu.GameObject.IsValid() )
		{
			menu.GameObject.Destroy();
		}
		else
		{
			menu.Destroy();
		}
#else
		// DXRP ShowUi-mounted build shares the HUD root GameObject, so destroy only this component.
		menu.Destroy();
#endif
	}

	// --- Permission / roster reads (client-side, for UX gating only) -------

	/// <summary>
	/// True if the local viewer's ranks grant <paramref name="permissionId"/>. UX gating only —
	/// the host re-checks on dispatch.
	/// </summary>
	public static bool CanView( string permissionId )
	{
#if LIFEPUNCH_LOCAL
		return true;
#else
		return RankSystem.HasLocalPermission( permissionId );
#endif
	}

	/// <summary>True if the viewer can use at least one catalog action (gates opening the menu).</summary>
	public static bool HasAnyStaffAccess()
		=> StaffMenuActions.All.Any( action => CanView( action.PermissionId ) );

	/// <summary>Label for the "non-staff" roster bucket.</summary>
	public const string NonStaffGroup = "Players";

	/// <summary>The online players the menu can list, grouped by staff tier, targetability resolved.</summary>
	public static IReadOnlyList<StaffMenuPlayer> OnlinePlayers()
	{
#if LIFEPUNCH_LOCAL
		return new List<StaffMenuPlayer>
		{
			new( 5L, "Owner Olivia", false, "Owner", 100, "Owner", "#E74C3C", 10980 ),
			new( 4L, "Super Sam", false, "Super Admin", 10, "Super Admin", "#3498DB", 5400 ),
			new( 3L, "Admin Andy", false, "Admin", 5, "Admin", "#2ECC71", 2400 ),
			new( 6L, "Mod Maddie", true, "Mod", 4, "Mod", "#9B59B6", 900 ),
			new( 1L, "Regular Rick", true, NonStaffGroup, int.MinValue, "Member", "#FFFFFF", 300 ),
			new( 2L, "Suspicious Sammy", true, NonStaffGroup, int.MinValue, "VIP", "#F1C40F", 120 )
		};
#else
		return GameUtils.Players
			.Where( player => player.IsValid() )
			.Select( player =>
			{
				var staff = IsStaff( player.SteamId );
				var group = staff ? RankName( player.SteamId ) : NonStaffGroup;
				var order = staff ? RankOrder( player.SteamId ) : int.MinValue;
				return new StaffMenuPlayer(
					player.SteamId,
					player.DisplayName,
					RankSystem.CanLocalTarget( player.SteamId ),
					group,
					order,
					RealRole( player.SteamId ),
					RankColorHex( player.SteamId ),
					player.PlayTime );
			} )
			.ToList();
#endif
	}

	/// <summary>Live detail for the selected player's profile pane. Found=false if they aren't connected.</summary>
	public static StaffPlayerDetail GetPlayerDetail( long steamId )
	{
#if LIFEPUNCH_LOCAL
		var p = OnlinePlayers().FirstOrDefault( x => x.SteamId == steamId );
		if ( p.SteamId == 0 )
		{
			return new StaffPlayerDetail( steamId, "", "—", "#ffffff", 0, "—", "#ffffff", 0, 0, 0, 0, 0, 0, 0, false );
		}

		return new StaffPlayerDetail( p.SteamId, p.Name, p.Role, p.RankColorHex, p.PlayTimeMinutes,
			"Citizen", "#5DA9E9", 1240, 540323, 100, 100, 25, 12, 4, true );
#else
		var player = GameUtils.Players.FirstOrDefault( x => x.IsValid() && x.SteamId == steamId );
		if ( !player.IsValid() )
		{
			return new StaffPlayerDetail( steamId, "", "—", "#ffffff", 0, "—", "#ffffff", 0, 0, 0, 0, 0, 0, 0, false );
		}

		var health = player.HealthComponent.IsValid() ? (int)player.HealthComponent.Health : 0;
		var maxHealth = player.HealthComponent.IsValid() ? (int)player.HealthComponent.MaxHealth : 0;
		var armor = player.ArmorComponent.IsValid() ? (int)player.ArmorComponent.Armor : 0;

		// JobDisplayName is CustomJob ?? Job.DisplayName(); guard the rare pre-init state where both are null.
		var job = "—";
		var jobColor = "#ffffff";
		if ( player.CustomJob != null || player.Job != null )
		{
			var name = player.JobDisplayName;
			if ( !string.IsNullOrWhiteSpace( name ) )
			{
				job = name;
			}
		}

		if ( player.Job != null )
		{
			jobColor = $"#{player.Job.Color & 0xFFFFFFu:X6}";
		}

		return new StaffPlayerDetail(
			player.SteamId,
			player.DisplayName,
			RealRole( player.SteamId ),
			RankColorHex( player.SteamId ),
			player.PlayTime,
			job,
			jobColor,
			(int)player.WalletBalance,
			(int)player.BankBalance,
			health,
			maxHealth,
			armor,
			player.Kills,
			player.Deaths,
			true );
#endif
	}

#if !LIFEPUNCH_LOCAL
	// A player counts as "staff" (and gets their own rank-named group) only if their rank grants at
	// least one action in our catalog. Everyone else collapses into the "Players" bucket — so donor
	// ranks (VIP/EVIP) and members land under "Players", while Mod/Admin/Super Admin/Owner each group
	// by their portal rank name. Reads host-synced rank dictionaries, so it resolves client-side.
	private static bool IsStaff( long steamId )
		=> StaffMenuActions.All.Any( action => RankSystem.HasPermission( steamId, action.PermissionId ) );

	private static string RankName( long steamId )
	{
		var name = RankSystem.Instance.IsValid() ? RankSystem.Instance.GetRankName( steamId ) : "";
		name = SanitizeRankName( name );
		return string.IsNullOrWhiteSpace( name ) ? NonStaffGroup : name;
	}

	/// <summary>
	/// DXRP stores backend rank names with a leading colour/markup control character (e.g. the real
	/// "Owner" arrives as a 6-char string). That junk breaks both clean display and our reference-tier
	/// matching, so we strip control / format / private-use / surrogate code points and trim. Letters,
	/// digits, spaces and ordinary punctuation are preserved, so "Super Admin" stays intact.
	/// </summary>
	private static string SanitizeRankName( string raw )
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

			var category = System.Globalization.CharUnicodeInfo.GetUnicodeCategory( c );
			if ( category is System.Globalization.UnicodeCategory.Format
			    or System.Globalization.UnicodeCategory.PrivateUse
			    or System.Globalization.UnicodeCategory.OtherNotAssigned )
			{
				continue;
			}

			sb.Append( c );
		}

		return sb.ToString().Trim();
	}

	private static int RankOrder( long steamId )
		=> RankSystem.Instance.IsValid() ? RankSystem.Instance.GetRankOrder( steamId ) : 0;

	/// <summary>The player's real, sanitised rank name for the detail pane ("—" when they have none).</summary>
	private static string RealRole( long steamId )
	{
		var name = RankSystem.Instance.IsValid() ? SanitizeRankName( RankSystem.Instance.GetRankName( steamId ) ) : "";
		return string.IsNullOrWhiteSpace( name ) ? "—" : name;
	}

	/// <summary>The player's rank colour as a "#RRGGBB" string for the detail pane.</summary>
	private static string RankColorHex( long steamId )
	{
		var color = RankSystem.Instance.IsValid() ? RankSystem.Instance.GetRankColor( steamId ) : 0xFFFFFFu;
		return $"#{color & 0xFFFFFFu:X6}";
	}
#endif

	// --- Dispatch ----------------------------------------------------------

	/// <summary>
	/// Dispatch an action to DXRP's backend. AdminSystem RPC where one exists, else the registered
	/// chat command. No-op-safe in the local build (logs instead).
	/// </summary>
	public static void Dispatch( StaffAction action, long targetSteamId, IReadOnlyDictionary<string, string> args )
	{
#if LIFEPUNCH_LOCAL
		var argText = string.Join( ", ", args.Select( kv => $"{kv.Key}={kv.Value}" ) );
		Log.Info( $"[StaffMenu] (local stub) {action.Key} target={targetSteamId} [{argText}]" );
#else
		switch ( action.Dispatch )
		{
			case StaffDispatchKind.AdminRpc:
				DispatchAdminRpc( action, targetSteamId, args );
				break;
			case StaffDispatchKind.ChatCommand:
				DispatchChatCommand( action, targetSteamId, args );
				break;
			case StaffDispatchKind.LocalToggle:
				DispatchLocalToggle( action );
				break;
		}
#endif
	}

#if !LIFEPUNCH_LOCAL
	private static void DispatchAdminRpc( StaffAction action, long targetSteamId, IReadOnlyDictionary<string, string> args )
	{
		if ( !AdminSystem.Instance.IsValid() )
		{
			return;
		}

		switch ( action.DispatchTarget )
		{
			case "kick":
				var reason = args.TryGetValue( "reason", out var supplied ) && !string.IsNullOrWhiteSpace( supplied )
					? supplied
					: "Kicked by staff";
				AdminSystem.Instance.KickPlayerHost( targetSteamId, reason );
				break;
			case "screenshot":
				AdminSystem.Instance.ForceScreenshotHost( targetSteamId );
				break;
		}
	}

	/// <summary>
	/// Client-only affordances DXRP exposes via keybind rather than a command. Noclip is a synced
	/// MoveMode toggled on the local player's own controller (same path the "Noclip" bind drives),
	/// gated by <c>ability.noclip</c> — we re-use the engine mechanism rather than reimplementing it.
	/// </summary>
	private static void DispatchLocalToggle( StaffAction action )
	{
		switch ( action.DispatchTarget )
		{
			case "noclip":
				if ( !Player.Local.IsValid() || !Player.Local.Controller.IsValid() )
				{
					return;
				}

				var noclip = Player.Local.Controller.Components.Get<MoveModeNoClip>();
				if ( noclip.IsValid() )
				{
					noclip.IsNoclipping = !noclip.IsNoclipping;
				}

				break;
		}
	}

	private static void DispatchChatCommand( StaffAction action, long targetSteamId, IReadOnlyDictionary<string, string> args )
	{
		var argv = new List<string>();

		// Target identifier first, as a Steam ID string (CommandHelper.ResolvePlayer accepts it,
		// avoiding name-collision ambiguity). Self-only commands carry no target.
		if ( action.TargetMode == StaffActionTarget.OtherPlayer )
		{
			argv.Add( targetSteamId.ToString() );
		}

		foreach ( var arg in action.Args )
		{
			if ( args.TryGetValue( arg.Name, out var value ) && !string.IsNullOrWhiteSpace( value ) )
			{
				argv.Add( value );
			}
		}

		Chat.Current?.ExecuteCommandHost( action.DispatchTarget, argv.ToArray() );
	}
#endif
}

#if !LIFEPUNCH_LOCAL
/// <summary>
/// Registers <c>/staffmenu</c> and <c>/adminmenu</c> as in-game chat commands. <see cref="ExecuteLocal"/>
/// opens the menu client-side and consumes the command, so it never round-trips to the host.
/// Discovered automatically via TypeLibrary on the dxrp.net gamemode build.
/// </summary>
public sealed class StaffMenuCommand : ICommand
{
	public string Command => "staffmenu";
	public string[] Aliases => ["adminmenu"];
	public string Help => "Open the LifePunch staff menu.";
	public bool IsUsableWhileDead => true;

	public bool ExecuteLocal( string[] args, string raw )
	{
		StaffMenuHost.Toggle();
		return true;
	}

	public bool ExecuteHost( Player caller, string[] args, string raw ) => true;
}
#endif
