// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Government Datacenter" (s&box ident: lifepunch.governmentdatacenter · addon ident: governmentdatacenter) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Author account: mrragerlp · Public alias (in-game · Steam · Discord): Bloodwave
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System;

namespace LifePunch.DXRP.Addons.GovernmentDatacenter;

/// <summary>
/// Economy constants for city treasury tax miners.
/// Mirrors player <see cref="BitcoinMining.GpuRackEntity"/> math — always mining, no player withdraw.
/// Implementation: Opus ports from GpuRackEntity on Red; entity stub lands in Phase 2.
/// </summary>
public static class GovernmentTaxMiner
{
	/// <summary>Keep in sync with GpuRackEntity.BitcoinValue until a shared economy module exists.</summary>
	public const float BitcoinUsdRate = 1500f;

	/// <summary>Owner cap: accumulated BTC worth at most this many in-game dollars.</summary>
	public const float BtcBalanceUsdCap = 30_000f;

	/// <summary>Max BTC held on miner before accrual stops: $30,000 / $1,500 = 20 BTC.</summary>
	public const float BtcBalanceCap = BtcBalanceUsdCap / BitcoinUsdRate;

	public const float BaseSpeed = 0.005f;
	public const float MiningIntervalSeconds = 60f;
	public const float TaxPayoutIntervalSeconds = 3600f;

	/// <summary>Default city tax rate when map/server has not set one (0–0.30).</summary>
	public const float DefaultTaxRate = 0.15f;

	public const float MinTaxRate = 0f;
	public const float MaxTaxRate = 0.30f;

	/// <summary>Starting hash profile (no player upgrades on gov miners).</summary>
	public const float StartClockGhz = 2.44f;
	public const int StartCoreCount = 1;

	public static float BtcPerMinute( float clockGhz, int cores ) => clockGhz * BaseSpeed * cores;

	public static float ClampTaxRate( float rate ) =>
		MathF.Max( MinTaxRate, MathF.Min( MaxTaxRate, rate ) );

	/// <summary>Cash deposited to city funds each hourly tick.</summary>
	public static int TaxCashPayout( float btcBalance, float taxRate )
	{
		var clamped = ClampTaxRate( taxRate );
		return (int)MathF.Floor( btcBalance * BitcoinUsdRate * clamped );
	}

	public static float ClampBtcBalance( float amount ) =>
		MathF.Min( amount, BtcBalanceCap );
}
