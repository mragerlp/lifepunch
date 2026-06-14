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

using System.Collections.Generic;
using LifePunch.DXRP.Addons;

namespace LifePunch.DXRP.Addons.HackerJob;

/// <summary>UI chrome tokens per hacker terminal tier (mirrors LifePunch Ops machine uniforms).</summary>
public static class HackerTerminalBrand
{
	public static string TitleBar( HackerTerminalTier tier ) => tier switch
	{
		HackerTerminalTier.Advanced => "LIFEPUNCH vengeance.exe v0.1 — vengeance@terminal",
		_ => "LIFEPUNCH cornerman.exe v0.1 — cornerman@terminal"
	};

	public static string PromptLabel( HackerTerminalTier tier ) => tier switch
	{
		HackerTerminalTier.Advanced => "vengeance@terminal:~$",
		_ => "cornerman@terminal:~$"
	};

	public static string ProgramName( HackerTerminalTier tier ) => tier switch
	{
		HackerTerminalTier.Advanced => HackerJob.AdvancedProgramName,
		_ => HackerJob.InGameProgramName
	};

	public static string CssTierClass( HackerTerminalTier tier ) => tier switch
	{
		HackerTerminalTier.Advanced => "tier-advanced",
		_ => "tier-standard"
	};

	public static string OpsConsoleTitle( HackerTerminalTier tier ) => tier switch
	{
		HackerTerminalTier.Advanced => "VENGEANCE OPS CONSOLE",
		_ => "CORNERMAN OPS CONSOLE"
	};

	public static string OpsConsoleMark( HackerTerminalTier tier ) => tier switch
	{
		HackerTerminalTier.Advanced => "▲",
		_ => "◆"
	};

	/// <summary>Shipped About copy — LIFEPUNCH source only; no third-party product credits.</summary>
	public static string[] AboutLines( HackerTerminalTier tier )
	{
		var lines = new List<string>( LifePunchSourceMark.AboutBlock( HackerJob.ProductTitle ) )
		{
			"cornerman.exe / vengeance.exe are in-world fiction — not third-party software.",
			"Wallet hacks: host-validated only. Bank accounts are never touched."
		};

		if ( tier == HackerTerminalTier.Advanced )
			lines.Add( "Govdb breaches countered by Police terminals (lifepunchnet cyan)." );

		return lines.ToArray();
	}
}
