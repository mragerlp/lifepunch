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
using Sandbox;

namespace LifePunch.DXRP.Addons.HackerJob;

/// <summary>
/// Time-boxed coding puzzle presented during a wallet hack attempt.
/// Client displays; host re-validates via <see cref="HackerEconomySecurity.ValidatePuzzleOnHost"/>.
/// Phase 2 (Opus): host issues puzzle session id — see TECH_DEBT HACKER-02.
/// </summary>
public sealed class HackerPuzzleSession
{
	public enum PuzzleKind
	{
		CompleteTheLine,
		TypeSequence,
		PickFix,
		GovDbBypass
	}

	public PuzzleKind Kind { get; }
	public string Prompt { get; }
	public string Answer { get; }
	public float TimeLimitSeconds { get; }
	public TimeSince Started { get; private set; }

	public bool IsExpired => Started.Relative >= TimeLimitSeconds;

	public HackerPuzzleSession( PuzzleKind kind, string prompt, string answer, float timeLimitSeconds )
	{
		Kind = kind;
		Prompt = prompt;
		Answer = answer;
		TimeLimitSeconds = timeLimitSeconds;
		Started = 0f;
	}

	public static HackerPuzzleSession CreateRandom( bool advancedTerminal = false )
	{
		if ( advancedTerminal )
		{
			return new HackerPuzzleSession(
				PuzzleKind.GovDbBypass,
				"Bypass treasury firewall — type the intrusion token:",
				"govdb_breach",
				40f );
		}

		var roll = Random.Shared.Int( 0, 2 );
		return roll switch
		{
			0 => new HackerPuzzleSession(
				PuzzleKind.CompleteTheLine,
				"Complete the bypass line:\n  if (wallet.balance > 0) { __________ }",
				"drain(wallet);",
				45f ),
			1 => new HackerPuzzleSession(
				PuzzleKind.TypeSequence,
				"Type the exploit token within 30s:",
				"cornerman_bypass",
				30f ),
			_ => new HackerPuzzleSession(
				PuzzleKind.PickFix,
				"Pick the valid packet header (type the number):\n  1) CORNERMAN/1.0 OK\n  2) DXRP/HACK FREE\n  3) WALLET/OPEN ALL",
				"1",
				35f ),
		};
	}

	public bool TrySubmit( string input )
	{
		if ( IsExpired )
			return false;

		return string.Equals( input?.Trim(), Answer, StringComparison.OrdinalIgnoreCase );
	}

	public float SecondsRemaining => MathF.Max( 0f, TimeLimitSeconds - Started.Relative );
}
