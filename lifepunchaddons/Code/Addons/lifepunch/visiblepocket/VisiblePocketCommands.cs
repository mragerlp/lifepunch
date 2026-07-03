// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Visible Pocket for DXRP" (s&box ident: lifepunch.visiblepocket · addon ident: visiblepocket) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Author account: mrragerlp · Public alias (in-game · Steam · Discord): Bloodwave
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

#if !LIFEPUNCH_LOCAL
using Sandbox;

namespace LifePunch.DXRP.Addons.VisiblePocket;

/// <summary>Dev play-test commands — remove before portal ship.</summary>
public static class VisiblePocketCommands
{
	[ConCmd( "lp_pocket_policy" )]
	public static void PocketPolicy()
	{
		VisiblePocketService.LogPolicyStatus();
	}

	[ConCmd( "lp_pocket_slots" )]
	public static void PocketSlots()
	{
		PocketPolicy();
	}

	[ConCmd( "lp_pocket_apply_dev" )]
	public static void PocketApplyDev()
	{
		VisiblePocketService.TryApplyDevGlobalMax();
	}

	[ConCmd( "lp_pocket_refresh" )]
	public static void PocketRefresh()
	{
		VisiblePocketService.RequestHudRefresh();
	}
}
#endif
