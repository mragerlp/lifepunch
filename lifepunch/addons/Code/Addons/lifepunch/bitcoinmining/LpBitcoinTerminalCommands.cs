// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// ─────────────────────────────────────────────────────────────────────────────

using System;
using System.Collections.Generic;
using System.Linq;

namespace LifePunch.DXRP.Addons.Bitcoin;

internal readonly record struct LpBitcoinCommandResult( bool Ok, string Line );

internal static class LpBitcoinTerminalCommands
{
	public static LpBitcoinCommandResult Execute(
		LpBitcoinHubEntity hub,
		ref int selectedIndex,
		string raw )
	{
		if ( !hub.IsValid() )
			return new LpBitcoinCommandResult( false, "ERR no hub" );

		if ( !hub.IsPowered )
			return new LpBitcoinCommandResult( false, "ERR hub power off — enable at hub admin panel" );

		var parts = ( raw ?? string.Empty ).Trim().Split( ' ', StringSplitOptions.RemoveEmptyEntries );
		if ( parts.Length == 0 )
			return new LpBitcoinCommandResult( true, string.Empty );

		var cmd = parts[0].ToLowerInvariant();
		var racks = hub.GetLinkedRacks();

		switch ( cmd )
		{
			case "help":
				return new LpBitcoinCommandResult( true, HelpText() );

			case "racks":
				if ( racks.Count == 0 )
					return new LpBitcoinCommandResult( true, "No linked GPU racks." );

				var lines = racks.Select( ( r, i ) =>
					$"#{i} {( r.LargeRack ? "ADV" : "STD" )} BTC={r.BitcoinAmount:F6} {( r.IsMining ? "MINING" : "IDLE" )}" );
				return new LpBitcoinCommandResult( true, string.Join( "\n", lines ) );

			case "select":
				if ( parts.Length < 2 || !int.TryParse( parts[1], out var pick ) )
					return new LpBitcoinCommandResult( false, "usage: select <index>" );

				if ( pick < 0 || pick >= racks.Count )
					return new LpBitcoinCommandResult( false, $"ERR rack #{pick} not found" );

				selectedIndex = pick;
				return new LpBitcoinCommandResult( true, $"selected rack #{pick}" );

			case "status":
				var rack = hub.FindRackByIndex( selectedIndex );
				if ( rack is null )
					return new LpBitcoinCommandResult( false, "ERR no rack selected — type racks / select <n>" );

				return new LpBitcoinCommandResult( true,
					$"rack #{selectedIndex} {( rack.LargeRack ? "ADV" : "STD" )} | BTC {rack.BitcoinAmount:F8} | ${rack.UsdValue} | {rack.ClockGhz:F2}GHz x{rack.CoreCount} | {( rack.IsMining ? "MINING" : "IDLE" )}" );

			case "mining":
				if ( parts.Length < 2 )
					return new LpBitcoinCommandResult( false, "usage: mining start|stop|all-start|all-stop" );

				return parts[1].ToLowerInvariant() switch
				{
					"start" => MiningStart( hub, selectedIndex ),
					"stop" => MiningStop( hub, selectedIndex ),
					"all-start" => MiningAll( hub, true ),
					"all-stop" => MiningAll( hub, false ),
					_ => new LpBitcoinCommandResult( false, "usage: mining start|stop|all-start|all-stop" )
				};

			case "sell":
				if ( parts.Length > 1 && parts[1].Equals( "all", StringComparison.OrdinalIgnoreCase ) )
					return SellAll( hub );

				return SellSelected( hub, selectedIndex );

			case "bitcoin":
				if ( parts.Length > 1 && parts[1].Equals( "sell", StringComparison.OrdinalIgnoreCase ) )
					return SellSelected( hub, selectedIndex );

				return new LpBitcoinCommandResult( false, "usage: bitcoin sell | sell" );

			default:
				return new LpBitcoinCommandResult( false, $"ERR unknown command '{cmd}' — type help" );
		}
	}

	private static LpBitcoinCommandResult MiningStart( LpBitcoinHubEntity hub, int index )
	{
		var rack = hub.FindRackByIndex( index );
		if ( rack is null )
			return new LpBitcoinCommandResult( false, "ERR no rack selected" );

		rack.RequestSetMining( true );
		return new LpBitcoinCommandResult( true, $"mining started on rack #{index}" );
	}

	private static LpBitcoinCommandResult MiningStop( LpBitcoinHubEntity hub, int index )
	{
		var rack = hub.FindRackByIndex( index );
		if ( rack is null )
			return new LpBitcoinCommandResult( false, "ERR no rack selected" );

		rack.RequestSetMining( false );
		return new LpBitcoinCommandResult( true, $"mining stopped on rack #{index}" );
	}

	private static LpBitcoinCommandResult MiningAll( LpBitcoinHubEntity hub, bool on )
	{
		foreach ( var rack in hub.GetLinkedRacks() )
			rack.RequestSetMining( on );

		return new LpBitcoinCommandResult( true, on ? "mining started on all racks" : "mining stopped on all racks" );
	}

	private static LpBitcoinCommandResult SellSelected( LpBitcoinHubEntity hub, int index )
	{
		var rack = hub.FindRackByIndex( index );
		if ( rack is null )
			return new LpBitcoinCommandResult( false, "ERR no rack selected" );

		if ( rack.BitcoinAmount <= 0f )
			return new LpBitcoinCommandResult( false, "ERR rack balance empty" );

		rack.RequestSell();
		return new LpBitcoinCommandResult( true, $"sold rack #{index} balance to wallet" );
	}

	private static LpBitcoinCommandResult SellAll( LpBitcoinHubEntity hub )
	{
		var sold = 0;
		foreach ( var rack in hub.GetLinkedRacks() )
		{
			if ( rack.BitcoinAmount <= 0f )
				continue;

			rack.RequestSell();
			sold++;
		}

		return new LpBitcoinCommandResult( true, sold == 0 ? "no balances to sell" : $"sold {sold} rack balance(s)" );
	}

	private static string HelpText() =>
		"help\nracks\nselect <n>\nstatus\nmining start|stop|all-start|all-stop\nsell | bitcoin sell\nsell all";
}
