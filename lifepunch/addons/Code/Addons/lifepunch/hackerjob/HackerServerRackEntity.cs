// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Hacker Job" (s&box ident: lifepunch.hackerjob · addon ident: hackerjob) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System;
using System.Collections.Generic;
using Sandbox;
using LifePunch.DXRP.Addons;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
#endif

namespace LifePunch.DXRP.Addons.HackerJob;

/// <summary>
/// Server rack — powers linked hacker terminals and hosts upgrade state for the job line.
/// </summary>
[Title( "Hacker Server Rack" )]
[Category( "LifePunch/Hacker Job" )]
#if LIFEPUNCH_LOCAL
public class HackerServerRackEntity : Component, Component.IPressable
#else
public class HackerServerRackEntity : BaseEntity, Component.IPressable
#endif
{
	[Property] public HackerRackTier RackTier { get; set; } = HackerRackTier.Basic;
	[Property] public bool IsPowered { get; set; }
	[Property] public int DetectionTier { get; set; }
	[Property] public int PuzzleTimeTier { get; set; }
	[Property] public int RewardTier { get; set; }
	[Property] public int CooldownTier { get; set; }

	/// <summary>True when a 4-digit operator PIN is configured (hash stays host-only).</summary>
	[Sync( SyncFlags.FromHost )] public bool AccessPinIsSet { get; set; }
	/// <summary>Display label for the operator who configured the rack PIN.</summary>
	[Sync( SyncFlags.FromHost )] public string OperatorDisplayName { get; set; } = "";

	private ushort _pinHash;
	private readonly Dictionary<Guid, double> _sessionExpiry = new();

	public float PuzzleTimeLimitSeconds => HackerUpgradeCatalog.GetPuzzleTimeLimitSeconds( PuzzleTimeTier );
	public float RewardMultiplier => HackerUpgradeCatalog.GetRewardMultiplier( RewardTier );
	public float HackCooldownSeconds => HackerUpgradeCatalog.GetHackCooldownSeconds( CooldownTier );

	protected override void OnStart()
	{
		base.OnStart();
		TryBindSpawnOwnerHost();
	}

	private void TryBindSpawnOwnerHost()
	{
#if !LIFEPUNCH_LOCAL
		if ( !Networking.IsHost || Owner != 0 )
			return;

		var networkOwner = GameObject.Network.Owner;
		if ( networkOwner == null )
			return;

		var player = GameUtils.GetPlayerByConnectionId( networkOwner.Id );
		if ( player.IsValid() )
			Owner = player.SteamId;
#endif
	}

	public bool CanPress( IPressable.Event e ) => LifePunchMenuInteractGate.CanPressMenu( GameObject );

	public bool Press( IPressable.Event e )
	{
		RequestOpenMenu();
		return true;
	}

	public void RequestOpenMenu() => OpenMenuHost();

	[Rpc.Host]
	private void OpenMenuHost()
	{
		TryBindSpawnOwnerHost();

#if !LIFEPUNCH_LOCAL
		if ( !LifePunchMenuInteractGate.IsCallerAllowed( Rpc.Caller, GameObject ) )
			return;
#else
		if ( !LifePunchMenuInteractGate.IsCallerAllowed( null, GameObject ) )
			return;
#endif

#if LIFEPUNCH_LOCAL
		if ( !AccessPinIsSet )
		{
			OpenPinSetup( Rpc.CallerId );
			return;
		}

		if ( !IsAccessAuthorized( Rpc.CallerId ) )
		{
			OpenPinUnlock( Rpc.CallerId );
			return;
		}

		OpenMenu( Rpc.CallerId );
		return;
#endif

		if ( !AccessPinIsSet )
		{
			if ( IsRackOwner( Rpc.CallerId ) )
				OpenPinSetup( Rpc.CallerId );
			else
				OpenPinBlocked( Rpc.CallerId );

			return;
		}

		if ( !IsAccessAuthorized( Rpc.CallerId ) )
		{
			OpenPinUnlock( Rpc.CallerId );
			return;
		}

		OpenMenu( Rpc.CallerId );
	}

	[Rpc.Broadcast]
	private void OpenMenu( Guid callerId )
	{
		if ( Connection.Local.Id != callerId )
			return;

		HackerServerRackMenu.Open( this );
	}

	[Rpc.Broadcast]
	private void OpenPinSetup( Guid callerId )
	{
		if ( Connection.Local.Id != callerId )
			return;

		HackerServerRackMenu.OpenPinSetup( this );
	}

	[Rpc.Broadcast]
	private void OpenPinUnlock( Guid callerId )
	{
		if ( Connection.Local.Id != callerId )
			return;

		HackerServerRackMenu.OpenPinUnlock( this );
	}

	[Rpc.Broadcast]
	private void OpenPinBlocked( Guid callerId )
	{
		if ( Connection.Local.Id != callerId )
			return;

		HackerServerRackMenu.OpenPinBlocked( this );
	}

	public void RequestSetAccessPin( string pin, string confirm ) => SetAccessPinHost( pin, confirm );

	[Rpc.Host]
	private void SetAccessPinHost( string pin, string confirm )
	{
		if ( !IsCallerInReach() )
			return;

		if ( !IsRackOwner( Rpc.CallerId ) )
		{
			DenyPinUnlock( Rpc.CallerId, "Only the rack owner can set the initial PIN." );
			return;
		}

		if ( AccessPinIsSet )
		{
			DenyPinUnlock( Rpc.CallerId, "PIN already set — contact the operator to change it." );
			return;
		}

		if ( !HackerServerRackAccessPin.IsValidFormat( pin ) || pin != confirm )
		{
			DenyPinUnlock( Rpc.CallerId, "PIN must be four digits." );
			return;
		}

		_pinHash = HackerServerRackAccessPin.Hash( pin, GameObject.Id );
		AccessPinIsSet = true;
		OperatorDisplayName = ResolveOperatorLabel( Rpc.CallerId );
		AuthorizeSession( Rpc.CallerId );
		OpenMenu( Rpc.CallerId );
	}

	public void RequestUnlockAccessPin( string pin ) => UnlockAccessPinHost( pin );

	[Rpc.Host]
	private void UnlockAccessPinHost( string pin )
	{
		if ( !IsCallerInReach() )
			return;

		if ( !AccessPinIsSet )
		{
			if ( IsRackOwner( Rpc.CallerId ) )
				OpenPinSetup( Rpc.CallerId );
			else
				OpenPinBlocked( Rpc.CallerId );

			return;
		}

		if ( !HackerServerRackAccessPin.IsValidFormat( pin ) )
		{
			DenyPinUnlock( Rpc.CallerId, "Enter a 4-digit PIN." );
			return;
		}

		if ( HackerServerRackAccessPin.Hash( pin, GameObject.Id ) != _pinHash )
		{
			DenyPinUnlock( Rpc.CallerId, "Invalid PIN." );
			return;
		}

		AuthorizeSession( Rpc.CallerId );
		OpenMenu( Rpc.CallerId );
	}

	public void RequestEndAccessSession() => EndAccessSessionHost();

	[Rpc.Host]
	private void EndAccessSessionHost()
	{
		_sessionExpiry.Remove( Rpc.CallerId );
	}

	[Rpc.Broadcast]
	private void DenyPinUnlock( Guid callerId, string message )
	{
		if ( Connection.Local.Id != callerId )
			return;

		HackerServerRackMenu.NotifyPinDenied( message );
	}

	public bool IsAccessAuthorized( Guid callerId )
	{
		if ( !AccessPinIsSet )
			return false;

		return _sessionExpiry.TryGetValue( callerId, out var expiry ) && Time.Now < expiry;
	}

	public bool RequiresPinSession( Guid callerId ) => AccessPinIsSet && !IsAccessAuthorized( callerId );

	private bool IsRackOwner( Guid callerId )
	{
#if LIFEPUNCH_LOCAL
		return true;
#else
		if ( Owner == 0 )
			return false;

		var player = GameUtils.GetPlayerByConnectionId( callerId );
		return player.IsValid() && player.SteamId == Owner;
#endif
	}

	private bool IsCallerInReach()
	{
#if LIFEPUNCH_LOCAL
		return LifePunchMenuInteractGate.IsCallerAllowed( null, GameObject );
#else
		return LifePunchMenuInteractGate.IsCallerAllowed( Rpc.Caller, GameObject );
#endif
	}

	private void AuthorizeSession( Guid callerId )
	{
		_sessionExpiry[callerId] = Time.Now + HackerServerRackAccessPin.SessionSeconds;
	}

	private static string ResolveOperatorLabel( Guid callerId )
	{
#if LIFEPUNCH_LOCAL
		return "LOCAL OPERATOR";
#else
		var player = GameUtils.GetPlayerByConnectionId( callerId );
		if ( !player.IsValid() )
			return "UNKNOWN";

		return string.IsNullOrWhiteSpace( player.DisplayName ) ? player.SteamId.ToString() : player.DisplayName;
#endif
	}

	public void RequestSetPowered( bool powered ) => SetPoweredHost( powered );

	[Rpc.Host]
	private void SetPoweredHost( bool powered )
	{
#if !LIFEPUNCH_LOCAL
		if ( !GameUtils.HasPermission( Rpc.Caller, GameObject ) )
			return;
#endif
		if ( RequiresPinSession( Rpc.CallerId ) )
			return;

		IsPowered = powered;
		RefreshLinkedTerminalScreens();
	}

	private void RefreshLinkedTerminalScreens()
	{
		foreach ( var terminal in HackerServerRackRegistry.GetLinkedTerminals( this ) )
			terminal?.RefreshScreenIdle();
	}

	public void RequestUpgrade( HackerUpgradeKind kind ) => UpgradeHost( kind );

	public void RequestLinkTerminal( int scanIndex ) => LinkTerminalHost( scanIndex );

	public void RequestUnlinkTerminal( int linkIndex ) => UnlinkTerminalHost( linkIndex );

	public void RequestUnlinkAllTerminals() => UnlinkAllTerminalsHost();

	[Rpc.Host]
	private void LinkTerminalHost( int scanIndex )
	{
#if !LIFEPUNCH_LOCAL
		if ( !GameUtils.HasPermission( Rpc.Caller, GameObject ) )
			return;
#endif
		if ( RequiresPinSession( Rpc.CallerId ) )
			return;

		var candidates = HackerServerRackRegistry.ScanUnlinkedTerminals( this );
		if ( scanIndex < 0 || scanIndex >= candidates.Count )
		{
			NotifyLinkMessage( Rpc.CallerId, $"ERROR: invalid link index — {candidates.Count} available." );
			return;
		}

		if ( !HackerServerRackRegistry.TryLinkTerminal( this, candidates[scanIndex], out var error ) )
		{
			NotifyLinkMessage( Rpc.CallerId, $"ERROR: {error}" );
			return;
		}

		NotifyLinkMessage( Rpc.CallerId, $"LINKED: {HackerServerRackRegistry.GetTerminalLabel( candidates[scanIndex] )}." );
		RefreshLinkedTerminalScreens();
	}

	[Rpc.Host]
	private void UnlinkTerminalHost( int linkIndex )
	{
#if !LIFEPUNCH_LOCAL
		if ( !GameUtils.HasPermission( Rpc.Caller, GameObject ) )
			return;
#endif
		if ( RequiresPinSession( Rpc.CallerId ) )
			return;

		if ( !HackerServerRackRegistry.TryUnlinkTerminalAt( this, linkIndex, out var error ) )
		{
			NotifyLinkMessage( Rpc.CallerId, $"ERROR: {error}" );
			return;
		}

		NotifyLinkMessage( Rpc.CallerId, "UNLINKED: terminal removed from rack." );
		RefreshLinkedTerminalScreens();
	}

	[Rpc.Host]
	private void UnlinkAllTerminalsHost()
	{
#if !LIFEPUNCH_LOCAL
		if ( !GameUtils.HasPermission( Rpc.Caller, GameObject ) )
			return;
#endif
		if ( RequiresPinSession( Rpc.CallerId ) )
			return;

		HackerServerRackRegistry.UnlinkAllFromRack( this );
		NotifyLinkMessage( Rpc.CallerId, "UNLINKED: all terminals cleared." );
		RefreshLinkedTerminalScreens();
	}

	[Rpc.Broadcast]
	private void NotifyLinkMessage( Guid callerId, string message )
	{
		if ( Connection.Local.Id != callerId )
			return;

		HackerServerRackMenu.NotifyLinkMessage( message );
	}

	[Rpc.Host]
	private void UpgradeHost( HackerUpgradeKind kind )
	{
#if !LIFEPUNCH_LOCAL
		if ( !GameUtils.HasPermission( Rpc.Caller, GameObject ) )
			return;
#endif
		if ( RequiresPinSession( Rpc.CallerId ) )
			return;

		var current = GetTier( kind );
		var max = GetMaxTierForRack( kind );
		if ( current >= max )
			return;

		var cost = HackerUpgradeCatalog.GetUpgradeCost( kind, current + 1 );
#if LIFEPUNCH_LOCAL
		SetTier( kind, current + 1 );
#else
		var player = GameUtils.GetPlayerByConnectionId( Rpc.CallerId );
		if ( !player.IsValid() || player.WalletBalance < cost )
			return;

		SetTier( kind, current + 1 );
#endif
	}

	public int GetTier( HackerUpgradeKind kind ) => kind switch
	{
		HackerUpgradeKind.Detection => DetectionTier,
		HackerUpgradeKind.PuzzleTime => PuzzleTimeTier,
		HackerUpgradeKind.Reward => RewardTier,
		HackerUpgradeKind.Cooldown => CooldownTier,
		_ => 0
	};

	public int GetMaxTierForRack( HackerUpgradeKind kind ) =>
		HackerUpgradeCatalog.GetMaxTier( RackTier, kind );

	private void SetTier( HackerUpgradeKind kind, int value )
	{
		switch ( kind )
		{
			case HackerUpgradeKind.Detection: DetectionTier = value; break;
			case HackerUpgradeKind.PuzzleTime: PuzzleTimeTier = value; break;
			case HackerUpgradeKind.Reward: RewardTier = value; break;
			case HackerUpgradeKind.Cooldown: CooldownTier = value; break;
		}
	}
}
