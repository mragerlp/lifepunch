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
using System.Collections.Generic;
using Sandbox;

namespace LifePunch.DXRP.Addons.HackerJob;

/// <summary>Which class of target an intrusion session attacks. Mirrors <see cref="HackerHackTarget"/>.</summary>
public enum HackerIntrusionTargetClass
{
	Wallet,
	Hashd,
	GovDb
}

/// <summary>
/// HK-S2 — host-authoritative intrusion sessions for the Hacker ops console.
/// Closes TECH_DEBT HACKER-01 (client-guess success UX) and HACKER-02 (client-chosen puzzle kind):
/// the host issues the session id AND the puzzle, stores the expected answer server-side, and the
/// client renders only what the host returns.
///
/// MONEY-DISABLED BY LAW (issue #152): a validated success emits a PLACEHOLDER THEFT EVENT only —
/// a log line and a caller-visible message. No wallet, bank, or BTC value is read for mutation and
/// none is moved. HK-S4 swap point is marked in <see cref="Submit"/>; the wallets-never-bank rail
/// (Rail 3, <c>CYBER_ECONOMY_RAILS.md</c>) binds any future replacement.
///
/// Trace/heat counterplay: every session carries trace heat. Wrong submissions add heat; reaching
/// <see cref="TraceHeatThreshold"/> terminates the session as TRACED and fires the existing
/// <see cref="HackerCounterplayService"/> roll. Session expiry does the same. Per-hacker-per-target
/// cooldowns (rack-tuned) gate re-targeting.
///
/// Tunables below are Phase-1 constants on purpose — HK-S3 owns config extraction (#153).
/// </summary>
public static class HackerIntrusionService
{
	// ── HK-S3 extraction candidates (hardcoded Phase-1 baseline) ──
	/// <summary>Heat every session starts with — the uplink is never fully cold.</summary>
	public const int BaseHeat = 15;
	/// <summary>Heat added by each rejected submission.</summary>
	public const int WrongSubmitHeat = 25;
	/// <summary>Heat at or above which the session is traced and counterplay fires.</summary>
	public const int TraceHeatThreshold = 100;

	public sealed class IntrusionSession
	{
		public Guid SessionId { get; init; }
		public Guid OwnerConnectionId { get; init; }
		public string TargetId { get; init; }
		public HackerIntrusionTargetClass TargetClass { get; init; }
		public HackerPuzzleSession.PuzzleKind Kind { get; init; }
		public string Prompt { get; init; }
		public string ExpectedAnswer { get; init; }
		public float TimeLimitSeconds { get; init; }
		public TimeSince Started { get; set; }
		public int Heat { get; set; }

		public bool IsExpired => Started.Relative > TimeLimitSeconds + 0.25f;
	}

	public readonly record struct BeginResult(
		bool Ok, Guid SessionId, int PuzzleKind, string Prompt, float TimeLimitSeconds, int Heat, string Message )
	{
		public static BeginResult Denied( string message ) => new( false, Guid.Empty, 0, "", 0f, 0, message );
	}

	public readonly record struct SubmitResult(
		bool Success, bool Terminated, int Heat, bool Traced, string Message )
	{
		public static SubmitResult Rejected( int heat, string message ) => new( false, false, heat, false, message );
		public static SubmitResult Dead( string message ) => new( false, true, 0, false, message );
	}

	private static readonly Dictionary<Guid, IntrusionSession> Sessions = new();
	private static readonly Dictionary<(Guid Owner, string TargetId), TimeSince> Cooldowns = new();

	/// <summary>Active session for a caller, or null. One live intrusion per operator.</summary>
	public static IntrusionSession FindByOwner( Guid ownerConnectionId )
	{
		foreach ( var session in Sessions.Values )
		{
			if ( session.OwnerConnectionId == ownerConnectionId )
				return session;
		}

		return null;
	}

	/// <summary>
	/// Host-issued session start. Enforces one-session-per-operator and the per-target cooldown,
	/// then generates the puzzle HOST-SIDE (kind + expected answer never chosen by the client).
	/// </summary>
	public static BeginResult Begin(
		Guid ownerConnectionId,
		string targetId,
		HackerIntrusionTargetClass targetClass,
		bool advancedTerminal,
		float timeLimitSeconds,
		float cooldownSeconds )
	{
		if ( string.IsNullOrWhiteSpace( targetId ) )
			return BeginResult.Denied( "invalid target" );

		var existing = FindByOwner( ownerConnectionId );
		if ( existing is not null && !existing.IsExpired )
			return BeginResult.Denied( "intrusion already active — finish or abort it first" );

		if ( existing is not null )
			Sessions.Remove( existing.SessionId );

		if ( Cooldowns.TryGetValue( (ownerConnectionId, targetId), out var since ) && since.Relative < cooldownSeconds )
		{
			var wait = MathF.Ceiling( cooldownSeconds - since.Relative );
			return BeginResult.Denied( $"target uplink cooling down — {wait}s remaining" );
		}

		var puzzle = HackerPuzzleSession.CreateRandom( advancedTerminal, timeLimitSeconds );
		var session = new IntrusionSession
		{
			SessionId = Guid.NewGuid(),
			OwnerConnectionId = ownerConnectionId,
			TargetId = targetId,
			TargetClass = targetClass,
			Kind = puzzle.Kind,
			Prompt = puzzle.Prompt,
			ExpectedAnswer = puzzle.Answer,
			TimeLimitSeconds = timeLimitSeconds,
			Started = 0f,
			Heat = BaseHeat
		};

		Sessions[session.SessionId] = session;
		Log.Info( $"[LIFEPUNCH Hacker] intrusion session issued — id={session.SessionId} class={targetClass} target={targetId}" );
		return new BeginResult( true, session.SessionId, (int)session.Kind, session.Prompt, session.TimeLimitSeconds, session.Heat, "uplink established" );
	}

	/// <summary>
	/// Host verdict on a submitted answer. Success emits a placeholder theft event ONLY.
	/// Wrong answers add trace heat; the threshold or expiry terminates the session.
	/// </summary>
	public static SubmitResult Submit( Guid sessionId, Guid callerConnectionId, string answer )
	{
		if ( !Sessions.TryGetValue( sessionId, out var session ) )
			return SubmitResult.Dead( "no active intrusion session" );

		if ( session.OwnerConnectionId != callerConnectionId )
			return SubmitResult.Dead( "session owner mismatch — request rejected" );

		if ( session.IsExpired )
		{
			Terminate( session, startCooldown: true );
			return new SubmitResult( false, true, session.Heat, false, "uplink window expired — connection dropped" );
		}

		var valid = HackerEconomySecurity.ValidatePuzzleOnHost(
			session.Kind,
			answer,
			advancedTerminal: session.Kind == HackerPuzzleSession.PuzzleKind.GovDbBypass,
			session.Started.Relative,
			session.TimeLimitSeconds );

		if ( !valid )
		{
			session.Heat += WrongSubmitHeat;
			if ( session.Heat >= TraceHeatThreshold )
			{
				Terminate( session, startCooldown: true );
				return new SubmitResult( false, true, session.Heat, true, "TRACE COMPLETE — countermeasures triggered" );
			}

			return SubmitResult.Rejected( session.Heat, $"checksum rejected — trace heat {session.Heat}%" );
		}

		// ── HK-S4 SWAP POINT (the ONLY place a real transfer may ever land) ──
		// Replace this placeholder event with the atomic HackerEconomySecurity transfer once #154
		// is ruled (atomicity + victim-protection). Until then: log + message, zero value moved.
		Log.Info( $"[LIFEPUNCH Hacker] THEFT EVENT (placeholder) — class={session.TargetClass} target={session.TargetId} heat={session.Heat} — no funds moved" );
		Terminate( session, startCooldown: true );
		return new SubmitResult( true, true, session.Heat, false, "THEFT EVENT logged (placeholder) — no funds moved; economy = HK-S4" );
	}

	/// <summary>
	/// Caller-initiated end of session: <paramref name="expired"/> = the client-side timer ran out
	/// (counts as a failed intrusion, counterplay eligible); otherwise a voluntary abort
	/// (no counterplay, but the target cooldown still applies — bailing is not free retargeting).
	/// </summary>
	public static SubmitResult Abandon( Guid sessionId, Guid callerConnectionId, bool expired )
	{
		if ( !Sessions.TryGetValue( sessionId, out var session ) )
			return SubmitResult.Dead( "no active intrusion session" );

		if ( session.OwnerConnectionId != callerConnectionId )
			return SubmitResult.Dead( "session owner mismatch — request rejected" );

		Terminate( session, startCooldown: true );

		return expired || session.IsExpired
			? new SubmitResult( false, true, session.Heat, false, "uplink window expired — trace risk increased" )
			: new SubmitResult( false, true, session.Heat, false, "intrusion aborted — uplink closed" );
	}

	private static void Terminate( IntrusionSession session, bool startCooldown )
	{
		Sessions.Remove( session.SessionId );
		if ( startCooldown )
			Cooldowns[(session.OwnerConnectionId, session.TargetId)] = 0f;
	}
}
