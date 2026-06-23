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
	public const string HubStartupSoundPath = "addons/lifepunch/lpbitcoin/bitcoinhub/assets/sounds/bitcoinminer/hub-startup.sound";
	public const string HubFanLoopSoundPath = "addons/lifepunch/lpbitcoin/bitcoinhub/assets/sounds/bitcoinminer/hub-fan-loop.sound";
	public const string HubFanDownSoundPath = "addons/lifepunch/lpbitcoin/bitcoinhub/assets/sounds/bitcoinminer/hub-fan-down.sound";
	/// <summary>Mechanical click — rig0 CRT command line only (same asset as hacker terminal).</summary>
	public const string KeyboardSoundPath = "addons/lifepunch/lpbitcoin/bitcoinhub/assets/sounds/bitcoinminer/keyboard.sound";
	public const string HubDisplayName = "Bitcoin Hub";

	/// <summary>Hub durability — heavier than DXRP money printer (100).</summary>
	public const float HubMaxHealth = 250f;

	/// <summary>GPU rack farm durability (stacked mesh — single ship tier).</summary>
	public const float RackMaxHealth = 500f;

	/// <summary>Baseline rack yield multiplier — CPU/core upgrades drive effective rate (no small vs stacked tier).</summary>
	public const float BaseRackYieldMultiplier = 1f;

	/// <summary>DXRP Market caps per operator (portal content rows — enforced by gamemode at purchase/spawn).</summary>
	public const int PortalMaxHubsPerOperator = 1;
	public const int PortalMaxTerminalsPerOperator = 1;

	/// <summary>HASHD / rig0 slot prefix — GPURack-1 … GPURack-3.</summary>
	public const string RackSlotPrefix = "GPURack";

	/// <summary>DXRP portal cap per hub (max GPU racks linked to one hub).</summary>
	public const int PortalMaxRacksPerHub = 3;

	public const string RackSlug = "gpu-rack";
	public const string RackDisplayName = "GPU Rack";
	public const string RackModelPath =
		"addons/lifepunch/lpbitcoin/gpurack/assets/models/gpu-rack-stacked.vmdl";

	public const string RackPrefabPath =
		"addons/lifepunch/lpbitcoin/gpurack/assets/entities/gpu-rack.prefab";

	/// <summary>Operator-facing rack slot (1-based). Internal APIs stay 0-based.</summary>
	public static int DisplayRackNumber( int zeroBasedIndex ) => zeroBasedIndex + 1;

	/// <summary>Operator-facing rack ID — e.g. GPURack-1 … GPURack-3.</summary>
	public static string FormatRackSlotId( LpBitcoinRackEntity rack, IReadOnlyList<LpBitcoinRackEntity> linkedRacks )
	{
		if ( !TryGetRackSlotNumber( rack, linkedRacks, out var slot ) )
			return $"{RackSlotPrefix}-?";

		return $"{RackSlotPrefix}-{slot}";
	}

	/// <summary>Hub UI label — e.g. GPU Rack 1 … GPU Rack 3.</summary>
	public static string FormatRackSlotDisplayName( LpBitcoinRackEntity rack, IReadOnlyList<LpBitcoinRackEntity> linkedRacks )
	{
		if ( !TryGetRackSlotNumber( rack, linkedRacks, out var slot ) )
			return $"{RackDisplayName} ?";

		return $"{RackDisplayName} {slot}";
	}

	/// <summary>rig0 / CRT copy token — e.g. gpurack-1 (lowercase slot id).</summary>
	public static string FormatRackSlotTerminalToken( LpBitcoinRackEntity rack, IReadOnlyList<LpBitcoinRackEntity> linkedRacks )
		=> FormatRackSlotId( rack, linkedRacks ).ToLowerInvariant();

	public static bool TryGetRackSlotNumber(
		LpBitcoinRackEntity rack,
		IReadOnlyList<LpBitcoinRackEntity> linkedRacks,
		out int slot )
	{
		slot = 0;
		if ( !rack.IsValid() )
			return false;

		foreach ( var candidate in linkedRacks )
		{
			if ( !candidate.IsValid() )
				continue;

			slot++;
			if ( candidate.GameObject.Id == rack.GameObject.Id )
				return true;
		}

		return false;
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
	public const string TerminalPrefabPath = "addons/lifepunch/lpbitcoin/hashdterminal/assets/entities/hashd-terminal.prefab";

	/// <summary>HASHD hub + terminal UI — transparent Bitcoin mark (sidebar / PIN gate).</summary>
	public const string BtcMarkPath = "addons/lifepunch/lpbitcoin/bitcoinhub/assets/ui/hashd/btc.png";
	public const string BtcMarkUrl = "/addons/lifepunch/lpbitcoin/bitcoinhub/assets/ui/hashd/btc.png";

	/// <summary>Canonical Bitcoin glyph for UI copy, server titles, and docs (Unicode U+20BF).</summary>
	public const string BtcEmoji = "₿";

	// Legacy aliases — remove when prefab paths and portal rows finish rename (BITCOINMINING-07).
	[Obsolete( "Use RackPrefabPath — single GPU rack farm entity." )]
	public const string AdvancedRackPrefabPath = RackPrefabPath;

	[Obsolete( "Use RackDisplayName — advanced tier merged into GPU Rack." )]
	public const string AdvancedRackDisplayName = RackDisplayName;

	[Obsolete( "Use RackSlug." )]
	public const string AdvancedRackSlug = RackSlug;

	[Obsolete( "Use BaseRackYieldMultiplier — tier yield removed." )]
	public const float AdvancedRackYield = BaseRackYieldMultiplier;

	[Obsolete( "Use BaseRackYieldMultiplier." )]
	public const float StandardRackYield = BaseRackYieldMultiplier;

	[Obsolete( "Use RackMaxHealth." )]
	public const float AdvancedRackMaxHealth = RackMaxHealth;

	[Obsolete( "Use PortalMaxRacksPerHub." )]
	public const int PortalMaxAdvancedRacksPerHub = PortalMaxRacksPerHub;

	[Obsolete( "Single rack tier — always 0." )]
	public const int PortalMaxStandardRacksPerHub = 0;

	[Obsolete( "Single rack tier shipped." )]
	public const bool StandardRackShipParked = true;

	[Obsolete( "Use RackSlotPrefix." )]
	public const string StandardRackSlotPrefix = RackSlotPrefix;

	[Obsolete( "Use RackSlotPrefix." )]
	public const string AdvancedRackSlotPrefix = RackSlotPrefix;
}
