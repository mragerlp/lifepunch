// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH Bitcoin Miner for DXRP" (s&box ident: lifepunch.bitcoin · addon ident: bitcoinmining)
// ─────────────────────────────────────────────────────────────────────────────

using System;
using System.Linq;
using Sandbox;
using LifePunch.DXRP.Addons;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
using Dxura.RP.Shared;
#endif

namespace LifePunch.DXRP.Addons.Bitcoin;

/// <summary>CRT terminal prop — world LCD telemetry + USE opens command console.</summary>
[Title( "LIFEPUNCH Bitcoin Terminal (v2)" )]
[Category( "LifePunch/Bitcoin" )]
#if LIFEPUNCH_LOCAL
public sealed class LpBitcoinTerminalEntity : Component, Component.IPressable
#else
public sealed class LpBitcoinTerminalEntity : BaseEntity, Component.IPressable
#endif
{
	private const float ScreenRefreshSeconds = 0.25f;

	[Property] public float LinkRange { get; set; } = 512f;
	[Property] public TextRenderer ScreenText { get; set; }

#if !LIFEPUNCH_LOCAL
	public override string DisplayName => LpBitcoinIdent.TerminalDisplayName;
#endif

	private string _cachedScreenText;
	private bool _occluded;

	protected override void OnAwake()
	{
		// Prefab editor + runtime: green BoxCollider must match ModelDoc white wireframe (model.Bounds).
		LifePunchPropPhysics.SyncBoxColliderFromModel( GameObject );
	}

	protected override void OnStart()
	{
		base.OnStart();
#if !LIFEPUNCH_LOCAL
		this.TryBindSpawnOwnerHost();
		if ( Networking.IsHost )
			LifePunchGroundContact.AlignMeshBottom( GameObject );
#else
		LifePunchGroundContact.AlignMeshBottom( GameObject );
#endif

		if ( !ScreenText.IsValid() )
			ScreenText = GameObject.Children.FirstOrDefault( c => c.Name == "lcd_screen" )?.GetComponent<TextRenderer>();

		RefreshScreenIdle();
	}

#if !LIFEPUNCH_LOCAL
	public override void OnOcclusionChanged( bool occlude )
	{
		base.OnOcclusionChanged( occlude );
		_occluded = occlude;
	}
#endif

	protected override void OnUpdate()
	{
#if !LIFEPUNCH_LOCAL
		if ( _occluded || GameManager.IsHeadless )
			return;

		if ( Cooldown.Current.CheckAndStartCooldown( $"{GameObject.Id}:lcd", ScreenRefreshSeconds ) )
			return;
#endif

		RefreshScreenIdle();
	}

	/// <summary>Push hub telemetry to every terminal linked to this hub.</summary>
	public static void RefreshForHub( LpBitcoinHubEntity hub )
	{
		if ( hub is null || !hub.IsValid() )
			return;

		var scene = hub.GameObject.Scene ?? Game.ActiveScene;
		if ( scene is null )
			return;

		foreach ( var terminal in scene.GetAllComponents<LpBitcoinTerminalEntity>() )
		{
			if ( !terminal.IsValid() )
				continue;

			var linked = terminal.FindLinkedHub();
			if ( linked.IsValid() && linked.GameObject.Id == hub.GameObject.Id )
				terminal.RefreshScreenIdle();
		}
	}

	public void RefreshScreenIdle()
	{
		if ( !ScreenText.IsValid() )
			return;

		var text = LpBitcoinTerminalScreen.Build( FindLinkedHub() );
		if ( string.Equals( text, _cachedScreenText, StringComparison.Ordinal ) )
			return;

		_cachedScreenText = text;
		ScreenText.Text = text;
	}

	public bool CanPress( IPressable.Event e ) => LifePunchMenuInteractGate.CanPressMenu( GameObject );

	public bool Press( IPressable.Event e )
	{
		RequestOpenTerminal();
		return true;
	}

	public void Hover( IPressable.Event e ) { }
	public void Blur( IPressable.Event e ) { }

	public void RequestOpenTerminal() => OpenTerminalHost();

	[Rpc.Host]
	private void OpenTerminalHost()
	{
#if !LIFEPUNCH_LOCAL
		if ( !LifePunchMenuInteractGate.IsCallerAllowed( Rpc.Caller, GameObject ) )
			return;
#else
		if ( !LifePunchMenuInteractGate.IsCallerAllowed( null, GameObject ) )
			return;
#endif

		var hub = FindLinkedHub();
		if ( hub is null )
		{
			Log.Warning( "[lifepunch.bitcoin] No hub in range for terminal." );
			return;
		}

		if ( !hub.IsPowered )
		{
			Log.Warning( "[lifepunch.bitcoin] Hub power off — enable at hub admin panel." );
			return;
		}

		OpenTerminal( Rpc.CallerId, hub.GameObject.Id );
	}

	[Rpc.Broadcast]
	private void OpenTerminal( Guid callerId, Guid hubId )
	{
		if ( Connection.Local.Id != callerId )
			return;

		var hub = ResolveHub( hubId );
		if ( hub is null )
			return;

		LpBitcoinTerminalUiHost.Open( hub );
	}

	private static LpBitcoinHubEntity ResolveHub( Guid hubId )
	{
		var scene = Game.ActiveScene;
		if ( scene is null )
			return null;

		foreach ( var hub in scene.GetAllComponents<LpBitcoinHubEntity>() )
		{
			if ( hub.IsValid() && hub.GameObject.Id == hubId )
				return hub;
		}

		return null;
	}

	internal LpBitcoinHubEntity FindLinkedHub()
	{
		var scene = GameObject.Scene ?? Game.ActiveScene;
		if ( scene is null )
			return null;

		LpBitcoinHubEntity best = null;
		var bestDist = float.MaxValue;

		foreach ( var hub in scene.GetAllComponents<LpBitcoinHubEntity>() )
		{
			if ( !hub.IsValid() )
				continue;

			var dist = hub.WorldPosition.Distance( WorldPosition );
			if ( dist > LinkRange || dist >= bestDist )
				continue;

			bestDist = dist;
			best = hub;
		}

		return best;
	}
}
