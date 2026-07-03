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
using Sandbox;

namespace LifePunch.DXRP.Addons.BitcoinMining;

/// <summary>
/// Client-side rig list for hashd — scans <see cref="GpuRackEntity"/> rigs near the terminal anchor.
/// Phase 1: local selection only. Host still validates per-rig RPCs on each entity.
/// </summary>
internal static class GpuRackRegistry
{
	private const float MetersToUnits = 39.3701f;
	private const float LinkHorizontalUnits = 4f * MetersToUnits;
	private const float LinkVerticalUnits = 2f * MetersToUnits;

	private static readonly List<GpuRackEntity> Registered = new();
	private static int _selectedIndex;
	private static BitcoinMinerHubEntity _activeHub;

	public static BitcoinMinerHubEntity ActiveHub => _activeHub.IsValid() ? _activeHub : null;

	public static IReadOnlyList<GpuRackEntity> RegisteredRigs => Registered;

	public static GpuRackEntity SelectedRig =>
		_selectedIndex >= 0 && _selectedIndex < Registered.Count ? Registered[_selectedIndex] : null;

	public static int SelectedIndex => _selectedIndex;

	public static void Refresh( Scene scene, Vector3 anchor )
	{
		_activeHub = null;
		RefreshInternal( scene, anchor, null );
	}

	public static void RefreshFromHub( Scene scene, BitcoinMinerHubEntity hub )
	{
		if ( !hub.IsValid() )
		{
			_activeHub = null;
			Registered.Clear();
			_selectedIndex = 0;
			return;
		}

		_activeHub = hub;
		RefreshInternal( scene, hub.WorldPosition, hub );
	}

	public static void RefreshFromHub( BitcoinMinerHubEntity hub ) =>
		RefreshFromHub( Game.ActiveScene, hub );

	private static void RefreshInternal( Scene scene, Vector3 anchor, BitcoinMinerHubEntity hub )
	{
		Registered.Clear();
		_selectedIndex = 0;

		if ( scene is null )
			return;

		if ( hub.IsValid() )
		{
			foreach ( var rig in BitcoinMinerHubRegistry.GetLinkedRacks( hub ) )
			{
				if ( rig.IsValid() )
					Registered.Add( rig );
			}

			return;
		}

		var candidates = new List<(GpuRackEntity rig, float horizontal)>();

		foreach ( var rig in scene.GetAllComponents<GpuRackEntity>() )
		{
			if ( !rig.IsValid() || !rig.GameObject.IsValid() )
				continue;

			var delta = rig.WorldPosition - anchor;
			var horizontal = new Vector3( delta.x, delta.y, 0f ).Length;
			var vertical = MathF.Abs( delta.z );

			if ( horizontal > LinkHorizontalUnits || vertical > LinkVerticalUnits )
				continue;

			candidates.Add( (rig, horizontal) );
		}

		foreach ( var pair in candidates.OrderBy( c => c.horizontal ) )
			Registered.Add( pair.rig );
	}

	public static bool TrySelect( int index )
	{
		if ( index < 0 || index >= Registered.Count )
			return false;

		_selectedIndex = index;
		return true;
	}

	public static bool TrySelect( GpuRackEntity rig )
	{
		if ( !rig.IsValid() )
			return false;

		var index = Registered.IndexOf( rig );
		if ( index < 0 )
			return false;

		_selectedIndex = index;
		return true;
	}

	public static string GetRigTypeLabel( GpuRackEntity rig ) =>
		rig.IsValid() && rig.AdvancedRack ? BitcoinMiningAddon.AdvancedDisplayName : BitcoinMiningAddon.DisplayName;

	public static string GetRigStatusLabel( GpuRackEntity rig ) =>
		rig.IsValid() && rig.IsMining ? "MINING" : "IDLE";
}
