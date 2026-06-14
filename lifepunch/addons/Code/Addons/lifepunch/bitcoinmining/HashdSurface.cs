// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Bitcoin Mining" (s&box ident: lifepunch.bitcoinmining · addon ident: bitcoinmining) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

namespace LifePunch.DXRP.Addons.BitcoinMining;

/// <summary>
/// Which HASHD UI surface opened — hub management rail vs monitor command console.
/// </summary>
public enum HashdSurface
{
	/// <summary>Hub body — power, link racks, upgrades, read-only audit log.</summary>
	HubPanel,

	/// <summary>HASHD monitor — rig0 typed commands (mining, bitcoin, status).</summary>
	HeadConsole,
}
