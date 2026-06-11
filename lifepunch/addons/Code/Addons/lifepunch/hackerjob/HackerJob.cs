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
	public const string InGameProgramName = "cornerman.exe";

	public const int ContentType = 0;
	public const string Grouping = "Entities";

	// Prefab/model paths TBD when assets ship — placeholders for manifest alignment.
	public const string WorldPrefabPath = "addons/lifepunch/hackerjob/entities/hacker-terminal/hacker-terminal.prefab";
	public const string WorldModelPath = "addons/lifepunch/hackerjob/models/lifepunch/hackerjob/hacker-terminal/hacker-terminal.vmdl";
}
