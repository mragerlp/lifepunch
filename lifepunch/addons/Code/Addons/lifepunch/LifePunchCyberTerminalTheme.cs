// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH DXRP Addons" (s&box ident: lifepunch.* · addon ident: lifepunch) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System.Collections.Generic;

namespace LifePunch.DXRP.Addons;

/// <summary>
/// Shared Cyber Hacker Simulator–style terminal shell (home grid + module screens + footer log).
/// Reference: Cyber Hacker Simulator (Microsoft Store 9nvc5p0bphgr) — layout only; LIFEPUNCH™ branding per job.
/// Canon: addons/docs/branding/CYBER_TERMINAL_SHELL_SPEC.md
/// </summary>
public enum LifePunchCyberScreen
{
	Home,
	Terminal,
	Network,
	Decrypt,
	Dashboard
}

public readonly record struct LifePunchCyberModuleCard(
	string Title,
	string Description,
	LifePunchCyberScreen Screen,
	string IconMaterial );

public static class LifePunchCyberTerminalTheme
{
	public static string ScreenTitle( string brandSlug, LifePunchCyberScreen screen ) => screen switch
	{
		LifePunchCyberScreen.Home => brandSlug,
		LifePunchCyberScreen.Terminal => $"{brandSlug} TERMINAL",
		LifePunchCyberScreen.Network => $"{brandSlug} NETWORK",
		LifePunchCyberScreen.Decrypt => $"{brandSlug} DECRYPT",
		LifePunchCyberScreen.Dashboard => $"{brandSlug} DASHBOARD",
		_ => brandSlug
	};

	public static string WelcomeLine( string brandDisplay ) => $"WELCOME TO {brandDisplay}";

	public static string BootSubtitle( string programName ) =>
		$"Initializing {programName} environment...";

	/// <summary>
	/// In-fiction ops header only — LifePunch Official (lifepunchnet) public host.
	/// Never derived from the player machine, LAN, or connection metadata.
	/// </summary>
	public const string FictionOpsHostIp = "205.209.104.22";
}
