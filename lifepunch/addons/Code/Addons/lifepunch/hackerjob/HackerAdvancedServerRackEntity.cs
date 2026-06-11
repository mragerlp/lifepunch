// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Hacker Job" (s&box ident: lifepunch.hackerjob · addon ident: hackerjob) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using Sandbox;

namespace LifePunch.DXRP.Addons.HackerJob;

/// <summary>
/// Advanced server rack — vengeance-tier upgrade caps (see <see cref="HackerUpgradeCatalog"/> advanced max tiers).
/// Powers linked <see cref="HackerTerminalEntity"/> instances within registry range.
/// </summary>
[Title( "Advanced Hacker Server Rack" )]
[Category( "LifePunch/Hacker Job" )]
#if LIFEPUNCH_LOCAL
public sealed class HackerAdvancedServerRackEntity : HackerServerRackEntity
#else
public sealed class HackerAdvancedServerRackEntity : HackerServerRackEntity
#endif
{
	protected override void OnStart()
	{
		RackTier = HackerRackTier.Advanced;
		base.OnStart();
	}
}
