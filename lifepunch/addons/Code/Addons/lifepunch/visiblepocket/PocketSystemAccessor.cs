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
using System.Collections.Generic;
using System.Reflection;
using Dxura.RP.Game;
using Sandbox;

namespace LifePunch.DXRP.Addons.VisiblePocket;

/// <summary>
/// Read/write adapter for DXRP <see cref="PocketSystem"/> storage — swap point if Dxura exposes a public API.
/// </summary>
internal static class PocketSystemAccessor
{
	private static FieldInfo _pocketsField;

	public static Dictionary<long, List<GameObject>> GetPockets()
	{
		var instance = PocketSystem.Instance;
		if ( !instance.IsValid() )
		{
			return null;
		}

		_pocketsField ??= typeof( PocketSystem ).GetField(
			"Pockets",
			BindingFlags.Instance | BindingFlags.NonPublic );

		if ( _pocketsField == null )
		{
			Log.Error( "[VisiblePocket] PocketSystem.Pockets field missing — DXRP API drift." );
			return null;
		}

		return _pocketsField.GetValue( instance ) as Dictionary<long, List<GameObject>>;
	}

	public static int GetCount( long steamId )
	{
		var pockets = GetPockets();
		if ( pockets == null || !pockets.TryGetValue( steamId, out var list ) )
		{
			return 0;
		}

		return list.Count;
	}

	public static IReadOnlyList<GameObject> GetItems( long steamId )
	{
		var pockets = GetPockets();
		if ( pockets == null || !pockets.TryGetValue( steamId, out var list ) || list.Count == 0 )
		{
			return [];
		}

		return list;
	}
}
#endif
