// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Visible Pocket for DXRP" (s&box ident: lifepunch.visiblepocket · addon ident: visiblepocket) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Author account: mrragerlp · Public alias (in-game · Steam · Discord): Bloodwave
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
using Dxura.RP.Game.Equipments;
using Dxura.RP.Shared;
using LifePunch.DXRP.Addons;
using Sandbox;

namespace LifePunch.DXRP.Addons.VisiblePocket;

/// <summary>
/// Hands replication layer on DXRP <see cref="HandsEquipment"/>:
/// Reload + Hands → pocket inventory UI; attack2 → policy-aware world pickup/drop.
/// </summary>
internal sealed class VisiblePocketInputBridge : Component
{
	protected override void OnUpdate()
	{
		if ( LifePunchMenuInputBlock.IsAnyMenuOpen )
			return;

		if ( !Config.Current.Game.PocketEnabled )
		{
			return;
		}

		var player = Player.Local;
		if ( !player.IsValid() )
		{
			return;
		}

		if ( !IsHandsEquipped( player ) )
		{
			if ( VisiblePocketHudState.IsOpen )
				VisiblePocketHudState.SetOpen( false );

			return;
		}

		if ( Input.Pressed( "reload" ) )
		{
			VisiblePocketHudState.ToggleOpen();
			Input.Clear( "reload" );
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
			.UseHitboxes()
			.IgnoreGameObjectHierarchy( player.GameObject )
			.WithoutTags( Constants.TraceIgnoreTags )
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

	private static bool IsHandsEquipped( Player player )
	{
		var equipment = player.CurrentEquipment;
		return equipment.IsValid() && equipment.Identifier == "hands";
	}
}
#endif
