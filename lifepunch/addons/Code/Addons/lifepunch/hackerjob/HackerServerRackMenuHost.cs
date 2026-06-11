// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Hacker Job" (s&box ident: lifepunch.hackerjob · addon ident: hackerjob) is the sole-owned
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

namespace LifePunch.DXRP.Addons.HackerJob;

internal static class HackerServerRackMenuHost
{
	public static bool IsOpen =>
		Sandbox.Game.ActiveScene?.GetAllComponents<HackerServerRackMenu>().FirstOrDefault().IsValid() ?? false;

	public static HackerServerRackMenu Mount()
	{
		var existing = Sandbox.Game.ActiveScene?.GetAllComponents<HackerServerRackMenu>().FirstOrDefault();
		if ( existing.IsValid() )
			Close( existing );

#if LIFEPUNCH_LOCAL
		var scene = Sandbox.Game.ActiveScene;
		if ( scene is null )
			return null;

		var go = scene.CreateObject();
		go.Name = "HackerServerRackMenu";
		go.AddComponent<ScreenPanel>();
		return go.AddComponent<HackerServerRackMenu>();
#else
		return GameManager.ShowUi<HackerServerRackMenu>();
#endif
	}

	public static void Close( HackerServerRackMenu menu )
	{
		if ( !menu.IsValid() )
			return;

#if LIFEPUNCH_LOCAL
		if ( menu.GameObject.IsValid() )
			menu.GameObject.Destroy();
		else
			menu.Destroy();
#else
		menu.Destroy();
#endif
	}

	public static void CloseOpen()
	{
		var menu = Sandbox.Game.ActiveScene?.GetAllComponents<HackerServerRackMenu>().FirstOrDefault();
		if ( menu.IsValid() )
			Close( menu );
	}

	public static int GetLocalWalletCash()
	{
#if LIFEPUNCH_LOCAL
		return 999_999;
#else
		return Player.Local.IsValid() ? (int)Player.Local.WalletBalance : 0;
#endif
	}
}
