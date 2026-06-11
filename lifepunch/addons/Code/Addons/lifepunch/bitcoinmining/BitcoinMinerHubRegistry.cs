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
using System.Collections.Generic;
using System.Linq;
using Sandbox;

namespace LifePunch.DXRP.Addons.BitcoinMining;

/// <summary>
/// Links <see cref="BitcoinMinerHubEntity"/> to nearby <see cref="GpuRackEntity"/> racks (owner + proximity).
/// Host placement caps land in Phase 2.
/// </summary>
public static class BitcoinMinerHubRegistry
{
	private const float MetersToUnits = 39.3701f;
	private const float LinkHorizontalUnits = 8f * MetersToUnits;
	private const float LinkVerticalUnits = 4f * MetersToUnits;

	public static BitcoinMinerHubEntity FindHubForRig( GpuRackEntity rig )
	{
		if ( !rig.IsValid() || rig.Scene is null )
			return null;

		BitcoinMinerHubEntity best = null;
		var bestHorizontal = float.MaxValue;

		foreach ( var hub in rig.Scene.GetAllComponents<BitcoinMinerHubEntity>() )
		{
			if ( !hub.IsValid() )
				continue;

			if ( !IsInLinkRange( rig.WorldPosition, hub.WorldPosition, out var horizontal ) )
				continue;

			if ( horizontal < bestHorizontal )
			{
				bestHorizontal = horizontal;
				best = hub;
			}
		}

		return best;
	}

	public static IReadOnlyList<GpuRackEntity> GetLinkedRacks( BitcoinMinerHubEntity hub )
	{
		if ( !hub.IsValid() || hub.Scene is null )
			return Array.Empty<GpuRackEntity>();

		var small = new List<GpuRackEntity>();
		var large = new List<GpuRackEntity>();

		foreach ( var rig in hub.Scene.GetAllComponents<GpuRackEntity>() )
		{
			if ( !rig.IsValid() )
				continue;

			if ( !IsInLinkRange( rig.WorldPosition, hub.WorldPosition, out _ ) )
				continue;

			if ( rig.AdvancedRack )
				large.Add( rig );
			else
				small.Add( rig );
		}

		var ordered = small
			.OrderBy( r => ( r.WorldPosition - hub.WorldPosition ).Length )
			.Take( BitcoinMiningCombatStats.MaxSmallRacksPerHub )
			.Concat(
				large
					.OrderBy( r => ( r.WorldPosition - hub.WorldPosition ).Length )
					.Take( BitcoinMiningCombatStats.MaxLargeRacksPerHub ) )
			.ToList();

		return ordered;
	}

	public static int CountHubs( Scene scene )
	{
		if ( scene is null )
			return 0;

		return scene.GetAllComponents<BitcoinMinerHubEntity>().Count( h => h.IsValid() );
	}

	public static bool IsInLinkRange( Vector3 from, Vector3 to, out float horizontal )
	{
		var delta = from - to;
		horizontal = new Vector3( delta.x, delta.y, 0f ).Length;
		var vertical = MathF.Abs( delta.z );
		return horizontal <= LinkHorizontalUnits && vertical <= LinkVerticalUnits;
	}
}
