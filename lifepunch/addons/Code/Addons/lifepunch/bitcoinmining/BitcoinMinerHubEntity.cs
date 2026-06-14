// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Bitcoin Mining" (s&box ident: lifepunch.bitcoinmining · addon ident: bitcoinmining) is the sole-owned
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

namespace LifePunch.DXRP.Addons.BitcoinMining;

/// <summary>
/// Bitcoin Miner hub (Ophion) — hashd menu anchor, hub power, encryption defense tiers.
/// Racks link explicitly via hashd <c>link</c> / <c>unlink</c> (stored on <see cref="LinkedRigIds"/>).
/// </summary>
[Title( "Bitcoin Miner Hub" )]
[Category( "LifePunch/Bitcoin Miner" )]
#if LIFEPUNCH_LOCAL
public sealed class BitcoinMinerHubEntity : Component, Component.IPressable
#else
public sealed class BitcoinMinerHubEntity : BaseEntity, Component.IPressable
#endif
{
	[Property] public ModelRenderer ModelRenderer { get; set; }

	[Sync( SyncFlags.FromHost )] public bool IsPowered { get; set; }
	/// <summary>Hub wallet — linked GPU racks credit this balance on mining ticks.</summary>
	[Sync( SyncFlags.FromHost )] public float BitcoinAmount { get; set; }
	[Sync( SyncFlags.FromHost )] public int FirewallTier { get; set; }
	[Sync( SyncFlags.FromHost )] public int WalletCipherTier { get; set; }
	[Sync( SyncFlags.FromHost )] public int IntrusionAlertTier { get; set; }
	[Sync( SyncFlags.FromHost )] public int RehackCooldownTier { get; set; }
	[Sync( SyncFlags.FromHost )] public int PuzzleHardeningTier { get; set; }
	/// <summary>True when a 4-digit operator PIN is configured (hash stays host-only).</summary>
	[Sync( SyncFlags.FromHost )] public bool AccessPinIsSet { get; set; }
	/// <summary>Display label for the operator who configured the hub PIN.</summary>
	[Sync( SyncFlags.FromHost )] public string OperatorDisplayName { get; set; } = "";
	/// <summary>Pipe-separated <see cref="GameObject.Id"/> values for explicitly linked GPU racks.</summary>
	[Sync( SyncFlags.FromHost )] public string LinkedRigIds { get; set; } = "";

	private ushort _pinHash;
	private readonly Dictionary<Guid, double> _sessionExpiry = new();
	private readonly Dictionary<Guid, HashdSurface> _pendingSurface = new();
	private readonly Dictionary<Guid, Guid> _pendingHeadObjectId = new();
	private readonly List<string> _operationLog = new();
	private const int MaxOperationLogLines = 200;

	public float FirewallFailBonus => BitcoinMinerEncryptionCatalog.GetFirewallFailBonus( FirewallTier );
	public float WalletStealReduction => BitcoinMinerEncryptionCatalog.GetWalletCipherStealReduction( WalletCipherTier );
	public float IntrusionAlertChance => BitcoinMinerEncryptionCatalog.GetIntrusionAlertChance( IntrusionAlertTier );
	public float RehackCooldownBonusSeconds => BitcoinMinerEncryptionCatalog.GetRehackCooldownBonusSeconds( RehackCooldownTier );
	public float PuzzleHardeningSeconds => BitcoinMinerEncryptionCatalog.GetPuzzleHardeningSeconds( PuzzleHardeningTier );

	protected override void OnStart()
	{
		base.OnStart();
		EnsurePhysicalBody();
		TryBindSpawnOwnerHost();
		ApplyHubPowerState( IsPowered );
	}

	/// <summary>Prefab ships with gravity + motion; wake the body so placement and pushes behave normally.</summary>
	private void EnsurePhysicalBody()
	{
		var body = Components.Get<Rigidbody>( FindMode.EverythingInSelf );
		if ( !body.IsValid() )
			return;

		body.Gravity = true;
		body.MotionEnabled = true;
	}

	/// <summary>Stamp spawner Steam ID from network owner or first USE caller when <see cref="Owner"/> is still unset.</summary>
	private void TryBindSpawnOwnerHost( Guid? callerId = null )
	{
#if !LIFEPUNCH_LOCAL
		if ( !Networking.IsHost || Owner != 0 )
			return;

		var networkOwner = GameObject.Network.Owner;
		if ( networkOwner != null )
		{
			var ownerPlayer = GameUtils.GetPlayerByConnectionId( networkOwner.Id );
			if ( ownerPlayer.IsValid() )
			{
				Owner = ownerPlayer.SteamId;
				return;
			}
		}

		if ( callerId.HasValue )
		{
			var callerPlayer = GameUtils.GetPlayerByConnectionId( callerId.Value );
			if ( callerPlayer.IsValid() )
				Owner = callerPlayer.SteamId;
		}
#endif
	}

	public bool CanPress( IPressable.Event e ) => LifePunchMenuInteractGate.CanPressMenu( GameObject );

	public bool Press( IPressable.Event e )
	{
		RequestOpenTerminal();
		return true;
	}

	public void RequestOpenTerminal() => BeginTerminalOpen( HashdSurface.HubPanel, GameObject );

	/// <summary>Legacy alias — terminal flow handles power gate after PIN auth.</summary>
	public void RequestOpenPowerGate() => BeginTerminalOpen( HashdSurface.HubPanel, GameObject );

	/// <summary>Legacy alias — opens hub management panel after PIN auth.</summary>
	public void RequestOpenHashd() => BeginTerminalOpen( HashdSurface.HubPanel, GameObject );

	/// <summary>USE on the HASHD monitor — rig0 command console after PIN auth.</summary>
	public void RequestOpenHeadConsole( GameObject headSource ) =>
		BeginTerminalOpen( HashdSurface.HeadConsole, headSource );

	[Rpc.Host]
	private void BeginTerminalOpen( HashdSurface surface, GameObject reachObject )
	{
		if ( !reachObject.IsValid() || !LifePunchMenuInteractGate.IsCallerAllowed( Rpc.Caller, reachObject ) )
			return;

		_pendingSurface[Rpc.CallerId] = surface;
		if ( surface == HashdSurface.HeadConsole && reachObject.IsValid() )
			_pendingHeadObjectId[Rpc.CallerId] = reachObject.Id;

		OpenTerminalHost();
	}

	[Rpc.Host]
	private void OpenTerminalHost()
	{
		TryBindSpawnOwnerHost( Rpc.CallerId );

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

		ContinueAfterAuth( Rpc.CallerId );
		return;
#endif

		if ( !AccessPinIsSet )
		{
			if ( IsHubOwner( Rpc.CallerId ) )
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

		ContinueAfterAuth( Rpc.CallerId );
	}

	private void ContinueAfterAuth( Guid callerId )
	{
		var surface = _pendingSurface.TryGetValue( callerId, out var pending )
			? pending
			: HashdSurface.HubPanel;

		_pendingSurface.Remove( callerId );

		if ( surface == HashdSurface.HeadConsole )
		{
			OpenHeadConsole( callerId );
			return;
		}

		if ( !IsPowered )
			OpenPowerGate( callerId );
		else
			OpenHubPanel( callerId );
	}

	[Rpc.Broadcast]
	private void OpenPowerGate( System.Guid callerId )
	{
		if ( Connection.Local.Id != callerId )
			return;

		HashdTerminal.OpenHubPowerGate( this );
	}

	[Rpc.Broadcast]
	private void OpenHubPanel( System.Guid callerId )
	{
		if ( Connection.Local.Id != callerId )
			return;

		HashdTerminal.OpenHubPanel( this );
	}

	[Rpc.Broadcast]
	private void OpenHeadConsole( Guid callerId )
	{
		if ( Connection.Local.Id != callerId )
			return;

		GameObject head = null;
		if ( _pendingHeadObjectId.TryGetValue( callerId, out var headId ) )
		{
			_pendingHeadObjectId.Remove( callerId );
			head = GameObject.Scene?.Directory.FindByGuid( headId );
		}

		if ( !head.IsValid() )
			head = FindLinkedHeadForCaller( callerId );

		HashdTerminal.OpenHeadConsole( this, head );
	}

	private GameObject FindLinkedHeadForCaller( Guid callerId )
	{
		var scene = GameObject.Scene;
		if ( scene is null )
			return null;

		GameObject best = null;
		var bestHorizontal = float.MaxValue;

		foreach ( var prop in scene.GetAllComponents<BitcoinTerminalProp>() )
		{
			if ( !prop.IsValid() || !prop.GameObject.IsValid() )
				continue;

			if ( !BitcoinTerminalProp.IsWithinHubLinkRange( prop.WorldPosition, WorldPosition ) )
				continue;

			var delta = prop.WorldPosition - WorldPosition;
			var horizontal = new Vector3( delta.x, delta.y, 0f ).Length;
			if ( horizontal < bestHorizontal )
			{
				bestHorizontal = horizontal;
				best = prop.GameObject;
			}
		}

		return best;
	}

	internal IReadOnlyList<string> GetOperationLog() => _operationLog;

	public void RequestAppendOperationLog( string line ) => AppendOperationLogHost( line );

	[Rpc.Host]
	private void AppendOperationLogHost( string line )
	{
		if ( string.IsNullOrWhiteSpace( line ) )
			return;

		_operationLog.Add( line );
		while ( _operationLog.Count > MaxOperationLogLines )
			_operationLog.RemoveAt( 0 );
	}

	[Rpc.Broadcast]
	private void OpenPinSetup( Guid callerId )
	{
		if ( Connection.Local.Id != callerId )
			return;

		HashdTerminal.OpenHubPinSetup( this );
	}

	[Rpc.Broadcast]
	private void OpenPinUnlock( Guid callerId )
	{
		if ( Connection.Local.Id != callerId )
			return;

		HashdTerminal.OpenHubPinUnlock( this );
	}

	[Rpc.Broadcast]
	private void OpenPinBlocked( Guid callerId )
	{
		if ( Connection.Local.Id != callerId )
			return;

		HashdTerminal.OpenHubPinBlocked( this );
	}

	public void RequestSetAccessPin( string pin, string confirm ) => SetAccessPinHost( pin, confirm );

	[Rpc.Host]
	private void SetAccessPinHost( string pin, string confirm )
	{
		if ( !IsCallerInReach() )
			return;

		if ( !IsHubOwner( Rpc.CallerId ) )
		{
			DenyPinUnlock( Rpc.CallerId, "Only the hub owner can set the initial PIN." );
			return;
		}

		if ( AccessPinIsSet )
		{
			DenyPinUnlock( Rpc.CallerId, "PIN already set — contact the operator to change it." );
			return;
		}

		if ( !BitcoinMinerHubAccessPin.IsValidFormat( pin ) || pin != confirm )
		{
			DenyPinUnlock( Rpc.CallerId, "PIN must be four digits." );
			return;
		}

		_pinHash = BitcoinMinerHubAccessPin.Hash( pin, GameObject.Id );
		AccessPinIsSet = true;
		OperatorDisplayName = ResolveOperatorLabel( Rpc.CallerId );
		AuthorizeSession( Rpc.CallerId );
		ContinueAfterAuth( Rpc.CallerId );
	}

	public void RequestUnlockAccessPin( string pin ) => UnlockAccessPinHost( pin );

	[Rpc.Host]
	private void UnlockAccessPinHost( string pin )
	{
		if ( !IsCallerInReach() )
			return;

		if ( !AccessPinIsSet )
		{
			if ( IsHubOwner( Rpc.CallerId ) )
				OpenPinSetup( Rpc.CallerId );
			else
				OpenPinBlocked( Rpc.CallerId );

			return;
		}

		if ( !BitcoinMinerHubAccessPin.IsValidFormat( pin ) )
		{
			DenyPinUnlock( Rpc.CallerId, "Enter a 4-digit PIN." );
			return;
		}

		if ( BitcoinMinerHubAccessPin.Hash( pin, GameObject.Id ) != _pinHash )
		{
			DenyPinUnlock( Rpc.CallerId, "Invalid PIN." );
			return;
		}

		AuthorizeSession( Rpc.CallerId );
		ContinueAfterAuth( Rpc.CallerId );
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

		HashdTerminal.NotifyPinDenied( message );
	}

	public bool IsAccessAuthorized( Guid callerId )
	{
		if ( !AccessPinIsSet )
			return false;

		return _sessionExpiry.TryGetValue( callerId, out var expiry ) && Time.Now < expiry;
	}

	/// <summary>Host RPCs that move money or rigs require an unlocked PIN session once configured.</summary>
	public bool RequiresPinSession( Guid callerId ) => AccessPinIsSet && !IsAccessAuthorized( callerId );

	public string GetOwnerLabel()
	{
#if LIFEPUNCH_LOCAL
		return "LOCAL OWNER";
#else
		if ( Owner == 0 )
			return "unassigned";

		var player = GameUtils.GetPlayerById( Owner );
		if ( player.IsValid() )
			return string.IsNullOrWhiteSpace( player.DisplayName ) ? player.SteamId.ToString() : player.DisplayName;

		return Owner.ToString();
#endif
	}

	/// <summary>Client-side — true when local player is the spawner stamped on this hub.</summary>
	public bool IsLocalPlayerHubOwner()
	{
#if LIFEPUNCH_LOCAL
		return true;
#else
		return Owner != 0 && Player.Local.IsValid() && Player.Local.SteamId == Owner;
#endif
	}

	/// <summary>Hub is dormant until the spawner registers the gatekeeper PIN.</summary>
	public bool IsHubAwakened => AccessPinIsSet;

	private bool IsHubOwner( Guid callerId )
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

	private bool IsCallerInReach() => LifePunchMenuInteractGate.IsCallerAllowed( Rpc.Caller, GameObject );

	private void AuthorizeSession( Guid callerId )
	{
		_sessionExpiry[callerId] = Time.Now + BitcoinMinerHubAccessPin.SessionSeconds;
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
		if ( !IsCallerInReach() || RequiresPinSession( Rpc.CallerId ) )
			return;

		IsPowered = powered;
		BroadcastHubPowerState( powered );
		if ( !powered )
			StopLinkedRacks();
	}

	[Rpc.Broadcast]
	private void BroadcastHubPowerState( bool powered )
	{
		ApplyHubPowerState( powered );
	}

	private void ApplyHubPowerState( bool powered )
	{
		GpuRackPowerAnim.ApplyHubPower( ModelRenderer, powered, out _ );
	}

	public void RequestUpgrade( BitcoinMiningAddonEncryptionKind kind ) => UpgradeHost( kind );

	[Rpc.Host]
	private void UpgradeHost( BitcoinMiningAddonEncryptionKind kind )
	{
		if ( !IsCallerInReach() || RequiresPinSession( Rpc.CallerId ) )
			return;

		var current = GetTier( kind );
		var max = GetMaxTier( kind );
		if ( current >= max )
			return;

		var cost = BitcoinMinerEncryptionCatalog.GetUpgradeCost( kind, current + 1 );
#if LIFEPUNCH_LOCAL
		SetTier( kind, current + 1 );
#else
		var player = GameUtils.GetPlayerByConnectionId( Rpc.CallerId );
		if ( !player.IsValid() || player.WalletBalance < cost )
			return;

		SetTier( kind, current + 1 );
#endif
	}

	public int GetTier( BitcoinMiningAddonEncryptionKind kind ) => kind switch
	{
		BitcoinMiningAddonEncryptionKind.Firewall => FirewallTier,
		BitcoinMiningAddonEncryptionKind.WalletCipher => WalletCipherTier,
		BitcoinMiningAddonEncryptionKind.IntrusionAlert => IntrusionAlertTier,
		BitcoinMiningAddonEncryptionKind.RehackCooldown => RehackCooldownTier,
		BitcoinMiningAddonEncryptionKind.PuzzleHardening => PuzzleHardeningTier,
		_ => 0
	};

	public int GetMaxTier( BitcoinMiningAddonEncryptionKind kind ) => kind switch
	{
		BitcoinMiningAddonEncryptionKind.Firewall => BitcoinMinerEncryptionCatalog.MaxFirewallTier,
		BitcoinMiningAddonEncryptionKind.WalletCipher => BitcoinMinerEncryptionCatalog.MaxWalletCipherTier,
		BitcoinMiningAddonEncryptionKind.IntrusionAlert => BitcoinMinerEncryptionCatalog.MaxIntrusionAlertTier,
		BitcoinMiningAddonEncryptionKind.RehackCooldown => BitcoinMinerEncryptionCatalog.MaxRehackCooldownTier,
		BitcoinMiningAddonEncryptionKind.PuzzleHardening => BitcoinMinerEncryptionCatalog.MaxPuzzleHardeningTier,
		_ => 0
	};

	private void SetTier( BitcoinMiningAddonEncryptionKind kind, int tier )
	{
		switch ( kind )
		{
			case BitcoinMiningAddonEncryptionKind.Firewall:
				FirewallTier = tier;
				break;
			case BitcoinMiningAddonEncryptionKind.WalletCipher:
				WalletCipherTier = tier;
				break;
			case BitcoinMiningAddonEncryptionKind.IntrusionAlert:
				IntrusionAlertTier = tier;
				break;
			case BitcoinMiningAddonEncryptionKind.RehackCooldown:
				RehackCooldownTier = tier;
				break;
			case BitcoinMiningAddonEncryptionKind.PuzzleHardening:
				PuzzleHardeningTier = tier;
				break;
		}
	}

	private void StopLinkedRacks()
	{
		foreach ( var rig in BitcoinMinerHubRegistry.GetLinkedRacks( this ) )
			rig?.RequestSetMiningState( false );
	}

	/// <summary>Host-only — called when a linked rack completes a mining tick.</summary>
	public void CreditMiningPayout( float amount )
	{
		if ( amount <= 0f || !IsPowered )
			return;

		BitcoinAmount += amount;
	}

	public void RequestSellBitcoin() => SellBitcoinHost();

	public void RequestLinkRig( int scanIndex ) => LinkRigHost( scanIndex );

	public void RequestUnlinkRig( int linkIndex ) => UnlinkRigHost( linkIndex );

	public void RequestUnlinkAllRigs() => UnlinkAllRigsHost();

	[Rpc.Host]
	private void LinkRigHost( int scanIndex )
	{
		if ( !IsCallerInReach() || RequiresPinSession( Rpc.CallerId ) )
			return;

		var candidates = BitcoinMinerHubRegistry.ScanUnlinkedRigs( this );
		if ( scanIndex < 0 || scanIndex >= candidates.Count )
		{
			NotifyLinkMessage( Rpc.CallerId, $"ERROR: invalid link index — run 'link' to list ({candidates.Count} available)." );
			return;
		}

		if ( !BitcoinMinerHubRegistry.TryLinkRig( this, candidates[scanIndex], out var error ) )
		{
			NotifyLinkMessage( Rpc.CallerId, $"ERROR: {error}" );
			return;
		}

		NotifyLinkMessage( Rpc.CallerId, $"LINKED: {BitcoinMinerHubRegistry.GetRigLabel( candidates[scanIndex] )}." );
	}

	[Rpc.Host]
	private void UnlinkRigHost( int linkIndex )
	{
		if ( !IsCallerInReach() || RequiresPinSession( Rpc.CallerId ) )
			return;

		if ( !BitcoinMinerHubRegistry.TryUnlinkRigAt( this, linkIndex, out var error ) )
		{
			NotifyLinkMessage( Rpc.CallerId, $"ERROR: {error}" );
			return;
		}

		NotifyLinkMessage( Rpc.CallerId, "UNLINKED: rack removed from hub." );
	}

	[Rpc.Host]
	private void UnlinkAllRigsHost()
	{
		if ( !IsCallerInReach() || RequiresPinSession( Rpc.CallerId ) )
			return;

		BitcoinMinerHubRegistry.UnlinkAll( this );
		NotifyLinkMessage( Rpc.CallerId, "UNLINKED: all racks cleared." );
	}

	[Rpc.Broadcast]
	private void NotifyLinkMessage( Guid callerId, string message )
	{
		if ( Connection.Local.Id != callerId )
			return;

		AppendOperationLogHost( message );
		HashdTerminal.NotifyLinkMessage( message );
	}

	[Rpc.Host]
	private async void SellBitcoinHost()
	{
		var callerId = Rpc.CallerId;

		if ( !IsCallerInReach() || RequiresPinSession( callerId ) )
			return;

		if ( BitcoinAmount <= 0f )
			return;

		var value = (uint)( BitcoinAmount * GpuRackEntity.BitcoinValue );

		if ( !await TryPayPlayer( callerId, value, "Sold mined bitcoin" ) )
			return;

		BitcoinAmount = 0f;
	}

#if LIFEPUNCH_LOCAL
	private static async System.Threading.Tasks.Task<bool> TryPayPlayer( System.Guid callerId, uint amount, string reason )
	{
		await System.Threading.Tasks.Task.CompletedTask;
		return true;
	}
#else
	private async System.Threading.Tasks.Task<bool> TryPayPlayer( System.Guid callerId, uint amount, string reason )
	{
		var player = GameUtils.GetPlayerByConnectionId( callerId );
		return player.IsValid() && await player.PayHost( amount, reason );
	}
#endif
}
