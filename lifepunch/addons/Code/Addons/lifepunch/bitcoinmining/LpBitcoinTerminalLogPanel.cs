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
using System.Collections.Generic;
using Sandbox;
using Sandbox.UI;

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>Scrollback log — selectable labels with ctrl+c / ctrl+a support.</summary>
[Library( "lp_bitcoin_terminal_log_panel" )]
public sealed class LpBitcoinTerminalLogPanel : Panel
{
	private static readonly Color SelectionTint = (Color.Parse( "#f0a500" ) ?? new Color( 0.941f, 0.647f, 0f )).WithAlpha( 0.35f );

	public LpBitcoinTerminalLogPanel()
	{
		AllowChildSelection = true;
		AcceptsFocus = true;
		AddClass( "log" );
		Style.FlexGrow = 1;
		Style.FlexShrink = 1;
		Style.MinHeight = Length.Pixels( 0 );
	}

	public override void Tick()
	{
		base.Tick();

		foreach ( var label in ChildrenOfType<Label>() )
		{
			if ( label.Selectable && label.ShouldDrawSelection )
				continue;

			label.Selectable = true;
			label.ShouldDrawSelection = true;
			label.SelectionColor = SelectionTint;
		}
	}

	public override void OnButtonEvent( ButtonEvent e )
	{
		base.OnButtonEvent( e );

		if ( !e.Pressed || !e.HasCtrl )
			return;

		if ( e.Button == "A" )
		{
			if ( !HasFocus )
				return;

			SelectAllInChildren();
			e.StopPropagation = true;
			return;
		}

		if ( e.Button != "C" )
			return;

		var selected = CollectSelectedText();
		if ( string.IsNullOrEmpty( selected ) )
			return;

		Clipboard.SetText( selected );
		e.StopPropagation = true;
	}

	private string CollectSelectedText()
	{
		var parts = new List<string>();

		foreach ( var label in ChildrenOfType<Label>() )
		{
			if ( !label.HasSelection() )
				continue;

			var slice = label.GetSelectedText();
			if ( string.IsNullOrEmpty( slice ) )
				continue;

			parts.Add( slice );
		}

		return parts.Count == 0 ? string.Empty : string.Join( "\n", parts );
	}
}
