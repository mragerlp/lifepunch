// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// ─────────────────────────────────────────────────────────────────────────────

using System;
using System.Collections.Generic;
using System.Linq;
using Sandbox;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
#endif

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>Hub — PIN, power, linking, upgrades (purchased here). No mine/sell on hub UI.</summary>
[Title( "LIFEPUNCH Bitcoin Hub (v2)" )]
[Category( "LifePunch/Bitcoin" )]
#if LIFEPUNCH_LOCAL
public sealed class LpBitcoinHubEntity : Component, Component.IPressable
#else
public sealed class LpBitcoinHubEntity : BaseEntity, Component.IPressable
#endif
{
	[Sync( SyncFlags.FromHost )] public bool IsPowered { get; set; } = true;
	[Sync( SyncFlags.FromHost )] public bool AccessPinIsSet { get; set; }
	[Sync( SyncFlags.FromHost )] public int AccessPinHash { get; set; }
	[Sync( SyncFlags.FromHost )] public long Owner { get; set; }

	private ModelRenderer _modelRenderer;
	private bool _lastPoweredVisual = true;

	protected override void OnStart()
	{
		_modelRenderer = Components.Get<ModelRenderer>( FindMode.EverythingInSelf );
		ApplyHubPowerVisual( IsPowered );
	}

	protected override void OnUpdate()
	{
		if ( IsPowered == _lastPoweredVisual )
			return;

		ApplyHubPowerVisual( IsPowered );
	}

	public bool Press( IPressable.Event e )
	{
		LpHashdUiHost.Open( this );
		return true;
	}

	public void Hover( IPressable.Event e ) { }
	public void Blur( IPressable.Event e ) { }

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
	}

	public IReadOnlyList<LpBitcoinRackEntity> GetLinkedRacks()
	{
		var scene = GameObject.Scene ?? Game.ActiveScene;
		if ( scene is null )
			return Array.Empty<LpBitcoinRackEntity>();

		return scene.GetAllComponents<LpBitcoinRackEntity>()
			.Where( r => r.IsValid() && r.LinkedHubId == GameObject.Id )
			.ToList();
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

	public void RequestSellAllRacks() => SellAllRacksHost();

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
			SendPinResultToCaller( false, "PIN must be 4–6 digits and match confirmation." );
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

	[Rpc.Host]
	private async void SellAllRacksHost()
	{
		if ( !CanManageHub( Rpc.CallerId ) )
			return;

		foreach ( var rack in GetLinkedRacks() )
		{
			if ( rack.BitcoinAmount <= 0f )
				continue;

			await rack.SellForCallerHost( Rpc.CallerId );
		}
	}

	[Rpc.Owner]
	private void SendPinResultToCaller( bool ok, string message )
	{
		var panel = Game.ActiveScene?.GetAllComponents<LpHashdPanel>().FirstOrDefault();
		if ( panel.IsValid() )
			panel.OnPinGateResult( ok, message );
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
#if !LIFEPUNCH_LOCAL
		if ( !Networking.IsHost || Owner != 0 )
			return;

		if ( Player.Local.IsValid() )
			Owner = Player.Local.SteamId;
#else
		Owner = 1;
#endif
	}

#if !LIFEPUNCH_LOCAL
	private bool CallerIsOwner( Guid callerId )
	{
		var player = GameUtils.GetPlayerByConnectionId( callerId );
		if ( !player.IsValid() )
			return Networking.IsHost;

		return Owner == 0 || player.SteamId == Owner;
	}

	private bool TryBindOwner( Guid callerId )
	{
		var player = GameUtils.GetPlayerByConnectionId( callerId );
		if ( !player.IsValid() )
			return false;

		Owner = player.SteamId;
		return true;
	}
#endif

	private void ApplyHubPowerVisual( bool powered )
	{
		_lastPoweredVisual = powered;

		if ( !_modelRenderer.IsValid() )
			_modelRenderer = Components.Get<ModelRenderer>( FindMode.EverythingInSelf );

		if ( !_modelRenderer.IsValid() )
			return;

		LpBitcoinPowerAnim.ApplyHubPower( _modelRenderer, powered, out _ );
	}
}
