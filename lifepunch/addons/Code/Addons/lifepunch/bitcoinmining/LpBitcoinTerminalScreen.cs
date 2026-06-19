// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// ─────────────────────────────────────────────────────────────────────────────

using System;
using System.Collections.Generic;
using System.Linq;

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>World LCD — minimal live status on CRT glass; detail in hashd UI on USE.</summary>
public static class LpBitcoinTerminalScreen
{
	public static string Build( LpBitcoinHubEntity hub )
	{
		if ( hub is null || !hub.IsValid() )
			return "LIFEPUNCH hashd\nNOT LINKED";

		if ( !hub.IsPowered )
			return "LIFEPUNCH hashd\nPOWER OFF";

		var racks = hub.GetLinkedRacks();
		if ( racks.Count == 0 )
			return "LIFEPUNCH hashd\nSTANDBY\nlink rack at hub";

		var miningRacks = racks.Where( r => r.IsMining ).ToList();
		var miningCount = miningRacks.Count;
		var totalRacks = racks.Count;
		var mix = FormatRackMix( racks );
		var totalBtc = racks.Sum( r => r.BitcoinAmount ) + hub.HubWalletBtc;
		var rate = miningRacks.Sum( r => r.MiningRatePerMinute );
		var pct = miningCount > 0
			? (int)( miningRacks.Average( r => r.MiningProgress ) * 100 )
			: 0;
		var usd = (int)( totalBtc * LpBitcoinEconomy.BitcoinValueUsd );

		if ( miningCount == 0 )
			return $"LIFEPUNCH hashd\nIDLE · 0/{totalRacks} {mix}\n\u20BF {totalBtc:0.00000000}\n${usd}";

		return $"LIFEPUNCH hashd\nMINING · {miningCount}/{totalRacks} {mix} · {pct}%\n\u20BF {totalBtc:0.00000000}\n{rate:0.00000}/m · ${usd}";
	}

	/// <summary>Standard + advanced rack counts — e.g. <c>(2+2)</c> for two GPU + two Advanced GPU.</summary>
	static string FormatRackMix( IEnumerable<LpBitcoinRackEntity> racks )
	{
		var standard = 0;
		var advanced = 0;
		foreach ( var rack in racks )
		{
			if ( !rack.IsValid() )
				continue;

			if ( rack.AdvancedRack )
				advanced++;
			else
				standard++;
		}

		return $"({standard}+{advanced})";
	}
}
