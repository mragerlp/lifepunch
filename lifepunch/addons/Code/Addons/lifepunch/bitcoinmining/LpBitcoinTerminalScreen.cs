// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// ─────────────────────────────────────────────────────────────────────────────

using System;
using System.Linq;

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>World LCD text for bitcoin terminals — mirrors v1 rack screen layout, fed by hub telemetry.</summary>
public static class LpBitcoinTerminalScreen
{
	private const char BarFill = '\u2588';
	private const int LineWidth = 18;
	private static readonly string Rule = new( '\u2500', LineWidth );

	public static string Build( LpBitcoinHubEntity hub )
	{
		if ( hub is null || !hub.IsValid() )
		{
			return Header( "NO LINK" ) +
			       $"{Rule}\n" +
			       "no hub in range\n" +
			       "place terminal\n" +
			       "near Ophion hub";
		}

		if ( !hub.IsPowered )
		{
			return Header( "OFFLINE" ) +
			       $"{Rule}\n" +
			       "hub power required\n" +
			       "enable at hub admin";
		}

		var racks = hub.GetLinkedRacks();
		if ( racks.Count == 0 )
		{
			return Header( "STANDBY" ) +
			       $"{Rule}\n" +
			       "0 racks linked\n" +
			       "USE to scan HW";
		}

		var miningRacks = racks.Where( r => r.IsMining ).ToList();
		var pendingBtc = racks.Sum( r => r.BitcoinAmount );
		var totalBtc = pendingBtc + hub.HubWalletBtc;
		var rate = miningRacks.Sum( r => r.MiningRatePerMinute );
		var progress = miningRacks.Count > 0
			? miningRacks.Average( r => r.MiningProgress )
			: 0f;

		var primary = miningRacks.FirstOrDefault() ?? racks[0];
		var status = miningRacks.Count > 0 ? "\u25CF MINING" : "\u25CB IDLE";
		var rateLine = miningRacks.Count > 0 ? $"{rate:0.00000}/m" : "0.00000/m";
		var hashLine = $"{primary.ClockGhz:0.00}G L{primary.CpuUpgradeLevel}/{LpBitcoinEconomy.CpuUpgradeCosts.Length}";
		var coreLine = $"{primary.CoreCount}c L{primary.CoreUpgradeLevel}/{LpBitcoinEconomy.CoreUpgradeCosts.Length}";
		var usd = (int)( totalBtc * LpBitcoinEconomy.BitcoinValueUsd );
		var filled = (int)( progress * 8 );
		var bar = miningRacks.Count > 0 ? new string( BarFill, filled ) : string.Empty;
		var pct = (int)( progress * 100 );
		var rackLine = $"RACKS {miningRacks.Count}/{racks.Count}";

		return Header( status ) +
		       $"{Rule}\n" +
		       $"\u20BF {totalBtc:0.00000000}\n" +
		       $"\n{rateLine}\n" +
		       $"{hashLine}\n" +
		       $"{coreLine}\n" +
		       $"${usd}\n" +
		       $"{Rule}\n" +
		       $"{rackLine}\n" +
		       $"{bar}\n" +
		       $"{pct}%";
	}

	private static string Header( string status ) => $"LIFEPUNCH hashd\n{status}";
}
