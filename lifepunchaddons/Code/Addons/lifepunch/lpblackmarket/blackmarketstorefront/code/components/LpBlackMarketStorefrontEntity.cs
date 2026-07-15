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
/// Dealer stall — the hidden storefront machine (BM-S2, issue #147). Content-only:
/// state machine + USE + display-only placeholder stock. No sales, no transfers,
/// no fencing (R6 OPEN), no job gate yet (job row is the S1/#146 portal contract).
/// </summary>
[Title( "LIFEPUNCH Black Market Storefront" )]
[Category( "LifePunch/BlackMarket" )]
public sealed class LpBlackMarketStorefrontEntity : LpBlackMarketMachine
{
	protected override string EntitySlug => "blackmarketstorefront";

	// Display-only labels. Deliberately generic: SKU selection collides with open
	// rulings (R2 access model, R5 chemist boundary) and is NOT decided here.
	private static readonly IReadOnlyList<string> Catalog = new[]
	{
		"[PLACEHOLDER] Concealed shelf slot A",
		"[PLACEHOLDER] Concealed shelf slot B",
		"[PLACEHOLDER] Concealed shelf slot C"
	};

	protected override IReadOnlyList<string> PlaceholderInventory => Catalog;
}
