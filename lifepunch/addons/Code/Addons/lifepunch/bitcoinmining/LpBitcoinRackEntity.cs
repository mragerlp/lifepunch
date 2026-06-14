// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// is the sole-owned intellectual property of lifepunch.co. It is NOT licensed for resale,
// redistribution, sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Author account: mrragerlp · Public alias (in-game · Steam · Discord): Bloodwave
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System;
using Sandbox;

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>Greenfield v2 GPU rack satellite — yield multiplier for linked hub.</summary>
[Title( "LIFEPUNCH Bitcoin Rack (v2)" )]
[Category( "LifePunch/Bitcoin" )]
#if LIFEPUNCH_LOCAL
public sealed class LpBitcoinRackEntity : Component
#else
public sealed class LpBitcoinRackEntity : BaseEntity
#endif
{
	[Property] public bool LargeRack { get; set; }

	public float YieldMultiplier => LargeRack ? 2f : 1f;

	[Sync( SyncFlags.FromHost )] public Guid LinkedHubId { get; set; }

	public void LinkToHub( LpBitcoinHubEntity hub )
	{
		if ( !hub.IsValid() )
			return;

		LinkedHubId = hub.GameObject.Id;
		hub.RackYieldMultiplier = Math.Max( hub.RackYieldMultiplier, YieldMultiplier );
	}
}
