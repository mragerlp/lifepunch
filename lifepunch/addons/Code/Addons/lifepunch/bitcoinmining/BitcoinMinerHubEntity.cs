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
	[Sync( SyncFlags.FromHost )] public int FirewallTier { get; set; }
	[Sync( SyncFlags.FromHost )] public int WalletCipherTier { get; set; }
	[Sync( SyncFlags.FromHost )] public int IntrusionAlertTier { get; set; }
	[Sync( SyncFlags.FromHost )] public int RehackCooldownTier { get; set; }
	[Sync( SyncFlags.FromHost )] public int PuzzleHardeningTier { get; set; }

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

		HashdTerminal.OpenHubPowerGate( this );
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

		HashdTerminal.OpenFromHub( this );
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
#if !LIFEPUNCH_LOCAL
		if ( !GameUtils.HasPermission( Rpc.Caller, GameObject ) )
			return;
#endif

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
			rig?.SetMiningState( false );
	}
}
