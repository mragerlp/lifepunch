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
using System.Linq;
using Sandbox;
using LifePunch.DXRP.Addons;

namespace LifePunch.DXRP.Addons.BitcoinMining;

/// <summary>
/// HASHD monitor ("head") — rig0 command console. Place on or beside the hub; LCD can mirror a linked GPU rack.
/// Hub body USE opens management rail; monitor USE opens typed commands. See <c>docs/BITCOINMINING_TERMINAL_DOCTRINE.md</c>.
/// </summary>
[Title( "Bitcoin Terminal (hashd CRT)" )]
[Category( "LifePunch/Bitcoin Miner" )]
public sealed class BitcoinTerminalProp : Component, Component.IPressable
{
	private const float LinkHorizontalUnits = 4f * 39.3701f;
	private const float LinkVerticalUnits = 2f * 39.3701f;

	[Property] public GpuRackEntity LinkedRig { get; set; }
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

		var nearest = FindNearestRig( Scene, WorldPosition );
		if ( !nearest.IsValid() )
			return;

		LinkedRig = nearest;
		LinkedRig.BindScreen( ScreenText );
	}

	public bool CanPress( IPressable.Event e ) => LifePunchMenuInteractGate.CanPressMenu( GameObject );

	public bool Press( IPressable.Event e )
	{
		TryAutoLink();

		var hub = FindNearestHub( Scene, WorldPosition );
		if ( !hub.IsValid() )
		{
			Log.Info( "[hashd] No Bitcoin Miner hub in range — place the monitor beside the hub." );
			return false;
		}

		hub.RequestOpenHeadConsole( GameObject );
		return true;
	}

	internal static bool IsWithinHubLinkRange( Vector3 from, Vector3 hubPosition )
	{
		var delta = from - hubPosition;
		var horizontal = new Vector3( delta.x, delta.y, 0f ).Length;
		var vertical = MathF.Abs( delta.z );
		return horizontal <= LinkHorizontalUnits && vertical <= LinkVerticalUnits;
	}

	internal static BitcoinMinerHubEntity FindNearestHub( Scene scene, Vector3 from )
	{
		if ( scene is null )
			return null;

		BitcoinMinerHubEntity best = null;
		var bestHorizontal = float.MaxValue;

		foreach ( var hub in scene.GetAllComponents<BitcoinMinerHubEntity>() )
		{
			if ( !hub.IsValid() || !hub.GameObject.IsValid() )
				continue;

			if ( !IsWithinHubLinkRange( from, hub.WorldPosition ) )
				continue;

			var delta = hub.WorldPosition - from;
			var horizontal = new Vector3( delta.x, delta.y, 0f ).Length;
			if ( horizontal < bestHorizontal )
			{
				bestHorizontal = horizontal;
				best = hub;
			}
		}

		return best;
	}

	internal static GpuRackEntity FindNearestRig( Scene scene, Vector3 from )
	{
		if ( scene is null )
			return null;

		GpuRackEntity best = null;
		var bestHorizontal = float.MaxValue;

		foreach ( var rig in scene.GetAllComponents<GpuRackEntity>() )
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
