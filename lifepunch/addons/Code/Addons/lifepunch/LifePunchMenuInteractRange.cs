// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH DXRP Addons" (s&box ident: lifepunch.* · addon ident: lifepunch) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Author account: mrragerlp · Public alias (in-game · Steam · Discord): Bloodwave
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System;
using Sandbox;

namespace LifePunch.DXRP.Addons;

/// <summary>
/// Shared open/close proximity for LifePunch terminal and rack menus — tighter than stock DXRP USE reach
/// so Hands pickup (attack2) and pocket inventory (Reload + Hands) do not compete with distant menu activation.
/// </summary>
public static class LifePunchMenuInteractRange
{
	public const float MetersToUnits = 39.3701f;

	/// <summary>~1.25 m — stand at the console face to USE-open menus.</summary>
	public const float OpenHorizontalMeters = 1.25f;

	/// <summary>~1.0 m vertical slack while opening.</summary>
	public const float OpenVerticalMeters = 1.0f;

	/// <summary>~2.0 m — auto-close UI if the player walks away.</summary>
	public const float UiCloseHorizontalMeters = 2.0f;

	/// <summary>~1.5 m vertical slack while a menu stays open.</summary>
	public const float UiCloseVerticalMeters = 1.5f;

	public static float OpenHorizontalUnits => OpenHorizontalMeters * MetersToUnits;
	public static float OpenVerticalUnits => OpenVerticalMeters * MetersToUnits;
	public static float UiCloseHorizontalUnits => UiCloseHorizontalMeters * MetersToUnits;
	public static float UiCloseVerticalUnits => UiCloseVerticalMeters * MetersToUnits;

	public static bool IsInOpenRange( Vector3 viewerPos, Vector3 targetPos )
		=> IsWithin( viewerPos, targetPos, OpenHorizontalUnits, OpenVerticalUnits, out _ );

	public static bool IsInOpenRange( Vector3 viewerPos, Vector3 targetPos, out float horizontalDistance )
		=> IsWithin( viewerPos, targetPos, OpenHorizontalUnits, OpenVerticalUnits, out horizontalDistance );

	public static bool IsInUiCloseRange( Vector3 viewerPos, Vector3 targetPos )
		=> IsWithin( viewerPos, targetPos, UiCloseHorizontalUnits, UiCloseVerticalUnits, out _ );

	private static bool IsWithin(
		Vector3 viewerPos,
		Vector3 targetPos,
		float horizontalUnits,
		float verticalUnits,
		out float horizontalDistance )
	{
		var delta = targetPos - viewerPos;
		horizontalDistance = new Vector3( delta.x, delta.y, 0f ).Length;
		var vertical = MathF.Abs( delta.z );
		return horizontalDistance <= horizontalUnits && vertical <= verticalUnits;
	}
}
