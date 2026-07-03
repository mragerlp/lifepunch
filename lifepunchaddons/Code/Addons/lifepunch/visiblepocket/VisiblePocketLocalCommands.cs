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

#if LIFEPUNCH_LOCAL
using Sandbox;

namespace LifePunch.DXRP.Addons.VisiblePocket;

public static class VisiblePocketLocalCommands
{
	[ConCmd( "lp_pocket_preview" )]
	public static void PocketPreview()
	{
		VisiblePocketHudHost.Mount();
		VisiblePocketHudState.Apply( 10, 3, new[] { "pistol", "keys", "weed" } );
		Log.Info( "[VisiblePocket] HUD preview mounted (local stub)." );
	}
}
#endif
