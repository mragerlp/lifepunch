// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// is the sole-owned intellectual property of lifepunch.co. It is NOT licensed for resale,
// redistribution, sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System;
using System.Linq;
using Sandbox;
using Sandbox.UI;
using LifePunch.DXRP.Addons;

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>
/// HASHD CRT scrollback — manual wheel scroll + drag-select on log labels (PowerShell-style).
/// </summary>
public sealed class LpBitcoinTerminalLogPanel : LifePunchScrollRegionPanel
{
	private static readonly Color SelectionTint = (Color.Parse( "#f0a500" ) ?? new Color( 0.941f, 0.647f, 0f )).WithAlpha( 0.35f );

	public Func<string> CopyFallback { get; set; }

	public LpBitcoinTerminalLogPanel()
	{
		CanDragScroll = false;
		AcceptsFocus = true;
		AllowChildSelection = true;
	}

	public override void OnButtonEvent( ButtonEvent e )
	{
		if ( e.Pressed && e.HasCtrl && e.Button is "c" or "C" )
		{
			if ( TryCopySelection() )
			{
				e.StopPropagation = true;
				return;
			}

			var text = CopyFallback?.Invoke();
			if ( !string.IsNullOrEmpty( text ) )
			{
				Clipboard.SetText( text );
				e.StopPropagation = true;
				return;
			}
		}

		base.OnButtonEvent( e );
	}

	public void ApplyLineSelectionChrome()
	{
		foreach ( var label in Descendants.OfType<Label>() )
		{
			label.Selectable = true;
			label.ShouldDrawSelection = true;
			label.SelectionColor = SelectionTint;
		}
	}

	private bool TryCopySelection()
	{
		foreach ( var label in Descendants.OfType<Label>() )
		{
			if ( !label.HasSelection() )
				continue;

			var text = label.GetClipboardValue( false );
			if ( string.IsNullOrEmpty( text ) )
				continue;

			Clipboard.SetText( text );
			return true;
		}

		return false;
	}
}
