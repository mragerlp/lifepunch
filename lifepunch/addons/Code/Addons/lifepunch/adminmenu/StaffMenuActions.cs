using System;
using System.Collections.Generic;

namespace LifePunch.DXRP.Addons.StaffMenu;

/// <summary>Who an action operates on.</summary>
public enum StaffActionTarget
{
	/// <summary>Applies to the caller (no target picker needed).</summary>
	SelfOnly,

	/// <summary>Requires a selected, targetable player.</summary>
	OtherPlayer,

	/// <summary>Affects everyone / the server at once (e.g. teleport-all).</summary>
	Global
}

/// <summary>
/// Which DXRP backend an action dispatches to. The menu prefers a direct <c>AdminSystem</c> host
/// RPC where one exists, else routes through the registered chat <c>ICommand</c> via
/// <c>Chat.ExecuteCommandHost</c>. <see cref="LocalToggle"/> handles client-only affordances that
/// DXRP exposes via keybind rather than a command (e.g. noclip move-mode). Every path is re-checked
/// host-side; this catalog never carries authority.
/// </summary>
public enum StaffDispatchKind
{
	AdminRpc,
	ChatCommand,
	LocalToggle
}

/// <summary>How the UI should render/validate an argument input.</summary>
public enum StaffArgKind
{
	Text,
	Duration,
	Number
}

/// <summary>
/// A user-supplied argument, mirroring the DXRP chat-command grammar
/// (e.g. <c>/ban &lt;player&gt; &lt;duration&gt; &lt;reason&gt;</c>). Arg order in
/// <see cref="StaffAction.Args"/> must match the command's positional argument order.
/// </summary>
public sealed record StaffActionArg(
	string Name,
	string Label,
	StaffArgKind Kind = StaffArgKind.Text,
	bool Required = true,
	string? Placeholder = null );

/// <summary>
/// One entry in the staff command catalog (ULX-style, built clean as data). References DXRP only by
/// stable permission Id string + dispatch target name — never a Dxura type — so it compiles in the
/// standalone editor build. Permission Ids reconcile 1:1 with the live DXRP portal and
/// <c>admin-panel/permissions/*.json</c>.
/// </summary>
public sealed record StaffAction(
	string Key,
	string Label,
	string Category,
	string PermissionId,
	StaffDispatchKind Dispatch,
	string DispatchTarget,
	StaffActionTarget TargetMode,
	IReadOnlyList<StaffActionArg> Args,
	string Icon = "bolt" );

/// <summary>
/// The LifePunch staff command catalog + categories, mirroring the DXRP portal permission taxonomy
/// (Moderation / Commands / Ability). Growing the menu = adding rows here.
/// Catalog reconciled against the live portal Super Admin permission set (2026-06).
/// </summary>
public static class StaffMenuActions
{
	public const string CategoryModeration = "Moderation";
	public const string CategoryCommands = "Commands";
	public const string CategoryAbility = "Ability";

	/// <summary>Category display order for the menu tabs.</summary>
	public static readonly IReadOnlyList<string> Categories = new[]
	{
		CategoryModeration, CategoryCommands, CategoryAbility
	};

	private static readonly StaffActionArg[] NoArgs = Array.Empty<StaffActionArg>();

	private static StaffActionArg Reason( bool required ) =>
		new( "reason", "Reason", StaffArgKind.Text, required, "Reason" );

	private static StaffActionArg Duration( bool required ) =>
		new( "duration", "Duration", StaffArgKind.Duration, required, "e.g. 1h, 1d, 7d, perm" );

	public static readonly IReadOnlyList<StaffAction> All = new List<StaffAction>
	{
		// ---- Moderation ----
		new( "kick", "Kick", CategoryModeration, "player.kick",
			StaffDispatchKind.AdminRpc, "kick", StaffActionTarget.OtherPlayer,
			new[] { Reason( required: false ) }, "logout" ),

		new( "ban", "Ban", CategoryModeration, "player.ban",
			StaffDispatchKind.ChatCommand, "ban", StaffActionTarget.OtherPlayer,
			new[] { Duration( required: true ), Reason( required: true ) }, "gavel" ),

		new( "jail", "Jail", CategoryModeration, "player.jail",
			StaffDispatchKind.ChatCommand, "jail", StaffActionTarget.OtherPlayer,
			new[] { Duration( required: true ), Reason( required: true ) }, "lock" ),

		new( "gag", "Gag", CategoryModeration, "player.gag",
			StaffDispatchKind.ChatCommand, "gag", StaffActionTarget.OtherPlayer,
			new[] { Duration( required: true ), Reason( required: true ) }, "mic_off" ),

		new( "warn", "Warn", CategoryModeration, "player.warn",
			StaffDispatchKind.ChatCommand, "warn", StaffActionTarget.OtherPlayer,
			new[] { Reason( required: true ) }, "warning" ),

		new( "spectate", "Spectate", CategoryModeration, "player.spectate",
			StaffDispatchKind.ChatCommand, "spectate", StaffActionTarget.OtherPlayer,
			NoArgs, "visibility" ),

		new( "screenshot", "Screenshot", CategoryModeration, "player.screenshot",
			StaffDispatchKind.AdminRpc, "screenshot", StaffActionTarget.OtherPlayer,
			NoArgs, "photo_camera" ),

		// ---- Commands ----
		new( "god", "God Mode", CategoryCommands, "command.god",
			StaffDispatchKind.ChatCommand, "god", StaffActionTarget.SelfOnly, NoArgs, "shield" ),

		new( "cloak", "Cloak", CategoryCommands, "command.cloak",
			StaffDispatchKind.ChatCommand, "cloak", StaffActionTarget.SelfOnly, NoArgs, "visibility_off" ),

		new( "incognito", "Incognito", CategoryCommands, "command.incognito",
			StaffDispatchKind.ChatCommand, "incognito", StaffActionTarget.SelfOnly, NoArgs, "person_off" ),

		new( "fakedisconnect", "Fake Disconnect", CategoryCommands, "command.fakedisconnect",
			StaffDispatchKind.ChatCommand, "fakedisconnect", StaffActionTarget.SelfOnly, NoArgs, "wifi_off" ),

		new( "freeze", "Freeze", CategoryCommands, "command.freeze",
			StaffDispatchKind.ChatCommand, "freeze", StaffActionTarget.OtherPlayer, NoArgs, "ac_unit" ),

		new( "sethealth", "Set Health", CategoryCommands, "command.sethealth",
			StaffDispatchKind.ChatCommand, "sethealth", StaffActionTarget.OtherPlayer,
			new[] { new StaffActionArg( "amount", "Health", StaffArgKind.Number, true, "e.g. 100" ) }, "favorite" ),

		new( "arrest", "Arrest", CategoryCommands, "command.arrest",
			StaffDispatchKind.ChatCommand, "arrest", StaffActionTarget.OtherPlayer,
			new[] { Duration( required: false ) }, "local_police" ),

		new( "unarrest", "Unarrest", CategoryCommands, "command.unarrest",
			StaffDispatchKind.ChatCommand, "unarrest", StaffActionTarget.OtherPlayer, NoArgs, "no_accounts" ),

		new( "forcerpname", "Force RP Name", CategoryCommands, "command.forcerpname",
			StaffDispatchKind.ChatCommand, "forcerpname", StaffActionTarget.OtherPlayer,
			new[] { new StaffActionArg( "name", "RP Name", StaffArgKind.Text, false, "Leave blank to clear" ) }, "badge" ),

		new( "canceldemote", "Cancel Demote", CategoryCommands, "command.canceldemote",
			StaffDispatchKind.ChatCommand, "canceldemote", StaffActionTarget.OtherPlayer, NoArgs, "how_to_vote" ),

		new( "clearprops", "Clear Props", CategoryCommands, "command.clearprops",
			StaffDispatchKind.ChatCommand, "clearprops", StaffActionTarget.OtherPlayer, NoArgs, "cleaning_services" ),

		new( "forceselldoor", "Force Sell Door", CategoryCommands, "command.forceselldoor",
			StaffDispatchKind.ChatCommand, "forceselldoor", StaffActionTarget.SelfOnly, NoArgs, "sensor_door" ),

		// ---- Ability ----
		new( "goto", "Teleport To", CategoryAbility, "ability.teleport",
			StaffDispatchKind.ChatCommand, "goto", StaffActionTarget.OtherPlayer, NoArgs, "my_location" ),

		new( "bring", "Bring", CategoryAbility, "ability.teleport",
			StaffDispatchKind.ChatCommand, "bring", StaffActionTarget.OtherPlayer, NoArgs, "pan_tool" ),

		new( "return", "Return", CategoryAbility, "ability.teleport",
			StaffDispatchKind.ChatCommand, "return", StaffActionTarget.OtherPlayer, NoArgs, "undo" ),

		new( "tpall", "Teleport All", CategoryAbility, "ability.teleportall",
			StaffDispatchKind.ChatCommand, "tpall", StaffActionTarget.Global, NoArgs, "groups" ),

		new( "noclip", "Noclip", CategoryAbility, "ability.noclip",
			StaffDispatchKind.LocalToggle, "noclip", StaffActionTarget.SelfOnly, NoArgs, "flight" )
	};
}

/// <summary>
/// Tunable, server-agnostic policy the DXRP portal can't express. The portal only toggles WHETHER a
/// rank may ban — not for how long. This adds a per-rank ban-duration ceiling (the headline value-add
/// for reselling the menu to other servers). It is a client-side guardrail for UX; DXRP's own
/// permission checks remain the security boundary (see TECH_DEBT STAFF-03 for the enforceable endgame).
/// </summary>
public static class StaffMenuConfig
{
	/// <summary>
	/// Server-owner-configurable reference ladder. These staff tiers are ALWAYS rendered as sub-headers
	/// under the "Staff" parent — even with nobody of that rank online (shown as "(0)") — so staff can see
	/// the full ladder at a glance. Online staff are merged into the matching tier by their real portal
	/// rank name (case/whitespace-insensitive); any online staff whose rank name doesn't match a reference
	/// tier (a different server's custom ranks) is appended afterwards as its own real category. Edit this
	/// list per server so the names line up with that server's portal ranks; Order only drives display
	/// sort (highest first).
	///
	/// NOTE: DXRP doesn't expose the full rank ladder client-side (RankSystem.Ranks is private + host-only),
	/// so we can't auto-derive empty tiers from the backend — this curated reference list is the clean
	/// interim. See TECH_DEBT STAFF-05.
	/// </summary>
	public static readonly IReadOnlyList<(string Name, int Order)> ReferenceTiers = new[]
	{
		("Owner", 100),
		("Super Admin", 10),
		("Admin", 5),
		("Mod", 4)
	};

	/// <summary>Quick-pick ban durations. Tokens use DXRP's m/h/d grammar, or "perm".</summary>
	public static readonly IReadOnlyList<(string Label, string Token, int Hours)> BanDurations = new[]
	{
		("1 hour", "1h", 1),
		("6 hours", "6h", 6),
		("1 day", "1d", 24),
		("3 days", "3d", 72),
		("1 week", "7d", 168),
		("30 days", "30d", 720),
		("Permanent", "perm", int.MaxValue)
	};

	/// <summary>
	/// Max ban length (in hours) the caller's rank ORDER may issue; null = unlimited (permanent allowed).
	/// Defaults match the live LifePunch ladder (Mod=4, Admin=5, Super Admin=10, Owner=69).
	/// </summary>
	public static int? MaxBanHoursForRankOrder( int order ) => order switch
	{
		>= 10 => null,    // Super Admin / Owner — unlimited
		>= 5 => 168,      // Admin — up to 1 week
		>= 4 => 24,       // Mod — up to 1 day (only if granted player.ban at all)
		_ => 0            // below staff — none
	};

	/// <summary>True if a rank order may issue the given quick-pick duration (in hours).</summary>
	public static bool IsBanDurationAllowed( int rankOrder, int hours )
	{
		var cap = MaxBanHoursForRankOrder( rankOrder );
		return cap is null || hours <= cap.Value;
	}
}
