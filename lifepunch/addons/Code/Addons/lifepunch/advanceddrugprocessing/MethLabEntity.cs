// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Advanced Drug Processing" (s&box ident: lifepunch.advanceddrugprocessing · addon ident: advanceddrugprocessing) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

using System;
using Sandbox;
#if !LIFEPUNCH_LOCAL
using Dxura.RP.Game;
#endif

namespace LifePunch.DXRP.Addons.AdvancedDrugProcessing;

/// <summary>
/// GMod-inspired meth batch cooker — single placeable lab, internal stage machine.
/// Dual-build: host tick on <c>LIFEPUNCH_LOCAL</c> or <c>OnSecondlyUpdate</c> on DXRP.
/// </summary>
[Title( "Meth Lab" )]
[Category( "LifePunch/Advanced Drug Processing" )]
[Icon( "science" )]
public sealed class MethLabEntity : Component, Component.IPressable
{
	[Property] public TextRenderer StatusDisplay { get; set; }
	[Property] public ModelRenderer ModelRenderer { get; set; }

	[Sync( SyncFlags.FromHost )] public MethCookStage Stage { get; set; } = MethCookStage.Idle;
	[Sync( SyncFlags.FromHost )] public float StageProgress { get; set; }
	[Sync( SyncFlags.FromHost )] public float FuelLevel { get; set; } = MethCookingRecipe.MaxFuel;

	[Sync( SyncFlags.FromHost )] public bool HasRedPhosphorus { get; set; }
	[Sync( SyncFlags.FromHost )] public bool HasMuriaticAcid { get; set; }
	[Sync( SyncFlags.FromHost )] public bool HasLithiumScrap { get; set; }

	private TimeSince _stageSince;
	private TimeSince _fuelSince;

	protected override void OnStart()
	{
		GameObject.Tags.Add( "meth_lab" );
		RefreshDisplay();
	}

	protected override void OnUpdate()
	{
		if ( Networking.IsHost )
			HostTick( Time.Delta );

		RefreshDisplay();
	}

	private void HostTick( float delta )
	{
		if ( Stage is MethCookStage.Idle or MethCookStage.Ready or MethCookStage.Failed )
			return;

		if ( Stage is MethCookStage.Heat or MethCookStage.Crystalize )
			DrainFuel( delta );

		if ( _stageSince >= MethCookingRecipe.StageDuration( Stage ) )
			AdvanceStageHost();
		else
			StageProgress = _stageSince / Math.Max( MethCookingRecipe.StageDuration( Stage ), 0.01f );
	}

	private void DrainFuel( float delta )
	{
		var rate = Stage == MethCookStage.Heat
			? MethCookingRecipe.FuelDrainHeatPerSecond
			: MethCookingRecipe.FuelDrainCrystalizePerSecond;

		_fuelSince += delta;
		if ( _fuelSince < 1f )
			return;

		_fuelSince = 0f;
		FuelLevel = Math.Max( 0f, FuelLevel - rate );

		if ( FuelLevel < MethCookingRecipe.MinFuelToHeat )
			FailBatchHost( "OUT OF FUEL" );
	}

	private void AdvanceStageHost()
	{
		switch ( Stage )
		{
			case MethCookStage.PrepMix:
				Stage = MethCookStage.Heat;
				break;
			case MethCookStage.Heat:
				Stage = MethCookStage.Vent;
				break;
			case MethCookStage.Vent:
				FailBatchHost( "PRESSURE — VENT MISSED" );
				return;
			case MethCookStage.Crystalize:
				Stage = MethCookStage.Ready;
				break;
			default:
				return;
		}

		ResetStageTimer();
	}

	private void ResetStageTimer()
	{
		_stageSince = 0f;
		StageProgress = 0f;
	}

	private void FailBatchHost( string reason )
	{
		Stage = MethCookStage.Failed;
		StageProgress = 0f;
		Log.Warning( $"MethLab: batch failed — {reason}" );
	}

	public bool CanPress( IPressable.Event e ) => true;

	public bool Press( IPressable.Event e )
	{
		RequestPressHost();
		return true;
	}

	public void RequestPressHost() => DispatchPressHost();

	[Rpc.Host]
	private void DispatchPressHost()
	{
#if !LIFEPUNCH_LOCAL
		if ( !GameUtils.HasPermission( Rpc.Caller, GameObject ) )
			return;

		var player = GameUtils.GetPlayerByConnectionId( Rpc.CallerId );
		if ( !player.IsValid() )
			return;

		HandlePressHost( player.GameObject );
#else
		HandlePressHost( null );
#endif
	}

	private void HandlePressHost( GameObject presser )
	{
		switch ( Stage )
		{
			case MethCookStage.Idle:
				TryStartCookHost( presser );
				break;
			case MethCookStage.Vent:
				Stage = MethCookStage.Crystalize;
				ResetStageTimer();
				break;
			case MethCookStage.Ready:
				HarvestHost( presser );
				break;
			case MethCookStage.Failed:
				ResetBatchHost();
				break;
		}
	}

	private void TryStartCookHost( GameObject presser )
	{
		if ( !HasAllIngredients() )
		{
			Log.Info( "MethLab: missing chemicals — use lp_meth_fill (dev) or buy reagents." );
			return;
		}

		if ( FuelLevel < MethCookingRecipe.MinFuelToHeat )
		{
			Log.Info( "MethLab: fuel too low — refill propane (Phase 2)." );
			return;
		}

#if !LIFEPUNCH_LOCAL
		if ( !IsDrugDealer( presser ) )
		{
			Log.Info( "MethLab: Drug Dealer job required." );
			return;
		}
#endif

		ConsumeIngredients();
		Stage = MethCookStage.PrepMix;
		ResetStageTimer();
	}

	private void HarvestHost( GameObject presser )
	{
		var bags = MethCookingRecipe.MethBagsPerBatch;
#if !LIFEPUNCH_LOCAL
		Log.Info( $"MethLab: harvested {bags} meth bags (inventory hook TBD)." );
#else
		Log.Info( $"MethLab: harvested {bags} meth bags (local stub)." );
#endif

		ResetBatchHost();
	}

	private void ResetBatchHost()
	{
		Stage = MethCookStage.Idle;
		StageProgress = 0f;
		_stageSince = 0f;
	}

	private bool HasAllIngredients() =>
		HasRedPhosphorus && HasMuriaticAcid && HasLithiumScrap;

	private void ConsumeIngredients()
	{
		HasRedPhosphorus = false;
		HasMuriaticAcid = false;
		HasLithiumScrap = false;
	}

	/// <summary>Dev / Phase 2 — fill all reagent slots.</summary>
	public void DevFillIngredients()
	{
		if ( !Networking.IsHost )
			return;

		HasRedPhosphorus = true;
		HasMuriaticAcid = true;
		HasLithiumScrap = true;
	}

#if !LIFEPUNCH_LOCAL
	private static bool IsDrugDealer( GameObject presser )
	{
		var player = presser?.Components.Get<Player>( FindMode.EverythingInSelfAndAncestors );
		if ( !player.IsValid() )
			return true;

		var label = player.JobDisplayName ?? "";
		return label.Contains( "drug", StringComparison.OrdinalIgnoreCase );
	}
#endif

	private void RefreshDisplay()
	{
		if ( !StatusDisplay.IsValid() )
			return;

		var pct = (int)( StageProgress * 100f );
		var bar = Stage switch
		{
			MethCookStage.Ready => "[████████████] DONE",
			MethCookStage.Failed => "[!! FAILED !!]",
			MethCookStage.Idle => "[            ] IDLE",
			_ => $"[{new string( '█', pct / 8 ).PadRight( 12 )}] {pct}%"
		};

		StatusDisplay.Text =
			$"LIFEPUNCH METH LAB\n" +
			$"STAGE  {Stage}\n" +
			$"FUEL   {FuelLevel:0}/{MethCookingRecipe.MaxFuel:0}\n" +
			$"REAGENT RP:{YN( HasRedPhosphorus )} MA:{YN( HasMuriaticAcid )} LI:{YN( HasLithiumScrap )}\n" +
			$"{bar}\n" +
			HintLine();

		StatusDisplay.Color = Stage == MethCookStage.Failed
			? Color.Parse( "#E4002B" ) ?? Color.Red
			: Color.Parse( "#00FF7F" ) ?? Color.Green;
	}

	private static string YN( bool v ) => v ? "Y" : "N";

	private string HintLine() => Stage switch
	{
		MethCookStage.Idle => "USE — start batch",
		MethCookStage.Vent => "USE — vent pressure",
		MethCookStage.Ready => "USE — harvest",
		MethCookStage.Failed => "USE — reset",
		_ => "WAIT — cooking"
	};
}
