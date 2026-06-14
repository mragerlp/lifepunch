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
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
#endif

namespace LifePunch.DXRP.Addons.HackerJob;

/// <summary>
/// Host-only economy and hack validation seam. Phase 1: validate + audit log, never move money.
/// Phase 2 (Opus): job gate, distance, cooldowns, wallet debit/credit, govdb breach — see
/// <c>hackerjob/docs/SECURITY.md</c>.
/// </summary>
public static class HackerEconomySecurity
{
	// ── Phase 2 economy skeleton (prep only — no wallet transfer until owner post-legal sign-off) ──
	// Swap point checklist: hackerjob/docs/SECURITY.md + HACKER_PHASE2_ECONOMY_PREP.md
	// 1. ProcessWalletTransferHost — debit target.WalletBalance, credit hacker (on-hand cash only)
	// 2. ProcessRackUpgradeChargeHost — debit installer on INSTALL button (rack menu today is UI-only)
	// 3. BuildScanTargetsHost — host enumerates players + GovernmentTaxMinerEntity nodes
	// 4. IssuePuzzleSessionHost — session id on hack/infil start (closes HACKER-02)
	// 5. IsHackerJobHost + ValidateTerminalProximityHost — job + distance gates
	// DO NOT call DXRP ChargeHost/PayHost from Phase 1 paths until checklist is signed off.

	public readonly record struct HackAttemptResult( bool Accepted, bool FundsMoved, string Message )
	{
		public static HackAttemptResult Denied( string message ) => new( false, false, message );
		public static HackAttemptResult AcceptedNoTransfer( string message ) => new( true, false, message );
	}

	/// <summary>Re-validate puzzle on host — never trust client-only <see cref="HackerPuzzleSession.TrySubmit"/>.</summary>
	public static bool ValidatePuzzleOnHost(
		HackerPuzzleSession.PuzzleKind kind,
		string submittedAnswer,
		bool advancedTerminal,
		float secondsElapsed,
		float timeLimitSeconds )
	{
		if ( secondsElapsed > timeLimitSeconds + 0.25f )
			return false;

		if ( advancedTerminal )
		{
			return kind == HackerPuzzleSession.PuzzleKind.GovDbBypass
				&& string.Equals( submittedAnswer?.Trim(), "govdb_breach", StringComparison.OrdinalIgnoreCase );
		}

		return kind switch
		{
			HackerPuzzleSession.PuzzleKind.CompleteTheLine =>
				string.Equals( submittedAnswer?.Trim(), "drain(wallet);", StringComparison.OrdinalIgnoreCase ),
			HackerPuzzleSession.PuzzleKind.TypeSequence =>
				string.Equals( submittedAnswer?.Trim(), "cornerman_bypass", StringComparison.OrdinalIgnoreCase ),
			HackerPuzzleSession.PuzzleKind.PickFix =>
				string.Equals( submittedAnswer?.Trim(), "1", StringComparison.OrdinalIgnoreCase ),
			_ => false
		};
	}

#if !LIFEPUNCH_LOCAL
	public static HackAttemptResult ProcessWalletHackHost(
		HackerTerminalEntity terminal,
		Player hacker,
		long targetSteamId,
		HackerPuzzleSession.PuzzleKind puzzleKind,
		string submittedAnswer,
		float secondsElapsed,
		float timeLimitSeconds )
	{
		if ( !terminal.IsValid() || !hacker.IsValid() )
			return HackAttemptResult.Denied( "invalid session" );

		if ( hacker.SteamId == targetSteamId )
			return HackAttemptResult.Denied( "cannot hack self" );

		// Phase 2: IsHackerJob( hacker ), distance/LOS to terminal, per-target cooldown, audit log.
		if ( !ValidatePuzzleOnHost( puzzleKind, submittedAnswer, advancedTerminal: false, secondsElapsed, timeLimitSeconds ) )
		{
			var rack = HackerServerRackRegistry.FindRackForTerminal( terminal );
			_ = HackerCounterplayService.TryTriggerFailedHackAlert( rack, hacker.WorldPosition );
			return HackAttemptResult.Denied( "puzzle validation failed" );
		}

		// Phase 2: clamp transfer to target.WalletBalance; ChargeHost/PayHost; never touch bank.
		Log.Info( $"[LIFEPUNCH Hacker] wallet hack validated (stub) — hacker={hacker.SteamId} target={targetSteamId} kind={puzzleKind}" );
		return HackAttemptResult.AcceptedNoTransfer( "validated — Phase 2 economy not enabled" );
	}

	public static HackAttemptResult ProcessGovdbInfilHost(
		HackerTerminalEntity terminal,
		Player hacker,
		string nodeId,
		HackerPuzzleSession.PuzzleKind puzzleKind,
		string submittedAnswer,
		float secondsElapsed,
		float timeLimitSeconds )
	{
		if ( !terminal.IsValid() || !hacker.IsValid() || !terminal.IsAdvanced )
			return HackAttemptResult.Denied( "invalid session" );

		if ( string.IsNullOrWhiteSpace( nodeId ) )
			return HackAttemptResult.Denied( "invalid node" );

		if ( !ValidatePuzzleOnHost( puzzleKind, submittedAnswer, advancedTerminal: true, secondsElapsed, timeLimitSeconds ) )
		{
			var rack = HackerServerRackRegistry.FindRackForTerminal( terminal );
			_ = HackerCounterplayService.TryTriggerFailedHackAlert( rack, hacker.WorldPosition );
			return HackAttemptResult.Denied( "puzzle validation failed" );
		}

		Log.Info( $"[LIFEPUNCH Hacker] govdb infil validated (stub) — hacker={hacker.SteamId} node={nodeId}" );
		return HackAttemptResult.AcceptedNoTransfer( "validated — Phase 2 govdb not enabled" );
	}
#else
	public static HackAttemptResult ProcessWalletHackHost(
		HackerTerminalEntity terminal,
		long targetSteamId,
		HackerPuzzleSession.PuzzleKind puzzleKind,
		string submittedAnswer,
		float secondsElapsed,
		float timeLimitSeconds )
	{
		_ = terminal;
		if ( !ValidatePuzzleOnHost( puzzleKind, submittedAnswer, advancedTerminal: false, secondsElapsed, timeLimitSeconds ) )
			return HackAttemptResult.Denied( "puzzle validation failed" );

		Log.Info( $"[LIFEPUNCH Hacker] wallet hack local stub — target={targetSteamId}" );
		return HackAttemptResult.AcceptedNoTransfer( "local stub — no funds moved" );
	}

	public static HackAttemptResult ProcessGovdbInfilHost(
		HackerTerminalEntity terminal,
		string nodeId,
		HackerPuzzleSession.PuzzleKind puzzleKind,
		string submittedAnswer,
		float secondsElapsed,
		float timeLimitSeconds )
	{
		_ = terminal;
		if ( !ValidatePuzzleOnHost( puzzleKind, submittedAnswer, advancedTerminal: true, secondsElapsed, timeLimitSeconds ) )
			return HackAttemptResult.Denied( "puzzle validation failed" );

		Log.Info( $"[LIFEPUNCH Hacker] govdb infil local stub — node={nodeId}" );
		return HackAttemptResult.AcceptedNoTransfer( "local stub — no records exfiltrated" );
	}
#endif
}
