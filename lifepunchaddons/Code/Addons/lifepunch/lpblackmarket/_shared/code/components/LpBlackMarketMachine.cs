// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH™ Black Market Dealer for DXRP" (s&box ident: lifepunch.blackmarket · addon ident: blackmarketdealer) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Author account: mrragerlp · Public alias (in-game · Steam · Discord): Bloodwave
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System;
using System.Collections.Generic;
using Sandbox;

namespace LifePunch.DXRP.Addons.BlackMarket;

/// <summary>
/// Machine states per LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md §4 (Law 6).
/// BM-S2 wires OFF → BOOTING → RUNNING only; OVERCLOCKED / BROKEN / HACKED are later slices.
/// </summary>
public enum LpBlackMarketMachineState
{
	Off,
	Booting,
	Running
}

/// <summary>
/// Shared digital-machine base for BM-S2 entities (storefront, dead-drop).
/// Content-only slice (#147): host-authoritative OFF → BOOTING → RUNNING state machine,
/// USE-prompt interaction, placeholder inventory. ZERO economy — this class must never
/// reference any wallet, bank, BTC, balance, ledger, market-grant, or payout API.
/// Fencing / NPC sale flows are OPEN ruling R6 and are deliberately absent.
/// </summary>
public abstract class LpBlackMarketMachine : Component, Component.IPressable
{
	/// <summary>Seconds spent in BOOTING before the machine reaches RUNNING.</summary>
	[Property] public float BootSeconds { get; set; } = 2.5f;

	/// <summary>Host-authoritative machine state. Clients read, never write.</summary>
	[Property, ReadOnly]
	[Sync( SyncFlags.FromHost )]
	public LpBlackMarketMachineState State { get; private set; } = LpBlackMarketMachineState.Off;

	private TimeSince _sinceBootStarted;

	/// <summary>Ship entity slug (folder name = slug per PACKAGE_STAGING_LAYOUT.md).</summary>
	protected abstract string EntitySlug { get; }

	/// <summary>
	/// Placeholder inventory shown while RUNNING. Display-only labels — these are NOT
	/// market rows, content references, prices, or grants. Real catalog is gated on
	/// rulings R2/R3/R4 and the S4 economy slice (#149).
	/// </summary>
	protected abstract IReadOnlyList<string> PlaceholderInventory { get; }

	protected override void OnStart()
	{
		base.OnStart();
		EnsureBaselineCollision();
	}

	/// <summary>
	/// BLACKMARKET-01 baseline (TECH_DEBT.md): guarantee a single BoxCollider so USE traces
	/// and physics have an honest Phase-1 shape even before ModelDoc convex hulls exist.
	/// Endgame is authored convex hulls per LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md §2.
	/// </summary>
	private void EnsureBaselineCollision()
	{
		if ( Components.Get<Collider>( FindMode.EverythingInSelfAndDescendants ) is not null )
			return;

		var box = Components.Create<BoxCollider>();
		var renderer = Components.Get<ModelRenderer>( FindMode.EverythingInSelfAndDescendants );
		if ( renderer?.Model is not null )
		{
			var bounds = renderer.Model.Bounds;
			box.Center = bounds.Center;
			box.Scale = bounds.Size;
		}
		else
		{
			// Box-before-bones: no mesh yet (prefab/model owed) — citizen-relative stand-in.
			box.Scale = new Vector3( 32f, 32f, 48f );
			box.Center = new Vector3( 0f, 0f, 24f );
		}

		Log.Info( $"LP_BLACKMARKET_SENSOR baseline-boxcollider entity={EntitySlug} scale={box.Scale}" );
	}

	protected override void OnFixedUpdate()
	{
		base.OnFixedUpdate();
		if ( !Networking.IsHost )
			return;

		if ( State == LpBlackMarketMachineState.Booting && _sinceBootStarted >= BootSeconds )
			SetStateHost( LpBlackMarketMachineState.Running );
	}

	// ── USE prompt (Component.IPressable) ────────────────────────────────────

	public bool CanPress( IPressable.Event e ) => true;

	public bool Press( IPressable.Event e )
	{
		RequestUseHost();
		return true;
	}

	public void Hover( IPressable.Event e ) { }
	public void Blur( IPressable.Event e ) { }

	/// <summary>
	/// Host-authoritative USE. OFF → begin boot; RUNNING → surface placeholder inventory
	/// (log sensor; stub panel is a later UI slice behind #135/S5) then power down;
	/// BOOTING → ignored. No state change performs any balance/stock/grant operation.
	/// </summary>
	[Rpc.Host]
	private void RequestUseHost()
	{
		switch ( State )
		{
			case LpBlackMarketMachineState.Off:
				_sinceBootStarted = 0f;
				SetStateHost( LpBlackMarketMachineState.Booting );
				break;

			case LpBlackMarketMachineState.Running:
				LogPlaceholderInventoryHost();
				SetStateHost( LpBlackMarketMachineState.Off );
				break;

			case LpBlackMarketMachineState.Booting:
			default:
				break;
		}
	}

	private void SetStateHost( LpBlackMarketMachineState next )
	{
		if ( State == next )
			return;

		var previous = State;
		State = next;
		Log.Info( $"LP_BLACKMARKET_SENSOR state entity={EntitySlug} {previous}->{next}" );
		OnStateChangedHost( previous, next );
	}

	/// <summary>Visual/audio hooks per state land in P1–P2 (lights, sound, screen boot).</summary>
	protected virtual void OnStateChangedHost( LpBlackMarketMachineState previous, LpBlackMarketMachineState next ) { }

	private void LogPlaceholderInventoryHost()
	{
		Log.Info( $"LP_BLACKMARKET_SENSOR placeholder-inventory entity={EntitySlug} count={PlaceholderInventory.Count}" );
		foreach ( var label in PlaceholderInventory )
			Log.Info( $"LP_BLACKMARKET_SENSOR placeholder-item entity={EntitySlug} label=\"{label}\" (display-only, no price, no grant)" );
	}
}
