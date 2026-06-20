// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH DXRP Addons" (s&box ident: lifepunch.* · addon ident: lifepunch)
// ─────────────────────────────────────────────────────────────────────────────

using System.Linq;
using Sandbox;

namespace LifePunch.DXRP.Addons;

/// <summary>
/// While a LifePunch menu is open, UI mouse clicks must not fire weapons or DXRP Hands actions.
/// Panels call <see cref="NotifyMenuOpened"/> / <see cref="NotifyMenuClosed"/> from
/// <c>OnEnabled</c> / <c>OnDisabled</c> (PIN gate included). A scene guard applies suppression
/// every frame before equipment reads <c>Attack1</c>.
/// </summary>
public static class LifePunchMenuInputBlock
{
	private static int _openDepth;

	private static readonly string[] SuppressedActions =
	{
		"Attack1",
		"Attack2",
		"Use",
		"Reload",
		"Pocket",
		"Slot1",
		"Slot2",
		"Slot3",
		"Slot4",
		"Slot5",
		"SlotNext",
		"SlotPrev"
	};

	public static bool IsAnyMenuOpen => _openDepth > 0;

	public static void NotifyMenuOpened()
	{
		_openDepth++;
		LifePunchMenuInputGuard.Ensure( Game.ActiveScene );
		Apply();
	}

	public static void NotifyMenuClosed()
	{
		if ( _openDepth <= 0 )
			return;

		_openDepth--;
	}

	public static void Apply()
	{
		if ( !IsAnyMenuOpen )
			return;

		foreach ( var action in SuppressedActions )
		{
			Input.SetAction( action, false );
			Input.Clear( action );
			Input.ReleaseAction( action );
		}
	}
}

/// <summary>
/// Runs input suppression early each frame while any LifePunch menu is registered open.
/// </summary>
internal sealed class LifePunchMenuInputGuard : Component
{
	private const string GuardObjectName = "LifePunchMenuInputGuard";

	protected override void OnUpdate()
	{
		LifePunchMenuInputBlock.Apply();
	}

	internal static void Ensure( Scene scene )
	{
		if ( scene is null )
			return;

		var existing = scene.GetAllComponents<LifePunchMenuInputGuard>().FirstOrDefault();
		if ( existing.IsValid() )
			return;

		var go = scene.CreateObject();
		go.Name = GuardObjectName;
		go.AddComponent<LifePunchMenuInputGuard>();
	}
}
