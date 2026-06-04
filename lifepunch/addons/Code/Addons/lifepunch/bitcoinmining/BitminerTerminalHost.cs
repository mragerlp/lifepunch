using System.Linq;
using Sandbox;
using Sandbox.UI;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
#endif

namespace LifePunch.BitcoinMining;

/// <summary>
/// Dual-build host helpers for <see cref="BitminerTerminal"/>.
///
/// All DXRP-coupled calls live here (in C#, which reliably receives the LIFEPUNCH_LOCAL define)
/// so <c>BitminerTerminal.razor</c> stays define-free and <c>Dxura</c>-free. The s&amp;box editor's
/// Razor compilation pass does not always honour the project define, so keeping these branches in
/// a plain .cs file is what lets the addon compile cleanly in the standalone editor while still
/// using the real <c>Dxura.RP.Game</c> implementation on the dxrp.net server build.
/// </summary>
internal static class BitminerTerminalHost
{
	/// <summary>Close any open terminal, then mount and return a fresh one.</summary>
	public static BitminerTerminal Mount()
	{
		var existing = Sandbox.Game.ActiveScene?.GetAllComponents<BitminerTerminal>().FirstOrDefault();
		if ( existing.IsValid() )
			Close( existing );

#if LIFEPUNCH_LOCAL
		// Local build: no DXRP HUD helper. Host the panel on a dedicated ScreenPanel object.
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
		// Local build hosts the panel on its own object, so destroy the whole object.
		if ( terminal.GameObject.IsValid() )
			terminal.GameObject.Destroy();
		else
			terminal.Destroy();
#else
		// DXRP ShowUi-mounted build shares the HUD root, so destroy only this component.
		terminal.Destroy();
#endif
	}

	/// <summary>World position of the local viewer, used for the auto-close distance check.</summary>
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
