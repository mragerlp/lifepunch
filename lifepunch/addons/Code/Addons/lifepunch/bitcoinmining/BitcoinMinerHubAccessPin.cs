// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Bitcoin Mining" (s&box ident: lifepunch.bitcoinmining · addon ident: bitcoinmining) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System;

namespace LifePunch.DXRP.Addons.BitcoinMining;

/// <summary>
/// Hub access PIN helpers — 4-digit operator lock. Hash stays host-only; never sync plaintext.
/// </summary>
internal static class BitcoinMinerHubAccessPin
{
	public const int PinLength = 4;
	public const float SessionSeconds = 900f;

	public static bool IsValidFormat( string pin )
	{
		if ( string.IsNullOrEmpty( pin ) || pin.Length != PinLength )
			return false;

		foreach ( var c in pin )
		{
			if ( c < '0' || c > '9' )
				return false;
		}

		return true;
	}

	public static ushort Hash( string pin, Guid hubId )
	{
		var h = 2166136261u;
		foreach ( var c in pin )
			h = ( h ^ c ) * 16777619u;

		h ^= (uint)hubId.GetHashCode();
		return (ushort)( h & 0xFFFF );
	}

	public static string MaskPin( string pin )
	{
		if ( !IsValidFormat( pin ) )
			return "----";

		return new string( '*', PinLength );
	}
}
