// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// ─────────────────────────────────────────────────────────────────────────────

using System.Linq;

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>Hub access PIN — fiction gate, not banking-grade crypto.</summary>
internal static class LpBitcoinHubPin
{
	public const int MinDigits = 4;
	public const int MaxDigits = 6;

	public static bool IsValidFormat( string pin )
	{
		if ( string.IsNullOrEmpty( pin ) )
			return false;

		return pin.Length is >= MinDigits and <= MaxDigits && pin.All( char.IsDigit );
	}

	public static int Hash( string pin ) => pin?.GetHashCode() ?? 0;

	public static bool Matches( string pin, int storedHash )
		=> IsValidFormat( pin ) && Hash( pin ) == storedHash;
}
