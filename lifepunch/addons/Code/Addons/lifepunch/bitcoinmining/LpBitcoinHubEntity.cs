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

using System;
using System.Threading.Tasks;
using Sandbox;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
#endif

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>Greenfield v2 hub — wallet, mining loop, USE → HASHD module panel.</summary>
[Title( "LIFEPUNCH Bitcoin Hub (v2)" )]
[Category( "LifePunch/Bitcoin" )]
#if LIFEPUNCH_LOCAL
public sealed class LpBitcoinHubEntity : Component, Component.IPressable
#else
public sealed class LpBitcoinHubEntity : BaseEntity, Component.IPressable
#endif
{
	[Sync( SyncFlags.FromHost )] public bool IsPowered { get; set; } = true;
	[Sync( SyncFlags.FromHost )] public bool IsMining { get; set; }
	[Sync( SyncFlags.FromHost )] public float BitcoinAmount { get; set; }
	[Sync( SyncFlags.FromHost )] public float ClockGhz { get; set; } = LpBitcoinEconomy.StartClockGhz;
	[Sync( SyncFlags.FromHost )] public int CoreCount { get; set; } = LpBitcoinEconomy.StartCores;
	[Sync( SyncFlags.FromHost )] public int CpuUpgradeLevel { get; set; }
	[Sync( SyncFlags.FromHost )] public int CoreUpgradeLevel { get; set; }
	[Sync( SyncFlags.FromHost )] public float MiningProgress { get; set; }

#if LIFEPUNCH_LOCAL
	[Sync( SyncFlags.FromHost )] public long Owner { get; set; }
#endif

	private TimeSince _sincePayout;

	public float RackYieldMultiplier { get; set; } = 1f;

	public float MiningRatePerMinute => LpBitcoinEconomy.MiningRatePerMinute( ClockGhz, CoreCount, RackYieldMultiplier );
	public int UsdValue => (int)(BitcoinAmount * LpBitcoinEconomy.BitcoinValueUsd);

	protected override void OnUpdate()
	{
		if ( !Networking.IsHost || !IsPowered || !IsMining )
			return;

		MiningProgress = Math.Clamp( _sincePayout.Relative / LpBitcoinEconomy.PayoutIntervalSeconds, 0f, 1f );

		if ( _sincePayout < LpBitcoinEconomy.PayoutIntervalSeconds )
			return;

		_sincePayout = 0;
		BitcoinAmount += LpBitcoinEconomy.TickPayout( ClockGhz, CoreCount, RackYieldMultiplier );
	}

	public bool Press( IPressable.Event e )
	{
		if ( !IsPowered )
			return false;

		LpHashdUiHost.Open( this );
		return true;
	}

	public void Hover( IPressable.Event e ) { }
	public void Blur( IPressable.Event e ) { }

	public void SetMining( bool on ) => SetMiningHost( on );

	[Rpc.Host]
	private void SetMiningHost( bool on )
	{
		IsMining = on && IsPowered;
		if ( IsMining )
			_sincePayout = 0;
	}

	public void RequestSell() => SellHost();

	[Rpc.Host]
	private async void SellHost()
	{
		if ( BitcoinAmount <= 0f )
			return;

		var value = (uint)(BitcoinAmount * LpBitcoinEconomy.BitcoinValueUsd);
		if ( !await TryPayPlayer( Rpc.CallerId, value, "LIFEPUNCH bitcoin sell" ) )
			return;

		BitcoinAmount = 0f;
	}

	public void RequestUpgradeCpu() => UpgradeCpuHost();

	[Rpc.Host]
	private async void UpgradeCpuHost()
	{
		if ( CpuUpgradeLevel >= LpBitcoinEconomy.CpuUpgradeCosts.Length )
			return;

		var cost = (uint)LpBitcoinEconomy.CpuUpgradeCosts[CpuUpgradeLevel];
		if ( !await TryChargePlayer( Rpc.CallerId, cost, "LIFEPUNCH CPU upgrade" ) )
			return;

		CpuUpgradeLevel++;
		ClockGhz += LpBitcoinEconomy.CpuGhzPerLevel;
	}

	public void RequestUpgradeCores() => UpgradeCoresHost();

	[Rpc.Host]
	private async void UpgradeCoresHost()
	{
		if ( CoreUpgradeLevel >= LpBitcoinEconomy.CoreUpgradeCosts.Length )
			return;

		var cost = (uint)LpBitcoinEconomy.CoreUpgradeCosts[CoreUpgradeLevel];
		if ( !await TryChargePlayer( Rpc.CallerId, cost, "LIFEPUNCH core upgrade" ) )
			return;

		CoreUpgradeLevel++;
		CoreCount += LpBitcoinEconomy.CoresPerLevel;
	}

	public void BindOwnerFromLocalViewer()
	{
#if !LIFEPUNCH_LOCAL
		if ( !Networking.IsHost || Owner != 0 )
			return;

		if ( Player.Local.IsValid() )
			Owner = Player.Local.SteamId;
#else
		Owner = 1;
#endif
	}

#if LIFEPUNCH_LOCAL
	private static async Task<bool> TryChargePlayer( Guid callerId, uint amount, string reason )
	{
		await Task.CompletedTask;
		return true;
	}

	private static async Task<bool> TryPayPlayer( Guid callerId, uint amount, string reason )
	{
		await Task.CompletedTask;
		return true;
	}
#else
	private static async Task<bool> TryChargePlayer( Guid callerId, uint amount, string reason )
	{
		var player = GameUtils.GetPlayerByConnectionId( callerId );
		return player.IsValid() && await player.ChargeHost( amount, reason );
	}

	private static async Task<bool> TryPayPlayer( Guid callerId, uint amount, string reason )
	{
		var player = GameUtils.GetPlayerByConnectionId( callerId );
		return player.IsValid() && await player.PayHost( amount, reason );
	}
#endif
}
