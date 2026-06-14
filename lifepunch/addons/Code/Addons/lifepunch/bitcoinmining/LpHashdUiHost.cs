// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// is the sole-owned intellectual property of lifepunch.co. It is NOT licensed for resale,
// redistribution, sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Author account: mrragerlp · Public alias (in-game · Steam · Discord): Bloodwave
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System.Linq;
using Sandbox;
using Sandbox.UI;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
#endif

namespace LifePunch.DXRP.Addons.Bitcoin;

internal static class LpHashdUiHost
{
	public static bool IsOpen =>
		Game.ActiveScene?.GetAllComponents<LpHashdPanel>().FirstOrDefault().IsValid() ?? false;

	public static LpHashdPanel Open( LpBitcoinHubEntity hub )
	{
		CloseOpen();

#if LIFEPUNCH_LOCAL
		var scene = Game.ActiveScene;
		if ( scene is null )
			return null;

		var go = scene.CreateObject();
		go.Name = "LpHashdPanel";
		go.AddComponent<ScreenPanel>();
		var panel = go.AddComponent<LpHashdPanel>();
		panel.BindHub( hub );
		return panel;
#else
		var panel = GameManager.ShowUi<LpHashdPanel>();
		panel?.BindHub( hub );
		return panel;
#endif
	}

	public static void CloseOpen()
	{
		var panel = Game.ActiveScene?.GetAllComponents<LpHashdPanel>().FirstOrDefault();
		if ( !panel.IsValid() )
			return;

		panel.Destroy();
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
