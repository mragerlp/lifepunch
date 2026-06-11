// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Visible Pocket for DXRP" (s&box ident: lifepunch.visiblepocket · addon ident: visiblepocket) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System.Collections.Generic;

namespace LifePunch.DXRP.Addons.VisiblePocket;

/// <summary>Client HUD mirror — updated from host on pocket changes.</summary>
public static class VisiblePocketHudState
{
	public static int MaxSlots { get; private set; } = PocketSlotPolicy.DefaultSlots;
	public static int Count { get; private set; }
	public static IReadOnlyList<string> Labels { get; private set; } = [];
	public static int Revision { get; private set; }

	public static void Apply( int maxSlots, int count, IReadOnlyList<string> labels )
	{
		MaxSlots = maxSlots;
		Count = count;
		Labels = labels ?? [];
		Revision++;
	}
}
