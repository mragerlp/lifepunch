// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// is the sole-owned intellectual property of lifepunch.co. It is NOT licensed for resale,
// redistribution, sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using Sandbox;
using Sandbox.UI;

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>rig@hub&gt; prompt — drag-select, ctrl+c/x/v, amber selection tint.</summary>
[Library( "lp_bitcoin_terminal_cmd_input" )]
public sealed class LpBitcoinTerminalCommandInput : TextEntry
{
	private static readonly Color SelectionTint = Color.Parse( "#f0a500" ).WithAlpha( 0.35f );

	public LpBitcoinTerminalCommandInput()
	{
		SelectionColor = SelectionTint;
		AcceptsFocus = true;
		AddClass( "cmd-input" );
	}

	public override void OnPaste( string text )
	{
		if ( string.IsNullOrEmpty( text ) )
			return;

		base.OnPaste( text );
	}
}
