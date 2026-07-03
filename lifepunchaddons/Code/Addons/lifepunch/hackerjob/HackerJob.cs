// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Hacker Job" (s&box ident: lifepunch.hackerjob · addon ident: hackerjob) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Author account: mrragerlp · Public alias (in-game · Steam · Discord): Bloodwave
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using LifePunch.DXRP.Addons;

namespace LifePunch.DXRP.Addons.HackerJob;

/// <summary>
/// LifePunch Hacker Job package identity. Design spec: <c>addons/docs/HACKER_JOB_SPEC.md</c>.
/// Economy-touching (wallet theft puzzle) — Opus review + owner sign-off before implementation.
/// </summary>
public static class HackerJob
{
	public const string Package = "lifepunch.hackerjob";
	public const string Ident = "hackerjob";
	public const string EntitySlug = "hacker-terminal";
	public const string AdvancedEntitySlug = "advanced-hacker-terminal";
	public const string ServerRackEntitySlug = "server-rack";
	public const string AdvancedServerRackEntitySlug = "advanced-server-rack";
	public const string DisplayName = "Hacker Terminal";
	public const string AdvancedDisplayName = "Advanced Hacking Terminal";
	public const string ServerRackDisplayName = "Hacker Server Rack";
	public const string AdvancedServerRackDisplayName = "Advanced Hacker Server Rack";
	public const string Description = "Retro CRT terminal for the Hacker job. Boot cornerman.exe, scan wallets, solve coding puzzles.";
	public const string AdvancedDescription = "Enhanced intrusion rig for government database access. Boots vengeance.exe — Vengeance Ops tier.";
	public const string InGameProgramName = "cornerman.exe";
	public const string AdvancedProgramName = "vengeance.exe";
	public const string DevGiveCommand = "cornerman";
	public const string DevSpawnCommand = "lp_spawn_hacker_terminal";
	public const string DevAdvancedSpawnCommand = "lp_spawn_advanced_hacker_terminal";
	public const string DevServerRackSpawnCommand = "lp_spawn_server_rack";
	public const string DevAdvancedServerRackSpawnCommand = "lp_spawn_advanced_server_rack";
	public const string DevHackerKitPreviewCommand = "lp_hacker_kit_preview";
	public const string DevUiCommand = "lp_cornerman_ui";
	public const string DevAdvancedUiCommand = "lp_vengeance_ui";

	public const int ContentType = 0;
	public const string Grouping = "Entities";

	public const string WorldPrefabPath = "addons/lifepunch/hackerjob/entities/hacker-terminal/hacker-terminal.prefab";
	public const string AdvancedWorldPrefabPath = "addons/lifepunch/hackerjob/entities/advanced-hacker-terminal/advanced-hacker-terminal.prefab";
	public const string ServerRackWorldPrefabPath = "addons/lifepunch/hackerjob/entities/server-rack/server-rack.prefab";
	public const string AdvancedServerRackWorldPrefabPath = "addons/lifepunch/hackerjob/entities/advanced-server-rack/advanced-server-rack.prefab";
	public const string WorldModelPath = "addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/bitcoin-terminal/bitcoin-terminal.vmdl";
	public const string AdvancedWorldModelPath = "addons/lifepunch/bitcoinmining/models/lifepunch/bitcoinmining/bitcoin-terminal/bitcoin-terminal.vmdl";
	public const string ServerRackWorldModelPath = "addons/lifepunch/hackerjob/models/lifepunch/hackerjob/server-rack/server-rack.vmdl";
	public const string AdvancedServerRackWorldModelPath = "addons/lifepunch/hackerjob/models/lifepunch/hackerjob/advanced-server-rack/advanced-server-rack.vmdl";
	public const string KeyboardSoundPath = "addons/lifepunch/bitcoinmining/sounds/bitcoinminer/keyboard.sound";

	/// <summary>Seconds allowed to complete an active puzzle before auto-fail.</summary>
	public const float DefaultPuzzleTimeLimitSeconds = 45f;

	/// <summary>Hard rule: only on-hand wallet cash — bank is never touched.</summary>
	public const bool BankUntouchable = true;

	/// <summary>Trademark + source identifier for in-product About tab and portal copy.</summary>
	public const string PublisherMark = LifePunchSourceMark.Mark;
	public const string PublisherName = LifePunchSourceMark.Publisher;
	public const string PublisherUrl = LifePunchSourceMark.PublisherUrl;
	public const string ProductTitle = "LIFEPUNCH™ Hacker Job for DXRP";
	public const string UiVersionFooter = "lifepunch.hackerjob v1.0.0 - lifepunch.co";
	public const string ProprietaryNotice = LifePunchSourceMark.ProprietaryShort;
	public const string UseRestrictionNotice = LifePunchSourceMark.UseRestrictionShort;
}
