// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Hacker Job" (s&box ident: lifepunch.hackerjob · addon ident: hackerjob) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System;
using System.Collections.Generic;
using System.Linq;
using Sandbox;

namespace LifePunch.DXRP.Addons.HackerJob;

/// <summary>
/// Links <see cref="HackerServerRackEntity"/> to nearby hacker terminals for power + upgrades.
/// </summary>
public static class HackerServerRackRegistry
{
	private const float LinkHorizontalUnits = 8f * 39.3701f;
	private const float LinkVerticalUnits = 4f * 39.3701f;

	public static HackerServerRackEntity FindRackForTerminal( HackerTerminalEntity terminal )
	{
		if ( !terminal.IsValid() )
			return null;

		if ( terminal.LinkedRack.IsValid() )
			return terminal.LinkedRack;

		return FindNearestRack( terminal.Scene, terminal.WorldPosition );
	}

	public static HackerServerRackEntity FindNearestRack( Scene scene, Vector3 from )
	{
		if ( scene is null )
			return null;

		HackerServerRackEntity best = null;
		var bestHorizontal = float.MaxValue;

		foreach ( var rack in scene.GetAllComponents<HackerServerRackEntity>() )
		{
			if ( !rack.IsValid() )
				continue;

			if ( !IsInLinkRange( from, rack.WorldPosition, out var horizontal ) )
				continue;

			if ( horizontal < bestHorizontal )
			{
				bestHorizontal = horizontal;
				best = rack;
			}
		}

		return best;
	}

	public static IReadOnlyList<HackerTerminalEntity> GetLinkedTerminals( HackerServerRackEntity rack )
	{
		if ( !rack.IsValid() || rack.Scene is null )
			return Array.Empty<HackerTerminalEntity>();

		var list = new List<HackerTerminalEntity>();
		foreach ( var terminal in rack.Scene.GetAllComponents<HackerTerminalEntity>() )
		{
			if ( !terminal.IsValid() )
				continue;

			var linked = terminal.LinkedRack.IsValid() ? terminal.LinkedRack : FindNearestRack( rack.Scene, terminal.WorldPosition );
			if ( linked == rack )
				list.Add( terminal );
		}

		return list;
	}

	public static bool IsTerminalPowered( HackerTerminalEntity terminal )
	{
		var rack = FindRackForTerminal( terminal );
		return rack.IsValid() && rack.IsPowered;
	}

	public static bool IsInLinkRange( Vector3 from, Vector3 to, out float horizontalDistance )
	{
		var delta = to - from;
		horizontalDistance = new Vector3( delta.x, delta.y, 0f ).Length;
		var vertical = MathF.Abs( delta.z );
		return horizontalDistance <= LinkHorizontalUnits && vertical <= LinkVerticalUnits;
	}
}
