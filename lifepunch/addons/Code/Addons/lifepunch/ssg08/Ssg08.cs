// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "SSG 08" (s&box ident: lifepunch.ssg08 · addon ident: ssg08) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

namespace LifePunch.DXRP.Addons.Ssg08;

public static class Ssg08
{
	public const string Package = "lifepunch.ssg08";
	public const string Ident = "ssg08";
	public const string DisplayName = "SSG 08";
	public const string Grouping = "Secondary";
	public const string WeaponClass = "sniper";
	public const string DxrpClassReference = "m700";

	public const string WorldPrefabPath = "addons/lifepunch/ssg08/equipment/w_ssg08/w_ssg08.prefab";
	public const string ViewModelPrefabPath = "addons/lifepunch/ssg08/equipment/vm_ssg08/vm_ssg08.prefab";
	public const string WorldModelPath = "addons/lifepunch/ssg08/models/lifepunch/ssg08/w_ssg08/w_ssg08.vmdl";
	public const string ClassWorldPrefabPlaceholder = "gameplay/equipment/weapons/m700/w_m700.prefab";
	public const string ClassViewModelPlaceholder = "gameplay/equipment/weapons/m700/vm_m700.prefab";

	public static Ssg08WeaponStats Stats { get; } = new()
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

public sealed class Ssg08WeaponStats
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