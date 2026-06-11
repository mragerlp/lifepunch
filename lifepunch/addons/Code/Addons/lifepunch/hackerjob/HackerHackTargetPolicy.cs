// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Hacker Job" (s&box ident: lifepunch.hackerjob · addon ident: hackerjob) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

namespace LifePunch.DXRP.Addons.HackerJob;

public enum HackerHackTarget
{
	Wallet,
	BitcoinMiner,
	GovernmentDataCenter
}

/// <summary>
/// Which terminal tier may attack which target class.
/// Standard (cornerman) = wallets only. Advanced (vengeance) = miners + govdb.
/// </summary>
public static class HackerHackTargetPolicy
{
	public static bool CanHack( HackerTerminalTier tier, HackerHackTarget target ) => target switch
	{
		HackerHackTarget.Wallet => true,
		HackerHackTarget.BitcoinMiner => tier == HackerTerminalTier.Advanced,
		HackerHackTarget.GovernmentDataCenter => tier == HackerTerminalTier.Advanced,
		_ => false
	};

	public static string DenyMessage( HackerTerminalTier tier, HackerHackTarget target )
	{
		if ( CanHack( tier, target ) )
			return null;

		return target switch
		{
			HackerHackTarget.BitcoinMiner =>
				"ERROR: Bitcoin Miner intrusion requires Advanced Hacking Terminal (vengeance.exe) on a powered rack.",
			HackerHackTarget.GovernmentDataCenter =>
				"ERROR: Government Data Center access requires Advanced Hacking Terminal (vengeance.exe) on a powered rack.",
			_ => "ERROR: target not authorized for this terminal tier."
		};
	}
}
