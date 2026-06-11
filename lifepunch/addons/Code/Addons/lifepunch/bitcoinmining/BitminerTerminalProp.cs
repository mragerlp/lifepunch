// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Bitcoin Mining" (s&box ident: lifepunch.bitcoinmining · addon ident: bitcoinmining) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System.Linq;
using Sandbox;

namespace LifePunch.DXRP.Addons.BitcoinMining;

/// <summary>
/// Separate CRT/computer prop — links to a nearby <see cref="BitminerEntity"/> for LCD + hashd open.
/// Rack and terminal are distinct placeable entities; pair in editor or via <c>lp_spawn_bitminer_kit</c>.
/// </summary>
[Title( "Bitcoin Terminal (hashd CRT)" )]
[Category( "LifePunch/Bitcoin Mining" )]
public sealed class BitminerTerminalProp : Component, Component.IPressable
{
	private const float LinkHorizontalUnits = 4f * 39.3701f;
	private const float LinkVerticalUnits = 2f * 39.3701f;

	[Property] public BitminerEntity LinkedRig { get; set; }
	[Property] public TextRenderer ScreenText { get; set; }

	protected override void OnStart()
	{
		base.OnStart();
		TryAutoLink();
	}

	private void TryAutoLink()
	{
		if ( LinkedRig.IsValid() )
		{
			LinkedRig.BindScreen( ScreenText );
			return;
		}

		var nearest = FindNearestRig( WorldPosition );
		if ( !nearest.IsValid() )
			return;

		LinkedRig = nearest;
		LinkedRig.BindScreen( ScreenText );
	}

	public bool Press( IPressable.Event e )
	{
		TryAutoLink();
		BitminerCommandHost.OpenNearestTerminal();
		return true;
	}

	internal static BitminerEntity FindNearestRig( Vector3 from )
	{
		BitminerEntity best = null;
		var bestHorizontal = float.MaxValue;

		foreach ( var rig in Scene.GetAllComponents<BitminerEntity>() )
		{
			if ( !rig.IsValid() || !rig.GameObject.IsValid() )
				continue;

			var delta = rig.WorldPosition - from;
			var horizontal = new Vector3( delta.x, delta.y, 0f ).Length;
			var vertical = MathF.Abs( delta.z );

			if ( horizontal > LinkHorizontalUnits || vertical > LinkVerticalUnits )
				continue;

			if ( horizontal < bestHorizontal )
			{
				bestHorizontal = horizontal;
				best = rig;
			}
		}

		return best;
	}
}
