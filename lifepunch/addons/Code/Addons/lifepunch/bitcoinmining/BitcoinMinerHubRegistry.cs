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
/// Explicit hub ↔ GPU rack links via <see cref="BitcoinMinerHubEntity.LinkedRigIds"/> (no proximity auto-link).
/// </summary>
public static class BitcoinMinerHubRegistry
{
	public static BitcoinMinerHubEntity FindHubForRig( GpuRackEntity rig )
	{
		if ( !rig.IsValid() || rig.Scene is null )
			return null;

		foreach ( var hub in rig.Scene.GetAllComponents<BitcoinMinerHubEntity>() )
		{
			if ( !hub.IsValid() )
				continue;

			if ( BitcoinMinerHubLinkIds.Parse( hub.LinkedRigIds ).Contains( rig.GameObject.Id ) )
				return hub;
		}

		return null;
	}

	public static IReadOnlyList<GpuRackEntity> GetLinkedRacks( BitcoinMinerHubEntity hub )
	{
		if ( !hub.IsValid() || hub.Scene is null )
			return Array.Empty<GpuRackEntity>();

		var resolved = ResolveLinkedRigsInOrder( hub );
		var small = resolved.Where( r => !r.AdvancedRack ).Take( BitcoinMiningCombatStats.MaxSmallRacksPerHub ).ToList();
		var large = resolved.Where( r => r.AdvancedRack ).Take( BitcoinMiningCombatStats.MaxLargeRacksPerHub ).ToList();
		return small.Concat( large ).ToList();
	}

	public static IReadOnlyList<GpuRackEntity> ResolveLinkedRigsInOrder( BitcoinMinerHubEntity hub )
	{
		if ( !hub.IsValid() || hub.Scene is null )
			return Array.Empty<GpuRackEntity>();

		var rigsById = hub.Scene.GetAllComponents<GpuRackEntity>()
			.Where( r => r.IsValid() )
			.ToDictionary( r => r.GameObject.Id, r => r );

		var ordered = new List<GpuRackEntity>();
		foreach ( var id in BitcoinMinerHubLinkIds.Parse( hub.LinkedRigIds ) )
		{
			if ( rigsById.TryGetValue( id, out var rig ) && rig.IsValid() && SharesHubOwner( hub, rig ) )
				ordered.Add( rig );
		}

		return ordered;
	}

	/// <summary>Owner rigs in the scene that are not linked to any hub yet.</summary>
	public static IReadOnlyList<GpuRackEntity> ScanUnlinkedRigs( BitcoinMinerHubEntity hub )
	{
		if ( !hub.IsValid() || hub.Scene is null )
			return Array.Empty<GpuRackEntity>();

		var list = new List<GpuRackEntity>();
		foreach ( var rig in hub.Scene.GetAllComponents<GpuRackEntity>() )
		{
			if ( !rig.IsValid() || !SharesHubOwner( hub, rig ) || IsRigLinkedAnywhere( rig ) )
				continue;

			list.Add( rig );
		}

		return list
			.OrderBy( r => r.AdvancedRack )
			.ThenBy( r => r.GameObject.Name )
			.ToList();
	}

	public static bool TryLinkRig( BitcoinMinerHubEntity hub, GpuRackEntity rig, out string error )
	{
		error = null;

		if ( !hub.IsValid() || !rig.IsValid() )
		{
			error = "Invalid hub or rack.";
			return false;
		}

		if ( !SharesHubOwner( hub, rig ) )
		{
			error = "Rack owner does not match this hub.";
			return false;
		}

		var ids = BitcoinMinerHubLinkIds.Parse( hub.LinkedRigIds ).ToList();
		if ( ids.Contains( rig.GameObject.Id ) )
		{
			error = "Rack already linked to this hub.";
			return false;
		}

		if ( IsRigLinkedAnywhere( rig ) )
		{
			error = "Rack is linked to another hub — unlink first.";
			return false;
		}

		var projected = ResolveIdsToRigs( hub, ids );
		projected.Add( rig );

		if ( !CanAcceptRig( projected, rig, out error ) )
			return false;

		ids.Add( rig.GameObject.Id );
		hub.LinkedRigIds = BitcoinMinerHubLinkIds.Serialize( ids );
		return true;
	}

	public static bool TryUnlinkRigAt( BitcoinMinerHubEntity hub, int index, out string error )
	{
		error = null;
		var linked = ResolveLinkedRigsInOrder( hub ).ToList();
		if ( index < 0 || index >= linked.Count )
		{
			error = "Invalid link index — run 'link' to list.";
			return false;
		}

		var removeId = linked[index].GameObject.Id;
		var ids = BitcoinMinerHubLinkIds.Parse( hub.LinkedRigIds ).Where( id => id != removeId ).ToList();
		hub.LinkedRigIds = BitcoinMinerHubLinkIds.Serialize( ids );
		return true;
	}

	public static void UnlinkAll( BitcoinMinerHubEntity hub )
	{
		if ( !hub.IsValid() )
			return;

		hub.LinkedRigIds = "";
	}

	public static int CountHubs( Scene scene )
	{
		if ( scene is null )
			return 0;

		return scene.GetAllComponents<BitcoinMinerHubEntity>().Count( h => h.IsValid() );
	}

	/// <summary>Human-readable link summary for hashd rail.</summary>
	public static string DescribeLinkedRacks( IReadOnlyList<GpuRackEntity> racks )
	{
		if ( racks == null || racks.Count == 0 )
			return "none — use LINK at rig0>";

		var small = racks.Count( r => r.IsValid() && !r.AdvancedRack );
		var large = racks.Count( r => r.IsValid() && r.AdvancedRack );
		var parts = new List<string>();
		if ( small > 0 )
			parts.Add( $"{small}× {BitcoinMiningAddon.DisplayName}" );
		if ( large > 0 )
			parts.Add( $"{large}× {BitcoinMiningAddon.AdvancedDisplayName}" );

		return string.Join( " · ", parts );
	}

	public static string GetRigLabel( GpuRackEntity rig ) =>
		rig.IsValid()
			? ( rig.AdvancedRack ? BitcoinMiningAddon.AdvancedDisplayName : BitcoinMiningAddon.DisplayName ) + $" ({rig.GameObject.Name})"
			: "rack";

	/// <summary>Only the spawner's racks link to their hub — prevents neighbor rack hijack.</summary>
	internal static bool SharesHubOwner( BitcoinMinerHubEntity hub, GpuRackEntity rig )
	{
#if LIFEPUNCH_LOCAL
		return true;
#else
		if ( !hub.IsValid() || !rig.IsValid() )
			return false;

		if ( hub.Owner == 0 || rig.Owner == 0 )
			return hub.Owner == rig.Owner;

		return hub.Owner == rig.Owner;
#endif
	}

	private static bool IsRigLinkedAnywhere( GpuRackEntity rig )
	{
		if ( !rig.IsValid() || rig.Scene is null )
			return false;

		foreach ( var hub in rig.Scene.GetAllComponents<BitcoinMinerHubEntity>() )
		{
			if ( !hub.IsValid() )
				continue;

			if ( BitcoinMinerHubLinkIds.Parse( hub.LinkedRigIds ).Contains( rig.GameObject.Id ) )
				return true;
		}

		return false;
	}

	private static List<GpuRackEntity> ResolveIdsToRigs( BitcoinMinerHubEntity hub, IReadOnlyList<Guid> ids )
	{
		var rigsById = hub.Scene.GetAllComponents<GpuRackEntity>()
			.Where( r => r.IsValid() )
			.ToDictionary( r => r.GameObject.Id, r => r );

		var list = new List<GpuRackEntity>();
		foreach ( var id in ids )
		{
			if ( rigsById.TryGetValue( id, out var rig ) && rig.IsValid() )
				list.Add( rig );
		}

		return list;
	}

	private static bool CanAcceptRig( IReadOnlyList<GpuRackEntity> projected, GpuRackEntity rig, out string error )
	{
		error = null;
		var small = projected.Count( r => !r.AdvancedRack );
		var large = projected.Count( r => r.AdvancedRack );

		if ( rig.AdvancedRack && large > BitcoinMiningCombatStats.MaxLargeRacksPerHub )
		{
			error = $"Cap: {BitcoinMiningCombatStats.MaxLargeRacksPerHub}× {BitcoinMiningAddon.AdvancedDisplayName}.";
			return false;
		}

		if ( !rig.AdvancedRack && small > BitcoinMiningCombatStats.MaxSmallRacksPerHub )
		{
			error = $"Cap: {BitcoinMiningCombatStats.MaxSmallRacksPerHub}× {BitcoinMiningAddon.DisplayName}.";
			return false;
		}

		return true;
	}
}
