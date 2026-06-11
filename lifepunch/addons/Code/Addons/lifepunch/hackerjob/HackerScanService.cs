// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Hacker Job" (s&box ident: lifepunch.hackerjob · addon ident: hackerjob) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System.Collections.Generic;
using Sandbox;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
#endif

namespace LifePunch.DXRP.Addons.HackerJob;

/// <summary>
/// Server-authoritative player scan for wallet-hack targets.
/// Phase 1 returns editor-safe stubs; Phase 2 wires live DXRP player list + filters (Opus).
/// </summary>
public static class HackerScanService
{
	public sealed record ScanTarget( string SteamId, string DisplayName, int WalletCash );

	public static IReadOnlyList<ScanTarget> RequestScan( HackerTerminalEntity terminal )
	{
#if LIFEPUNCH_LOCAL
		_ = terminal;
		return new[]
		{
			new ScanTarget( "76561198000000001", "target_alpha", 4200 ),
			new ScanTarget( "76561198000000002", "target_bravo", 1250 ),
			new ScanTarget( "76561198000000003", "target_charlie", 890 ),
		};
#else
		// TODO Phase 2: host RPC builds list from live players — exclude self, staff, invalid targets.
		return System.Array.Empty<ScanTarget>();
#endif
	}
}
