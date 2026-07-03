// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Bitcoin Mining" (s&box ident: lifepunch.bitcoinmining · addon ident: bitcoinmining) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Author account: mrragerlp · Public alias (in-game · Steam · Discord): Bloodwave
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System;
using System.Collections.Generic;
using System.Linq;

namespace LifePunch.DXRP.Addons.BitcoinMining;

/// <summary>Parses hub → rig explicit link ids stored on <see cref="BitcoinMinerHubEntity.LinkedRigIds"/>.</summary>
internal static class BitcoinMinerHubLinkIds
{
	private const char Separator = '|';

	public static IReadOnlyList<Guid> Parse( string csv )
	{
		if ( string.IsNullOrWhiteSpace( csv ) )
			return Array.Empty<Guid>();

		var list = new List<Guid>();
		foreach ( var token in csv.Split( Separator, StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries ) )
		{
			if ( Guid.TryParse( token, out var id ) && id != Guid.Empty )
				list.Add( id );
		}

		return list;
	}

	public static string Serialize( IEnumerable<Guid> ids )
	{
		if ( ids is null )
			return "";

		return string.Join( Separator, ids.Where( id => id != Guid.Empty ).Select( id => id.ToString() ) );
	}
}
