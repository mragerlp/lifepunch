// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Hacker Job" (s&box ident: lifepunch.hackerjob · addon ident: hackerjob) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

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
	public const string DisplayName = "Hacker Terminal";
	public const string Description = "Retro CRT terminal for the Hacker job. Boot cornerman.exe, scan wallets, solve coding puzzles.";
	public const string InGameProgramName = "cornerman.exe";
	public const string DevGiveCommand = "cornerman";
	public const string DevSpawnCommand = "lp_spawn_hacker_terminal";

	public const int ContentType = 0;
	public const string Grouping = "Entities";

	public const string WorldPrefabPath = "addons/lifepunch/hackerjob/entities/hacker-terminal/hacker-terminal.prefab";
	public const string WorldModelPath = "addons/lifepunch/hackerjob/models/lifepunch/hackerjob/hacker-terminal/hacker-terminal.vmdl";
	public const string KeyboardSoundPath = "addons/lifepunch/hackerjob/sounds/hacker-terminal/keyboard.sound";

	/// <summary>Seconds allowed to complete an active puzzle before auto-fail.</summary>
	public const float DefaultPuzzleTimeLimitSeconds = 45f;

	/// <summary>Hard rule: only on-hand wallet cash — bank is never touched.</summary>
	public const bool BankUntouchable = true;
}
