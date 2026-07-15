// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH™ Black Market Dealer for DXRP" (s&box ident: lifepunch.blackmarket · addon ident: blackmarketdealer) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Author account: mrragerlp · Public alias (in-game · Steam · Discord): Bloodwave
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System.Collections.Generic;
using Sandbox;

namespace LifePunch.DXRP.Addons.BlackMarket;

/// <summary>
/// Dead-drop machine (BM-S2, issue #147). Content-only: a stash point whose location
/// is knowledge, not a map ping. State machine + USE + one display-only placeholder
/// compartment. No item hand-off, no collection loop, no cash/BTC — the drop loop
/// itself is ladder slice 5; money is S4 (#149, gated).
/// </summary>
[Title( "LIFEPUNCH Black Market Dead-Drop" )]
[Category( "LifePunch/BlackMarket" )]
public sealed class LpBlackMarketDeadDropEntity : LpBlackMarketMachine
{
	protected override string EntitySlug => "blackmarketdeaddrop";

	private static readonly IReadOnlyList<string> Compartment = new[]
	{
		"[PLACEHOLDER] Dead-drop compartment (empty)"
	};

	protected override IReadOnlyList<string> PlaceholderInventory => Compartment;
}
