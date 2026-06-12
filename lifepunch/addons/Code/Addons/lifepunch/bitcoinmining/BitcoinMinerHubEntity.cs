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
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
#endif

namespace LifePunch.DXRP.Addons.BitcoinMining;

/// <summary>
/// Bitcoin Miner hub (Ophion) — hashd menu anchor, hub power, encryption defense tiers.
/// Racks link by proximity via <see cref="BitcoinMinerHubRegistry"/>.
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

	private ushort _pinHash;
	private readonly Dictionary<Guid, double> _sessionExpiry = new();

	public float FirewallFailBonus => BitcoinMinerEncryptionCatalog.GetFirewallFailBonus( FirewallTier );
	public float WalletStealReduction => BitcoinMinerEncryptionCatalog.GetWalletCipherStealReduction( WalletCipherTier );
	public float IntrusionAlertChance => BitcoinMinerEncryptionCatalog.GetIntrusionAlertChance( IntrusionAlertTier );
	public float RehackCooldownBonusSeconds => BitcoinMinerEncryptionCatalog.GetRehackCooldownBonusSeconds( RehackCooldownTier );
	public float PuzzleHardeningSeconds => BitcoinMinerEncryptionCatalog.GetPuzzleHardeningSeconds( PuzzleHardeningTier );

	private SoundHandle _hubFanLoopHandle;
	private bool _hubFanLoopPlaying;
	private float _hubFanVolume;
	private const float HubFanMaxVolume = 1f;
	private const float HubFanRampSeconds = 4f;

	protected override void OnStart()
	{
		base.OnStart();
		TryBindSpawnOwnerHost();
		ApplyHubPowerState( IsPowered );
	}

	/// <summary>Stamp spawner Steam ID from network owner when Market/dev spawn sets connection but not <see cref="Owner"/> yet.</summary>
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

	protected override void OnUpdate()
	{
		base.OnUpdate();

		UpdateHubFanVolume();
	}

	public bool Press( IPressable.Event e )
	{
		RequestOpenTerminal();
		return true;
	}

	public void RequestOpenTerminal() => OpenTerminalHost();

	/// <summary>Legacy alias — terminal flow handles power gate after PIN auth.</summary>
	public void RequestOpenPowerGate() => OpenTerminalHost();

	/// <summary>Legacy alias — terminal flow handles PIN before full console.</summary>
	public void RequestOpenHashd() => OpenTerminalHost();

	[Rpc.Host]
	private void OpenTerminalHost()
	{
		if ( !IsCallerInReach() )
			return;

		TryBindSpawnOwnerHost();

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
		if ( !IsPowered )
			OpenPowerGate( callerId );
		else
			OpenHashd( callerId );
	}

	[Rpc.Broadcast]
	private void OpenPowerGate( System.Guid callerId )
	{
		if ( Connection.Local.Id != callerId )
			return;

		HashdTerminal.OpenHubPowerGate( this );
	}

	[Rpc.Broadcast]
	private void OpenHashd( System.Guid callerId )
	{
		if ( Connection.Local.Id != callerId )
			return;

		HashdTerminal.OpenFromHub( this );
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

	private bool IsCallerInReach()
	{
#if LIFEPUNCH_LOCAL
		return true;
#else
		return GameUtils.HasPermission( Rpc.Caller, GameObject );
#endif
	}

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
		UpdateHubSounds( powered );
	}

	private void UpdateHubSounds( bool powered )
	{
		if ( powered )
		{
			if ( !_hubFanLoopPlaying )
			{
				Sound.Play( BitcoinMiningAddon.HubStartupSoundPath, WorldPosition );
				_hubFanLoopHandle = Sound.Play( BitcoinMiningAddon.HubFanLoopSoundPath, WorldPosition );
				if ( _hubFanLoopHandle is null )
				{
					_hubFanLoopPlaying = false;
					return;
				}

				_hubFanLoopHandle.Volume = 0f;
				_hubFanVolume = 0f;
				_hubFanLoopPlaying = true;
			}
		}
		else
		{
			if ( _hubFanLoopPlaying )
			{
				Sound.Play( BitcoinMiningAddon.HubFanDownSoundPath, WorldPosition );
				_hubFanLoopPlaying = false;
			}
		}
	}

	private void UpdateHubFanVolume()
	{
		if ( !_hubFanLoopPlaying || _hubFanLoopHandle is null )
			return;

		try
		{
			_hubFanLoopHandle.Position = WorldPosition;

			var target = IsPowered ? HubFanMaxVolume : 0f;
			var step = ( HubFanMaxVolume / HubFanRampSeconds ) * Time.Delta;

			if ( _hubFanVolume < target )
				_hubFanVolume = MathF.Min( _hubFanVolume + step, target );
			else if ( _hubFanVolume > target )
				_hubFanVolume = MathF.Max( _hubFanVolume - step, 0f );

			_hubFanLoopHandle.Volume = _hubFanVolume;

			if ( !IsPowered && _hubFanVolume <= 0f )
			{
				_hubFanLoopHandle.Stop();
				_hubFanLoopPlaying = false;
			}
		}
		catch
		{
			_hubFanLoopPlaying = false;
		}
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
