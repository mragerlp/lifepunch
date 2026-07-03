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

	/// <summary>Offline/dev fallback when portal sync has not run yet.</summary>
	public const int DefaultBitcoinCashUsd = 5000;

	/// <summary>Default $ paid per portal inventory BTC stack on Use (independent of hub mined BTC rate).</summary>
	public const int DefaultPortalRedeemCashUsd = 5000;

	/// <summary>
	/// Live $ per 1 mined BTC in the hub wallet (hub cashout → DXRP bank via PayHost inBank).
	/// Owner-controlled separately from <see cref="PortalRedeemCashUsdPerStack"/>.
	/// </summary>
	public static int PortalBaseCashUsdPerBtc { get; private set; } = DefaultBitcoinCashUsd;

	/// <summary>
	/// Live $ per 1 portal inventory $BTC stack when player Uses consumable
	/// (<see cref="LpBitcoinIdent.PortalBtcRedeemGrantName"/>).
	/// </summary>
	public static int PortalRedeemCashUsdPerStack { get; private set; } = DefaultPortalRedeemCashUsd;

	/// <summary>Runtime portal-backed base rate (was const $5000).</summary>
	public static int BitcoinValueUsd => PortalBaseCashUsdPerBtc;

	/// <summary>Live server/event multiplier on cash rate (1 = normal). UI + payout both read <see cref="CashUsdPerBtc"/>.</summary>
	public static float CashRateMultiplier { get; set; } = 1f;

	/// <summary>Effective $ per BTC for display and hub bank cashout (portal base × event multiplier).</summary>
	public static float CashUsdPerBtc => PortalBaseCashUsdPerBtc * MathF.Max( 0f, CashRateMultiplier );

	/// <summary>Host/event hook — hub mined BTC cashout rate + optional event multiplier.</summary>
	public static void ApplyPortalBacking( int cashUsdPerBtc, float eventMultiplier = 1f )
	{
		PortalBaseCashUsdPerBtc = Math.Max( 0, cashUsdPerBtc );
		CashRateMultiplier = MathF.Max( 0f, eventMultiplier );
		PortalEconomyRevision++;
	}

	/// <summary>Portal inventory stack redeem rate (1 Use = 1 stack → this many dollars).</summary>
	public static void ApplyPortalRedeemBacking( int cashUsdPerStack )
	{
		PortalRedeemCashUsdPerStack = Math.Max( 0, cashUsdPerStack );
		PortalEconomyRevision++;
	}

	public static uint PortalRedeemCashPayout()
	{
		if ( PortalRedeemCashUsdPerStack <= 0 )
		{
			return 0;
		}

		return (uint)PortalRedeemCashUsdPerStack;
	}

	/// <summary>Monotonic tick — hub UI BuildHash includes economy fields.</summary>
	public static int PortalEconomyRevision { get; private set; }

	public static float BtcToCashUsd( float btc ) => btc * CashUsdPerBtc;

	public static uint BtcToCashPayout( float btc )
	{
		var usd = BtcToCashUsd( btc );
		if ( usd <= 0f )
			return 0;

		return (uint)MathF.Floor( usd );
	}

	public static string FormatExchangeRateLabel()
	{
		if ( MathF.Abs( CashRateMultiplier - 1f ) < 0.001f )
			return $"${PortalBaseCashUsdPerBtc:N0} / BTC";

		return $"${CashUsdPerBtc:N0} / BTC ({CashRateMultiplier:0.##}×)";
	}

	public static string FormatBtcToCash( float btc, string btcFormat = "F6" )
		=> $"{btc.ToString( btcFormat )} BTC → ${BtcToCashUsd( btc ):N2}";

	public const float StartClockGhz = 2.44f;
	public const int StartCores = 1;

	public const float CpuGhzPerLevel = 1.5f;
	public const int CoresPerLevel = 2;

	/// <summary>Four purchasable CPU clock tiers per rack (hub upgrades panel shows one at a time).</summary>
	public static readonly int[] CpuUpgradeCosts =
	{
		2000, 4000, 8000, 16000
	};

	/// <summary>Four purchasable core-count tiers per rack (hub upgrades panel shows one at a time).</summary>
	public static readonly int[] CoreUpgradeCosts =
	{
		50000, 100000, 175000, 350000
	};

	public static float MiningRatePerMinute( float clockGhz, int cores, float rackYield = 1f )
	{
		var perTick = clockGhz * BaseSpeed * cores * rackYield;
		return perTick * (60f / PayoutIntervalSeconds);
	}

	public static float TickPayout( float clockGhz, int cores, float rackYield = 1f )
		=> clockGhz * BaseSpeed * cores * rackYield;

	/// <summary>Undeposited BTC cap per rack before mining stops and hub alerts fire.</summary>
	public const float RackBtcCapacity = 0.15f;

	public static float RackBtcCapacityFor( LpBitcoinRackEntity rack )
		=> RackBtcCapacity;
}
