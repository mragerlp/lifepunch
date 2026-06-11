// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Bitcoin Mining" (s&box ident: lifepunch.bitcoinmining · addon ident: bitcoinmining) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using Sandbox;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
#endif

namespace LifePunch.DXRP.Addons.BitcoinMining;

/// <summary>
/// Bitcoin Miner hub (Ophion) — hashd menu anchor, hub power, encryption defense tiers.
/// Racks link by proximity via <see cref="BitminerHubRegistry"/>.
/// </summary>
[Title( "Bitcoin Miner Hub" )]
[Category( "LifePunch/Bitcoin Miner" )]
#if LIFEPUNCH_LOCAL
public sealed class BitminerHubEntity : Component, Component.IPressable
#else
public sealed class BitminerHubEntity : BaseEntity, Component.IPressable
#endif
{
	[Property] public ModelRenderer ModelRenderer { get; set; }

	[Sync( SyncFlags.FromHost )] public bool IsPowered { get; set; }
	[Sync( SyncFlags.FromHost )] public int FirewallTier { get; set; }
	[Sync( SyncFlags.FromHost )] public int WalletCipherTier { get; set; }
	[Sync( SyncFlags.FromHost )] public int IntrusionAlertTier { get; set; }
	[Sync( SyncFlags.FromHost )] public int RehackCooldownTier { get; set; }
	[Sync( SyncFlags.FromHost )] public int PuzzleHardeningTier { get; set; }

	public float FirewallFailBonus => BitminerEncryptionCatalog.GetFirewallFailBonus( FirewallTier );
	public float WalletStealReduction => BitminerEncryptionCatalog.GetWalletCipherStealReduction( WalletCipherTier );
	public float IntrusionAlertChance => BitminerEncryptionCatalog.GetIntrusionAlertChance( IntrusionAlertTier );
	public float RehackCooldownBonusSeconds => BitminerEncryptionCatalog.GetRehackCooldownBonusSeconds( RehackCooldownTier );
	public float PuzzleHardeningSeconds => BitminerEncryptionCatalog.GetPuzzleHardeningSeconds( PuzzleHardeningTier );

	private SoundHandle _hubFanLoopHandle;
	private bool _hubFanLoopPlaying;
	private float _hubFanVolume;
	private const float HubFanMaxVolume = 1f;
	private const float HubFanRampSeconds = 4f;

	protected override void OnStart()
	{
		base.OnStart();
		ApplyHubPowerState( IsPowered );
	}

	protected override void OnUpdate()
	{
		base.OnUpdate();

		UpdateHubFanVolume();
	}

	public bool Press( IPressable.Event e )
	{
		if ( !IsPowered )
		{
			RequestOpenPowerGate();
			return true;
		}

		RequestOpenHashd();
		return true;
	}

	public void RequestOpenPowerGate() => OpenPowerGateHost();

	[Rpc.Host]
	private void OpenPowerGateHost()
	{
#if !LIFEPUNCH_LOCAL
		if ( !GameUtils.HasPermission( Rpc.Caller, GameObject ) )
			return;
#endif
		if ( IsPowered )
			return;

		OpenPowerGate( Rpc.CallerId );
	}

	[Rpc.Broadcast]
	private void OpenPowerGate( System.Guid callerId )
	{
		if ( Connection.Local.Id != callerId )
			return;

		BitminerTerminal.OpenHubPowerGate( this );
	}

	public void RequestOpenHashd() => OpenHashdHost();

	[Rpc.Host]
	private void OpenHashdHost()
	{
#if !LIFEPUNCH_LOCAL
		if ( !GameUtils.HasPermission( Rpc.Caller, GameObject ) )
			return;
#endif
		if ( !IsPowered )
			return;

		OpenHashd( Rpc.CallerId );
	}

	[Rpc.Broadcast]
	private void OpenHashd( System.Guid callerId )
	{
		if ( Connection.Local.Id != callerId )
			return;

		BitminerTerminal.OpenFromHub( this );
	}

	public void RequestSetPowered( bool powered ) => SetPoweredHost( powered );

	[Rpc.Host]
	private void SetPoweredHost( bool powered )
	{
#if !LIFEPUNCH_LOCAL
		if ( !GameUtils.HasPermission( Rpc.Caller, GameObject ) )
			return;
#endif

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
		BitminerPowerAnim.ApplyHubPower( ModelRenderer, powered, out _ );
		UpdateHubSounds( powered );
	}

	private void UpdateHubSounds( bool powered )
	{
		if ( powered )
		{
			if ( !_hubFanLoopPlaying )
			{
				Sound.Play( Bitminer.HubStartupSoundPath, WorldPosition );
				_hubFanLoopHandle = Sound.Play( Bitminer.HubFanLoopSoundPath, WorldPosition );
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
				Sound.Play( Bitminer.HubFanDownSoundPath, WorldPosition );
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

	public void RequestUpgrade( BitminerEncryptionKind kind ) => UpgradeHost( kind );

	[Rpc.Host]
	private void UpgradeHost( BitminerEncryptionKind kind )
	{
#if !LIFEPUNCH_LOCAL
		if ( !GameUtils.HasPermission( Rpc.Caller, GameObject ) )
			return;
#endif

		var current = GetTier( kind );
		var max = GetMaxTier( kind );
		if ( current >= max )
			return;

		var cost = BitminerEncryptionCatalog.GetUpgradeCost( kind, current + 1 );
#if LIFEPUNCH_LOCAL
		SetTier( kind, current + 1 );
#else
		var player = GameUtils.GetPlayerByConnectionId( Rpc.CallerId );
		if ( !player.IsValid() || player.WalletBalance < cost )
			return;

		SetTier( kind, current + 1 );
#endif
	}

	public int GetTier( BitminerEncryptionKind kind ) => kind switch
	{
		BitminerEncryptionKind.Firewall => FirewallTier,
		BitminerEncryptionKind.WalletCipher => WalletCipherTier,
		BitminerEncryptionKind.IntrusionAlert => IntrusionAlertTier,
		BitminerEncryptionKind.RehackCooldown => RehackCooldownTier,
		BitminerEncryptionKind.PuzzleHardening => PuzzleHardeningTier,
		_ => 0
	};

	public int GetMaxTier( BitminerEncryptionKind kind ) => kind switch
	{
		BitminerEncryptionKind.Firewall => BitminerEncryptionCatalog.MaxFirewallTier,
		BitminerEncryptionKind.WalletCipher => BitminerEncryptionCatalog.MaxWalletCipherTier,
		BitminerEncryptionKind.IntrusionAlert => BitminerEncryptionCatalog.MaxIntrusionAlertTier,
		BitminerEncryptionKind.RehackCooldown => BitminerEncryptionCatalog.MaxRehackCooldownTier,
		BitminerEncryptionKind.PuzzleHardening => BitminerEncryptionCatalog.MaxPuzzleHardeningTier,
		_ => 0
	};

	private void SetTier( BitminerEncryptionKind kind, int tier )
	{
		switch ( kind )
		{
			case BitminerEncryptionKind.Firewall:
				FirewallTier = tier;
				break;
			case BitminerEncryptionKind.WalletCipher:
				WalletCipherTier = tier;
				break;
			case BitminerEncryptionKind.IntrusionAlert:
				IntrusionAlertTier = tier;
				break;
			case BitminerEncryptionKind.RehackCooldown:
				RehackCooldownTier = tier;
				break;
			case BitminerEncryptionKind.PuzzleHardening:
				PuzzleHardeningTier = tier;
				break;
		}
	}

	private void StopLinkedRacks()
	{
		foreach ( var rig in BitminerHubRegistry.GetLinkedRacks( this ) )
			rig?.SetMiningState( false );
	}
}
