// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// ─────────────────────────────────────────────────────────────────────────────

using Sandbox;

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>Shared UI feedback — PIN pad + rig0 terminal use DXRP purchase cha-ching.</summary>
public static class LpBitcoinUiSounds
{
	public static void PlayKeyboardClick()
	{
		if ( string.IsNullOrEmpty( LpBitcoinIdent.KeyboardSoundPath ) )
			return;

		Sound.Play( LpBitcoinIdent.KeyboardSoundPath );
	}
}
