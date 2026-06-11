// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Visible Pocket for DXRP" (s&box ident: lifepunch.visiblepocket · addon ident: visiblepocket) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
using Dxura.RP.Game.Equipments;
using Dxura.RP.Shared;
using Sandbox;

namespace LifePunch.DXRP.Addons.VisiblePocket;

/// <summary>
/// Routes hands attack2 pocket input through LifePunch policy pickup before stock DXRP handler runs.
/// </summary>
internal sealed class VisiblePocketInputBridge : Component
{
	protected override void OnUpdate()
	{
		if ( !Config.Current.Game.PocketEnabled )
		{
			return;
		}

		var player = Player.Local;
		if ( !player.IsValid() )
		{
			return;
		}

		if ( !Input.Pressed( "attack2" ) )
		{
			return;
		}

		if ( Cooldown.Current.CheckAndStartCooldown( "pocket", Config.Current.Game.PocketCooldown, true ) )
		{
			return;
		}

		var trace = Scene.Trace.Ray( player.AimRay, Config.Current.Game.ReachDistance )
			.IgnoreGameObjectHierarchy( player.GameObject )
			.WithTag( Constants.EntityTag )
			.Run();

		if ( !trace.Hit || !trace.GameObject.IsValid() )
		{
			return;
		}

		var targetGo = trace.GameObject.Root;
		if ( !targetGo.IsValid() )
		{
			return;
		}

		if ( targetGo.Components.Get<IHandEvents>() != null )
		{
			return;
		}

		if ( targetGo.Tags.Has( Constants.PocketItemTag ) && !targetGo.Tags.Has( Constants.PocketTag ) )
		{
			VisiblePocketService.RequestPickup();
		}
		else
		{
			VisiblePocketService.RequestDrop();
		}

		Input.Clear( "attack2" );
		Input.Clear( "Pocket" );
	}
}
#endif
