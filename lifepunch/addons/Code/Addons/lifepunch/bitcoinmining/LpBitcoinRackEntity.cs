// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// ─────────────────────────────────────────────────────────────────────────────

using System;
using Sandbox;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
#endif

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>GPU rack — idle BTC printer; mine/stop/sell only via terminal commands.</summary>
[Title( "LIFEPUNCH Bitcoin Rack (v2)" )]
[Category( "LifePunch/Bitcoin" )]
#if LIFEPUNCH_LOCAL
public sealed class LpBitcoinRackEntity : Component, Component.IPressable
#else
public sealed class LpBitcoinRackEntity : BaseEntity, Component.IPressable
#endif
{
	[Property] public bool LargeRack { get; set; }

	[Sync( SyncFlags.FromHost )] public Guid LinkedHubId { get; set; }
	[Sync( SyncFlags.FromHost )] public bool IsMining { get; set; }
	[Sync( SyncFlags.FromHost )] public float BitcoinAmount { get; set; }
	[Sync( SyncFlags.FromHost )] public float ClockGhz { get; set; } = LpBitcoinEconomy.StartClockGhz;
	[Sync( SyncFlags.FromHost )] public int CoreCount { get; set; } = LpBitcoinEconomy.StartCores;
	[Sync( SyncFlags.FromHost )] public int CpuUpgradeLevel { get; set; }
	[Sync( SyncFlags.FromHost )] public int CoreUpgradeLevel { get; set; }
	[Sync( SyncFlags.FromHost )] public float MiningProgress { get; set; }

	public float YieldMultiplier => LargeRack ? 2f : 1f;
	public float MiningRatePerMinute => LpBitcoinEconomy.MiningRatePerMinute( ClockGhz, CoreCount, YieldMultiplier );
	public int UsdValue => (int)(BitcoinAmount * LpBitcoinEconomy.BitcoinValueUsd);

	private TimeSince _sincePayout;

	protected override void OnUpdate()
	{
		var hub = GetLinkedHub();
		if ( !Networking.IsHost || hub is null || !hub.IsPowered || !IsMining )
			return;

		MiningProgress = Math.Clamp( _sincePayout.Relative / LpBitcoinEconomy.PayoutIntervalSeconds, 0f, 1f );

		if ( _sincePayout < LpBitcoinEconomy.PayoutIntervalSeconds )
			return;

		_sincePayout = 0;
		BitcoinAmount += LpBitcoinEconomy.TickPayout( ClockGhz, CoreCount, YieldMultiplier );
	}

	public bool Press( IPressable.Event e )
	{
		var hub = GetLinkedHub();
		if ( hub is null )
			return false;

		LpBitcoinTerminalUiHost.Open( hub, this );
		return true;
	}

	public void Hover( IPressable.Event e ) { }
	public void Blur( IPressable.Event e ) { }

	public void LinkToHub( LpBitcoinHubEntity hub )
	{
		if ( !hub.IsValid() )
			return;

		LinkedHubId = hub.GameObject.Id;
	}

	public LpBitcoinHubEntity GetLinkedHub()
	{
		if ( LinkedHubId == Guid.Empty )
			return null;

		var scene = GameObject.Scene ?? Game.ActiveScene;
		var go = scene?.Directory.FindByGuid( LinkedHubId );
		return go.IsValid() ? go.GetComponent<LpBitcoinHubEntity>() : null;
	}

	public void RequestSetMining( bool on ) => SetMiningHost( on );

	[Rpc.Host]
	private void SetMiningHost( bool on )
	{
		var hub = GetLinkedHub();
		if ( hub is null || !hub.IsPowered || !hub.CanOperateTerminal( Rpc.CallerId ) )
		{
			IsMining = false;
			return;
		}

		IsMining = on;
		if ( IsMining )
			_sincePayout = 0;
	}

	public void RequestSell() => SellHost();

	[Rpc.Host]
	private async void SellHost() => await SellForCallerHost( Rpc.CallerId );

	internal async System.Threading.Tasks.Task SellForCallerHost( Guid callerId )
	{
		if ( BitcoinAmount <= 0f )
			return;

		var hub = GetLinkedHub();
		if ( hub is null || !hub.CanOperateTerminal( callerId ) )
			return;

		var value = (uint)(BitcoinAmount * LpBitcoinEconomy.BitcoinValueUsd);
		if ( !await LpBitcoinWallet.TryPay( callerId, value, "LIFEPUNCH bitcoin sell" ) )
			return;

		BitcoinAmount = 0f;
	}

	internal void StopMiningHost()
	{
		IsMining = false;
		MiningProgress = 0f;
	}

	public void RequestUpgradeCpu() => UpgradeCpuHost();

	[Rpc.Host]
	private void UpgradeCpuHost() => ApplyUpgradeCpu( Rpc.CallerId );

	internal async void ApplyUpgradeCpu( Guid callerId )
	{
		if ( CpuUpgradeLevel >= LpBitcoinEconomy.CpuUpgradeCosts.Length )
			return;

		var hub = GetLinkedHub();
		if ( hub is null || !hub.CanManageHub( callerId ) )
			return;

		var cost = (uint)LpBitcoinEconomy.CpuUpgradeCosts[CpuUpgradeLevel];
		if ( !await LpBitcoinWallet.TryCharge( callerId, cost, "LIFEPUNCH CPU upgrade" ) )
			return;

		CpuUpgradeLevel++;
		ClockGhz += LpBitcoinEconomy.CpuGhzPerLevel;
	}

	public void RequestUpgradeCores() => UpgradeCoresHost();

	[Rpc.Host]
	private void UpgradeCoresHost() => ApplyUpgradeCores( Rpc.CallerId );

	internal async void ApplyUpgradeCores( Guid callerId )
	{
		if ( CoreUpgradeLevel >= LpBitcoinEconomy.CoreUpgradeCosts.Length )
			return;

		var hub = GetLinkedHub();
		if ( hub is null || !hub.CanManageHub( callerId ) )
			return;

		var cost = (uint)LpBitcoinEconomy.CoreUpgradeCosts[CoreUpgradeLevel];
		if ( !await LpBitcoinWallet.TryCharge( callerId, cost, "LIFEPUNCH core upgrade" ) )
			return;

		CoreUpgradeLevel++;
		CoreCount += LpBitcoinEconomy.CoresPerLevel;
	}
}
