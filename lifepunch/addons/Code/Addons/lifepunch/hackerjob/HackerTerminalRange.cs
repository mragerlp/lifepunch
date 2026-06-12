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

namespace LifePunch.DXRP.Addons.HackerJob;

/// <summary>Shared open/close range for hacker CRT interact + console open helpers.</summary>
internal static class HackerTerminalRange
{
	public const float MetersToUnits = 39.3701f;
	public const float OpenHorizontalUnits = 6f * MetersToUnits;
	public const float OpenVerticalUnits = 3f * MetersToUnits;
	public const float UiCloseHorizontalUnits = 8f * MetersToUnits;
	public const float UiCloseVerticalUnits = 4f * MetersToUnits;

	public static bool IsInOpenRange( Vector3 viewerPos, Vector3 terminalPos )
		=> IsWithin( viewerPos, terminalPos, OpenHorizontalUnits, OpenVerticalUnits );

	public static bool IsInUiCloseRange( Vector3 viewerPos, Vector3 terminalPos )
		=> IsWithin( viewerPos, terminalPos, UiCloseHorizontalUnits, UiCloseVerticalUnits );

	private static bool IsWithin( Vector3 viewerPos, Vector3 terminalPos, float horizontalUnits, float verticalUnits )
	{
		var delta = terminalPos - viewerPos;
		var horizontal = new Vector3( delta.x, delta.y, 0f ).Length;
		var vertical = MathF.Abs( delta.z );
		return horizontal <= horizontalUnits && vertical <= verticalUnits;
	}
}
