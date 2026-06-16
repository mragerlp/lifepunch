// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// ─────────────────────────────────────────────────────────────────────────────

using Sandbox;

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>
/// Toggles emissive/self-illum on vmdl materials at runtime (power/mining indicator LEDs).
/// Uses <c>g_flSelfIllumScale</c> on the renderer scene object — materials with <c>F_SELF_ILLUM</c> only.
/// </summary>
public static class LpBitcoinPowerLeds
{
	private const string SelfIllumScaleAttr = "g_flSelfIllumScale";

	public const float HubLedOn = 2.5f;
	public const float RackGpuLedOn = 1.5f;

	public static void ApplyHubFenceLeds( ModelRenderer renderer, bool powered )
		=> ApplySelfIllum( renderer, powered ? HubLedOn : 0f );

	public static void ApplyRackGpuLeds( ModelRenderer renderer, bool active, float intensity01 = 1f )
	{
		var scale = active ? RackGpuLedOn * Math.Clamp( intensity01, 0f, 1f ) : 0f;
		ApplySelfIllum( renderer, scale );
	}

	public static void ApplySelfIllum( ModelRenderer renderer, float scale )
	{
		if ( !renderer.IsValid() )
			return;

		var sceneObject = renderer.SceneObject;
		if ( sceneObject is null || !sceneObject.IsValid() )
			return;

		sceneObject.Attributes.Set( SelfIllumScaleAttr, scale );
	}
}
