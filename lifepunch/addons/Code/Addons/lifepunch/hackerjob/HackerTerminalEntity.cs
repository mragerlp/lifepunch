// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Hacker Job" (s&box ident: lifepunch.hackerjob · addon ident: hackerjob) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Author account: mrragerlp · Public alias (in-game · Steam · Discord): Bloodwave
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System;
using Sandbox;
using LifePunch.DXRP.Addons;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
#endif

namespace LifePunch.DXRP.Addons.HackerJob;

/// <summary>
/// Placeable retro CRT terminal for the Hacker job.
/// Phase 1: open <c>cornerman.exe</c> UI shell — economy + validated puzzles land in Phase 2 (Opus).
/// </summary>
[Title( "Hacker Terminal" )]
[Category( "LifePunch/Hacker Job" )]
#if LIFEPUNCH_LOCAL
public sealed class HackerTerminalEntity : Component, Component.IPressable
#else
public sealed class HackerTerminalEntity : BaseEntity, Component.IPressable
#endif
{
	[Property] public HackerTerminalTier Tier { get; set; } = HackerTerminalTier.Standard;
	[Property] public HackerServerRackEntity LinkedRack { get; set; }
	[Property] public TextRenderer ScreenText { get; set; }

	public bool IsAdvanced => Tier == HackerTerminalTier.Advanced;
	public bool IsPowered => HackerServerRackRegistry.IsTerminalPowered( this );
	public HackerServerRackEntity ActiveRack => HackerServerRackRegistry.FindRackForTerminal( this );

	public HackerServerRackEntity ResolveLinkedRack() =>
		LinkedRack.IsValid() ? LinkedRack : null;

	public void SetLinkedRackHost( HackerServerRackEntity rack ) => LinkedRack = rack;

	public void ClearLinkedRackHost() => LinkedRack = null;

	protected override void OnAwake()
	{
		LifePunchPropPhysics.SyncBoxColliderFromModel( GameObject );
	}

	protected override void OnStart()
	{
		base.OnStart();
		RefreshScreenIdle();
#if !LIFEPUNCH_LOCAL
		this.TryBindSpawnOwnerHost();
#endif
	}

	public bool CanPress( IPressable.Event e ) => LifePunchMenuInteractGate.CanPressMenu( GameObject );

	public bool Press( IPressable.Event e )
	{
		RequestOpenTerminal();
		return true;
	}

	public void RequestOpenTerminal() => OpenTerminalHost();

	[Rpc.Host]
	private void OpenTerminalHost()
	{
#if !LIFEPUNCH_LOCAL
		if ( !LifePunchMenuInteractGate.IsCallerAllowed( Rpc.Caller, GameObject ) )
			return;
#else
		if ( !LifePunchMenuInteractGate.IsCallerAllowed( null, GameObject ) )
			return;
#endif
		if ( !IsPowered )
		{
			DenyTerminalOpen( Rpc.CallerId, "ERROR: terminal offline — power ON the Server Rack first." );
			return;
		}

		OpenTerminal( Rpc.CallerId );
	}

	[Rpc.Broadcast]
	private void DenyTerminalOpen( Guid callerId, string message )
	{
		if ( Connection.Local.Id != callerId )
			return;

		Log.Info( $"[LIFEPUNCH Hacker] {message}" );
	}

	[Rpc.Broadcast]
	private void OpenTerminal( Guid callerId )
	{
		if ( Connection.Local.Id != callerId )
			return;

		HackerTerminal.Open( this );
	}

	public void RequestSubmitWalletHack( string targetSteamId, int puzzleKind, string answer, float secondsElapsed, float timeLimitSeconds )
		=> SubmitWalletHackHost( targetSteamId, puzzleKind, answer, secondsElapsed, timeLimitSeconds );

	public void RequestSubmitGovdbInfil( string nodeId, int puzzleKind, string answer, float secondsElapsed, float timeLimitSeconds )
		=> SubmitGovdbInfilHost( nodeId, puzzleKind, answer, secondsElapsed, timeLimitSeconds );

	[Rpc.Host]
	private void SubmitWalletHackHost( string targetSteamId, int puzzleKind, string answer, float secondsElapsed, float timeLimitSeconds )
	{
#if !LIFEPUNCH_LOCAL
		if ( !GameUtils.HasPermission( Rpc.Caller, GameObject ) )
			return;

		var hacker = GameUtils.GetPlayerByConnectionId( Rpc.CallerId );
		if ( !hacker.IsValid() )
			return;

		if ( !long.TryParse( targetSteamId, out var targetId ) )
			return;

		var kind = (HackerPuzzleSession.PuzzleKind)puzzleKind;
		_ = HackerEconomySecurity.ProcessWalletHackHost( this, hacker, targetId, kind, answer, secondsElapsed, timeLimitSeconds );
#else
		if ( !long.TryParse( targetSteamId, out var targetId ) )
			return;

		var kind = (HackerPuzzleSession.PuzzleKind)puzzleKind;
		_ = HackerEconomySecurity.ProcessWalletHackHost( this, targetId, kind, answer, secondsElapsed, timeLimitSeconds );
#endif
	}

	[Rpc.Host]
	private void SubmitGovdbInfilHost( string nodeId, int puzzleKind, string answer, float secondsElapsed, float timeLimitSeconds )
	{
#if !LIFEPUNCH_LOCAL
		if ( !GameUtils.HasPermission( Rpc.Caller, GameObject ) )
			return;

		var hacker = GameUtils.GetPlayerByConnectionId( Rpc.CallerId );
		if ( !hacker.IsValid() )
			return;

		var kind = (HackerPuzzleSession.PuzzleKind)puzzleKind;
		_ = HackerEconomySecurity.ProcessGovdbInfilHost( this, hacker, nodeId, kind, answer, secondsElapsed, timeLimitSeconds );
#else
		var kind = (HackerPuzzleSession.PuzzleKind)puzzleKind;
		_ = HackerEconomySecurity.ProcessGovdbInfilHost( this, nodeId, kind, answer, secondsElapsed, timeLimitSeconds );
#endif
	}

	public void RequestReportHackFailure() => ReportHackFailureHost();

	[Rpc.Host]
	private void ReportHackFailureHost()
	{
#if !LIFEPUNCH_LOCAL
		if ( !GameUtils.HasPermission( Rpc.Caller, GameObject ) )
			return;

		var hacker = GameUtils.GetPlayerByConnectionId( Rpc.CallerId );
		var position = hacker.IsValid() ? hacker.WorldPosition : WorldPosition;
#else
		var position = WorldPosition;
#endif
		var rack = ActiveRack;
		var alertLine = HackerCounterplayService.TryTriggerFailedHackAlert( rack, position );
		NotifyHackFailure( Rpc.CallerId, alertLine );
	}

	[Rpc.Broadcast]
	private void NotifyHackFailure( Guid callerId, string alertLine )
	{
		if ( Connection.Local.Id != callerId )
			return;

		HackerTerminal.NotifyHackFailure( alertLine );
	}

	public void RefreshScreenIdle()
	{
		if ( !ScreenText.IsValid() )
			return;

		if ( !IsPowered )
		{
			ScreenText.Text = IsAdvanced
				? "LIFEPUNCH vengeance.exe\n[ OFFLINE ] rack power required"
				: "LIFEPUNCH cornerman.exe\n[ OFFLINE ] rack power required";
			return;
		}

		ScreenText.Text = IsAdvanced
			? "LIFEPUNCH vengeance.exe\n[ STANDBY ] enhanced intrusion rig"
			: "LIFEPUNCH cornerman.exe\n[ STANDBY ] USE to log in";
	}
}
