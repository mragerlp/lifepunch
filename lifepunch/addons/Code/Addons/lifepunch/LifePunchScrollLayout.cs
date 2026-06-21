// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH DXRP Addons" (s&box ident: lifepunch.* · addon ident: lifepunch)
// ─────────────────────────────────────────────────────────────────────────────

using System;
using Sandbox.UI;

namespace LifePunch.DXRP.Addons;

/// <summary>
/// Stacked flex scroll metrics — row lists (waypoints, audit) need summed child height, not max.
/// </summary>
internal static class LifePunchScrollLayout
{
	public static float GetManualScrollMaxY( Panel panel )
	{
		var viewHeight = panel.Box.Rect.Height;
		if ( viewHeight <= 1f )
			return 0f;

		return Math.Max( 0f, GetStackedContentHeight( panel ) - viewHeight );
	}

	public static float GetStackedContentHeight( Panel panel )
	{
		var childCount = 0;
		var stackedHeight = 0f;
		var maxHeight = 0f;

		foreach ( var child in panel.Children )
		{
			if ( !child.IsValid )
				continue;

			childCount++;
			var height = child.Box.Rect.Height;
			stackedHeight += height;
			maxHeight = Math.Max( maxHeight, height );
		}

		return childCount > 1 ? stackedHeight : maxHeight;
	}
}
