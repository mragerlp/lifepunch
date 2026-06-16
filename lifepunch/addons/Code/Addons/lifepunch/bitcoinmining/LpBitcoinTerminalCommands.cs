// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// ─────────────────────────────────────────────────────────────────────────────

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using LifePunch.DXRP.Addons;

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
			case "?":
				return new LpBitcoinCommandResult( true, HelpText() );

			case "racks":
			case "rigs":
				return ListRacks( racks );

			case "select":
				if ( parts.Length < 2 || !int.TryParse( parts[1], out var pick ) )
					return new LpBitcoinCommandResult( false, "usage: select <index>" );

				if ( pick < 0 || pick >= racks.Count )
					return new LpBitcoinCommandResult( false, $"ERR rack #{pick} not found — type racks" );

				selectedIndex = pick;
				return new LpBitcoinCommandResult( true, $"selected rack #{pick}" );

			case "status":
				return StatusSelected( hub, selectedIndex );

			case "info":
				return InfoSelected( hub, selectedIndex );

			case "wallet":
			case "hub":
				return WalletSummary( hub );

			case "mining":
				return ExecuteMining( hub, parts, ref selectedIndex );

			case "deposit":
				if ( parts.Length > 1 && parts[1].Equals( "all", StringComparison.OrdinalIgnoreCase ) )
					return DepositAll( hub );

				if ( parts.Length > 1 && int.TryParse( parts[1], out var depositPick ) )
					return DepositRack( hub, depositPick );

				return DepositRack( hub, selectedIndex );

			case "send":
			case "transfer":
				return ExecuteSend( hub, parts );

			case "sell":
				return new LpBitcoinCommandResult( false, "ERR sell moved to hub admin — use deposit here, then cash out from hub wallet" );

			case "bitcoin":
				if ( parts.Length > 1 && parts[1].Equals( "sell", StringComparison.OrdinalIgnoreCase ) )
					return new LpBitcoinCommandResult( false, "ERR use hub admin wallet to cash out — type wallet" );

				return new LpBitcoinCommandResult( false, "usage: deposit | deposit all | deposit <index> | wallet" );

			case "about":
				return new LpBitcoinCommandResult( true,
					"LIFEPUNCH HASHD rig console\n(c) 2026 lifepunch.co — cash out at hub admin wallet" );

			default:
				return new LpBitcoinCommandResult( false,
					$"ERR unknown command '{cmd}' — commands are space-separated (type help)" );
		}
	}

	private static LpBitcoinCommandResult ExecuteMining(
		LpBitcoinHubEntity hub,
		string[] parts,
		ref int selectedIndex )
	{
		if ( parts.Length < 2 )
			return new LpBitcoinCommandResult( false, "usage: mining start|stop|all-start|all-stop" );

		var action = parts[1].ToLowerInvariant();
		var scope = parts.Length > 2 ? parts[2].ToLowerInvariant() : string.Empty;

		if ( action is "start" or "on" )
		{
			if ( scope is "all" )
				return MiningAll( hub, true );

			return MiningStart( hub, selectedIndex );
		}

		if ( action is "stop" or "off" )
		{
			if ( scope is "all" )
				return MiningAll( hub, false );

			return MiningStop( hub, selectedIndex );
		}

		return action switch
		{
			"all-start" or "all-on" => MiningAll( hub, true ),
			"all-stop" or "all-off" => MiningAll( hub, false ),
			_ => new LpBitcoinCommandResult( false, "usage: mining start|stop|all-start|all-stop" )
		};
	}

	private static LpBitcoinCommandResult ListRacks( IReadOnlyList<LpBitcoinRackEntity> racks )
	{
		if ( racks.Count == 0 )
			return new LpBitcoinCommandResult( true, "No linked GPU racks." );

		var lines = new StringBuilder();
		for ( var i = 0; i < racks.Count; i++ )
		{
			var rack = racks[i];
			if ( !rack.IsValid() )
				continue;

			lines.AppendLine( FormatRackLine( i, rack ) );
		}

		return new LpBitcoinCommandResult( true, lines.ToString().TrimEnd() );
	}

	private static LpBitcoinCommandResult StatusSelected( LpBitcoinHubEntity hub, int index )
	{
		var rack = hub.FindRackByIndex( index );
		if ( rack is null )
			return new LpBitcoinCommandResult( false, "ERR no rack selected — type racks / select <n>" );

		var cap = LpBitcoinEconomy.RackBtcCapacity( rack.AdvancedRack );
		var fill = cap > 0f ? (int)Math.Round( 100f * rack.BitcoinAmount / cap ) : 0;
		var state = rack.IsMining ? "MINING" : "IDLE";
		if ( rack.IsMining && rack.BitcoinAmount >= cap )
			state = "CAP FULL";

		return new LpBitcoinCommandResult( true,
			$"#{index} {RackLabel( rack )} | {state} | {rack.BitcoinAmount:F6}/{cap:F6} BTC ({fill}%)\n" +
			$"rate {rack.MiningRatePerMinute:F6} BTC/min | tick {( rack.MiningProgress * 100f ):F0}%\n" +
			$"hub wallet {hub.HubWalletBtc:F6} BTC | pending {hub.GetRackPendingBtc():F6} BTC" );
	}

	private static LpBitcoinCommandResult InfoSelected( LpBitcoinHubEntity hub, int index )
	{
		var rack = hub.FindRackByIndex( index );
		if ( rack is null )
			return new LpBitcoinCommandResult( false, "ERR no rack selected — type racks / select <n>" );

		var cap = LpBitcoinEconomy.RackBtcCapacity( rack.AdvancedRack );
		return new LpBitcoinCommandResult( true,
			$"#{index} {RackLabel( rack )}\n" +
			$"CPU {rack.ClockGhz:F2} GHz (Lv {rack.CpuUpgradeLevel}) | cores x{rack.CoreCount} (Lv {rack.CoreUpgradeLevel})\n" +
			$"yield x{rack.YieldMultiplier:F1} | cap {cap:F6} BTC | ${rack.UsdValue} rack value" );
	}

	private static LpBitcoinCommandResult WalletSummary( LpBitcoinHubEntity hub )
	{
		var pending = hub.GetRackPendingBtc();
		var wallet = hub.HubWalletBtc;
		return new LpBitcoinCommandResult( true,
			$"hub wallet {wallet:F6} BTC (${(int)(wallet * LpBitcoinEconomy.BitcoinValueUsd):N0})\n" +
			$"on racks {pending:F6} BTC (${(int)(pending * LpBitcoinEconomy.BitcoinValueUsd):N0})\n" +
			"deposit rack BTC here — send to other hubs: send <steamid> <amount>\n" +
			"cash out to bank from hub admin wallet tab" );
	}

	private static LpBitcoinCommandResult ExecuteSend( LpBitcoinHubEntity hub, string[] parts )
	{
		if ( parts.Length < 3 )
			return new LpBitcoinCommandResult( false, "usage: send <steamid> <amount|all>" );

		if ( !long.TryParse( parts[1], out var steamId ) || steamId <= 0 )
			return new LpBitcoinCommandResult( false, "ERR invalid steam id — use recipient hub owner's numeric Steam ID" );

		if ( !TryParseSendAmount( hub, parts[2], out var amount, out var amountError ) )
			return new LpBitcoinCommandResult( false, amountError );

		if ( hub.Owner != 0 && hub.Owner == steamId )
			return new LpBitcoinCommandResult( false, "ERR cannot send to your own hub wallet" );

		if ( !hub.HasLinkedTerminal() )
			return new LpBitcoinCommandResult( false, "ERR no bitcoin terminal linked to hub" );

		var target = LpBitcoinHubEntity.FindHubByOwnerSteamId( steamId, exclude: hub );
		if ( target is null || !target.IsValid() )
			return new LpBitcoinCommandResult( false, $"ERR no hub found for steam id {steamId}" );

		hub.RequestSendHubWallet( steamId, amount );
		var label = LifePunchEntityOwnership.GetOwnerLabel( steamId );
		if ( string.IsNullOrWhiteSpace( label ) )
			label = steamId.ToString();

		return new LpBitcoinCommandResult( true, $"sent {amount:F6} BTC to hub {label} ({steamId})" );
	}

	private static bool TryParseSendAmount(
		LpBitcoinHubEntity hub,
		string token,
		out float amount,
		out string error )
	{
		amount = 0f;
		error = string.Empty;

		if ( token.Equals( "all", StringComparison.OrdinalIgnoreCase ) )
		{
			amount = hub.HubWalletBtc;
			if ( amount <= 0f )
			{
				error = "ERR hub wallet empty";
				return false;
			}

			return true;
		}

		if ( !float.TryParse( token, out amount ) || amount <= 0f )
		{
			error = "ERR invalid amount — use a positive BTC value or all";
			return false;
		}

		if ( amount > hub.HubWalletBtc + 0.000001f )
		{
			error = $"ERR insufficient hub wallet ({hub.HubWalletBtc:F6} BTC available)";
			return false;
		}

		return true;
	}

	private static LpBitcoinCommandResult MiningStart( LpBitcoinHubEntity hub, int index )
	{
		var rack = hub.FindRackByIndex( index );
		if ( rack is null )
			return new LpBitcoinCommandResult( false, "ERR no rack selected — type select <n>" );

		var cap = LpBitcoinEconomy.RackBtcCapacity( rack.AdvancedRack );
		if ( rack.BitcoinAmount >= cap )
			return new LpBitcoinCommandResult( false, $"ERR rack #{index} at capacity — deposit before mining" );

		if ( rack.IsMining )
			return new LpBitcoinCommandResult( true, $"rack #{index} already mining" );

		rack.RequestSetMining( true );
		return new LpBitcoinCommandResult( true, $"mining started on rack #{index}" );
	}

	private static LpBitcoinCommandResult MiningStop( LpBitcoinHubEntity hub, int index )
	{
		var rack = hub.FindRackByIndex( index );
		if ( rack is null )
			return new LpBitcoinCommandResult( false, "ERR no rack selected — type select <n>" );

		if ( !rack.IsMining )
			return new LpBitcoinCommandResult( true, $"rack #{index} already idle" );

		rack.RequestSetMining( false );
		return new LpBitcoinCommandResult( true, $"mining stopped on rack #{index}" );
	}

	private static LpBitcoinCommandResult MiningAll( LpBitcoinHubEntity hub, bool on )
	{
		var racks = hub.GetLinkedRacks();
		if ( racks.Count == 0 )
			return new LpBitcoinCommandResult( false, "ERR no linked racks" );

		var started = 0;
		var skipped = 0;
		foreach ( var rack in racks )
		{
			if ( !rack.IsValid() )
				continue;

			if ( on )
			{
				var cap = LpBitcoinEconomy.RackBtcCapacity( rack.AdvancedRack );
				if ( rack.BitcoinAmount >= cap || rack.IsMining )
				{
					skipped++;
					continue;
				}

				rack.RequestSetMining( true );
				started++;
				continue;
			}

			if ( rack.IsMining )
			{
				rack.RequestSetMining( false );
				started++;
			}
			else
			{
				skipped++;
			}
		}

		if ( on )
		{
			return started == 0
				? new LpBitcoinCommandResult( false, "ERR no racks started — all at capacity or already mining" )
				: new LpBitcoinCommandResult( true, $"mining started on {started} rack(s)" + ( skipped > 0 ? $" ({skipped} skipped)" : "" ) );
		}

		return started == 0
			? new LpBitcoinCommandResult( true, "all racks already idle" )
			: new LpBitcoinCommandResult( true, $"mining stopped on {started} rack(s)" );
	}

	private static LpBitcoinCommandResult DepositRack( LpBitcoinHubEntity hub, int index )
	{
		if ( !hub.HasLinkedTerminal() )
			return new LpBitcoinCommandResult( false, "ERR no bitcoin terminal linked to hub" );

		var rack = hub.FindRackByIndex( index );
		if ( rack is null )
			return new LpBitcoinCommandResult( false, "ERR no rack selected — type select <n>" );

		if ( rack.BitcoinAmount <= 0f )
			return new LpBitcoinCommandResult( false, "ERR rack balance empty" );

		var amount = rack.BitcoinAmount;
		hub.RequestDepositRack( index );
		return new LpBitcoinCommandResult( true, $"deposited {amount:F6} BTC from rack #{index} to hub wallet" );
	}

	private static LpBitcoinCommandResult DepositAll( LpBitcoinHubEntity hub )
	{
		if ( !hub.HasLinkedTerminal() )
			return new LpBitcoinCommandResult( false, "ERR no bitcoin terminal linked to hub" );

		var pending = hub.GetRackPendingBtc();
		if ( pending <= 0f )
			return new LpBitcoinCommandResult( false, "ERR no rack balances to deposit" );

		hub.RequestDepositRacksToHub();
		return new LpBitcoinCommandResult( true, $"deposited {pending:F6} BTC from all racks to hub wallet" );
	}

	private static string FormatRackLine( int index, LpBitcoinRackEntity rack )
	{
		var cap = LpBitcoinEconomy.RackBtcCapacity( rack.AdvancedRack );
		var state = rack.IsMining ? "MINING" : "IDLE";
		if ( rack.BitcoinAmount >= cap )
			state = "FULL";

		return $"#{index} {RackLabel( rack )} | {rack.BitcoinAmount:F6}/{cap:F6} BTC | {state}";
	}

	private static string RackLabel( LpBitcoinRackEntity rack )
		=> rack.AdvancedRack ? LpBitcoinIdent.AdvancedRackDisplayName : LpBitcoinIdent.RackDisplayName;

	private static string HelpText() =>
		"── HASHD rig0 commands (space-separated) ──\n" +
		"help · clear · racks · select <n> · status · info · wallet\n" +
		"mining start|stop · mining start all|stop all · mining all-start|all-stop\n" +
		"deposit · deposit all · deposit <n>\n" +
		"send <steamid> <amount|all> — transfer hub wallet BTC to another operator's hub\n" +
		"cash out to bank at hub admin wallet tab (not on this CRT)";
}
