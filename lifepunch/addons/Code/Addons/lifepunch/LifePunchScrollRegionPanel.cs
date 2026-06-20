// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH DXRP Addons" (s&box ident: lifepunch.* · addon ident: lifepunch)
// ─────────────────────────────────────────────────────────────────────────────

using System.Collections.Generic;
using System.Linq;
using Sandbox.UI;

namespace LifePunch.DXRP.Addons;

/// <summary>
/// Manual wheel scroll for flex-bound <c>lp-ui-scroll-region</c> panels — s&amp;box often leaves
/// <see cref="Panel.HasScrollY"/> false until layout catches up; pair with <see cref="LifePunchUiScrollPolicy"/>.
/// </summary>
public class LifePunchScrollRegionPanel : Panel
{
	private const float WheelStep = 48f;

	/// <summary>When true, new log lines stick to the bottom; wheel-up clears until user returns near bottom.</summary>
	public bool PreferScrollToBottom { get; set; } = true;

	public LifePunchScrollRegionPanel()
	{
		CanDragScroll = false;
	}

	public override void OnMouseWheel( Vector2 value )
	{
		if ( System.Math.Abs( value.y ) < 0.01f )
			return;

		var max = GetMaxScrollY();
		if ( max <= 0f )
			return;

		var next = System.Math.Clamp( ScrollOffset.y - value.y * WheelStep, 0f, max );
		ScrollOffset = new Vector2( 0f, next );
		PreferScrollToBottom = next >= max - 4f;
	}

	public float GetMaxScrollY()
	{
		if ( !IsValid )
			return 0f;

		var viewHeight = Box.Rect.Height;
		if ( viewHeight <= 1f )
			return 0f;

		return System.Math.Max( 0f, GetContentHeight() - viewHeight );
	}

	public void ScrollToBottom( bool force = false )
	{
		var max = GetMaxScrollY();
		if ( max <= 0f )
			return;

		if ( !force && !PreferScrollToBottom && ScrollOffset.y < max - 28f )
			return;

		ScrollOffset = new Vector2( 0f, max );
		PreferScrollToBottom = true;
	}

	private float GetContentHeight()
	{
		var contentHeight = 0f;

		foreach ( var child in Children )
		{
			if ( !child.IsValid )
				continue;

			contentHeight = System.Math.Max( contentHeight, child.Box.Rect.Height );
		}

		return contentHeight;
	}
}

/// <summary>
/// s&amp;box Razor cannot nest markup inside custom C# <see cref="Panel"/> tags — use
/// <c>&lt;div class="lp-ui-scroll-region"&gt;</c> in markup, then upgrade after the tree builds.
/// </summary>
public static class LifePunchScrollRegionBootstrap
{
	public static void Upgrade( Panel root )
	{
		if ( root is null || !root.IsValid )
			return;

		var sources = root.Descendants
			.Where( panel => panel is not LifePunchScrollRegionPanel && panel.HasClass( "lp-ui-scroll-region" ) )
			.ToList();

		foreach ( var source in sources )
		{
			if ( !source.IsValid )
				continue;

			var parent = source.Parent;
			if ( parent is null || !parent.IsValid )
				continue;

			var slotClass = GetScrollSlotClass( source );
			if ( slotClass is not null )
			{
				var existing = parent.Children
					.OfType<LifePunchScrollRegionPanel>()
					.FirstOrDefault( panel => panel.HasClass( slotClass ) );

				if ( existing.IsValid() )
				{
					MergeChildren( source, existing );
					source.Delete();
					continue;
				}
			}

			// Razor may emit the scroll shell a frame before its body — wait for content.
			if ( !source.Children.Any() )
				continue;

			var scroll = new LifePunchScrollRegionPanel();

			CopyPanelClasses( source, scroll );

			scroll.ScrollOffset = source.ScrollOffset;
			scroll.PreferScrollToBottom = source.PreferScrollToBottom;

			MergeChildren( source, scroll );

			var index = parent.GetChildIndex( source );
			source.Delete();
			scroll.Parent = parent;

			if ( index >= 0 )
				parent.SetChildIndex( scroll, index );
		}
	}

	private static void MergeChildren( Panel from, Panel to )
	{
		foreach ( var child in from.Children.ToList() )
			child.Parent = to;
	}

	private static string GetScrollSlotClass( Panel panel )
	{
		if ( panel.HasClass( "upgrades-scroll" ) )
			return "upgrades-scroll";

		if ( panel.HasClass( "racks-scroll" ) )
			return "racks-scroll";

		if ( panel.HasClass( "logs-scroll" ) )
			return "logs-scroll";

		if ( panel.HasClass( "log" ) || panel.HasClass( "terminal-log-scroll" ) )
			return "log";

		if ( panel.HasClass( "terminal-sidebar-scroll" ) )
			return "terminal-sidebar-scroll";

		return null;
	}

	public static LifePunchScrollRegionPanel FindFirst( Panel root, string className )
	{
		if ( root is null || !root.IsValid )
			return null;

		foreach ( var panel in root.Descendants )
		{
			if ( panel is LifePunchScrollRegionPanel scroll && scroll.HasClass( className ) )
				return scroll;
		}

		return null;
	}

	private static void CopyPanelClasses( Panel from, Panel to )
	{
		// Panel.Classes.Split(...) is not string.Split — it returns the class string, so foreach yields char.
		var classText = from.Classes.ToString();
		if ( string.IsNullOrWhiteSpace( classText ) )
			return;

		var classNames = classText.Split( ' ', System.StringSplitOptions.RemoveEmptyEntries );
		for ( var i = 0; i < classNames.Length; i++ )
			to.AddClass( classNames[i] );
	}
}
