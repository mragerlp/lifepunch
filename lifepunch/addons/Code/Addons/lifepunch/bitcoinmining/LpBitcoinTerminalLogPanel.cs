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
using Sandbox;
using Sandbox.UI;

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>Scrollback log host — ctrl+c copies full scrollback via <see cref="ProvideCopyText"/>.</summary>
[Library( "lp_bitcoin_terminal_log_panel" )]
public sealed class LpBitcoinTerminalLogPanel : Panel
{
	public Func<string> ProvideCopyText { get; set; }

	public LpBitcoinTerminalLogPanel()
	{
		AcceptsFocus = true;
		AddClass( "log" );
		Style.FlexGrow = 1;
		Style.FlexShrink = 1;
		Style.MinHeight = Length.Pixels( 0 );
	}

	public override void OnButtonEvent( ButtonEvent e )
	{
		base.OnButtonEvent( e );

		if ( !e.Pressed || !e.HasCtrl || e.Button != "C" )
			return;

		var text = ProvideCopyText?.Invoke() ?? string.Empty;
		if ( string.IsNullOrEmpty( text ) )
			return;

		Clipboard.SetText( text );
		e.StopPropagation = true;
	}
}
