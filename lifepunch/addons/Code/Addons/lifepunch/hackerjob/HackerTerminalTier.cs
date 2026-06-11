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
/// Hacker terminal hardware tier. Brand matrix: <c>addons/docs/TERMINAL_BRAND_MATRIX.md</c>.
/// </summary>
public enum HackerTerminalTier
{
	/// <summary>Cornerman green — wallet scan + puzzle theft (Hacker job).</summary>
	Standard = 0,

	/// <summary>Vengeance red — government database intrusion (Advanced Hacker).</summary>
	Advanced = 1
}
