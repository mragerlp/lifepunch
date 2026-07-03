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
using LifePunch.DXRP.Addons;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
#endif

namespace LifePunch.DXRP.Addons.Dev;

/// <summary>
/// Staging hub power state — OFF/ON drives fence LEDs + status point light. USE opens staging panel.
/// Drop-in until <see cref="Bitcoin.LpBitcoinHubEntity"/> remounts on greenfield lane.
/// </summary>
public sealed class LpBitcoinStagingHubPower : Component, Component.IPressable
{
	[Sync( SyncFlags.FromHost )] public bool IsPowered { get; private set; }

	[Property] public LpBitcoinStagingHubVisuals Visuals { get; set; }

	protected override void OnStart()
	{
		EnsureVisuals();
		ApplyPoweredState( IsPowered );
	}

	public bool CanPress( IPressable.Event e ) => GameObject.IsValid();

	public bool Press( IPressable.Event e )
	{
		RequestOpenPanel();
		return true;
	}

	public void Hover( IPressable.Event e ) { }

	public void Blur( IPressable.Event e ) { }

	public void RequestOpenPanel() => OpenPanelHost();

	[Rpc.Host]
	private void OpenPanelHost()
	{
#if !LIFEPUNCH_LOCAL
		if ( !LifePunchMenuInteractGate.IsCallerAllowed( Rpc.Caller, GameObject ) )
			return;
#endif
		LpBitcoinStagingHubUiHost.Open( this );
	}

	public void SetPowered( bool on ) => SetPoweredHost( on );

	[Rpc.Host]
	public void SetPoweredHost( bool on )
	{
#if !LIFEPUNCH_LOCAL
		if ( !Networking.IsHost )
			return;
#endif
		IsPowered = on;
		ApplyPoweredState( on );
	}

	public void ApplyPoweredState( bool on )
	{
		EnsureVisuals();
		Visuals?.ApplyPowerVisuals( on );
	}

	internal void EnsureVisuals()
	{
		if ( !Visuals.IsValid() )
			Visuals = Components.Get<LpBitcoinStagingHubVisuals>( FindMode.EverythingInSelf );

		if ( !Visuals.IsValid() )
		{
			Visuals = GameObject.AddComponent<LpBitcoinStagingHubVisuals>();
			Visuals.Power = this;
		}
		else if ( !Visuals.Power.IsValid() )
		{
			Visuals.Power = this;
		}
	}
}
