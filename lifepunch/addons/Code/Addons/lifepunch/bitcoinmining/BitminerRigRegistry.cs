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
/// Client-side rig list for hashd — scans <see cref="BitminerEntity"/> rigs near the terminal anchor.
/// Phase 1: local selection only. Host still validates per-rig RPCs on each entity.
/// </summary>
internal static class BitminerRigRegistry
{
	private const float MetersToUnits = 39.3701f;
	private const float LinkHorizontalUnits = 4f * MetersToUnits;
	private const float LinkVerticalUnits = 2f * MetersToUnits;

	private static readonly List<BitminerEntity> Registered = new();
	private static int _selectedIndex;

	public static IReadOnlyList<BitminerEntity> RegisteredRigs => Registered;

	public static BitminerEntity SelectedRig =>
		_selectedIndex >= 0 && _selectedIndex < Registered.Count ? Registered[_selectedIndex] : null;

	public static int SelectedIndex => _selectedIndex;

	public static void Refresh( Scene scene, Vector3 anchor )
	{
		Registered.Clear();
		_selectedIndex = 0;

		if ( scene is null )
			return;

		var candidates = new List<(BitminerEntity rig, float horizontal)>();

		foreach ( var rig in scene.GetAllComponents<BitminerEntity>() )
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

	public static bool TrySelect( BitminerEntity rig )
	{
		if ( !rig.IsValid() )
			return false;

		var index = Registered.IndexOf( rig );
		if ( index < 0 )
			return false;

		_selectedIndex = index;
		return true;
	}

	public static string GetRigTypeLabel( BitminerEntity rig ) =>
		rig.IsValid() && rig.AdvancedRack ? "ADVANCED" : "SMALL";

	public static string GetRigStatusLabel( BitminerEntity rig ) =>
		rig.IsValid() && rig.IsMining ? "MINING" : "IDLE";
}
