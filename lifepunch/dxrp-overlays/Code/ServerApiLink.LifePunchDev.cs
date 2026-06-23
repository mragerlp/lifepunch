// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH DXRP workspace overlay" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// is the sole-owned intellectual property of lifepunch.co. It is NOT licensed for resale,
// redistribution, sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using Dxura.RP.Shared;

namespace Dxura.RP.Game;

public partial class ServerApiLink
{
	/// <summary>
	/// Editor host play (<c>lp_authorize</c>): store portal tenant/server IDs without
	/// <see cref="Initialize"/> map/lobby bootstrap. Whitelist-safe — no reflection.
	/// </summary>
	public void ApplyDevPortalContext( InitalizeServerResponseDto response )
	{
		if ( response == null )
		{
			return;
		}

		TenantId = response.TenantId.ToString();
		ServerId = response.Id;
		RulesetId = response.RulesetId;
		_isInitialized = true;
		LastPulseTime = 0;
	}
}
