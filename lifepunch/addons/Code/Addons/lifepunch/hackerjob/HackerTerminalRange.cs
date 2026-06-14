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
using LifePunch.DXRP.Addons;

namespace LifePunch.DXRP.Addons.HackerJob;

/// <summary>Shared open/close range for hacker CRT + rack menus — delegates to <see cref="LifePunchMenuInteractRange"/>.</summary>
internal static class HackerTerminalRange
{
	public static bool IsInOpenRange( Vector3 viewerPos, Vector3 terminalPos )
		=> LifePunchMenuInteractRange.IsInOpenRange( viewerPos, terminalPos );

	public static bool IsInUiCloseRange( Vector3 viewerPos, Vector3 terminalPos )
		=> LifePunchMenuInteractRange.IsInUiCloseRange( viewerPos, terminalPos );
}
