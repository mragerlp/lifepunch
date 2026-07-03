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

namespace LifePunch.DXRP.Addons.HackerJob;

/// <summary>
/// Server rack access PIN — 4-digit operator lock. Hash stays host-only; never sync plaintext.
/// </summary>
internal static class HackerServerRackAccessPin
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

	public static ushort Hash( string pin, Guid rackId )
	{
		var h = 2166136261u;
		foreach ( var c in pin )
			h = ( h ^ c ) * 16777619u;

		h ^= (uint)rackId.GetHashCode();
		return (ushort)( h & 0xFFFF );
	}
}
