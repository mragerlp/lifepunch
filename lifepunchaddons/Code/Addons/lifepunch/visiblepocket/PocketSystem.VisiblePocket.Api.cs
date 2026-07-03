// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Visible Pocket for DXRP" (s&box ident: lifepunch.visiblepocket · addon ident: visiblepocket) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Author account: mrragerlp · Public alias (in-game · Steam · Discord): Bloodwave
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

#if !LIFEPUNCH_LOCAL
using System;
using System.Collections.Generic;
using Sandbox;

namespace Dxura.RP.Game;

/// <summary>
/// LifePunch Visible Pocket host accessors — requires <c>PocketSystem</c> declared <c>partial</c> in DXRP core.
/// </summary>
public partial class PocketSystem
{
	public int GetPocketCount( long steamId )
	{
		return Pockets.TryGetValue( steamId, out var pocket ) ? pocket.Count : 0;
	}

	public IReadOnlyList<GameObject> GetPocketItems( long steamId )
	{
		if ( !Pockets.TryGetValue( steamId, out var pocket ) || pocket.Count == 0 )
			return Array.Empty<GameObject>();

		return pocket;
	}

	public List<GameObject> GetOrCreatePocket( long steamId )
	{
		if ( !Pockets.TryGetValue( steamId, out var pocket ) )
		{
			pocket = new List<GameObject>();
			Pockets[steamId] = pocket;
		}

		return pocket;
	}
}
#endif
