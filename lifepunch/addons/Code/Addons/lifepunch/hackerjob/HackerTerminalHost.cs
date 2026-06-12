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

/// Dual-build mount/close helpers for <see cref="HackerTerminal"/>.

/// DXRP: mounts on <see cref="GameManager"/> HUD root via <c>ShowUi</c> (screen overlay — not the world CRT).

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



#if LIFEPUNCH_LOCAL

		var scene = Sandbox.Game.ActiveScene;

		if ( scene is null )

		{

			LogMountFailure( "no active scene" );

			return null;

		}



		var go = scene.CreateObject();

		go.Name = "HackerTerminal";

		go.AddComponent<ScreenPanel>();

		var panel = go.AddComponent<HackerTerminal>();

#else

		var panel = GameManager.ShowUi<HackerTerminal>();

#endif

		if ( !panel.IsValid() )

		{

			LogMountFailure( null );

			return null;

		}



		SetCursorMode( true );

		return panel;

	}



	public static void Close( HackerTerminal terminal )

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



	private static void LogMountFailure( string localReason )

	{

#if LIFEPUNCH_LOCAL

		Log.Error( $"[cornerman] UI mount failed — {localReason ?? "ScreenPanel create failed"}." );

#else

		if ( !GameManager.Instance.IsValid() )

		{

			Log.Error( "[cornerman] UI mount failed — GameManager not ready. Play game.scene as a joined player, not a prefab stage." );

			return;

		}



		if ( !GameManager.Instance.HudGameObject.IsValid() )

		{

			Log.Error( "[cornerman] UI mount failed — GameManager.HudGameObject missing on this map." );

			return;

		}



		Log.Error( "[cornerman] UI mount failed — HackerTerminal Razor did not mount. Check compile errors for HackerTerminal.razor." );

#endif

	}

}


