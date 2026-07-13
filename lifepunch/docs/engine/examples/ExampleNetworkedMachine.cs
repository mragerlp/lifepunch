// ============================================================
// ExampleNetworkedMachine.cs — GOLDEN EXAMPLE **CANDIDATE**
// Canon home when landed: docs/engine/examples/ExampleNetworkedMachine.cs
//
// STATUS: AUTHORED BY FABLE, **NOT COMPILE-PROVEN**. Per
// SBOX_CONTEXT.md §7 this file is a CANDIDATE until Red's first
// editor gate produces a compile/hotload log postdating this
// write plus the positive code-string ID "LP_EXAMPLE_SENSOR".
// Red machine-verifies every idiom against the pinned fork and
// corrects freely; corrections are the point.
//
// WHAT IT DEMONSTRATES (one small world machine, every core law):
//   Scene System component (no legacy Entity) · [Property] editor
//   surface · [Sync] replication · host-gated tick · [Rpc.Host] +
//   Rpc.CallerId interaction · uint money with zero-clamp ·
//   debit-before-await + additive restore · loud ERROR sentinel ·
//   LP_*_SENSOR issuance logging · no #if CLIENT/SERVER.
// ============================================================

using System;
using System.Threading.Tasks;

namespace LifePunch.Examples;

/// <summary>
/// A minimal pay-to-run world machine: a player pays a cash fee
/// to power it; while powered it accrues "work units" on the host
/// and replicates state to all clients.
/// </summary>
public sealed class ExampleNetworkedMachine : Component
{
	// ---- Tunables: [Property] = editor/prefab surface. Real
	// addons load these via the T3 + Store hybrid config pattern
	// (SBOX_CONTEXT.md §4); a golden example keeps them visible.
	[Property] public uint ActivationCost { get; set; } = 250;
	[Property] public float SecondsPerWorkUnit { get; set; } = 5f;

	// ---- Replicated state: [Sync] or it does not exist on
	// clients. UI reads these; only the host writes them.
	[Sync] public bool IsPowered { get; set; }
	[Sync] public int WorkUnits { get; set; }

	private float _sinceWork;

	// ---- Host-gated tick. The IsHost gate is the FIRST line of
	// any authoritative loop — clients run OnFixedUpdate too.
	protected override void OnFixedUpdate()
	{
		if ( !Networking.IsHost ) return;
		if ( !IsPowered ) return;

		_sinceWork += Time.Delta;
		if ( _sinceWork < SecondsPerWorkUnit ) return;
		_sinceWork = 0f;

		WorkUnits++;
		// Issuance/production is NEVER silent (J4-F3 law).
		Log.Info( $"LP_EXAMPLE_SENSOR work-unit machine={GameObject.Id} total={WorkUnits}" );
	}

	// ---- Player interaction: [Rpc.Host] runs on the host no
	// matter who calls; Rpc.CallerId identifies the caller.
	// Permission/ownership checks go here, first.
	[Rpc.Host]
	public void RequestPowerOn()
	{
		if ( IsPowered ) return;

		var caller = PlayerFromCallerId( Rpc.CallerId );
		if ( caller is null ) return;

		_ = PowerOnHostAsync( caller );
	}

	// ---- The money pattern, in full (SBOX_CONTEXT.md §3):
	// debit BEFORE the await; on failure restore ONLY what was
	// debited, ADDITIVELY; clamp at zero; ERROR sentinel on
	// impossible states. Never trust a pre-await balance check as
	// payment (TOCTOU).
	private async Task PowerOnHostAsync( ExamplePlayerStub caller )
	{
		if ( caller.WalletBalance < ActivationCost )
			return;

		caller.WalletBalance -= ActivationCost;          // debit first
		var charged = ActivationCost;                    // remember EXACTLY what we took

		var ok = await ExampleBillingStub.CommitChargeAsync( caller, charged );
		if ( !ok )
		{
			caller.WalletBalance += charged;             // additive restore, exact amount
			Log.Info( $"LP_EXAMPLE_SENSOR charge-refund machine={GameObject.Id} amount={charged}" );
			return;
		}

		if ( IsPowered )
		{
			// Double-activation between debit and commit: refund
			// and scream — an impossible state must be LOUD.
			caller.WalletBalance += charged;
			Log.Error( $"LP_EXAMPLE_ERROR double-activation machine={GameObject.Id}" );
			return;
		}

		IsPowered = true;
		Log.Info( $"LP_EXAMPLE_SENSOR powered-on machine={GameObject.Id} paidBy={caller.SteamId} cost={charged}" );
	}

	// ---- Stubs so the example is self-contained. Real code uses
	// the project's Player and ServerApiClient surfaces — copy
	// THOSE idioms from shipped components, not these stubs.
	private static ExamplePlayerStub PlayerFromCallerId( Guid callerId )
		=> ExamplePlayerStub.Find( callerId );
}

public sealed class ExamplePlayerStub
{
	public ulong SteamId { get; init; }
	public uint WalletBalance { get; set; }              // money is uint; clamp on subtract
	public static ExamplePlayerStub Find( Guid callerId ) => null; // stub
}

public static class ExampleBillingStub
{
	public static Task<bool> CommitChargeAsync( ExamplePlayerStub p, uint amount )
		=> Task.FromResult( true );                      // stub
}
