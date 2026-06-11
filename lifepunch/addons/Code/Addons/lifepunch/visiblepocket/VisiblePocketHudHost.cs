// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Visible Pocket for DXRP" (s&box ident: lifepunch.visiblepocket · addon ident: visiblepocket) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System.Linq;
using Sandbox;
using Sandbox.UI;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
#endif

namespace LifePunch.DXRP.Addons.VisiblePocket;

internal static class VisiblePocketHudHost
{
	public static VisiblePocketHud Mount()
	{
		var existing = Sandbox.Game.ActiveScene?.GetAllComponents<VisiblePocketHud>().FirstOrDefault();
		if ( existing.IsValid() )
		{
			return existing;
		}

#if LIFEPUNCH_LOCAL
		var scene = Sandbox.Game.ActiveScene;
		if ( scene is null )
		{
			return null;
		}

		var go = scene.CreateObject();
		go.Name = "VisiblePocketHud";
		go.AddComponent<ScreenPanel>();
		return go.AddComponent<VisiblePocketHud>();
#else
		return GameManager.ShowUi<VisiblePocketHud>();
#endif
	}
}
