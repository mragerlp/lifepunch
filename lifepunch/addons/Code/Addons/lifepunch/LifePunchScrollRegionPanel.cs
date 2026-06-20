// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH DXRP Addons" (s&box ident: lifepunch.* · addon ident: lifepunch)
// ─────────────────────────────────────────────────────────────────────────────

using System;
using Sandbox.UI;

namespace LifePunch.DXRP.Addons;

/// <summary>
/// Manual wheel scroll for flex-bound <c>lp-ui-scroll-region</c> panels — s&box often leaves
/// <see cref="Panel.HasScrollY"/> false until layout catches up; pair with <see cref="LifePunchUiScrollPolicy"/>.
/// </summary>
public class LifePunchScrollRegionPanel : Panel
{
	private const float WheelStep = 48f;

	public LifePunchScrollRegionPanel()
	{
		CanDragScroll = false;
		AddClass( "lp-ui-scroll-region" );
	}

	public override void OnMouseWheel( Vector2 value )
	{
		if ( Math.Abs( value.y ) < 0.01f )
			return;

		var max = GetMaxScrollY();
		if ( max <= 0f )
			return;

		var next = Math.Clamp( ScrollOffset.y - value.y * WheelStep, 0f, max );
		ScrollOffset = new Vector2( 0f, next );
		PreferScrollToBottom = next >= max - 4f;
	}

	public float GetMaxScrollY()
	{
		if ( !IsValid() )
			return 0f;

		var viewHeight = Box.Rect.Height;
		if ( viewHeight <= 1f )
			return 0f;

		return Math.Max( 0f, GetContentHeight() - viewHeight );
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
			if ( !child.IsValid() )
				continue;

			contentHeight = Math.Max( contentHeight, child.Box.Rect.Height );
		}

		return contentHeight;
	}
}
