// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// ─────────────────────────────────────────────────────────────────────────────

using LifePunch.DXRP.Addons;

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>
/// rack_compute — tenant #1 of the purchase ledger and the House Pattern reference
/// implementation (ECONOMY_DOCTRINE · UPGRADE_ARC_DESIGN decision 1). Unified COMPUTE
/// track, tiers I–V; replaces legacy CpuUpgradeLevel/CoreUpgradeLevel (deleted slice 2).
/// Base price ladder 0.25/0.75/2/6/16 BTC (decision 4); Advanced pays ladder × yield
/// multiplier at quote time — slice 2 (decision 5). Effects (Apply(tier) → ClockGhz +
/// CoreCount, ×2..×32) land in the effects slice (decision 2).
/// </summary>
internal static class LpBitcoinComputeTrack
{
	public const string TrackId = "rack_compute";

	/// <summary>Subject classes — apply honors tier ONLY on class match (GO ruling R1).</summary>
	public const string ClassStandard = "gpurack";
	public const string ClassAdvanced = "advancedgpurack";

	private static bool _registered;

	public static void EnsureRegistered()
	{
		if ( _registered )
			return;

		_registered = true;
		LifePunchUpgradeTracks.Register( new LifePunchTrackDef
		{
			Id = TrackId,
			MaxTier = 5,
			PriceLadderSats = new long[]
			{
				25_000_000,    // I   — 0.25 BTC
				75_000_000,    // II  — 0.75 BTC
				200_000_000,   // III — 2 BTC
				600_000_000,   // IV  — 6 BTC
				1_600_000_000, // V   — 16 BTC
			},
			SubjectKind = LifePunchTrackSubjectKind.Slot,
		} );
	}

	public static string ClassOf( LpBitcoinRackEntity rack )
		=> rack.AdvancedRack ? ClassAdvanced : ClassStandard;
}
