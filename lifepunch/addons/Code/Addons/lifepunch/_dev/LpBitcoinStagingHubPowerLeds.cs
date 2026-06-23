// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LifePunch Dev Tools" (s&box ident: lifepunch.dev · addon ident: dev) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using Sandbox;
using LifePunch.DXRP.Addons.Bitcoin;

namespace LifePunch.DXRP.Addons.Dev;

/// <summary>
/// Runtime emissive on hub fence LED vmat (<c>g_flSelfIllumScale</c> / <c>g_vSelfIllumTint</c>).
/// Green ON, red OFF — delegates to production <c>LpBitcoinPowerLeds</c>.
/// </summary>
public static class LpBitcoinStagingHubPowerLeds
{
	public static void ApplyHubStatusLed( ModelRenderer renderer, bool powered )
		=> LpBitcoinPowerLeds.ApplyHubStatusLed( renderer, powered );
}
