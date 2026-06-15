// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// is the sole-owned intellectual property of lifepunch.co. It is NOT licensed for resale,
// redistribution, sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Author account: mrragerlp · Public alias (in-game · Steam · Discord): Bloodwave
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>Greenfield v2 package identity — lifepunch.bitcoin.</summary>
public static class LpBitcoinIdent
{
	public const string SboxPackage = "lifepunch.bitcoin";
	public const string RepoIdent = "bitcoinmining";
	public const string ProductTitle = "LIFEPUNCH™ Bitcoin Miner for DXRP";
	public const string OpsTitle = "Bitcoin Ops";
	public const string HashdProgram = "hashd";
	public const string UiFooter = "lifepunch.bitcoin v2 — lifepunch.co";

	public const string HubPrefabPath = "addons/lifepunch/bitcoinmining/entities/bitcoinminer/bitcoin-miner.prefab";
	public const string RackPrefabPath = "addons/lifepunch/bitcoinmining/entities/gpurack/gpu-rack.prefab";
	public const string LargeRackPrefabPath = "addons/lifepunch/bitcoinmining/entities/largegpurack/large-gpu-rack.prefab";
	public const string TerminalPrefabPath = "addons/lifepunch/bitcoinmining/entities/bitcoin-terminal/bitcoin-terminal.prefab";

	/// <summary>HASHD hub + terminal UI — Bitcoin mark (orange ₿ on black).</summary>
	public const string BtcMarkPath = "addons/lifepunch/bitcoinmining/ui/hashd/btc-mark.png";
	public const string BtcMarkUrl = "/addons/lifepunch/bitcoinmining/ui/hashd/btc-mark.png";

	/// <summary>Canonical Bitcoin glyph for UI copy, server titles, and docs (Unicode U+20BF).</summary>
	public const string BtcEmoji = "₿";
}
