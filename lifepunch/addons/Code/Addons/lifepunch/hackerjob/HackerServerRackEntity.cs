// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Hacker Job" (s&box ident: lifepunch.hackerjob · addon ident: hackerjob) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using Sandbox;
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

	public float PuzzleTimeLimitSeconds => HackerUpgradeCatalog.GetPuzzleTimeLimitSeconds( PuzzleTimeTier );
	public float RewardMultiplier => HackerUpgradeCatalog.GetRewardMultiplier( RewardTier );
	public float HackCooldownSeconds => HackerUpgradeCatalog.GetHackCooldownSeconds( CooldownTier );

	public bool Press( IPressable.Event e )
	{
		RequestOpenMenu();
		return true;
	}

	public void RequestOpenMenu() => OpenMenuHost();

	[Rpc.Host]
	private void OpenMenuHost()
	{
#if !LIFEPUNCH_LOCAL
		if ( !GameUtils.HasPermission( Rpc.Caller, GameObject ) )
			return;
#endif
		OpenMenu( Rpc.CallerId );
	}

	[Rpc.Broadcast]
	private void OpenMenu( System.Guid callerId )
	{
		if ( Connection.Local.Id != callerId )
			return;

		HackerServerRackMenu.Open( this );
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
		RefreshLinkedTerminalScreens();
	}

	private void RefreshLinkedTerminalScreens()
	{
		foreach ( var terminal in HackerServerRackRegistry.GetLinkedTerminals( this ) )
			terminal?.RefreshScreenIdle();
	}

	public void RequestUpgrade( HackerUpgradeKind kind ) => UpgradeHost( kind );

	[Rpc.Host]
	private void UpgradeHost( HackerUpgradeKind kind )
	{
#if !LIFEPUNCH_LOCAL
		if ( !GameUtils.HasPermission( Rpc.Caller, GameObject ) )
			return;
#endif

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

		// Phase 2: ChargeHost + audit. Baseline: tier bump after affordability check.
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
