// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// ─────────────────────────────────────────────────────────────────────────────

using System.Linq;
using System.Security.Cryptography;
using System.Text;

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>Hub access PIN — fiction gate, not banking-grade crypto.</summary>
internal static class LpBitcoinHubPin
{
	public const int MinDigits = 4;
	public const int MaxDigits = 4;

	public static bool IsValidFormat( string pin )
	{
		if ( string.IsNullOrEmpty( pin ) )
			return false;

		return pin.Length is >= MinDigits and <= MaxDigits && pin.All( char.IsDigit );
	}

	/// <summary>Per-hub random salt (host-side, never replicated). Defeats cross-hub hash equality
	/// and precomputed-table attacks if the digest ever leaks by another path (log / snapshot export).</summary>
	public static string NewSalt() => System.Guid.NewGuid().ToString( "N" );

	/// <summary>Stable, deterministic-across-processes salted digest. Replaces String.GetHashCode(),
	/// which is RANDOMIZED PER PROCESS in modern .NET — the C3 restart-lockout bug (Green AE1). The
	/// digest is HOST-ONLY: it is never [Sync]'d to clients, so the 10k-keyspace brute-force (P2) has
	/// no material to attack.</summary>
	public static string Hash( string pin, string salt )
	{
		var bytes = SHA256.HashData( Encoding.UTF8.GetBytes( ( salt ?? string.Empty ) + ":" + ( pin ?? string.Empty ) ) );
		return System.Convert.ToHexString( bytes );
	}

	public static bool Matches( string pin, string salt, string storedDigest )
		=> IsValidFormat( pin )
		   && !string.IsNullOrEmpty( storedDigest )
		   && Hash( pin, salt ) == storedDigest;
}
