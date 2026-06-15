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

/// <summary>
/// Mount/close helpers for <see cref="HackerTerminal"/>.
/// Always spawns a dedicated <see cref="ScreenPanel"/> root — never stacks on DXRP HUD siblings.
/// </summary>
internal static class HackerTerminalHost
{
	public static bool IsOpen =>
		Sandbox.Game.ActiveScene?.GetAllComponents<HackerTerminal>().FirstOrDefault().IsValid() ?? false;

	public static HackerTerminal Mount()
	{
		var existing = Sandbox.Game.ActiveScene?.GetAllComponents<HackerTerminal>().FirstOrDefault();
		if ( existing.IsValid() )
			Close( existing );

		var scene = Sandbox.Game.ActiveScene;
		if ( scene is null )
		{
			LogMountFailure( "no active scene" );
			return null;
		}

		var go = scene.CreateObject();
		go.Name = "HackerTerminalUi";
		go.AddComponent<ScreenPanel>();
		var panel = go.AddComponent<HackerTerminal>();

		if ( !panel.IsValid() )
		{
			if ( go.IsValid() )
				go.Destroy();

			LogMountFailure( "ScreenPanel create failed" );
			return null;
		}

		SetCursorMode( true );
		return panel;
	}

	public static void Close( HackerTerminal terminal )
	{
		if ( !terminal.IsValid() )
			return;

		if ( terminal.GameObject.IsValid() )
			terminal.GameObject.Destroy();
		else
			terminal.Destroy();

		if ( !IsOpen )
			SetCursorMode( false );
	}

	public static void CloseOpen()
	{
		var terminal = Sandbox.Game.ActiveScene?.GetAllComponents<HackerTerminal>().FirstOrDefault();
		if ( terminal.IsValid() )
			Close( terminal );
	}

	public static Vector3? LocalViewerPosition( Scene scene )
	{
#if LIFEPUNCH_LOCAL
		var viewer = scene?.GetAllComponents<CameraComponent>().FirstOrDefault();
		return viewer.IsValid() ? viewer.WorldPosition : (Vector3?)null;
#else
		if ( Player.Local.IsValid() )
			return Player.Local.WorldPosition;

		var viewer = scene?.GetAllComponents<CameraComponent>().FirstOrDefault();
		return viewer.IsValid() ? viewer.WorldPosition : (Vector3?)null;
#endif
	}

	private static void SetCursorMode( bool menuOpen )
	{
#if !LIFEPUNCH_LOCAL
		if ( Player.Local.IsValid() )
			Player.Local.LockCamera = menuOpen;
#endif
	}

	private static void LogMountFailure( string reason )
	{
		Log.Error( $"[cornerman] UI mount failed — {reason}. Play from game.scene, then lp_cornerman_ui." );
	}
}
