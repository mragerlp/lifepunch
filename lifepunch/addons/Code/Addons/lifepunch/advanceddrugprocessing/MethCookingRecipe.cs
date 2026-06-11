// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Advanced Drug Processing" (s&box ident: lifepunch.advanceddrugprocessing · addon ident: advanceddrugprocessing) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

namespace LifePunch.DXRP.Addons.AdvancedDrugProcessing;

public enum MethIngredient
{
	RedPhosphorus,
	MuriaticAcid,
	LithiumScrap
}

public enum MethCookStage
{
	Idle,
	PrepMix,
	Heat,
	Vent,
	Crystalize,
	Ready,
	Failed
}

/// <summary>
/// Tunable meth batch constants — inspired by GMod timed stages, LifePunch-owned values.
/// </summary>
public static class MethCookingRecipe
{
	public const int MethBagsPerBatch = 4;
	public const float MaxFuel = 100f;
	public const float MinFuelToHeat = 10f;
	public const float FuelDrainHeatPerSecond = 2f;
	public const float FuelDrainCrystalizePerSecond = 1f;

	public const float PrepMixSeconds = 20f;
	public const float HeatSeconds = 45f;
	public const float VentWindowSeconds = 8f;
	public const float CrystalizeSeconds = 40f;

	public static float StageDuration( MethCookStage stage ) => stage switch
	{
		MethCookStage.PrepMix => PrepMixSeconds,
		MethCookStage.Heat => HeatSeconds,
		MethCookStage.Vent => VentWindowSeconds,
		MethCookStage.Crystalize => CrystalizeSeconds,
		_ => 0f
	};

	public static bool RequiresIngredient( MethIngredient ingredient ) => ingredient switch
	{
		MethIngredient.RedPhosphorus => true,
		MethIngredient.MuriaticAcid => true,
		MethIngredient.LithiumScrap => true,
		_ => false
	};
}
