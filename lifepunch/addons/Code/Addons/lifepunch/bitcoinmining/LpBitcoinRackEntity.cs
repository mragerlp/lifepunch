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
using DamageInfo = Dxura.RP.Game.DamageInfo;
#endif

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>GPU rack — idle BTC printer; deposit to hub wallet via bitcoin terminal only.</summary>
[Title( "LIFEPUNCH Bitcoin Rack (v2)" )]
[Category( "LifePunch/Bitcoin" )]
#if LIFEPUNCH_LOCAL
public sealed class LpBitcoinRackEntity : Component, Component.IPressable
#else
public sealed class LpBitcoinRackEntity : BaseEntity, Component.IPressable, IAreaDamageReceiver
#endif
{
	/// <summary>GPU rack farm — stacked mesh; per-rack CPU/core upgrades drive mining rate.</summary>
	[Property] public bool AdvancedRack { get; set; } = true;

	/// <summary>Dev spawn (<see cref="LpBitcoinDevSpawn"/>) — feet on ground, frozen collider (no printer drop).</summary>
	internal bool DevSpawnAsWorldMachine { get; set; }

	[Sync( SyncFlags.FromHost )] public Guid LinkedHubId { get; set; }
	[Sync( SyncFlags.FromHost )] public bool IsMining { get; set; }
	[Sync( SyncFlags.FromHost )] public float BitcoinAmount { get; set; }
	[Sync( SyncFlags.FromHost )] public float ClockGhz { get; set; } = LpBitcoinEconomy.StartClockGhz;
	[Sync( SyncFlags.FromHost )] public int CoreCount { get; set; } = LpBitcoinEconomy.StartCores;
	[Sync( SyncFlags.FromHost )] public int CpuUpgradeLevel { get; set; }
	[Sync( SyncFlags.FromHost )] public int CoreUpgradeLevel { get; set; }
	[Sync( SyncFlags.FromHost )] public float MiningProgress { get; set; }

	public float YieldMultiplier => LpBitcoinIdent.BaseRackYieldMultiplier;
	public float MiningRatePerMinute => LpBitcoinEconomy.MiningRatePerMinute( ClockGhz, CoreCount, YieldMultiplier );
	public int UsdValue => (int)LpBitcoinEconomy.BtcToCashUsd( BitcoinAmount );

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
#if !LIFEPUNCH_LOCAL
	[Property]
	[Group( "Effects" )]
	public GameObject Explosion { get; set; }

	bool _isExploding;
	int _spawnDropGraceTicks;
	bool _colliderSyncedFromModel;
#endif

	protected override void OnAwake()
	{
		// Collider sync after spawn grace in OnFixedUpdate (printer-style drop).
	}

	protected override void OnStart()
	{
		base.OnStart();
#if !LIFEPUNCH_LOCAL
		this.TryBindSpawnOwnerHost();
		if ( Networking.IsHost )
		{
			if ( DevSpawnAsWorldMachine )
			{
				ApplyVirginSpawnDefaultsHost();
				if ( HealthComponent.IsValid() )
				{
					HealthComponent.MaxHealth = LpBitcoinIdent.RackMaxHealth;
					if ( HealthComponent.Health <= 0f || HealthComponent.Health > HealthComponent.MaxHealth )
						HealthComponent.Health = HealthComponent.MaxHealth;
				}

				LifePunchPropPhysics.SetupWorldMachine( GameObject, alignGround: true );
				_colliderSyncedFromModel = true;
				Log.Info( $"RACK_SPAWN_PHYSICS advanced={AdvancedRack} pos={GameObject.WorldPosition} mode=dev-world-machine" );
			}
			else
			{
				ApplyVirginSpawnDefaultsHost();
				if ( HealthComponent.IsValid() )
				{
					HealthComponent.MaxHealth = LpBitcoinIdent.RackMaxHealth;
					if ( HealthComponent.Health <= 0f || HealthComponent.Health > HealthComponent.MaxHealth )
						HealthComponent.Health = HealthComponent.MaxHealth;
				}

				_spawnDropGraceTicks = 45;
				_colliderSyncedFromModel = false;
				LifePunchPropPhysics.BeginGrabbablePrinterDrop( GameObject, syncColliderFromModel: false );
				Log.Info( $"RACK_SPAWN_PHYSICS advanced={AdvancedRack} pos={GameObject.WorldPosition} gravity=on (printer drop)" );
			}
		}
#endif
		_modelRenderer = Components.Get<ModelRenderer>( FindMode.EverythingInSelf )
		                 ?? Components.Get<SkinnedModelRenderer>( FindMode.EverythingInSelf ) as ModelRenderer;
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
		if ( !Networking.IsHost )
			return;

		LifePunchPropPhysics.MaintainGrabbablePlaceableProp( GameObject );

		if ( _spawnDropGraceTicks > 0 )
		{
			_spawnDropGraceTicks--;
			return;
		}

		if ( !_colliderSyncedFromModel )
		{
			LifePunchPropPhysics.SyncBoxColliderFromModel( GameObject );
			_colliderSyncedFromModel = true;
		}
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
		var capacity = LpBitcoinEconomy.RackBtcCapacity;
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

		if ( Networking.IsHost && !hub.IsPowered )
			return;

		LinkedHubId = hub.GameObject.Id;
#if !LIFEPUNCH_LOCAL
		if ( Networking.IsHost )
			StopMiningHost();
#endif
		hub.RefreshLinkedTerminalScreens();
	}

	public LpBitcoinHubEntity GetLinkedHub()
		=> LpBitcoinHubEntity.FindByGameObjectId( LinkedHubId, GameObject.Scene ?? Game.ActiveScene );

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

		if ( on && BitcoinAmount >= LpBitcoinEconomy.RackBtcCapacity )
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

		var value = LpBitcoinEconomy.BtcToCashPayout( BitcoinAmount );
		if ( !await LpBitcoinWallet.TryPayBank( callerId, value, "LIFEPUNCH bitcoin sell" ) )
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
#if !LIFEPUNCH_LOCAL
		_visuals?.SyncMiningVisualState();
#endif
	}

	private void RefreshLinkedTerminalScreens()
	{
		GetLinkedHub()?.RefreshLinkedTerminalScreens();
	}

	/// <summary>Market spawn baseline — unlinked racks stay idle until registered at rig0.</summary>
	private void ApplyVirginSpawnDefaultsHost()
	{
		if ( LinkedHubId != Guid.Empty )
			return;

		IsMining = false;
		MiningProgress = 0f;
	}

	internal static LpBitcoinRackEntity FindNearestUnlinked( LpBitcoinHubEntity hub, float maxRange )
	{
		if ( !hub.IsValid() )
			return null;

		var scene = hub.GameObject.Scene ?? Game.ActiveScene;
		if ( scene is null )
			return null;

		LpBitcoinRackEntity best = null;
		var bestDist = float.MaxValue;
		var hubPos = hub.WorldPosition;

		foreach ( var rack in scene.GetAllComponents<LpBitcoinRackEntity>() )
		{
			if ( !rack.IsValid() || rack.LinkedHubId != Guid.Empty )
				continue;

#if !LIFEPUNCH_LOCAL
			if ( !LifePunchEntityOwnership.SharesOperator( hub.Owner, rack.Owner ) )
				continue;
#endif

			var dist = hubPos.Distance( rack.WorldPosition );
			if ( dist > maxRange || dist >= bestDist )
				continue;

			bestDist = dist;
			best = rack;
		}

		return best;
	}

#if !LIFEPUNCH_LOCAL
	public void ApplyAreaDamage( AreaDamage component )
	{
		var dmg = new DamageInfo(
			component.Attacker,
			component.Damage,
			component.Inflictor,
			component.WorldPosition,
			Flags: component.DamageFlags );

		HealthComponent?.TakeDamageHost( dmg );
	}

	protected override void OnDestroyed()
	{
		if ( Networking.IsHost && !_isExploding )
		{
			_isExploding = true;
			StopMiningHost();
			BitcoinAmount = 0f;
			LifePunchMachineDestroyFx.SpawnPrinterStyleExplosion( this, Explosion, WorldPosition );
		}

		base.OnDestroyed();
	}
#endif
}
