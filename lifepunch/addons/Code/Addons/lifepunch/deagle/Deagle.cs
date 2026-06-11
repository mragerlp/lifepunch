// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "Desert Eagle" (s&box ident: lifepunch.deagle · addon ident: deagle) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

namespace LifePunch.DXRP.Addons.Deagle;

public static class Deagle
{
	public const string Package = "lifepunch.deagle";
	public const string Ident = "deagle";
	public const string DisplayName = "Desert Eagle";
	public const string Grouping = "Secondary";
	public const string WeaponClass = "handgun";
	public const string DxrpClassReference = "usp";

	public const string WorldPrefabPath = "addons/lifepunch/deagle/equipment/w_deagle/w_deagle.prefab";
	public const string ViewModelPrefabPath = "addons/lifepunch/deagle/equipment/vm_deagle/vm_deagle.prefab";
	public const string WorldModelPath = "addons/lifepunch/deagle/models/lifepunch/deagle/w_deagle/w_deagle.vmdl";
	public const string ClassWorldPrefabPlaceholder = "gameplay/equipment/weapons/usp/w_usp.prefab";
	public const string ClassViewModelPlaceholder = "gameplay/equipment/weapons/usp/vm_usp.prefab";

	public static DeagleWeaponStats Stats { get; } = new()
	{
		Damage = 0,
		RoundsPerMinute = 0,
		MagazineSize = 0,
		ReserveAmmo = 0,
		ReloadSeconds = 0f,
		RangeMeters = 0,
		SpreadDegrees = 0f,
		RecoilPitch = 0f,
		RecoilYaw = 0f,
		Automatic = false
	};
}

public sealed class DeagleWeaponStats
{
	public int Damage { get; init; }
	public int RoundsPerMinute { get; init; }
	public int MagazineSize { get; init; }
	public int ReserveAmmo { get; init; }
	public float ReloadSeconds { get; init; }
	public int RangeMeters { get; init; }
	public float SpreadDegrees { get; init; }
	public float RecoilPitch { get; init; }
	public float RecoilYaw { get; init; }
	public bool Automatic { get; init; }

	public float SecondsBetweenShots => RoundsPerMinute > 0 ? 60f / RoundsPerMinute : 0f;
}