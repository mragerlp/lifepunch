// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// ─────────────────────────────────────────────────────────────────────────────

using System.Linq;
using Sandbox;
using Sandbox.UI;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
#endif

namespace LifePunch.DXRP.Addons.Bitcoin;

internal static class LpBitcoinTerminalUiHost
{
	public static bool IsOpen =>
		Game.ActiveScene?.GetAllComponents<LpBitcoinTerminalPanel>().FirstOrDefault().IsValid() ?? false;

	public static LpBitcoinTerminalPanel Open( LpBitcoinHubEntity hub, LpBitcoinRackEntity focusRack = null )
	{
		CloseOpen();

#if LIFEPUNCH_LOCAL
		var scene = Game.ActiveScene;
		if ( scene is null )
			return null;

		var go = scene.CreateObject();
		go.Name = "LpBitcoinTerminalPanel";
		go.AddComponent<ScreenPanel>();
		var panel = go.AddComponent<LpBitcoinTerminalPanel>();
		panel.Bind( hub, focusRack );
		return panel;
#else
		var panel = GameManager.ShowUi<LpBitcoinTerminalPanel>();
		panel?.Bind( hub, focusRack );
		return panel;
#endif
	}

	public static void CloseOpen()
	{
		var panel = Game.ActiveScene?.GetAllComponents<LpBitcoinTerminalPanel>().FirstOrDefault();
		if ( !panel.IsValid() )
			return;

		panel.Destroy();
	}
}
