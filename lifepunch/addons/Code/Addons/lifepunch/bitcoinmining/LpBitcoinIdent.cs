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

	public const string HubEntitySlug = "bitcoinhub";
	public const string HubPrefabPath = "addons/lifepunch/lpbitcoin/bitcoinhub/assets/entities/bitcoinhub.prefab";
	public const string HubModelPath = "addons/lifepunch/lpbitcoin/bitcoinhub/assets/models/bitcoinhub.vmdl";
	public const string HubFanModelPath = "addons/lifepunch/lpbitcoin/bitcoinhub/assets/models/bitcoinhub-fan.vmdl";
	public const string HubStartupSoundPath = "addons/lifepunch/bitcoinmining/sounds/bitcoinminer/hub-startup.sound";
	public const string HubFanLoopSoundPath = "addons/lifepunch/bitcoinmining/sounds/bitcoinminer/hub-fan-loop.sound";
	public const string HubFanDownSoundPath = "addons/lifepunch/bitcoinmining/sounds/bitcoinminer/hub-fan-down.sound";
	/// <summary>DXRP gamemode purchase cha-ching — HASHD PIN pad + rig0 terminal keystrokes.</summary>
	public const string KeyboardSoundPath = "sounds/purchase.sound";
	public const string HubDisplayName = "Bitcoin Hub";

	/// <summary>Hub durability — heavier than DXRP money printer (100).</summary>
	public const float HubMaxHealth = 250f;

	/// <summary>Standard GPU rack durability.</summary>
	public const float RackMaxHealth = 250f;

	/// <summary>Advanced (stacked) GPU rack durability.</summary>
	public const float AdvancedRackMaxHealth = 500f;

	/// <summary>Standard GPU rack mining yield multiplier.</summary>
	public const float StandardRackYield = 1f;

	/// <summary>Advanced GPU rack mining yield multiplier (2× standard).</summary>
	public const float AdvancedRackYield = 2f;

	/// <summary>HASHD / rig0 slot prefix — first standard rack = GPURack-1.</summary>
	public const string StandardRackSlotPrefix = "GPURack";

	/// <summary>HASHD / rig0 slot prefix — first advanced rack = AdvancedGPURack-1.</summary>
	public const string AdvancedRackSlotPrefix = "AdvancedGPURack";

	/// <summary>DXRP portal cap per hub (market/content rows — not enforced in dev spawn).</summary>
	public const int PortalMaxStandardRacksPerHub = 2;

	/// <summary>DXRP portal cap per hub (market/content rows — not enforced in dev spawn).</summary>
	public const int PortalMaxAdvancedRacksPerHub = 2;

	/// <summary>Operator-facing rack slot (1-based). Internal APIs stay 0-based.</summary>
	public static int DisplayRackNumber( int zeroBasedIndex ) => zeroBasedIndex + 1;

	/// <summary>Operator-facing rack ID — e.g. GPURack-1, AdvancedGPURack-1 (per-type slot).</summary>
	public static string FormatRackSlotId( LpBitcoinRackEntity rack, IReadOnlyList<LpBitcoinRackEntity> linkedRacks )
	{
		if ( !rack.IsValid() )
			return "GPURack-?";

		var slot = 0;
		foreach ( var candidate in linkedRacks )
		{
			if ( !candidate.IsValid() || candidate.AdvancedRack != rack.AdvancedRack )
				continue;

			slot++;
			if ( candidate.GameObject.Id == rack.GameObject.Id )
				return rack.AdvancedRack
					? $"{AdvancedRackSlotPrefix}-{slot}"
					: $"{StandardRackSlotPrefix}-{slot}";
		}

		return rack.AdvancedRack ? $"{AdvancedRackSlotPrefix}-?" : $"{StandardRackSlotPrefix}-?";
	}

	/// <summary>Parse operator rack slot (1..linkedRackCount) to internal 0-based index.</summary>
	public static bool TryParseRackSlot( string token, int linkedRackCount, out int zeroBasedIndex )
	{
		zeroBasedIndex = -1;
		if ( !int.TryParse( token, out var slot ) )
			return false;

		if ( slot < 1 || slot > linkedRackCount )
			return false;

		zeroBasedIndex = slot - 1;
		return true;
	}
	public const string TerminalDisplayName = "Bitcoin Terminal";
	public const string TerminalModelPath =
		"addons/lifepunch/lpbitcoin/hashdterminal/assets/models/hashd-terminal.vmdl";

	/// <summary>Terminal durability — matches DXRP money printer baseline (100).</summary>
	public const float TerminalMaxHealth = 100f;
	public const string RackDisplayName = "GPU Rack";
	public const string AdvancedRackDisplayName = "Advanced GPU Rack";

	public const string AdvancedRackSlug = "advanced-gpu-rack";

	public const string RackPrefabPath = "addons/lifepunch/bitcoinmining/entities/gpurack/gpu-rack.prefab";
	public const string AdvancedRackPrefabPath = "addons/lifepunch/bitcoinmining/entities/advancedgpurack/advanced-gpu-rack.prefab";
	public const string TerminalPrefabPath = "addons/lifepunch/bitcoinmining/entities/bitcoin-terminal/bitcoin-terminal.prefab";

	/// <summary>HASHD hub + terminal UI — transparent Bitcoin mark (sidebar / PIN gate).</summary>
	public const string BtcMarkPath = "addons/lifepunch/bitcoinmining/ui/hashd/btc.png";
	public const string BtcMarkUrl = "/addons/lifepunch/bitcoinmining/ui/hashd/btc.png";

	/// <summary>Canonical Bitcoin glyph for UI copy, server titles, and docs (Unicode U+20BF).</summary>
	public const string BtcEmoji = "₿";
}
