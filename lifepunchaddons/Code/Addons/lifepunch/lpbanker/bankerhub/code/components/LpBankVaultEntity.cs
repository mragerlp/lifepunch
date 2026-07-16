// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "LIFEPUNCH™ Banker Job for DXRP" (s&box ident: lifepunch.banker · addon ident: bankerjob) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Author account: mrragerlp · Public alias (in-game · Steam · Discord): Bloodwave
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System;
using Sandbox;

namespace LifePunch.DXRP.Addons.Banker;

/// <summary>
/// Bank vault storage machine — BANKER-S2, content-only slice (#139).
///
/// Digital-machine state stack per LIFEPUNCH_DIGITAL_MACHINE_STANDARD.md:
/// OFF → BOOTING → RUNNING, plus a door OPEN/CLOSED sub-state while RUNNING.
/// Storage is a PLACEHOLDER manifest (labels only). ZERO economy by design:
/// no deposits, withdrawals, interest, yields, fees, or wallet/bank mutations.
/// The $LP / cash hookup is S4 (#141, head-dev-only) — this component must not
/// grow a value path.
/// </summary>
[Title( "LIFEPUNCH Bank Vault (S2 baseline)" )]
[Category( "LifePunch/Banker" )]
public sealed class LpBankVaultEntity : Component, Component.IPressable
{
	/// <summary>Law 6 machine states. OVERCLOCK/BROKEN/HACKED are future design, not in S2 scope.</summary>
	public enum VaultState
	{
		Off = 0,
		Booting = 1,
		Running = 2,
	}

	private const float BootSeconds = 3f;

	/// <summary>Placeholder-only storage manifest labels. NOT items, NOT value — content dressing until a ruled inventory contract exists.</summary>
	public static readonly string[] PlaceholderManifest =
	{
		"SEALED DEPOSIT BOX 01",
		"SEALED DEPOSIT BOX 02",
		"SEALED DEPOSIT BOX 03",
		"DOCUMENT TUBE",
	};

	// Host-authoritative machine state (mirrors the LpBitcoinHubEntity snapshot idiom).
	[Property, ReadOnly] [Sync( SyncFlags.FromHost )] public int StateRaw { get; set; } = (int)VaultState.Off;

	/// <summary>Door sub-state — only meaningful while RUNNING; forced closed otherwise.</summary>
	[Property, ReadOnly] [Sync( SyncFlags.FromHost )] public bool DoorOpen { get; set; }

	public VaultState State => (VaultState)StateRaw;
	public bool IsPowered => State != VaultState.Off;

	private TimeSince _sinceBootStarted;

	protected override void OnUpdate()
	{
		if ( !Networking.IsHost )
			return;

		if ( State == VaultState.Booting && _sinceBootStarted >= BootSeconds )
			SetStateHostOnly( VaultState.Running );
	}

	// ── USE (IPressable) ────────────────────────────────────────────────────

	public bool CanPress( IPressable.Event e ) => true;

	public bool Press( IPressable.Event e )
	{
		RequestUseHost();
		return true;
	}

	public void Hover( IPressable.Event e ) { }
	public void Blur( IPressable.Event e ) { }

	/// <summary>
	/// Host-resolved USE. OFF → begin boot; BOOTING → ignored; RUNNING → toggle door.
	/// No caller identity trust needed in S2 — there is nothing of value behind the door.
	/// Ownership/PIN gating arrives with the S4 economy design, not before.
	/// </summary>
	[Rpc.Host]
	private void RequestUseHost()
	{
		switch ( State )
		{
			case VaultState.Off:
				_sinceBootStarted = 0;
				SetStateHostOnly( VaultState.Booting );
				break;

			case VaultState.Booting:
				break;

			case VaultState.Running:
				DoorOpen = !DoorOpen;
				Log.Info( $"LP_BANKVAULT_SENSOR door={( DoorOpen ? "OPEN" : "CLOSED" )} manifest={PlaceholderManifest.Length} value=NONE(content-only)" );
				break;
		}
	}

	private void SetStateHostOnly( VaultState next )
	{
		if ( State == next )
			return;

		StateRaw = (int)next;

		// Door never survives a state change — a powered-down vault is a closed vault.
		if ( next != VaultState.Running )
			DoorOpen = false;

		Log.Info( $"LP_BANKVAULT_SENSOR state={next}" );
	}
}
