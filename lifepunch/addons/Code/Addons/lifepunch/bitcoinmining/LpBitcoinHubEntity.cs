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
	[Sync( SyncFlags.FromHost )] public bool AccessPinIsSet { get; set; } = true;
	[Sync( SyncFlags.FromHost )] public long Owner { get; set; }

	public bool Press( IPressable.Event e )
	{
		LpHashdUiHost.Open( this );
		return true;
	}

	public void Hover( IPressable.Event e ) { }
	public void Blur( IPressable.Event e ) { }

	public void SetPowered( bool on ) => SetPoweredHost( on );

	[Rpc.Host]
	private void SetPoweredHost( bool on )
	{
		if ( !CanManageHub( Rpc.CallerId ) )
			return;

		IsPowered = on;
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
			return TryBindOwner( callerId );

		if ( Owner == 0 )
			return TryBindOwner( callerId );

		var player = GameUtils.GetPlayerByConnectionId( callerId );
		return player.IsValid() && player.SteamId == Owner;
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
	private bool TryBindOwner( Guid callerId )
	{
		var player = GameUtils.GetPlayerByConnectionId( callerId );
		if ( !player.IsValid() )
			return false;

		Owner = player.SteamId;
		return true;
	}
#endif
}
