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

/// <summary>Server-authoritative economy tuning — canon from BITCOINMINING_UX_SPEC.md.</summary>
public static class LpBitcoinEconomy
{
	public const float BaseSpeed = 0.005f;
	public const float PayoutIntervalSeconds = 90f;
	public const int BitcoinValueUsd = 5000;

	public const float StartClockGhz = 2.44f;
	public const int StartCores = 1;

	public const float CpuGhzPerLevel = 1.5f;
	public const int CoresPerLevel = 2;

	public static readonly int[] CpuUpgradeCosts =
	{
		2000, 4000, 8000, 16000, 32000, 64000, 128000
	};

	public static readonly int[] CoreUpgradeCosts =
	{
		50000, 100000, 175000
	};

	public static float MiningRatePerMinute( float clockGhz, int cores, float rackYield = 1f )
	{
		var perTick = clockGhz * BaseSpeed * cores * rackYield;
		return perTick * (60f / PayoutIntervalSeconds);
	}

	public static float TickPayout( float clockGhz, int cores, float rackYield = 1f )
		=> clockGhz * BaseSpeed * cores * rackYield;

	/// <summary>Undeposited BTC cap per rack before mining stops and hub alerts fire.</summary>
	public const float StandardRackBtcCapacity = 0.05f;
	public const float AdvancedRackBtcCapacity = 0.15f;

	public static float RackBtcCapacity( bool advancedRack )
		=> advancedRack ? AdvancedRackBtcCapacity : StandardRackBtcCapacity;
}
