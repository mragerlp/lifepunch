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

namespace LifePunch.DXRP.Addons.Dev;

/// <summary>
/// Runtime emissive on hub fence LED vmat (<c>g_flSelfIllumScale</c> / <c>g_vSelfIllumTint</c>).
/// Green ON, red OFF — matches production <c>LpBitcoinPowerLeds</c>.
/// </summary>
public static class LpBitcoinStagingHubPowerLeds
{
	private const string SelfIllumScaleAttr = "g_flSelfIllumScale";
	private const string SelfIllumTintAttr = "g_vSelfIllumTint";

	public const float HubStatusOnScale = 2.5f;
	public const float HubStatusOffScale = 1.75f;

	private static readonly Vector4 HubStatusOnTint = new( 0.15f, 1f, 0.45f, 0f );
	private static readonly Vector4 HubStatusOffTint = new( 1f, 0.12f, 0.05f, 0f );

	public static void ApplyHubStatusLed( ModelRenderer renderer, bool powered )
	{
		if ( !renderer.IsValid() )
			return;

		var sceneObject = renderer.SceneObject;
		if ( sceneObject is null || !sceneObject.IsValid() )
			return;

		sceneObject.Attributes.Set( SelfIllumTintAttr, powered ? HubStatusOnTint : HubStatusOffTint );
		sceneObject.Attributes.Set( SelfIllumScaleAttr, powered ? HubStatusOnScale : HubStatusOffScale );
	}
}
