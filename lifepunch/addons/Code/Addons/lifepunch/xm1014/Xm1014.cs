// ─────────────────────────────────────────────────────────────────────────────
// PROPRIETARY & CONFIDENTIAL — © 2026 lifepunch.co. All rights reserved.
//
// "XM1014" (s&box ident: lifepunch.xm1014 · addon ident: xm1014) is the sole-owned
// intellectual property of lifepunch.co. It is NOT licensed for resale, redistribution,
// sublicensing, copying, or reuse by ANY person or entity — including DXRP and
// LifePunch staff, contributors, or community — EXCEPT the owner (lifepunch.co).
// Presence in this repository or on the DXRP portal grants no rights to anyone else.
// ─────────────────────────────────────────────────────────────────────────────

namespace LifePunch.DXRP.Addons.Xm1014;

public static class Xm1014
{
	public const string Package = "lifepunch.xm1014";
	public const string Ident = "xm1014";
	public const string DisplayName = "XM1014";
	public const string Grouping = "Secondary";
	public const string WeaponClass = "shotgun";
	public const string DxrpClassReference = "spaghelli";

	public const string WorldPrefabPath = "addons/lifepunch/xm1014/equipment/w_xm1014/w_xm1014.prefab";
	public const string ViewModelPrefabPath = "addons/lifepunch/xm1014/equipment/vm_xm1014/vm_xm1014.prefab";
	public const string WorldModelPath = "addons/lifepunch/xm1014/models/lifepunch/xm1014/w_xm1014/w_xm1014.vmdl";
	public const string ClassWorldPrefabPlaceholder = "gameplay/equipment/weapons/spaghelli/w_spaghelli.prefab";
	public const string ClassViewModelPlaceholder = "gameplay/equipment/weapons/spaghelli/vm_spaghelli.prefab";

	public static Xm1014WeaponStats Stats { get; } = new()
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

public sealed class Xm1014WeaponStats
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