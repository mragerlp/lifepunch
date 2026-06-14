// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// ─────────────────────────────────────────────────────────────────────────────

using System;
using System.Threading.Tasks;
using Sandbox;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
#endif

namespace LifePunch.DXRP.Addons.Bitcoin;

internal static class LpBitcoinWallet
{
	public static async Task<bool> TryCharge( Guid callerId, uint amount, string reason )
	{
#if LIFEPUNCH_LOCAL
		await Task.CompletedTask;
		return true;
#else
		var player = GameUtils.GetPlayerByConnectionId( callerId );
		return player.IsValid() && await player.ChargeHost( amount, reason );
#endif
	}

	public static async Task<bool> TryPay( Guid callerId, uint amount, string reason )
	{
#if LIFEPUNCH_LOCAL
		await Task.CompletedTask;
		return true;
#else
		var player = GameUtils.GetPlayerByConnectionId( callerId );
		return player.IsValid() && await player.PayHost( amount, reason );
#endif
	}

	public static int GetLocalCash()
	{
#if LIFEPUNCH_LOCAL
		return 999_999;
#else
		return Player.Local.IsValid() ? (int)Player.Local.WalletBalance : 0;
#endif
	}
}
