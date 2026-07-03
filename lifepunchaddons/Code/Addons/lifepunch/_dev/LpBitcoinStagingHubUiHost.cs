// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LifePunch Dev Tools" (s&box ident: lifepunch.dev · addon ident: dev) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System.Linq;
using Sandbox;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
#endif

namespace LifePunch.DXRP.Addons.Dev;

internal static class LpBitcoinStagingHubUiHost
{
	private const string PanelObjectName = "LpBitcoinStagingHubPanel";

	public static bool IsOpen =>
		Game.ActiveScene?.GetAllComponents<LpBitcoinStagingHubPanel>().FirstOrDefault().IsValid() ?? false;

	public static LpBitcoinStagingHubPanel Open( LpBitcoinStagingHubPower hub )
	{
		CloseOpen();

		var panel = MountPanel();
		panel?.BindHub( hub );
		return panel;
	}

	private static LpBitcoinStagingHubPanel MountPanel()
	{
#if LIFEPUNCH_LOCAL
		return OpenOnScreenPanel();
#else
		var panel = GameManager.ShowUi<LpBitcoinStagingHubPanel>();
		if ( panel.IsValid() )
			return panel;

		Log.Warning( "LpBitcoinStagingHubUiHost: GameManager.ShowUi returned null — ScreenPanel fallback." );
		return OpenOnScreenPanel();
#endif
	}

	private static LpBitcoinStagingHubPanel OpenOnScreenPanel()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
			return null;

		var go = scene.CreateObject();
		go.Name = PanelObjectName;
		go.AddComponent<ScreenPanel>();
		return go.AddComponent<LpBitcoinStagingHubPanel>();
	}

	public static void CloseOpen()
	{
		var panel = Game.ActiveScene?.GetAllComponents<LpBitcoinStagingHubPanel>().FirstOrDefault();
		Close( panel );
	}

	private static void Close( LpBitcoinStagingHubPanel panel )
	{
		if ( !panel.IsValid() )
			return;

		if ( panel.GameObject.IsValid() && panel.GameObject.Name == PanelObjectName )
			panel.GameObject.Destroy();
		else
			panel.Destroy();
	}
}
