// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// ─────────────────────────────────────────────────────────────────────────────

using System.Linq;
using Sandbox;

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>Coordinates the two bitcoin UI surfaces — only one open at a time.</summary>
internal static class LpBitcoinUi
{
	public static void CloseAll()
	{
		LpHashdUiHost.CloseOpen();
		LpBitcoinTerminalUiHost.CloseOpen();
		CloseSuiPreviews();
	}

	/// <summary>
	/// UI Designer scratch preview (<c>lp_bitcoin_sui_hub_preview</c>) mounts a static layout that
	/// shows pin + hub body at once — destroy it before opening ship Razor panels.
	/// </summary>
	public static void CloseSuiPreviews()
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
			return;

		foreach ( var go in scene.GetAllObjects( true ) )
		{
			if ( !go.IsValid() || go.Name != "LpSuiHubPreview" )
				continue;

			go.Destroy();
		}
	}

	public static LpBitcoinHubEntity GetOrCreatePreviewHub( bool withSampleRacks = false )
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
			return null;

		var existing = scene.GetAllComponents<LpBitcoinHubEntity>()
			.FirstOrDefault( h => h.IsValid() && !h.GameObject.Name.StartsWith( "LpBitcoinPreview" ) );

		if ( existing.IsValid() )
			return existing;

		var go = scene.CreateObject();
		go.Name = "LpBitcoinPreviewHub";
		var hub = go.AddComponent<LpBitcoinHubEntity>();
		hub.BindOwnerFromLocalViewer();
		hub.ApplyPoweredState( true );

		if ( withSampleRacks )
			EnsureSampleRacks( scene, hub );

		return hub;
	}

	private static void EnsureSampleRacks( Scene scene, LpBitcoinHubEntity hub )
	{
		if ( hub.GetLinkedRacks().Count > 0 )
			return;

		for ( var i = 0; i < 2; i++ )
		{
			var rackGo = scene.CreateObject();
			rackGo.Name = i == 0 ? "LpBitcoinPreviewRackStd" : "LpBitcoinPreviewRackAdv";
			var rack = rackGo.AddComponent<LpBitcoinRackEntity>();
			rack.AdvancedRack = i == 1;
			rack.LinkToHub( hub );
		}
	}
}
