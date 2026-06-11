// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Hacker Job" (s&box ident: lifepunch.hackerjob · addon ident: hackerjob) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System;
using Sandbox;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
#endif

namespace LifePunch.DXRP.Addons.HackerJob;

/// <summary>
/// Placeable retro CRT terminal for the Hacker job.
/// Phase 1: open <c>cornerman.exe</c> UI shell — economy + validated puzzles land in Phase 2 (Opus).
/// </summary>
[Title( "Hacker Terminal" )]
[Category( "LifePunch/Hacker Job" )]
#if LIFEPUNCH_LOCAL
public sealed class HackerTerminalEntity : Component, Component.IPressable
#else
public sealed class HackerTerminalEntity : BaseEntity, Component.IPressable
#endif
{
	[Property] public TextRenderer ScreenText { get; set; }

	protected override void OnStart()
	{
		base.OnStart();
		RefreshScreenIdle();
	}

	public bool Press( IPressable.Event e )
	{
		RequestOpenTerminal();
		return true;
	}

	public void RequestOpenTerminal() => OpenTerminalHost();

	[Rpc.Host]
	private void OpenTerminalHost()
	{
#if !LIFEPUNCH_LOCAL
		if ( !GameUtils.HasPermission( Rpc.Caller, GameObject ) )
			return;

		// Job gate + distance validation land in Phase 2 (Opus).
#endif
		OpenTerminal( Rpc.CallerId );
	}

	[Rpc.Broadcast]
	private void OpenTerminal( Guid callerId )
	{
		if ( Connection.Local.Id != callerId )
			return;

		HackerTerminal.Open( this );
	}

	private void RefreshScreenIdle()
	{
		if ( !ScreenText.IsValid() )
			return;

		ScreenText.Text = "LIFEPUNCH cornerman.exe\n[ STANDBY ] type cornerman nearby";
	}
}
