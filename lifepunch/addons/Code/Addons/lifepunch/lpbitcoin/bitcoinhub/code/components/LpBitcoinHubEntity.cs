// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// ─────────────────────────────────────────────────────────────────────────────

using System;
using System.Collections.Generic;
using System.Linq;
using Sandbox;
using LifePunch.DXRP.Addons;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
using DamageInfo = Dxura.RP.Game.DamageInfo;
#endif

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>Hub — PIN, power, linking, upgrades (purchased here). No mine/sell on hub UI.</summary>
[Title( "LIFEPUNCH Bitcoin Hub (v2)" )]
[Category( "LifePunch/Bitcoin" )]
#if LIFEPUNCH_LOCAL
public sealed class LpBitcoinHubEntity : Component, Component.IPressable
#else
public sealed class LpBitcoinHubEntity : BaseEntity, Component.IPressable, IAreaDamageReceiver
#endif
{
#if !LIFEPUNCH_LOCAL
	[Property]
	[Group( "Effects" )]
	public GameObject Explosion { get; set; }

	bool _isExploding;
#endif
	[Sync( SyncFlags.FromHost )] public bool IsPowered { get; set; }
	[Sync( SyncFlags.FromHost )] public bool AccessPinIsSet { get; set; }
	[Sync( SyncFlags.FromHost )] public int AccessPinHash { get; set; }
#if LIFEPUNCH_LOCAL
	[Sync( SyncFlags.FromHost )] public long Owner { get; set; }
#endif
	/// <summary>PIN-gated hub wallet — rack BTC deposits here via terminal; cash out from hub admin.</summary>
	[Sync( SyncFlags.FromHost )] public float HubWalletBtc { get; set; }
	[Sync( SyncFlags.FromHost )] public string AlertFeed { get; private set; } = string.Empty;
	[Sync( SyncFlags.FromHost )] public int UnreadAlertCount { get; private set; }

#if !LIFEPUNCH_LOCAL
	public override string DisplayName => LpBitcoinIdent.HubDisplayName;
#endif

	/// <summary>Dev spawn (<see cref="LpBitcoinDevSpawn"/>) — feet on ground, frozen collider (no printer drop).</summary>
	internal bool DevSpawnAsWorldMachine { get; set; }

	private ModelRenderer _modelRenderer;
	private bool _lastPoweredVisual;
#if !LIFEPUNCH_LOCAL
	/// <summary>Skip collider sync / ground hacks until renderer bounds are live (printer-style drop).</summary>
	int _spawnDropGraceTicks;
	bool _colliderSyncedFromModel;
#endif

	protected override void OnAwake()
	{
		// Collider sync after ground align in OnStart (avoid self-hit trace).
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
					HealthComponent.MaxHealth = LpBitcoinIdent.HubMaxHealth;
					if ( HealthComponent.Health <= 0f || HealthComponent.Health > HealthComponent.MaxHealth )
						HealthComponent.Health = HealthComponent.MaxHealth;
				}

				LifePunchPropPhysics.SetupWorldMachine( GameObject, alignGround: true );
				_colliderSyncedFromModel = true;
				Log.Info( $"HUB_SPAWN_PHYSICS pos={GameObject.WorldPosition} mode=dev-world-machine" );
			}
			else
			{
				ApplyVirginSpawnDefaultsHost();
				if ( HealthComponent.IsValid() )
				{
					HealthComponent.MaxHealth = LpBitcoinIdent.HubMaxHealth;
					if ( HealthComponent.Health <= 0f || HealthComponent.Health > HealthComponent.MaxHealth )
						HealthComponent.Health = HealthComponent.MaxHealth;
				}

				// Printer drop — prefab collider first frame; no AlignMeshBottom teleport.
				_spawnDropGraceTicks = 45;
				_colliderSyncedFromModel = false;
				LifePunchPropPhysics.BeginGrabbablePrinterDrop( GameObject, syncColliderFromModel: false );
				Log.Info( $"HUB_SPAWN_PHYSICS pos={GameObject.WorldPosition} gravity=on (printer drop, no ground snap)" );
			}
		}
#endif
		_modelRenderer = Components.Get<ModelRenderer>( FindMode.EverythingInSelf )
		                 ?? Components.Get<SkinnedModelRenderer>( FindMode.EverythingInSelf ) as ModelRenderer;
		EnsureHubVisuals();
		ApplyHubPowerVisual( IsPowered );
	}

	private void EnsureHubVisuals()
	{
		var visuals = Components.Get<LpBitcoinHubVisuals>( FindMode.EverythingInSelf );
		if ( !visuals.IsValid() )
		{
			visuals = GameObject.AddComponent<LpBitcoinHubVisuals>();
			visuals.Hub = this;
		}
		else if ( !visuals.Hub.IsValid() )
		{
			visuals.Hub = this;
		}
	}

	/// <summary>Re-align feet after dev recall / reposition.</summary>
	public void RestartPrinterSettle()
	{
#if !LIFEPUNCH_LOCAL
		if ( !Networking.IsHost )
			return;

		_spawnDropGraceTicks = 45;
		_colliderSyncedFromModel = false;
		LifePunchPropPhysics.BeginGrabbablePrinterDrop( GameObject, syncColliderFromModel: false );
#endif
	}

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
		if ( IsPowered == _lastPoweredVisual )
			return;

		ApplyHubPowerVisual( IsPowered );
	}

	protected override void OnDestroy()
	{
		// Hub wallet is session/entity-bound — do not leave BTC on a destroyed hub.
		HubWalletBtc = 0f;
#if !LIFEPUNCH_LOCAL
		if ( Networking.IsHost )
			GetLinkedTerminal()?.UnlinkFromHub();
#endif
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
			LifePunchMachineDestroyFx.SpawnPrinterStyleExplosion( this, Explosion, WorldPosition );
		}

		base.OnDestroyed();
	}
#endif

	public bool CanPress( IPressable.Event e ) => LifePunchMenuInteractGate.CanPressHubMenu( GameObject );

	public bool Press( IPressable.Event e )
	{
		RequestOpenHub();
		return true;
	}

	public void Hover( IPressable.Event e ) { }
	public void Blur( IPressable.Event e ) { }

	public void RequestOpenHub() => OpenHubHost();

	[Rpc.Host]
	private void OpenHubHost()
	{
#if !LIFEPUNCH_LOCAL
		if ( !LifePunchMenuInteractGate.IsCallerAllowedHub( Rpc.Caller, GameObject ) )
			return;
#else
		if ( !LifePunchMenuInteractGate.IsCallerAllowedHub( null, GameObject ) )
			return;
#endif

		OpenHub( Rpc.CallerId );
	}

	[Rpc.Broadcast]
	private void OpenHub( Guid callerId )
	{
		if ( Connection.Local.Id != callerId )
			return;

		LpHashdUiHost.Open( this );
	}

	public void SetPowered( bool on ) => SetPoweredHost( on );

	/// <summary>Host-side power apply without RPC caller (preview hub, editor).</summary>
	public void ApplyPoweredState( bool on )
	{
		IsPowered = on;
		ApplyHubPowerVisual( on );
		if ( !on )
		{
			foreach ( var rack in GetLinkedRacks() )
				rack.StopMiningHost();
		}

		RefreshLinkedTerminalScreens();
	}

	[Rpc.Host]
	private void SetPoweredHost( bool on )
	{
		if ( !CanManageHub( Rpc.CallerId ) )
			return;

		IsPowered = on;
		ApplyHubPowerVisual( on );
		if ( !on )
		{
			foreach ( var rack in GetLinkedRacks() )
				rack.StopMiningHost();
		}

		RefreshLinkedTerminalScreens();
	}

	public void RefreshLinkedTerminalScreens() => LpBitcoinTerminalEntity.RefreshForHub( this );

	public IReadOnlyList<LpBitcoinRackEntity> GetLinkedRacks()
	{
		var scene = GameObject.Scene ?? Game.ActiveScene;
		if ( scene is null )
			return Array.Empty<LpBitcoinRackEntity>();

		return LpBitcoinIdent.OrderLinkedRacks(
			scene.GetAllComponents<LpBitcoinRackEntity>()
				.Where( r => r.IsValid() && r.LinkedHubId == GameObject.Id ) );
	}

	public LpBitcoinRackEntity FindRackByIndex( int index )
	{
		var racks = GetLinkedRacks();
		return index >= 0 && index < racks.Count ? racks[index] : null;
	}

	public void RequestUpgradeCpu( Guid rackId ) => UpgradeCpuHost( rackId );

	public void RequestUpgradeCores( Guid rackId ) => UpgradeCoresHost( rackId );

	public void RequestSetAccessPin( string pin, string confirm ) => SetAccessPinHost( pin, confirm );

	public void RequestUnlockAccessPin( string pin ) => UnlockAccessPinHost( pin );

	public void RequestChangeAccessPin( string currentPin, string newPin, string confirm )
		=> ChangeAccessPinHost( currentPin, newPin, confirm );

	public void RequestDepositRacksToHub() => DepositRacksToHubHost();

	public void RequestDepositRack( int index ) => DepositRackHost( index );

	public void RequestCashOutHub( float amount ) => CashOutHubHost( amount, false );

	public void RequestCashOutAllHub() => CashOutHubHost( HubWalletBtc, true );

	public void RequestSendHubWallet( long targetSteamId, float amount ) => SendHubWalletHost( targetSteamId, amount );

	/// <summary>First hub in the scene owned by <paramref name="steamId"/> (excludes <paramref name="exclude"/>).</summary>
	public static LpBitcoinHubEntity FindHubByOwnerSteamId( long steamId, LpBitcoinHubEntity exclude = null )
	{
		if ( steamId == 0 )
			return null;

		var scene = Game.ActiveScene;
		if ( scene is null )
			return null;

		foreach ( var hub in scene.GetAllComponents<LpBitcoinHubEntity>() )
		{
			if ( !hub.IsValid() || hub == exclude )
				continue;

			if ( hub.Owner == steamId )
				return hub;
		}

		return null;
	}

	/// <summary>Legacy alias — cash out entire hub wallet.</summary>
	public void RequestSellAllRacks() => RequestCashOutAllHub();

	/// <summary>Resolve hub by spawned <see cref="GameObject.Id"/> — scene component scan, not Directory.FindByGuid.</summary>
	public static LpBitcoinHubEntity FindByGameObjectId( Guid hubId, Scene scene = null )
	{
		if ( hubId == Guid.Empty )
			return null;

		scene ??= Game.ActiveScene;
		if ( scene is null )
			return null;

		foreach ( var hub in scene.GetAllComponents<LpBitcoinHubEntity>() )
		{
			if ( hub.IsValid() && hub.GameObject.Id == hubId )
				return hub;
		}

		return null;
	}

	public bool HasLinkedTerminal() => GetLinkedTerminal().IsValid();

	public LpBitcoinTerminalEntity GetLinkedTerminal()
	{
		var scene = GameObject.Scene ?? Game.ActiveScene;
		if ( scene is null )
			return null;

		foreach ( var terminal in scene.GetAllComponents<LpBitcoinTerminalEntity>() )
		{
			if ( !terminal.IsValid() )
				continue;

			if ( terminal.LinkedHubId == GameObject.Id )
				return terminal;
		}

		return null;
	}

	public bool HasNearbyUnlinkedTerminal()
		=> LpBitcoinTerminalEntity.FindNearestUnlinked( this ).IsValid();

	/// <summary>Max distance from hub for terminal Settings link and rig0 <c>link</c> rack registration.</summary>
	[Property] public float RackLinkRange { get; set; } = 512f;

	public bool HasNearbyUnlinkedRack()
		=> LpBitcoinRackEntity.FindNearestUnlinked( this, RackLinkRange ).IsValid();

	public void RequestLinkNearbyRack() => LinkNearbyRackHost();

	public void RequestLinkRack( string slotToken ) => LinkRackByTokenHost( slotToken );

	public void RequestLinkNearbyTerminal() => LinkNearbyTerminalHost();

	public void RequestUnlinkTerminal() => UnlinkTerminalHost();

	[Rpc.Host]
	private void LinkNearbyTerminalHost()
	{
		if ( !CanManageHub( Rpc.CallerId ) )
			return;

		if ( !IsPowered )
		{
			PushAlertHost( LpBitcoinHubAlertKind.TerminalCommand,
				"Hub power is off — use the power switch before linking equipment." );
			return;
		}

		if ( Owner == 0 && !TryBindOwner( Rpc.CallerId ) )
		{
			PushAlertHost( LpBitcoinHubAlertKind.TerminalCommand,
				"Claim this hub first (secure boot / PIN), then link your terminal." );
			return;
		}

		var existing = GetLinkedTerminal();
		if ( existing.IsValid() )
		{
			PushAlertHost( LpBitcoinHubAlertKind.TerminalCommand,
				"Terminal already linked — unlink first to register another." );
			return;
		}

		var terminal = LpBitcoinTerminalEntity.FindNearestUnlinked( this );
		if ( !terminal.IsValid() )
		{
			PushAlertHost( LpBitcoinHubAlertKind.TerminalCommand,
				"No unlinked terminal in range that belongs to you — place your terminal near this hub." );
			return;
		}

		if ( !this.TryClaimLinkableEquipment( terminal, Rpc.CallerId, out var linkError ) )
		{
			PushAlertHost( LpBitcoinHubAlertKind.TerminalCommand, linkError );
			return;
		}

		LinkTerminalHost( terminal );
	}

	[Rpc.Host]
	private void UnlinkTerminalHost()
	{
		if ( !CanManageHub( Rpc.CallerId ) )
			return;

		var terminal = GetLinkedTerminal();
		if ( !terminal.IsValid() )
			return;

		terminal.UnlinkFromHub();
		PushAlertHost( LpBitcoinHubAlertKind.TerminalCommand, "Bitcoin terminal unlinked from hub." );
	}

	[Rpc.Host]
	private void LinkNearbyRackHost()
	{
		if ( !CanOperateTerminal( Rpc.CallerId ) )
			return;

		if ( !IsPowered )
		{
			PushAlertHost( LpBitcoinHubAlertKind.TerminalCommand,
				"Hub power is off — power on before linking GPU racks." );
			return;
		}

		if ( !HasLinkedTerminal() )
			return;

		if ( GetLinkedRacks().Count >= LpBitcoinIdent.PortalMaxRacksPerHub )
		{
			PushAlertHost( LpBitcoinHubAlertKind.TerminalCommand,
				$"This hub supports 2 GPU racks + 1 Advanced GPU Rack — unlink a slot first." );
			return;
		}

		if ( Owner == 0 && !TryBindOwner( Rpc.CallerId ) )
		{
			PushAlertHost( LpBitcoinHubAlertKind.TerminalCommand,
				"Claim this hub first (secure boot / PIN), then link your racks." );
			return;
		}

		var rack = LpBitcoinRackEntity.FindNearestUnlinked( this, RackLinkRange );
		if ( !rack.IsValid() )
		{
			PushAlertHost( LpBitcoinHubAlertKind.TerminalCommand,
				"No unlinked GPU rack in range that belongs to you — place your rack near this hub, then type link at rig0." );
			return;
		}

		if ( !this.TryClaimLinkableEquipment( rack, Rpc.CallerId, out var linkError ) )
		{
			PushAlertHost( LpBitcoinHubAlertKind.TerminalCommand, linkError );
			return;
		}

		if ( !LpBitcoinIdent.CanLinkRackToHub( rack, GetLinkedRacks(), out var rackSlotError ) )
		{
			PushAlertHost( LpBitcoinHubAlertKind.TerminalCommand, rackSlotError );
			return;
		}

		rack.LinkToHub( this );
		var label = LpBitcoinIdent.FormatRackSlotDisplayName( rack, GetLinkedRacks() );
		PushAlertHost( LpBitcoinHubAlertKind.TerminalCommand, $"{label} linked — type racks to confirm." );
		RefreshLinkedTerminalScreens();
	}

	[Rpc.Host]
	private void LinkRackByTokenHost( string slotToken )
	{
		if ( !CanOperateTerminal( Rpc.CallerId ) )
			return;

		if ( !IsPowered )
		{
			PushAlertHost( LpBitcoinHubAlertKind.TerminalCommand,
				"Hub power is off — power on before linking GPU racks." );
			return;
		}

		if ( !HasLinkedTerminal() )
			return;

		if ( !LpBitcoinIdent.TryParseLinkRackSlotToken( slotToken, out var advanced, out var standardSlot ) )
		{
			PushAlertHost( LpBitcoinHubAlertKind.TerminalCommand,
				"usage: link gpurack-1|gpurack-2|advancedgpurack" );
			return;
		}

		var linked = GetLinkedRacks();
		if ( !LpBitcoinIdent.CanLinkToDeclaredSlot( advanced, standardSlot, linked, out var slotError ) )
		{
			PushAlertHost( LpBitcoinHubAlertKind.TerminalCommand, slotError );
			return;
		}

		if ( GetLinkedRacks().Count >= LpBitcoinIdent.PortalMaxRacksPerHub )
		{
			PushAlertHost( LpBitcoinHubAlertKind.TerminalCommand,
				"This hub supports 2 GPU racks + 1 Advanced GPU Rack — unlink a slot first." );
			return;
		}

		if ( Owner == 0 && !TryBindOwner( Rpc.CallerId ) )
		{
			PushAlertHost( LpBitcoinHubAlertKind.TerminalCommand,
				"Claim this hub first (secure boot / PIN), then link your racks." );
			return;
		}

		var rack = LpBitcoinRackEntity.FindNearestUnlinked( this, RackLinkRange, advancedOnly: advanced );
		if ( !rack.IsValid() )
		{
			var kind = advanced ? "Advanced GPU" : "GPU";
			PushAlertHost( LpBitcoinHubAlertKind.TerminalCommand,
				$"No unlinked {kind} rack in range that belongs to you — place your rack near this hub." );
			return;
		}

		if ( advanced != rack.AdvancedRack )
		{
			var expected = advanced ? "advancedgpurack" : $"gpurack-{standardSlot}";
			PushAlertHost( LpBitcoinHubAlertKind.TerminalCommand,
				$"ERR nearest rack in range is not {expected} — move the correct rack closer or unlink a mismatch." );
			return;
		}

		if ( !this.TryClaimLinkableEquipment( rack, Rpc.CallerId, out var linkError ) )
		{
			PushAlertHost( LpBitcoinHubAlertKind.TerminalCommand, linkError );
			return;
		}

		if ( !LpBitcoinIdent.CanLinkRackToHub( rack, linked, out var rackSlotError ) )
		{
			PushAlertHost( LpBitcoinHubAlertKind.TerminalCommand, rackSlotError );
			return;
		}

		rack.LinkToHub( this );
		var declared = LpBitcoinIdent.FormatDeclaredLinkSlotToken( advanced, standardSlot );
		var label = LpBitcoinIdent.FormatRackSlotDisplayName( rack, GetLinkedRacks() );
		PushAlertHost( LpBitcoinHubAlertKind.TerminalCommand, $"{label} linked as {declared} — type racks to confirm." );
		RefreshLinkedTerminalScreens();
	}

	internal void LinkTerminalHost( LpBitcoinTerminalEntity terminal )
	{
		if ( !Networking.IsHost || !terminal.IsValid() )
			return;

		if ( !IsPowered )
		{
			PushAlertHost( LpBitcoinHubAlertKind.TerminalCommand,
				"Hub power is off — turn the hub on before linking the terminal." );
			return;
		}

		if ( terminal.LinkedHubId != Guid.Empty && terminal.LinkedHubId != GameObject.Id )
			return;

		if ( !terminal.IsWithinLinkRange( this ) )
		{
			PushAlertHost( LpBitcoinHubAlertKind.TerminalCommand,
				"Terminal out of link range — move it closer to the hub." );
			return;
		}

#if !LIFEPUNCH_LOCAL
		if ( Owner != 0 && !LifePunchEntityOwnership.SharesOperator( Owner, terminal.Owner ) )
		{
			PushAlertHost( LpBitcoinHubAlertKind.TerminalCommand,
				"That terminal belongs to another operator — only your terminal can link here." );
			return;
		}
#endif

		terminal.LinkToHub( this );
		PushAlertHost( LpBitcoinHubAlertKind.TerminalCommand, "Bitcoin terminal linked — rig0 ops enabled." );
		RefreshLinkedTerminalScreens();
	}

	public float GetRackPendingBtc() => GetLinkedRacks().Sum( r => r.BitcoinAmount );

	public IReadOnlyList<LpBitcoinHubAlert> GetAlerts()
		=> LpBitcoinHubAlertCodec.Deserialize( AlertFeed );

	public int GetRackIndex( LpBitcoinRackEntity rack )
	{
		if ( !rack.IsValid() )
			return -1;

		var racks = GetLinkedRacks();
		for ( var i = 0; i < racks.Count; i++ )
		{
			if ( racks[i].GameObject.Id == rack.GameObject.Id )
				return i;
		}

		return -1;
	}

	public void RequestMarkAlertsRead() => MarkAlertsReadHost();

	public void RequestClearAlerts() => ClearAlertsHost();

	/// <summary>Dev only — seed varied sample alerts so the Hub logs page can be verified in flatgrass.</summary>
	internal void DevSeedSampleAlerts()
	{
		if ( !Networking.IsHost )
			return;

		PushAlertHost( LpBitcoinHubAlertKind.TerminalCommand, "rig0> link gpurack-01 — registered" );
		PushAlertHost( LpBitcoinHubAlertKind.HubTransfer, "Swept 0.004210 BTC from gpurack-01 to hub wallet" );
		PushAlertHost( LpBitcoinHubAlertKind.RackCapacity, "gpurack-02 at capacity (0.010000 / 0.010000 BTC) — deposit at terminal" );
		PushAlertHost( LpBitcoinHubAlertKind.HackAttack, "HASHD intrusion attempt — unknown operator" );
		PushAlertHost( LpBitcoinHubAlertKind.TerminalCommand, "rig0> racks — 2 linked, 1 mining" );
		PushAlertHost( LpBitcoinHubAlertKind.HubTransfer, "Cashed out 0.025000 BTC at terminal" );
	}

	public void RequestPushTerminalCommandAlert( string command, string result )
		=> PushTerminalCommandAlertHost( command, result );

	public void ReportHackAttempt( string attackerLabel ) => ReportHackAttemptHostRpc( attackerLabel );

	[Rpc.Host]
	private void ReportHackAttemptHostRpc( string attackerLabel )
	{
		var label = LpBitcoinHubAlertCodec.Sanitize( attackerLabel );
		if ( string.IsNullOrWhiteSpace( label ) )
			label = "unknown operator";

		PushHackAttackAlertHost( $"HASHD intrusion attempt — {label}" );
	}

	internal void PushRackCapacityAlertHost( int rackIndex, float amount, float capacity )
	{
		var racks = GetLinkedRacks();
		var rack = FindRackByIndex( rackIndex );
		var label = rack.IsValid() ? LpBitcoinIdent.FormatRackSlotTerminalToken( rack, racks ) : "gpurack";
		PushAlertHost(
			LpBitcoinHubAlertKind.RackCapacity,
			$"{label} at capacity ({amount:F6} / {capacity:F6} BTC) — deposit at terminal" );
	}

	[Rpc.Host]
	private void MarkAlertsReadHost()
	{
		if ( !CanManageHub( Rpc.CallerId ) )
			return;

		UnreadAlertCount = 0;
	}

	[Rpc.Host]
	private void ClearAlertsHost()
	{
		if ( !CanManageHub( Rpc.CallerId ) )
			return;

		AlertFeed = string.Empty;
		UnreadAlertCount = 0;
	}

	[Rpc.Host]
	private void PushTerminalCommandAlertHost( string command, string result )
	{
		if ( !CanOperateTerminal( Rpc.CallerId ) )
			return;

		var cmd = LpBitcoinHubAlertCodec.Sanitize( command );
		if ( string.IsNullOrWhiteSpace( cmd ) )
			return;

		var line = LpBitcoinHubAlertCodec.Sanitize( result );
		var message = string.IsNullOrWhiteSpace( line ) ? cmd : $"{cmd} → {line}";
		PushAlertHost( LpBitcoinHubAlertKind.TerminalCommand, message );
	}

	internal void PushHackAttackAlertHost( string detail )
	{
		var message = LpBitcoinHubAlertCodec.Sanitize( detail );
		if ( string.IsNullOrWhiteSpace( message ) )
			message = "Intrusion attempt detected on HASHD hub";

		PushAlertHost( LpBitcoinHubAlertKind.HackAttack, message );
	}

	internal void PushAlertHost( LpBitcoinHubAlertKind kind, string message )
	{
		if ( !Networking.IsHost )
			return;

		message = LpBitcoinHubAlertCodec.Sanitize( message );
		if ( string.IsNullOrWhiteSpace( message ) )
			return;

		var alerts = GetAlerts().ToList();
		alerts.Insert( 0, new LpBitcoinHubAlert
		{
			Kind = kind,
			Message = message,
			Timestamp = Time.Now,
		} );

		while ( alerts.Count > 20 )
			alerts.RemoveAt( alerts.Count - 1 );

		AlertFeed = LpBitcoinHubAlertCodec.Serialize( alerts );
		UnreadAlertCount = Math.Min( UnreadAlertCount + 1, 99 );
	}

	[Rpc.Host]
	private void SetAccessPinHost( string pin, string confirm )
	{
		if ( AccessPinIsSet )
		{
			SendPinResultToCaller( false, "PIN already configured." );
			return;
		}

		if ( !LpBitcoinHubPin.IsValidFormat( pin ) || pin != confirm )
		{
			SendPinResultToCaller( false, "PIN must be 4 digits and match confirmation." );
			return;
		}

		if ( Owner == 0 && !TryBindOwner( Rpc.CallerId ) )
		{
			SendPinResultToCaller( false, "Could not claim hub ownership." );
			return;
		}

		if ( Owner != 0 && !CallerIsOwner( Rpc.CallerId ) )
		{
			SendPinResultToCaller( false, "Only the hub owner can set the PIN." );
			return;
		}

		AccessPinHash = LpBitcoinHubPin.Hash( pin );
		AccessPinIsSet = true;
		SendPinResultToCaller( true, "Secure boot enabled." );
	}

	[Rpc.Host]
	private void UnlockAccessPinHost( string pin )
	{
		if ( !AccessPinIsSet )
		{
			SendPinResultToCaller( true, string.Empty );
			return;
		}

		if ( !CallerIsOwner( Rpc.CallerId ) )
		{
			SendPinResultToCaller( false, "Access denied — hub belongs to another operator." );
			return;
		}

		if ( !LpBitcoinHubPin.Matches( pin, AccessPinHash ) )
		{
			SendPinResultToCaller( false, "Incorrect PIN." );
			return;
		}

		SendPinResultToCaller( true, string.Empty );
	}

	/// <summary>Terminal (rig0>) uses the exact same PIN secret as the hub admin panel.</summary>
	public void RequestTerminalUnlock( string pin ) => RequestTerminalUnlockHost( pin );

	[Rpc.Host]
	private void RequestTerminalUnlockHost( string pin )
	{
		if ( !AccessPinIsSet )
		{
			SendTerminalUnlockResultToCaller( true );
			return;
		}

		if ( !LpBitcoinHubPin.Matches( pin, AccessPinHash ) )
		{
			SendTerminalUnlockResultToCaller( false );
			return;
		}

		SendTerminalUnlockResultToCaller( true );
	}

	private void SendTerminalUnlockResultToCaller( bool ok )
		=> NotifyTerminalUnlockResult( Rpc.CallerId, ok );

	[Rpc.Broadcast]
	private void NotifyTerminalUnlockResult( Guid callerId, bool ok )
	{
		if ( Connection.Local.Id != callerId )
			return;

		var terminalPanel = Game.ActiveScene?.GetAllComponents<LpBitcoinTerminalPanel>()
			.FirstOrDefault( p => p.IsValid() && p.Hub == this )
			?? Game.ActiveScene?.GetAllComponents<LpBitcoinTerminalPanel>().FirstOrDefault( p => p.IsValid() );

		if ( terminalPanel.IsValid() )
			terminalPanel.OnTerminalPinResult( ok );
	}

	[Rpc.Host]
	private void ChangeAccessPinHost( string currentPin, string newPin, string confirm )
	{
		if ( !AccessPinIsSet )
		{
			SendPinChangeResultToCaller( false, "Hub PIN is not configured yet." );
			return;
		}

		if ( !CallerIsOwner( Rpc.CallerId ) )
		{
			SendPinChangeResultToCaller( false, "Only the hub owner can change the PIN." );
			return;
		}

		if ( !LpBitcoinHubPin.Matches( currentPin, AccessPinHash ) )
		{
			SendPinChangeResultToCaller( false, "Current PIN is incorrect." );
			return;
		}

		if ( !LpBitcoinHubPin.IsValidFormat( newPin ) || newPin != confirm )
		{
			SendPinChangeResultToCaller( false, "New PIN must be 4 digits and match confirmation." );
			return;
		}

		if ( currentPin == newPin )
		{
			SendPinChangeResultToCaller( false, "New PIN must differ from the current PIN." );
			return;
		}

		AccessPinHash = LpBitcoinHubPin.Hash( newPin );
		SendPinChangeResultToCaller( true, "Hub PIN updated." );
	}

	[Rpc.Host]
	private void DepositRackHost( int index )
	{
		if ( !CanManageHub( Rpc.CallerId ) )
			return;

		if ( !HasLinkedTerminal() )
			return;

		var rack = FindRackByIndex( index );
		if ( rack is null || rack.BitcoinAmount <= 0f )
			return;

		HubWalletBtc += rack.BitcoinAmount;
		rack.ClearBalanceHost();
		RefreshLinkedTerminalScreens();
	}

	[Rpc.Host]
	private void DepositRacksToHubHost()
	{
		if ( !CanManageHub( Rpc.CallerId ) )
			return;

		if ( !HasLinkedTerminal() )
			return;

		foreach ( var rack in GetLinkedRacks() )
		{
			if ( rack.BitcoinAmount <= 0f )
				continue;

			HubWalletBtc += rack.BitcoinAmount;
			rack.ClearBalanceHost();
		}

		RefreshLinkedTerminalScreens();
	}

	[Rpc.Host]
	private async void CashOutHubHost( float amount, bool soldAll )
	{
		if ( !CanManageHub( Rpc.CallerId ) )
			return;

		if ( amount <= 0f || amount > HubWalletBtc )
			return;

		var payout = LpBitcoinEconomy.BtcToCashPayout( amount );
		if ( payout == 0 )
			return;

		if ( !await LpBitcoinWallet.TryPayBank( Rpc.CallerId, payout, "LIFEPUNCH hub BTC cashout" ) )
			return;

		HubWalletBtc -= amount;
		NotifyCashOutSuccess( Rpc.CallerId, amount, payout, soldAll );
		RefreshLinkedTerminalScreens();
	}

	[Rpc.Host]
	private void SendHubWalletHost( long targetSteamId, float amount )
	{
		if ( !CanOperateTerminal( Rpc.CallerId ) )
			return;

		if ( !HasLinkedTerminal() )
			return;

		if ( targetSteamId <= 0 || amount <= 0f || amount > HubWalletBtc )
			return;

		if ( Owner != 0 && Owner == targetSteamId )
			return;

		var target = FindHubByOwnerSteamId( targetSteamId, exclude: this );
		if ( target is null || !target.IsValid() )
			return;

		HubWalletBtc -= amount;
		target.HubWalletBtc += amount;

		var recipientLabel = LifePunchEntityOwnership.GetOwnerLabel( targetSteamId );
		if ( string.IsNullOrWhiteSpace( recipientLabel ) )
			recipientLabel = targetSteamId.ToString();

		var senderLabel = LifePunchEntityOwnership.GetOwnerLabel( Owner );
		if ( string.IsNullOrWhiteSpace( senderLabel ) )
			senderLabel = Owner == 0 ? "unknown operator" : Owner.ToString();

		PushAlertHost( LpBitcoinHubAlertKind.HubTransfer,
			$"Sent {amount:F6} BTC to hub {recipientLabel}" );
		target.PushAlertHost( LpBitcoinHubAlertKind.HubTransfer,
			$"Received {amount:F6} BTC from hub {senderLabel}" );

		RefreshLinkedTerminalScreens();
		target.RefreshLinkedTerminalScreens();
	}

	[Rpc.Broadcast]
	private void NotifyCashOutSuccess( Guid callerId, float btcAmount, uint usdPayout, bool soldAll )
	{
		if ( Connection.Local.Id != callerId )
			return;

		var panel = Game.ActiveScene?.GetAllComponents<LpHashdPanel>().FirstOrDefault();
		if ( panel.IsValid() )
			panel.OnCashOutSuccess( btcAmount, usdPayout, soldAll );
	}

	private void SendPinResultToCaller( bool ok, string message )
		=> NotifyPinResult( Rpc.CallerId, ok, message );

	[Rpc.Broadcast]
	private void NotifyPinResult( Guid callerId, bool ok, string message )
	{
		if ( Connection.Local.Id != callerId )
			return;

		var panel = FindHashdPanelForCaller();
		if ( panel.IsValid() )
			panel.OnPinGateResult( ok, message );
	}

	private void SendPinChangeResultToCaller( bool ok, string message )
		=> NotifyPinChangeResult( Rpc.CallerId, ok, message );

	[Rpc.Broadcast]
	private void NotifyPinChangeResult( Guid callerId, bool ok, string message )
	{
		if ( Connection.Local.Id != callerId )
			return;

		var panel = FindHashdPanelForCaller();
		if ( panel.IsValid() )
			panel.OnPinChangeResult( ok, message );
	}

	private LpHashdPanel FindHashdPanelForCaller()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
			return null;

		return scene.GetAllComponents<LpHashdPanel>()
			.FirstOrDefault( p => p.IsValid() && p.Hub == this )
			?? scene.GetAllComponents<LpHashdPanel>().FirstOrDefault( p => p.IsValid() );
	}

	[Rpc.Host]
	private void UpgradeCpuHost( Guid rackId )
	{
		if ( !CanManageHub( Rpc.CallerId ) )
			return;

		ResolveRack( rackId )?.ApplyUpgradeCpu( Rpc.CallerId );
	}

	[Rpc.Host]
	private void UpgradeCoresHost( Guid rackId )
	{
		if ( !CanManageHub( Rpc.CallerId ) )
			return;

		ResolveRack( rackId )?.ApplyUpgradeCores( Rpc.CallerId );
	}

	private LpBitcoinRackEntity ResolveRack( Guid rackId )
	{
		if ( rackId == Guid.Empty )
			return GetLinkedRacks().FirstOrDefault();

		return GetLinkedRacks().FirstOrDefault( r => r.GameObject.Id == rackId );
	}

	public bool CanManageHub( Guid callerId )
	{
#if LIFEPUNCH_LOCAL
		return true;
#else
		if ( !AccessPinIsSet )
			return CallerIsOwner( callerId ) || Owner == 0;

		return CallerIsOwner( callerId );
#endif
	}

	public bool CanOperateTerminal( Guid callerId )
	{
		if ( !IsPowered )
			return false;

		return CanManageHub( callerId );
	}

	public void BindOwnerFromLocalViewer()
	{
#if LIFEPUNCH_LOCAL
		if ( Owner != 0 )
			return;
		Owner = 1;
#else
		LifePunchEntityOwnership.BindOwnerFromLocalViewer( this );
#endif
	}

	/// <summary>Market spawn baseline — OFF until operator sets PIN and powers on at hub admin.</summary>
	private void ApplyVirginSpawnDefaultsHost()
	{
		if ( AccessPinIsSet || HubWalletBtc > 0f )
			return;

		IsPowered = false;
	}

	private bool CallerIsOwner( Guid callerId )
	{
#if LIFEPUNCH_LOCAL
		return true;
#else
		return LifePunchEntityOwnership.CallerIsOwner( Owner, callerId );
#endif
	}

	private bool TryBindOwner( Guid callerId )
	{
#if LIFEPUNCH_LOCAL
		Owner = 1;
		return true;
#else
		return this.TryBindOwnerFromCaller( callerId );
#endif
	}

#if !LIFEPUNCH_LOCAL
	private bool TryClaimLinkableEquipment( BaseEntity equipment, Guid callerId, out string error )
	{
		error = string.Empty;
		if ( !equipment.IsValid() )
		{
			error = "Equipment missing — re-place and try again.";
			return false;
		}

		if ( LifePunchEntityOwnership.SharesOperator( Owner, equipment.Owner ) )
			return true;

		if ( equipment.Owner != 0 )
		{
			error = "That equipment belongs to another operator — only your gear can link to this hub.";
			return false;
		}

		if ( !LifePunchEntityOwnership.TryClaimEquipmentForHub( equipment, Owner, callerId ) )
		{
			error = "Could not claim equipment ownership — only gear you placed can link here.";
			return false;
		}

		return true;
	}
#else
	private bool TryClaimLinkableEquipment( Component equipment, Guid callerId, out string error )
	{
		error = string.Empty;
		return equipment.IsValid();
	}
#endif

	private void ApplyHubPowerVisual( bool powered )
	{
		_lastPoweredVisual = powered;

		var visuals = Components.Get<LpBitcoinHubVisuals>( FindMode.EverythingInSelf );
		if ( !visuals.IsValid() || !visuals.Enabled )
			return;

		if ( !_modelRenderer.IsValid() )
			_modelRenderer = Components.Get<ModelRenderer>( FindMode.EverythingInSelf )
			                 ?? Components.Get<SkinnedModelRenderer>( FindMode.EverythingInSelf ) as ModelRenderer;

		visuals.ApplyPowerVisuals( powered );
	}
}
