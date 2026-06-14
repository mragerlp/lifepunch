// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// ─────────────────────────────────────────────────────────────────────────────

using System.Linq;
using Sandbox;

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>CRT terminal prop — typed commands control linked GPU racks remotely.</summary>
[Title( "LIFEPUNCH Bitcoin Terminal (v2)" )]
[Category( "LifePunch/Bitcoin" )]
#if LIFEPUNCH_LOCAL
public sealed class LpBitcoinTerminalEntity : Component, Component.IPressable
#else
public sealed class LpBitcoinTerminalEntity : BaseEntity, Component.IPressable
#endif
{
	[Property] public float LinkRange { get; set; } = 512f;

	public bool Press( IPressable.Event e )
	{
		var hub = FindLinkedHub();
		if ( hub is null )
		{
			Log.Warning( "[lifepunch.bitcoin] No hub in range for terminal." );
			return false;
		}

		LpBitcoinTerminalUiHost.Open( hub );
		return true;
	}

	public void Hover( IPressable.Event e ) { }
	public void Blur( IPressable.Event e ) { }

	private LpBitcoinHubEntity FindLinkedHub()
	{
		var scene = GameObject.Scene ?? Game.ActiveScene;
		if ( scene is null )
			return null;

		LpBitcoinHubEntity best = null;
		var bestDist = float.MaxValue;

		foreach ( var hub in scene.GetAllComponents<LpBitcoinHubEntity>() )
		{
			if ( !hub.IsValid() )
				continue;

			var dist = hub.WorldPosition.Distance( WorldPosition );
			if ( dist > LinkRange || dist >= bestDist )
				continue;

			bestDist = dist;
			best = hub;
		}

		return best;
	}
}
