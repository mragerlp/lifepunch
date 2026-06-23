// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH DXRP Addons" (s&box ident: lifepunch.* · addon ident: lifepunch)
// ─────────────────────────────────────────────────────────────────────────────

using System;
using System.Collections.Generic;
using Sandbox.UI;

namespace LifePunch.DXRP.Addons;

/// <summary>
/// Stacked flex scroll metrics and generic scroll-region detection.
/// Addon-neutral only — no lane-specific CSS class names (see DXRP_ADDON_PUBLISH_DOCTRINE § Shared UI).
/// </summary>
internal static class LifePunchScrollLayout
{
	public static bool IsManualScrollShell( Panel panel )
		=> panel is LifePunchScrollRegionPanel || panel.HasClass( "lp-ui-scroll-region" );

	/// <summary>
	/// Slot id for <see cref="LifePunchScrollRegionBootstrap"/> — first class on the panel besides <c>lp-ui-scroll-region</c>.
	/// Markup convention: <c>class="lp-ui-scroll-region {slot-id}"</c> (slot-id is owned by the addon Razor, not shared C#).
	/// </summary>
	public static string GetScrollSlotClass( Panel panel )
	{
		if ( !panel.HasClass( "lp-ui-scroll-region" ) )
			return null;

		foreach ( var className in GetClassNames( panel ) )
		{
			if ( className == "lp-ui-scroll-region" )
				continue;

			if ( !string.IsNullOrWhiteSpace( className ) )
				return className;
		}

		return null;
	}

	private static List<string> GetClassNames( Panel panel )
	{
		var classText = panel.Classes.ToString();
		if ( string.IsNullOrWhiteSpace( classText ) )
			return [];

		return new List<string>( classText.Split( ' ', StringSplitOptions.RemoveEmptyEntries ) );
	}

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
