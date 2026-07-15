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

using Sandbox;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
#endif

namespace LifePunch.DXRP.Addons.HackerJob;

/// <summary>
/// Tracks whether a player is logged into an ops program (cornerman.exe / vengeance.exe).
/// Hack commands run only through <see cref="HackerTerminal"/> ops console input — see
/// <c>docs/TERMINAL_SESSION_DOCTRINE.md</c>.
/// </summary>
internal static class HackerTerminalSession
{
	/// <summary>True when the local ops console UI is mounted (player is "logged in").</summary>
	public static bool IsLoggedIn => HackerTerminalHost.IsOpen;

	/// <summary>Whether ops commands (scan, hack, govdb, infil) may run from the program prompt.</summary>
	public static bool CanRunOpsCommand( HackerTerminalEntity terminal, out string denyReason )
	{
		if ( !IsLoggedIn )
		{
			denyReason = "not logged in — USE the Hacker Terminal and wait for cornerman.exe / vengeance.exe";
			return false;
		}

		if ( !terminal.IsValid() )
		{
			denyReason = "terminal link lost";
			return false;
		}

		var isDevStub = terminal.GameObject.Name.Contains( "DevStub" );
		if ( !isDevStub && !terminal.IsPowered )
		{
			denyReason = "terminal offline — power ON the Server Rack first";
			return false;
		}

		if ( !IsHackerJob( terminal.Tier, out var jobDeny ) )
		{
			denyReason = jobDeny;
			return false;
		}

		denyReason = null;
		return true;
	}

	/// <summary>DXRP job gate — deny until Bloodwave rules and T2 defines the Hacker job row.</summary>
	private static bool IsHackerJob( HackerTerminalTier terminalTier, out string denyReason )
	{
#if LIFEPUNCH_LOCAL
		_ = terminalTier;
		denyReason = null;
		return true;
#else
		if ( !Player.Local.IsValid() )
		{
			denyReason = "no local player";
			return false;
		}

		_ = terminalTier;
		denyReason = "hacker job unavailable — T2 job row not configured";
		return false;
#endif
	}
}
