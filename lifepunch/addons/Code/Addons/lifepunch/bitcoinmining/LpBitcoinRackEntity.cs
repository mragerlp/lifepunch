// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// ─────────────────────────────────────────────────────────────────────────────

using System;
using Sandbox;
using LifePunch.DXRP.Addons;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
using Dxura.RP.Shared;
#endif

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>GPU rack — idle BTC printer; deposit to hub wallet via bitcoin terminal only.</summary>
[Title( "LIFEPUNCH Bitcoin Rack (v2)" )]
[Category( "LifePunch/Bitcoin" )]
#if LIFEPUNCH_LOCAL
public sealed class LpBitcoinRackEntity : Component, Component.IPressable
#else
public sealed class LpBitcoinRackEntity : BaseEntity, Component.IPressable
#endif
{
	/// <summary>Stacked rack (<see cref="LpBitcoinIdent.AdvancedRackSlug"/>) — <see cref="LpBitcoinIdent.AdvancedRackDisplayName"/>, 2× yield.</summary>
	[Property] public bool AdvancedRack { get; set; }

	[Sync( SyncFlags.FromHost )] public Guid LinkedHubId { get; set; }
	[Sync( SyncFlags.FromHost )] public bool IsMining { get; set; }
	[Sync( SyncFlags.FromHost )] public float BitcoinAmount { get; set; }
	[Sync( SyncFlags.FromHost )] public float ClockGhz { get; set; } = LpBitcoinEconomy.StartClockGhz;
	[Sync( SyncFlags.FromHost )] public int CoreCount { get; set; } = LpBitcoinEconomy.StartCores;
	[Sync( SyncFlags.FromHost )] public int CpuUpgradeLevel { get; set; }
	[Sync( SyncFlags.FromHost )] public int CoreUpgradeLevel { get; set; }
	[Sync( SyncFlags.FromHost )] public float MiningProgress { get; set; }

	public float YieldMultiplier => AdvancedRack ? 2f : 1f;
	public float MiningRatePerMinute => LpBitcoinEconomy.MiningRatePerMinute( ClockGhz, CoreCount, YieldMultiplier );
	public int UsdValue => (int)(BitcoinAmount * LpBitcoinEconomy.BitcoinValueUsd);

#if !LIFEPUNCH_LOCAL
	public override string DisplayName => AdvancedRack
		? LpBitcoinIdent.AdvancedRackDisplayName
		: LpBitcoinIdent.RackDisplayName;
#endif

	private TimeSince _sincePayout;
	private ModelRenderer _modelRenderer;
	private LpBitcoinRackVisuals _visuals;
	private bool _lastMiningVisual;
	private bool _capacityAlertSent;

	protected override void OnStart()
	{
		base.OnStart();
#if !LIFEPUNCH_LOCAL
		LifePunchPropPhysics.SyncBoxColliderFromModel( GameObject );
		if ( Networking.IsHost )
			LifePunchGroundContact.AlignMeshBottom( GameObject );
		this.TryBindSpawnOwnerHost();
#endif
		_modelRenderer = Components.Get<ModelRenderer>( FindMode.EverythingInSelf );
		_visuals = Components.Get<LpBitcoinRackVisuals>( FindMode.EverythingInSelf );
		if ( !_visuals.IsValid() )
		{
			_visuals = GameObject.AddComponent<LpBitcoinRackVisuals>();
			_visuals.Rack = this;
		}

		ApplyRackMiningVisual( IsMining );
	}

#if !LIFEPUNCH_LOCAL
	public override void OnOcclusionChanged( bool occlude )
	{
		base.OnOcclusionChanged( occlude );
		_visuals?.OnOcclusionChanged( occlude );
	}
#endif

	protected override void OnFixedUpdate()
	{
#if !LIFEPUNCH_LOCAL
		TryAlignGroundWhenReleased();
#endif
	}

	protected override void OnUpdate()
	{
		if ( IsMining != _lastMiningVisual )
			ApplyRackMiningVisual( IsMining );

		if ( !Networking.IsHost )
			return;

		var hub = GetLinkedHub();
		if ( hub is null || !hub.IsPowered || !IsMining )
			return;

		MiningProgress = Math.Clamp( _sincePayout.Relative / LpBitcoinEconomy.PayoutIntervalSeconds, 0f, 1f );

		if ( _sincePayout < LpBitcoinEconomy.PayoutIntervalSeconds )
			return;

		_sincePayout = 0;
		BitcoinAmount += LpBitcoinEconomy.TickPayout( ClockGhz, CoreCount, YieldMultiplier );
		TryHandleCapacityHost();
		RefreshLinkedTerminalScreens();
	}

	private void TryHandleCapacityHost()
	{
		var capacity = LpBitcoinEconomy.RackBtcCapacity( AdvancedRack );
		if ( BitcoinAmount < capacity )
		{
			_capacityAlertSent = false;
			return;
		}

		BitcoinAmount = capacity;

		if ( IsMining )
			StopMiningHost();

		if ( _capacityAlertSent )
			return;

		_capacityAlertSent = true;
		var hub = GetLinkedHub();
		if ( hub is null )
			return;

		hub.PushRackCapacityAlertHost( hub.GetRackIndex( this ), BitcoinAmount, capacity );
	}

	public bool Press( IPressable.Event e ) => false;

	public void Hover( IPressable.Event e ) { }
	public void Blur( IPressable.Event e ) { }

	public void LinkToHub( LpBitcoinHubEntity hub )
	{
		if ( !hub.IsValid() )
			return;

		LinkedHubId = hub.GameObject.Id;
		hub.RefreshLinkedTerminalScreens();
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
			ApplyRackMiningVisual( false );
			RefreshLinkedTerminalScreens();
			return;
		}

		if ( on && BitcoinAmount >= LpBitcoinEconomy.RackBtcCapacity( AdvancedRack ) )
			on = false;

		IsMining = on;
		if ( IsMining )
			_sincePayout = 0;

		ApplyRackMiningVisual( IsMining );
		RefreshLinkedTerminalScreens();
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
		ApplyRackMiningVisual( false );
		RefreshLinkedTerminalScreens();
	}

	internal void ClearBalanceHost()
	{
		BitcoinAmount = 0f;
		_capacityAlertSent = false;
		RefreshLinkedTerminalScreens();
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

	private void ApplyRackMiningVisual( bool mining )
	{
		_lastMiningVisual = mining;

		if ( !_modelRenderer.IsValid() )
			_modelRenderer = Components.Get<ModelRenderer>( FindMode.EverythingInSelf );

		if ( !_modelRenderer.IsValid() )
			return;

		var played = LpBitcoinPowerAnim.ApplyRackPower( _modelRenderer, mining, out _ );
		_visuals?.SetVmdlAnimActive( played && mining );
	}

	private void RefreshLinkedTerminalScreens()
	{
		GetLinkedHub()?.RefreshLinkedTerminalScreens();
	}

	private void TryAlignGroundWhenReleased()
	{
		if ( !Networking.IsHost || GameObject.Tags.Has( Constants.GrabbedTag ) )
			return;

		if ( !_modelRenderer.IsValid() )
			_modelRenderer = Components.Get<ModelRenderer>( FindMode.EverythingInSelf );

		if ( !_modelRenderer.IsValid() || _modelRenderer.Bounds.Mins.z > -0.15f )
			return;

		if ( Rigidbody.IsValid() && Rigidbody.Velocity.Length > 8f )
			return;

		LifePunchGroundContact.AlignMeshBottom( GameObject );
	}
}
