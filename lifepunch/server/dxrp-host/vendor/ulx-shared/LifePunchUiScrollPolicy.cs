// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH DXRP Addons" (s&box ident: lifepunch.* · addon ident: lifepunch)
// ─────────────────────────────────────────────────────────────────────────────

using System;
using Sandbox.UI;

namespace LifePunch.DXRP.Addons;

/// <summary>
/// LifePunch menus use wheel scroll only — never drag-scroll (<see cref="Panel.CanDragScroll"/>).
/// Call <see cref="Apply"/> every frame while a menu is open; pass <c>resetOffset: true</c> after UI scale changes.
/// </summary>
public static class LifePunchUiScrollPolicy
{
	public static void Apply( Panel root, bool resetOffset = false )
	{
		if ( root is null || !root.IsValid )
			return;

		ApplyToPanel( root, resetOffset );

		foreach ( var panel in root.Descendants )
			ApplyToPanel( panel, resetOffset );
	}

	public static void ResetOffsets( Panel root ) => Apply( root, resetOffset: true );

	private static void ApplyToPanel( Panel panel, bool resetOffset )
	{
		if ( panel is null || !panel.IsValid )
			return;

		panel.CanDragScroll = false;

		if ( resetOffset )
		{
			panel.ScrollOffset = Vector2.Zero;
			return;
		}

		ClampScrollOffset( panel );
	}

	private static void ClampScrollOffset( Panel panel )
	{
		if ( !panel.HasScrollY && !panel.HasScrollX )
		{
			if ( panel.ScrollOffset != Vector2.Zero )
				panel.ScrollOffset = Vector2.Zero;

			return;
		}

		var offset = panel.ScrollOffset;
		var maxX = 0f;
		var maxY = 0f;

		if ( panel.HasScrollX )
		{
			var viewWidth = panel.Box.Right - panel.Box.Left;
			maxX = Math.Max( 0f, panel.ScrollSize.x - viewWidth );
		}

		if ( panel.HasScrollY )
		{
			var viewHeight = panel.Box.Bottom - panel.Box.Top;
			maxY = Math.Max( 0f, panel.ScrollSize.y - viewHeight );
		}

		var x = Math.Clamp( offset.x, 0f, maxX );
		var y = Math.Clamp( offset.y, 0f, maxY );

		if ( Math.Abs( offset.x - x ) > 0.01f || Math.Abs( offset.y - y ) > 0.01f )
			panel.ScrollOffset = new Vector2( x, y );
	}
}
