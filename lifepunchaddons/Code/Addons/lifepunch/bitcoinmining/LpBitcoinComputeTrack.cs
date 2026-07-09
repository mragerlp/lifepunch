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
/// track, tiers I–V; the legacy CpuUpgradeLevel/CoreUpgradeLevel pair is deleted
/// (slice 2, GO ruling R2). Base price ladder 0.25/0.75/2/6/16 BTC (decision 4);
/// Advanced pays ladder × yield multiplier read at quote time (decision 5). Effects
/// are ABSOLUTE: Apply(tier) sets ClockGhz + CoreCount from tier alone, rate vector
/// ×2/4/8/16/32 (decision 2).
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

	/// <summary>Rate multiplier vs stock for a tier: ×1 at T0, ×2/4/8/16/32 at I–V.</summary>
	public static int EffectMultiplierFor( int tier )
		=> 1 << System.Math.Clamp( tier, 0, 5 );

	/// <summary>Absolute effect apply — ClockGhz + CoreCount derive from tier ALONE
	/// (decision 2). One knob: the clock carries the whole vector; cores stay stock.
	/// Idempotent; also runs at reconcile so a rehydrated rack re-derives its rate.</summary>
	public static void Apply( LpBitcoinRackEntity rack, int tier )
	{
		rack.ClockGhz = LpBitcoinEconomy.StartClockGhz * EffectMultiplierFor( tier );
		rack.CoreCount = LpBitcoinEconomy.StartCores;
	}

	/// <summary>Quote for a tier on THIS rack — base ladder × the rack's yield
	/// multiplier, read at quote time (decision 5: Advanced pays 2× for 2× throughput).
	/// Returns -1 when the tier has no price.</summary>
	public static long QuoteSats( LpBitcoinRackEntity rack, int tier )
	{
		EnsureRegistered();
		var baseSats = LifePunchUpgradeTracks.Get( TrackId )?.PriceSatsForTier( tier ) ?? -1;
		if ( baseSats < 0 )
			return -1;

		return (long)System.Math.Round( baseSats * (double)rack.YieldMultiplier );
	}
}
