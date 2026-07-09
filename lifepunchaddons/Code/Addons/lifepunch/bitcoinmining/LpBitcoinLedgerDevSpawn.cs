// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// ─────────────────────────────────────────────────────────────────────────────

using System;
using System.Linq;
using Sandbox;
using LifePunch.DXRP.Addons;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
#endif

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>
/// Gate-1 proof harness for the upgrade-ledger spine — dev-only ConCmds exercising
/// commit / rehydrate / clamp before the purchase flow (slice 2) exists. Excluded from
/// publish by the *DevSpawn.cs rule. Proof plan: UPGRADE_ARC_DESIGN build order, gate 1.
/// NOTE: no charging here — the spine records cost; money rails land in slice 2.
/// </summary>
internal static class LpBitcoinLedgerDevSpawn
{
	/// <summary>Buy a rack_compute tier for a linked rack (host only). Default: next
	/// sequential tier. An explicit tier is submitted to the ledger AS-IS so the
	/// sequential precondition can be exercised (gate-1 rejection asserts).
	/// Usage: lp_bitcoin_dev_buy_tier [gpurack-1|gpurack-2|advancedgpurack] [tier]</summary>
	[ConCmd( "lp_bitcoin_dev_buy_tier" )]
	public static void BuyTier( string slotToken = "", int tier = 0 )
	{
		if ( !Networking.IsHost )
		{
			Log.Warning( "lp_bitcoin_dev_buy_tier: host only" );
			return;
		}

		if ( !TryResolveRack( slotToken, out var hub, out var rack, out var slot ) )
			return;

		EnsureDebugListener();
		LpBitcoinComputeTrack.EnsureRegistered();

		var subjectClass = LpBitcoinComputeTrack.ClassOf( rack );
		var current = LifePunchUpgradeLedger.MaxTier(
			hub.Owner, LpBitcoinComputeTrack.TrackId, slot, subjectClass );

		var requested = tier > 0 ? tier : current + 1;

		var committed = LifePunchUpgradeLedger.TryCommitPurchase(
			hub.Owner, LpBitcoinComputeTrack.TrackId, slot, subjectClass,
			requested, Connection.Local.Id, out var error );

		if ( !committed )
		{
			Log.Warning( $"LP_DEV_BUY rejected: {error}" );
			return;
		}

		// Projection applied only after the ledger commit succeeded (commit-then-project).
		rack.ComputeTier = requested;
		Log.Info( $"LP_DEV_BUY ok owner={hub.Owner} slot={slot} class={subjectClass} tier={requested}" );
	}

	/// <summary>Deliberately corrupt the tier projection (proof case c — restart or
	/// lp_bitcoin_dev_reconcile must clamp it back to ledger truth).</summary>
	[ConCmd( "lp_bitcoin_dev_corrupt_tier" )]
	public static void CorruptTier( int tier, string slotToken = "" )
	{
		if ( !Networking.IsHost )
		{
			Log.Warning( "lp_bitcoin_dev_corrupt_tier: host only" );
			return;
		}

		if ( !TryResolveRack( slotToken, out _, out var rack, out var slot ) )
			return;

		rack.ComputeTier = tier;
		Log.Info( $"LP_DEV_CORRUPT slot={slot} projection forced to {tier} — restart/reconcile must clamp" );
	}

	/// <summary>Force the ledger-wins reconcile now (restart-free clamp proof).</summary>
	[ConCmd( "lp_bitcoin_dev_reconcile" )]
	public static void Reconcile( string slotToken = "" )
	{
		if ( !Networking.IsHost )
		{
			Log.Warning( "lp_bitcoin_dev_reconcile: host only" );
			return;
		}

		if ( !TryResolveRack( slotToken, out _, out var rack, out var slot ) )
			return;

		rack.ReconcileComputeTierHost();
		Log.Info( $"LP_DEV_RECONCILE slot={slot} projection={rack.ComputeTier}" );
	}

	/// <summary>Print every committed ledger record.</summary>
	[ConCmd( "lp_bitcoin_dev_ledger" )]
	public static void PrintLedger()
	{
		if ( !Networking.IsHost )
		{
			Log.Warning( "lp_bitcoin_dev_ledger: host only" );
			return;
		}

		var records = LifePunchUpgradeLedger.GetRecords();
		Log.Info( $"LP_DEV_LEDGER {records.Count} record(s)" );
		foreach ( var r in records )
		{
			Log.Info(
				$"  seq={r.Seq} owner={r.OwnerSteamId} track={r.TrackId} subject={r.SubjectId} " +
				$"class={r.SubjectClass} tier={r.Tier} costSats={r.CostSats}" );
		}
	}

	private static bool TryResolveRack(
		string slotToken,
		out LpBitcoinHubEntity hub,
		out LpBitcoinRackEntity rack,
		out string slot )
	{
		hub = null;
		rack = null;
		slot = string.Empty;

		var scene = Game.ActiveScene;
		if ( scene is null )
		{
			Log.Warning( "LP_DEV: no active scene" );
			return false;
		}

		hub = scene.GetAllComponents<LpBitcoinHubEntity>()
			.FirstOrDefault( h => h.IsValid() && h.Owner != 0 )
			?? scene.GetAllComponents<LpBitcoinHubEntity>().FirstOrDefault( h => h.IsValid() );

		if ( hub is null )
		{
			Log.Warning( "LP_DEV: no hub in scene" );
			return false;
		}

		if ( hub.Owner == 0 )
		{
			Log.Warning( "LP_DEV: hub has no owner SteamID — claim the hub first (secure boot / PIN)" );
			return false;
		}

		var racks = hub.GetLinkedRacks();
		if ( racks.Count == 0 )
		{
			Log.Warning( "LP_DEV: hub has no linked racks — link a rack first" );
			return false;
		}

		rack = string.IsNullOrWhiteSpace( slotToken )
			? racks[0]
			: racks.FirstOrDefault( r =>
				string.Equals( LpBitcoinIdent.FormatRackSlotTerminalToken( r, racks ), slotToken.Trim(),
					StringComparison.OrdinalIgnoreCase ) );

		if ( rack is null )
		{
			Log.Warning( $"LP_DEV: no linked rack at slot '{slotToken}'" );
			return false;
		}

		slot = LpBitcoinIdent.FormatRackSlotTerminalToken( rack, racks );
		return true;
	}

	private static void EnsureDebugListener()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
			return;

		if ( scene.GetAllComponents<LpBitcoinPurchaseDebugListener>().Any( l => l.IsValid() ) )
			return;

		var go = scene.CreateObject();
		go.Name = "LP Purchase Debug Listener (dev)";
		go.Components.Create<LpBitcoinPurchaseDebugListener>();
	}
}

/// <summary>Dev-only OnPurchase listener — proves commit-then-raise is observable via the
/// native event-interface idiom (LIFEPUNCH_ADDON_ARCHITECTURE Rule 1).</summary>
internal sealed class LpBitcoinPurchaseDebugListener : Component, ILifePunchPurchaseEvent
{
#if !LIFEPUNCH_LOCAL
	public void OnPurchase( Player player, string trackId, int tier, float costBtc )
	{
		var who = player.IsValid() ? player.SteamId.ToString() : "<no player>";
		Log.Info( $"LP_ONPURCHASE player={who} track={trackId} tier={tier} costBtc={costBtc:F8}" );
	}
#else
	public void OnPurchase( object player, string trackId, int tier, float costBtc )
	{
		Log.Info( $"LP_ONPURCHASE (local) track={trackId} tier={tier} costBtc={costBtc:F8}" );
	}
#endif
}
