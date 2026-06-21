// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Hacker Job" (s&box ident: lifepunch.hackerjob · addon ident: hackerjob) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Author account: mrragerlp · Public alias (in-game · Steam · Discord): Bloodwave
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System.Collections.Generic;
using System.Linq;
using Sandbox;
using LifePunch.DXRP.Addons.Bitcoin;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
#endif

namespace LifePunch.DXRP.Addons.HackerJob;

/// <summary>
/// Player scan for wallet-hack targets. DXRP editor play uses live roster entries —
/// including editor test bots spawned via <c>lifepunch_spawn_testbot</c> (<c>_dev/LifePunchEditorTestBots</c>).
/// Phase 2: scan list must be built on host via <c>[Rpc.Host]</c> — client display only.
/// </summary>
public static class HackerScanService
{
	public sealed record ScanTarget( string SteamId, string DisplayName, int WalletCash );
	public sealed record GovDbTarget( string NodeId, string Label, string SecurityTier );
	public sealed record HashdTarget( string ScanId, string Label, float DistanceMeters, float HubWalletBtc );

	public static IReadOnlyList<ScanTarget> RequestScan( HackerTerminalEntity terminal )
	{
#if LIFEPUNCH_LOCAL
		_ = terminal;
		return EditorStubWalletTargets();
#else
		return BuildLiveWalletTargets();
#endif
	}

	/// <summary>Advanced terminal only — government tax-miner / govdb nodes (Phase 1 stub).</summary>
	public static IReadOnlyList<GovDbTarget> RequestGovDbScan( HackerTerminalEntity terminal )
	{
#if LIFEPUNCH_LOCAL
		_ = terminal;
		return EditorStubGovDbTargets();
#else
		_ = terminal;
		// TODO Phase 2: host RPC enumerates map-placed GovernmentTaxMinerEntity instances.
		return EditorStubGovDbTargets();
#endif
	}

	/// <summary>Advanced terminal only — nearby LIFEPUNCH HASHD bitcoin hubs (vengeance miner intrusion).</summary>
	public static IReadOnlyList<HashdTarget> RequestHashdScan( HackerTerminalEntity terminal, float maxDistance = 2500f )
	{
#if LIFEPUNCH_LOCAL
		_ = terminal;
		return EditorStubHashdTargets();
#else
		return BuildLiveHashdTargets( terminal, maxDistance );
#endif
	}

	private static IReadOnlyList<HashdTarget> EditorStubHashdTargets() => new[]
	{
		new HashdTarget( "hashd-preview-01", "HASHD hub (preview)", 42f, 0.0125f ),
	};

#if !LIFEPUNCH_LOCAL
	private static IReadOnlyList<HashdTarget> BuildLiveHashdTargets( HackerTerminalEntity terminal, float maxDistance )
	{
		if ( !terminal.IsValid() )
			return EditorStubHashdTargets();

		var scene = terminal.GameObject.Scene ?? Game.ActiveScene;
		if ( scene is null )
			return EditorStubHashdTargets();

		var origin = terminal.WorldPosition;
		var results = new List<HashdTarget>();

		foreach ( var hub in scene.GetAllComponents<LpBitcoinHubEntity>() )
		{
			if ( !hub.IsValid() )
				continue;

			var distance = hub.WorldPosition.Distance( origin );
			if ( distance > maxDistance )
				continue;

			results.Add( new HashdTarget(
				LpBitcoinHubAlertBridge.ToScanId( hub ),
				LpBitcoinIdent.HubDisplayName,
				distance,
				hub.HubWalletBtc ) );
		}

		return results.Count > 0 ? results : EditorStubHashdTargets();
	}
#endif

	private static IReadOnlyList<ScanTarget> EditorStubWalletTargets() => new[]
	{
		new ScanTarget( "76561198000000001", "target_alpha", 4200 ),
		new ScanTarget( "76561198000000002", "target_bravo", 1250 ),
		new ScanTarget( "76561198000000003", "target_charlie", 890 ),
	};

#if !LIFEPUNCH_LOCAL
	private static IReadOnlyList<ScanTarget> BuildLiveWalletTargets()
	{
		var manager = GameNetworkManager.Instance;
		if ( !manager.IsValid() )
			return EditorStubWalletTargets();

		var localId = Player.Local.IsValid() ? Player.Local.SteamId : 0L;
		var results = new List<ScanTarget>();

		foreach ( var entry in manager.Players )
		{
			var player = entry.Value;
			if ( !player.IsValid() )
				continue;

			if ( localId != 0 && player.SteamId == localId )
				continue;

			var wallet = (int)player.WalletBalance;
			results.Add( new ScanTarget(
				player.SteamId.ToString(),
				player.DisplayName,
				wallet ) );
		}

		return results.Count > 0 ? results : EditorStubWalletTargets();
	}
#endif

	private static IReadOnlyList<GovDbTarget> EditorStubGovDbTargets() => new[]
	{
		new GovDbTarget( "govdb-tax-01", "City Treasury Miner", "CLASSIFIED" ),
		new GovDbTarget( "govdb-records", "Civic Records Shard", "RESTRICTED" ),
		new GovDbTarget( "govdb-audit", "Tax Audit Trail", "ELEVATED" ),
	};
}
