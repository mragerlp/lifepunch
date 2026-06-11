// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Bitcoin Mining" (s&box ident: lifepunch.bitcoinmining · addon ident: bitcoinmining) is the sole-owned
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

namespace LifePunch.DXRP.Addons.BitcoinMining;

/// <summary>
/// Dual-build host helpers for <see cref="BitminerTerminal"/>.
///
/// All DXRP-coupled calls live here (in C#, which reliably receives the LIFEPUNCH_LOCAL define)
/// so <c>BitminerTerminal.razor</c> stays define-free and <c>Dxura</c>-free.
/// </summary>
internal static class BitminerTerminalHost
{
	/// <summary>Whether a terminal panel is currently mounted.</summary>
	public static bool IsOpen =>
		Sandbox.Game.ActiveScene?.GetAllComponents<BitminerTerminal>().FirstOrDefault().IsValid() ?? false;

	/// <summary>Close any open terminal, then mount and return a fresh one.</summary>
	public static BitminerTerminal Mount()
	{
		var existing = Sandbox.Game.ActiveScene?.GetAllComponents<BitminerTerminal>().FirstOrDefault();
		if ( existing.IsValid() )
			Close( existing );

#if LIFEPUNCH_LOCAL
		var scene = Sandbox.Game.ActiveScene;
		if ( scene is null )
			return null;

		var go = scene.CreateObject();
		go.Name = "BitminerTerminal";
		go.AddComponent<ScreenPanel>();
		return go.AddComponent<BitminerTerminal>();
#else
		return GameManager.ShowUi<BitminerTerminal>();
#endif
	}

	/// <summary>Tear down a terminal correctly for the active build.</summary>
	public static void Close( BitminerTerminal terminal )
	{
		if ( !terminal.IsValid() )
			return;

#if LIFEPUNCH_LOCAL
		if ( terminal.GameObject.IsValid() )
			terminal.GameObject.Destroy();
		else
			terminal.Destroy();
#else
		terminal.Destroy();
#endif
	}

	/// <summary>Close whichever terminal is open, if any.</summary>
	public static void CloseOpen()
	{
		var terminal = Sandbox.Game.ActiveScene?.GetAllComponents<BitminerTerminal>().FirstOrDefault();
		if ( terminal.IsValid() )
			Close( terminal );
	}

	/// <summary>World position of the local viewer, used for range checks.</summary>
	public static Vector3? LocalViewerPosition( Scene scene )
	{
#if LIFEPUNCH_LOCAL
		var viewer = scene?.GetAllComponents<CameraComponent>().FirstOrDefault();
		return viewer.IsValid() ? viewer.WorldPosition : (Vector3?)null;
#else
		return Player.Local.IsValid()
			? Player.Local.WorldPosition
			: (Vector3?)null;
#endif
	}
}
